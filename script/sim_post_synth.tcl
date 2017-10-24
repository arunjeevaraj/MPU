# ####################################################################### #
# MODELSIM POST SYNTHESIS SIMULATION SCRIPT
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
project new . post_synth_project

# Add tb files to project
foreach vhdFile $tb_list {
  project addfile ${vhdFile}
}
# Add netlist post synthesis file to project
project addfile $netlist_path/top.v

# ----------------------------------------------------------------------- #
# Compile
# ----------------------------------------------------------------------- #
echo "----- Compilation started -----"
project compileall
echo "----- Compilation done -----"

# ----------------------------------------------------------------------- #
# Simulate
# ----------------------------------------------------------------------- #
vsim -L foc0l_a33_t33_generic_io -L fsc0l_d_generic_core -voptargs=+acc -noglitch -sdftyp /top_tb/UUT=$netlist_path/${top_entity_name}_synth.fixed.sdf work.$tb_name

echo "----- Simulation started -----"
do $tb_path/wave_top_synth.do
onbreak {resume}
run -all
echo "----- Simulation done -----"
