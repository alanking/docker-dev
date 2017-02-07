#!/bin/bash

## Iptables script for IRES in docker 

## set default policies to let everything in
iptables --policy INPUT   ACCEPT;
iptables --policy OUTPUT  ACCEPT;
iptables --policy FORWARD ACCEPT;

## start fresh
iptables -Z; # zero counters
iptables -F; # flush (delete) rules
iptables -X; # delete all extra chains

ICAT="$(getent hosts irods | cut -d' ' -f1)"
echo $ICAT
METALNX="$(getent hosts metalnx | cut -d' ' -f1)"
echo $METALNX

# Set the default policy of the OUTPUT chain to ACCEPT
iptables -P OUTPUT ACCEPT

# Allow loopback access
iptables -A INPUT -i lo -j ACCEPT

#Allow icmp
iptables -A INPUT -p icmp -j ACCEPT

# Allow RELATED,ESTABLISHED on INPUT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

#allow SSH from anywhere
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

#Allow access on port 8000 from metalnx
iptables -A INPUT -p tcp --dport 8000 -s $METALNX -j ACCEPT

#Allow access on port 1247 and 1248 from ICAT
iptables -A INPUT -p tcp --dport 1247 -s $ICAT -j ACCEPT
iptables -A INPUT -p tcp --dport 1248 -s $ICAT -j ACCEPT

# Set the default policy of the INPUT chain to DROP
iptables -A INPUT -j DROP

# 25. Log dropped packets
#iptables -N LOGGING
#iptables -A INPUT -j LOGGING
#iptables -A LOGGING -m limit --limit 2/min -j LOG --log-prefix "IPTables Packet Dropped: " --log-level 7
#iptables -A LOGGING -j DROP



