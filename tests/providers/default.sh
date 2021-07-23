#!/usr/bin/env bash
set -e

cp ./examples/cldemo.dot topology.dot
python3 ./topology_converter.py topology.dot
grep 'device.vm.provider "virtualbox"' Vagrantfile
