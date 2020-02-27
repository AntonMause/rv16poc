# check againt 225 MHz, reching 268 MHz using speedgrade -1
create_clock -name {Clock} -period 4.44444 -waveform {0 2.22225 } [ get_ports { i_clk } ]
