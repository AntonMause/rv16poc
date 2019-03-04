 
----------------------------------------------------------------------
-- mySynCnt
----------------------------------------------------------------------
-- (c) 2019 by Anton Mause
--
----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

----------------------------------------------------------------------
entity mySynCnt is
  generic (N : Integer:=8);
  port ( i_rst_n, i_clk : in std_logic;
         o_q : out std_logic_vector(N-1 downto 0) );
end entity mySynCnt;

----------------------------------------------------------------------
architecture rtl of mySynCnt is

  signal s : std_logic_vector(N-1 downto 0);

begin

P_SynCnt: process(i_rst_n, i_clk)
  begin
    if i_rst_n='0' then
      s <= (OTHERS=>'0');
    elsif rising_edge(i_clk) then
      s <=      s + 1;
    end if;
    o_q  <=     s;
  end process;

end architecture rtl;
----------------------------------------------------------------------
