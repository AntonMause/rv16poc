# g5 cpu clock
create_clock -name {clock} -period 4 -waveform {0 2 } [ get_ports { i_clk } ]
