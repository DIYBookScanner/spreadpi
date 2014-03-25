#! /bin/bash

# Using explicit /home/spreads references because of a bug in coreutils non-native architecture chroot handling
virtualenv /home/spreads/virtspreads

. /home/spreads/virtspreads/bin/activate

# Get newest pip version
cd /home/spreads/virtspreads
wget https://raw.github.com/pypa/pip/develop/contrib/get-pip.py
python get-pip.py
pip --version

# Install pythonic dependencies
# Installing cffi needs to happen first for some reason
pip install cffi
pip install colorama futures flask flask-compress hidapi-cffi \
jpegtran-cffi requests waitress zipstream

# netifaces needs these extra ones
pip install --allow-external netifaces --allow-unverified netifaces netifaces

# https://github.com/openxc/openxc-python/issues/18
pip install --pre pyusb

# Install spreads from GitHub
git clone https://github.com/DIYBookScanner/spreads.git ~/virtspreads/src
cd /home/spreads/virtspreads/src
pip install -e .[web]
python setup.py install


# List all installed python module versions
pip freeze
