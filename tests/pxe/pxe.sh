#!/usr/bin/env bash
set -e

cp ./examples/cldemo.dot topology.dot
sed -i 's/"edge01" \[/"edge01" \[pxehost="True" /' topology.dot
sed -i 's/"edge01":"eth1" -- "exit01":"swp1"/"edge01":"eth1" -- "exit01":"swp1" \[left_pxebootinterface="True"\]/' topology.dot
cat topology.dot
python3 ./topology_converter.py topology.dot
edge01Block=`sed -n '/DEFINE VM for edge01/,/DEFINE VM for/p' < Vagrantfile`
echo $edge01Block | grep 'Setup Interfaces for PXEBOOT'
