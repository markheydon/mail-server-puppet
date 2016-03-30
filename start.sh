#!/bin/sh
./install_puppet.sh

/usr/bin/git submodule update --init --recursive

./run_puppet.sh
./run_puppet.sh
