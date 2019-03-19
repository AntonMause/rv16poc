# Exporting core myOSC to TCL
# Exporting Create design command for core myOSC
create_and_configure_core -core_vlnv {Actel:SgCore:OSC:2.0.101} -component_name {myOSC} -params {\
"FAMILY:19"  \
"PARAM_IS_FALSE:false"  \
"RCOSC_1MHZ_DRIVES_CCC:1"  \
"RCOSC_1MHZ_DRIVES_FAB:1"  \
"RCOSC_1MHZ_IS_USED:1"  \
"RCOSC_25_50MHZ_DRIVES_CCC:1"  \
"RCOSC_25_50MHZ_DRIVES_FAB:1"  \
"RCOSC_25_50MHZ_IS_USED:1"  \
"VOLTAGE_IS_1_2:true"  \
"XTLOSC_DRIVES_CCC:false"  \
"XTLOSC_DRIVES_FAB:false"  \
"XTLOSC_FREQ:20.00"  \
"XTLOSC_IS_USED:false"  \
"XTLOSC_SRC:CRYSTAL"   } -inhibit_configurator 1
# Exporting core myOSC to TCL done
