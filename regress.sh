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

