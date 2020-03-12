# Exporting core my17Madd to TCL
# Exporting Create design command for core my17Madd
create_and_configure_core -core_vlnv {Actel:SgCore:HARD_MULT_ADDSUB:1.0.100} -component_name {my17Madd} -params {\
"A0_CONST:0x1"  \
"A0_IS_CONST:false"  \
"A0_IS_REGISTERED:true"  \
"A0_WIDTH:17"  \
"A1_CONST:0x1"  \
"A1_IS_CONST:false"  \
"A1_IS_REGISTERED:false"  \
"A1_WIDTH:1"  \
"ARSHFT17_IS_REGISTERED:false"  \
"ARSHFT17_IS_USED:false"  \
"B0_IS_REGISTERED:true"  \
"B0_WIDTH:17"  \
"B1_IS_REGISTERED:false"  \
"B1_WIDTH:1"  \
"C_CONST:0x0"  \
"C_IS_CONST:false"  \
"C_IS_REGISTERED:true"  \
"C_WIDTH:17"  \
"CDSEL:CDINCONST"  \
"CIN:true"  \
"FAMILY:19"  \
"OP_FUNCTION:MULTADDSUB"  \
"OP_MODE:NORMAL"  \
"OVERFLOW_COUT:COUT"  \
"P_IS_REGISTERED:false"  \
"SD_EXPORT_HIDDEN_PORTS:false"  \
"SUB_IS_REGISTERED:true"   } -inhibit_configurator 1
# Exporting core my17Madd to TCL done
