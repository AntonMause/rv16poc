
# rv51mt

2019-2025 by Anton Mause

### RISC-V 6 stage multithreaded CPU on Actel/Microsemi/Microchip SoC

Design target : Build 32 bit CPU based on RISC-V RV32I ISA running high clock rate.

stage 0: schedule the next thread to run, so far taken from static table

stage 1: get programm pointer for next thread to run

stage 2: fetch instruction for current thread

stage 3: decode instruction and select rs1 & rs2

stage 4: execute most alu instructions

stage 5: byte swap and write

#### Resource utilisation :
-  32x LSRAM 18k -> for fast instruction and data local memory
-   8x URAM  1k  -> for multiple register banks
-   0x MACC      -> only LUT based ALU so far
- 2082 LE        -> no IO yet

The current snapshot is intended to use Libero SoC version 2025.1
 
Unpack ./rv16poc-RevXYZ.zip to your projects directory and name ./rv16poc/ .

Edit ./scripts/g..config.tcl if you use older Libero, or even checkout older repo.
Adjust your installation path of Libero and SoftConsole C: vs D: and so

run : Libero -> Project -> Execute Script -> boards/g5pool/g5block0_create.tcl


No interrupt, status or control register support or at all.

