#
# Microsemi Tcl Script for Microsemi Libero SoC
# (c) 2021 by Anton Mause 
#

# point to RISC-V compiler executable

# ... on Windows
#set CC_PATH   "C:\\Microsemi\\SoftConsole-v2021.3\\riscv-unknown-elf-gcc\\bin\\"
set CC_PATH   "C:\\Microchip\\SoftConsole-v2022.2-RISC-V-747\\riscv-unknown-elf-gcc\\bin\\"
set CC_POSTFIX  ".exe"

# ... on Linux
#set CC_PATH    "/opt/microsemi/SoftConsole-v2021.1/riscv-unknown-elf-gcc/bin/"
#set CC_POSTFIX ""

# Generic Part (both OS)
set CC_PREFIX  "riscv64-unknown-elf-"
set CC_ARGS    "-march=rv32i -mabi=ilp32"
#