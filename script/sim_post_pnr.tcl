# ####################################################################### #
# MODELSIM POST PNR SIMULATION SCRIPT
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

# ----------------------------------------------------------------------- #
# Project
# ----------------------------------------------------------------------- #
quit -sim
# Create modelsim project
project close
project new . post_pnr_project

# Add tb files to project
foreach vhdFile $tb_list {
  project addfile ${vhdFile}
}
# Add netlist post PnR file to project
project addfile $netlist_path/top_pnr.v

# ----------------------------------------------------------------------- #
# Compile
# ----------------------------------------------------------------------- #
echo "----- Compilation started -----"
project compileall
echo "----- Compilation done -----"

# ----------------------------------------------------------------------- #
# Simulate
# ----------------------------------------------------------------------- #
vsim -L foc0l_a33_t33_generic_io -L fsc0l_d_generic_core -L foc0h_a33_t33_generic_io -t ps -L fsc0h_d_generic_core -voptargs=+acc -noglitch -sdftyp /top_tb/UUT=${netlist_path}/${top_entity_name}_pnr.fixed.sdf work.$tb_name

# write vcd file dump
vcd file $netlist_path/top.vcd
# add all UUT signals
vcd add -r /top_tb/UUT/*

echo "----- Simulation started -----"
do $tb_path/wave_top_synth.do
onbreak {resume}
run -all
echo "----- Simulation done -----"

# end vcd
echo "----- VCD written -----"
