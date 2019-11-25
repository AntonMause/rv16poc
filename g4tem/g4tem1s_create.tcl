#
# Microsemi Tcl Script for Microsemi Libero SoC
# (c) 2019 by Anton Mause 
#
# Tenz TEM0001 Board for Microsemi M2S010-VFG400
# Board populated with and used as SmartFusion2
#
# tested with ...
#

# 
set BOARD_NAME         rv16tem1s
set NAME_BASE          _base
set NAME_BASE          $BOARD_NAME$NAME_BASE
#
set PROJ_DESCRIPTION   "G4 M2S010 Trenz TEM0001 rv16"
set PATH_DESTINATION   "../../Lib12p2"
set PATH_POOL          "../g4pool"
#
set PATH_SOURCE   [pwd]
set PATH_BASE      $PATH_DESTINATION/$NAME_BASE

# where are we
puts -nonewline "Sources Path  : "
puts $PATH_SOURCE
#
puts -nonewline "Base Path   : "
puts $PATH_BASE
#
puts -nonewline "Pool Path : "
puts $PATH_POOL

# create new base project
new_project -location $PATH_BASE -name $NAME_BASE -project_description $PROJ_DESCRIPTION \
	-block_mode 0 -standalone_peripheral_initialization 0 -use_enhanced_constraint_flow 1 -hdl {VHDL} \
	-family {SmartFusion2} -die {M2S010} -package {400 VF} -speed {STD} -die_voltage {1.2} \
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

# initial source files, HDL and constraints
import_files \
    -convert_EDN_to_HDL 0 \
    -hdl_source {./brdConst_pkg.vhd} \
    -hdl_source $PATH_POOL/brdRstClk.vhd \
    -hdl_source $PATH_POOL/rv16uram.vhd \
    -hdl_source {../vhdl/mySynCnt.vhd}
#
import_files \
    -convert_EDN_to_HDL 0 \
    -io_pdc {./brdBaseIo.pdc} \
    -io_pdc {./brdLedIo.pdc}
#
import_files \
    -convert_EDN_to_HDL 0 \
    -sdc {./brdBaseTim.sdc} 

#import_files \
#    -convert_EDN_to_HDL 0 \
#    -library {work} \
#    -simulation {../test/wave.do} 

source $PATH_POOL/g4myOSC.tcl
source $PATH_POOL/g4myCCC.tcl
source $PATH_POOL/g4my17Madd.tcl

save_project 

# copy project to ZIP archive
project_archive -location $PATH_BASE -name $NAME_BASE -replace_links 1 -files {all} -designer_views {all} 

# finished base project, let's modify it   #########################################################

set NAME_CONCAT .prjx
set NAME_CONCAT $PATH_BASE/$NAME_BASE$NAME_CONCAT

open_project -file $NAME_CONCAT -do_backup_on_convert 0
source ../vhdl/rv16poc_create.tcl

open_project -file $NAME_CONCAT -do_backup_on_convert 0
source ../rv16gpo/g4rv16gpo_create.tcl
save_project 

#if { $::argc > 0 } {
#}
#
# ToDo :
# could not yet TCL this :
# stimulus hierachy -> set as active stimulus
# project -> settings -> waveforms -> enable wave.do
#
