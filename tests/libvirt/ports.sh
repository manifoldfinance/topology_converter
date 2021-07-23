#!/usr/bin/env bash
set -e

cp ./examples/cldemo.dot topology.dot
sed -i 's/"leaf01" \[/"leaf01" \[ports=32 /' topology.dot
cat topology.dot
python3 ./topology_converter.py topology.dot -p libvirt
leaf01Block=`sed -n '/DEFINE VM for leaf01/,/DEFINE VM for/p' < Vagrantfile`
echo $leaf01Block | grep "swp1"
echo $leaf01Block | grep "swp2"
echo $leaf01Block | grep "swp3"
echo $leaf01Block | grep "swp4"
echo $leaf01Block | grep "swp5"
echo $leaf01Block | grep "swp6"
echo $leaf01Block | grep "swp7"
echo $leaf01Block | grep "swp8"
echo $leaf01Block | grep "swp9"
echo $leaf01Block | grep "swp10"
echo $leaf01Block | grep "swp11"
echo $leaf01Block | grep "swp12"
echo $leaf01Block | grep "swp13"
echo $leaf01Block | grep "swp14"
echo $leaf01Block | grep "swp15"
echo $leaf01Block | grep "swp16"
echo $leaf01Block | grep "swp17"
echo $leaf01Block | grep "swp18"
echo $leaf01Block | grep "swp19"
echo $leaf01Block | grep "swp20"
echo $leaf01Block | grep "swp21"
echo $leaf01Block | grep "swp22"
echo $leaf01Block | grep "swp23"
echo $leaf01Block | grep "swp24"
echo $leaf01Block | grep "swp25"
echo $leaf01Block | grep "swp26"
echo $leaf01Block | grep "swp27"
echo $leaf01Block | grep "swp28"
echo $leaf01Block | grep "swp29"
echo $leaf01Block | grep "swp30"
echo $leaf01Block | grep "swp31"
echo $leaf01Block | grep "swp32"
