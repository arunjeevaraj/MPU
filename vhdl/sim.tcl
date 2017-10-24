# ####################################################################### #
# MODELSIM BEHAVIORAL SIMULATION SCRIPT
# ####################################################################### #

# ----------------------------------------------------------------------- #
# script control part
# ----------------------------------------------------------------------- #
set dir_path "."

set script_path "$dir_path"
set rtl_path "$dir_path"	

# entity name of the test bench.
#set tb_name "reg_array_tb"
#set tb_name "address_deco_tb"
#set tb_name "Ram_test"
set tb_name "top_tb"
#-------------------------------------------------------------------------#
# Add Files to the rtl_list
#-------------------------------------------------------------------------#
set rtl_list "$rtl_path/address_deco_8v2.vhd \
		      $rtl_path/daig_writing.vhd \
			  $rtl_path/denorm.vhd \
			  $rtl_path/div_array.vhd \
			  $rtl_path/norm_lut.vhd \
			  $rtl_path/nr_div.vhd \
			  $rtl_path/top_inverse.vhd \
			  $rtl_path/Ram4_wrap.vhd \
			  $rtl_path/ram_wrapper.vhd \
			  $rtl_path/SHUD130_128X32X1BM1.vhd\
			  $rtl_path/mat_ctrl.vhd \
			  $rtl_path/reg_array.vhd \
			  $rtl_path/top.vhd \
			  $rtl_path/top_tb.vhd\
			  $rtl_path/mast_ctrl.vhd\
			  $rtl_path/d_mul4.vhd\
			  $rtl_path/mac4.vhd" 
#		  
# ----------------------------------------------------------------------- #
# Project
# ----------------------------------------------------------------------- #
quit -sim

# ----------------------------------------------------------------------- #
# Compile
# ----------------------------------------------------------------------- #
echo "----- Compilation Source start -----"
 foreach vhdFile $rtl_list {
   vcom -check_synthesis -source ${vhdFile}
 }
echo "----- Compilation Source done -----"

# ----------------------------------------------------------------------- #
# Start Simulation
# ----------------------------------------------------------------------- #

vsim work.$tb_name

# starting the simulation.

echo "----- Simulation started -----"
do $dir_path/wave.do

run 5000 ns
echo "----- Simulation ended -----"