#!/bin/bash

ip addr

read -p "Which network interface? " ifcfg
read -p "New IP Address? " ip
read -p "New Subnet Mask? (CIDR Notation - No slash) " subnet
read -p "Gateway IP? " gateway
read -p "First DNS Server IP? " dns1
read -p "Second DNS Server IP? " dns2

cat > /etc/sysconfig/network-scripts/ifcfg-$ifcfg << EOF
TYPE=Ethernet
BOOTPROTO=none
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
NAME=$ifcfg
UUID=
DEVICE=$ifcfg
ONBOOT=yes
IPADDR=$ip
PREFIX=$subnet
GATEWAY=$gateway
DNS1=$dns1
DNS2=$dns2
IPV6_PEERDNS=yes
IPV6_PEERROUTES=yes
EOF

systemctl restart network.service