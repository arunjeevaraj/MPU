##-----------------------------------------------------
## Design       : matrix Multiplication
## File Name    : pt_timing.tcl
## Purpose      : PrimeTime STA template for Matrix Multiplication 
## Limitation   : none
## Errors       : none known
## Include Files: none
## Author       : Sebastien and Arun
## Software     : Synopsys PrimeTime
##---------------------------------------------------
## Revision List:
##+-----------+--------------------+-----------------+----------------------------------+
##| Version   |Author              | Date            | Changes	                        |
##+-----------+--------------------+-----------------+----------------------------------+
##|1.0        |       Sebastien and  Arun  | 2016/02/26      | original created         |
##+-----------+--------------------+-----------------+----------------------------------+

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

echo "starting the script"
##################  remove any previous designs
#echo "remove design"
#remove_design -all

################### set up power analysis mode #####################
# step 1: enalbe power analysis and set analysis mode 

echo "power enable & analysis mode"
set power_enable_analysis true
set power_analysis_mode time_based


####################### set up libaries ############################
# step 1: link to your design libary 
# used libaries: 
#               fsc0l_d_generic_core_ff1p32vm40c.db/fsc0l_d_generic_core_ss1p08v125c.db/fsc0l_d_generic_core_tt1p2v25c.db
#               foc0l_a33_t33_generic_io_ff1p32vm40c.db/foc0l_a33_t33_generic_io_ss1p08v125c.db/foc0l_a33_t33_generic_io_tt1p2v25c.db
#               SHLD130_128X32X1BM1_TC.db/SPLD130_512X14BM1A_TC.db

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



echo "mem library"
# RAM lib
set target_library "SHUD130_128X32X1BM1_WC.db $target_library"
set link_library "SHUD130_128X32X1BM1_WC.db $link_library"
# ROM lib
set target_library "SPUD130_512X14BM1A_WC.db $target_library"
set link_library "SPUD130_512X14BM1A_WC.db $link_library"


 
 
####################### design input    ############################
# step 2: read your design (netlist) & link design
# top deisgn name: MEDIANFILTER_N8

echo "current design"
read_verilog $netlist_path/top_pnr.v
#current_design top
#link -force

####################### timing constraint ##########################
# step 3: setup timing constraint (or read sdc file)
# clock port: clk

#read_sdc $netlist_path/top_synth.sdc
#read_sdc $netlist_path/top_pnr.sdc

current_design top
link
create_clock [get_ports {i_clk_r}]  -name clk -period 15.000000 -waveform {0.000000 1.000000}
set_propagated_clock  [get_ports {i_clk_r}]
set_clock_uncertainty 0.16 [get_clocks {clk}]



####################### Back annotate     ##########################
# step 4: back annotate delay information (read sdf file)

read_parasitics $netlist_path/top_pnr.spef
read_sdf -type sdf_max $netlist_path/top_pnr.fixed.sdf
#read_sdf -type sdf_max $netlist_path/top_synth.fixed.sdf
#read_sdf -type sdf_max $netlist_path/top_pnr.sdf

set_operating_conditions WCCOM

read_vcd -strip_path top_tb/UUT $netlist_path/top.vcd


####################### timing analysis and report #################
# step 5: output timing report, including setup timing, hold timing, and clock skew
check_power
update_power
report_power -verbose -hierarchy > $report_path/primetime/power_top.rpt
report_timing -delay_type min -max_paths 10 > $report_path/primetime/timing_hold_top.rpt
report_timing -delay_type max -max_paths 10 > $report_path/primetime/timing_setup_top.rpt

report_clock_timing -type skew -verbose > $report_path/primetime/timing_clk_top.rpt


