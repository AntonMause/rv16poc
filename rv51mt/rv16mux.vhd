--------------------------------------------------------------------------------
-- File: rv16mux.vhd   >>>>> a lot to do <<<<<<
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use work.rv16pkg.all;

--------------------------------------------------------------------------------
entity rv16mux is generic(XLEN : natural := 32);
port (
  i_ins  : in  std_logic_vector(31 downto 0);
  i_load : in std_logic;
  i_ldat : in  std_logic_vector(31 downto 0);  -- load data
  i_ladr : in  std_logic_vector( 1 downto 0);  -- load pointer
--i_mux  : in  std_logic_vector(15 downto 0);
  i_alu  : in  std_logic_vector(XLEN-1 downto 0);
--  i_mem  : in  std_logic_vector(XLEN-1 downto 0);
  o_reg  : out std_logic_vector(XLEN-1 downto 0) );
end rv16mux;

--                byte  -o3-  -o2-  -o1-  -o0-
--  sft lft  7 -  0  :  -i3-  -i2-  -i1-  -i0-   shmt[5:4]=00 *
--  sft lft 15 -  8  :  -i2-  -i1-  -i0-  ----   shmt[5:4]=01
--  sft lft 23 - 16  :  -i1-  -i0-  ----  ----   shmt[5:4]=10
--  sft lft 31 - 24  :  -i0-  ----  ----  ----   shmt[5:4]=11
--  sft rgt  7 -  0  :  -i3-  -i2-  -i1-  -i0-   shmt[5:4]=00 *
--  sft rgt 15 -  8  :  -msb  *i3-  -i2-  -i1-   shmt[5:4]=01
--  sft rgt 23 - 16  :  -msb  -msb  *i3-  -i2-   shmt[5:4]=10
--  sft rgt 31 - 24  :  -msb  -msb  -msb  *i3-   shmt[5:4]=11

--  sft lft  7 -  0  :  -i3-  -i2-  -i1-  -i0-   shmt[5:4]=00 *
--  sft rgt  7 -  0  :  -i3-  -i2-  -i1-  -i0-   shmt[5:4]=00 *


--     byte0 < 3.2.1.0.- 
--     byte1 < 3.2.1.0.-.m 
--     byte2 < 3.2.1.0.-.m 
--     byte3 < 3.2.1.0. .m 


-- sgn  <= 0 when (2)='1' else byt[adr[1:0]];
--------------------------------------------------------------------------------
architecture rtl of rv16mux is

signal s_ins, s_inp, s_out : std_logic_vector(31 downto 0); -- instruction
signal s_fu3 : std_logic_vector(2 downto 0);
signal s_in0, s_in1, s_in2, s_in3, s_ou0, s_ou1, s_ou2, s_ou3, s_msb : std_logic_vector( 7 downto 0);
signal s_rs1, s_pc0, s_pcj, s_pcr, s_pcb, s_pcx : unsigned(XLEN-1 downto 0);

signal s_ldat_msb : std_logic_vector(3 downto 0); -- most significant bit of each byte loaded
signal s_ldat_sgn : std_logic;                    -- sign to set for output
signal s_lsgn, s_ldat : std_logic_vector(31 downto 0); -- full size sign, full output
signal s_lwrd         : std_logic_vector(15 downto 0); -- loaded word, address decoded
signal s_lbyt         : std_logic_vector( 7 downto 0); -- loaded byte, address decoded

begin

  -- copy input to local signal, convert to internal format
  s_ins    <= i_ins;               -- current instruction
  s_fu3    <= s_ins(14 downto 12); -- 3 bit of (sub) function
  
  s_inp    <= i_alu;

  s_msb    <= (others=>'1') when (s_inp(31)='1') else (others=>'0');
 
  
  
  -- fu3  000=lb     100=lbu    load byte
  --      001=lh     101=lhu    load half
  --      010=lw          this code assumes valid address and length combinations else it will fail
  s_ldat_msb <= i_ldat(31) & i_ldat(23) & i_ldat(15) & i_ldat(7);       -- extract msb of each byte
  s_ldat_sgn <= '0'                                         when (s_fu3(2) = '1') -- load unsigned
           else s_ldat_msb( to_integer(unsigned(i_ladr)+1)) when (s_fu3(0) = '1') -- load halfword
           else s_ldat_msb( to_integer(unsigned(i_ladr)+0));                      -- load byte(word)
  s_lsgn   <= (others=>'1') when (s_ldat_sgn='1') else (others=>'0');
  s_lwrd   <= i_ldat(31 downto 16) when (i_ladr(1)='1') else i_ldat(15 downto 0); -- upper / lower half
  s_lbyt   <= s_lwrd(15 downto  8) when (i_ladr(0)='1') else s_lwrd( 7 downto 0); -- upper / lower byte
  s_ldat   <= i_ldat                                 when (s_fu3(1) = '1') -- load word
         else s_lsgn(31 downto 16) & s_lwrd          when (s_fu3(0) = '1') -- load half
         else s_lsgn(31 downto  8) & s_lbyt;                               -- load byte
  s_out    <= s_ldat when (i_load='1') else i_alu;

  s_in3    <= s_inp(31 downto 24); -- msb
  s_in2    <= s_inp(23 downto 16);
  s_in1    <= s_inp(15 downto  8);
  s_in0    <= s_inp( 7 downto  0); -- lsb

  s_ou3    <= s_in3;
  s_ou2    <= s_in2;
  s_ou1    <= s_in1;
  s_ou0    <= s_in0;
  
--  s_out    <= s_ou3 & s_ou2 & s_ou1 & s_ou0;
  o_reg    <= s_out;

end rtl;
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- rv16pcx_bench  bechmark this IP between two registers
-- constrain to 300MHz(g3) 300MHz(g5), synths to:
--        AGL-0 A3P-1 M2S-1 MPF-1 (MHz)
--                          ???
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use work.rv16pkg.all;

entity rv16mux_bench is generic(XLEN : natural := 32);
port (
  i_clk : in  std_logic;
  i_ins : in  std_logic_vector(31 downto 0);
  i_pc0 : in  std_logic_vector(XLEN-1 downto 0);
  i_alu : in  std_logic_vector(XLEN-1 downto 0);
  o_reg : out std_logic_vector(XLEN-1 downto 0) );
end rv16mux_bench;

architecture rtl of rv16mux_bench is
	signal s_ins, s_dec, s_alu, s_pc0, s_reg : std_logic_vector(31 downto 0);
begin

mux_bench_p : process(i_clk)
  begin
    if (i_clk'event and i_clk = '1') then
      s_ins <= i_ins;
      s_pc0 <= i_pc0;
      s_alu <= i_alu;
      o_reg <= s_reg;
    end if;
  end process;

rv16mux_0 : rv16mux generic map(XLEN=>XLEN) port map( i_ins => s_ins, i_load=>s_ins(30), i_ldat => s_pc0, i_ladr => s_ins(29 downto 28), i_alu => s_alu, o_reg => s_reg );

end rtl;

--  load w  31 -  0  :  -i3-  -i2-  -i1-  -i0-    adr[1:0]=00 *
--  load h  31 - 16  :  -msb  -msb  *i3-  -i2-    adr[1:0]=10
--  load h  15 -  0  :  -msb  -msb  *i1-  -i0-    adr[1:0]=00 *
--  load b  31 - 24  :  -msb  -msb  -msb  *i3-    adr[1:0]=11
--  load b  23 - 16  :  -msb  -msb  -msb  *i2-    adr[1:0]=10
--  load b  15 -  8  :  -msb  -msb  -msb  *i1-    adr[1:0]=01
--  load b   7 -  0  :  -msb  -msb  -msb  *i0-    adr[1:0]=00 *
-- store w              -i3-  -i2-  -i1-  -i0-
-- store h              -i1-  -i0-  -i1-  -i0-
-- store b              -i0-  -i0-  -i0-  -i0-

-- ori    $8401
-- l.0     8401
--  r.0    84010
--  r.4    F8401
-- l.1     0802
--  r.3    F0802
-- l.2     1004
--  r.2    E1004
-- l.3     2008
--  r.1    C2008
-- l.4     4010
--  r.0    84010

-- ori    $8765
-- sgn   $F8765 for ari sft rig
-- uns   $08765 for log sft rig
-- l.2   $E1D94
-- sgn2r  $E1D9
-- uns2r  $21D9

--     byte0 < 3.2.1.0    +shift right
--     byte1 < 3.2.1.msb
--     byte2 < 3.2.m.msb
--     byte3 < 3.m.m.msb

-- or4a <= (i2 & e2) | i3 & e3)
-- or4b <= (i0 & e0) | i1 & e1)
-- out  <= or4a | or4b | (msb & sel)
