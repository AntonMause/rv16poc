
# rv16poc

 2019 by Anton Mause

## rv16poc RISC-V Proof of Concept on Actel/Microsemi/Microchip SoC

Design target : Build small 16 bit CPU based on RISC-V RV32I ISA using on chip hardware resources.

This CPU should act like a RV32I for all values that fit into +/-32k.

Resource oriented design, wrapped around one Multiply-Adder-Subtractor-Unit MACC.

See signal flow in diagram attached.

The MACC provides P=C+/-B*A as a hard macro and some of these are spread all over the FPGA.

Thought it could be clever to use this resource instead of generating a ALU from logic gates.

My rv16poc routes the data and configures the MACC to make use of it.

It started with straight forward signal flow ;-), but it got broken a bit later in the design cycle :-( .

The rv16 concept maps best on G4, G5 needs different layout, so I will focus on G4 in this branch.

#### Resource utilisation :

###### -1x LSRAM 18k  -> 1k x 16 bit (instruction)
###### -1x g4 URAM 1k -> 64 x 16 bit (register) g5=4x
###### -1x MACC  17 bit signed (alu)
###### -600 LE  (this is what you find around each MACC)

The current snapshot is intended to use Libero SoC version 12.1 (2019q2)

Unpack ./rv16poc-RevXYZ.zip to your projects directory and name ./rv16poc/ .
Most generic HDL sources can be found in the "./vhdl/" folder.

run : Libero -> Project -> Execute Script -> xyz_create.tcl

Supported features & instructions :

#### Generic : LUI, AUIPC, JAL, JALR, LH, SH,
#### ALU (Immediate & Register) : Add, Sub, Sll, Srl, Sra, Slt, Xor, Or, And
#### Branch : Bne, Beq, BLE, ...
#### Missing : Fence, System, Irq, CSR, ...
#### current implementation has I_Idle cycle, just to be sure there are no side effects between instructions
#### pcu and instruction LSRAM can handle 16 bit wide instructions AND misaligned access

Supported FPGA families / boards & hardware :

#### G4 := (65nm)  SmartFusion2/IGLOO2/RTG4
#### G5 := (28nm)  MPF/Microsemi PolarFire  (not supported in master tree, check out older branch early 2019)

#### IMG SmartFusion2 Development Board in folder g4img
#### Avnet SmartFusion2 / Igloo2 KickStart Kit in folder g4kick
#### Trenz SmartFusion2 SFM2000 / TEM1 in folder g4tem

#### (Microsemi Polarfire Splash Kit in folder g5splash) (not supported now)

Activate the project you want via "Set as Root":
#### rv16poc to run simulation
#### rv16soc to programm the target board

Change this to use SmartDebug:
Click "Project->Project Settings ..." -> "Design Flow"
Set "Synthesis gate level netlist format" to "Verilog netlist"
This will allow you to enable "Hardware Breakpont Auto Instantiation"
Rebuid project, "Run Programm Action", start "SmartDebugDesign".
Select "Debug FPGA Array" -> "Hierarchical View", search for "s_pcu_bra".
Add signal to "Live Probes" list and "Assign to Channel A".
Select "Actives Probe" and "Load..." ".\test\active_probes_saved_break.txt".
You can now press "Read Active Probes" and see rv16 running "s_pcu_pc0".
This reading while running may crash the application in the FPGA.
Better use "Arm Trigger" to halt rv16 at breakpoint.
Use "Pause", "Run", "Step", to control the FPGA.


ToDo / Ideas :

#### remove dummy I_Idle state to speed up CPU
#### add rv16c decoder for compressed support
#### use bit 17..18 (or 1..0) in LSRAM to flag 3 different kinds of breakpoints
#### could use SmartDebug for trigger and memory monitoring
#### use upper 32 uSRAM cells to store upper 16 bit of data, would become a 2 cycle rv32
#### use upper 32 uSRAM register for second context / hyperthread / Irq / ...
#### use x0 to temporally store current PC, for example for context change or break points
