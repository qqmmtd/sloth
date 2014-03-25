#! /bin/bash

WLAN0_GW=172.16.133.254
ETH0_GW=172.16.35.254

route add default gw $WLAN0_GW dev wlan0
route del default gw $ETH0_GW dev eth0

# white list for local servers
route add -net 172.16.11.0 netmask 255.255.255.0 gw $ETH0_GW dev eth0
route add -net 172.16.46.4 netmask 255.255.255.255 gw $ETH0_GW dev eth0
route add -net 172.24.61.0 netmask 255.255.255.0 gw $ETH0_GW dev eth0
#route add -net 172.24.63.184 netmask 255.255.255.255 gw $ETH0_GW dev eth0
route add -net 10.89.1.107 netmask 255.255.255.255 gw $ETH0_GW dev eth0

