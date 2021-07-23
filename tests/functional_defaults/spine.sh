#!/usr/bin/env bash
set -e

cp ./examples/cldemo.dot topology.dot
sed -i '/^ "spine02" \[function="spine"/c\ "spine02" \[function="spine"\]' topology.dot
cat topology.dot
python3 ./topology_converter.py topology.dot -p libvirt
spineBlock=`sed -n '/DEFINE VM for spine02/,/DEFINE VM for/p' < Vagrantfile`
echo $spineBlock | grep 'device.vm.box = "CumulusCommunity/cumulus-vx"'
echo $spineBlock | grep 'v.memory = 768'
