
----------------------------------------------------------------------
-- rv16poc
----------------------------------------------------------------------
-- (c) 2019 by Anton Mause
--
----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

----------------------------------------------------------------------
entity rv16poc is port (
  i_clk     : in  std_logic;
  i_rst_n   : in  std_logic;
  o_dbg     : out std_logic_vector(7 downto 0);
  o_led     : out std_logic_vector(7 downto 0) );
end rv16poc;

----------------------------------------------------------------------
architecture RTL of rv16poc is

component my17Madd is port(
        A0         : in  std_logic_vector(16 downto 0);
        A0_ACLR_N  : in  std_logic;
        A0_EN      : in  std_logic;
        A0_SCLR_N  : in  std_logic;
        B0         : in  std_logic_vector(16 downto 0);
        B0_ACLR_N  : in  std_logic;
        B0_EN      : in  std_logic;
        B0_SCLR_N  : in  std_logic;
        C          : in  std_logic_vector(16 downto 0);
        CARRYIN    : in  std_logic;
        CLK        : in  std_logic;
        C_ACLR_N   : in  std_logic;
        C_EN       : in  std_logic;
        C_SCLR_N   : in  std_logic;
        SUB        : in  std_logic;
        SUB_ACLR_N : in  std_logic;
        SUB_EN     : in  std_logic;
        SUB_SCLR_N : in  std_logic;
        CARRYOUT   : out std_logic;
        CDOUT      : out std_logic_vector(43 downto 0);
        P          : out std_logic_vector(34 downto 0) );
end component;

----------------------------------------------------------------------
-- Constant declarations
----------------------------------------------------------------------
constant RV32I_OP_LUI:		std_logic_vector := "0110111";
constant RV32I_OP_AUIPC:	std_logic_vector := "0010111";
constant RV32I_OP_JAL:		std_logic_vector := "1101111";
constant RV32I_OP_JALR:		std_logic_vector := "1100111";
constant RV32I_OP_BRANCH:	std_logic_vector := "1100011";
constant RV32I_OP_LOAD:		std_logic_vector := "0000011";
constant RV32I_OP_STORE:	std_logic_vector := "0100011";
constant RV32I_OP_REG_IMM:	std_logic_vector := "0010011";
constant RV32I_OP_REG_REG:	std_logic_vector := "0110011";
constant RV32I_OP_FENCE:	std_logic_vector := "0001111";
constant RV32I_OP_SYS:		std_logic_vector := "1110011";

----------------------------------------------------------------------
-- Signal declarations
----------------------------------------------------------------------
signal s_pcu_pc0, s_pcu_pc2, s_pcu_pc4, s_pcu_pcx, s_pcu_nxt : unsigned(15 downto 0);
signal s_clk, s_rst_n : std_logic;
signal s_pcu_bra : std_logic; -- branch is without storing PC
signal s_pcu_jmp : std_logic; -- jump is with storing PC to rd
signal s_pcu_brk : std_logic; -- breakpoint flag

signal s_dec_ins : std_logic_vector(31 downto 0);  -- decoder
signal s_dec_slt : std_logic; -- current opcode is set lower than xyz
signal s_dec_sgn : std_logic_vector(16 downto 0);  -- sign of immediate
signal s_dec_rs1, s_dec_rs2, s_dec_rd : std_logic_vector(4 downto 0);

signal s_log_in1, s_log_in2, s_log_out : std_logic_vector(16 downto 0);
signal s_log_opp : std_logic_vector(2 downto 0); -- 0=byp,1=sll,2,3,4=xor,5=srl,6=or,7=and

signal s_mac_run : signed(3 downto 0);  -- ?_SCLR_N ?=sub,c3,b2,a1
signal s_mac_sub, s_mac_msh, s_mac_uns : std_logic;
signal s_mac_in1, s_mac_in2, s_mac_in3, s_mac_out : std_logic_vector(16 downto 0);
signal s_mac_out_all : std_logic_vector(34 downto 0);
signal s_mac_out_sgn : signed(33 downto 0);

signal s_dat_dat, s_dat_out  : std_logic_vector(15 downto 0);
signal s_dat_wrt : std_logic; -- write to data bus (store instruction)
signal s_dat_led : std_logic_vector(7 downto 0);

type duo_mem_array is array(0 to 1023) of std_logic_vector(15 downto 0);
signal s_duo_mem : duo_mem_array;  -- instruction memory 2x16 bit
signal s_duo_adr0, s_duo_adr0_reg : std_logic_vector(9 downto 0);
signal s_duo_adr1, s_duo_adr1_reg : std_logic_vector(9 downto 0);
signal s_duo_dat0, s_duo_out0     : std_logic_vector(15 downto 0);
signal s_duo_dat1, s_duo_out1     : std_logic_vector(15 downto 0);
signal s_duo_wrt0, s_duo_wrt1     : std_logic;

type reg_mem_type is array (31 downto 0) of std_logic_vector (15 downto 0);
signal s_reg_mem : reg_mem_type;  -- register bank 1x In 2x Out (g4)
signal s_reg_dat : std_logic_vector(15 downto 0);
signal s_reg_wrt, s_reg_ext, s_reg_clr : std_logic;
signal s_reg_rs1, s_reg_rs2 : std_logic_vector(16 downto 0);

type t_state is (I_Reset, I_Init, I_Idle, I_Fetch, I_Decode, I_Branch, I_Execute, I_Update);
signal s_cur_state, s_nxt_state : t_state;

signal s_rom_adr : unsigned(15 downto 0);
signal s_rom_dat : std_logic_vector(31 downto 0);
signal s_rom_sta : std_logic_vector(2 downto 0);
signal s_rom_rdy : std_logic;
signal s_rom_wrt : std_logic;

begin

----------------------------------------------------------------------
  s_clk     <= i_clk;

----------------------------------------------------------------------
rom_p : process(s_clk,i_rst_n)
  begin
    if (i_rst_n = '0') then
      s_rom_adr    <= (others=>'0'); -- start address
      s_rom_sta    <= (others=>'0'); -- state machine
      s_rom_sta(0) <= '1';           -- one hot coding
    elsif (s_clk'event and s_clk = '1') then
      if (s_rom_sta(2) = '1') then
        s_rom_adr <= s_rom_adr +4;
      end if;
      if (s_rom_rdy='0') then
        s_rom_sta <= s_rom_sta(1 downto 0) & s_rom_sta(2);
      else
        s_rom_sta <= (others=>'0');
      end if;
    end if;
  end process;
  s_rom_wrt <= s_rom_sta(1);
  s_rom_rdy <= s_rom_adr(8);
  s_rst_n   <= s_rom_rdy;

-- demo code created using : http://www.kvakil.me/venus/
rom_tbl_p : process(s_rom_adr(7 downto 0))
  begin                    -- Immediate  source function destination operation
    case s_rom_adr(7 downto 0) is
    -- init some registers, test long constants via LUI & ADDI
    when  x"00" => s_rom_dat <= x"001" & "00000" & "000" & "00110" & "0010011"; -- ADDI   x6 = x0 +1
    when  x"04" => s_rom_dat <= x"FFF" & "00000" & "000" & "00101" & "0010011"; -- ADDI   x5 = x0 -1
    when  x"08" => s_rom_dat <= x"55555"                 & "00011" & "0110111"; -- LUI    x3 =     #20
    when  x"0C" => s_rom_dat <= x"555" & "00011" & "000" & "00011" & "0010011"; -- ADDI   x3 = x3 +#12

    -- skip second instruction, branch back, make x2=x1, so BNE continues
    when  x"10" => s_rom_dat <= x"00800"                 & "00001" & "1101110"; -- JAL    x1 = pc +4, pc = pc +$8
    when  x"14" => s_rom_dat <= x"000" & "00010" & "000" & "00001" & "0010011"; -- ADDI   x1 = x2 +0
    when  x"18" => s_rom_dat <= x"00000"                 & "00010" & "0010111"; -- AUIPC  x2 = pc +0
    when  x"1C" => s_rom_dat <= x"FE1" & "00010" & "001" & "11001" & "1100011"; -- BNE    x1, x2, -8

    -- rigth shift logical, so will end up at zero
    when  x"20" => s_rom_dat <= x"F00" & "00000" & "000" & "00100" & "0010001"; -- ADDI   x4 = x0 +?
    when  x"24" => s_rom_dat <= x"003" & "00100" & "101" & "00100" & "0010011"; -- SRLI   x4 = x4 >> 3
    when  x"28" => s_rom_dat <= x"00401"                 & "00000" & "0100011"; -- SH     0(x0) = x4
--  when  x"2C" => s_rom_dat <= x"FE4" & "00000" & "110" & "11001" & "1100011"; -- BLTU   x0, x4, -8, last = 0
--  when  x"2C" => s_rom_dat <= x"FE6" & "00100" & "111" & "11001" & "1100011"; -- BGEU   x4, x6, -8, last = 0
    when  x"2C" => s_rom_dat <= x"FE4" & "00110" & "110" & "11001" & "1100011"; -- BLTU   x6, x4, -8, last =+1

    -- rigth shift arithmeticly, so will end up at -1 (found in x5)
    when  x"30" => s_rom_dat <= x"FF0" & "00000" & "000" & "00100" & "0010011"; -- ADDI   x4 = x0 +?
    when  x"34" => s_rom_dat <= x"401" & "00100" & "101" & "00100" & "0010011"; -- SRAI   x4 = x4 >> 1
    when  x"38" => s_rom_dat <= x"00401"                 & "00000" & "0100011"; -- SH     0(x0) = x4
    when  x"3C" => s_rom_dat <= x"FE5" & "00100" & "001" & "11001" & "1100011"; -- BNE    x4, x5, -8, last =-1

    -- shift left x4, or and xor, ... .
    when  x"40" => s_rom_dat <= x"101" & "00000" & "000" & "00100" & "0010011"; -- ADDI   x4 = x0 +$101
    when  x"44" => s_rom_dat <= x"000" & "00000" & "000" & "00011" & "0010011"; -- ADDI   x3 = x0 +0
    when  x"48" => s_rom_dat <= x"000" & "00000" & "000" & "00010" & "0010011"; -- ADDI   x2 = x0 +0
    when  x"4C" => s_rom_dat <= x"004" & "00011" & "110" & "00011" & "0110011"; -- OR     x3 = x3 or  x4
    when  x"50" => s_rom_dat <= x"004" & "00010" & "100" & "00010" & "0110011"; -- XOR    x2 = x2 or  x4
    when  x"54" => s_rom_dat <= x"001" & "00100" & "001" & "00100" & "0010011"; -- SLLI   x4 = x4 << 1
--  when  x"58" => s_rom_dat <= x"0FF" & "00100" & "111" & "00100" & "0010011"; -- ANDI   x4 = x4 and $FF
    when  x"88" => s_rom_dat <= x"00401"                 & "00000" & "0100011"; -- SH     0(x0) = x4
    when  x"5C" => s_rom_dat <= x"FE0" & "00100" & "001" & "10001" & "1100011"; -- BNE    x4, x0, -16,

    -- set bit zero in rd if rs1 is lower than rs2 / #immediate
    when  x"60" => s_rom_dat <= x"000" & "00110" & "010" & "00010" & "0010011"; -- SLTI   x2 = (+1<+0)?1:0
    when  x"64" => s_rom_dat <= x"002" & "00110" & "010" & "00011" & "0010011"; -- SLTI   x3 = (+1<+2)?1:0

    when  x"68" => s_rom_dat <= x"FFE" & "00101" & "011" & "00010" & "0010011"; -- SLTUI  x2 = (-1<-2)?1:0
    when  x"6C" => s_rom_dat <= x"000" & "00101" & "011" & "00011" & "0010011"; -- SLTUI  x3 = (-1<+0)?1:0

  --when  x"70" => s_rom_dat <= x"FFE" & "00101" & "010" & "00010" & "0010011"; -- SLTI   x2 = (-1<-2)?1:0
  --when  x"74" => s_rom_dat <= x"000" & "00101" & "010" & "00011" & "0010011"; -- SLTI   x3 = (-1<+0)?1:0

    when  x"70" => s_rom_dat <= x"005" & "00110" & "010" & "00010" & "0110011"; -- SLT    x2 = (-1<+1)?1:0
    when  x"74" => s_rom_dat <= x"005" & "00110" & "011" & "00011" & "0110011"; -- SLTU   x3 = (-1<+1)?1:0

  --when  x"78" => s_rom_dat <= x"00019"                 & "00100" & "0000011"; -- LH     x4 = #12(x3)
    when  x"78" => s_rom_dat <= x"00100"                 & "00000" & "1110011"; -- EBREAK
    when  x"7C" => s_rom_dat <= x"02000"                 & "00000" & "1100111"; -- JALR   pc = $20, restart demo loop
  --when  x"7C" => s_rom_dat <= x"00000"                 & "00000" & "1101111"; -- JAL    pc = pc +0, endless loop

    when others => s_rom_dat <= x"00000"                 & "00000" & "0010011"; -- ADDI   x0 = x0 +0 default nop
  end case;
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
  s_dec_sgn <= (others=>'1') when (s_dec_ins(31) = '1') else (others=>'0');

dec32_p : process(all)
  variable v_ins : std_logic_vector(31 downto 0);
  variable v_fu3 : std_logic_vector(2 downto 0);
  variable v_rd  : std_logic_vector( 4 downto 0);
  variable v_wrt : std_logic;

  begin
    v_ins          := s_dec_ins; -- instruction shortform
    v_ins(1 downto 0) := "11";   -- reduce decoding logic
    v_rd           := v_ins(11 downto 7); -- dest register
    v_fu3          := v_ins(14 downto 12);
    v_wrt          := '1'; -- most instructions write to register
    s_reg_ext      <= '0';
    s_pcu_jmp      <= '0';
    s_log_in1      <= s_reg_rs1;
    s_log_in2      <= s_reg_rs2;
    s_log_opp      <= "000"; -- bypass
    s_mac_run      <= (others=>'1');
    s_mac_in1      <= (0=>'1', others=>'0');
    s_mac_in3      <= s_reg_rs1;
    s_mac_sub      <= '0'; -- 0=add, 1=subtract c-(a*b)
    s_mac_msh      <= '0'; -- 0=low half, 1=upper half
    s_mac_uns      <= '0'; -- 0=signed, 1=unsigned
    s_dat_wrt      <= '0';
    s_dec_slt      <= '0'; -- any SLT instruction in progress
    s_pcu_brk      <= not s_dec_ins(0); -- '0';

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
	case v_ins(6 downto 0) is
	when RV32I_OP_LUI =>     -- rd = #Imm
      s_mac_in3 <= (others=>'0');
      s_log_in2 <= v_ins(15) & v_ins(15 downto 12) & x"000"; -- U-Type

	when RV32I_OP_AUIPC =>   -- rd = pc + #Imm
      s_mac_in3 <= std_logic(s_pcu_pc0(15)) & std_logic_vector(s_pcu_pc0);
      s_log_in2 <= v_ins(15) & v_ins(15 downto 12) & x"000"; -- U-Type

	when RV32I_OP_JAL =>     -- pc = pc + #Imm, rd = pc +4
      s_mac_in3 <= std_logic(s_pcu_pc0(15)) & std_logic_vector(s_pcu_pc0);
      s_log_in2 <= v_ins(15) & v_ins(15 downto 12) & v_ins(20) & v_ins(30 downto 21) & '0'; -- J-Type
      s_pcu_jmp <= '1';

	when RV32I_OP_JALR =>    -- pc = rs1 + #Imm, rd = pc +4
      s_log_in2 <= s_dec_sgn(16 downto 12) & v_ins(31 downto 20); -- I-Type
      s_pcu_jmp <= '1';

	when RV32I_OP_BRANCH =>  -- 
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
        s_log_in2 <= s_dec_sgn(16 downto 12) & v_ins(7) & v_ins(30 downto 25) & v_ins(11 downto 8) & '0'; -- B-Type
      end case;
      v_wrt     := '0';

	when RV32I_OP_LOAD =>    -- rd = #Imm(rs1)
      s_log_in2 <= s_dec_sgn(16 downto 12) & v_ins(31 downto 20); -- I-Type
      s_reg_ext <= '1';

	when RV32I_OP_STORE =>   -- #Imm(rs1) = rs2
      s_mac_in3 <= (others=>'0');
      s_log_in2 <= s_dec_sgn(16 downto 12) & v_ins(31 downto 25) & v_ins(11 downto 7); -- S-Type
      s_dat_wrt <= '1';
      v_wrt     := '0';

	when RV32I_OP_REG_IMM | RV32I_OP_REG_REG =>
      if (v_ins(5)='0') then -- 0=Immediate 1=Register
        s_log_in2 <= s_dec_sgn(16 downto 12) & v_ins(31 downto 20); -- I-Type
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

	when RV32I_OP_FENCE =>
      v_wrt     := '0';

	when RV32I_OP_SYS =>
      v_wrt     := '0';
      s_pcu_brk <= v_ins(20); -- break

	when others =>
      v_wrt     := '0';
    end case;

    s_reg_wrt <= '0'; -- default, do not write now ############################
    case s_cur_state is
    when I_Reset    => v_rd := (others=>'0');      -- overwrite destination ...
                       s_mac_run <= (others=>'0');
                       s_reg_clr <= '1';
    when I_Init     => v_rd := (others=>'0');      -- ... to zero x0 register
                       s_mac_run <= (others=>'0'); -- force MACC output to zero
                       s_reg_wrt <= '1';
                       s_reg_clr <= '1';
    when I_Execute  => if (v_rd/="00000") then         
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
    when "101" => -- SRL shift right logical, TODO : handle arithmetic / signed shift rigth
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

my17Madd_0 : my17Madd port map(  -- c3 +/- (a1 * b2)
        A0         => s_mac_in1,
        A0_ACLR_N  => s_rst_n,
        A0_EN      => '1',
        A0_SCLR_N  => s_mac_run(0),
        B0         => s_mac_in2,
        B0_ACLR_N  => s_rst_n,
        B0_EN      => '1',
        B0_SCLR_N  => s_mac_run(1),
        C          => s_mac_in3,
        CARRYIN    => '0',
        CLK        => s_clk,
        C_ACLR_N   => s_rst_n,
        C_EN       => '1',
        C_SCLR_N   => s_mac_run(2),
        SUB        => s_mac_sub,
        SUB_ACLR_N => s_rst_n,
        SUB_EN     => '1',
        SUB_SCLR_N => s_mac_run(3),
        CARRYOUT   => open,
        CDOUT      => open,
        P          => open);
      --P          => s_mac_out_all );

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
  s_pcu_pc2 <= s_pcu_pc0 +2; -- point to second half of current instruction / behind 16 bit instruction
  s_pcu_pc4 <= s_pcu_pc0 +4; -- point behind 32 bit instruction
  s_pcu_pcx <= s_pcu_pc4; --when (s_dec_ins(1 downto 0) = "11") else s_pcu_pc2;
  s_pcu_nxt <= unsigned(s_mac_out(15 downto 0)) when (s_pcu_bra='1') 
          else unsigned(s_mac_out(15 downto 0)) when (s_pcu_jmp='1') 
          else s_pcu_pcx;

----------------------------------------------------------------------

  s_reg_dat  <= s_dat_out(15 downto 0)                   when (s_reg_ext='1') 
           else std_logic_vector(s_pcu_pcx(15 downto 0)) when (s_pcu_jmp='1')
           else "00000000" & "0000000" & s_mac_out(16)   when (s_dec_slt='1')
           else "00000000" & "00000000"                  when (s_reg_clr='1')
           else s_mac_out(15 downto 0);

reg_p : process (s_clk)
  begin
    if rising_edge(s_clk) then
      if (s_reg_wrt = '1') then
        s_reg_mem(to_integer (unsigned(s_dec_rd))) <= s_reg_dat(15 downto 0);
      end if;
    end if;
  end process;
  s_dec_rs1              <= s_dec_ins(19 downto 15); -- register source one
  s_dec_rs2              <= s_dec_ins(24 downto 20); -- register source two
  s_reg_rs1(15 downto 0) <= s_reg_mem(to_integer (unsigned(s_dec_rs1)));
  s_reg_rs2(15 downto 0) <= s_reg_mem(to_integer (unsigned(s_dec_rs2)));
  s_reg_rs1(16)          <= '0' when s_mac_uns='1' else s_reg_rs1(15);
  s_reg_rs2(16)          <= '0' when s_mac_uns='1' else s_reg_rs2(15);

----------------------------------------------------------------------
  s_dat_dat <= s_reg_rs2(15 downto 0);  -- use LEDs to dummy data access

led_p : process (s_clk, s_rst_n)
  begin
    if (s_rst_n = '0') then
      s_dat_led <= x"11";
    elsif (s_clk'event and s_clk = '1') then
      if (s_dat_wrt='1') then
        if s_cur_state = I_Update then
          s_dat_led <= s_dat_dat(7 downto 0);
        end if;
      end if;
    end if;
  end process;
  o_led     <= s_dat_led;
  s_dat_out <= x"00" & s_dat_led;

----------------------------------------------------------------------
  s_duo_adr0 <= std_logic_vector(s_rom_adr(10 downto 2)) & '0' when (s_rst_n='0') else '0' & std_logic_vector(s_pcu_pc0(9 downto 1));
  s_duo_adr1 <= std_logic_vector(s_rom_adr(10 downto 2)) & '1' when (s_rst_n='0') else '0' & std_logic_vector(s_pcu_pc2(9 downto 1));

  s_duo_dat0 <= s_rom_dat(15 downto 0);
  s_duo_wrt0 <= s_rom_wrt;
  s_duo_dat1 <= s_rom_dat(31 downto 16);
  s_duo_wrt1 <= s_rom_wrt;

duo_mem_p : process (i_clk)
  begin
    if rising_edge(i_clk) then
      if (s_duo_wrt0 = '1') then
        s_duo_mem(to_integer(unsigned(s_duo_adr0))) <= s_duo_dat0;
      end if;
      if (s_duo_wrt1='1') then
        s_duo_mem(to_integer(unsigned(s_duo_adr1))) <= s_duo_dat1;
      end if;
      s_duo_adr0_reg <= s_duo_adr0;
      s_duo_adr1_reg <= s_duo_adr1;
    end if;
  end process;
-- registered address / non pipelined output
  s_duo_out0 <= s_duo_mem(to_integer(unsigned(s_duo_adr0_reg)));
  s_duo_out1 <= s_duo_mem(to_integer(unsigned(s_duo_adr1_reg)));

  s_dec_ins <= s_duo_out1 & s_duo_out0;

  o_dbg <= "00000" & s_pcu_brk & not s_dec_ins(1) & not s_dec_ins(0);

----------------------------------------------------------------------

end RTL;

