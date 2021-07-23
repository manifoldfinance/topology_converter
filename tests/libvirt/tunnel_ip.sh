#!/usr/bin/env bash
set -e

cp ./examples/cldemo.dot topology.dot
python3 ./topology_converter.py topology.dot -p libvirt -i 10.20.30.40
if [ $(grep -c '10.20.30.40' Vagrantfile) -ne 237 ]; then
    exit 1
fi
python3 ./topology_converter.py topology.dot -p libvirt --tunnel-ip 10.20.30.40
if [ $(grep -c '10.20.30.40' Vagrantfile) -ne 237 ]; then
    exit 1
fi
