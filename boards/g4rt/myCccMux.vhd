
----------------------------------------------------------------------
-- myCccMux (for RTG4)
----------------------------------------------------------------------
-- (c) 2016 by Anton Mause
--
-- RTG4 does not have NGMUX NonGlitching Mux, emulate it.
-- (B.t.w. It does have clock gating)
--
----------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

----------------------------------------------------------------------
entity myCccMux is
port( i_clk0, i_clk1, i_mux : in  std_logic;
      o_clk : out std_logic );
end myCccMux;

architecture DEF_ARCH of myCccMux is

  signal sel0, sel0a, sel0b : std_logic;
  signal sel1, sel1a, sel1b : std_logic;

begin

  sel0 <= (    i_mux) and (not sel1b);
  sel1 <= (not i_mux) and (not sel0b);

  process(i_clk0)
  begin
    if (i_clk0'event and i_clk0 = '1') then
      sel0a <= sel0;
    end if;
  end process;

  process(i_clk0)
  begin
    if (i_clk0'event and i_clk0 = '0') then
      sel0b <= sel0a;
    end if;
  end process;

  process(i_clk1)
  begin
    if (i_clk1'event and i_clk1 = '1') then
      sel1a <= sel1;
    end if;
  end process;

  process(i_clk1)
  begin
    if (i_clk1'event and i_clk1 = '0') then
      sel1b <= sel1a;
    end if;
  end process;

  o_clk <= (i_clk0 and sel0b) or (i_clk1 and sel1b);

end DEF_ARCH;
--------------------------------------------------------------------------------

