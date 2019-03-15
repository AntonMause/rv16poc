#
# Microsemi Tcl Script for libero SoC
# (c) 2016 by Anton Mause 
#
# Microsemi Splash Kit for Microsemi MPF300TS-484ES (2018)
#
# tested with board Rev ??????
#

#
set NAME_LINKED        rv16splash3tse_lnk
set NAME_SOURCED       rv16splash3tse_src
set PROJ_DESCRIPTION   "G5 MPF300 TS ES Microsemi Splash Kit rv16"
set PATH_DESTINATION   "../../Lib12p0"
set PATH_POOL          "../g5pool"
# 

set PATH_SOURCES   .
set PATH_LINKED    $PATH_DESTINATION/$NAME_LINKED
set PATH_IMPORTED  $PATH_DESTINATION/$NAME_SOURCED

# where are we
puts -nonewline "Sources Path  : "
puts $PATH_SOURCES
#
puts -nonewline "Linked Path   : "
puts $PATH_LINKED
#
puts -nonewline "Imported Path : "
puts $PATH_IMPORTED
#
puts -nonewline "Pool Path : "
puts $PATH_POOL
#
puts -nonewline "Current Path  : "
puts [pwd]

# create new project
new_project -location $PATH_LINKED -name $NAME_LINKED -project_description $PROJ_DESCRIPTION \
	-block_mode 0 -standalone_peripheral_initialization 0 -instantiate_in_smartdesign 1 \
	-ondemand_build_dh 1 -use_enhanced_constraint_flow 1 -hdl {VHDL} \
	-family {PolarFire} -die {MPF300TS_ES} -package {FCG484} -speed {-1} \
	-die_voltage {1.0} -part_range {EXT} -adv_options {IO_DEFT_STD:LVCMOS 1.8V} \
	-adv_options {RESTRICTPROBEPINS:1} -adv_options {RESTRICTSPIPINS:0} \
	-adv_options {SYSTEM_CONTROLLER_SUSPEND_MODE:0} -adv_options {TEMPR:IND} \
	-adv_options {VCCI_1.2_VOLTR:EXT} -adv_options {VCCI_1.5_VOLTR:EXT} \
	-adv_options {VCCI_1.8_VOLTR:EXT} -adv_options {VCCI_2.5_VOLTR:EXT} \
	-adv_options {VCCI_3.3_VOLTR:EXT} -adv_options {VOLTR:IND} 

set_device -family {PolarFire} -die {MPF300TS_ES} -package {FCG484} -speed {-1} \
    -die_voltage {1.05} -part_range {EXT} -adv_options {IO_DEFT_STD:LVCMOS 1.8V} \
	-adv_options {RESTRICTPROBEPINS:1} -adv_options {RESTRICTSPIPINS:0} \
	-adv_options {SYSTEM_CONTROLLER_SUSPEND_MODE:0} -adv_options {TEMPR:IND} \
	-adv_options {VCCI_1.2_VOLTR:EXT} -adv_options {VCCI_1.5_VOLTR:EXT} \
	-adv_options {VCCI_1.8_VOLTR:EXT} -adv_options {VCCI_2.5_VOLTR:EXT} \
	-adv_options {VCCI_3.3_VOLTR:EXT} -adv_options {VOLTR:IND} 

# initialy link to source files, HDL and constraints
create_links \
    -convert_EDN_to_HDL 0 \
    -hdl_source {./brdConst_pkg.vhd} \
    -hdl_source {../vhdl/brdRstClk.vhd} \
    -hdl_source {../vhdl/mySynCnt.vhd} \
    -hdl_source {../vhdl/rv16poc.vhd} \
    -hdl_source {../vhdl/rv16soc.vhd} 
#
create_links \
    -convert_EDN_to_HDL 0 \
    -io_pdc {./brdBaseIo.pdc} \
    -io_pdc {./brdLedIo.pdc}
#
create_links \
    -convert_EDN_to_HDL 0 \
    -sdc {./brdBaseTim.sdc} 

create_links \
    -convert_EDN_to_HDL 0 \
    -library {} \
    -stimulus {../test/rv16poc_tb.vhd} 

import_files \
    -convert_EDN_to_HDL 0 \
    -library {work} \
    -simulation {../test/wave.do} 

# import !failes! so we take generated vhd
#import_component -file {./my17Madd.cxf} 

build_design_hierarchy 
set_root -module {rv16soc::work} 
organize_tool_files -tool {PLACEROUTE} -input_type {constraint} -module {rv16soc::work} \
	-file {./brdBaseIo.pdc} \
	-file {./brdLedIo.pdc}
organize_tool_files -tool {SYNTHESIZE} -input_type {constraint} -module {rv16soc::work} \
    -file {./brdBaseTim.sdc} 

set_root -module {rv16poc::work} 
organize_tool_files -tool {SIM_PRESYNTH} -file {../test/rv16poc_tb.vhd} \
	-module {rv16poc::work} -input_type {stimulus} 
organize_tool_files -tool {SIM_POSTSYNTH} -file {../test/rv16poc_tb.vhd} \
	-module {rv16poc::work} -input_type {stimulus} 

#run_tool -name {SIM_PRESYNTH} 

set_root -module {rv16soc::work} 
save_project 
# close_project -save 1 

# save/make copy of project changing from "linked files" to "imported files"
save_project_as -location $PATH_IMPORTED -name $NAME_SOURCED -replace_links 1 -files {all} -designer_views {all} 
save_project 

# copy project to ZIP archive
project_archive -location $PATH_LINKED -name $NAME_SOURCED -replace_links 1 -files {all} -designer_views {all} 
save_project 

# show current/process working directory
puts -nonewline "Current Path  : "
puts [pwd]

#if { $::argc > 0 } {
#}
#
set_root -module {rv16poc::work} 
#
# ToDo :
# could not yet TCL this :
# stimulus hierachy -> set as active stimulus
# project -> settings -> waveforms -> enable wave.do
#
