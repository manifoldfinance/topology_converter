#!/usr/bin/env bash
set -e

cp ./examples/cldemo.dot topology.dot
sed -i '/^ "oob-mgmt-switch" \[function="oob-switch"/c\ "oob-mgmt-switch" \[function="oob-switch"\]' topology.dot
cat topology.dot
python3 ./topology_converter.py topology.dot -p libvirt
oobmgmtswitchBlock=`sed -n '/DEFINE VM for oob-mgmt-switch/,/DEFINE VM for/p' < Vagrantfile`
echo $oobmgmtswitchBlock | grep 'device.vm.box = "CumulusCommunity/cumulus-vx"'
echo $oobmgmtswitchBlock | grep 'v.memory = 768'
