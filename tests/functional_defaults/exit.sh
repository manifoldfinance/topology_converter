#!/usr/bin/env bash
set -e

cp ./examples/cldemo.dot topology.dot
sed -i '/^ "exit01" \[function="exit"/c\ "exit01" \[function="exit"\]' topology.dot
cat topology.dot
python3 ./topology_converter.py topology.dot -p libvirt
exitBlock=`sed -n '/DEFINE VM for exit01/,/DEFINE VM for/p' < Vagrantfile`
echo $exitBlock | grep 'device.vm.box = "CumulusCommunity/cumulus-vx"'
echo $exitBlock | grep 'v.memory = 768'
