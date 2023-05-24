----------------------------------------------------------------------
-- File: tbi10_tb.vhd
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity tbi10_tb is
end tbi10_tb;

architecture behavioral of tbi10_tb is

    constant SYSCLK_PERIOD : time := 10 ns; -- 100MHZ

    signal SYSCLK : std_logic := '0';
    signal NSYSRESET : std_logic := '0';
    signal s_dati : std_logic_vector(9 downto 0);
    signal s_dato : std_logic_vector(7 downto 0);
    signal s_clk10, s_clk8 : std_logic;

    component tbi10to4 port( 
            i_clk   : in  std_logic;
            i_clk_d : in  std_logic;
            i_rst_n : in  std_logic;
            i_dat   : in  std_logic_vector(9 downto 0);
            o_clk10 : out std_logic;
            o_clk8  : out std_logic;
            o_dat   : out std_logic_vector(7 downto 0) );
    end component;

begin

    process
        variable vhdl_initial : BOOLEAN := TRUE;

    begin
        if ( vhdl_initial ) then
            -- Assert Reset
            NSYSRESET <= '0';
            s_dati <= (others=>'0');
            wait for ( SYSCLK_PERIOD * 2 );
            
            NSYSRESET <= '1';
            wait for ( SYSCLK_PERIOD * 1 );
            
            s_dati <= "1101100011";
            wait for ( SYSCLK_PERIOD * 1 );
            s_dati <= (others=>'0');
            wait for ( SYSCLK_PERIOD * 1.5 );
            
            s_dati <= "0101100011";
            wait for ( SYSCLK_PERIOD * 1 );
            s_dati <= (others=>'0');
            wait for ( SYSCLK_PERIOD * 1.5 );
            
            s_dati <= "1100111100";
            wait for ( SYSCLK_PERIOD * 1 );
            s_dati <= (others=>'0');
            wait for ( SYSCLK_PERIOD * 1.5 );
            
            s_dati <= "1101110110";
            wait for ( SYSCLK_PERIOD * 1 );
            s_dati <= (others=>'0');
            wait for ( SYSCLK_PERIOD * 1.5 );
            
            wait;
        end if;
    end process;

    -- Clock Driver
    SYSCLK <= not SYSCLK after (SYSCLK_PERIOD / 2.0 );

    -- Instantiate Unit Under Test:  tbi10to4
    tbi10to4_0 : tbi10to4 port map( 
            i_clk   => SYSCLK,
            i_clk_d => s_clk10,
            i_rst_n => NSYSRESET,
            i_dat   => s_dati,
            o_clk10 => s_clk10,
            o_clk8  => s_clk8,
            o_dat   => s_dato );

end behavioral;

