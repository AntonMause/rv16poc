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
