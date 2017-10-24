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
add wave -noupdate -divider TOP
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
add wave -noupdate -divider CTRL
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/ctrl_inst/i_clk_r
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/ctrl_inst/i_rst_p
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/ctrl_inst/i_start
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/ctrl_inst/o_r
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/ctrl_inst/o_i
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/ctrl_inst/o_j
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/ctrl_inst/o_rd_en
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/ctrl_inst/o_first_data_en
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/ctrl_inst/o_last_data_en
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/ctrl_inst/o_ready
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/ctrl_inst/o_done
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/ctrl_inst/current_state
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/ctrl_inst/elements_counter
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/ctrl_inst/MAX_NB_ELEMENTS
add wave -noupdate -divider ROM
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/rom_wrapper_inst/CK
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/rom_wrapper_inst/addr
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/rom_wrapper_inst/data_out
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/rom_wrapper_inst/CS
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/rom_wrapper_inst/OE
add wave -noupdate -divider INPUT_REG
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/input_reg_inst/i_clk_r
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/input_reg_inst/i_rst_p
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/input_reg_inst/i_data_x
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/input_reg_inst/i_data_vld
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/input_reg_inst/index
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/input_reg_inst/input_array
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/input_reg_inst/i_r
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/input_reg_inst/i_i
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/input_reg_inst/i_rd_en
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/input_reg_inst/o_data_x
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/input_reg_inst/o_data_vld
add wave -noupdate -divider MU
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/mu_inst/i_clk_r
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/mu_inst/i_rst_p
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/mu_inst/i_data_x
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/mu_inst/i_data_a
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/mu_inst/i_first_data_en
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/mu_inst/i_last_data_en
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/mu_inst/i_data_vld
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/mu_inst/o_data_p
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/mu_inst/o_data_vld
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/mu_inst/data_mult
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/mu_inst/data_acc
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/mu_inst/p_data
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/mu_inst/last_data
add wave -noupdate -divider MAX
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/max_inst/i_clk_r
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/max_inst/i_rst_p
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/max_inst/i_data_p
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/max_inst/i_new_max_en
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/max_inst/i_data_vld
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/max_inst/o_data_max
add wave -noupdate -divider AVG
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/avg_inst/i_clk_r
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/avg_inst/i_rst_p
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/avg_inst/i_data_p
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/avg_inst/i_new_avg_en
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/avg_inst/i_data_vld
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/matrix_multiplier_inst/avg_inst/o_data_avg
add wave -noupdate -divider SORTER
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/sorter_inst/clk
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/sorter_inst/rst
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/sorter_inst/sort_order
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/sorter_inst/sort_start
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/sorter_inst/sort_ready
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/sorter_inst/sort_finish
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/sorter_inst/addr
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/sorter_inst/data_in
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/sorter_inst/data_out
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/sorter_inst/web
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/sorter_inst/current_state
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/sorter_inst/next_state
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/sorter_inst/cnt_write
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/sorter_inst/cnt_read
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/sorter_inst/cnt_pass
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/sorter_inst/val_ref_reg
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/sorter_inst/swap_detected
add wave -noupdate -divider RAM
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/ram_wrapper_inst/CK
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/ram_wrapper_inst/addr
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/ram_wrapper_inst/data_in
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/ram_wrapper_inst/WEB
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/ram_wrapper_inst/data_out
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/ram_wrapper_inst/CS
add wave -noupdate -radix unsigned /top_tb/UUT/top_internal_inst/ram_wrapper_inst/OE
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
