--------------------------------------------------------------------------------
-- File: rv16c.vhd       ported from RI5CY System Verilog to VHDL
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

--------------------------------------------------------------------------------
entity rv16c is
port (
  i_ins   : in  std_logic_vector(31 downto 0);
  o_ins   : out std_logic_vector(31 downto 0);
  o_rvc   : out std_logic );
end rv16c;
--------------------------------------------------------------------------------
architecture rtl of rv16c is
  signal s_ins : std_logic_vector(15 downto 0);
  signal s_sgn12 : std_logic_vector(31 downto 0);
begin

s_ins <= i_ins(s_ins'range); -- reduce to 16 lower bit
s_sgn12 <= (others=>'1') when (s_ins(12) = '1') else (others=>'0');

----------------------------------------------------------------------
decode_p : process(s_ins,s_sgn12)
  begin
    --o_ins <= (others=>'1'); -- ~155 LUT4
    --o_ins <= s_sgn12;       -- ~151 LUT4
    --o_ins <= i_ins;         -- ~149 LUT4
    --o_ins <= (others=>'0'); -- ~130 LUT4
    o_ins <= (others=>'X');   -- ~119 LUT4  ~205 LUT3
    o_ins(1 downto 0) <= (others=>'1');
    
    case s_ins(1 downto 0) is
    when "00"   => -- ins[1:0] C0
      case s_ins(15 downto 13) is
      when "000"   => -- ins[15:13] c.addi4spn -> addi rd', x2, imm
        o_ins <= "00"& s_ins(10 downto 7)& s_ins(12 downto 11)& s_ins(5)& s_ins(6)& "00"& "00010"& "000"& "01"& s_ins(4 downto 2)& "0010011";
    --when "001"   => -- ins[15:13] c.fld -> fld rd', imm(rs1')
      when "010"   => -- ins[15:13] c.lw -> lw rd', imm(rs1')
        o_ins <= "00000"& s_ins(5)& s_ins(12 downto 10)& s_ins(6)& "00"& "01"& s_ins(9 downto 7)& "010"& "01"& s_ins(4 downto 2)& "0000111";
    --when "011"   => -- ins[15:13] c.flw -> flw rd', imm(rs1')
    --when "100"   => -- ins[15:13] reserved
    --when "101"   => -- ins[15:13] c.fsd -> fsd rs2', imm(rs1')
      when "110"   => -- ins[15:13] c.sw -> sw rs2', imm(rs1')
        o_ins <= "00000"& s_ins(5)& s_ins(12)& "01"& s_ins(4 downto 2)& "01"& s_ins(9 downto 7)& "010"& s_ins(11 downto 10)& s_ins(6)& "00"& "0100111";
    --when "111"   => -- ins[15:13] c.fsw -> fsw rs2', imm(rs1')
      when others  => -- ins[15:13]
      end case;
    when "01"   => -- ins[1:0] C1
      case s_ins(15 downto 13) is
      when "000"   => -- ins[15:13] c.addi -> addi rd, rd, nzimm
        o_ins <= s_sgn12(31 downto 25)& s_ins(6 downto 2)&  s_ins(11 downto 7)& "000"& s_ins(11 downto 7)& "0010011";
      when "001"      -- c.jal -> jal x1, imm
         | "101"   => -- c.jal -> jal x0, imm
        o_ins <= s_ins(12)& s_ins(8)& s_ins(10 downto 9)& s_ins(6)& s_ins(7)& s_ins(2)& s_ins(11)& s_ins(5 downto 3)& s_sgn12(31 downto 23)& "0000"& not s_ins(15)& "1101111";
      when "010"   => -- c.li -> addi rd, x0, nzimm
        o_ins <= s_sgn12(31 downto 25)& s_ins(6 downto 2)& "00000"& "000"& s_ins(11 downto 7)& "0010011";
      when "011"   => 
        if(s_ins(11 downto 7) = "00010") then -- c.addi16sp -> addi x2, x2, nzimm -- (rd)target = (x2=sp)StackPointer
          o_ins <= s_sgn12(31 downto 29)& s_ins(4 downto 3)& s_ins(5)& s_ins(2)& s_ins(6)& "0000"& "00010"& "000"& "00010"&  "0010011";
        else -- c.lui -> lui rd, imm
          o_ins <= s_sgn12(31 downto 17)& s_ins(6 downto 2)& s_ins(11 downto 7)& "0110111";
        end if;
      when "100"   => -- ins[15:13] 
        case s_ins(11 downto 10) is
        when "00"      -- c.srli -> srli rd, rd, shamt
           | "01"   => -- c.srai -> srai rd, rd, shamt
          o_ins <= "0"& s_ins(10)& "00000"& s_ins(6 downto 2)& "01"& s_ins(9 downto 7)& "101"& "01"& s_ins(9 downto 7)& "0010011";
        when "10"   => -- c.andi -> andi rd, rd, imm
          o_ins <= s_sgn12(31 downto 25)& s_ins(6 downto 2)& "01"& s_ins(9 downto 7)& "111"& "01"& s_ins(9 downto 7)& "0010011";
        when "11"   => -- ins[11:10]
          case s_ins(6 downto 5) is -- assuming ins(12)=0 -> RV32 only support
          when "00"   => -- c.sub -> sub rd', rd', rs2'
            o_ins <= "01"& "00000"& "01"& s_ins(4 downto 2)& "01"& s_ins(9 downto 7)& "000"& "01"& s_ins(9 downto 7)& "0110011";
          when "01"   => -- c.xor -> xor rd', rd', rs2'
--          instr_o = {7'b0, 2'b01, instr_i[4:2], 2'b01, instr_i[9:7], 3'b100, 2'b01, instr_i[9:7], OPCODE_OP};
--          o_ins <= "0000000"& "01"& s_instr_i[4:2], 2'b01, instr_i[9:7], 3'b100, 2'b01, instr_i[9:7], OPCODE_OP};
          when "10"   => -- c.or  -> or  rd', rd', rs2'
--                    instr_o = {7'b0, 2'b01, instr_i[4:2], 2'b01, instr_i[9:7], 3'b110, 2'b01, instr_i[9:7], OPCODE_OP};
--                    instr_o = {7'b0, 2'b01, instr_i[4:2], 2'b01, instr_i[9:7], 3'b110, 2'b01, instr_i[9:7], OPCODE_OP};
          when "11"   => -- c.and -> and rd', rd', rs2'
--                    instr_o = {7'b0, 2'b01, instr_i[4:2], 2'b01, instr_i[9:7], 3'b111, 2'b01, instr_i[9:7], OPCODE_OP};
--                    instr_o = {7'b0, 2'b01, instr_i[4:2], 2'b01, instr_i[9:7], 3'b111, 2'b01, instr_i[9:7], OPCODE_OP};
          --when "100" c.subw | "101" c.addw | "110" | "111" RV64/RV128 only / reserved
          end case; -- ins[6:5]
        end case; -- ins[11:10]
      when "110"    -- c.beqz -> beq rs1', x0, imm
        |  "111" => -- c.bnez -> bne rs1', x0, imm
        o_ins <= s_sgn12(31 downto 28)& s_ins(6 downto 5)& s_ins(2)& "00000"& "01"& s_ins(9 downto 7)& "00"& s_ins(13)& s_ins(11 downto 10)& s_ins(4 downto 3)& s_ins(12)& "1100011";
      when others  => -- ins[15:13]
      end case; -- ins[15:13]

    when "10"   => -- ins[1:0] C2 
      case s_ins(15 downto 13) is
      when "000"   => -- c.slli -> slli rd, rd, shamt
        o_ins <= "0000000"& s_ins(6 downto 2)& s_ins(11 downto 7)& "001"& s_ins(11 downto 7)& "0010011";
    --when "001"   => -- c.fldsp -> fld rd, imm(x2)
      when "010"   => -- c.lwsp -> lw rd, imm(x2)
        o_ins <= "0000"& s_ins(3 downto 2)& s_ins(12)& s_ins(6 downto 4)& "00"& "00010"& "010"& s_ins(11 downto 7)& "0000011";
    --when "011"   => -- c.flwsp -> flw rd, imm(x2)
      when "100"   =>
        if( s_ins(12) = '0') then
          if( s_ins(6 downto 2) = "00000") then -- c.jr -> jalr x0, rd/rs1, 0
            o_ins <= x"000"& s_ins(11 downto 7)& "000"& "00000"& "1100111";
          else                                  -- c.mv -> add rd/rs1, x0, rs2
            o_ins <= "0000000"& s_ins(6 downto 2)& "00000"& "000"& s_ins(11 downto 7)& "0110011";
          end if;
        else -- ins(12)=1
          -- c.add -> add rd, rd, rs2
          o_ins <= "0000000"& s_ins(6 downto 2)& s_ins(11 downto 7)& "000"& s_ins(11 downto 7)& "0110011";
        --if (s_ins(11 downto 7) = "00000") then -- c.ebreak -> ebreak
        --  o_ins <= x"00_10_00_73"; -- this costs ~50 LUT4 with g4
        --els
          if (s_ins(6 downto 2) = "00000") then -- c.jalr -> jalr x1, rs1, 0
            o_ins <= x"000"& s_ins(11 downto 7)& "000"& "00001"& "1100111";
          end if;
        end if;
        end case; -- ins[15:13]

    when others => -- ins[1:0] 11 uncrompressed
--    o_ins <= i_ins;
    end case; -- ins[1:0]
  end process;
  
  o_rvc <= '0' when s_ins(1 downto 0) = "11" else '1';

end rtl;
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- File: rv16c_bench.vhd
--------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity rv16c_bench is port (
  i_clk   : in  std_logic;
  i_rst_n : in  std_logic;
  i_ins   : in  std_logic_vector(31 downto 0);
  o_ins   : out std_logic_vector(31 downto 0);
  o_rvc   : out std_logic );
end rv16c_bench;

architecture rtl of rv16c_bench is

component rv16c is port (
  i_ins   : in  std_logic_vector(31 downto 0);
  o_ins   : out std_logic_vector(31 downto 0);
  o_rvc   : out std_logic );
end component;

	signal s_one, s_two : std_logic_vector(31 downto 0);

begin

rvc_try_p : process(i_clk,i_rst_n)
  begin
    if (i_rst_n = '0') then
      s_one <= (others=>'0'); -- Input
      o_ins <= (others=>'0'); -- Output
    elsif (i_clk'event and i_clk = '1') then
      s_one <= i_ins;
      o_ins <= s_two;
    end if;
  end process;
  
rv16c_0 : rv16c port map(
  i_ins => s_one,
  o_ins => s_two,
  o_rvc => o_rvc );
  
end rtl;

--------------------------------------------------------------------------------
-- # default G4 constrain 100 MHz, reaching 173 MHz, using 125 LUT4
-- #create_clock -name {Clock} -period 10 -waveform {0 5 } [ get_ports { i_clk } ]
-- # over    G4 constrain 200 MHz, reaching 228 MHz, using 163 LUT4
-- create_clock -name {Clock} -period 5 -waveform {0 2.5 } [ get_ports { i_clk } ]
-- # over    G4 constrain 275 MHz, reaching 235 MHz, using 185 LUT4
-- #create_clock -name {Clock} -period 3.63636 -waveform {0 1.81818 } [ get_ports { i_clk } ]
