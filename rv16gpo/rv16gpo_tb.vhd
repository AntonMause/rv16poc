----------------------------------------------------------------------
-- Created by Microsemi SmartDesign Mon Nov 18 20:10:30 2019
-- Testbench Template
-- This is a basic testbench that instantiates your design with basic 
-- clock and reset pins connected.  If your design has special
-- clock/reset or testbench driver requirements then you should 
-- copy this file and modify it. 
----------------------------------------------------------------------

--------------------------------------------------------------------------------
-- File: rv16gpo_tb.vhd
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity rv16gpo_tb is
end rv16gpo_tb;

architecture behavioral of rv16gpo_tb is

    constant SYSCLK_PERIOD : time := 100 ns; -- 10MHZ
    constant IALEN : natural := 10;

    signal SYSCLK : std_logic := '0';
    signal NSYSRESET : std_logic := '0';
    signal s_irdy : std_logic;
    signal s_iadr : std_logic_vector(IALEN-1 downto 0);
    signal s_idat : std_logic_vector(31 downto 0);
    signal s_gpi, s_gpo : std_logic_vector(15 downto 0) := (others=>'0');

component rv16rom
generic( IALEN : natural );
port( i_clk : in  std_logic;
      i_adr : in  std_logic_vector(IALEN-1 downto 0);
      o_dat : out std_logic_vector(31 downto 0) );
end component;

    component rv16gpo
        port( 
            i_clk : in std_logic;
            i_rst_n : in std_logic;
            i_gpi : in std_logic_vector(15 downto 0);
            i_irdy : in std_logic;
            i_idat : in std_logic_vector(31 downto 0);
            o_isel : out std_logic;
            o_iadr : out std_logic_vector(9 downto 0);
            o_gpo : out std_logic_vector(15 downto 0) );
    end component;

begin

    process
        variable vhdl_initial : BOOLEAN := TRUE;

    begin
        if ( vhdl_initial ) then
            -- Assert Reset
            NSYSRESET <= '0';
            wait for ( SYSCLK_PERIOD * 10 );
            
            NSYSRESET <= '1';
            wait;
        end if;
    end process;

    -- Clock Driver
    SYSCLK <= not SYSCLK after (SYSCLK_PERIOD / 2.0 );

  rv16rom_0 : rv16rom
    generic map( IALEN => IALEN )
    port map ( i_clk => SYSCLK,
               i_adr => s_iadr,
               o_dat => s_idat );

    -- Instantiate Unit Under Test:  rv16gpo
    rv16gpo_0 : rv16gpo
        port map( 
            i_clk => SYSCLK,
            i_rst_n => NSYSRESET,
            i_gpi => s_gpi,
            i_irdy => s_irdy,
            i_idat => s_idat,
            o_isel =>  s_irdy,
            o_iadr => s_iadr,
            o_gpo => s_gpo );

    s_gpi <= s_gpo;
end behavioral;

