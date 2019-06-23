#
# Microsemi Tcl Script for libero SoC
# (c) 2016 by Anton Mause 
#
# IMG Nordhausen Development Kit for Microsemi M2S025T-FGG484 (2014)
# Board populated with and used as SmartFusion2 with Transceiver.
#
# tested with, ...
#

# 
set PATH_SOURCES   .
set PATH_LINKED    ../../11p9/g4img2s_lnk
set PATH_IMPORTED  ../../11p9/g4img2s_src

# where are we
puts -nonewline "Sources Path  : "
puts $PATH_SOURCES
#
puts -nonewline "Linked Path   : "
puts $PATH_LINKED
#
puts -nonewline "Imported Path : "
puts $PATH_IMPORTED

puts -nonewline "Current Path  : "
puts [pwd]

# create new project
new_project -location $PATH_LINKED -name {g4img2s_lnk} -project_description {G4 M2S025T IMG DevKit} \
	-block_mode 0 -standalone_peripheral_initialization 0 -use_enhanced_constraint_flow 1 -hdl {VHDL} \
	-family {SmartFusion2} -die {M2S025T} -package {484 FBGA} -speed {STD} -die_voltage {1.2} \
	-part_range {COM} -adv_options {DSW_VCCA_VOLTAGE_RAMP_RATE:100_MS} \
	-adv_options {IO_DEFT_STD:LVCMOS 2.5V} -adv_options {PLL_SUPPLY:PLL_SUPPLY_25} \
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
         -hdl_source {./brdLexSwx.vhd} \
         -hdl_source {./brdRstClk.vhd} \
         -hdl_source {./brdConst_pkg.vhd} \
         -hdl_source {../vhdl/FsmPatGen.vhd} \
         -hdl_source {../vhdl/FsmSftDiv.vhd} \
         -hdl_source {../vhdl/myCccGat4.vhd} \
         -hdl_source {../vhdl/myCccMux4.vhd} \
         -hdl_source {../vhdl/myChpOsc4.vhd} \
         -hdl_source {../vhdl/myDff.vhd} \
         -hdl_source {../vhdl/myDffCnt.vhd} \
         -hdl_source {../vhdl/myPllOsc50m4.vhd} \
         -hdl_source {../vhdl/myRngOsc.vhd} \
         -hdl_source {../vhdl/mySerRxd.vhd} \
         -hdl_source {../vhdl/mySerTxd.vhd} \
         -hdl_source {../vhdl/mySynRst.vhd} \
         -hdl_source {../vhdl/OscCccPll.vhd} \
         -hdl_source {../vhdl/OscChpCnt.vhd} \
         -hdl_source {../vhdl/OscChpGat.vhd} \
         -hdl_source {../vhdl/OscChpMux.vhd} \
         -hdl_source {../vhdl/OscRngCnt.vhd} \
         -hdl_source {../vhdl/OscXtlCnt.vhd} \
         -hdl_source {../vhdl/OscXtlSer.vhd} \
         -hdl_source {../vhdl/OscXtlTxd.vhd} 
#
create_links \
         -convert_EDN_to_HDL 0 \
         -io_pdc {./g4brd.io.pdc} \
         -io_pdc {./g4led.io.pdc}
#         -io_pdc {./g4gpi.io.pdc}

set_root -module {OscRngCnt::work} 

organize_tool_files -tool {COMPILE} -input_type {constraint} -module {OscRngCnt::work} \
	-file {./g4led.io.pdc}

organize_tool_files -tool {COMPILE} -input_type {constraint} -module {OscChpCnt::work} \
	-file {./g4led.io.pdc}

organize_tool_files -tool {COMPILE} -input_type {constraint} -module {OscChpMux::work} \
	-file {./g4led.io.pdc}

organize_tool_files -tool {COMPILE} -input_type {constraint} -module {OscChpGat::work} \
	-file {./g4led.io.pdc}

organize_tool_files -tool {COMPILE} -input_type {constraint} -module {OscCccPll::work} \
	-file {./g4led.io.pdc}

organize_tool_files -tool {COMPILE} -input_type {constraint} -module {OscXtlCnt::work} \
	-file {./g4brd.io.pdc} \
	-file {./g4led.io.pdc}

organize_tool_files -tool {COMPILE} -input_type {constraint} -module {OscXtlSer::work} \
	-file {./g4brd.io.pdc} \
	-file {./g4led.io.pdc}

organize_tool_files -tool {COMPILE} -input_type {constraint} -module {OscXtlTxd::work} \
	-file {./g4brd.io.pdc} \
	-file {./g4led.io.pdc}

organize_tool_files -tool {COMPILE} -input_type {constraint} -module {FsmSftDiv::work} \
	-file {./g4brd.io.pdc} \
	-file {./g4led.io.pdc}

organize_tool_files -tool {COMPILE} -input_type {constraint} -module {FsmPatGen::work} \
	-file {./g4brd.io.pdc} \
	-file {./g4led.io.pdc}

save_project 
# close_project -save 1 

# save/make copy of project changing from "linked files" to "imported files"
save_project_as -location $PATH_IMPORTED -name {g4img2s_src} -replace_links 1 -files {all} -designer_views {all} 
save_project 

# copy project to ZIP archive
project_archive -location $PATH_LINKED -name {g4img2s_src} -replace_links 1 -files {all} -designer_views {all} 
save_project 

# show current/process working directory
puts -nonewline "Current Path  : "
puts [pwd]

# build project if arguments passed to script
if { $::argc > 0 } {

set PATH_CURRENT   $PATH_IMPORTED
cd $PATH_CURRENT
puts -nonewline "Current Path  : "
puts $PATH_CURRENT

set_root -module {OscRngCnt::work} 
# complete toolflow for reference
run_tool -name {SYNTHESIZE} 
run_tool -name {COMPILE} 
run_tool -name {PLACEROUTE} 
run_tool -name {VERIFYTIMING} 
run_tool -name {GENERATEPROGRAMMINGDATA}  
run_tool -name {GENERATEPROGRAMMINGFILE} 
export_bitstream_file \
         -file_name {OscRngCnt} \
         -export_dir {.\designer\OscRngCnt\export} \
         -format {STP} \
         -master_file 0 \
         -master_file_components {} \
         -encrypted_uek1_file 0 \
         -encrypted_uek1_file_components {} \
         -encrypted_uek2_file 0 \
         -encrypted_uek2_file_components {} \
         -trusted_facility_file 1 \
         -trusted_facility_file_components {FABRIC} \
         -add_golden_image 0 \
         -golden_image_address {} \
         -golden_image_design_version {} \
         -add_update_image 0 \
         -update_image_address {} \
         -update_image_design_version {} \
         -serialization_stapl_type {SINGLE} \
         -serialization_target_solution {FLASHPRO_3_4_5} 
# run_tool -name {PROGRAMDEVICE} 
#
# clean up project after exporting
delete_files -file $PATH_CURRENT/designer/impl1/OscRngCnt_placeroute_log.rpt -from_disk 
clean_tool -name {PLACEROUTE} 
#
delete_files -file $PATH_CURRENT/designer/impl1/OscRngCnt.adb -from_disk 
delete_files -file $PATH_CURRENT/designer/impl1/OscRngCnt_compile_log.rpt -from_disk 
clean_tool -name {COMPILE} 
#
delete_files -file $PATH_CURRENT/synthesis/OscRngCnt.edn -from_disk 
clean_tool -name {SYNTHESIZE} 
#
save_project 
#
}
#