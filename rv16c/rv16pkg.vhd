----------------------------------------------------------------------
-- rv16pkg

----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

----------------------------------------------------------------------
package rv16pkg is
--type t_decode is (D_Ill, D_Load, D_Store, D_ImmOp, D_RegOp, D_Auipc, D_Lui, D_Bra, D_Jal, D_Jalr, D_Cmp);
  type t_decode is (D_Load, D_Store, D_ImmOp, D_RegOp, D_Auipc, D_Lui, D_Bra, D_Jal, D_Jalr);

component rv16dec is port (
  i_ins : in  std_logic_vector(31 downto 0);
  o_dec : out std_logic_vector(31 downto 0) );
end component;

end rv16pkg;

----------------------------------------------------------------------
package body rv16pkg is

end rv16pkg;

----------------------------------------------------------------------
