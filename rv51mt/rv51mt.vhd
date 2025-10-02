----------------------------------------------------------------------------------
-- Module Name: rv51mt.vhd             playground for multi thread programm flow
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.rv16pkg.all;
use work.rv51pkg.all;

----------------------------------------------------------------------------------
-- t0: tid<nxt         schedule next thread to get and run
-- t1: pc0<tbl(tid)    get next thread pointer to execute
-- t2: ins<rom(pc0)    fetch instruction for current thread
-- t3: dec<ins         decode instruction and read register rs1/rs2
-- t4: alu<exe(early)  most alu operations
-- t5: reg<two(late)   byte swap and write
--     byte0 < 3.2.1.0    +shift right
--     byte1 < 3.2.1.msb
--     byte2 < 3.2.m.msb
--     byte3 < 3.m.m.msb
----------------------------------------------------------------------------------
-- PLEN   length of Programm pointer length
-- XLEN   length of ALU execution length
-- RLEN   length of Programm ROM image
entity rv51mt is
generic(PLEN : natural := 16; XLEN : natural := 32; RLEN : natural := 12);
port (
  i_clk     : in  std_logic;
  i_rst_n   : in  std_logic;
  i_gpi     : in  std_logic_vector( 7 downto 0);
  o_sch     : out std_logic_vector( 3 downto 0);
  o_tid     : out std_logic_vector( 3 downto 0);
  o_vld     : out std_logic_vector( 3 downto 0);
  o_pc0     : out std_logic_vector(PLEN-1 downto 0);
  o_pc4     : out std_logic_vector(PLEN-1 downto 0);
  o_gpo     : out std_logic_vector( 7 downto 0) );
end rv51mt;

architecture RTL of rv51mt is

----------------------------------------------------------------------
signal s_clk, s_rst_n : std_logic;

----------------------------------------------------------------------
-- t0: schedule next thread ID
--signal s0_tbl : std_logic_vector(31 downto 0) := x"8121312F";
  signal s0_tbl : std_logic_vector(31 downto 0) := x"09234967";  -- just one
--signal s0_tbl : std_logic_vector(31 downto 0) := x"09ACB9A7";  -- no duo
--signal s0_tbl : std_logic_vector(31 downto 0) := x"09A9B9A7";  -- with duo
signal n0_run : std_logic := '0';
signal n1_mx2 : std_logic := '0'; -- mux if same ID found 2 stages appart
signal s_ifu_lsb : std_logic_vector(15 downto 0) := (OTHERS=>'0');

-- ori type reg_mem_type is array (31 downto 0) of std_logic_vector (XLEN-1 downto 0);
type reg_mem_type is array (0 to 127) of std_logic_vector (XLEN-1 downto 0);
signal s_reg_mem : reg_mem_type := ( x"00000000",x"00000001",x"00000002",OTHERS=>x"00000A00" );
--attribute syn_ramstyle of object : objectType is "string" ;
attribute syn_ramstyle : string;
attribute syn_ramstyle of s_reg_mem : signal is "uram";

-- pcu programm counter unit memory and logic signals
--type pcu_mem_type is array (0 to 15) of std_logic_vector (PLEN-1 downto 0);
type pcu_mem_type is array (0 to  7) of std_logic_vector (PLEN-1 downto 0);
signal s_pcu_mem : pcu_mem_type := ( x"0000", x"0110", x"0200", x"0300", x"0400", x"0500", x"0600", x"0700", others=>x"0F00" );
signal s_pcu_val_rd, s_pcu_val_wr : std_logic_vector(PLEN-1 downto 0) := (OTHERS=>'0');
signal s_pcu_idx_rd, s_pcu_idx_wr : std_logic_vector( 2 downto 0) := (OTHERS=>'0');
signal s_pcu_sel_rd, s_pcu_sel_wr, s_pcu_run : std_logic := '0';
signal s_pcu_adr_rd0, s_pcu_adr_wr0 : std_logic_vector( 4 downto 0) := (OTHERS=>'0');
signal s_pcu_val_rd0, s_pcu_val_wr0 : std_logic_vector(31 downto 0) := (OTHERS=>'0');
signal s_pcu_val_rd1, s_pcu_val_rd2 : std_logic_vector(PLEN-1 downto 0) := (OTHERS=>'0');

-- signal for instruction fetch unit -----------------------------------------------
signal s2_rd0, s2_rdw, s3_rdw                           : std_logic;
signal s2_rs1, s2_rs2, s2_rd, s3_rs1, s3_rs2, s3_rd     : std_logic_vector(4 downto 0);
signal s3_rg1, s3_rg2, s3_imm, s3_rx2, s3_alu           : std_logic_vector(XLEN-1 downto 0);

----------------------------------------------------------------------
signal s1_tid, s2_tid, s3_tid, s4_tid, n1_tid : std_logic_vector(3 downto 0) := (OTHERS=>'0');
signal s1_pc0i,s1_pc0, s2_pc0, s2_pc4, s3_pc0, s3_pc4, s3_pcx, s4_pc4 : std_logic_vector(PLEN-1 downto 0) := (OTHERS=>'0');
signal n0_pc0, n1_pc4, n2_pc0, n2_pc4, n3_pc4 : std_logic_vector(PLEN-1 downto 0) := (OTHERS=>'0');
signal s2_insi,s2_ins, s2_dec, s3_ins, s3_dec : std_logic_vector(31 downto 0) := (OTHERS=>'0');
signal s2_dex : t_decode;
signal n2_dat,  s2_dat : std_logic_vector(31 downto 0);

signal s3_bra,  s3_jmp  : std_logic := '0';
signal s2_pc0x, s3_pc0x, s3_pcxx : std_logic_vector(XLEN-1 downto 0);
signal s3_dat  : std_logic_vector(XLEN-1 downto 0);
signal s2_one, s3_one : std_logic_vector(XLEN-1 downto 0); -- alu results
----------------------------------------------------------------------
-- pra, prd, dra, drd, dwa, dwd,    programm / data / register,  read/write,  addres/data/select
signal s_pwa, s_pra, s_dra, s_dwa, s_rwa, s_rra1, s_rra2 : std_logic_vector(31 downto 0) := (OTHERS=>'0'); -- address
signal s_pwd, s_prd, s_drd, s_dwd, s_rwd, s_rrd1, s_rrd2 : std_logic_vector(31 downto 0) := (OTHERS=>'0'); -- data
signal s_pws, s_prs, s_drs, s_dws : std_logic := '0';                               -- select

begin

----------------------------------------------------------------------
  s_clk     <= i_clk;
  s_rst_n   <= i_rst_n;
  n0_run    <= '1'; -- i_gpi(7);

----------------------------------------------------------------------
-- t0: simple static thread scheduler
sch_tbl_p : process (s_clk)
  begin
    if rising_edge(s_clk) then
      s0_tbl <=  s0_tbl(s0_tbl'length-5 downto 0) & s0_tbl(s0_tbl'length-1 downto s0_tbl'length-4);
    end if;
  end process;
  n1_tid     <= s0_tbl(3 downto 0);
  o_sch      <= n1_tid;
  o_tid      <= s1_tid;

----------------------------------------------------------------------
-- t1: read PC for scheduled thread TID from inferred table (and write back in t?)
pcu_mem_p : process (s_clk)
  begin
    if rising_edge(s_clk) then
      if (s2_tid(3) = '1') then -- '0' = skip updating this thread
        s_pcu_mem(to_integer (unsigned(s2_tid(2 downto 0)))) <= s3_pcx;
      end if;
    end if;
  end process;
  s1_pc0i <= s_pcu_mem(to_integer (unsigned(n1_tid(2 downto 0)))); -- read from inferrence
----------------------------------------------------------------------
-- array of programm pointer
  s_pcu_adr_rd0 <=    "00" & n1_tid(2 downto 0);
  s_pcu_adr_wr0 <=    "00" & s2_tid(2 downto 0);
  s_pcu_val_wr0 <= x"0000" & s3_pcx;
PF_URAM_PCU_0 : PF_URAM_PCU0 port map( 
        W_DATA => s_pcu_val_wr0,
        R_ADDR => s_pcu_adr_rd0,
        W_ADDR => s_pcu_adr_wr0,
        W_EN   => s2_tid(3),
      --R_CLK  => s_clk, -- reading asynchron
        W_CLK  => s_clk,
        R_DATA => s_pcu_val_rd0  );
--s1_pc0 <= s_pcu_val_rd0(PLEN-1 downto 0); -- use instantiation
  s1_pc0 <= s1_pc0i;                        -- use inference data
  n1_mx2     <=   n1_tid(3) when (n1_tid = s2_tid) else '0';  -- use tid(3) to indicate activity

----------------------------------------------------------------------
-- t2: select PC to use for next instruction fetch from table or from short cut
  n2_pc0     <=   s1_pc0 and x"00FF" when (n1_mx2 = '0') else s2_pc4; -- read from memory or inc4
  o_pc0      <=   n2_pc0;
  n2_pc4     <=   std_logic_vector(unsigned(s1_pc0) +4);
  o_pc4      <=   n2_pc4;
  o_vld      <=   s4_tid(3) & s3_tid(3) & s2_tid(3) & s1_tid(3);
  
----------------------------------------------------------------------
-- t2: instruction SRAM to fetch from
rv16rom0 : rv16rom
  generic map( PLEN => RLEN )
  port map ( i_clk => s_clk,
             i_adr => std_logic_vector(n2_pc0(RLEN-1 downto 0)),
             o_dat => s2_insi );
------------------------------------------------------------------------
PF_SRAM_INS_0 : PF_SRAM_INS port map( 
        W_DATA => (others=>'0'),
        W_ADDR => (others=>'1'),
        R_ADDR => n2_pc0(14 downto 2),
        W_EN   => '0',
        W_CLK  => s_clk,
        R_CLK  => s_clk,
--        R_DATA => open);    -- use inference
        R_DATA => s2_ins);    -- use   instance
--s2_ins    <= s2_insi;       -- use inference
s_ifu_lsb <= s2_ins(15 downto 0);
----------------------------------------------------------------------
ctl_p : process(s_clk,s_rst_n)
  begin
    if (s_rst_n = '0') then
      s1_tid       <=  (OTHERS=>'0');
      s2_tid       <=  (OTHERS=>'0');
      s2_pc0       <=  (OTHERS=>'0');
      s2_pc4       <=  (OTHERS=>'0');
      s3_pc0       <=  (OTHERS=>'0');
      s3_pc4       <=  (OTHERS=>'0');
      s3_ins       <=  (OTHERS=>'0');
      s3_dec       <=  (OTHERS=>'0');
      s3_rd        <=  (OTHERS=>'0');
      s3_rdw       <=  '0';
      s3_one       <=  (OTHERS=>'0');
      s4_pc4       <=  (OTHERS=>'0');
    elsif rising_edge(s_clk) then  -- t0 schedule
      s1_tid       <=  n1_tid;     -- t1 get pc
      s2_tid       <=  s1_tid;     -- t2 fetch ins
      s2_pc0       <=  s1_pc0;
      s2_pc4       <=  n2_pc4;
      s2_dat       <=  n2_dat;
      s3_tid       <=  s2_tid;     -- t3 decode rs
      s3_pc0       <=  s2_pc0;
      s3_pc4       <=  s2_pc4;
      s3_ins       <=  s2_ins;
      s3_dec       <=  s2_dec;
      s3_rd        <=  s2_rd;
      s3_rdw       <=  s2_rdw;
      s3_one       <=  s2_one;
      s4_tid       <=  s3_tid;     -- t4 execute
      s4_pc4       <=  s3_pc4;
    end if;
  end process;                     -- t5 write

----------------------------------------------------------------------
-- t2: (pre)decode while loading instruction
rv16dec_0 : rv16dec port map( i_ins => s2_ins, o_dec => s2_dec );

s2_pc0x <= x"0000" & s2_pc0;
rv16one_0 : rv16one port map( i_ins => s2_ins, i_pc0 => s2_pc0x, o_alu => s2_one); 
-- early results for jal, jalr, lui, auipc (no registers required)

  s2_rd   <= s2_ins(11 downto  7); -- register destination
  s2_rd0  <= '0' when(s2_rd = "00000") else '1'; -- destination not zero
  s2_rs1  <= s2_ins(19 downto 15); -- register source one
  s2_rs2  <= s2_ins(24 downto 20); -- register source two
  s2_rdw  <= s1_tid(3) and s2_rd0 and s2_dec(t_decode'pos(D_Upd)); -- merged bits on decoder  << todo: adjust s1_ <> s2_

----------------------------------------------------------------------
-- t3: (final) decode and get register
  s3_pc0x <= x"0000" & s3_pc0;
--s3_dat  <= x"0000" & s4_pc4;
  s3_dat  <= s3_one;  -- fast result from operations without registers involved #imm only
  s_rwd   <= s_drd  when  (s3_dec(t_decode'pos(D_Load  )) = '1') -- reg <= load or any other ALU opp
        else s3_alu when ((s3_dec(t_decode'pos(D_ImmOp )) = '1') or (s3_dec(t_decode'pos(D_RegOp )) = '1'))
        else s3_dat;  -- fast results

----------------------------------------------------------------------
    s_rra1(4 downto 0) <= s2_rs1; -- rra = register read  address
    s_rra2(4 downto 0) <= s2_rs2; -- rwd = register write data
reg_mem_p : process (s_clk)
  begin
    if rising_edge(s_clk) then
      if (s3_rdw = '1') then -- write to destination register
        s_reg_mem(to_integer (unsigned(s3_rd))) <= s_rwd(XLEN-1 downto 0);
      end if;
--    s_rra1(4 downto 0) <= s2_rs1;
--    s_rra2(4 downto 0) <= s2_rs2;
      s3_rg1(XLEN-1 downto 0) <= s_reg_mem(to_integer (unsigned(s_rra1))); -- rs1
      s3_rg2(XLEN-1 downto 0) <= s_reg_mem(to_integer (unsigned(s_rra2))); -- rs2
    end if;
  end process;
--  s3_rg1(XLEN-1 downto 0) <= s_reg_mem(to_integer (unsigned(s_rra1))); -- rs1
--  s3_rg2(XLEN-1 downto 0) <= s_reg_mem(to_integer (unsigned(s_rra2))); -- rs2

rv16imm_0 : rv16imm generic map( XLEN => XLEN ) port map( i_ins => s3_ins, o_imm => s3_imm );

  s3_rx2   <= s3_rg2 when(s3_ins(5)='1') else s3_imm; -- alu.inp2 <= rs2 or #imm 
  
rv16alu_0 : rv16alu generic map( XLEN => XLEN )
  port map( i_ins => s3_ins, i_in1 => s3_rg1, i_in2 => s3_rx2, o_alu => s3_alu );
  
----------------------------------------------------------------------
-- t4: 
rv16bra_0 : rv16bra generic map( XLEN => XLEN ) -- compare rs1 and rs2 and decide if to branch
  port map( i_ins => s3_ins, i_rs1 => s3_rg1,  i_rs2 => s3_rg2,  o_bra => s3_bra );
  
rv16pcx_0 : rv16pcx generic map(XLEN=>XLEN) -- calculate neXt PC (jmp/bra)
  port map( i_ins => s3_ins, i_pc0 => s3_pc0x, i_rs1 => s3_rg1, o_pcx => s3_pcxx );

  s3_jmp <= s3_dec(t_decode'pos(D_Jal)) or s3_dec(t_decode'pos(D_JalR)) or s3_bra; -- jump or branch flag set
  s3_pcx <= s3_pcxx(PLEN-1 downto 0) when(s3_jmp) else s3_pc4; -- jump/branch  or continue pc+4 (PC neXt)

---------------------------------------------------------------------- Load / Store external memory
rv16dra_0 : rv16dra port map( i_ins => s3_ins, i_rs1 => s3_rg1, o_agu => s_dra );
rv16dwa_0 : rv16dwa port map( i_ins => s3_ins, i_rs1 => s3_rg1, o_agu => s_dwa );
  s_dwd <= s3_rg2;                -- write register rs2 to ext mem
  s_dws <= s3_tid(3) and s3_dec(t_decode'pos(D_Store));

----------------------------------------------------------------------
PF_SRAM_DAT_0 : PF_SRAM_DAT port map( 
        W_EN     => s_dws,
        W_CLK    => s_clk,
        R_CLK    => s_clk,
        W_DATA   => s_dwd,
        W_ADDR   => s_dwa(14 downto 2),
        R_ADDR   => s_dra(14 downto 2),
        WBYTE_EN => x"FFFF",
        R_DATA   => s_drd );

----------------------------------------------------------------------

end RTL;

-- instruction pool
-- 00000013 addi  x0, x0, 0   (nop)
-- 12345137 lui   x2, 0x12345