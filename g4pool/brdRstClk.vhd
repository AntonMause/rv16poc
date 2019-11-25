
----------------------------------------------------------------------
-- brdRstClk (for Kickstart Kit)
----------------------------------------------------------------------
-- (c) 2019 by Anton Mause
--
-- Board dependend reset and clock manipulation file.
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

library smartfusion2;
use smartfusion2.all;

----------------------------------------------------------------------
entity brdRstClk is
  port ( i_rst_n, i_clk : in std_logic;
         o_rst_n, o_clk : out std_logic );
end brdRstClk;

----------------------------------------------------------------------
architecture rtl of brdRstClk is

component SYSRESET
  port( DEVRST_N         : in  std_logic;
        POWER_ON_RESET_N : out std_logic );
end component;

component myOSC
  port( RCOSC_1MHZ_CCC     : out std_logic;
        RCOSC_1MHZ_O2F     : out std_logic;
        RCOSC_25_50MHZ_CCC : out std_logic;
        RCOSC_25_50MHZ_O2F : out std_logic);
end component;

component myCCC is
  port(  CLK0 : in  std_logic;
         RCOSC_1MHZ : in  std_logic;
         GL0  : out std_logic;
         GL1  : out std_logic;
         LOCK : out std_logic);
end component;

  signal s_clk, s_dly_n, s_rst_n : std_logic;
  signal s_rst_sys, s_rst_pll : std_logic;
  signal s_osc_1mhz_ccc : std_logic;

begin

SYSRESET_0 : SYSRESET
  port map( 
    DEVRST_N         => i_rst_n,
    POWER_ON_RESET_N => s_rst_sys );

myOSC_0 : myOSC 
  port map( 
    RCOSC_1MHZ_CCC     => s_osc_1mhz_ccc,
    RCOSC_1MHZ_O2F     => open,
    RCOSC_25_50MHZ_CCC => open,
    RCOSC_25_50MHZ_O2F => open);

myCCC_0 : myCCC 
  port map(  
    CLK0       => i_clk,
    RCOSC_1MHZ => s_osc_1mhz_ccc,
    GL0        => open,
    GL1        => s_clk,
    LOCK       => s_rst_pll );

  s_rst_n <= s_rst_pll OR s_rst_sys;

  process(s_clk, s_rst_n)
  begin
    if s_rst_n = '0' then
      s_dly_n <= '0';
      o_rst_n <= '0';
    elsif (s_clk'event and s_clk = '1') then
      s_dly_n <= '1';
      o_rst_n <= s_dly_n;
    end if;
  end process;

  o_clk   <= s_clk;

end rtl;
----------------------------------------------------------------------
