--------------------------------------------------------------------------------
-- WatchOut: 
--   rv16rom.vhd        gets generated via script, do not modify
--   rv16rom_head.vhd   edit here ...
--   rv16rom_tail.vhd   ... or here
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- File: rv16rom.vhd   (c) 2019 by Anton Mause
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity rv16rom is 
generic( PLEN : natural := 10 );
port( i_clk : in  std_logic;
      i_adr : in  std_logic_vector(PLEN-1 downto 0);
      o_dat : out std_logic_vector(31 downto 0) );
end rv16rom;

architecture rtl of rv16rom is

signal s_clk : std_logic;
type duo_mem_array is array(0 to (2**(PLEN-1))-1) of std_logic_vector(15 downto 0);
signal s_duo_mem : duo_mem_array := ( -- instruction memory 2x16 bit
-- head -- head -- head -- head -- head -- head -- head -- head -- head --
    x"0113", x"0020", -- 0x00200113
    x"00ef", x"0080", -- 0x008000ef
    x"8167", x"0000", -- 0x00008167
    x"5ce3", x"fe11", -- 0xfe115ce3
    x"f06f", x"ff9f", -- 0xff9ff06f
    x"006f", x"0080", -- 0x0080006f
    x"f06f", x"ff9f", -- 0xff9ff06f
    x"006f", x"0080", -- 0x0080006f
    x"f06f", x"ff9f", -- 0xff9ff06f
    x"f06f", x"ffdf", -- 0xffdff06f
    x"0000", x"0000", -- 0x00000000
    x"0000", x"0000", -- 0x00000000

-- tail -- tail -- tail -- tail -- tail -- tail -- tail -- tail -- tail -- 
    others=>x"0000" );
signal s_duo_adr0, s_duo_adr0_reg : std_logic_vector(PLEN-2 downto 0);
signal s_duo_adr1, s_duo_adr1_reg : std_logic_vector(PLEN-2 downto 0);
signal s_duo_out0, s_duo_out1     : std_logic_vector(15 downto 0);

begin
  s_clk     <= i_clk;

  -- i_adr() points to BYTE, remove 2 lsb to get LONG
  -- s_adr() points to HALF, add one lsb(1/0) again
--s_duo_adr0 <= i_adr(PLEN-1 downto 2) & '0';
--s_duo_adr1 <= i_adr(PLEN-1 downto 2) & '1';
  s_duo_adr0 <= "0000" & i_adr(PLEN-5 downto 2) & '0';
  s_duo_adr1 <= "0000" & i_adr(PLEN-5 downto 2) & '1';

duo_mem_p : process (s_clk)
  begin
--    if falling_edge(s_clk) then
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