# default constraining 100 MHz, reaching 173 MHz, using 125 LUT4
#create_clock -name {Clock} -period 10 -waveform {0 5 } [ get_ports { i_clk } ]

# constrain to 200 MHz, reaching 228 MHz using 163 LUT4
create_clock -name {Clock} -period 5 -waveform {0 2.5 } [ get_ports { i_clk } ]

# over constrain to 275 MHz, reaching 235 MHz using 185 G4 LUT4
#create_clock -name {Clock} -period 3.63636 -waveform {0 1.81818 } [ get_ports { i_clk } ]
# may reach 268 MHz after place and route later on