
----------------------------------------------------------------------
-- brdConst_pkg (for Maker Board)
----------------------------------------------------------------------
-- (c) 2019 by Anton Mause
--
-- Package to declare board specific constants.
--
-- LEDs & PushButton SW polarity XOR constants
-- Handling examples :
--   constant c_lex : std_logic := BRD_LED_POL;
--   constant c_pbx : std_logic := BRD_BTN_POL;
--
--   LED0   <=  c_lex xor s_led(0);
--   LED2   <=  c_lex;         -- force idle LEDs OFF on all boards
--   s_pb1  <=  c_pbx xor PB1; -- force '1' only if pressed
--
----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

----------------------------------------------------------------------
package brdConst_pkg is
  constant BRD_OSC_CLK_MHZ : positive;
  constant BRD_LED_POL : std_logic;
  constant BRD_BTN_POL : std_logic;
end brdConst_pkg;

----------------------------------------------------------------------
package body brdConst_pkg is
  -- Frequency of signal o_clk from brdRstClk to system
  constant BRD_OSC_CLK_MHZ : positive := 50_000_000; -- direct
--constant BRD_OSC_CLK_MHZ : positive := 25_000_000; -- divided

  -- polarity of LED driver output
  -- '0' = low idle, high active
  -- '1' = high idle, low active
  constant BRD_LED_POL : std_logic := '1';

  -- polarity of push button switches
  -- '0' = low idle, high active (pressed)
  -- '1' = high idle, low active (pressed)
  constant BRD_BTN_POL : std_logic := '0';

end brdConst_pkg;

----------------------------------------------------------------------
