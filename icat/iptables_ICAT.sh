#!/bin/bash

## Iptables script for ICAT in docker 

## set default policies to let everything in
iptables --policy INPUT   ACCEPT;
iptables --policy OUTPUT  ACCEPT;
iptables --policy FORWARD ACCEPT;

## start fresh
iptables -Z; # zero counters
iptables -F; # flush (delete) rules
iptables -X; # delete all extra chains

PACMAN="$(getent hosts pacman | cut -d' ' -f1)"
echo $PACMAN
FRONTEND="$(getent hosts irods-frontend | cut -d' ' -f1)"
echo $FRONTEND
IRES="$(getent hosts ires | cut -d' ' -f1)"
echo $IRES

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

#Allow access on port 1247 from  pacman
iptables -A INPUT -p tcp --dport 1247 -s $PACMAN -j ACCEPT

#Allow access on port 1247 from irods-frontend
iptables -A INPUT -p tcp --dport 1247 -s $FRONTEND -j ACCEPT

#Allow access on port 1247 and 1248 from ires
iptables -A INPUT -p tcp --dport 1247 -s $IRES -j ACCEPT
iptables -A INPUT -p tcp --dport 1248 -s $IRES -j ACCEPT

# Set the default policy of the INPUT chain to DROP
iptables -A INPUT -j DROP

# 25. Log dropped packets
#iptables -N LOGGING
#iptables -A INPUT -j LOGGING
#iptables -A LOGGING -m limit --limit 2/min -j LOG --log-prefix "IPTables Packet Dropped: " --log-level 7
#iptables -A LOGGING -j DROP



