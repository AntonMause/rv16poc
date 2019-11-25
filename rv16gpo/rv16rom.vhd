--------------------------------------------------------------------------------
-- Warning:             dummy
--   rv16rom.vhd        gets generated via script, do not modify
--   rv16rom_head.vhd   edit here ...
--   rv16rom_tail.vhd   ... or here
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- File: rv16rom.vhd
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity rv16rom is 
generic( IALEN : natural := 10 );
port( i_clk : in  std_logic;
      i_adr : in  std_logic_vector(IALEN-1 downto 0);
      o_dat : out std_logic_vector(31 downto 0) );
end rv16rom;

architecture rtl of rv16rom is

signal s_clk : std_logic;
type duo_mem_array is array(0 to 1023) of std_logic_vector(15 downto 0);
signal s_duo_mem : duo_mem_array := ( -- instruction memory 2x16 bit
-- head -- head -- head -- head -- head -- head -- head -- head -- head --
-- tail -- tail -- tail -- tail -- tail -- tail -- tail -- tail -- tail -- 
    others=>x"0000" );
signal s_duo_adr0, s_duo_adr0_reg : std_logic_vector(IALEN-2 downto 0);
signal s_duo_adr1, s_duo_adr1_reg : std_logic_vector(IALEN-2 downto 0);
signal s_duo_out0, s_duo_out1     : std_logic_vector(15 downto 0);

begin
  s_clk     <= i_clk;

  -- i_adr() points to BYTE, remove 2 lsb to get LONG
  -- s_adr() points to HALF, add one lsb(1/0) again
  s_duo_adr0 <= i_adr(IALEN-1 downto 2) & '0';
  s_duo_adr1 <= i_adr(IALEN-1 downto 2) & '1';

duo_mem_p : process (s_clk)
  begin
    if rising_edge(s_clk) then
      s_duo_adr0_reg <= s_duo_adr0;
      s_duo_adr1_reg <= s_duo_adr1;
    end if;
  end process;
-- registered address / non pipelined output
  s_duo_out0 <= s_duo_mem(to_integer(unsigned(s_duo_adr0_reg)));
  s_duo_out1 <= s_duo_mem(to_integer(unsigned(s_duo_adr1_reg)));

  o_dat <= s_duo_out1 & s_duo_out0;

end rtl;