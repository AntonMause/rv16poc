onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /rv51mt_tb/NSYSRESET
add wave -noupdate /rv51mt_tb/rv51mt_0/s0_tid
add wave -noupdate -divider t0
add wave -noupdate /rv51mt_tb/rv51mt_0/s0_pc0i
add wave -noupdate /rv51mt_tb/rv51mt_0/s0_pc0o
add wave -noupdate -expand /rv51mt_tb/rv51mt_0/s_pcu_mem
add wave -noupdate /rv51mt_tb/rv51mt_0/s0_mx2
add wave -noupdate -divider T1
add wave -noupdate /rv51mt_tb/rv51mt_0/o_vld
add wave -noupdate /rv51mt_tb/rv51mt_0/s1_pc0
add wave -noupdate /rv51mt_tb/rv51mt_0/s1_pc4
add wave -noupdate /rv51mt_tb/rv51mt_0/s1_mx2
add wave -noupdate -divider T2
add wave -noupdate /rv51mt_tb/rv51mt_0/s2_tid
add wave -noupdate /rv51mt_tb/rv51mt_0/s2_pc0
add wave -noupdate /rv51mt_tb/rv51mt_0/s2_pc4
add wave -noupdate /rv51mt_tb/rv51mt_0/s2_ins
add wave -noupdate /rv51mt_tb/rv51mt_0/s2_dec
add wave -noupdate /rv51mt_tb/rv51mt_0/s2_rs1
add wave -noupdate /rv51mt_tb/rv51mt_0/s2_rs2
add wave -noupdate /rv51mt_tb/rv51mt_0/s2_rd
add wave -noupdate /rv51mt_tb/rv51mt_0/s2_no0
add wave -noupdate /rv51mt_tb/rv51mt_0/s2_rdw
add wave -noupdate /rv51mt_tb/rv51mt_0/s2_mx2
add wave -noupdate /rv51mt_tb/rv51mt_0/s_rra1
add wave -noupdate /rv51mt_tb/rv51mt_0/s_rra2
add wave -noupdate -divider T3
add wave -noupdate /rv51mt_tb/rv51mt_0/s3_pc0
add wave -noupdate /rv51mt_tb/rv51mt_0/s3_pc4
add wave -noupdate /rv51mt_tb/rv51mt_0/s3_pcxx
add wave -noupdate /rv51mt_tb/rv51mt_0/s3_rg1
add wave -noupdate /rv51mt_tb/rv51mt_0/s3_rg2
add wave -noupdate /rv51mt_tb/rv51mt_0/s_rwa
add wave -noupdate /rv51mt_tb/rv51mt_0/s3_rd
add wave -noupdate /rv51mt_tb/rv51mt_0/s_dwa
add wave -noupdate /rv51mt_tb/rv51mt_0/s_dwd
add wave -noupdate /rv51mt_tb/rv51mt_0/s3_rdw
add wave -noupdate /rv51mt_tb/rv51mt_0/s_reg_mem
add wave -noupdate -divider Top
add wave -noupdate /rv51mt_tb/SYSCLK
add wave -noupdate /rv51mt_tb/rv51mt_0/s1_tid
add wave -noupdate /rv51mt_tb/rv51mt_0/s3_tid
add wave -noupdate /rv51mt_tb/rv51mt_0/o_gpo
add wave -noupdate /rv51mt_tb/rv51mt_0/s_gpo6
add wave -noupdate /rv51mt_tb/rv51mt_0/s_gpo1
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {157500 ps} 0} {{Cursor 2} {182500 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 236
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
WaveRestoreZoom {135567 ps} {328035 ps}
