#!/usr/bin/env bash
set -e

cp ./examples/cldemo.dot topology.dot
python3 ./topology_converter.py topology.dot -p libvirt
grep 'device.vm.provider :libvirt' Vagrantfile
python3 ./topology_converter.py topology.dot --provider libvirt
grep 'device.vm.provider :libvirt' Vagrantfile
