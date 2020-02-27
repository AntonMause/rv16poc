# oover constrain to 275 MHz, reaching 235 MHz
create_clock -name {Clock} -period 3.63636 -waveform {0 1.81818 } [ get_ports { i_clk } ]
