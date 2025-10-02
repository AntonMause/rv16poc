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
#
#import_files \
#    -convert_EDN_to_HDL 0 \
#    -library {} \
#    -stimulus {../../rv51mt/rv16d_tb.vhd} 

#import_files \
#    -convert_EDN_to_HDL 0 \
#    -sdc {../../rv51mt/g5rv51mt_tim.sdc} 

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

save_project 
build_design_hierarchy 

set_root -module {rv51mt::work} 
organize_tool_files -tool {PLACEROUTE} -input_type {constraint} -module {rv51mt::work} \
	-file $PATH_PROJ/constraint/io/brdBaseIo.pdc \
	-file $PATH_PROJ/constraint/io/brdLedIo.pdc
organize_tool_files -tool {SYNTHESIZE} -input_type {constraint} -module {rv51mt::work} \
    -file $PATH_PROJ/constraint/brdBaseTim.sdc
build_design_hierarchy 
check_sdc_constraints -tool {synthesis} 


#set_root -module {rv16gpo::work} 
#organize_tool_files -tool {SIM_PRESYNTH} -file $PATH_PROJ/stimulus/rv16gpo_tb.vhd \
#	-module {rv16gpo::work} -input_type {stimulus} 
#organize_tool_files -tool {SIM_POSTSYNTH} -file $PATH_PROJ/stimulus/rv16gpo_tb.vhd \
#	-module {rv16gpo::work} -input_type {stimulus} 
#organize_tool_files -tool {SIM_POSTLAYOUT} -file $PATH_PROJ/stimulus/rv16gpo_tb.vhd \
#	-module {rv16gpo::work} -input_type {stimulus} 

#check_sdc_constraints -tool {synthesis} 
#build_design_hierarchy 

set_root -module {rv51mt::work} 
save_project 
