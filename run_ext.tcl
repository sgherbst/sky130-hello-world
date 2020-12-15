# read design
gds read $::env(GDS_FILE)
load $::env(CELL_NAME)

# extract for LVS
extract all
ext2spice lvs
ext2spice subcircuits off
ext2spice -o lvs.spice

# extract for PEX
select top cell
port makeall
ext2spice lvs
ext2spice cthresh 0.01
ext2spice rthresh 0.01
ext2spice subcircuit on
ext2spice ngspice
ext2spice -o pex.spice

# quit
quit
