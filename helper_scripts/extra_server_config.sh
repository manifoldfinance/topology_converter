#!/bin/bash

echo "#################################"
echo "  Running Extra_Server_Config.sh"
echo "#################################"

# cosmetic fix for dpkg-reconfigure: unable to re-open stdin: No file or directory during vagrant up
export DEBIAN_FRONTEND=noninteractive

sudo su

useradd cumulus -m -s /bin/bash
echo "cumulus:CumulusLinux!" | chpasswd
usermod -aG sudo cumulus
echo -e "cumulus ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/20_cumulus

SSH_URL="http://192.168.200.254/authorized_keys"
#Setup SSH key authentication for Ansible
mkdir -p /home/cumulus/.ssh
wget -O /home/cumulus/.ssh/authorized_keys $SSH_URL

#Test for Debian-Based Host
which apt &> /dev/null
if [ "$?" == "0" ]; then
    #These lines will be used when booting on a debian-based box
    echo -e "note: ubuntu device detected"
    #Install LLDP
    apt-get update -qy && apt-get install lldpd -qy
    echo "configure lldp portidsubtype ifname" > /etc/lldpd.d/port_info.conf

    #Replace existing network interfaces file
    echo -e "auto lo" > /etc/network/interfaces
    echo -e "iface lo inet loopback\n\n" >> /etc/network/interfaces
    echo -e  "source /etc/network/interfaces.d/*.cfg\n" >> /etc/network/interfaces

    #Add vagrant interface
    echo -e "\n\nauto vagrant" > /etc/network/interfaces.d/vagrant.cfg
    echo -e "iface vagrant inet dhcp\n\n" >> /etc/network/interfaces.d/vagrant.cfg

    echo -e "\n\nauto eth0" > /etc/network/interfaces.d/eth0.cfg
    echo -e "iface eth0 inet dhcp\n\n" >> /etc/network/interfaces.d/eth0.cfg

    echo "retry 1;" >> /etc/dhcp/dhclient.conf
    echo "timeout 600;" >> /etc/dhcp/dhclient.conf
fi

#Test for Fedora-Based Host
which yum &> /dev/null
if [ "$?" == "0" ]; then
    echo -e "note: fedora-based device detected"
    /usr/bin/dnf install python -y
    echo -e "DEVICE=vagrant\nBOOTPROTO=dhcp\nONBOOT=yes" > /etc/sysconfig/network-scripts/ifcfg-vagrant
    echo -e "DEVICE=eth0\nBOOTPROTO=dhcp\nONBOOT=yes" > /etc/sysconfig/network-scripts/ifcfg-eth0
fi


echo "#################################"
echo "   Finished"
echo "#################################"
