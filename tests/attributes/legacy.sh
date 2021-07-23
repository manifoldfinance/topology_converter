#!/usr/bin/env bash
set -e

cp ./examples/cldemo.dot topology.dot
sed -i '/^ "leaf01" \[function="leaf"/c\ "leaf01" \[function="leaf" legacy=True\]' topology.dot
cat topology.dot
python3 ./topology_converter.py topology.dot -p libvirt
leaf01Block=`sed -n '/DEFINE VM for leaf01/,/DEFINE VM for/p' < Vagrantfile`
if grep 'device.vm.hostname = "leaf01"' Vagrantfile; then
    exit 1
fi
