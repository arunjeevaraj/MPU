onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider TESTBENCH
add wave -noupdate -radix unsigned /top_tb/clk
add wave -noupdate -radix unsigned /top_tb/rst
add wave -noupdate -radix unsigned /top_tb/tb_data_x
add wave -noupdate -radix unsigned /top_tb/tb_data_x_vld
add wave -noupdate -radix unsigned /top_tb/tb_start
add wave -noupdate -radix unsigned /top_tb/tb_sort_order
add wave -noupdate -radix unsigned /top_tb/tb_sort_start
add wave -noupdate -radix unsigned /top_tb/tb_sort_vld
add wave -noupdate -radix unsigned /top_tb/tb_ready
add wave -noupdate -radix unsigned /top_tb/tb_mult_done
add wave -noupdate -radix unsigned /top_tb/tb_sort_done
add wave -noupdate -radix unsigned /top_tb/tb_ram_addr
add wave -noupdate -radix unsigned /top_tb/tb_ram_rd_en
add wave -noupdate -radix unsigned /top_tb/tb_ram_data
add wave -noupdate -radix unsigned /top_tb/tb_ram_data_vld
add wave -noupdate -radix unsigned /top_tb/output_index
add wave -noupdate -radix unsigned /top_tb/operation_number
add wave -noupdate -radix unsigned /top_tb/test_phase
add wave -noupdate -itemcolor Gold -radix unsigned /top_tb/error_cnt
add wave -noupdate -divider {ref values}
add wave -noupdate -radix unsigned /top_tb/matrix_x
add wave -noupdate -radix unsigned /top_tb/matrix_p
add wave -noupdate -radix unsigned /top_tb/matrix_s
add wave -noupdate -radix unsigned /top_tb/max_p
add wave -noupdate -radix unsigned /top_tb/mean_p
add wave -noupdate -radix unsigned /top_tb/data_matrix_p
add wave -noupdate -radix unsigned /top_tb/data_matrix_s
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {29000 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 225
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 2
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
WaveRestoreZoom {0 ns} {30000 ns}
