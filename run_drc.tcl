# read design
gds read $::env(GDS_FILE)
load $::env(CELL_NAME)

# count number of DRC errors
drc catchup
drc count

# quit
quit
