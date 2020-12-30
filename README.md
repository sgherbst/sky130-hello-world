# sky130-hello-world
[![Actions Status](https://github.com/sgherbst/sky130-hello-world/workflows/Regression/badge.svg)](https://github.com/sgherbst/sky130-hello-world/actions)
[![License:Apache-2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) [![Join the chat at https://gitter.im/sgherbst/sky130-hello-world](https://badges.gitter.im/sgherbst/sky130-hello-world.svg)](https://gitter.im/sgherbst/sky130-hello-world?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

This repo contains a minimal example of LVS, DRC, PEX, and SPICE simulation in SKY130.  It has a self-checking regression that runs on a GitHub Actions Linux host, so the intent is that one should be able to follow along with the steps in ``.github/workflows/regression.yml``, ``install.sh``, and ``regress.sh`` to fully reproduce the functionality shown here.

The example is based around the minimum-size inverter from the SKY130 PDK.  DRC is run on the GDS for that inverter, and then it is extracted for LVS and PEX.  On the LVS front, the extracted SPICE netlist is compared to the netlist given in the PDK using ``netgen``.  On the PEX front, ``ngspice`` is used to run a transient simulation of the inverter with parasitic capacitances included.  The regression tests also include some tests to make sure that DRC and LVS errors can in fact be detected, using the intentionally broken file ``inv1_bad.gds``.

The full details for this example can always be found by examining the source code here, but the main functions are also summarized below.

## Installing dependencies

Certain dependencies need to be installed before moving on to the SKY130-specific tools.

```shell
sudo apt-get install m4 tcsh csh libx11-dev tcl-dev tk-dev libcairo2-dev libncurses-dev libglu1-mesa-dev freeglut3-dev mesa-common-dev ngspice
```

## Installing tools

This script walks through the installation of ``magic``, ``netgen``, ``skywater-pdk``, and ``open_pdks``.

```shell
# create directory to hold open-source PDKS
mkdir PDKS

# install magic
git clone https://github.com/RTimothyEdwards/magic.git
cd magic
git checkout magic-8.3
./configure
make
sudo make install
cd ..

# install netgen
git clone https://github.com/RTimothyEdwards/netgen.git
cd netgen
git checkout netgen-1.5
./configure
make
sudo make install
cd ..

# install skywater-pdk
git clone https://github.com/google/skywater-pdk
cd skywater-pdk
git submodule init libraries/sky130_fd_pr/latest
git submodule update
cd ..

# install open_pdks
git clone https://github.com/RTimothyEdwards/open_pdks.git
cd open_pdks
./configure --with-sky130-source=`realpath ../skywater-pdk` --with-sky130-local-path=`realpath ../PDKS`
make
make install
cd ..
```

In addition, the ``PDKPATH`` environment variable should be set to the absoute path of ``PDKS/sky130``, e.g.
```
export PDKPATH=`realpath PDKS/sky130`
```

## Running magic scripts

``magic`` can run TCL scripts (DRC, extraction, etc.) in a non-interactive fashion using the following command:

```shell
magic -noconsole -dnull script.tcl
```

Make sure that your scripts have ``quit`` at the end, to avoid ending up at an interactive prompt!

## Running DRC

The following ``magic`` TCL script reads in a GDS and counts up the number of DRC violations.  For some reason, the final line says that there are zero DRC errors, even if previous lines show errors.  Run this script using the ``magic`` command from the previous section.

```tcl
gds read path_to_gds_file
load name_of_top_cell
drc catchup
drc count
quit
```

## Running LVS

The following ``magic`` TCL script reads in a GDS and extracts it to an LVS-ready netlist.

```tcl
gds read path_to_gds_file
load name_of_top_cell
extract all
ext2spice lvs
ext2spice subcircuits off
ext2spice -o lvs_output_file
quit
```

## Running PEX

The following ``magic`` TCL script reads in a GDS and extracts it to an netlist for SPICE simulation.

```tcl
gds read path_to_gds_file
load name_of_top_cell
extract all
select top cell
port makeall
ext2spice lvs
ext2spice cthresh 0.01
ext2spice rthresh 0.01
ext2spice subcircuit on
ext2spice ngspice
ext2spice pex_output_file
quit
```

## Running LVS

LVS can be run to compare the design netlist with the extracted netlist using ``netgen``:

```shell
netgen -batch lvs "design_netlist design_top_cell" "ext_netlist ext_top_cell" $PDKPATH/libs.tech/netgen/sky130_setup.tcl
```

## Running SPICE simulations

SPICE simulations can be run without special options (e.g., ``ngspice myfile.spice``), but the following line should be placed near the top of the input file.

```spice
.lib "skywater-pdk/libraries/sky130_fd_pr/latest/models/sky130.lib.spice" tt
```

You'll probably need to make that an absolute path unless ``skywater-pdk`` happens to be in your current direction.  Also, remember that for ngspice, the very first line of the input file must be a comment!

## Acknowledgements
* SKY130 inverter example with a video
  * https://github.com/mattvenn/magic-inverter
* SKY130 chip example with DRC/LVS/PEX scripts
  * https://github.com/yrrapt/amsat_txrx_ic
* SkyWater Open Source PDK
  * https://github.com/google/skywater-pdk
  * https://github.com/RTimothyEdwards/open_pdks
* Open Circuit Design Tools
  * https://github.com/RTimothyEdwards/magic
  * https://github.com/RTimothyEdwards/netgen
