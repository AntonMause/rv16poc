
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
constant RV32I_OP_JAL:		std_logic_vector := "1101111";

----------------------------------------------------------------------
-- Signal declarations
----------------------------------------------------------------------
signal s_pcu_pc0, s_pcu_pc2, s_pcu_pc4, s_pcu_pcx, s_pcu_nxt : unsigned(15 downto 0);
signal s_clk, s_rst_n : std_logic;
signal s_pcu_bra : std_logic; -- branch is with or without storing PC
signal s_pcu_jmp : std_logic; -- jump is with storing PC to rd

signal s_dec_ins : std_logic_vector(31 downto 0);  -- decoder
signal s_dec_rs1, s_dec_rs2, s_dec_rd : std_logic_vector(4 downto 0);

signal s_mac_run : signed(3 downto 0);  -- ?_SCLR_N ?=sub,c3,b2,a1
signal s_mac_sub, s_mac_msh : std_logic;
signal s_mac_in1, s_mac_in2, s_mac_in3, s_mac_out : std_logic_vector(16 downto 0);
signal s_mac_out_all : std_logic_vector(34 downto 0);
signal s_mac_out_sgn : signed(16 downto 0);

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
signal s_reg_wrt, s_reg_ext : std_logic;
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
  s_rom_rdy <= s_rom_adr(5);
  s_rst_n   <= s_rom_rdy;

rom_tbl_p : process(s_rom_adr(7 downto 0))
  begin                    -- Immediate  source function destination operation
    case s_rom_adr(7 downto 0) is
    when  x"00" => s_rom_dat <= x"000" & "00000" & "111" & "00000" & "0010011"; -- ANDI   r0 = zero
    when  x"04" => s_rom_dat <= x"00800"                 & "00001" & "1101111"; -- JAL    pc = pc +8
    when  x"08" => s_rom_dat <= x"00400"                 & "00010" & "1101111"; -- JAL    pc = pc +4
  --when  x"0C" => s_rom_dat <= x"000" & "00000" & "111" & "00000" & "0010011"; -- ANDI   r0 = zero
    when  x"0C" => s_rom_dat <= x"0001"          &                     x"0002"; -- 2x compressed dummys
    when others => s_rom_dat <= x"FF1FF"                 & "00011" & "1101111"; -- JAL    pc = pc -16
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
dec32_p : process(s_dec_ins,s_cur_state,s_pcu_pc0)
  variable v_ins : std_logic_vector(31 downto 0);
  variable v_rd  : std_logic_vector( 4 downto 0);
  variable v_wrt : std_logic;

  begin
    v_ins          := s_dec_ins; -- instruction shortform
    v_rd           := s_dec_ins(11 downto 7); -- dest register
    v_wrt          := '1'; -- most instructions write to register
    s_reg_ext      <= '0';
    s_pcu_bra      <= '0';
    s_pcu_jmp      <= '0';
    s_mac_run      <= (others=>'1');
    s_mac_in1      <= (0=>'1', others=>'0');
    s_mac_in2      <= (others=>'0');
    s_mac_in3      <= (others=>'0');
    s_mac_sub      <= '0';
    s_mac_msh      <= '0';

    case s_cur_state is
    when I_Reset   =>  s_nxt_state   <= I_Init;
    when I_Init    =>  s_nxt_state   <= I_Idle;
    when I_Idle    =>  s_nxt_state   <= I_Fetch;
    when I_Fetch   =>  s_nxt_state   <= I_Execute;
    when I_Execute =>  s_nxt_state   <= I_Update;
    when I_Update  =>  s_nxt_state   <= I_Idle;
    when others    =>  s_nxt_state   <= I_Idle;
    end case;

	-- Main instruction decoder
	case s_dec_ins(6 downto 0) is
	when RV32I_OP_JAL =>     -- add pc + #Imm
      s_mac_in3 <= std_logic(s_pcu_pc0(15)) & std_logic_vector(s_pcu_pc0);
      s_mac_in2 <= v_ins(15) & v_ins(15 downto 12) & v_ins(20) & v_ins(30 downto 21) & '0'; -- J-Type
      s_pcu_jmp <= '1';
      s_pcu_bra <= '1';

	when others =>
    end case;

    s_reg_wrt <= '0'; -- default, do not write now
    case s_cur_state is
    when I_Reset    => v_rd := (others=>'0');      -- overwrite destination ...
                       s_mac_run <= (others=>'0');
    when I_Init     => v_rd := (others=>'0');      -- ... to zero x0 register
                       s_mac_run <= (others=>'0'); -- force MACC output to zero
                       s_reg_wrt <= '1';
    when I_Execute  => if (v_rd/="00000") then         
                         s_reg_wrt <= v_wrt;
                       end if;
	when others =>
    end case;
    s_dec_rd <= v_rd;

end process;

----------------------------------------------------------------------

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
        P          => s_mac_out_all );
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
  s_pcu_pcx <= s_pcu_pc4 when (s_dec_ins(1 downto 0) = "11") else s_pcu_pc2;
  s_pcu_nxt <= s_pcu_pcx when (s_pcu_bra = '0') else unsigned(s_mac_out(15 downto 0));

----------------------------------------------------------------------
--ori  s_reg_dat  <= s_dat_out(15 downto 0)                   when (s_reg_ext='1') 
  s_reg_dat  <= x"BEEF"                                  when (s_reg_ext='1') 
           else std_logic_vector(s_pcu_pcx(15 downto 0)) when (s_pcu_jmp='1')
           else s_mac_out(15 downto 0);

reg_p : process (s_clk)
  begin
    if rising_edge(s_clk) then
      if (s_reg_wrt = '1') then
        s_reg_mem(to_integer (unsigned(s_dec_ins(11 downto  7)))) <= s_reg_dat(15 downto 0);
      end if;
    end if;
  end process;
  s_dec_rs1              <= s_dec_ins(19 downto 15); -- register source one
  s_dec_rs2              <= s_dec_ins(24 downto 20); -- register source two
  s_reg_rs1(15 downto 0) <= s_reg_mem(to_integer (unsigned(s_dec_rs1)));
  s_reg_rs2(15 downto 0) <= s_reg_mem(to_integer (unsigned(s_dec_rs1)));
  s_reg_rs1(16)          <= s_reg_rs1(15);
  s_reg_rs2(16)          <= s_reg_rs2(15);

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

----------------------------------------------------------------------
--o_led     <= std_logic_vector(s_pcu_pc0(4 downto 1)) & std_logic_vector(s_pcu_nxt(4 downto 1));
  o_led     <= 
    std_logic_vector(s_dec_ins(31 downto 24)) xor std_logic_vector(s_dec_ins(23 downto 16)) xor
    std_logic_vector(s_dec_ins(15 downto  8)) xor std_logic_vector(s_dec_ins( 7 downto  0)) xor
    std_logic_vector(s_pcu_nxt( 7 downto  0));

end RTL;

-- http://www.kvakil.me/venus/
--one:
--	  andi    x0, x0, 0
--    jal     x0, two
--    jal     x0, two
--two:
--	  andi	  x0, x0, 0
--	  jal	  x0, one
--00007013
--0080006f
--0040006f
--00007013
--ff1ff06f