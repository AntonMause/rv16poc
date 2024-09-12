
----------------------------------------------------------------------
-- brdRstClk (for RTG4-non ES)
----------------------------------------------------------------------
-- (c) 2016 by Anton Mause
--
-- Board dependend reset and clock manipulation file.
-- Adjust i_clk from some known clock, so o_clk has BRD_OSC_CLK_MHZ.
-- See "brdConst_pkg.vhd" for specific BRD_OSC_CLK_MHZ values.
-- Sync up o_rst_n to fit to rising edge of o_clk.
--
----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library rtg4;
use rtg4.all;

----------------------------------------------------------------------
entity brdRstClk is
  port ( i_rst_n, i_clk : in std_logic;
         o_rst_n, o_clk : out std_logic);
end brdRstClk;

----------------------------------------------------------------------
architecture rtl of brdRstClk is

component SYSRESET
  port( DEVRST_N         : in  std_logic;
        POWER_ON_RESET_N : out std_logic );
  end component;

  signal s_tgl, s_dly_n, s_rst_n : std_logic;

begin

SYSRESET_0 : SYSRESET
  port map( 
    DEVRST_N         => i_rst_n,
    POWER_ON_RESET_N => s_rst_n );

-- Special for RT4G AsyncReset SyncUp.
-- This silicon revision has only 206 async reset domain.
-- So a small asynchr reset domain can block 500+ LEs. 
  process(i_clk) -- trigger synchron
  begin
    if (i_clk'event and i_clk = '1') then
      if s_rst_n = '0' then
        s_dly_n <= '0';
        s_tgl   <= '0';
        o_rst_n <= '0';
      else
        s_dly_n <= '1';
        s_tgl   <= not s_tgl;
      o_rst_n <= s_dly_n;
      end if;
    end if;
  end process;
--  process(i_clk, s_rst_n) -- trigger asynchron
--  begin
--    if s_rst_n = '0' then
--      s_dly_n <= '0';
--      o_rst_n <= '0';
--    elsif (i_clk'event and i_clk = '1') then
--      s_dly_n <= '1';
--      o_rst_n <= s_dly_n;
--    end if;
--  end process;

-- edit BRD_OSC_CLK_MHZ in brdConst_pkg too
  o_clk   <= i_clk; -- 50MHz, direct
--o_clk   <= s_tgl; -- 25MHz, divided

end rtl;
----------------------------------------------------------------------
