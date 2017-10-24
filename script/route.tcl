# ####################################################################### #
# PNR SCRIPT
# ####################################################################### #
## Date   : 24th Feb 2016
## author : Arun and Sebastien
## Note   : first run route_init.tcl
# ####################################################################### #

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
