--------------------------------------------------------------------------------
-- File: rv16dec.vhd
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.numeric_std.all;
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
decode_seven_p : process(i_ins) -- decode all 7 opcode bits
  variable v_ins : std_logic_vector(6 downto 0);
  variable v_dec : t_decode;
  variable v_msk : std_logic_vector(o_dec'left downto 0);
  begin
    v_ins := i_ins(v_ins'range); -- instruction shortform
    --v_ins(1 downto 0)  :=  "11"; -- force LSBs to 32bit mode
    --v_ins := i_ins(6 downto 2) & "11"; -- instruction shortform
    v_dec := D_Load;

    --    6543210
	case v_ins(v_ins'range) is
	when "0110111" => v_dec := D_Lui;
	when "0010111" => v_dec := D_Auipc;
	when "1101111" => v_dec := D_Jal;
	when "1100111" => v_dec := D_Jalr;
	when "1100011" => v_dec := D_Bra;
	when "0000011" => v_dec := D_Load;
	when "0100011" => v_dec := D_Store;
	when "0010011" => v_dec := D_ImmOp;
	when "0110011" => v_dec := D_RegOp;
	when others    => v_dec := D_Load;
    end case;
    -- convert enumeration type to one hot bitfield
    v_msk                      := (others=>'0');
    v_msk(t_decode'pos(v_dec)) := '1';
  --  o_dec                      <= v_msk;
  end process;

--------------------------------------------------------------------------------
decode_five_p : process(i_ins) -- decode only 5 bits, ignore 16bit instructions
  variable v_ins : std_logic_vector(6 downto 2);
  variable v_dec : t_decode;
  variable v_msk : std_logic_vector(o_dec'left downto 0);
  begin
    v_ins := i_ins(v_ins'range); -- instruction shortform
    v_dec := D_Load;

    --    65432
	case v_ins(v_ins'range) is
	when "01101" => v_dec := D_Lui;
	when "00101" => v_dec := D_Auipc;
	when "11011" => v_dec := D_Jal;
	when "11001" => v_dec := D_Jalr;
	when "11000" => v_dec := D_Bra;
	when "00000" => v_dec := D_Load;
	when "01000" => v_dec := D_Store;
	when "00100" => v_dec := D_ImmOp;
	when "01100" => v_dec := D_RegOp;
	when others  => v_dec := D_Load;
    end case;
    -- convert enumeration type to one hot bitfield
    v_msk                      := (others=>'0');
    v_msk(t_decode'pos(v_dec)) := '1';
  --o_dec                      <= v_msk;
  end process;

--------------------------------------------------------------------------------
decode_sparse_p : process(i_ins) -- no way to synthesise :-(
  variable v_ins : std_logic_vector(6 downto 0);
  variable v_dec : t_decode;
  variable v_msk : std_logic_vector(o_dec'left downto 0);
  begin
    v_ins := i_ins(v_ins'range); -- instruction shortform
    v_ins(1 downto 0)  :=  "11"; -- force LSBs to 32bit mode
    v_dec := D_Load;

    --    6543210
	case v_ins(v_ins'range) is
	when "-11-1--" => v_dec := D_Lui;
	when "-01-1--" => v_dec := D_Auipc;
	when "1--11--" => v_dec := D_Jal;
	when "1--01--" => v_dec := D_Jalr;
	when "1---0--" => v_dec := D_Bra;
	when "000----" => v_dec := D_Load;  -- (2)=flw/lw reg(32..63)
	when "010----" => v_dec := D_Store; -- (2)=fsw/sw reg(32..63)
	when "-01-0--" => v_dec := D_ImmOp;
	when "-11-0--" => v_dec := D_RegOp;
    end case;
    -- convert enumeration type to one hot bitfield
    v_msk                      := (others=>'0');
    v_msk(t_decode'pos(v_dec)) := '1';
--    o_dec                      <= v_msk;
  end process;

--------------------------------------------------------------------------------
decode_enum_p : process(i_ins) -- convert to enum first, than bitvector
  variable v_ins : std_logic_vector(6 downto 2);
  variable v_dec : t_decode;
  variable v_msk : std_logic_vector(o_dec'left downto 0);
  begin
    v_ins := i_ins(v_ins'range); -- instruction shortform
    v_dec := D_Load;

    if(v_ins(6)='1') then     -- do  (bra | jal | jalr)
      if(v_ins(2)='1') then   -- do  (      jal | jalr)
        if(v_ins(3)='1') then -- do  (      jal       )
          v_dec := D_Jal;
        else                  -- do  (            jalr)
          v_dec := D_Jalr;
        end if;
      else                    -- do  (bra             )
        --v_dec := D_Cmp;     -- compare before branch
          v_dec := D_Bra;
      end if;
    else                      -- not (branch or jump )
      if(v_ins(4)='0') then   -- do  (load | store   )
        if(v_ins(5)='1') then -- do  (       store   )
          v_dec := D_Store;
        else                  -- do  (load           )
          v_dec := D_Load;
        end if;
      end if;
    end if;
    if(v_ins(4)='1') then     -- do  (any register op)
      if(v_ins(2)='1') then   -- do  (lui | auipc)
        if(v_ins(5)='1') then -- do  (lui        )
          v_dec := D_Lui;
        else                  -- do  (      auipc)
          v_dec := D_Auipc;
        end if;
      else                    -- do  (any to reg op)
        if(v_ins(5)='1') then -- do  (reg to reg op)
          v_dec := D_RegOp;
        else                  -- do  (#im to reg op)
          v_dec := D_ImmOp;
        end if;
      end if;
    end if;

    -- convert enumeration type to one hot bitfield
    v_msk                      := (others=>'0');
    v_msk(t_decode'pos(v_dec)) := '1';
    o_dec                      <= v_msk;
  end process;

--------------------------------------------------------------------------------
decode_onehot_p : process(i_ins) -- convert directly to bitvector
  variable v_ins : std_logic_vector(6 downto 2);
  variable v_dec : std_logic_vector(o_dec'left downto 0);
  begin
    v_ins := i_ins(v_ins'range); -- instruction shortform
    v_dec := (others=>'0');

    if(v_ins(6)='1') then     -- do  (bra | jal | jalr)
      if(v_ins(2)='1') then   -- do  (      jal | jalr)
        if(v_ins(3)='1') then -- do  (      jal       )
          v_dec(t_decode'pos(D_Jal)) := '1';
        else                  -- do  (            jalr)
          v_dec(t_decode'pos(D_Jalr)) := '1';
        end if;
      else                    -- do  (bra             )
        --v_dec := D_Cmp;     -- compare before branch
          v_dec(t_decode'pos(D_Bra)) := '1';
      end if;
    else                      -- not (branch or jump )
      if(v_ins(4)='0') then   -- do  (load | store   )
        if(v_ins(5)='1') then -- do  (       store   )
          v_dec(t_decode'pos(D_Store)) := '1';
        else                  -- do  (load           )
          v_dec(t_decode'pos(D_Load)) := '1';
        end if;
      end if;
    end if;
    if(v_ins(4)='1') then     -- do  (any register op)
      if(v_ins(2)='1') then   -- do  (lui | auipc)
        if(v_ins(5)='1') then -- do  (lui        )
          v_dec(t_decode'pos(D_Lui)) := '1';
        else                  -- do  (      auipc)
          v_dec(t_decode'pos(D_Auipc)) := '1';
        end if;
      else                    -- do  (any to reg op)
        if(v_ins(5)='1') then -- do  (reg to reg op)
          v_dec(t_decode'pos(D_RegOp)) := '1';
        else                  -- do  (#im to reg op)
          v_dec(t_decode'pos(D_ImmOp)) := '1';
        end if;
      end if;
    end if;
--    o_dec <= v_dec;
  end process;
  -- 65432   x=0   x=1   -=ignore
  -- 0x0--   load  store
  -- -x1-0   op#   op
  -- -x1-1   auipc lui
  -- 1---0   bra   
  -- 1--x1   jalr  jal

end rtl;
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- rv16dec_bench  bechmark this IP between two registers
-- constrain to 300MHz(g3) 800MHz(g4/5), synths to:
--        AGL-0 A3P-1 M2S-1 MPF-1 (MHz)
-- seven   152   215   498   700  ins(6:0)
-- five    144   203   500   744  ins(6:2)
-- sparse (unable to synth don't care)
-- enum    176   249   590   842
-- onehot  219   309   649   914
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