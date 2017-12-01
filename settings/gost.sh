#!/bin/sh
PORT=`cat /home/nemo/.config/gost/gost.json |grep redire|awk -F ':' '{print $NF}'|awk -F '"' '{print $1}'`
DNSPORT=5353
SERVER=`cat /home/nemo/.config/gost/gost.json |grep ss|awk -F ':' '{print $3}'|awk -F '@' '{print $2}'`
PDNSDCFG=/etc/pdnsd.conf

if [ "$1" = "start" ] ;then
    #echo "Starting pdnsd"
    iptables -t nat -F
    iptables -t nat -X
    pkill pdnsd
    pdnsd -d -mto -c $PDNSDCFG
    iptables -t nat -A OUTPUT -p udp --dport 53 -j REDIRECT --to-ports $DNSPORT #redirect dns queries
    #echo "Setting iptables"

    iptables -t nat -N SHADOWSOCKS
    iptables -t nat -A SHADOWSOCKS -d $SERVER -j RETURN
    iptables -t nat -A SHADOWSOCKS -d 0.0.0.0/8 -j RETURN
    iptables -t nat -A SHADOWSOCKS -d 10.0.0.0/8 -j RETURN
    iptables -t nat -A SHADOWSOCKS -d 127.0.0.0/8 -j RETURN
    iptables -t nat -A SHADOWSOCKS -d 169.254.0.0/16 -j RETURN
    iptables -t nat -A SHADOWSOCKS -d 172.16.0.0/12 -j RETURN
    iptables -t nat -A SHADOWSOCKS -d 192.168.0.0/16 -j RETURN
    iptables -t nat -A SHADOWSOCKS -d 224.0.0.0/4 -j RETURN
    iptables -t nat -A SHADOWSOCKS -d 240.0.0.0/4 -j RETURN
    iptables -t nat -A SHADOWSOCKS -p tcp -j REDIRECT --to-ports $PORT 
    iptables -t nat -A OUTPUT -p tcp -j SHADOWSOCKS
    exit 0;
elif [ "$1" = "stop" ]; then
    pkill pdnsd
    iptables -t nat -F
    iptables -t nat -X
    exit 0;
else
    exit 1;
fi