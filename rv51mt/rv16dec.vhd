--------------------------------------------------------------------------------
-- File: rv16dec.vhd    basic sparse risc-v instruction decoder
--                      
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.rv16pkg.all;

--------------------------------------------------------------------------------
entity rv16dec is port (
  i_ins : in  std_logic_vector(31 downto 0);
  o_dec : out std_logic_vector(31 downto 0) );
end rv16dec;

--------------------------------------------------------------------------------
architecture rtl of rv16dec is
begin

--------------------------------------------------------------------------------
decode_sparse_p : process(i_ins) -- decode only relevant sparse bits
  variable v_ins : std_logic_vector(6 downto 0);
  variable v_dec : std_logic_vector(o_dec'left downto 0);
  begin
    v_ins := i_ins(v_ins'range); -- instruction shortform
    v_dec := (others=>'0');

    --                   6543210
    if std_match(v_ins, "-11-1--") then v_dec(t_decode'pos(D_Lui  )) := '1';    end if;  -- upd  fast
    if std_match(v_ins, "-01-1--") then v_dec(t_decode'pos(D_Auipc)) := '1';    end if;  -- upd  fast
    if std_match(v_ins, "1--11--") then v_dec(t_decode'pos(D_Jal  )) := '1';    end if;  -- upd  fast
    if std_match(v_ins, "1--01--") then v_dec(t_decode'pos(D_Jalr )) := '1';    end if;  -- upd  fast
    if std_match(v_ins, "1-0-0--") then v_dec(t_decode'pos(D_Bra  )) := '1';    end if;
    if std_match(v_ins, "-000---") then v_dec(t_decode'pos(D_Load )) := '1';    end if;  -- upd
    if std_match(v_ins, "0100---") then v_dec(t_decode'pos(D_Store)) := '1';    end if;
    if std_match(v_ins, "-01-0--") then v_dec(t_decode'pos(D_ImmOp)) := '1';    end if;  -- upd
    if std_match(v_ins, "011-0--") then v_dec(t_decode'pos(D_RegOp)) := '1';    end if;  -- upd
    if std_match(v_ins, "-001---") then v_dec(t_decode'pos(D_Mem  )) := '1';    end if;
    if std_match(v_ins, "0101---") then v_dec(t_decode'pos(D_Amo  )) := '1';    end if;  -- upd
    if std_match(v_ins, "1-1----") then v_dec(t_decode'pos(D_Sys  )) := '1';    end if;  -- upd
    --
    -- early/fast instructions that not wait for reading register
    if std_match(v_ins, "--1-1--") then v_dec(t_decode'pos(D_Fast )) := '1';    end if;  -- Lui + Auipc
    if std_match(v_ins, "1-0-1--") then v_dec(t_decode'pos(D_Fast )) := '1';    end if;  -- Jump* (no rs1/2)
    --
    -- updating instructions that write to destination register
    if std_match(v_ins, "--1----") then v_dec(t_decode'pos(D_Upd  )) := '1';    end if;  -- update rd
    if std_match(v_ins, "-10-1--") then v_dec(t_decode'pos(D_Upd  )) := '1';    end if;
    if std_match(v_ins, "-0-0---") then v_dec(t_decode'pos(D_Upd  )) := '1';    end if;
    --
    -- illegal instruction, only course decoding for speed sane
    if std_match(v_ins, "10-----") then v_dec(t_decode'pos(D_Ill  )) := '1';    end if;  -- illegal RVI
    if std_match(v_ins, "---10--") then v_dec(t_decode'pos(D_Ill  )) := '1';    end if;
    --
    -- compressed instruction, merge with illegal if not supported
    if std_match(v_ins, "-----00") then v_dec(t_decode'pos(D_RVC  )) := '1';    end if;  --   valid RVC
    if std_match(v_ins, "-----01") then v_dec(t_decode'pos(D_RVC  )) := '1';    end if;
    if std_match(v_ins, "-----10") then v_dec(t_decode'pos(D_RVC  )) := '1';    end if;
    o_dec                      <= v_dec;
  end process;

--------------------------------------------------------------------------------
  -- 65432   -=ignore
  -- -000-   load
  -- -001-   mem (fence)
  -- -01-1   auipc
  -- -11-1   lui
  -- -01-0   op#
  -- 0100-   store
  -- 0101-   amo
  -- 011-0   op
  -- 1-0-0   bra   
  -- 1--01   jalr
  -- 1--11   jal
  -- 1-1--   sys
  -- 10---   illegal or these together
  -- ---10   illegal 
  -- -----11 not illegal (non compressed)

  -- rv32.Zba,  rd = rs1 << n + rs2,  n = 0..3
  -- sh1add 0010000 rs2 rs1 010 rd 011?011    RegOp
  -- sh2add 0010000 rs2 rs1 100 rd 011?011    RegOp
  -- sh3add 0010000 rs2 rs1 110 rd 011?011    RegOp
  --
  -- rv32i  isolate shift by #0..3 constant
  -- slli   0000000 shamt rs1 001 rd 0010011  ImmOp
  -- masked ------- 000-- rs1 001 rd ???????
  
  
-- instr[4:2] 000    001    010    011    100    101    110     111
--  [65] 00   load*  loadfp cust0  mem    op-im* auipc* op-im32 ---
--       01   stor*  storfp cust1  amo    op*    lui*   op32    ---
--       10   madd   msub   nmsub  nmadd  op-fp  res    rv128   ---
--       11   bra*   jalr*  res    jal*   sys*   res    rv128   ---

-- instr[4:2] 000    001    010    011    100    101    110     111
--  [65] 00   load   -?-    ---    mem    op-im  auipc  ---     ---
--       01   stor   -?-    ---    amo    op     lui    ---     ---
--       10   ---    ---    ---    ---    ---    ---    ---     ---
--       11   bra    jalr   ---    jal    sys    ---    ---     ---
  
  
end rtl;
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- rv16dec_bench  bechmark this IP between two registers
-- constrain to 300MHz(g3) 800MHz(g4/5), synths to:
--        AGL-0 A3P-1 M2S-1 MPF-1 (MHz)
-- sparse  ?      ?     ?   835
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use work.rv16pkg.all;

entity rv16dec_bench is port (
  i_clk : in std_logic;
  i_ins : in  std_logic_vector(31 downto 0);
  o_dec : out std_logic_vector(31 downto 0) );
end rv16dec_bench;

architecture rtl of rv16dec_bench is
	signal s_ins, s_dec : std_logic_vector(31 downto 0);
begin

dec_bench_p : process(i_clk)
  begin
    if (i_clk'event and i_clk = '1') then
      s_ins <= i_ins;
      o_dec <= s_dec;
    end if;
  end process;

rv16dec_0 : rv16dec port map( i_ins => s_ins, o_dec => s_dec );

end rtl;

-- AMO encoding
-- 00010 aq rl 00000 rs1 010 rd 0101111     lr.w  # load reserved  Zalrsc
-- 00011 aq rl  rs2  rs1 010 rd 0101111     sc.w  # store conditional
-- 00001 aq rl  rs2  rs1 010 rd 0101111     amoswap.w   # Zaamo
-- 00000 aq rl  rs2  rs1 010 rd 0101111     amoadd.w
-- 00100 aq rl  rs2  rs1 010 rd 0101111     amoxor.w
-- 01100 aq rl  rs2  rs1 010 rd 0101111     amoand.w
-- 01000 aq rl  rs2  rs1 010 rd 0101111     amoor.w
-- 10000 aq rl  rs2  rs1 010 rd 0101111     amomin.w
-- 10100 aq rl  rs2  rs1 010 rd 0101111     amomax.w
-- 11000 aq rl  rs2  rs1 010 rd 0101111     amominu.w
-- 11100 aq rl  rs2  rs1 010 rd 0101111     amomaxu.w
-- 00101 aq rl  rs2  rs1 010 rd 0101111     amocas.w     # compare and swap Zacas
--  000= byte  001= half 010= word  011= double         # Zabha
