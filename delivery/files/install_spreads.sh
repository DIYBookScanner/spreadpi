#! /bin/bash

virtualenv ~/virtspreads

. ~/virtspreads/bin/activate

# Get newest pip version
wget https://raw.github.com/pypa/pip/develop/contrib/get-pip.py
python get-pip.py
pip --version

# Install pythonic dependencies
# Installing cffi needs to happen first for some reason
pip install cffi
pip install colorama cython futures flask flask-compress jpegtran-cffi \
requests waitress zipstream

# netifaces needs these extra ones
pip install --allow-external netifaces --allow-unverified netifaces netifaces

# https://github.com/openxc/openxc-python/issues/18
pip install --pre pyusb

# Install spreads from GitHub
git clone https://github.com/jbaiter/spreads.git ~/virtspreads/src
cd ~/virtspreads/src
pip install -e .[web]
python setup.py install

# Install cython-hidapi from GitHub
pip install git+https://github.com/gbishop/cython-hidapi.git

# List all installed python module versions
pip freeze &>> $LOG
