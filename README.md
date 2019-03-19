
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

No, I will not rewrite this core from scratch, it is just a POC as the name states.


#### Resource utilisation :

###### -1x LSRAM 18k  -> 1k x 16 bit (instruction)
###### -1x g4 URAM 1k -> 64 x 16 bit (register) g5=4x
###### -1x MACC  17 bit signed (alu)
###### -600 LE  (this is what you find around each MACC)

The current snapshot is intended to use Libero SoC version 12.0 (2019q1)

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

Supported FPGA famlies / boards & hardware :

#### G4 := (65nm)  SmartFusion2/IGLOO2/RTG4
#### G5 := (28nm)  MPF/Microsemi PolarFire

#### Avnet SmartFusion2 / Igloo2 KickStart Kit in folder g4kick
#### Microsemi Polarfire Splash Kit in folder g5splash (not up to date for debug/break)

ToDo / Ideas :

#### remove dummy I_Idle state to speed up CPU
#### add rv16c decoder for compressed support
#### use bit 17..18 (or 1..0) in LSRAM to flag 3 different kinds of breakpoints
#### could use SmartDebug for trigger and memory monitoring
#### use upper 32 uSRAM cells to store upper 16 bit of data, would become a 2 cycle rv32
#### use upper 32 uSRAM register for second context / hyperthread / Irq / ...
#### use x0 to temporally store current PC, for example for context change or break points
