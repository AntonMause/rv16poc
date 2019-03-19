 
----------------------------------------------------------------------
-- rv16soc
----------------------------------------------------------------------
-- (c) 2019 by Anton Mause
--
-- Blink 8 LEDs controlled by rv16 CPU.
--
----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.brdConst_pkg.all;

----------------------------------------------------------------------
entity rv16soc is
  port( OSC_CLK  : in  std_logic;
        DEVRST_N : in  std_logic;
        PB1      : in  std_logic;
        PB2      : in  std_logic;
        LED0     : out std_logic;
        LED1     : out std_logic;
        LED2     : out std_logic;
        LED3     : out std_logic;
        LED4     : out std_logic;
        LED5     : out std_logic;
        LED6     : out std_logic;
        LED7     : out std_logic;
        UART_RXD : in  std_logic;
        UART_TXD : out std_logic );
end rv16soc;

----------------------------------------------------------------------
architecture rtl of rv16soc is

component brdRstClk
  port ( i_rst_n, i_clk : in std_logic;
         o_rst_n, o_clk : out std_logic );
end component;

component mySynCnt
  generic (N : Integer);
  port ( i_rst_n, i_clk : in std_logic;
         o_q : out std_logic_vector(N-1 downto 0) );
end component;

component rv16poc port( 
  i_clk : in std_logic;
  i_rst_n : in std_logic;
  o_dbg     : out std_logic_vector(7 downto 0);
  o_led : out std_logic_vector(7 downto 0) );
end component;

constant c_lex : std_logic := BRD_LED_POL;
constant c_pbx : std_logic := BRD_BTN_POL;

signal s_clk, s_clk2, s_rst_n : std_logic;
signal s_pb1, s_pb2, s_rst_in : std_logic;
signal s_cnt : std_logic_vector(28 downto 0);
signal s_dbg, s_led : std_logic_vector(7 downto 0);

begin

  s_pb1    <= c_pbx xor PB1;
  s_pb2    <= c_pbx xor PB2;
  s_rst_in <= not (s_pb1 or s_pb2 or DEVRST_N);

brdRstClk_0 : brdRstClk
  port map(
    i_rst_n => DEVRST_N,
    i_clk   => OSC_CLK,
    o_rst_n => s_rst_n,
    o_clk   => s_clk );

  s_clk2 <= s_clk;     -- full speed
--s_clk2 <= s_cnt(4);  -- fast
--s_clk2 <= s_cnt(16); -- slow
--s_clk2 <= s_cnt(18); -- slower
--s_clk2 <= s_cnt(20); -- real slow

rv16poc_0 : rv16poc 
  port map( 
    i_clk   => s_clk2,
    i_rst_n => s_rst_n,
    o_dbg   => s_dbg,
    o_led   => s_led );

  LED0   <=  c_lex xor s_led(0);
  LED1   <=  c_lex xor s_led(1);
  LED2   <=  c_lex xor s_led(2);
  LED3   <=  c_lex xor s_led(3);
  LED4   <=  c_lex xor s_led(4);
  LED5   <=  c_lex xor s_led(5);
  LED6   <=  c_lex xor s_led(6);
  LED7   <=  c_lex xor s_led(7);

  UART_TXD <= UART_RXD xor s_dbg(0) xor s_dbg(1); --  xor s_pb1 xor s_pb2; -- dummy

end rtl;
----------------------------------------------------------------------
