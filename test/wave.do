onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /rv16poc_tb/SYSCLK
add wave -noupdate /rv16poc_tb/NSYSRESET
add wave -noupdate /rv16poc_tb/rv16poc_0/s_rom_rdy
add wave -noupdate /rv16poc_tb/s_led
add wave -noupdate /rv16poc_tb/rv16poc_0/s_pcu_pc0
add wave -noupdate /rv16poc_tb/rv16poc_0/s_pcu_pc4
add wave -noupdate /rv16poc_tb/rv16poc_0/s_dec_ins
add wave -noupdate /rv16poc_tb/rv16poc_0/s_pcu_bra
add wave -noupdate /rv16poc_tb/rv16poc_0/s_pcu_jmp
add wave -noupdate /rv16poc_tb/rv16poc_0/s_cur_state
add wave -noupdate /rv16poc_tb/rv16poc_0/s_dec_rd
add wave -noupdate /rv16poc_tb/rv16poc_0/s_reg_wrt
add wave -noupdate /rv16poc_tb/rv16poc_0/s_log_in1
add wave -noupdate /rv16poc_tb/rv16poc_0/s_log_in2
add wave -noupdate /rv16poc_tb/rv16poc_0/s_log_out
add wave -noupdate /rv16poc_tb/rv16poc_0/s_mac_run
add wave -noupdate /rv16poc_tb/rv16poc_0/s_mac_sub
add wave -noupdate /rv16poc_tb/rv16poc_0/s_mac_msh
add wave -noupdate /rv16poc_tb/rv16poc_0/s_mac_in1
add wave -noupdate /rv16poc_tb/rv16poc_0/s_mac_in2
add wave -noupdate /rv16poc_tb/rv16poc_0/s_mac_in3
add wave -noupdate /rv16poc_tb/rv16poc_0/s_mac_out
add wave -noupdate /rv16poc_tb/rv16poc_0/s_reg_mem(0)
add wave -noupdate /rv16poc_tb/rv16poc_0/s_reg_mem(1)
add wave -noupdate /rv16poc_tb/rv16poc_0/s_reg_mem(2)
add wave -noupdate /rv16poc_tb/rv16poc_0/s_reg_mem(3)
add wave -noupdate /rv16poc_tb/rv16poc_0/s_reg_mem(4)
add wave -noupdate /rv16poc_tb/rv16poc_0/s_reg_mem(5)
add wave -noupdate /rv16poc_tb/rv16poc_0/s_reg_mem(6)
add wave -noupdate /rv16poc_tb/rv16poc_0/s_reg_mem(7)
add wave -noupdate /rv16poc_tb/rv16poc_0/s_dec_rd
add wave -noupdate /rv16poc_tb/rv16poc_0/s_dat_led
add wave -noupdate /rv16poc_tb/rv16poc_0/s_dat_wrt
add wave -noupdate /rv16poc_tb/rv16poc_0/s_reg_rs2
add wave -noupdate /rv16poc_tb/rv16poc_0/s_reg_rs1
add wave -noupdate /rv16poc_tb/rv16poc_0/s_dec_rs1
add wave -noupdate /rv16poc_tb/rv16poc_0/s_dec_rs2
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {667066062 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 234
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
WaveRestoreZoom {468358160 fs} {737930700 fs}
