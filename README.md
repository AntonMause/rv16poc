
# rv16poc

 2019 by Anton Mause

## RISC-V RV16 poc Proof of Concept on Actel/Microsemi/Microchip SoC

Design target : Build 16 bit CPU based on RISC-V RV32I ISA using G4/G5 hardware

## -1x LSRAM 18k -> 1k x 16 bit (instruction)
## -1x URAM  1k  -> 64 x 16 bit (register)
## -1x MACC  17 bit signed (alu)
## -600 LE (this fits between the components above in g4)

#### G4 := (65nm)  SmartFusion2/IGLOO2/RTG4
#### G5 := (28nm)  MPF/Microsemi PolarFire

The current snapshot is intended to use Libero SoC version 12.0 (2019q1)

Unpack ./rv16poc-RevXYZ.zip to your projects directory and name ./rv16poc/ .
Most generic HDL sources can be found in the "./vhdl/" folder.



