#!/usr/bin/env bash
# =============================================================================
#    FileName: removeRoute.sh
#      Author: marslo.jiao@gmail.com
#     Created: 2018-01-22 14:34:19
#  LastChange: 2020-10-20 22:51:54
# =============================================================================

ETHERNETDEVICE=$(networksetup -listallhardwareports | awk '/Hardware Port: USB 10\/100\/1000 LAN/{getline; print $2}')
[ -z ${ETHERNETDEVICE} ] && ETHERNETDEVICE="en7"

if ! ifconfig ${ETHERNETDEVICE} | grep inet > /dev/null 2>&1; then
  echo 'ethernet is off!'
fi

DEFAULTDNS=$(echo "show State:/Network/Service/7DAF738F-85BF-417F-B548-462D38CE1AE0/DNS" | scutil | /usr/local/bin/sed -nre 's:^\s+[0-9]+\s+\:\s*(.*$):\1:p' | /usr/local/bin/awk '{print}' ORS=' ')

GATEWAYLIST="130.147.236.5 130.147.159.139 161.92.35.82 161.92.35.78"
for gwlist in ${GATEWAYLIST}; do
  sudo route -qn delete -host "${gwlist}"
done

FUNCTIONSITELIST="10.65.8.149 10.65.9.136 104.146.30.8 10.65.192.85 10.64.115.137 52.76.131.156 149.96.49.207 149.96.65.207 172.227.96.240 10.65.192.35 40.108.231.53 37.0.1.34"
for fslist in ${FUNCTIONSITELIST}; do
  sudo route -qn delete -host "${fslist}"
done

PROXYLIST="180.166.223.109 140.207.91.234 42.99.164.34 185.46.212.34"
for pl in ${PROXYLIST}; do
  sudo route -qn delete -host "${pl}"
done

SUBNETLIST="130.145/16 130.147/16 161.85/16 161.92/16 130.139/16 130.140/16 130.144/16 130.146/16 130.138/15 130.140/14 137.55/16 161.83/16 161.84/16 161.88/16 161.91/16 185.166/16"
for snl in ${SUBNETLIST}; do
  sudo route -qn delete -net "${snl}"
done

networksetup -setdnsservers Wi-Fi empty
networksetup -setsearchdomains Wi-Fi empty
sudo killall -HUP mDNSResponder
sudo killall mDNSResponderHelper
sudo dscacheutil -flushcache
say cache flushed

for ddns in ${DEFAULTDNS}; do
  sudo bash -c "echo \"nameserver ${ddns}\" >> /etc/resolv.conf"
done
