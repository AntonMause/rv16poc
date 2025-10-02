--------------------------------------------------------------------------------
-- File: rv16one.vhd  early results, only based on PC and instruction (no regs)
--------------------------------------------------------------------------------
-- 	LUI, AUIPC = add zero or old PC to 20 upper constant bits
--	JAL, JALR  = add 4 to old PC as return value (this is not the new jump target)
--               all these results target the destination register not the new PC

--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.NUMERIC_STD.ALL;
use work.rv16pkg.all;

--------------------------------------------------------------------------------
entity rv16one is generic(XLEN : natural := 32);
port (
  i_ins : in  std_logic_vector(31 downto 0);
  i_pc0 : in  std_logic_vector(XLEN-1 downto 0);
  o_alu : out std_logic_vector(XLEN-1 downto 0) );
end rv16one;

--------------------------------------------------------------------------------
architecture rtl of rv16one is

signal s_ins : std_logic_vector(31 downto 0); -- instruction
signal s_u_type : std_logic_vector(31 downto 0);
signal s_pc0, s_pc4, s_lui, s_aui, s_alu, s_alx : unsigned(XLEN-1 downto 0);

begin

  -- copy input to local signal, convert to internal format
  s_ins    <= i_ins;             -- current instruction
  s_pc0    <= unsigned(i_pc0);   -- programm counter (+0 = old = not yet updated)

  -- convert immediate part of instructions to constant offsets
  s_u_type <= s_ins(31 downto 12)& x"000";                              -- U-Type

  -- add offset to base pointer for each type of instruction and constant
  s_lui    <= unsigned(signed(s_u_type(XLEN-1 downto 0)));                 -- LUI
  s_aui    <= unsigned(signed(s_pc0) + signed(s_u_type(XLEN-1 downto 0))); -- AUIPC  is PC  +i
  s_pc4    <= unsigned(signed(s_pc0) + 4);                                 -- PC  +4

  -- this ALU result is slow (but friendly, OR ready)
one_p : process(i_ins,s_pc0) -- decode all 7 opcode bits
  begin
	case s_ins(6 downto 0) is
 	when "0110111" => s_alu <= s_lui;         -- LUI
	when "0010111" => s_alu <= s_aui;         -- AUIPC;
	when "1101111" => s_alu <= s_pc4;         -- JAL;
	when "1100111" => s_alu <= s_pc4;         -- JALR;
	when others    => s_alu <= (others=>'0'); -- others;
    end case;
  end process;

  -- this ALX result is fast (but ugly, you can not OR it)
  s_alx    <= s_pc4 when(s_ins(6) = '1') -- any jump
         else s_lui when(s_ins(5) = '1') -- LUI
         else s_aui;                     -- AUIPC

--o_alu    <= std_logic_vector(s_alu); -- nice but slow
  o_alu    <= std_logic_vector(s_alx); -- fast but ugly
  
end rtl;
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- rv16bra_bench  bechmark this IP between two registers
-- constrain to 300MHz(g3) 100MHz(g5), synths to:
--        AGL-0 A3P-1 M2S-1 MPF-1 (MHz)
--                          478   ALX
--                          346   ALU
-- performance drops if constrained to more than 100 MHz
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use work.rv16pkg.all;

entity rv16one_bench is  generic(XLEN : natural := 32);
port (
  i_clk : in std_logic;
  i_ins : in  std_logic_vector(31 downto 0);
  i_pc0 : in  std_logic_vector(XLEN-1 downto 0);
  o_alu : out std_logic_vector(XLEN-1 downto 0) );
end rv16one_bench;

architecture rtl of rv16one_bench is
	signal s_ins        : std_logic_vector(31 downto 0);
	signal s_alu, s_pc0 : std_logic_vector(XLEN-1 downto 0);
begin

one_bench_p : process(i_clk)
  begin
    if (i_clk'event and i_clk = '1') then
      s_ins <= i_ins;
      s_pc0 <= i_pc0;
      o_alu <= s_alu;
    end if;
  end process;

rv16one_0 : rv16one generic map( XLEN => XLEN )
  port map( i_ins => s_ins, i_pc0 => s_pc0, o_alu => s_alu );

end rtl;