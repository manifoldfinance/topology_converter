#!/usr/bin/env bash
set -e

cp ./examples/cldemo.dot topology.dot
python3 ./topology_converter.py topology.dot -p libvirt -g 100
if [ $(grep -c '8[01][0-9][0-9]' Vagrantfile) -ne 237 ]; then
    exit 1
fi
python3 ./topology_converter.py topology.dot -p libvirt --port-gap 100
if [ $(grep -c '8[01][0-9][0-9]' Vagrantfile) -ne 237 ]; then
    exit 1
fi
