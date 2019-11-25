
# ########################################################################
# file: mkrv16rom.tcl   (c) 2019 by Anton Mause
#
set PATH "C:\\Microsemi\\SoftConsole_v6.1\\riscv-unknown-elf-gcc\\bin\\"
set PREFIX "riscv64-unknown-elf-"
set CC ${PATH}${PREFIX}gcc.exe
set OC ${PATH}${PREFIX}objcopy.exe
set OD ${PATH}${PREFIX}objdump.exe

puts $CC
file delete rv16rom.o rv16rom.elf rv16rom.bin rv16rom.lst rv16rom.vhd
exec $CC -march=rv32i -mabi=ilp32 -c -o rv16rom.o rv16rom.S
exec $CC -march=rv32i -mabi=ilp32 -T microsemi-riscv-ram.ld -nostartfiles -o rv16rom.elf rv16rom.o
# exec $OC -O ihex rv16rom.elf rv16rom.hex
exec $OC -O binary rv16rom.elf rv16rom.bin
# exec $OC -O verilog rv16rom.elf rv16rom.v
exec $OD -D rv16rom.elf >rv16rom.lst

# ########################################################################
# convert binary file to initialise vhdl memory block

# WatchOut: 
# This script assumes file size to be multiples of 4 (or fails)

# copy header into target
set outfile [open "../hdl/rv16rom.vhd" w]
set head [open "rv16rom_head.vhd" r]
fcopy $head $outfile
close $head

# generate body
set infile [open "rv16rom.bin" r]

fconfigure $infile \
    -translation binary \
    -encoding binary \
    -buffering full -buffersize 16384

while { 1 } {

	# Read 4 bytes from the file.
	set s1 [read $infile 1]
	set s2 [read $infile 1]
	set s3 [read $infile 1]
	set s4 [read $infile 1]

    # Stop if we've reached end of file
	if { [string length $s4] == 0 } {
        break
    }

    # Convert the data to hex.
    binary scan $s1 H*@0a* hex1 ascii
    binary scan $s2 H*@0a* hex2 ascii
    binary scan $s3 H*@0a* hex3 ascii
    binary scan $s4 H*@0a* hex4 ascii

    # Put the hex data to the channel
    puts $outfile [format {    x"%-2s%-2s", x"%-2s%-2s", -- 0x%-2s%-2s%-2s%-2s} \
		$hex2 $hex1 $hex4 $hex3   $hex4 $hex3 $hex2 $hex1]
}
close $infile

# copy tail into target
set tail [open "rv16rom_tail.vhd" r]
fcopy $tail $outfile
close $tail

close $outfile

# source ./script.tcl  << how to call script
#     x"0101", x"2323", x"3434", x"5454", 
