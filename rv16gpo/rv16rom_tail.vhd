
-- tail -- tail -- tail -- tail -- tail -- tail -- tail -- tail -- tail -- 
    others=>x"0000" );
signal s_duo_adr0, s_duo_adr0_reg : std_logic_vector(IALEN-2 downto 0);
signal s_duo_adr1, s_duo_adr1_reg : std_logic_vector(IALEN-2 downto 0);
signal s_duo_out0, s_duo_out1     : std_logic_vector(15 downto 0);

begin
  s_clk     <= i_clk;

  -- i_adr() points to BYTE, remove 2 lsb to get LONG
  -- s_adr() points to HALF, add one lsb(1/0) again
  s_duo_adr0 <= i_adr(IALEN-1 downto 2) & '0';
  s_duo_adr1 <= i_adr(IALEN-1 downto 2) & '1';

duo_mem_p : process (s_clk)
  begin
    if rising_edge(s_clk) then
      s_duo_adr0_reg <= s_duo_adr0;
      s_duo_adr1_reg <= s_duo_adr1;
    end if;
  end process;
-- registered address / non pipelined output
  s_duo_out0 <= s_duo_mem(to_integer(unsigned(s_duo_adr0_reg)));
  s_duo_out1 <= s_duo_mem(to_integer(unsigned(s_duo_adr1_reg)));

  o_dat <= s_duo_out1 & s_duo_out0;

end rtl;