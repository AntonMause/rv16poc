--------------------------------------------------------------------------------
-- File: rv16bra.vhd    compute if to change programm counter, either via jump or branch
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use work.rv16pkg.all;

--------------------------------------------------------------------------------
entity rv16bra is generic(XLEN : natural := 32);
port (
  i_ins : in  std_logic_vector(31 downto 0);
  i_rs1 : in  std_logic_vector(XLEN-1 downto 0);
  i_rs2 : in  std_logic_vector(XLEN-1 downto 0);
  o_bra : out std_logic );
end rv16bra;

--------------------------------------------------------------------------------
--  (1)  (0)     <= instr(13)    fu3
--  bne  beq  00 <= instr(15:14) fu3
--  bge  blt  10 <=     signed
--  bgeu bltu 11 <=   unsigned

--------------------------------------------------------------------------------
architecture rtl of rv16bra is

-- one bit extra length for (un)signed trick
signal s_rs1, s_rs2 : std_logic_vector(XLEN-0 downto 0);
signal s_eq, s_lt, s_flg, s_bra, s_jmp : std_logic;

begin

s_bra   <= '1' when  (i_ins(6 downto 0) = "1100011")  else '0'; -- branch
s_jmp   <= '1' when ((i_ins(6 downto 0) = "1101111")  or        -- jump and link pc +#imm
                     (i_ins(6 downto 0) = "1100111")) else '0'; -- jump and link register

-- force unsigned in signed compare (controlled by bit(14))
s_rs1(XLEN)            <= i_rs1(XLEN-1) and i_ins(14);
s_rs1(XLEN-1 downto 0) <= i_rs1;

s_rs2(XLEN)            <= i_rs2(XLEN-1) and i_ins(14);
s_rs2(XLEN-1 downto 0) <= i_rs2;

-- compare registers equal and signed
s_eq <= '0' when ( s_rs1(XLEN-1 downto 0) /= s_rs2(XLEN-1 downto 0)) else '1';
s_lt <= '1' when (          signed(s_rs1)  <          signed(s_rs2)) else '0';

-- select and trim compare result
s_flg <= s_lt  when (i_ins(15)='1') else s_eq;

-- merge jump and branch flags
o_bra <= (s_flg xor   i_ins(13)) when (s_bra = '1') else s_jmp;

end rtl;
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- rv16bra_bench  bechmark this IP between two registers
-- constrain to 300MHz(g3) 500MHz(g5), synths to:
--        AGL-0 A3P-1 M2S-1 MPF-1 (MHz)
--                          557
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use work.rv16pkg.all;

entity rv16bra_bench is  generic(XLEN : natural := 32);
port (
  i_clk : in std_logic;
  i_ins : in  std_logic_vector(31 downto 0);
  i_rs1 : in  std_logic_vector(XLEN-1 downto 0);
  i_rs2 : in  std_logic_vector(XLEN-1 downto 0);
  o_bra : out std_logic );
end rv16bra_bench;

architecture rtl of rv16bra_bench is
	signal s_ins        : std_logic_vector(31 downto 0);
	signal s_rs1, s_rs2 : std_logic_vector(XLEN-1 downto 0);
    signal s_bra        : std_logic;
begin

bra_bench_p : process(i_clk)
  begin
    if (i_clk'event and i_clk = '1') then
      s_ins <= i_ins;
      s_rs1 <= i_rs1;
      s_rs2 <= i_rs2;
      o_bra <= s_bra;
    end if;
  end process;

rv16bra_0 : rv16bra generic map( XLEN => XLEN )
  port map( i_ins => s_ins, i_rs1 => s_rs1, i_rs2 => s_rs2, o_bra => s_bra );

end rtl;