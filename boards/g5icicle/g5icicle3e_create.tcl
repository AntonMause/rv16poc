#
# Microsemi Tcl Script for Microsemi Libero SoC
# (c) 2019 by Anton Mause 
#
# Microsemi Icicle Kit for Microsemi MPFS250TS-484ES (2020)
#
# tested with board Rev ??????
#

source ../../scripts/g5config.tcl
puts -nonewline "Targeting Libero Version:" 
puts $LIBERO_VERSION

#
set BOARD_NAME         g5icicle3e
set NAME_BASE          _rv16base
set NAME_BASE          $BOARD_NAME$NAME_BASE
#
set PROJ_DESCRIPTION   "G5 MPFS250 ES Microsemi Icicle Kit rv16"
set PATH_DESTINATION   "../../.."
set PATH_DESTINATION   $PATH_DESTINATION/$LIBERO_VERSION
set PATH_POOL          "../g5pool"
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
    -block_mode 0 -standalone_peripheral_initialization 0 -instantiate_in_smartdesign 1 \
	-ondemand_build_dh 1 -use_relative_path 0 -linked_files_root_dir_env {} -hdl {VHDL} \
	-family {PolarFireSoC} -die {MPFS250T_ES} -package {FCVG484} -speed {STD} \
	-die_voltage {1.0} -part_range {EXT} -adv_options {IO_DEFT_STD:LVCMOS 1.8V} \
	-adv_options {RESTRICTPROBEPINS:1} -adv_options {RESTRICTSPIPINS:0} \
	-adv_options {SYSTEM_CONTROLLER_SUSPEND_MODE:0} -adv_options {TEMPR:EXT} \
	-adv_options {VCCI_1.2_VOLTR:EXT} -adv_options {VCCI_1.5_VOLTR:EXT} \
	-adv_options {VCCI_1.8_VOLTR:EXT} -adv_options {VCCI_2.5_VOLTR:EXT} \
	-adv_options {VCCI_3.3_VOLTR:EXT} -adv_options {VOLTR:EXT} 

set_device -family {PolarFireSoC} -die {MPFS250T_ES} -package {FCVG484} -speed {STD} \
    -die_voltage {1.0} -part_range {EXT} -adv_options {IO_DEFT_STD:LVCMOS 1.8V} \
	-adv_options {RESTRICTPROBEPINS:1} -adv_options {RESTRICTSPIPINS:0} \
	-adv_options {SYSTEM_CONTROLLER_SUSPEND_MODE:0} -adv_options {TEMPR:EXT} \
	-adv_options {VCCI_1.2_VOLTR:EXT} -adv_options {VCCI_1.5_VOLTR:EXT} \
	-adv_options {VCCI_1.8_VOLTR:EXT} -adv_options {VCCI_2.5_VOLTR:EXT} \
	-adv_options {VCCI_3.3_VOLTR:EXT} -adv_options {VOLTR:EXT} 

# initial source files, HDL and constraints
import_files \
    -convert_EDN_to_HDL 0 \
    -hdl_source {./brdConst_pkg.vhd} \
    -hdl_source {./brdRstClk.vhd} \
    -hdl_source $PATH_POOL/mySynCnt.vhd
#    -hdl_source $PATH_POOL/rv16uram.vhd \
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

# source $PATH_POOL/g5myOSC.tcl
# source $PATH_POOL/g5myCCC.tcl
# source $PATH_POOL/g5my17Madd.tcl
source $PATH_POOL/PFSOC_INIT_MONITOR_C0.tcl

save_project 

# copy project to ZIP archive
project_archive -location $PATH_BASE -name $NAME_BASE -replace_links 1 -files {all} -designer_views {all} 

# finished base project, let's modify it   #########################################################

set NAME_CONCAT .prjx
set NAME_CONCAT $PATH_BASE/$NAME_BASE$NAME_CONCAT

#rv16poc currently broken because of g4mem
#open_project -file $NAME_CONCAT -do_backup_on_convert 0
#source ../../rv16poc/g5rv16poc_create.tcl

open_project -file $NAME_CONCAT -do_backup_on_convert 0
source ../../rv16gpo/g5rv16gpo_create.tcl
save_project 

#if { $::argc > 0 } {
#}
#
# ToDo :
# could not yet TCL this :
# stimulus hierachy -> set as active stimulus
# project -> settings -> waveforms -> enable wave.do
#
