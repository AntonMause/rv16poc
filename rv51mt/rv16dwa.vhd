--------------------------------------------------------------------------------
-- File: rv16dwa.vhd
--------------------------------------------------------------------------------
-- address generator unit for writing to local memory
--    calculate pointer for store memory access
--    swap data to correct byte lane to write
--    enable relevant byte lane select

-- genering address from write #imm saves 1 level of mux

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
  i_rs2 : in  std_logic_vector(XLEN-1 downto 0);
  o_dwa : out std_logic_vector(XLEN-1 downto 0);
  o_dwd : out std_logic_vector(XLEN-1 downto 0);
  o_dws : out std_logic_vector(3 downto 0) );
end rv16dwa;

--------------------------------------------------------------------------------
architecture rtl of rv16dwa is

signal s_ins : std_logic_vector(31 downto 0); -- instruction
signal s_sgn, s_s_type        : std_logic_vector(XLEN-1 downto 0);
signal s_rs1, s_dwa           : signed(XLEN-1 downto 0);
signal s_rs2, s_dwd           : std_logic_vector(31 downto 0) := (others=>'0');
signal s_h1, s_h0             : std_logic_vector(15 downto 0) := (others=>'0');
signal s_b3, s_b2, s_b1, s_b0 : std_logic_vector( 7 downto 0) := (others=>'0');
signal s_dws, s_dwh, s_dwb    : std_logic_vector( 3 downto 0) := (others=>'0');

begin

  s_ins                  <= i_ins;           -- current instruction
  s_rs1                  <= signed(i_rs1);   -- base address
  s_rs2(XLEN-1 downto 0) <= i_rs2;           -- write data

  -- generate address from rs1 and sign ext #imm
  s_sgn    <= (others=>'1') when  (s_ins(31) = '1') else (others=>'0');          -- sign
  s_s_type <= s_sgn(XLEN-1 downto 12)& s_ins(31 downto 25)& s_ins(11 downto  7); -- S-Type
  
  s_dwa    <= signed(s_rs1) + signed(s_s_type(XLEN-1 downto 0));                 -- store
  o_dwa    <= std_logic_vector(s_dwa);

  -- swap data byte into place based on address only
  s_b0  <= s_rs2( 7 downto  0);                    -- byte0 = byte0, no mux
  s_b1  <= s_rs2( 7 downto  0) when (s_dwa(0)='1') -- byte1 = byte0 if odd1 adr
      else s_rs2(15 downto  8);
  s_h0  <= s_b1 & s_b0;                            -- merge lower half word
  s_h1  <= s_h0                when (s_dwa(1)='1') -- half1 = half0 if odd2 adr
      else s_rs2(31 downto 16);
  s_dwd <= s_h1 & s_h0;                            -- merge full word from halfs
  o_dwd <= s_dwd;

  -- generate byte select from address and instruction
  -- rv32i instruction bit 13:12   10=sw, 01=sh, 00=sb
  s_dwb    <= "1010" when (s_dwa(0)='1') else "0101";   -- select odd/even byte
  s_dwh    <= "1100" when (s_dwa(1)='1') else "0011";   -- select odd2/even half
  s_dws    <= "1111" when (s_ins(13) = '1')     -- store full word
         else s_dwh  when (s_ins(12) = '1')     -- store half word
         else (s_dwh and s_dwb);                -- store selected byte
  o_dws <= s_dws;
  
end rtl;
--------------------------------------------------------------------------------