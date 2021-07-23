#!/usr/bin/env bash
set -e

cp ./examples/cldemo.dot topology.dot
python3 ./topology_converter.py topology.dot -p libvirt -s 30000
if [ $(grep -c '3[01]0[0-9][0-9]' Vagrantfile) -ne 238 ]; then
    exit 1
fi
python3 ./topology_converter.py topology.dot -p libvirt --start-port 30000
if [ $(grep -c '3[01]0[0-9][0-9]' Vagrantfile) -ne 238 ]; then
    exit 1
fi
