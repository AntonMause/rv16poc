
----------------------------------------------------------------------
-- myPllOsc (for RTG4)
----------------------------------------------------------------------
-- (c) 2016 by Anton Mause
--
-- Instantiate 50 MHz OnChip RC Oscillator and use PLL to get 50 MHz
-- (kept initial SmartFusion2 naming, did use 1MHz there)
--
-- !!Watch Out!! Think twice where the OnChip Oscillator can be used.
-- The datasheet allows it to be up to tbd% off, beside having 1% typ.
-- In real world you face silicon, power and temperature variations.
--
-- Check if PLL locks even with narrow limits to see quality of board.
-- Consider using LOCK as RESET for sequencial components.
--
----------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

library rtg4;
use rtg4.all;

----------------------------------------------------------------------
entity myPllOsc1x50 is
port (
	o_clk   : OUT std_logic;
	o_rst_n : OUT std_logic );
end myPllOsc1x50;

----------------------------------------------------------------------
architecture DEF_ARCH of myPllOsc1x50 is

  component RCOSC_50MHZ
    port( CLKOUT : out std_logic );
  end component;

  component VCC
    port( Y : out   std_logic );
  end component;

  component GND
    port( Y : out   std_logic );
  end component;

  component CLKINT
    port( A : in    std_logic := 'U';
          Y : out   std_logic );
  end component;

  component CCC
    generic (INIT:std_logic_vector(174 downto 0) := "000" & x"0000000000000000000000000000000000000000000"; 
        VCOFREQUENCY:real := 0.0);
    port( BUSY            : out   std_logic;
          APB_S_PREADY    : out   std_logic;
          APB_S_PSLVERR   : out   std_logic;
          Y0              : out   std_logic;
          Y1              : out   std_logic;
          Y2              : out   std_logic;
          Y3              : out   std_logic;
          LOCK            : out   std_logic;
          PLL_LOCK        : out   std_logic_vector(2 downto 0);
          APB_S_PSEL      : in    std_logic := 'U';
          CLK0            : in    std_logic := 'U';
          CLK1            : in    std_logic := 'U';
          CLK2            : in    std_logic := 'U';
          CLK3            : in    std_logic := 'U';
          GL0_Y0_EN       : in    std_logic := 'U';
          GL1_Y1_EN       : in    std_logic := 'U';
          GL2_Y2_EN       : in    std_logic := 'U';
          GL3_Y3_EN       : in    std_logic := 'U';
          PLL_BYPASS_N    : in    std_logic := 'U';
          PLL_POWERDOWN_N : in    std_logic := 'U';
          PLL_ARST_N      : in    std_logic := 'U';
          GPD0_ARST_N     : in    std_logic := 'U';
          GPD1_ARST_N     : in    std_logic := 'U';
          GPD2_ARST_N     : in    std_logic := 'U';
          GPD3_ARST_N     : in    std_logic := 'U';
          GL0_Y0_ARST_N   : in    std_logic := 'U';
          GL1_Y1_ARST_N   : in    std_logic := 'U';
          GL2_Y2_ARST_N   : in    std_logic := 'U';
          GL3_Y3_ARST_N   : in    std_logic := 'U';
          CLK0_PAD        : in    std_logic := 'U';
          CLK1_PAD        : in    std_logic := 'U';
          CLK2_PAD        : in    std_logic := 'U';
          CLK3_PAD        : in    std_logic := 'U';
          RCOSC_50MHZ     : in    std_logic := 'U';
          GL0             : out   std_logic;
          GL1             : out   std_logic;
          GL2             : out   std_logic;
          GL3             : out   std_logic;
          DEL_CLK_REF     : out   std_logic;
          APB_S_PRDATA    : out   std_logic_vector(7 downto 0);
          APB_S_PWDATA    : in    std_logic_vector(7 downto 0) := (others => 'U');
          APB_S_PADDR     : in    std_logic_vector(7 downto 2) := (others => 'U');
          APB_S_PCLK      : in    std_logic := 'U';
          APB_S_PWRITE    : in    std_logic := 'U';
          APB_S_PENABLE   : in    std_logic := 'U';
          APB_S_PRESET_N  : in    std_logic := 'U' );
  end component;

  signal N_RCOSC_50MHZ : std_logic;
  signal gnd_net, vcc_net, GL0_net : std_logic;
  signal nc11, nc10, nc9, nc8, nc7, nc6, nc2, nc5, nc4, nc3, nc1 : std_logic;

begin

I_RCOSC_50MHZ : RCOSC_50MHZ
    port map(CLKOUT => N_RCOSC_50MHZ);

vcc_inst : VCC
    port map(Y => vcc_net);
    
gnd_inst : GND
    port map(Y => gnd_net);
    
GL0_INST : CLKINT
    port map(A => GL0_net, Y => o_clk);

CCC_INST : CCC
  --generic map(INIT => "000" & x"88101249000020A40404040664C993186181C11C16C", -- 1k ppm/narrow
    generic map(INIT => "000" & x"88101249000020B80404040664C993186181C11C16C", -- 6k ppm/wide lock
         VCOFREQUENCY => 800.000)

      port map(BUSY => OPEN, APB_S_PREADY => OPEN, APB_S_PSLVERR
         => OPEN, Y0 => OPEN, Y1 => OPEN, Y2 => OPEN, Y3 => OPEN, 
        LOCK => o_rst_n, PLL_LOCK(2) => nc7, PLL_LOCK(1) => nc6, 
        PLL_LOCK(0) => nc5, APB_S_PSEL => vcc_net, CLK0 => 
        vcc_net, CLK1 => vcc_net, CLK2 => vcc_net, CLK3 => 
        vcc_net, GL0_Y0_EN => vcc_net, GL1_Y1_EN => vcc_net, 
        GL2_Y2_EN => vcc_net, GL3_Y3_EN => vcc_net, PLL_BYPASS_N
         => vcc_net, PLL_POWERDOWN_N => vcc_net, PLL_ARST_N => 
        vcc_net, GPD0_ARST_N => vcc_net, GPD1_ARST_N => vcc_net, 
        GPD2_ARST_N => vcc_net, GPD3_ARST_N => vcc_net, 
        GL0_Y0_ARST_N => vcc_net, GL1_Y1_ARST_N => vcc_net, 
        GL2_Y2_ARST_N => vcc_net, GL3_Y3_ARST_N => vcc_net, 
        CLK0_PAD => gnd_net, CLK1_PAD => gnd_net, CLK2_PAD => 
        gnd_net, CLK3_PAD => gnd_net, RCOSC_50MHZ => N_RCOSC_50MHZ, 
        GL0 => GL0_net, GL1 => OPEN, GL2 => OPEN, GL3 => OPEN, 
        DEL_CLK_REF => OPEN, APB_S_PRDATA(7) => nc1, 
        APB_S_PRDATA(6) => nc9, APB_S_PRDATA(5) => nc8, 
        APB_S_PRDATA(4) => nc4, APB_S_PRDATA(3) => nc11, 
        APB_S_PRDATA(2) => nc3, APB_S_PRDATA(1) => nc10, 
        APB_S_PRDATA(0) => nc2, APB_S_PWDATA(7) => vcc_net, 
        APB_S_PWDATA(6) => vcc_net, APB_S_PWDATA(5) => vcc_net, 
        APB_S_PWDATA(4) => vcc_net, APB_S_PWDATA(3) => vcc_net, 
        APB_S_PWDATA(2) => vcc_net, APB_S_PWDATA(1) => vcc_net, 
        APB_S_PWDATA(0) => vcc_net, APB_S_PADDR(7) => vcc_net, 
        APB_S_PADDR(6) => vcc_net, APB_S_PADDR(5) => vcc_net, 
        APB_S_PADDR(4) => vcc_net, APB_S_PADDR(3) => vcc_net, 
        APB_S_PADDR(2) => vcc_net, APB_S_PCLK => vcc_net, 
        APB_S_PWRITE => vcc_net, APB_S_PENABLE => vcc_net, 
        APB_S_PRESET_N => vcc_net);

end DEF_ARCH;
--------------------------------------------------------------------------------

-- HowTo : This piece of source code was created using Libero SoC 11.7 :
-- Create new vhdl project, block flow, RT4G150-CG1657, no template, no files.
-- Create new SmartDesign, open catalog, drag Chip Oscillators and drop to canvas.
-- Configure CCC PLL to source from OnChip 50MHz RC Oscillator, connect OSC and CCC.
-- Promote signal to toplevel, generate component, open hdl and extract relevant components
-- WatchOut: Modify oscillator output signal name so it differs from component name.
