#!/bin/bash

echo "#################################"
echo "  Running Extra_Switch_Config.sh"
echo "#################################"
sudo su

echo "retry 1;" >> /etc/dhcp/dhclient.conf
echo "timeout 600;" >> /etc/dhcp/dhclient.conf

cat <<EOT > /etc/network/interfaces
auto lo
iface lo inet loopback

auto vagrant
iface vagrant inet dhcp

auto eth0
iface eth0 inet dhcp

EOT

#add line to support bonding inside virtualbox VMs
#sed -i '/.*iface swp.*/a\    #required for traffic to flow on Bonds in Vbox VMs\n    post-up ip link set $IFACE promisc on' /etc/network/interfaces

# Uncomment to unexpire and change the default cumulus user password
# passwd -x 99999 cumulus
# echo 'cumulus:CumulusLinux!' | chpasswd

# Uncomment to give cumulus user passwordless sudo
# echo "cumulus ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/10_cumulus

echo "#################################"
echo "   Finished"
echo "#################################"
