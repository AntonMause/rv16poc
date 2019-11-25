
----------------------------------------------------------------------
-- brdRstClk (generic G4/SmartFusion2/Igloo2 version)
----------------------------------------------------------------------
-- (c) 2019 by Anton Mause
--
-- Clone this file and put into board file folder
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

  signal s_clk, s_clk50mhz, s_dly_n, s_rst_n : std_logic;

begin

----------------------------------------------------------------------
SYSRESET_0 : SYSRESET
  port map( 
    DEVRST_N         => i_rst_n,
    POWER_ON_RESET_N => s_rst_n );

myOSC_0 : myOSC 
  port map( 
    RCOSC_1MHZ_CCC     => open,
    RCOSC_1MHZ_O2F     => open,
    RCOSC_25_50MHZ_CCC => open,
    RCOSC_25_50MHZ_O2F => s_clk50mhz);

--  s_clk   <= i_clk;
  s_clk   <= s_clk50mhz;

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
