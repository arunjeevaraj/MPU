# ####################################################################### #
# DC SYNTHESIS SCRIPT
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

# Config synthesis - 0: min area, 1: max speed
set MAX_SPEED_ENABLE 0
set EFFORT high

# Set clock period - fast for max speed, slow for min area
set fast_clk_period 2
set slow_clk_period 10

# Select VHDL for netlist, else verilog
set NETLIST_LANG_VHDL 0

# Clean
remove_design -all

# ----------------------------------------------------------------------- #
# Set library
# ----------------------------------------------------------------------- #
# RAM lib
set target_library "$lib_path/SHUD130_128X32X1BM1_BC.db $target_library"
set link_library "$lib_path/SHUD130_128X32X1BM1_BC.db $link_library"
# ROM lib
set target_library "$lib_path/SPUD130_512X14BM1A_BC.db $target_library"
set link_library "$lib_path/SPUD130_512X14BM1A_BC.db $link_library"

# ----------------------------------------------------------------------- #
# Analyse & elaborate
# ----------------------------------------------------------------------- #
analyze -library WORK -format vhdl $synth_list
elaborate $top_entity_name -architecture $top_arch_name -library DEFAULT

# Make sure the compiler does not exchange pads.
set_dont_touch [ get_cells *Pad*] true
set_dont_touch clkpad true

# ----------------------------------------------------------------------- #
# Set clock
# ----------------------------------------------------------------------- #
if { $MAX_SPEED_ENABLE == 1 } {
  create_clock $clk_signal -period $fast_clk_period -name $clk_name
  set_clock_uncertainty [expr "$fast_clk_period *0.02"] $clk_name
} else {
  create_clock $clk_signal -period $slow_clk_period -name $clk_name
  set_clock_uncertainty [expr "$slow_clk_period *0.02"] $clk_name
}
set_fix_hold $clk_name

# ----------------------------------------------------------------------- #
# Constrains
# ----------------------------------------------------------------------- #
if { $MAX_SPEED_ENABLE == 0 } { set_max_area 0 }

# ----------------------------------------------------------------------- #
# Synthesis
# ----------------------------------------------------------------------- #
compile -map_effort $EFFORT -area_effort $EFFORT

# ----------------------------------------------------------------------- #
# Reports
# ----------------------------------------------------------------------- #
check_design > $report_path/synth/checkdesign.rpt
report_constraint -all_violators > $report_path/synth/report_constraint.rpt
report_timing > $report_path/synth/report_timing.rpt
report_area -hierarchy > $report_path/synth/report_area.rpt

# ----------------------------------------------------------------------- #
# Netlist
# ----------------------------------------------------------------------- #
write -hierarchy -format ddc -output $netlist_path/${top_entity_name}_synth.ddc
# VHDL
if { $NETLIST_LANG_VHDL == 1 } {
  change_names -rules vhdl -hierarchy
  write -hierarchy -format vhdl -output $netlist_path/$top_entity_name.vhdl
} else {
# verilog
  change_names -rules verilog -hierarchy
  write -hierarchy -format verilog -output $netlist_path/$top_entity_name.v
}

# ----------------------------------------------------------------------- #
# Timing files
# ----------------------------------------------------------------------- #
write_sdf $netlist_path/${top_entity_name}_synth.sdf
write_sdc $netlist_path/${top_entity_name}_synth.sdc
