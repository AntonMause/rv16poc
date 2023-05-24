#
# Microsemi Tcl Script for Microsemi Libero SoC
# (c) 2019 by Anton Mause 
#
# Test generator for all supported boards
#

cd ../g5eval
source g5eval3tse_create.tcl
cleanall_tool -name {GENERATEPROGRAMMINGDATA} 
run_tool -name {GENERATEPROGRAMMINGDATA} 
save_project 

cd ../g5eval
source g5eval3ts_create.tcl
cleanall_tool -name {GENERATEPROGRAMMINGDATA} 
run_tool -name {GENERATEPROGRAMMINGDATA} 
save_project 

cd ../g5icicle
source g5icicle3e_create.tcl
cleanall_tool -name {GENERATEPROGRAMMINGDATA} 
run_tool -name {GENERATEPROGRAMMINGDATA} 
save_project 

cd ../g5splash
source g5splash3tse_create.tcl
cleanall_tool -name {GENERATEPROGRAMMINGDATA} 
run_tool -name {GENERATEPROGRAMMINGDATA} 
save_project 

cd ../g5video3
source g5video3t_create.tcl
cleanall_tool -name {GENERATEPROGRAMMINGDATA} 
run_tool -name {GENERATEPROGRAMMINGDATA} 
save_project 
