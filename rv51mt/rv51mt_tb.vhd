----------------------------------------------------------------------
-- Created by Microsemi SmartDesign Thu Oct  9 21:37:30 2025
-- Testbench Template
-- This is a basic testbench that instantiates your design with basic 
-- clock and reset pins connected.  If your design has special
-- clock/reset or testbench driver requirements then you should 
-- copy this file and modify it. 
----------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: rv51mt_tb.vhd
-- File history:
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--
-- Description: 
--
-- <Description here>
--
-- Targeted device: <Family::PolarFire> <Die::MPF050T> <Package::FCSG325>
-- Author: <Name>
--
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

entity rv51mt_tb is
end rv51mt_tb;

architecture behavioral of rv51mt_tb is

    constant SYSCLK_PERIOD : time := 5 ns; -- 200MHZ

    signal SYSCLK : std_logic := '0';
    signal NSYSRESET : std_logic := '0';
    signal s_gpi, s_gpo         : std_logic_vector(7 downto 0) := (others=>'0');
    signal s_sch, s_tid, s_vld  : std_logic_vector(3 downto 0);
    signal s_pc0, s_pc4         : std_logic_vector(15 downto 0);

    component rv51mt
        -- ports
        port( 
            -- Inputs
            i_clk : in std_logic;
            i_rst_n : in std_logic;
            i_gpi : in std_logic_vector(7 downto 0);

            -- Outputs
            o_sch : out std_logic_vector(3 downto 0);
            o_tid : out std_logic_vector(3 downto 0);
            o_vld : out std_logic_vector(3 downto 0);
            o_pc0 : out std_logic_vector(15 downto 0);
            o_pc4 : out std_logic_vector(15 downto 0);
            o_gpo : out std_logic_vector(7 downto 0)

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
            wait for ( SYSCLK_PERIOD * 2 );
            
            NSYSRESET <= '1';
            wait;
        end if;
    end process;

    -- Clock Driver
    SYSCLK <= not SYSCLK after (SYSCLK_PERIOD / 2.0 );

    -- Instantiate Unit Under Test:  rv51mt
    rv51mt_0 : rv51mt
        -- port map
        port map( 
            -- Inputs
            i_clk => SYSCLK,
            i_rst_n => NSYSRESET,
            i_gpi => s_gpi,

            -- Outputs
            o_sch => s_sch,
            o_tid => s_tid,
            o_vld => s_vld,
            o_pc0 => s_pc0,
            o_pc4 => s_pc4,
            o_gpo => s_gpo

        );

end behavioral;

