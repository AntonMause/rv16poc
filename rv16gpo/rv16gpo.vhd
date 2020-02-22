
----------------------------------------------------------------------
-- rv16gpo    (c) 2019 by Anton Mause
----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

----------------------------------------------------------------------
entity rv16gpo is 
generic(PLEN : natural := 10; XLEN : natural := 16);
port (
  i_clk     : in  std_logic;
  i_rst_n   : in  std_logic;
  i_gpi     : in  std_logic_vector(XLEN-1 downto 0);
  i_irdy    : in  std_logic; -- instruction ready
  i_idat    : in  std_logic_vector(31 downto 0);
  o_isel    : out std_logic; -- instruction select
  o_iadr    : out std_logic_vector(PLEN-1 downto 0);
  o_gpo     : out std_logic_vector(XLEN-1 downto 0) );
end rv16gpo;

----------------------------------------------------------------------
architecture RTL of rv16gpo is

----------------------------------------------------------------------
-- Signal declarations
----------------------------------------------------------------------
signal s_pcu_pc0, s_pcu_pc4, s_pcu_pcx, s_pcu_nxt : unsigned(15 downto 0);
signal s_clk, s_rst_n : std_logic;
signal s_pcu_bra : std_logic; -- branch is without storing PC
signal s_pcu_jmp : std_logic; -- jump is with storing PC to rd

signal s_dec_ins : std_logic_vector(31 downto 0);  -- decoder
signal s_dec_slt : std_logic; -- current opcode is set lower than xyz
signal s_dec_sgn : std_logic_vector(32 downto 0);  -- sign of immediate
signal s_dec_rs1, s_dec_rs2, s_dec_rd : std_logic_vector(4 downto 0);
signal s_not_zero : std_logic;

signal s_b_type, s_i_type, s_j_type, s_s_type, s_u_type : std_logic_vector(32 downto 0);

signal s_log_in1, s_log_in2, s_log_out : std_logic_vector(16 downto 0);
signal s_log_opp : std_logic_vector(2 downto 0); -- 0=byp,1=sll,2,3,4=xor,5=srl,6=or,7=and

signal s_mac_sub, s_mac_msh, s_mac_uns : std_logic;
signal s_mac_in1, s_mac_in2, s_mac_in3, s_mac_out : std_logic_vector(16 downto 0);
signal s_mac_out_all : std_logic_vector(34 downto 0);
signal s_mac_out_sgn : signed(33 downto 0);

signal s_dat_wrt : std_logic; -- write to data bus (store instruction)

signal s_reg_wrt, s_reg_ext, s_reg_clr : std_logic;
signal s_reg_rs1, s_reg_rs2 : std_logic_vector(16 downto 0);

type reg_mem_type is array (31 downto 0) of std_logic_vector (15 downto 0);
signal s_reg_mem : reg_mem_type := ( others=>x"6666" );
signal s_reg_dat : std_logic_vector(15 downto 0);

type t_state is (I_Reset, I_Init, I_Idle, I_Fetch, I_Decode, I_Branch, I_Execute, I_Update);
signal s_cur_state, s_nxt_state : t_state;

type t_decode is (D_Load, D_Store, D_ImmOp, D_RegOp, D_Auipc, D_Lui, D_Cmp, D_Bra, D_Jal, D_Jalr);
signal s_decode : t_decode;

begin

----------------------------------------------------------------------
  s_clk     <= i_clk;
  s_rst_n   <= i_rst_n;
  
----------------------------------------------------------------------
decode_p : process(s_dec_ins)
  variable v_ins : std_logic_vector(6 downto 2);
  variable v_dec : t_decode;
  begin
    v_ins := s_dec_ins(v_ins'range); -- instruction shortform
    v_dec := D_Load;

    if(v_ins(6)='1') then     -- do  (bra | jal | jalr)
      if(v_ins(2)='1') then   -- do  (      jal | jalr)
        if(v_ins(3)='1') then -- do  (      jal       )
          v_dec := D_Jal;
        else                  -- do  (            jalr)
          v_dec := D_Jalr;
        end if;
      else                    -- do  (bra             )
        --v_dec := D_Cmp;     -- compare before branch
          v_dec := D_Bra;
      end if;
    else                      -- not (branch or jump )
      if(v_ins(4)='0') then   -- do  (load | store   )
        if(v_ins(5)='1') then -- do  (       store   )
          v_dec := D_Store;
        else                  -- do  (load           )
          v_dec := D_Load;
        end if;
      end if;
    end if;
    if(v_ins(4)='1') then     -- do  (any register op)
      if(v_ins(2)='1') then   -- do  (lui | auipc)
        if(v_ins(5)='1') then -- do  (lui        )
          v_dec := D_Lui;
        else                  -- do  (      auipc)
          v_dec := D_Auipc;
        end if;
      else                    -- do  (any to reg op)
        if(v_ins(5)='1') then -- do  (reg to reg op)
          v_dec := D_RegOp;
        else                  -- do  (#im to reg op)
          v_dec := D_ImmOp;
        end if;
      end if;
    end if;
    s_decode <= v_dec;
  end process;
  -- 65432   x=0   x=1   -=ignore
  -- 0x0--   load  store
  -- -x1-0   op#   op
  -- -x1-1   auipc lui
  -- 1---x   bra   jal*
  -- 1--x1   jalr  jal

  s_dec_sgn <= (others=>'1') when (s_dec_ins(31) = '1') else (others=>'0');
  s_b_type <= s_dec_sgn(32 downto 12)& s_dec_ins(7)& s_dec_ins(30 downto 25) & s_dec_ins(11 downto 8)& '0'; -- B-Type 
  s_i_type <= s_dec_sgn(32 downto 12)& s_dec_ins(31 downto 20);                                             -- I-Type
  s_j_type <= s_dec_sgn(32 downto 20)& s_dec_ins(19 downto 12)& s_dec_ins(20)& s_dec_ins(30 downto 21)& '0';-- J-Type  
  s_s_type <= s_dec_sgn(32 downto 12)& s_dec_ins(31 downto 25)& s_dec_ins(11 downto 7);                     -- S-Type
  s_u_type <= s_dec_sgn(32)& s_dec_ins(31 downto 12)& x"000";                                               -- U-Type
 
----------------------------------------------------------------------
not_zero_p : process(s_clk) -- check if destination register s_dec_ins(11 downto 7) is not zero
  begin
    if (s_clk'event and s_clk = '1') then
      if s_dec_ins(10 downto 7) = "0000" then
        s_not_zero <= s_dec_ins(11);
      else
        s_not_zero <= '1';
      end if;
    end if;
  end process;

----------------------------------------------------------------------
state_p : process(s_clk,s_rst_n)
  begin
    if (s_rst_n = '0') then
      s_cur_state   <= I_Reset;
    elsif (s_clk'event and s_clk = '1') then
      s_cur_state   <= s_nxt_state;
    end if;
  end process;

  o_isel <= '1' when (s_nxt_state = I_Fetch) else '0';

----------------------------------------------------------------------
branch_p : process(all)
  begin
    if (s_rst_n = '0') then
      s_pcu_bra     <= '0';
    elsif (s_clk'event and s_clk = '1') then
      case s_cur_state is
      when I_Branch =>  if s_dec_ins(6 downto 2) = "11000" then
                          s_pcu_bra <= s_dec_ins(12) xor s_mac_out(16) xor s_dec_ins(14) xor '1';
                        else
                          s_pcu_bra <= '0';
                        end if;
      --when I_Update =>  s_pcu_bra <= '0';
      when I_Idle   =>  s_pcu_bra <= '0';
      when others   =>
      end case;
    end if;
  end process;

----------------------------------------------------------------------

dec32_p : process(all)
  variable v_ins : std_logic_vector(31 downto 2);
  variable v_fu3 : std_logic_vector(2 downto 0);
  variable v_rd  : std_logic_vector( 4 downto 0);
  variable v_wrt : std_logic;

  begin
    v_ins          := s_dec_ins(v_ins'range); -- instruction shortform
    v_rd           := v_ins(11 downto 7); -- dest register
    v_fu3          := v_ins(14 downto 12);
    v_wrt          := '1'; -- most instructions write to register
    s_reg_ext      <= '0';
    s_pcu_jmp      <= '0';
    s_log_in1      <= s_reg_rs1;
    s_log_in2      <= s_reg_rs2;
    s_log_opp      <= "000"; -- bypass
    s_mac_in1      <= (0=>'1', others=>'0');
    s_mac_in3      <= s_reg_rs1;
    s_mac_sub      <= '0'; -- 0=add, 1=subtract c-(a*b)
    s_mac_msh      <= '0'; -- 0=low half, 1=upper half
    s_mac_uns      <= '0'; -- 0=signed, 1=unsigned
    s_dat_wrt      <= '0';
    s_dec_slt      <= '0'; -- any SLT instruction in progress

    case s_cur_state is
    when I_Reset   =>  s_nxt_state   <= I_Init;
    when I_Init    =>  s_nxt_state   <= I_Idle;
    when I_Idle    =>  s_nxt_state   <= I_Fetch;
    when I_Fetch   =>  s_nxt_state   <= I_Execute;
    when I_Branch  =>  s_nxt_state   <= I_Execute;
    when I_Execute =>  s_nxt_state   <= I_Update;
    when I_Update  =>  s_nxt_state   <= I_Idle;
    when others    =>  s_nxt_state   <= I_Idle;
    end case;

	-- Main instruction decoder #############################################
	case s_decode is
	when D_Lui =>     -- rd = #Imm
      s_mac_in3 <= (others=>'0');
      s_log_in2 <= s_u_type(32) & s_u_type(15 downto 0);

	when D_Auipc =>   -- rd = pc + #Imm
      s_mac_in3 <= std_logic(s_pcu_pc0(15)) & std_logic_vector(s_pcu_pc0);
      s_log_in2 <= s_u_type(32) & s_u_type(15 downto 0);

	when D_Jal =>     -- pc = pc + #Imm, rd = pc +4
      s_mac_in3 <= std_logic(s_pcu_pc0(15)) & std_logic_vector(s_pcu_pc0);
      s_log_in2 <= s_j_type(32) & s_j_type(15 downto 0);
      s_pcu_jmp <= '1';

	when D_Jalr =>    -- pc = rs1 + #Imm, rd = pc +4
      s_log_in2 <= s_i_type(32) & s_i_type(15 downto 0);
      s_pcu_jmp <= '1';

	when D_Bra =>  -- 
      case s_cur_state is
      when I_IDLE | I_Fetch   =>
        s_mac_sub   <= '1'; -- 0=add 1=sub (subtract to compare)
        if (v_fu3(2 downto 1) = "00") then -- BEQ / BNE
          s_mac_in3 <= (others=>'0');  -- substract rs1 xor rs2  from zero
          s_log_opp <= "100"; -- XOR
          s_mac_uns <= '1';
        end if; -- else subtract rs2 from rs1
        if (v_fu3(2 downto 1) = "11") then -- BLTU / BGEU
          s_mac_uns <= '1'; -- subtract unsigned
        end if;
        if (s_cur_state = I_Fetch) then
          s_nxt_state <= I_Branch;
        end if;
     --when I_Execute =>
       when others =>
        s_mac_sub   <= '0'; -- 0=add 1=sub (add address offset to pc)
        s_mac_in3 <= std_logic(s_pcu_pc0(15)) & std_logic_vector(s_pcu_pc0);
        s_log_in2 <= s_b_type(32) & s_b_type(15 downto 0);
      end case;
      v_wrt     := '0';

    when D_Load =>    -- rd = #Imm(rs1)
      s_log_in2 <= s_i_type(32) & s_i_type(15 downto 0);
      s_reg_ext <= '1';

    when D_Store =>   -- #Imm(rs1) = rs2
      s_mac_in3 <= (others=>'0');
      s_log_in2 <= s_s_type(32) & s_s_type(15 downto 0);
      s_dat_wrt <= '1';
      v_wrt     := '0';

	when D_ImmOp | D_RegOp =>
      if (v_ins(5)='0') then -- 0=Immediate 1=Register
        s_log_in2 <= s_i_type(32) & s_i_type(15 downto 0);
      end if; -- else / default=rs2
      case v_fu3 is
        when "000" =>
          if (v_ins(5) = '1') then -- 0=Immediate 1=Register
            s_mac_sub <= v_ins(30); -- 0=add 1=sub
          end if;
        when "010" | "011" => -- SLT / SLTI / SLTU / SLTIU
          s_mac_sub   <= '1'; -- 0=add 1=sub (subtract to compare)
          s_mac_uns   <= v_fu3(0); 
          s_dec_slt   <= '1';
        when "001" | "101" => -- shift left / shift right
          s_mac_in1 <= s_reg_rs1;
          s_mac_in3 <= (others=>'0');
          s_log_opp <= v_fu3(2 downto 0);
          s_mac_msh <= v_fu3(2);
          -- the folowing statement only relevant for SR?
          s_mac_uns <= not v_ins(30); -- 0=signed, 1=unsigned
        when "100" | "110" | "111" => -- XOR / OR / AND
          s_mac_in3 <= (others=>'0');
          s_log_opp <= v_fu3(2 downto 0);
        when others =>
      end case;

	when others =>
      v_wrt     := '0';
    end case;

    s_reg_wrt <= '0'; -- default, do not write now ############################
    case s_cur_state is
    when I_Reset    => v_rd := (others=>'0');      -- overwrite destination ...
                       s_reg_clr <= '1';
    when I_Init     => v_rd := (others=>'0');      -- ... to zero x0 register
                       s_reg_wrt <= '1';
                       s_reg_clr <= '1';
    when I_Execute  => if (s_not_zero = '1') then
                         s_reg_wrt <= v_wrt;
                       end if;
                       s_reg_clr      <= '0';
	when others =>
                       s_reg_clr      <= '0';
    end case;
    s_dec_rd <= v_rd;

end process;

----------------------------------------------------------------------
log_p : process(s_log_opp,s_log_in1,s_log_in2)
  variable v_pos : integer;
  variable v_msk : std_logic_vector(16 downto 0);
  begin
    case s_log_opp is -- coding mostly like func3(2:0)
    when "001" => -- SLL shift left logical
      v_msk        := (others=>'0');
      v_pos        :=      to_integer(unsigned(s_log_in2(3 downto 0)));
      v_msk(v_pos) := not s_log_in2(4); -- result <= NULL if (shamt > 15)
      s_log_out    <= v_msk;
    when "101" => -- shift right logical SRL , arithmetic SRA / signed shift rigth
      v_msk        := (others=>'0');
      v_pos        := 16 - to_integer(unsigned(s_log_in2(3 downto 0)));
      v_msk(v_pos) := not s_log_in2(4); -- result <= NULL if (shamt > 15)
      s_log_out    <= v_msk;
	when "100" =>  s_log_out  <= (s_log_in1 xor s_log_in2);  -- XOR
	when "110" =>  s_log_out  <= (s_log_in1  or s_log_in2);  --  OR
	when "111" =>  s_log_out  <= (s_log_in1 and s_log_in2);  -- AND
    when others => s_log_out  <=                s_log_in2; -- bypass
  end case;
end process;

----------------------------------------------------------------------
  s_mac_in2 <= s_log_out;

mac_p : process (s_clk)
  begin
    if rising_edge(s_clk) then
      if (s_mac_sub = '0') then
        s_mac_out_sgn <= signed(s_mac_in3) + ( signed(s_mac_in1) * signed(s_mac_in2) );
     else
        s_mac_out_sgn <= signed(s_mac_in3) - ( signed(s_mac_in1) * signed(s_mac_in2) );
      end if;
    end if; 
  end process;
  s_mac_out_all <= '0' & std_logic_vector(s_mac_out_sgn);

  s_mac_out  <= std_logic_vector(s_mac_out_all(16 downto 0)) when (s_mac_msh='0')
           else std_logic_vector(s_mac_out_all(32 downto 16));

----------------------------------------------------------------------
pcu_p : process(s_clk,s_rst_n)
  begin
    if (s_rst_n = '0') then
      s_pcu_pc0     <= (others=>'0');
    elsif (s_clk'event and s_clk = '1') then
      if s_cur_state = I_Update then
        s_pcu_pc0     <= s_pcu_nxt;
      end if;
    end if;
  end process;
  s_pcu_pc4 <=  s_pcu_pc0 +4; -- point behind 32 bit instruction
  s_pcu_pcx <= (s_pcu_pc4 and x"03FC");
  s_pcu_nxt <= "000000" & unsigned(s_mac_out(9 downto 0)) when (s_pcu_bra='1') 
          else "000000" & unsigned(s_mac_out(9 downto 0)) when (s_pcu_jmp='1') 
          else s_pcu_pcx;

--handle register file memory access----------------------------------
  s_dec_rs1    <= s_dec_ins(19 downto 15); -- register source one
  s_dec_rs2    <= s_dec_ins(24 downto 20); -- register source two
  s_reg_dat    <= "00000000" & "00000000"               when (s_reg_clr='1')
           else i_gpi                                   when (s_reg_ext='1') 
           else "000000" & std_logic_vector(s_pcu_pcx(9 downto 2)) & "00" when (s_pcu_jmp='1')
           else "00000000" & "0000000" & s_mac_out(16)  when (s_dec_slt='1')
           else s_mac_out(15 downto 0);
    
reg_mem_p : process (s_clk)
  begin
    if rising_edge(s_clk) then
      if (s_reg_wrt = '1') then
        s_reg_mem(to_integer (unsigned(s_dec_rd))) <= s_reg_dat(15 downto 0);
      end if;
    end if;
  end process;
  s_reg_rs1(15 downto 0) <= s_reg_mem(to_integer (unsigned(s_dec_rs1))); -- rs1
  s_reg_rs2(15 downto 0) <= s_reg_mem(to_integer (unsigned(s_dec_rs2))); -- rs2

  s_reg_rs1(16)          <= '0' when s_mac_uns='1' else s_reg_rs1(15);
  s_reg_rs2(16)          <= '0' when s_mac_uns='1' else s_reg_rs2(15);
  
----------------------------------------------------------------------
gpo_p : process (s_clk, s_rst_n)
  begin
    if (s_rst_n = '0') then
      o_gpo <= x"6666";
    elsif (s_clk'event and s_clk = '1') then
      if (s_dat_wrt='1') then
        if s_cur_state = I_Update then
            o_gpo <= s_reg_rs2(15 downto 0);
        end if;
      end if;
    end if;
  end process;

----------------------------------------------------------------------
  o_iadr    <= std_logic_vector(s_pcu_pc0(PLEN-1 downto 0));
  s_dec_ins <= i_idat;

end RTL;

-- instr[4:2] 000    001    010    011    100    101    110     111
-- instr[6:5] 
--       00   load*  loadfp cust0  mem    op-im* auipc* op-im32 ---
--       01   stor*  storfp cust1  amo    op*    lui*   op32    ---
--       10   madd   msub   nmsub  nmadd  op-fp  res    rv128   ---
--       11   bra*   jalr*  res    jal*   sys*   res    rv128   ---

-- instr[4:2] 000    001    010    011    1-0    1-1    110     111
--       00   load   ---    ---    ---    op-im  auipc  ---     ---
--       01   stor   ---    ---    ---    op     lui    ---     ---
--       10   ---    ---    ---    ---    ---    ---    ---     ---
--       11   bra    jalr   ---    jal    ---    ---    ---     ---

-- 65432
-- 0x0--  0=load/1=store
-- -x1-0  0=op#/1=op
-- -x1-1  0=auipc/1=lui
-- 1---x  0=bra/1=jal*
-- 1--x-  0=jalr/1=jal

-- LOAD:    "00000";  1=lh
-- STORE:	"01000";  1=sh
-- AUIPC:	"00101";  1=auipc
-- LUI:		"01101";  1=lui
-- REG_IMM:	"00100";  9=slli,srli,srai,slti,sltiu,xori,ori,andi,addi
-- REG_REG:	"01100"; 10=sll,srl,sra,slt,sltu,xor,or,and,add,sub
-- BRANCH:	"11000";  8=bne,beq,blt,bge,bltu,bgeu
-- JALR:	"11001";  1=jalr
-- JAL:		"11011";  1=jal
-- SYS:		"11100";  0=ignored
