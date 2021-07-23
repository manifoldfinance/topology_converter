#!/usr/bin/env bash
set -e

cp ./examples/cldemo.dot topology.dot
python3 ./topology_converter.py topology.dot -p virtualbox
grep 'device.vm.provider "virtualbox"' Vagrantfile
python3 ./topology_converter.py topology.dot --provider virtualbox
grep 'device.vm.provider "virtualbox"' Vagrantfile
