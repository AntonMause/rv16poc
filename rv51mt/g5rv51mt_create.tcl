# !! called from g5-some-board.tcl, do not call this file alone !!

# file: g5rv51mt_create.tcl   (c) 2025 by Anton Mause
# finished base project, let's modify it   #########################################################

set NAME_PROJ      _rv51mt
set NAME_PROJ      $BOARD_NAME$NAME_PROJ
set PATH_PROJ      $PATH_DESTINATION/$NAME_PROJ
puts -nonewline "Proj Path : "
puts $PATH_PROJ

save_project_as -location $PATH_PROJ -name $NAME_PROJ -replace_links 1 -files {all} -designer_views {all} 

import_files \
    -convert_EDN_to_HDL 0 \
    -hdl_source {../../rv51mt/rv51mt.vhd} \
    -hdl_source {../../rv51mt/rv51pkg.vhd} \
    -hdl_source {../../rv51mt/rv16alu.vhd} \
    -hdl_source {../../rv51mt/rv16bra.vhd} \
    -hdl_source {../../rv51mt/rv16dec.vhd} \
    -hdl_source {../../rv51mt/rv16pcx.vhd} \
    -hdl_source {../../rv51mt/rv16one.vhd} \
    -hdl_source {../../rv51mt/rv16mux.vhd} \
    -hdl_source {../../rv51mt/rv16dra.vhd} \
    -hdl_source {../../rv51mt/rv16dwa.vhd} \
    -hdl_source {../../rv51mt/rv16imm.vhd} \
    -hdl_source {../../rv51mt/rv16rom.vhd} \
    -hdl_source {../../rv51mt/rv16pkg.vhd} 

import_files \
    -convert_EDN_to_HDL 0 \
    -library {} \
    -stimulus {../../rv51mt/rv51mt_tb.vhd} 
file copy ../../rv51mt/wave.do   $PATH_PROJ/simulation

import_files \
    -convert_EDN_to_HDL 0 \
    -sdc {../../rv51mt/g5rv51mt_tim.sdc} \
    -sdc {../../rv51mt/g5rv51mt_chk.sdc} 

file mkdir $PATH_PROJ/software
file copy ../../rv51mt/rv16rom_head.vhd   $PATH_PROJ/software
file copy ../../rv51mt/rv16rom_tail.vhd   $PATH_PROJ/software
file copy ../../rv51mt/rv16rom.S          $PATH_PROJ/software
file copy ../../rv51mt/mkrv16rom.tcl      $PATH_PROJ/software
file copy ../../rv51mt/encoding.h         $PATH_PROJ/software
file copy ../../rv51mt/microsemi-riscv-ram.ld     $PATH_PROJ/software
file copy ../../scripts/rv64config.tcl     $PATH_PROJ/software

cd $PATH_PROJ/software/
source mkrv16rom.tcl
cd $PATH_SOURCE

file copy ../../rv51mt/PF_SRAM_DAT.tcl   $PATH_PROJ/smartgen
file copy ../../rv51mt/PF_SRAM_INS.tcl   $PATH_PROJ/smartgen
file copy ../../rv51mt/PF_URAM_PCU0.tcl   $PATH_PROJ/smartgen

cd $PATH_PROJ/smartgen/
source PF_SRAM_DAT.tcl
source PF_SRAM_INS.tcl
source PF_URAM_PCU0.tcl
configure_core -component_name {PF_URAM_PCU0} -params {"BLK_PN:BLK_EN" "BLK_POLARITY:2" "BUSY_FLAG:0" "CASCADE:0" "CLKS:2" "CLOCK_PN:CLK" "IMPORT_FILE:INIT_FROM_CONTENT_EDITOR" "INIT_RAM:T" "LPMTYPE:LPM_URAM" "RDEPTH:32" "RESET_POLARITY:2" "RWIDTH:32" "R_ADDR_ARST_PN:R_ADDR_ARST_N" "R_ADDR_ARST_POLARITY:2" "R_ADDR_EN_PN:R_ADDR_EN" "R_ADDR_EN_POLARITY:2" "R_ADDR_LAT:1" "R_ADDR_PN:R_ADDR" "R_ADDR_SRST_PN:R_ADDR_SRST_N" "R_ADDR_SRST_POLARITY:2" "R_CLK_EDGE:RISE" "R_CLK_PN:R_CLK" "R_DATA_ARST_PN:R_DATA_ARST_N" "R_DATA_ARST_POLARITY:2" "R_DATA_EN_PN:R_DATA_EN" "R_DATA_EN_POLARITY:2" "R_DATA_LAT:1" "R_DATA_PN:R_DATA" "R_DATA_SRST_PN:R_DATA_SRST_N" "R_DATA_SRST_POLARITY:2" "SII_LOCK:0" "WDEPTH:32" "WWIDTH:32" "W_ADDR_PN:W_ADDR" "W_CLK_EDGE:RISE" "W_CLK_PN:W_CLK" "W_DATA_PN:W_DATA" "W_EN_PN:W_EN" "W_EN_POLARITY:1"} 
configure_core -component_name {PF_SRAM_INS} -params {"A_DOUT_EN_PN:R_DATA_EN" "A_DOUT_EN_POLARITY:2" "A_DOUT_SRST_PN:R_DATA_SRST_N" "A_DOUT_SRST_POLARITY:2" "A_WBYTE_EN_PN:WBYTE_EN" "BUSY_FLAG:0" "BYTEENABLES:0" "BYTE_ENABLE_WIDTH:7" "CASCADE:0" "CLKS:2" "CLK_EDGE:RISE" "CLOCK_PN:CLK" "DATA_IN_PN:W_DATA" "DATA_OUT_PN:R_DATA" "ECC:0" "IMPORT_FILE:./software/rv16rom.hex" "INIT_RAM:T" "LPMTYPE:LPM_RAM" "LPM_HINT:0" "PMODE2:0" "PTYPE:1" "RADDRESS_PN:R_ADDR" "RCLK_EDGE:RISE" "RCLOCK_PN:R_CLK" "RDEPTH:8192" "RESET_PN:R_DATA_ARST_N" "RESET_POLARITY:2" "RE_PN:R_EN" "RE_POLARITY:1" "RWIDTH:32" "SII_LOCK:0" "WADDRESS_PN:W_ADDR" "WCLK_EDGE:RISE" "WCLOCK_PN:W_CLK" "WDEPTH:8192" "WE_PN:W_EN" "WE_POLARITY:1" "WWIDTH:32"} 
configure_core -component_name {PF_SRAM_DAT} -params {"A_DOUT_EN_PN:R_DATA_EN" "A_DOUT_EN_POLARITY:2" "A_DOUT_SRST_PN:R_DATA_SRST_N" "A_DOUT_SRST_POLARITY:2" "A_WBYTE_EN_PN:WBYTE_EN" "BUSY_FLAG:0" "BYTEENABLES:1" "BYTE_ENABLE_WIDTH:16" "CASCADE:0" "CLKS:2" "CLK_EDGE:RISE" "CLOCK_PN:CLK" "DATA_IN_PN:W_DATA" "DATA_OUT_PN:R_DATA" "ECC:0" "IMPORT_FILE:" "INIT_RAM:T" "LPMTYPE:LPM_RAM" "LPM_HINT:0" "PMODE2:0" "PTYPE:1" "RADDRESS_PN:R_ADDR" "RCLK_EDGE:RISE" "RCLOCK_PN:R_CLK" "RDEPTH:8192" "RESET_PN:R_DATA_ARST_N" "RESET_POLARITY:2" "RE_PN:R_EN" "RE_POLARITY:2" "RWIDTH:32" "SII_LOCK:0" "WADDRESS_PN:W_ADDR" "WCLK_EDGE:RISE" "WCLOCK_PN:W_CLK" "WDEPTH:8192" "WE_PN:W_EN" "WE_POLARITY:1" "WWIDTH:32"} 
cd $PATH_SOURCE

save_project 
build_design_hierarchy 

set_root -module {rv51mt::work} 
organize_tool_files -tool {SYNTHESIZE} -input_type {constraint} -module {rv51mt::work} \
    -file $PATH_PROJ/constraint/g5rv51mt_tim.sdc
organize_tool_files -tool {PLACEROUTE} -input_type {constraint} -module {rv51mt::work} \
    -file $PATH_PROJ/constraint/g5rv51mt_tim.sdc
#	-file $PATH_PROJ/constraint/io/brdBaseIo.pdc \
#	-file $PATH_PROJ/constraint/io/brdLedIo.pdc 
organize_tool_files -tool {VERIFYTIMING}  -input_type {constraint}  -module {rv51mt::work} \
    -file $PATH_PROJ/constraint/g5rv51mt_chk.sdc
build_design_hierarchy 
check_sdc_constraints -tool {synthesis} 


set_root -module {rv51mt::work} 
organize_tool_files -tool {SIM_PRESYNTH} -file $PATH_PROJ/stimulus/rv51mt_tb.vhd -module {rv51mt::work} -input_type {stimulus} 
organize_tool_files -tool {SIM_POSTSYNTH} -file $PATH_PROJ/stimulus/rv51mt_tb.vhd -module {rv51mt::work} -input_type {stimulus} 
organize_tool_files -tool {SIM_POSTLAYOUT} -file $PATH_PROJ/stimulus/rv51mt_tb.vhd -module {rv51mt::work} -input_type {stimulus} 

#check_sdc_constraints -tool {synthesis} 
#build_design_hierarchy 

set_root -module {rv51mt::work} 
save_project 
