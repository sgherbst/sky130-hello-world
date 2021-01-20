# copy over RC file
cp $PDKPATH/libs.tech/magic/sky130A.magicrc .magicrc

# general setup
export CELL_NAME=sky130_fd_sc_hd__inv_1

# run DRC on a "good" GDS: expect no errors
export GDS_FILE=inv1.gds
magic -noconsole -dnull run_drc.tcl | tee drc.log
if grep -q "error tiles" drc.log ; then
    echo "Found DRC errors, which was not expected :-("
    exit 1
else
    echo "Found no DRC errors, as expected :-)"
fi

# run DRC on a "bad" GDS: expect errors
export GDS_FILE=inv1_bad.gds
magic -noconsole -dnull run_drc.tcl | tee drc.log
if grep -q "error tiles" drc.log ; then
    echo "Found DRC errors, as expected :-)"
else
    echo "Found no DRC errors, which was not expected :-("
    exit 1
fi

# run LVS on a "good" GDS: expect no errors
echo "Running extraction for LVS and PEX"
export GDS_FILE=inv1.gds
export LVS_FILE=lvs.spice
export PEX_FILE=pex.spice
magic -noconsole -dnull run_ext.tcl
netgen -batch lvs "$LVS_FILE $CELL_NAME" "inv1.spice $CELL_NAME" $PDKPATH/libs.tech/netgen/sky130_setup.tcl | tee lvs.log
if grep -q "Netlists do not match" lvs.log ; then
    echo "Found LVS errors, which was not expected :-("
    exit 1
else
    echo "Found no LVS errors, as expected :-)"
fi

# run extraction on a "bad" GDS: expect errors
echo "Running extraction for LVS and PEX"
export GDS_FILE=inv1_bad.gds
export LVS_FILE=lvs_bad.spice
export PEX_FILE=pex_bad.spice
magic -noconsole -dnull run_ext.tcl
netgen -batch lvs "$LVS_FILE $CELL_NAME" "inv1.spice $CELL_NAME" $PDKPATH/libs.tech/netgen/sky130_setup.tcl | tee lvs.log
if grep -q "Netlists do not match" lvs.log ; then
    echo "Found LVS errors, as expected :-)"
else
    echo "Found no LVS errors, which was not expected :-("
    exit 1
fi

# run SPICE simulation
echo "Running SPICE simulation"
echo "* Inverter simulation" > pre.spice
echo ".lib \"$SKYWATER/libraries/sky130_fd_pr/latest/models/sky130.lib.spice\" tt" >> pre.spice
cat pre.spice pex.spice post.spice > sim.spice
ngspice -b sim.spice
