#! /bin/bash

virtualenv ~/virtspreads spreads

. ~/virtspreads/bin/activate

# Get newest pip version
wget https://raw.github.com/pypa/pip/develop/contrib/get-pip.py
python get-pip.py
pip --version

# Install pythonic dependencies
pip install cffi colorama futures flask flask-compress jpegtran-cffi netifaces\
requests waitress zipstream

# https://github.com/openxc/openxc-python/issues/18
pip install --pre pyusb

# Install spreads from GitHub
git clone https://github.com/jbaiter/spreads.git /tmp/spreads
cd /tmp/spreads
pip install -e .[web]
python setup.py install

# Install cython-hidapi from GitHub
pip install git+https://github.com/gbishop/cython-hidapi.git

# List all installed python module versions
pip freeze &>> $LOG
