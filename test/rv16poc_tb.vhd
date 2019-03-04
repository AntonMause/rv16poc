----------------------------------------------------------------------
-- Created by Microsemi SmartDesign Sun Mar  3 22:35:02 2019
-- Testbench Template
-- This is a basic testbench that instantiates your design with basic 
-- clock and reset pins connected.  If your design has special
-- clock/reset or testbench driver requirements then you should 
-- copy this file and modify it. 
----------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: rv16poc_tb.vhd
-- File history:
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--
-- Description: 
--
-- <Description here>
--
-- Targeted device: <Family::SmartFusion2> <Die::M2S010S> <Package::144 TQ>
-- Author: <Name>
--
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

entity rv16poc_tb is
end rv16poc_tb;

architecture behavioral of rv16poc_tb is

    constant SYSCLK_PERIOD : time := 10 ns; -- 100MHZ

    signal SYSCLK : std_logic := '0';
    signal NSYSRESET : std_logic := '0';
    signal s_led : std_logic_vector(7 downto 0);

    component rv16poc
        -- ports
        port( 
            -- Inputs
            i_clk : in std_logic;
            i_rst_n : in std_logic;

            -- Outputs
            o_led : out std_logic_vector(7 downto 0)

            -- Inouts

        );
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

    -- Instantiate Unit Under Test:  rv16poc
    rv16poc_0 : rv16poc
        -- port map
        port map( 
            -- Inputs
            i_clk => SYSCLK,
            i_rst_n => NSYSRESET,

            -- Outputs
            o_led => s_led

            -- Inouts

        );

end behavioral;

