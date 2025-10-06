# g5 cpu clock
create_clock -name {clock} -period 5 -waveform {0 2.5 } [ get_ports { i_clk } ]
