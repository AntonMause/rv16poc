----------------------------------------------------------------------
-- Created by SmartDesign Tue Mar  5 21:23:11 2019
-- Version: v12.0 12.500.0.22
----------------------------------------------------------------------

----------------------------------------------------------------------
-- Libraries
----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library smartfusion2;
use smartfusion2.all;
----------------------------------------------------------------------
-- my17Madd entity declaration
----------------------------------------------------------------------
entity my17Madd is
    -- Port list
    port(
        -- Inputs
        A0         : in  std_logic_vector(16 downto 0);
        A0_ACLR_N  : in  std_logic;
        A0_EN      : in  std_logic;
        A0_SCLR_N  : in  std_logic;
        B0         : in  std_logic_vector(16 downto 0);
        B0_ACLR_N  : in  std_logic;
        B0_EN      : in  std_logic;
        B0_SCLR_N  : in  std_logic;
        C          : in  std_logic_vector(16 downto 0);
        CARRYIN    : in  std_logic;
        CLK        : in  std_logic;
        C_ACLR_N   : in  std_logic;
        C_EN       : in  std_logic;
        C_SCLR_N   : in  std_logic;
        SUB        : in  std_logic;
        SUB_ACLR_N : in  std_logic;
        SUB_EN     : in  std_logic;
        SUB_SCLR_N : in  std_logic;
        -- Outputs
        CARRYOUT   : out std_logic;
        CDOUT      : out std_logic_vector(43 downto 0);
        P          : out std_logic_vector(34 downto 0)
        );
end my17Madd;
----------------------------------------------------------------------
-- my17Madd architecture body
----------------------------------------------------------------------
architecture RTL of my17Madd is
----------------------------------------------------------------------
-- Component declarations
----------------------------------------------------------------------
-- my17Madd_my17Madd_0_HARD_MULT_ADDSUB   -   Actel:SgCore:HARD_MULT_ADDSUB:1.0.100
component my17Madd_my17Madd_0_HARD_MULT_ADDSUB
    -- Port list
    port(
        -- Inputs
        A0         : in  std_logic_vector(16 downto 0);
        A0_ACLR_N  : in  std_logic;
        A0_EN      : in  std_logic;
        A0_SCLR_N  : in  std_logic;
        B0         : in  std_logic_vector(16 downto 0);
        B0_ACLR_N  : in  std_logic;
        B0_EN      : in  std_logic;
        B0_SCLR_N  : in  std_logic;
        C          : in  std_logic_vector(16 downto 0);
        CARRYIN    : in  std_logic;
        CLK        : in  std_logic;
        C_ACLR_N   : in  std_logic;
        C_EN       : in  std_logic;
        C_SCLR_N   : in  std_logic;
        SUB        : in  std_logic;
        SUB_ACLR_N : in  std_logic;
        SUB_EN     : in  std_logic;
        SUB_SCLR_N : in  std_logic;
        -- Outputs
        CARRYOUT   : out std_logic;
        CDOUT      : out std_logic_vector(43 downto 0);
        P          : out std_logic_vector(34 downto 0)
        );
end component;
----------------------------------------------------------------------
-- Signal declarations
----------------------------------------------------------------------
signal CARRYOUT_net_0 : std_logic;
signal CDOUT_net_0    : std_logic_vector(43 downto 0);
signal P_0            : std_logic_vector(34 downto 0);
signal CARRYOUT_net_1 : std_logic;
signal CDOUT_net_1    : std_logic_vector(43 downto 0);
signal P_0_net_0      : std_logic_vector(34 downto 0);
----------------------------------------------------------------------
-- TiedOff Signals
----------------------------------------------------------------------
signal GND_net        : std_logic;
signal CDIN_const_net_0: std_logic_vector(43 downto 0);

begin
----------------------------------------------------------------------
-- Constant assignments
----------------------------------------------------------------------
 GND_net          <= '0';
 CDIN_const_net_0 <= B"00000000000000000000000000000000000000000000";
----------------------------------------------------------------------
-- Top level output port assignments
----------------------------------------------------------------------
 CARRYOUT_net_1     <= CARRYOUT_net_0;
 CARRYOUT           <= CARRYOUT_net_1;
 CDOUT_net_1        <= CDOUT_net_0;
 CDOUT(43 downto 0) <= CDOUT_net_1;
 P_0_net_0          <= P_0;
 P(34 downto 0)     <= P_0_net_0;
----------------------------------------------------------------------
-- Component instances
----------------------------------------------------------------------
-- my17Madd_0   -   Actel:SgCore:HARD_MULT_ADDSUB:1.0.100
my17Madd_0 : my17Madd_my17Madd_0_HARD_MULT_ADDSUB
    port map( 
        -- Inputs
        A0_ACLR_N  => A0_ACLR_N,
        A0_SCLR_N  => A0_SCLR_N,
        A0_EN      => A0_EN,
        B0_SCLR_N  => B0_SCLR_N,
        B0_ACLR_N  => B0_ACLR_N,
        B0_EN      => B0_EN,
        C_ACLR_N   => C_ACLR_N,
        C_SCLR_N   => C_SCLR_N,
        C_EN       => C_EN,
        SUB        => SUB,
        SUB_ACLR_N => SUB_ACLR_N,
        SUB_SCLR_N => SUB_SCLR_N,
        SUB_EN     => SUB_EN,
        CLK        => CLK,
        CARRYIN    => CARRYIN,
        A0         => A0,
        B0         => B0,
        C          => C,
        -- Outputs
        CARRYOUT   => CARRYOUT_net_0,
        P          => P_0,
        CDOUT      => CDOUT_net_0 
        );

end RTL;
