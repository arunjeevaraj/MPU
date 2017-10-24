# ####################################################################### #
# PNR SCRIPT
# ####################################################################### #
## Date   : 24th Feb 2016
## author : Arun and Sebastien
## Note   : first run route.tcl
# ####################################################################### #

#restoreDesign topRoute1.enc.dat top

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

