onerror {resume}
quietly WaveActivateNextPane {} 0
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
add wave -noupdate -radix unsigned /top_tb/matrix_x
add wave -noupdate -radix unsigned /top_tb/matrix_p
add wave -noupdate -radix unsigned /top_tb/matrix_s
add wave -noupdate -radix unsigned /top_tb/max_p
add wave -noupdate -radix unsigned /top_tb/mean_p
add wave -noupdate -radix unsigned /top_tb/output_index
add wave -noupdate -radix unsigned /top_tb/operation_number
add wave -noupdate -radix unsigned /top_tb/data_matrix_p
add wave -noupdate -radix unsigned /top_tb/data_matrix_s
add wave -noupdate -radix unsigned /top_tb/test_phase
add wave -noupdate -radix unsigned /top_tb/error_cnt
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/i_clk_r
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/i_rst_p
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/i_data_x
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/i_data_vld
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/i_start
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/i_sort_order
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/i_sort_start
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/o_sort_vld
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/o_ready
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/o_mult_done
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/o_sort_done
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/i_ram_rd_en
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/o_ram_data
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/o_ram_data_vld
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/cnt
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/cnt_ff
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_start
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_ready
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_done
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_addr
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_data_p
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_data_vld
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/sort_order
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/sort_start
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/sort_ready
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/sort_done
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/sort_addr
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/sort_data_p
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/sort_data_s
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/sort_web
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/ram_addr
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/ram_data_out
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/ram_data_in
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/ram_wen
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {17445 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 189
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
WaveRestoreZoom {0 ns} {36587 ns}
