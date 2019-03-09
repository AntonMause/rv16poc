
# rv16poc

 2019 by Anton Mause

## RISC-V RV16 poc Proof of Concept on Actel/Microsemi/Microchip SoC

Design target : Build small 16 bit CPU based on RISC-V RV32I ISA using G4/G5 hardware

###### -1x LSRAM 18k -> 1k x 16 bit (instruction)
###### -1x URAM  1k  -> 64 x 16 bit (register)
###### -1x MACC  17 bit signed (alu)
###### -600 LE (this fits between the components above in g4)

This CPU should act like a RV32I for all values that fit into +/-32k.

#### G4 := (65nm)  SmartFusion2/IGLOO2/RTG4
#### G5 := (28nm)  MPF/Microsemi PolarFire

The current snapshot is intended to use Libero SoC version 12.0 (2019q1)

Unpack ./rv16poc-RevXYZ.zip to your projects directory and name ./rv16poc/ .
Most generic HDL sources can be found in the "./vhdl/" folder.

run : Libero -> Project -> Execute Script -> xyz_create.tcl

Supported features & instructions :

#### Generic : LUI, AUIPC, JAL, JALR, LH, SH,
#### ALU (Immediate & Register) : Add, Sub, Sll, Srl, Xor, Or, And
#### Missing : Sra, Fence, System, Irq, CSR, Slt, Sltu, ...
#### Branch : ???, Bne, Beq, ??? (to be released soon, rework in progress)
#### current implementation has I_Idle cycle, just to be sure there are no side effects between instructions
#### pcu and instruction LSRAM can handle 16 bit wide instructions AND misaligned access

Supported boards & hardware :

#### Avnet SmartFusion2 / Igloo2 KickStart Kit in folder g4kick
#### did some testing on Polarfire too

ToDo / Ideas :

#### remove dummy I_Idle state to speed up CPU
#### add rv16c decoder for compressed support
#### use bit 17..18 (or 1..0) in LSRAM to flag 3 different kinds of breakpoints
#### could use SmartDebug for trigger and memory monitoring
#### use upper 32 uSRAM to store upper 16 bit of data, would become a 2 cycle rv32
#### use upper 32 uSRAM register for second context / hyperthread / Irq / ...
