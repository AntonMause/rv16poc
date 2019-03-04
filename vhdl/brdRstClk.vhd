
----------------------------------------------------------------------
-- brdRstClk (generic version)
----------------------------------------------------------------------
-- (c) 2016 by Anton Mause
--
-- Clone this file and put into board file folder
--
-- Add Board dependent reset and clock manipulation in clone.
--
-- Route incomming board reset via internal onchip sysreset unit.
--
-- Adjust i_clk from some known clock, so o_clk has BRD_OSC_CLK_MHZ.
-- See "brdConst_pkg.vhd" for specific BRD_OSC_CLK_MHZ values. (Option)
--
-- Sync up o_rst_n to fit to rising edge of o_clk.
--
----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

----------------------------------------------------------------------
entity brdRstClk is
  port ( i_rst_n, i_clk : in std_logic;
         o_rst_n, o_clk : out std_logic );
end brdRstClk;

----------------------------------------------------------------------
architecture rtl of brdRstClk is

  signal s_clk, s_dly_n, s_rst_n : std_logic;

begin

----------------------------------------------------------------------
  s_rst_n <= i_rst_n;   -- put chip dependent reset component here
  s_clk   <= i_clk;

----------------------------------------------------------------------
  process(s_clk, s_rst_n)  -- sync up reset out and clock out
  begin
    if s_rst_n = '0' then
      s_dly_n <= '0';
      o_rst_n <= '0';
    elsif (s_clk'event and s_clk = '1') then
      s_dly_n <= '1';
      o_rst_n <= s_dly_n;
    end if;
  end process;

----------------------------------------------------------------------
  o_clk   <= s_clk;  -- room for additional post clock fixing

end rtl;
----------------------------------------------------------------------
