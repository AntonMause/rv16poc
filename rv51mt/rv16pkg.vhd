----------------------------------------------------------------------
-- rv16pkg

----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

----------------------------------------------------------------------
package rv16pkg is
  type t_decode is (D_Ill, D_Upd, D_Fast, D_RVC, D_Load, D_Store, D_ImmOp, D_RegOp, D_Auipc, D_Lui, D_Jal, D_Jalr, D_Bra, D_Sys, D_Mem, D_Amo);
  --                  1      2      4       8      10      20       40       80       100      200    400    800    1000    2000   4000   8000

component rv16alu is generic(XLEN : natural := 32);
port (
  i_ins : in  std_logic_vector(31 downto 0);
  i_in1 : in  std_logic_vector(XLEN-1 downto 0);
  i_in2 : in  std_logic_vector(XLEN-1 downto 0);
  o_alu : out std_logic_vector(XLEN-1 downto 0) );
end component;

component rv16agu is generic(XLEN : natural := 32);
port (
  i_ins : in  std_logic_vector(31 downto 0);
  i_rs1 : in  std_logic_vector(XLEN-1 downto 0);
  o_agu : out std_logic_vector(XLEN-1 downto 0) );
end component;

component rv16dra is generic(XLEN : natural := 32);
port (
  i_ins : in  std_logic_vector(31 downto 0);
  i_rs1 : in  std_logic_vector(XLEN-1 downto 0);
  o_agu : out std_logic_vector(XLEN-1 downto 0) );
end component;

component rv16dwa is generic(XLEN : natural := 32);
port (
  i_ins : in  std_logic_vector(31 downto 0);
  i_rs1 : in  std_logic_vector(XLEN-1 downto 0);
  i_rs2 : in  std_logic_vector(XLEN-1 downto 0);
  o_dwa : out std_logic_vector(XLEN-1 downto 0);
  o_dwd : out std_logic_vector(XLEN-1 downto 0);
  o_dws : out std_logic_vector(3 downto 0) );
end component;

component rv16bra is generic(XLEN : natural := 32);
port (
  i_ins : in  std_logic_vector(31 downto 0);
  i_rs1 : in  std_logic_vector(XLEN-1 downto 0);
  i_rs2 : in  std_logic_vector(XLEN-1 downto 0);
  o_bra : out std_logic );
end component;

component rv16dec is port (
  i_ins : in  std_logic_vector(31 downto 0);
  o_dec : out std_logic_vector(31 downto 0) );
end component;

component rv16pcx is generic(XLEN : natural := 32);
port (
  i_ins : in  std_logic_vector(31 downto 0);
  i_pc0 : in  std_logic_vector(XLEN-1 downto 0);
  i_rs1 : in  std_logic_vector(XLEN-1 downto 0);
  o_pcx : out std_logic_vector(XLEN-1 downto 0) );
end component;

component rv16one is generic(XLEN : natural := 32);
port (
  i_ins : in  std_logic_vector(31 downto 0);
  i_pc0 : in  std_logic_vector(XLEN-1 downto 0);
  o_alu : out std_logic_vector(XLEN-1 downto 0) );
end component;

component rv16rom is generic( PLEN : natural );
port( i_clk : in  std_logic;
      i_adr : in  std_logic_vector(PLEN-1 downto 0);
      o_dat : out std_logic_vector(31 downto 0) );
end component;

component rv16imm is generic(XLEN : natural := 32);
port (
  i_ins : in  std_logic_vector(31 downto 0);
  o_imm : out std_logic_vector(XLEN-1 downto 0) );
end component;

component rv16mux is generic(XLEN : natural := 32);
port (
  i_ins  : in  std_logic_vector(31 downto 0);
  i_load : in std_logic;
  i_ldat : in  std_logic_vector(31 downto 0);
  i_ladr : in  std_logic_vector( 1 downto 0);
--i_mux  : in  std_logic_vector(15 downto 0);
  i_alu  : in  std_logic_vector(XLEN-1 downto 0);
--i_mem  : in  std_logic_vector(XLEN-1 downto 0);
  o_reg  : out std_logic_vector(XLEN-1 downto 0) );
end component;


end rv16pkg;

----------------------------------------------------------------------
package body rv16pkg is

end rv16pkg;

----------------------------------------------------------------------
