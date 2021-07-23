#!/usr/bin/env bash
set -e

cp ./examples/cldemo.dot topology.dot
sed -i '/^ "spine01" \[function="superspine"/c\ "spine01" \[function="superspine"\]' topology.dot
cat topology.dot
python3 ./topology_converter.py topology.dot -p libvirt
superspineBlock=`sed -n '/DEFINE VM for spine01/,/DEFINE VM for/p' < Vagrantfile`
echo $superspineBlock | grep 'device.vm.box = "CumulusCommunity/cumulus-vx"'
echo $superspineBlock | grep 'v.memory = 768'
