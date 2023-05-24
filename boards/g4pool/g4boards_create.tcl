#
# Microsemi Tcl Script for Microsemi Libero SoC
# (c) 2019 by Anton Mause 
#
# Test generator for all supported boards
#

cd ../g4adv
#source g4adv15g_create.tcl
#source g4adv15s_create.tcl

cd ../g4dev
#source g4dev5g_create.tcl
#source g4dev5s_create.tcl

cd ../g4eval
source g4eval1g_create.tcl
source g4eval1s_create.tcl
source g4eval2g_create.tcl
source g4eval2s_create.tcl
source g4eval9g_create.tcl
source g4eval9s_create.tcl

cd ../g4fcsg
source g4fcsg2s_create.tcl
#cleanall_tool -name {GENERATEPROGRAMMINGDATA} 
#run_tool -name {GENERATEPROGRAMMINGDATA} 
save_project 

cd ../g4hello
source g4hello1g_create.tcl
source g4hello1s_create.tcl

cd ../g4img
source g4img2g_create.tcl
source g4img2s_create.tcl

cd ../g4kick
source g4kick1g_create.tcl
source g4kick1s_create.tcl

cd ../g4maker
source g4maker1g_create.tcl
source g4maker1s_create.tcl

cd ../g4tem
source g4tem1g_create.tcl
source g4tem1s_create.tcl
