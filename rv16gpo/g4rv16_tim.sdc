# target for rv16g4 is 50 MHz, could reach 100 MHz
create_clock -name {Clock} -period 20 -waveform {0 10 } [ get_ports { i_clk } ]
