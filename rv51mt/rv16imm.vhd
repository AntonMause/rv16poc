--------------------------------------------------------------------------------
-- File: rv16imm.vhd   
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use work.rv16pkg.all;

--------------------------------------------------------------------------------
entity rv16imm is generic(XLEN : natural := 32);
port (
  i_ins : in  std_logic_vector(31 downto 0);
  o_imm : out std_logic_vector(XLEN-1 downto 0) );
end rv16imm;

--------------------------------------------------------------------------------
architecture rtl of rv16imm is

signal s_ins : std_logic_vector(31 downto 0); -- instruction
signal s_sgn, s_i_type : std_logic_vector(31 downto 0);

begin

  -- copy input to local signal, convert to internal format
  s_ins    <= i_ins;           -- current instruction

  -- convert immediate part of instructions to constant offsets
  s_sgn    <= (others=>'1') when (s_ins(31) = '1') else (others=>'0'); -- sign
  s_i_type <= s_sgn(31 downto 12)& s_ins(31 downto 25)& s_ins(24 downto 20);                 -- I-Type
  o_imm    <= s_i_type;

end rtl;
--------------------------------------------------------------------------------
