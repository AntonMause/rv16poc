
# rv16poc / rv16gpo

2019-2021 by Anton Mause

### RISC-V Proof of Concept on Actel/Microsemi/Microchip SoC

Design target : Build small 16 bit CPU based on RISC-V RV32I ISA using on chip hardware resources.

This family of CPUs should act like a RV32I for all values that fit into +/-32k.

- rv16poc : initial proof of concept, all in one single file.
- rv16gpo : modular version using gcc/as/ld/tcl for boot rom.

Resource oriented design, wrapped around one Multiply-Adder-Subtractor-Unit MACC.
RV16gpo starts as small as 172 LUT4 with simple blinky running (PLEN=XLEN=6,CLK=OSC).

See signal flow in diagram attached.

The MACC provides P=C+/-B*A as a hard macro and some of these are spread all over the FPGA.

Thought it could be clever to use this resource instead of generating a ALU from logic gates.

This rv16poc routes the data and configures the MACC to make use of it.

The rv16 concept maps best on G4, G5 needs different register memory layout, so it is a bit less efficient.

#### Resource utilisation :
- 1x LSRAM 18k  -> 1k x 16 bit (optional used for instruction)
- 1x URAM 1k -> 64 x 16 bit (register)(g4 optimized)
- 1x MACC  17 bit signed (alu)
- 600 LE  (this is what you find around each MACC)

The current snapshot is intended to use Libero SoC version 2021.2 (2021q3)
 
### >Done:  G4, code runs on 2021.2 too, first steps towards Linux support
### >ToDo:  G5, fix issue with Library Element

Edit ./scripts/g..config.tcl if you use older Libero, or even checkout older repo.

Unpack ./rv16poc-RevXYZ.zip to your projects directory and name ./rv16poc/ .

run : Libero -> Project -> Execute Script -> xyz_create.tcl

#### Supported features & instructions :

- Generic : Lui, Auipc, Jal, Jalr, Lh, S,
- ALU (Immediate & Register) : Add, Sub, Sll, Srl, Sra, Slt, Sltu, Xor, Or, And
- Branch : Bne, Beq, BLE, ...
- Missing : Fence, System, Irq, CSR, ...
- current implementation has I_Idle cycle, just to be sure there are no side effects between instructions

Beside the well known CISC and RISC processor class, there is one named MISC, for "minimalistic instruction set computer". By definition these can have up to 32 instructions, the bare rv16 supports up to 33 instructions. Instructions not used get optimized away by the synthesis tool. So it should be OK to put this CPU into the light weight MISC class. 

No interrupt, status or control register support or at all, rv16 is intended to fill the gap between a hand coded state machine and a real CPU. The current design uses way more LUT elements than register and an extra dummy idle slot. It should be possible to drop to 2/3 cycle, investing a bit more register than now, maybe even enable pipelining.

The rv16gpo version uses a hand optimized opcode pre-decoder (Thanx to Karnaugh), so only 2 to 3 bits from the 7 bit wide opcode are used. This saves a lot LUT elements, but will never detect unexpected instructions and obviously fail silently.


#### Activate the project you want via "Set as Root":
- rv16poc: to run simulation
- rv16soc: to program the target board

#### Change this to use SmartDebug in rv16poc:
- Click "Project->Project Settings ..." -> "Design Flow"
- Set "Synthesis gate level netlist format" to "Verilog netlist"
- This will allow you to enable "Hardware Breakpont Auto Instantiation"
- Rebuid project, "Run Program Action", start "SmartDebugDesign".
- Select "Debug FPGA Array" -> "Hierarchical View", search for "s_pcu_bra".
- Add signal to "Live Probes" list and "Assign to Channel A".
- Select "Actives Probe" and "Load..." ".\test\active_probes_saved_break.txt".
- You can now press "Read Active Probes" and see rv16 running "s_pcu_pc0".
- This reading while running may crash the application in the FPGA.
- Better use "Arm Trigger" to halt rv16 at breakpoint.
- Use "Pause", "Run", "Step", to control the FPGA.


#### ToDo / Ideas :
- remove dummy I_Idle state to speed up CPU
- add rv16c decoder for compressed support
- use bit 17..18 (or 1..0) in LSRAM to flag 3 different kinds of breakpoints
- could use SmartDebug for trigger and memory monitoring
- use upper 32 uSRAM cells to store upper 16 bit of data, would become a 2 cycle rv32
- use upper 32 uSRAM register for second context / hyperthread / Irq / ...
- use x0 to temporally store current PC, for example for context change or break points
