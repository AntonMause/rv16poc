#
# Microsemi Tcl Script for Microsemi Libero SoC
# (c) 2019 by Anton Mause 
#
# Microsemi RTG4 Proto Kit for (2014)
# Board populated with prototyping silicon
#
# tested with ...
#

source ../../scripts/g4config.tcl
puts -nonewline "Targeting Libero Version:" 
puts $LIBERO_VERSION

# 
set BOARD_NAME         g4rt15pr
set NAME_BASE          _rv16base
set NAME_BASE          $BOARD_NAME$NAME_BASE
#
set PROJ_DESCRIPTION   "RTG4 150 Proto DevKit rv16"
set PATH_DESTINATION   "../../.."
set PATH_DESTINATION   $PATH_DESTINATION/$LIBERO_VERSION
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
	-block_mode 0 -standalone_peripheral_initialization 0 -instantiate_in_smartdesign 1 \
	-ondemand_build_dh 1 -use_relative_path 0 -linked_files_root_dir_env {} -hdl {VHDL} \
	-family {RTG4} -die {RT4G150} -package {1657 CG} -speed {STD} -die_voltage {1.2} -part_range {MIL} \
	-adv_options {IO_DEFT_STD:LVCMOS 2.5V} -adv_options {RESTRICTPROBEPINS:1} \
	-adv_options {RESTRICTSPIPINS:0} -adv_options {TEMPR:MIL} \
	-adv_options {VCCI_1.2_VOLTR:MIL} -adv_options {VCCI_1.5_VOLTR:MIL} \
	-adv_options {VCCI_1.8_VOLTR:MIL} -adv_options {VCCI_2.5_VOLTR:MIL} \
	-adv_options {VCCI_3.3_VOLTR:MIL} -adv_options {VOLTR:MIL} 

# initial source files, HDL and constraints
import_files \
    -convert_EDN_to_HDL 0 \
	-hdl_source {./brdRstClk.vhd} \
    -hdl_source {./brdConst_pkg.vhd} \
    -hdl_source $PATH_POOL/rv16uram.vhd \
    -hdl_source $PATH_POOL/mySynCnt.vhd
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

#source $PATH_POOL/g4myOSC.tcl
#source $PATH_POOL/g4myCCC.tcl
#source $PATH_POOL/g4my17Madd.tcl

save_project 

# copy project to ZIP archive
project_archive -location $PATH_BASE -name $NAME_BASE -replace_links 1 -files {all} -designer_views {all} 

# finished base project, let's modify it   #########################################################

set NAME_CONCAT .prjx
set NAME_CONCAT $PATH_BASE/$NAME_BASE$NAME_CONCAT

open_project -file $NAME_CONCAT -do_backup_on_convert 0
source ../../rv16poc/g4rv16poc_create.tcl

open_project -file $NAME_CONCAT -do_backup_on_convert 0
source ../../rv16gpo/g4rv16gpo_create.tcl
save_project 

#if { $::argc > 0 } {
#}
#
# ToDo :
# could not yet TCL this :
# stimulus hierachy -> set as active stimulus
# project -> settings -> waveforms -> enable wave.do
#
