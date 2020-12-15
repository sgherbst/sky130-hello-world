#!/bin/bash

# copy over RC file
cp $PDKPATH/libs.tech/magic/sky130A.magicrc .magicrc

# general setup
export CELL_NAME=sky130_fd_sc_hd__inv_1

# run DRC, expect no errors
# TODO: switch back to inv1.gds
export GDS_FILE=inv1_bad.gds
magic -noconsole -dnull run_drc.tcl | tee drc.log
if grep -q "error tiles" drc.log ; then
  exit 1
fi

# run DRC, expect errors
#export GDS_FILE=inv1_bad.gds
#magic -noconsole -dnull run_drc.tcl | tee drc.log
#if grep -q "error tiles" drc.log ; then
#  exit 1
#fi

# run extraction
#magic -noconsole -dnull run_ext.tcl

# run LVS
#netgen -batch lvs "lvs.spice $CELL_NAME" "inv1.spice $CELL_NAME" $PDKPATH/libs.tech/netgen/sky130A_setup.tcl
