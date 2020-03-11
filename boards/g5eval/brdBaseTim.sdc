# Main OnBoard Oscillator
create_clock -name {OSC_CLK} -period 20 -waveform {0 10 } [ get_ports { OSC_CLK } ]

# Internal PreDivider (optional)
#create_clock -name {SYS_CLK} -period 40 -waveform {0 20 } [ get_nets { brdRstClk_0/s_tgl } ]
