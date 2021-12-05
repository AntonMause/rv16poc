onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tbi10_tb/SYSCLK
add wave -noupdate /tbi10_tb/NSYSRESET
add wave -noupdate /tbi10_tb/s_dati
add wave -noupdate /tbi10_tb/s_dato
add wave -noupdate /tbi10_tb/s_clk10
add wave -noupdate /tbi10_tb/s_clk8
add wave -noupdate -divider Register
add wave -noupdate /tbi10_tb/tbi10to4_0/s_tbi_dat
add wave -noupdate /tbi10_tb/tbi10to4_0/s_sft_dat
add wave -noupdate -divider Intern
add wave -noupdate /tbi10_tb/tbi10to4_0/r_sft_pat
add wave -noupdate /tbi10_tb/tbi10to4_0/f_sft_bit
add wave -noupdate /tbi10_tb/tbi10to4_0/r_sft_upd
add wave -noupdate /tbi10_tb/tbi10to4_0/s_odd_d
add wave -noupdate /tbi10_tb/tbi10to4_0/s_sft_upd
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {34911 ps} 0} {{Cursor 2} {60000 ps} 0} {{Cursor 3} {85000 ps} 0} {{Cursor 4} {109566 ps} 0}
quietly wave cursor active 4
configure wave -namecolwidth 199
configure wave -valuecolwidth 39
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {133466 ps}
