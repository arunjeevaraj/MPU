# ####################################################################### #
# GENERATE DB SCRIPT
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
# Generate db library
# ----------------------------------------------------------------------- #
enable_write_lib_mode
# ROM
read_lib $lib_path/SHUD130_128X32X1BM1_TC.lib
write_lib SHUD130_128X32X1BM1_TC -output $lib_path/SHUD130_128X32X1BM1_TC.db
read_lib $lib_path/SHUD130_128X32X1BM1_WC.lib
write_lib SHUD130_128X32X1BM1_WC -output $lib_path/SHUD130_128X32X1BM1_WC.db

# RAM
read_lib $lib_path/SPUD130_512X14BM1A_TC.lib
write_lib SPUD130_512X14BM1A_TC -output $lib_path/SPUD130_512X14BM1A_TC.db
read_lib $lib_path/SPUD130_512X14BM1A_WC.lib
write_lib SPUD130_512X14BM1A_WC -output $lib_path/SPUD130_512X14BM1A_WC.db
