
----------------------------------------------------------------------
-- brdRstClk (SoC G5/PolarFire version)
----------------------------------------------------------------------
-- (c) 2019 by Anton Mause
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

library polarfire;
use polarfire.all;

----------------------------------------------------------------------
entity brdRstClk is
  port ( i_rst_n, i_clk : in std_logic;
         o_rst_n, o_clk : out std_logic );
end brdRstClk;

----------------------------------------------------------------------
architecture rtl of brdRstClk is

component PFSOC_INIT_MONITOR_C0
    -- Port list
    port(
        -- Outputs
        AUTOCALIB_DONE             : out std_logic;
        BANK_0_CALIB_STATUS        : out std_logic;
        BANK_1_CALIB_STATUS        : out std_logic;
        DEVICE_INIT_DONE           : out std_logic;
        FABRIC_POR_N               : out std_logic;
        PCIE_INIT_DONE             : out std_logic;
        SRAM_INIT_DONE             : out std_logic;
        SRAM_INIT_FROM_SNVM_DONE   : out std_logic;
        SRAM_INIT_FROM_SPI_DONE    : out std_logic;
        SRAM_INIT_FROM_UPROM_DONE  : out std_logic;
        USRAM_INIT_DONE            : out std_logic;
        USRAM_INIT_FROM_SNVM_DONE  : out std_logic;
        USRAM_INIT_FROM_SPI_DONE   : out std_logic;
        USRAM_INIT_FROM_UPROM_DONE : out std_logic;
        XCVR_INIT_DONE             : out std_logic
        );
end component;

  signal s_clk, s_dly_n, s_rst_n : std_logic;

begin

----------------------------------------------------------------------
PFSOC_INIT_MONITOR_C0_0 : PFSOC_INIT_MONITOR_C0
    port map( 
        -- Outputs
        FABRIC_POR_N               => s_rst_n,
        PCIE_INIT_DONE             => OPEN,
        USRAM_INIT_DONE            => OPEN,
        SRAM_INIT_DONE             => OPEN,
        DEVICE_INIT_DONE           => OPEN,
        BANK_0_CALIB_STATUS        => OPEN,
        BANK_1_CALIB_STATUS        => OPEN,
        XCVR_INIT_DONE             => OPEN,
        USRAM_INIT_FROM_SNVM_DONE  => OPEN,
        USRAM_INIT_FROM_UPROM_DONE => OPEN,
        USRAM_INIT_FROM_SPI_DONE   => OPEN,
        SRAM_INIT_FROM_SNVM_DONE   => OPEN,
        SRAM_INIT_FROM_UPROM_DONE  => OPEN,
        SRAM_INIT_FROM_SPI_DONE    => OPEN,
        AUTOCALIB_DONE             => OPEN );

--s_rst_n <= i_rst_n;
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
