
# ########################################################################
# file: g4rv16poc_create.tcl   (c) 2019 by Anton Mause
# finished base project, let's modify it   ###############################

set NAME_PROJ      _rv16poc
set NAME_PROJ      $BOARD_NAME$NAME_PROJ
set PATH_PROJ      $PATH_DESTINATION/$NAME_PROJ
puts -nonewline "Proj Path : "
puts $PATH_PROJ

save_project_as -location $PATH_PROJ -name $NAME_PROJ -replace_links 1 -files {all} -designer_views {all} 

import_files \
    -convert_EDN_to_HDL 0 \
    -hdl_source {../../rv16poc/rv16poc.vhd} \
    -hdl_source {../../rv16poc/rv16soc.vhd} 
#
import_files \
    -convert_EDN_to_HDL 0 \
    -library {} \
    -stimulus {../../rv16poc/rv16poc_tb.vhd} 

import_files \
    -convert_EDN_to_HDL 0 \
    -sdc {./brdBaseTim.sdc}

save_project 
build_design_hierarchy 

set_root -module {rv16soc::work} 
organize_tool_files -tool {PLACEROUTE} -input_type {constraint} -module {rv16soc::work} \
	-file $PATH_PROJ/constraint/io/brdBaseIo.pdc \
	-file $PATH_PROJ/constraint/io/brdLedIo.pdc
organize_tool_files -tool {SYNTHESIZE} -input_type {constraint} -module {rv16soc::work} \
    -file $PATH_PROJ/constraint/brdBaseTim.sdc

check_sdc_constraints -tool {synthesis} 
build_design_hierarchy 

set_root -module {rv16soc::work} 
save_project 
