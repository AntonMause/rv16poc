 
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
  generic( PLEN  : natural :=  6;  -- tested from 6 to 16(XLEN)
           XLEN  : natural := 16); -- tested from 8 to 16
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

component rv16gpo is
generic(PLEN : natural; XLEN : natural);
port( 
  i_clk     : in  std_logic;
  i_rst_n   : in  std_logic;
  i_gpi     : in  std_logic_vector(XLEN-1 downto 0);
  i_irdy    : in  std_logic; -- instruction ready
  i_idat    : in  std_logic_vector(31 downto 0);
  o_isel    : out std_logic; -- instruction select
  o_iadr    : out std_logic_vector(PLEN-1 downto 0);
  o_gpo     : out std_logic_vector(XLEN-1 downto 0) );
end component;

component rv16rom is 
generic( PLEN : natural );
port( i_clk : in  std_logic;
      i_adr : in  std_logic_vector(PLEN-1 downto 0);
      o_dat : out std_logic_vector(31 downto 0) );
end component;

constant c_lex : std_logic := BRD_LED_POL;
constant c_pbx : std_logic := BRD_BTN_POL;

signal s_clk, s_clk2, s_rst_n : std_logic;
signal s_pb1, s_pb2 : std_logic;
signal s_cnt : std_logic_vector(28 downto 0);
signal s_gpi, s_gpo : std_logic_vector(XLEN-1 downto 0);
signal s_iadr : std_logic_vector(PLEN-1 downto 0);
signal s_idat : std_logic_vector(31 downto 0);
signal s_irdy, s_isel : std_logic;

begin

  s_pb1    <= c_pbx xor PB1;
  s_pb2    <= c_pbx xor PB2;

brdRstClk_0 : brdRstClk
  port map(
    i_rst_n => DEVRST_N,
    i_clk   => OSC_CLK,
    o_rst_n => s_rst_n,
    o_clk   => s_clk );

mySynCnt_0 : mySynCnt
  generic map( N => s_cnt'high+1 )
  port map(
    i_rst_n => s_rst_n,
    i_clk   => s_clk,
    o_q     => s_cnt );

  s_clk2 <= s_clk;     -- full speed
--s_clk2 <= s_cnt(4);  -- fast
--s_clk2 <= s_cnt(8);  -- mid
--s_clk2 <= s_cnt(16); -- slow
--s_clk2 <= s_cnt(18); -- slower
--s_clk2 <= s_cnt(20); -- real slow

rv16rom0 : rv16rom
  generic map( PLEN => PLEN )
  port map ( i_clk => s_clk2,
             i_adr => s_iadr,
             o_dat => s_idat );

rv16gpo_0 : rv16gpo 
  generic map( PLEN => PLEN, XLEN => XLEN )
  port map( 
    i_clk   => s_clk2,
    i_rst_n => s_rst_n,
    i_gpi   => s_gpi,
    i_irdy  => s_irdy,
    i_idat  => s_idat,
    o_isel  => s_isel,
    o_iadr  => s_iadr,
    o_gpo   => s_gpo );

  s_irdy  <=   s_isel; -- zero wait state

  s_gpi  <= (1=>s_pb2, 0=>s_pb1, others=>'0');
  LED0   <=  c_lex xor s_gpo(0);
  LED1   <=  c_lex xor s_gpo(1);
  LED2   <=  c_lex xor s_gpo(2);
  LED3   <=  c_lex xor s_gpo(3);
  LED4   <=  c_lex xor s_gpo(4);
  LED5   <=  c_lex xor s_gpo(5);
  LED6   <=  c_lex xor s_gpo(6);
  LED7   <=  c_lex xor s_gpo(7);

  UART_TXD <= UART_RXD xor OSC_CLK; -- dummy

end rtl;
----------------------------------------------------------------------