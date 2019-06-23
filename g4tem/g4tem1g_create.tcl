#
# Microsemi Tcl Script for Microsemi Libero SoC
# (c) 2019 by Anton Mause 
#
# Tenz TEM0001 Board for Microsemi M2S010-VFG400
# Board populated with SmartFusion2 but used as IGLOO2.
#
# tested with ...
#

# 
set NAME_LINKED        rv16tem1g_lnk
set NAME_SOURCED       rv16tem1g_src
set PROJ_DESCRIPTION   "G4 M2GL010 Trenz TEM0001 rv16"
set PATH_DESTINATION   "../../Lib12p1"
set PATH_POOL          "../g4pool"
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
	-block_mode 0 -standalone_peripheral_initialization 0 -use_enhanced_constraint_flow 1 -hdl {VHDL} \
	-family {IGLOO2} -die {M2GL010} -package {400 VF} -speed {STD} -die_voltage {1.2} \
	-part_range {COM} -adv_options {DSW_VCCA_VOLTAGE_RAMP_RATE:100_MS} \
	-adv_options {IO_DEFT_STD:LVCMOS 3.3V} -adv_options {PLL_SUPPLY:PLL_SUPPLY_25} \
	-adv_options {RESTRICTPROBEPINS:1} -adv_options {RESTRICTSPIPINS:0} \
	-adv_options {SYSTEM_CONTROLLER_SUSPEND_MODE:0} -adv_options {TEMPR:COM} \
	-adv_options {VCCI_1.2_VOLTR:COM} -adv_options {VCCI_1.5_VOLTR:COM} \
	-adv_options {VCCI_1.8_VOLTR:COM} -adv_options {VCCI_2.5_VOLTR:COM} \
	-adv_options {VCCI_3.3_VOLTR:COM} -adv_options {VOLTR:COM} 

# WhatchOut : Use "AbortFlowOnPdc=0" only for demonstration & debugging.
project_settings -hdl {VHDL} -auto_update_modelsim_ini 1 -auto_update_viewdraw_ini 1 -enable_viewdraw 0 \
	-standalone_peripheral_initialization 0 -auto_generate_synth_hdl 0 -auto_generate_physynth_hdl 0 \
	-auto_run_drc 0 -auto_generate_viewdraw_hdl 1 -auto_file_detection 1 -sim_flow_mode 0 -vm_netlist_flow 0 \
	-enable_set_mitigation 0 -display_fanout_limit {10} -abort_flow_on_sdc_errors 1 -abort_flow_on_pdc_errors 0 

# initialy link to source files, HDL and constraints
create_links \
    -convert_EDN_to_HDL 0 \
    -hdl_source {./brdConst_pkg.vhd} \
    -hdl_source $PATH_POOL/brdRstClk.vhd \
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

source $PATH_POOL/g4myOSC.tcl
source $PATH_POOL/g4myCCC.tcl
source $PATH_POOL/g4my17Madd.tcl

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
organize_tool_files -tool {SIM_POSTLAYOUT} -file {../test/rv16poc_tb.vhd} \
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
