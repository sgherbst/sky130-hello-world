# install magic
git clone https://github.com/RTimothyEdwards/magic.git
git checkout magic-8.3
./configure
make
sudo make install

# install netgen
git clone https://github.com/RTimothyEdwards/netgen.git
git checkout netgen-1.5
./configure
make
sudo make install
