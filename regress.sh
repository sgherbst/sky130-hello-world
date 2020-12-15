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

# create directory for PDKPATH
mkdir PDKPATH
export PDKPATH=`realpath PDKPATH`

# install open_pdks
git clone https://github.com/RTimothyEdwards/open_pdks.git
cd open_pdks
./configure --with-sky130-source=`realpath ../skywater-pdk` --with-sky130-local-path=$PDKPATH
make
make install
