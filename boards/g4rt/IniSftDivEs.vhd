
----------------------------------------------------------------------
-- IniSftDiv (for RTG4 ES)
----------------------------------------------------------------------
-- (c) 2016 by Anton Mause
--
-- Blink some LEDs to show results of initialisation attempts.
--
-- Result :
--  -assignments at declaration time will not work
--  -Asynch Reset will work and come for free (no etra resources)
--  -Sync Reset will work too, but may cost extra LUT resources
--
-- SRAM FPGA may support initialisation at declaration.
-- Watch your step when migrating from SRAM to FLASH FPGAs
--
----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

----------------------------------------------------------------------
entity IniSftDiv is
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
end IniSftDiv;

----------------------------------------------------------------------
architecture RTL of IniSftDiv is
component brdRstClk
  port ( i_rst_n, i_clk : in std_logic;
         o_rst_n, o_clk : out std_logic;
         o_lex,   o_pbx : out std_logic );
end component;

component mySynRst
  port(i_rst_n, i_clk : in std_logic;
       o_rst_n : out std_logic);
end component;

component myDffCnt
  generic (N : Integer);
  port ( i_rst_n, i_clk : in std_logic;
         o_q : out std_logic_vector(N-1 downto 0) );
end component;

----------------------------------------------------------------------
-- Signal declarations
----------------------------------------------------------------------
signal s_clk, s_clk2, s_rst_n, s_rst2_n, s_clr2_n, s_lex, s_pbx : std_logic;
signal s_cnt : std_logic_vector(23 downto 0);

----------------------------------------------------------------------
begin
brdRstClk_0 : brdRstClk
  port map(
    i_rst_n => DEVRST_N,
    i_clk   => OSC_CLK,
    o_rst_n => s_rst_n,
    o_clk   => s_clk,
    o_lex   => s_lex,
    o_pbx   => s_pbx );

myDffCnt_0 : myDffCnt
  generic map( N => s_cnt'high+1 )
  port map(
    i_rst_n => s_rst_n,
    i_clk   => s_clk,
    o_q     => s_cnt );

  s_clk2   <= s_cnt(s_cnt'high-0);
--LED0     <= s_cnt(s_cnt'high-1) xor (PB2 xor s_pbx);
  s_rst2_n <= PB1 xor s_pbx;

  s_clr2_n <= s_rst2_n; -- removed reset sync function for ES

noReset : process(s_clk2)
  -- the init value will NEVER reach the register via := here
  -- variable/signal/register will contain random value 
  variable v_sft : std_logic_vector(4 downto 0) := "00011";
  begin
    if (s_clk2'event and s_clk2 = '1') then
      v_sft := v_sft(0) & v_sft(4 downto 1);
    end if;
    LED0 <= v_sft(0) xor s_lex;
  end process;

asyncReset : process(s_clk2, s_rst_n)
  -- this aSync Reset will come at NO extra resource cost 
  variable v_sft : std_logic_vector(4 downto 0);
  begin
    if (s_rst_n = '0') then
      v_sft := "00011";
    elsif (s_clk2'event and s_clk2 = '1') then
      v_sft := v_sft(0) & v_sft(4 downto 1);
    end if;
    LED2 <= v_sft(0) xor s_lex;
  end process;

syncReset : process(s_clk2, s_rst_n)
  --  Sync Reset may cost additional LUT resources
  variable v_sft : std_logic_vector(4 downto 0);
  begin
    if (s_clk2'event and s_clk2 = '1') then
      if (s_clr2_n = '0') then
        v_sft := "00011";
      else
        v_sft := v_sft(0) & v_sft(4 downto 1);
      end if;
    end if;
    LED4 <= v_sft(0) xor s_lex;
  end process;

syncResetEna : process(s_clk2, s_rst_n)
  -- Sync Reset may cost additional LUT resources
  -- (Enable has priority over sync set/reset)
  variable v_sft : std_logic_vector(4 downto 0);
  begin
    if (s_clk2'event and s_clk2 = '1') then
      if (s_clr2_n = '0') then
        v_sft := "00011";
      else
        if(PB2=s_pbx) then -- idle
          v_sft := v_sft;
        else
          v_sft := v_sft(0) & v_sft(4 downto 1);
        end if;
      end if;
    end if;
    LED6 <= v_sft(0) xor s_lex;
  end process;

  UART_TXD <= UART_RXD; -- dummy

end RTL;