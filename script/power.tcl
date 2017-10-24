# ####################################################################### #
# POWER ANALYSIS SCRIPT
# ####################################################################### #
# ----------------------------------------------------------------------- #
# Set paths
# ----------------------------------------------------------------------- #
set dir_path "."
set script_path "$dir_path/script"

# ----------------------------------------------------------------------- #
# Design setup
# ----------------------------------------------------------------------- #
source $script_path/design_setup.tcl
# Clean
remove_design -all

# ----------------------------------------------------------------------- #
# Set up power analysis
# ----------------------------------------------------------------------- #
set power_enable_analysis true
set power_analysis_mode time_based

# ----------------------------------------------------------------------- #
# Set library
# ----------------------------------------------------------------------- #
set search_path "$env(FAR_LIB) $search_path $lib_path"

set link_library "* fsc0l_d_generic_core_ff1p32vm40c.db \
		  fsc0l_d_generic_core_ss1p08v125c.db \
		  fsc0l_d_generic_core_tt1p2v25c.db \
		  foc0l_a33_t33_generic_io_ff1p32vm40c.db \
		  foc0l_a33_t33_generic_io_ss1p08v125c.db \
		  foc0l_a33_t33_generic_io_tt1p2v25c.db $link_library"

set target_library "fsc0l_d_generic_core_ff1p32vm40c.db \
                    fsc0l_d_generic_core_ss1p08v125c.db \
                    fsc0l_d_generic_core_tt1p2v25c.db \
		                foc0l_a33_t33_generic_io_ff1p32vm40c.db \
                    foc0l_a33_t33_generic_io_ss1p08v125c.db \
                    foc0l_a33_t33_generic_io_tt1p2v25c.db $target_library"
                    
set symbol_library "fsc0l_d_generic_core.sdb foc0l_a33_t33_generic_io.sdb"
set synthetic_library "standard.sldb dw_foundation.sldb"

# RAM lib
set target_library "SHUD130_128X32X1BM1_WC.db $target_library"
set link_library "SHUD130_128X32X1BM1_WC.db $link_library"
# ROM lib
set target_library "SPUD130_512X14BM1A_WC.db $target_library"
set link_library "SPUD130_512X14BM1A_WC.db $link_library"

# ----------------------------------------------------------------------- #
# Design input
# ----------------------------------------------------------------------- #
read_verilog $netlist_path/top_pnr.v

# ----------------------------------------------------------------------- #
# Timing constraint
# ----------------------------------------------------------------------- #
#read_sdc $netlist_path/top_pnr.sdc
current_design top
link
create_clock [get_ports {i_clk_r}]  -name clk -period 15.000000 -waveform {0.000000 1.000000}
set_propagated_clock  [get_ports {i_clk_r}]
set_clock_uncertainty 0.16 [get_clocks {clk}]

# ----------------------------------------------------------------------- #
# Back annotate
# ----------------------------------------------------------------------- #
read_parasitics $netlist_path/top_pnr.spef
read_sdf -type sdf_max $netlist_path/top_pnr.fixed.sdf

set_operating_conditions WCCOM
read_vcd -strip_path top_tb/UUT $netlist_path/top.vcd

# ----------------------------------------------------------------------- #
# Reports
# ----------------------------------------------------------------------- #
check_power
update_power
report_power -verbose -hierarchy > $report_path/primetime/power_top.rpt
report_timing -delay_type min -max_paths 10 > $report_path/primetime/timing_hold_top.rpt
report_timing -delay_type max -max_paths 10 > $report_path/primetime/timing_setup_top.rpt
report_clock_timing -type skew -verbose > $report_path/primetime/timing_clk_top.rpt
