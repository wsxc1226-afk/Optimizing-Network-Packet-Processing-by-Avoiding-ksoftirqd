#!/bin/bash

# Clear existing rules
iptables -F

# Allow incoming TCP traffic

iptables -P INPUT  ACCEPT
iptables -P FOWARD ACCEPT

#iptables -P INPUT DROP
#iptables -P OUTPUT DROP
# Allow outgoing TCP traffic
iptables -P OUTPUT ACCEPT

#iptables -A INPUT -p tcp --tcp-flags RST RST -j DROP
#iptables -A OUTPUT -p tcp --tcp-flags RST RST -j DROP

#iptables -A INPUT -p tcp -j ACCEPT


# Display the updated rules
iptables -L

# Save the rules to persist across reboots
#iptables-save > /etc/iptables.rules
