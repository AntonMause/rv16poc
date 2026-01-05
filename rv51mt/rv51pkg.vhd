--------------------------------------------------------------------------------
-- File: rv51pkg.vhd
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

package rv51pkg is

----------------------------------------------------------------------
-- Component declarations
----------------------------------------------------------------------
-- PF_SRAM_DAT
component PF_SRAM_DAT port(
        R_ADDR   : in  std_logic_vector(12 downto 0);
        R_CLK    : in  std_logic;
        WBYTE_EN : in  std_logic_vector(15 downto 0);
        W_ADDR   : in  std_logic_vector(12 downto 0);
        W_CLK    : in  std_logic;
        W_DATA   : in  std_logic_vector(31 downto 0);
        W_EN     : in  std_logic;
        R_DATA   : out std_logic_vector(31 downto 0) );
end component;

component PF_SRAM_INS port(
        R_ADDR : in  std_logic_vector(12 downto 0);
        R_CLK  : in  std_logic;
        R_EN   : in  std_logic;
        W_ADDR : in  std_logic_vector(12 downto 0);
        W_CLK  : in  std_logic;
        W_DATA : in  std_logic_vector(31 downto 0);
        W_EN   : in  std_logic;
        R_DATA : out std_logic_vector(31 downto 0) );
end component;

component PF_URAM_INS0 port(
        R_ADDR : in  std_logic_vector(4 downto 0);
        R_CLK  : in  std_logic;
        W_ADDR : in  std_logic_vector(4 downto 0);
        W_CLK  : in  std_logic;
        W_DATA : in  std_logic_vector(31 downto 0);
        W_EN   : in  std_logic;
        R_DATA : out std_logic_vector(31 downto 0) );
end component;

component PF_URAM_PCU0 port(
        R_ADDR : in  std_logic_vector(4 downto 0);
--      R_CLK  : in  std_logic;
        W_ADDR : in  std_logic_vector(4 downto 0);
        W_CLK  : in  std_logic;
        W_DATA : in  std_logic_vector(31 downto 0);
        W_EN   : in  std_logic;
        R_DATA : out std_logic_vector(31 downto 0) );
end component;
-- PF_URAM_SCH0
component PF_URAM_SCH0
    -- Port list
    port(
        -- Inputs
        R_ADDR : in  std_logic_vector(4 downto 0);
        R_CLK  : in  std_logic;
        W_ADDR : in  std_logic_vector(4 downto 0);
        W_CLK  : in  std_logic;
        W_DATA : in  std_logic_vector(31 downto 0);
        W_EN   : in  std_logic;
        -- Outputs
        R_DATA : out std_logic_vector(31 downto 0)
        );
end component;

end rv51pkg;

----------------------------------------------------------------------
package body rv51pkg is

end rv51pkg;
----------------------------------------------------------------------
