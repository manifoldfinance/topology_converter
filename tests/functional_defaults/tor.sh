#!/usr/bin/env bash
set -e

cp ./examples/cldemo.dot topology.dot
sed -i '/^ "leaf02" \[function="tor"/c\ "leaf02" \[function="tor"\]' topology.dot
cat topology.dot
python3 ./topology_converter.py topology.dot -p libvirt
torBlock=`sed -n '/DEFINE VM for leaf02/,/DEFINE VM for/p' < Vagrantfile`
echo $torBlock | grep 'device.vm.box = "CumulusCommunity/cumulus-vx"'
echo $torBlock | grep 'v.memory = 768'
