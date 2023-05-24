
----------------------------------------------------------------------
-- tbi10to4    (c) 2021 by Anton Mause
--           tbi = Ten Bit Interface = 8bit data + 2bit AC scrambling
--           4(8)= slice to feed to output (oserdes/gearbox/tranceiver)
----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;

----------------------------------------------------------------------
entity tbi10to4 is 
port (
  i_clk     : in  std_logic; -- 250 MHz system output clock
  i_clk_d   : in  std_logic; -- 100 MHz data input clock
  i_rst_n   : in  std_logic;
  i_dat     : in  std_logic_vector(9 downto 0);
  o_clk10   : out std_logic; -- 100 MHz = clk/2.5 = tbi input clock
  o_clk8    : out std_logic; -- 125 MHz = clk/2   = byte output clock
  o_dat     : out std_logic_vector(7 downto 0) );
end tbi10to4;

----------------------------------------------------------------------
architecture RTL of tbi10to4 is

----------------------------------------------------------------------
-- Signal declarations
----------------------------------------------------------------------
signal s_clk, s_rst_n, s_tgl, s_clk_d, s_odd_d : std_logic;
signal s_sft_upd, f_sft_bit, s_clk10 : std_logic;
signal r_sft_pat, r_sft_upd : std_logic_vector(4 downto 0);
signal s_tbi_dat, s_sft_dat : std_logic_vector(11 downto 0);
signal s_sft_clk8 : std_logic_vector(3 downto 0);

begin

----------------------------------------------------------------------
  s_clk     <= i_clk;
  s_clk_d   <= i_clk_d;
  s_rst_n   <= i_rst_n;

----------------------------------------------------------------------
-- - 0 1 2 3 4 5 6 7 8 9  10
-- 0_11111000001111100000_11111000001111100000_1 100 MHz
--   aaaabbbbccCCDDDDEEEE ffffgggghhHHIIIIJJJJ   upper case = odd tbi word
-- 0_11001100110011001100_11001100110011001100_1 250 MHz
--   11110000001111000000 (rise|fall)
--   11110000000000000000 rising
--   00000000001111000000 falling
--   00000000111100000000 s_odd     next input data is odd
-- 0_11001100110011001100_11001100110011001100_1 250 MHz
--   000011110000
r_sft_pat_p : process(s_clk, s_rst_n) --
  begin
    if (s_rst_n = '0') then
      s_sft_clk8 <= "0001";
      r_sft_pat  <= "00010";
      r_sft_upd  <= "10100";
    elsif (s_clk'event and s_clk = '1') then
      s_sft_clk8 <= s_sft_clk8( 2 downto 0) & s_sft_clk8(1);
      r_sft_pat  <= r_sft_pat(0) & r_sft_pat(4 downto 1);
      r_sft_upd  <= r_sft_upd(0) & r_sft_upd(4 downto 1);
    end if;
  end process;
  s_odd_d   <= r_sft_pat(2);
  s_sft_upd <= r_sft_upd(0);

f_sft_pat_p : process(s_clk, s_rst_n) --
  begin
    if (s_rst_n = '0') then
      f_sft_bit  <= '0';
    elsif (s_clk'event and s_clk = '0') then
      f_sft_bit <= s_odd_d;
    end if;
  end process;

  s_clk10 <= r_sft_pat(4) or f_sft_bit;
--s_clk_d <= s_clk10;
  o_clk10 <= s_clk10;       -- 10 bit clock 
  o_clk8  <= s_sft_clk8(3); --  8 bit clock
--o_clk4  <= s_clk;         --  4 bit clock = system clock

----------------------------------------------------------------------
-- - 0 1 2 3 4 5 6 7 8 9  10
--   aaaabbbbccCCDDDDEEEE ffffgggghhHHIIIIJJJJ   upper case = odd tbi word
--   000000000000    -    000000000000
--   aaaabbbbcc00 <  0    000000000000  (even input)
--   aaaabbbbcc00    2 >  aaaabbbbcc00  (even update)
--   aaaabbbbcc00    4    bbbbcc000000
--   ccCCDDDDEEEE <  5    bbbbcc000000  (odd input)
--   ccCCDDDDEEEE    6 >  ccCCDDDDEEEE  (odd update)
--   ccCCDDDDEEEE    8    DDDDEEEE0000
--   ffffgggghh00 < 10    EEEE00000000  (even input)
--   ffffgggghh00   12 >  ffffgggghh00  (even update)
----------------------------------------------------------------------
tbi_dat_p : process(s_clk_d, s_rst_n)
  begin
    if (s_rst_n = '0') then
      s_tbi_dat  <= (others=>'0');
    elsif (s_clk_d'event and s_clk_d = '1') then
      if(s_odd_d = '1') then
        s_tbi_dat <= i_dat & s_tbi_dat(9 downto 8);
      else
        s_tbi_dat <= "00" & i_dat;
      end if;
    end if;
  end process;

----------------------------------------------------------------------
sft_dat_p : process(s_clk, s_rst_n)
  begin
    if (s_rst_n = '0') then
      s_sft_dat  <= (others=>'0');
    elsif (s_clk'event and s_clk = '1') then
      if(s_sft_upd = '1') then
        s_sft_dat <= s_tbi_dat;
      else
        s_sft_dat <= "0000" & s_sft_dat(11 downto 4);
      end if;
    end if;
  end process;
--o_dat <= s_sft_dat(7 downto 0); -- for 8 & 4 bit mode
  o_dat <= "0000" & s_sft_dat(3 downto 0); -- force 4 lsb

----------------------------------------------------------------------

end RTL;
