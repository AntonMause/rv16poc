onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /rv16poc_tb/SYSCLK
add wave -noupdate /rv16poc_tb/NSYSRESET
add wave -noupdate /rv16poc_tb/rv16poc_0/s_rom_rdy
add wave -noupdate /rv16poc_tb/s_led
add wave -noupdate /rv16poc_tb/rv16poc_0/s_pcu_pc0
add wave -noupdate /rv16poc_tb/rv16poc_0/s_pcu_pc4
add wave -noupdate /rv16poc_tb/rv16poc_0/s_pcu_bra
add wave -noupdate /rv16poc_tb/rv16poc_0/s_pcu_jmp
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 fs} 0}
quietly wave cursor active 0
configure wave -namecolwidth 228
configure wave -valuecolwidth 100
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
WaveRestoreZoom {0 fs} {965129534 fs}
