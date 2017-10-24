# ####################################################################### #
# PNR SCRIPT
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

# ----------------------------------------------------------------------- #
# Changing the view
# ----------------------------------------------------------------------- #
fit
setDrawView fplan

globalNetConnect VCC -type pgpin -pin VCC -inst *
globalNetConnect VCC -type tiehi -pin VCC -inst *
globalNetConnect GND -type pgpin -pin GND -inst *
globalNetConnect GND -type tielo -pin GND -inst *

# ----------------------------------------------------------------------- #
# Setting the floor plan
# ----------------------------------------------------------------------- #
			#width # height # spacing between pads
floorPlan -site core -s 1007.9 479.2 20 20 20 20

# ----------------------------------------------------------------------- #
# Moving the modules into the core area
# ----------------------------------------------------------------------- #
setObjFPlanBox Instance top_internal_inst/ram_wrapper_inst/ram_inst 429.9 527.2 1179.9 641.2
## lower left coordinate 1007.9+172-750 479.2+172-124 1007.9+172 479.2+162
setObjFPlanBox Instance top_internal_inst/matrix_multiplier_inst/rom_wrapper_inst/rom_inst 172 555.2 302.4 641.2
## lower left coordinate 172 479.2+172-96  upper right coordinate 230.4+172 479.2+162
setObjFPlanBox Module top_internal_inst 183.119 191.156 1133.119 491.956

# ----------------------------------------------------------------------- #
# Setting the halo aroung the RAM & ROM
# ----------------------------------------------------------------------- #
addHaloToBlock 10 10 10 10 top_internal_inst/ram_wrapper_inst/ram_inst
addHaloToBlock 10 10 10 10 top_internal_inst/matrix_multiplier_inst/rom_wrapper_inst/rom_inst

# ----------------------------------------------------------------------- #
# Cutting the row
# ----------------------------------------------------------------------- #
cutRow -object top_internal_inst/matrix_multiplier_inst/rom_wrapper_inst/rom_inst
cutRow -object top_internal_inst/ram_wrapper_inst/ram_inst

# ----------------------------------------------------------------------- #
# Adding the power rings
# ----------------------------------------------------------------------- #
# around the core
addRing -stacked_via_top_layer metal8 -around core -jog_distance 0.4 -threshold 0.4 -nets {GND VCC} -stacked_via_bottom_layer metal1 -layer {bottom metal3 top metal3 right metal4 left metal4} -width 2 -spacing 2 -offset 2
# around the rom
deselectAll
selectInst top_internal_inst/matrix_multiplier_inst/rom_wrapper_inst/rom_inst
addRing -stacked_via_top_layer metal8 -around selected -jog_distance 0.4 -threshold 0.4 -type block_rings -nets {GND VCC} -stacked_via_bottom_layer metal1 -layer {bottom metal3 top metal3 right metal4 left metal4} -width 2 -spacing 2 -offset 2 -skip_side {left top}
# around the ram
deselectAll
selectInst top_internal_inst/ram_wrapper_inst/ram_inst
addRing -stacked_via_top_layer metal8 -around selected -jog_distance 0.4 -threshold 0.4 -type block_rings -nets {GND VCC} -stacked_via_bottom_layer metal1 -layer {bottom metal3 top metal3 right metal4 left metal4} -width 2 -spacing 2 -offset 2 -skip_side {right top}

# ----------------------------------------------------------------------- #
# Create the stripes
# ----------------------------------------------------------------------- #
set merge_strip_distance 10
set strip_distance_h 100
set strip_distance_v 101

# adding the horizontal step
addStripe -block_ring_top_layer_limit metal4 -max_same_layer_jog_length 0.8 -padcore_ring_bottom_layer_limit metal2 -set_to_set_distance $strip_distance_h -stacked_via_top_layer metal8 -padcore_ring_top_layer_limit metal4 -spacing 2 -merge_stripes_value $merge_strip_distance -direction horizontal -layer metal3 -block_ring_bottom_layer_limit metal2 -width 2 -nets {GND VCC} -stacked_via_bottom_layer metal1
# adding the vertical step
addStripe -block_ring_top_layer_limit metal4 -max_same_layer_jog_length 0.8 -padcore_ring_bottom_layer_limit metal2 -set_to_set_distance $strip_distance_v -stacked_via_top_layer metal8 -padcore_ring_top_layer_limit metal4 -spacing 2 -merge_stripes_value $merge_strip_distance -layer metal4 -block_ring_bottom_layer_limit metal2 -width 2 -nets {GND VCC} -stacked_via_bottom_layer metal1

# ----------------------------------------------------------------------- #
# Filling the well tap
# ----------------------------------------------------------------------- #
addWellTap -cell FILLER4ELD -cellInterval 25 -prefix WELLTAP

# ----------------------------------------------------------------------- #
# The cell placement blockage M1 to M8
# ----------------------------------------------------------------------- #
setPlaceMode -prerouteAsObs {1 2 3 4 5 6 7 8} -fp false		
# fp is set to faulse by default.. 
placeDesign -prePlaceOpt

# ----------------------------------------------------------------------- #
# Pre CTS optimization
# ----------------------------------------------------------------------- #
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -preCTS

# ----------------------------------------------------------------------- #
# Create clock tree
# ----------------------------------------------------------------------- #
createClockTreeSpec -bufferList {BUFCKELD BUFCKGLD BUFCKHLD BUFCKILD BUFCKJLD BUFCKKLD BUFCKLLD BUFCKMLD BUFCKNLD BUFCKQLD BUFCLD BUFDLD BUFELD BUFGLD BUFHLD BUFILD BUFJLD BUFKLD BUFLLD BUFMLD BUFNLD BUFQLD DELAKLD DELBKLD DELCKLD DELDKLD INVCKDLD INVCKGLD INVCKHLD INVCKILD INVCKJLD INVCKKLD INVCKLLD INVCKMLD INVCKNLD INVCKQLD INVCLD INVDLD INVGLD INVHLD INVILD INVJLD INVKLD INVLLD INVMLD INVNLD INVQLD} -file Clock.ctstch
clockDesign -specFile Clock.ctstch -outDir clock_report -fixedInstBeforeCTS

# ----------------------------------------------------------------------- #
# Post CTS optimization
# ----------------------------------------------------------------------- #
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -postCTS

# ----------------------------------------------------------------------- #
# Adding filler IO
# ----------------------------------------------------------------------- #
addIoFiller -cell EMPTY16LB EMPTY8LB EMPTY4LB EMPTY2LB EMPTY1LB -prefix IO_FILLER -side n
addIoFiller -cell EMPTY16LB EMPTY8LB EMPTY4LB EMPTY2LB EMPTY1LB -prefix IO_FILLER -side w
addIoFiller -cell EMPTY16LB EMPTY8LB EMPTY4LB EMPTY2LB EMPTY1LB -prefix IO_FILLER -side e
addIoFiller -cell EMPTY16LB EMPTY8LB EMPTY4LB EMPTY2LB EMPTY1LB -prefix IO_FILLER -side s

# ----------------------------------------------------------------------- #
# Special route
# ----------------------------------------------------------------------- #
sroute -connect { blockPin padPin padRing corePin floatingStripe } -layerChangeRange { metal1 metal8 } -blockPinTarget { nearestRingStripe nearestTarget } -padPinPortConnect { allPort oneGeom } -stripeSCpinTarget { blockring padring ring stripe ringpin blockpin } -checkAlignedSecondaryPin 1 -blockPin useLef -allowJogging 1 -crossoverViaBottomLayer metal1 -allowLayerChange 1 -targetViaTopLayer metal8 -crossoverViaTopLayer metal8 -targetViaBottomLayer metal1 -nets { GND VCC }

# ----------------------------------------------------------------------- #
# NanoRoute
# ----------------------------------------------------------------------- #
setNanoRouteMode -quiet -timingEngine {}
setNanoRouteMode -quiet -routeWithSiPostRouteFix 0
setNanoRouteMode -quiet -routeTopRoutingLayer default
setNanoRouteMode -quiet -routeBottomRoutingLayer default
setNanoRouteMode -quiet -drouteEndIteration default
setNanoRouteMode -quiet -routeWithTimingDriven false
setNanoRouteMode -quiet -routeWithSiDriven false
routeDesign -globalDetail

# ----------------------------------------------------------------------- #
# Suppress the error that generate OCV operation failed
# ----------------------------------------------------------------------- #
setDelayCalMode -SIAware false

# ----------------------------------------------------------------------- #
# Reports generation
# ----------------------------------------------------------------------- #
# generate time report for setup
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -postRoute -pathReports -drvReports -slackReports -numPaths 50 -prefix top_postRoute -outDir timingReports

# generate time report for hold time
redirect -quiet {set honorDomain [getAnalysisMode -honorClockDomains]} > /dev/null
timeDesign -postRoute -hold -pathReports -slackReports -numPaths 50 -prefix top_postRoute -outDir timingReports

# ----------------------------------------------------------------------- #
# Post Route optimizations
# ----------------------------------------------------------------------- #
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -postRoute
setOptMode -fixCap true -fixTran true -fixFanoutLoad true
optDesign -postRoute -hold

# ----------------------------------------------------------------------- #
# Add filler
# ----------------------------------------------------------------------- #
addFiller -cell FILLER64ELD FILLER32ELD FILLER16ELD FILLER8ELD FILLER4ELD FILLER3LD FILLER2LD FILLER1LD -prefix FILLER -markFixed

# ----------------------------------------------------------------------- #
# Write output files
# ----------------------------------------------------------------------- #
# write sdf file
write_sdf -version 2.1 -interconn nooutport ./netlists/top_pnr.sdf
# write sdc file
write_sdc ./netlists/top_pnr.sdc
# write the netlist file
saveNetlist ./netlists/top_pnr.v

# save the files for power analysis
rcOut -spf ./netlists/top_pnr.spf -rc_corner SS
rcOut -spef ./netlists/top_pnr.spef -rc_corner SS
