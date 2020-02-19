
# ########################################################################
# file: g4rv16gpo_create.tcl   (c) 2019 by Anton Mause
# finished base project, let's modify it   ###############################

set NAME_PROJ      _rv16gpo
set NAME_PROJ      $BOARD_NAME$NAME_PROJ
set PATH_PROJ      $PATH_DESTINATION/$NAME_PROJ
puts -nonewline "Proj Path : "
puts $PATH_PROJ

save_project_as -location $PATH_PROJ -name $NAME_PROJ -replace_links 1 -files {all} -designer_views {all} 

import_files \
    -convert_EDN_to_HDL 0 \
    -hdl_source {../rv16gpo/rv16gpo.vhd} \
    -hdl_source {../rv16gpo/rv16rom.vhd} \
    -hdl_source {../rv16gpo/rv16soc.vhd} 
#
import_files \
    -convert_EDN_to_HDL 0 \
    -library {} \
    -stimulus {../rv16gpo/rv16gpo_tb.vhd} 

#import_files \
#    -convert_EDN_to_HDL 0 \
#    -sdc {../rv16gpo/g4rv16_tim.sdc} 

file mkdir $PATH_PROJ/software
file copy ../rv16gpo/rv16rom_head.vhd   $PATH_PROJ/software
file copy ../rv16gpo/rv16rom_tail.vhd   $PATH_PROJ/software
file copy ../rv16gpo/rv16rom.S          $PATH_PROJ/software
file copy ../rv16gpo/mkrv16rom.tcl      $PATH_PROJ/software
file copy ../rv16gpo/encoding.h         $PATH_PROJ/software
file copy ../rv16gpo/microsemi-riscv-ram.ld     $PATH_PROJ/software
file copy ../scripts/rv64config.tcl     $PATH_PROJ/software

cd $PATH_PROJ/software/
source mkrv16rom.tcl
cd $PATH_SOURCE

save_project 
build_design_hierarchy 

set_root -module {rv16soc::work} 
organize_tool_files -tool {PLACEROUTE} -input_type {constraint} -module {rv16soc::work} \
	-file $PATH_PROJ/constraint/io/brdBaseIo.pdc \
	-file $PATH_PROJ/constraint/io/brdLedIo.pdc
organize_tool_files -tool {SYNTHESIZE} -input_type {constraint} -module {rv16soc::work} \
    -file $PATH_PROJ/constraint/brdBaseTim.sdc

set_root -module {rv16gpo::work} 
organize_tool_files -tool {SIM_PRESYNTH} -file $PATH_PROJ/stimulus/rv16gpo_tb.vhd \
	-module {rv16gpo::work} -input_type {stimulus} 
organize_tool_files -tool {SIM_POSTSYNTH} -file $PATH_PROJ/stimulus/rv16gpo_tb.vhd \
	-module {rv16gpo::work} -input_type {stimulus} 
organize_tool_files -tool {SIM_POSTLAYOUT} -file $PATH_PROJ/stimulus/rv16gpo_tb.vhd \
	-module {rv16gpo::work} -input_type {stimulus} 

#organize_tool_files -tool {SYNTHESIZE} -input_type {constraint} -module {rv16gpo::work} \
#	-file $PATH_PROJ/constraint/g4rv16_tim.sdc}
check_sdc_constraints -tool {synthesis} 
build_design_hierarchy 

set_root -module {rv16soc::work} 
save_project 
