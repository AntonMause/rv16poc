--------------------------------------------------------------------------------
-- File: rv16dwa.vhd
--------------------------------------------------------------------------------
-- address generator unit, calculate pointer for store memory access

--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use work.rv16pkg.all;

--------------------------------------------------------------------------------
entity rv16dwa is generic(XLEN : natural := 32);
port (
  i_ins : in  std_logic_vector(31 downto 0);
  i_rs1 : in  std_logic_vector(XLEN-1 downto 0);
  o_agu : out std_logic_vector(XLEN-1 downto 0) );
end rv16dwa;

--------------------------------------------------------------------------------
architecture rtl of rv16dwa is

signal s_ins : std_logic_vector(31 downto 0); -- instruction
signal s_sgn, s_s_type : std_logic_vector(XLEN-1 downto 0);
signal s_rs1, s_agu : signed(XLEN-1 downto 0);

begin

  s_ins    <= i_ins;           -- current instruction
  s_rs1    <= signed(i_rs1);   -- base address

  s_sgn    <= (others=>'1') when  (s_ins(31) = '1') else (others=>'0');          -- sign
  s_s_type <= s_sgn(XLEN-1 downto 12)& s_ins(31 downto 25)& s_ins(11 downto  7); -- S-Type
  
  s_agu    <= signed(s_rs1) + signed(s_s_type(XLEN-1 downto 0));                 -- store
  o_agu    <= std_logic_vector(s_agu);

end rtl;
--------------------------------------------------------------------------------