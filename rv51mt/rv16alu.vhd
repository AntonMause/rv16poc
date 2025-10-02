--------------------------------------------------------------------------------
-- File: rv16alu.vhd
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use work.rv16pkg.all;

--------------------------------------------------------------------------------
entity rv16alu is generic(XLEN : natural := 32);
port (
  i_ins : in  std_logic_vector(31 downto 0);
  i_in1 : in  std_logic_vector(XLEN-1 downto 0);
  i_in2 : in  std_logic_vector(XLEN-1 downto 0);
  o_alu : out std_logic_vector(XLEN-1 downto 0) );
end rv16alu;

--------------------------------------------------------------------------------
architecture rtl of rv16alu is

signal s_ins : std_logic_vector(31 downto 0);
signal s_fu3 : std_logic_vector( 2 downto 0);
signal s_sft : std_logic_vector( 5 downto 0) := (others=>'0');
-- 0.ad? 1.sll 2.slt 3.sltu 4.xor 5.sr? 6.or 7.and

signal s_sgn, s_imm, s_in1, s_in2, s_alu : std_logic_vector(XLEN-0 downto 0);
signal s_slt : std_logic;

begin

--------------------------------------------------------------------------------
s_ins <= i_ins;
s_fu3 <= s_ins(14 downto 12); -- 3 bit of (sub) function (integer register instr. group)

s_sgn <= (others=>'1') when  (s_ins(31) = '1') else (others=>'0'); -- #imm sign
s_imm <= s_sgn(XLEN-0 downto 12) & s_ins(31 downto 20);            -- #imm I-Type

s_in1(XLEN-1 downto 0) <= i_in1;                                   -- rs1 = allways rs1
s_in1(XLEN)            <= s_in1(XLEN-1) and s_ins(14);             -- force (un)signed

s_in2(XLEN-1 downto 0) <= i_in2 when (s_ins(5) = '1') else s_imm(XLEN-1 downto 0);  -- rs2 = rs2 or #imm
s_in2(XLEN)            <= s_in2(XLEN-1) and s_ins(14);             -- force (un)signed (for set if lower than)
s_sft(     5 downto 0) <= s_in2(5 downto 0) and "000111";          -- extract relevant shift ammount bits

-- compare registers for "set if lower then" (un)signed
s_slt <= '1' when (          signed(s_in1)  <          signed(s_in2)) else '0';

alu_p : process(s_ins,s_fu3,s_in1,s_in2)
  begin
    case s_fu3 is     
    when "000"         => -- ADD / SUB(see instr. bit 30)
      if((s_ins(5)='1') and (s_ins(30)='1')) then
        s_alu   <= std_logic_vector( signed(s_in1) - signed(s_in2) ); -- sub only if not immediate
      else
        s_alu   <= std_logic_vector( signed(s_in1) + signed(s_in2) ); -- allways add if immediate 
      end if;

    when "001" => -- shift left
        s_alu <= std_logic_vector(shift_left(unsigned(s_in1), to_integer(unsigned(s_sft))));
    
    when "010" | "011" => -- SLT / SLTI / SLTU / SLTIU
        s_alu <= (0=>s_slt, others=>'0');

    when "101" => -- shift right
      if(s_ins(30)='1') then
        s_alu <= std_logic_vector(shift_right(signed(s_in1), to_integer(unsigned(s_sft))));
      else
        s_alu <= std_logic_vector(shift_right(unsigned(s_in1), to_integer(unsigned(s_sft))));
      end if;

    when "100" =>  s_alu  <= (s_in1 xor s_in2);  -- XOR
	when "110" =>  s_alu  <= (s_in1  or s_in2);  --  OR
	when "111" =>  s_alu  <= (s_in1 and s_in2);  -- AND
    when others => s_alu  <= (others=>'0'); -- zero (should not be reached)
  end case;
end process;  

  o_alu <= s_alu(XLEN-1 downto 0);
  
--------------------------------------------------------------------------------
-- 000 add (sub.30=1)
-- 001     sll
-- 010   slt
-- 011   sltu
-- 100 xor
-- 101     srl (sra.30=1)
-- 110 or
-- 111 and

-- bit manip Zba :  sh123add rd := rs1<<123 + rs2
-- ins  6:0   "0110011" (reg op)
-- fu3 14:12  1="010" 2="100" 3="110"
-- ins 31:25  "0010000"

end rtl;
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- rv16alu_bench  bechmark this IP between two registers
-- constrain to 300MHz(g3) 240MHz(g5), synths to:
--        AGL-0 A3P-1 M2S-1 MPF-1 (MHz)
--                          261
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use work.rv16pkg.all;

entity rv16alu_bench is  generic(XLEN : natural := 32);
port (
  i_clk : in std_logic;
  i_ins : in  std_logic_vector(31 downto 0);
  i_rs1 : in  std_logic_vector(XLEN-1 downto 0);
  i_rs2 : in  std_logic_vector(XLEN-1 downto 0);
  o_alu : out std_logic_vector(XLEN-1 downto 0) );
end rv16alu_bench;

architecture rtl of rv16alu_bench is
	signal s_ins        : std_logic_vector(31 downto 0);
	signal s_rs1, s_rs2 : std_logic_vector(XLEN-1 downto 0);
	signal s_alu        : std_logic_vector(XLEN-1 downto 0);
begin

alu_bench_p : process(i_clk)
  begin
    if (i_clk'event and i_clk = '1') then
      s_ins <= i_ins; -- xor s_alu;
      s_rs1 <= i_rs1;
      s_rs2 <= i_rs2;
      o_alu <= s_alu;
    end if;
  end process;

rv16alu_0 : rv16alu generic map( XLEN => XLEN )
  port map( i_ins => s_ins, i_in1 => s_rs1, i_in2 => s_rs2, o_alu => s_alu );

end rtl;