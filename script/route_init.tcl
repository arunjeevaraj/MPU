# ####################################################################### #
# PNR SCRIPT
# ####################################################################### #
## Date   : 24th Feb 2016
## author : Arun and Sebastien
## Note   : first script
# ####################################################################### #

# ----------------------------------------------------------------------- #
# Initialize
# ----------------------------------------------------------------------- #
set init_verilog ./netlists/top.v
set init_pwr_net VCC	
set init_gnd_net GND
set init_lef_file {/usr/local-eit/cad2/far130/syn2012/header8m2t_V55.lef /usr/local-eit/cad2/far130/syn2012/fsc0l_d_generic_core.lef /usr/local-eit/cad2/far130/syn2012/FSC0L_D_GENERIC_CORE_ANT_V55.8m2t.lef /usr/local-eit/cad2/far130/syn2012/foc0l_a33_t33_generic_io.8m2t.lef /usr/local-eit/cad2/far130/syn2012/FOC0L_A33_T33_GENERIC_IO_ANT_V55.8m2t.lef ./library/SHUD130_128X32X1BM1.lef ./library/SPUD130_512X14BM1A.lef}
set init_io_file ./soc/top.io
set init_top_cell top
set init_mmmc_file {./script/route_setup.view}

save_global Default.globals
init_design

