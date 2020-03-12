# Main OnBoard Oscillator
create_clock -name {OSC_CLK} -period 20 -waveform {0 10 } [ get_ports { OSC_CLK } ]

