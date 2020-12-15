# run DRC
magic -rcfile $PDKPATH/libs.tech/magic/sky130A.magicrc -noconsole -dnull run_drc.tcl

# run extraction
magic -rcfile $PDKPATH/libs.tech/magic/sky130A.magicrc -noconsole -dnull run_ext.tcl

# run LVS
netgen -batch lvs "lvs.spice sky130_fd_sc_hd__inv_1" "inv1.spice sky130_fd_sc_hd__inv_1" $PDKPATH/libs.tech/netgen/sky130A_setup.tcl
