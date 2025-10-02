--------------------------------------------------------------------------------
-- File: rv16pcx.vhd   risc-v programm counter, jumps and branch calculations
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use work.rv16pkg.all;

--------------------------------------------------------------------------------
entity rv16pcx is generic(XLEN : natural := 32);
port (
  i_ins : in  std_logic_vector(31 downto 0);
  i_pc0 : in  std_logic_vector(XLEN-1 downto 0);
  i_rs1 : in  std_logic_vector(XLEN-1 downto 0);
  o_pcx : out std_logic_vector(XLEN-1 downto 0) );
end rv16pcx;

--------------------------------------------------------------------------------
architecture rtl of rv16pcx is

signal s_ins : std_logic_vector(31 downto 0); -- instruction
signal s_sgn, s_b_type, s_i_type, s_j_type : std_logic_vector(31 downto 0);
signal s_rs1, s_pc0, s_pcj, s_pcr, s_pcb, s_pcx : unsigned(XLEN-1 downto 0);
signal s_flg : std_logic;

begin

  -- copy input to local signal, convert to internal format
  s_ins    <= i_ins;           -- current instruction
  s_pc0    <= unsigned(i_pc0); -- programm counter (+0 = old = not yet updated)
  s_rs1    <= unsigned(i_rs1); -- base address from source register 1

  -- convert immediate part of instructions to constant offsets
  s_sgn    <= (others=>'1') when (s_ins(31) = '1') else (others=>'0'); -- sign
  s_b_type <= s_sgn(31 downto 12)& s_ins(7)& s_ins(30 downto 25) & s_ins(11 downto  8)& '0'; -- B-Type 
  s_i_type <= s_sgn(31 downto 12)& s_ins(31 downto 25)& s_ins(24 downto 20);                 -- I-Type
  s_j_type <= s_sgn(31 downto 20)& s_ins(19 downto 12)& s_ins(20)& s_ins(30 downto 21)& '0'; -- J-Type  

  -- add offset to base pointer for each type of instruction and constant
  s_pcb    <= unsigned(signed(s_pc0) + signed(s_b_type(XLEN-1 downto 0))); -- branch to PC  +b
  s_pcr    <= unsigned(signed(s_rs1) + signed(s_i_type(XLEN-1 downto 0))); -- jump   to RS1 +i
  s_pcj    <= unsigned(signed(s_pc0) + signed(s_j_type(XLEN-1 downto 0))); -- jump   to PC  +j

--  s_ins 6543210
--  when "110--11" => similar coding;
--  when "1101111" => v_dec := D_Jal;
--  when "1100111" => v_dec := D_Jalr;
--  when "1100011" => v_dec := D_Bra;
--s_pcx    <= s_pcb when(s_ins(2) = '0') -- branch pc+
--       else s_pcj when(s_ins(3) = '1') -- jump   pc+
--       else s_pcr;                     -- jump   rs1+
  s_flg    <= '1' when(s_ins(3 downto 2) = "10") else '0'; -- jump rs1+i
  s_pcx    <= s_pcr when(s_flg    = '1') -- jump   rs1+
         else s_pcj when(s_ins(3) = '1') -- jump   pc+
         else s_pcb;                     -- branch pc+
  o_pcx    <= std_logic_vector(s_pcx);

end rtl;
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- rv16pcx_bench  bechmark this IP between two registers
-- constrain to 300MHz(g3) 400MHz(g5), synths to:
--        AGL-0 A3P-1 M2S-1 MPF-1 (MHz)
--                          451
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use work.rv16pkg.all;

entity rv16pcx_bench is generic(XLEN : natural := 32);
port (
  i_clk : in  std_logic;
  i_ins : in  std_logic_vector(31 downto 0);
  i_pc0 : in  std_logic_vector(XLEN-1 downto 0);
  i_rs1 : in  std_logic_vector(XLEN-1 downto 0);
  o_pcx : out std_logic_vector(XLEN-1 downto 0) );
end rv16pcx_bench;

architecture rtl of rv16pcx_bench is
	signal s_ins, s_dec, s_rs1, s_pc0, s_pcx : std_logic_vector(31 downto 0);
begin

dec_bench_p : process(i_clk)
  begin
    if (i_clk'event and i_clk = '1') then
      s_ins <= i_ins;
      s_pc0 <= i_pc0;
      s_rs1 <= i_rs1;
      o_pcx <= s_pcx;
    end if;
  end process;

rv16pcx_0 : rv16pcx generic map(XLEN=>XLEN) port map( i_ins => s_ins, i_pc0 => s_pc0, i_rs1 => s_rs1, o_pcx => s_pcx );

end rtl;
