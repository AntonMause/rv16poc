--------------------------------------------------------------------------------
-- File: rv16c_reg.vhd
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity rv16c_reg is port (
  i_clk   : in  std_logic;
  i_rst_n : in  std_logic;
  i_ins   : in  std_logic_vector(31 downto 0);
  o_ins   : out std_logic_vector(31 downto 0);
  o_cpr   : out std_logic );
end rv16c_reg;
architecture rtl of rv16c_reg is

component rv16c is port (
  i_ins   : in  std_logic_vector(31 downto 0);
  o_ins   : out std_logic_vector(31 downto 0);
  o_cpr   : out std_logic );
end component;

	signal s_one, s_two : std_logic_vector(31 downto 0);

begin

rom_p : process(i_clk,i_rst_n)
  begin
    if (i_rst_n = '0') then
      s_one <= (others=>'0'); -- start address
      o_ins <= (others=>'0'); -- state machine
    elsif (i_clk'event and i_clk = '1') then
      s_one <= i_ins;
      o_ins <= s_two;
    end if;
  end process;
  
rv16c_0 : rv16c port map(
  i_ins => s_one,
  o_ins => s_two,
  o_cpr => open );
  
end rtl;