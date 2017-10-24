# ####################################################################### #
# DESIGN SETUP SCRIPT
# ####################################################################### #
# ----------------------------------------------------------------------- #
# Set paths
# ----------------------------------------------------------------------- #
set dir_path "."
set rtl_path "$dir_path/vhdl"
set tb_path "$dir_path/testbench"
set lib_path "$dir_path/library"
set netlist_path "$dir_path/netlists"
set report_path "$dir_path/reports"

# ----------------------------------------------------------------------- #
# RTL files lists
# ----------------------------------------------------------------------- #
# Naming
set top_entity_name "top"
set top_arch_name "top_arch"
set clk_signal "i_clk_r"
set clk_name "clk"

# List of files for RTL
set rtl_list "$rtl_path/rom_wrapper.vhd \
$rtl_path/ctrl.vhd \
$rtl_path/input_reg.vhd \
$rtl_path/mu.vhd \
$rtl_path/ram_wrapper.vhd \
$rtl_path/max.vhd \
$rtl_path/avg.vhd \
$rtl_path/matrix_multiplier.vhd \
$rtl_path/sorter.vhd \
$rtl_path/top_internal.vhd"

# List of files used for behavioral model
set behav_list $rtl_list
lappend behav_list "$rtl_path/top.vhd"
# List of files used for synthesis
set synth_list $rtl_list
lappend synth_list "$rtl_path/top_pad.vhd"

# List of files for TB
set tb_list "$tb_path/matrix_multiplier_pkg.vhd \
$tb_path/SHUD130_128X32X1BM1.vhd \
$tb_path/SPUD130_512X14BM1A.vhd \
$tb_path/top_tb.vhd"

# ----------------------------------------------------------------------- #
# Testbench
# ----------------------------------------------------------------------- #
set tb_name "top_tb"
