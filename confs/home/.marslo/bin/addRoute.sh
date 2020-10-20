#!/bin/bash
#
# =============================================================================
#    FileName: addRoute.sh
#      Author: marslo.jiao@gmail.com
#        Desc: Setup dual-network card for both public and PGN network
#     Created: 2017-11-11 10:17:22
#  LastChange: 2018-08-22 14:11:00
# =============================================================================

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
INTRANETROUTE="130.147.182.1"
INTRANETDNS="130.147.236.5 130.147.159.139 161.92.35.78"
INTRANETSEARCHDOMMAIN="cn-132.lan.mycompany.com CODE1.EMI.mycompany.COM"

DEFAULTDNS=$(echo "show State:/Network/Service/7DAF738F-85BF-417F-B548-462D38CE1AE0/DNS" | scutil | /usr/local/bin/sed -nre 's:^\s+[0-9]+\s+\:\s*(.*$):\1:p' | /usr/local/bin/awk '{print}' ORS=' ')

WIFIDEVICE=$(networksetup -listallhardwareports | awk '/Hardware Port: Wi-Fi/{getline; print $2}')
[ -z $WIFIDEVICE ] && WIFIDEVICE="en0"
LOGFILE="$HOME/${WIFIDEVICE}-NETWORK"
# ETHERNETDEVICE=$(networksetup -listallhardwareports | awk '/Hardware Port: AX88x72A/{getline; print $2}')
ETHERNETDEVICE=$(networksetup -listallhardwareports | awk '/Hardware Port: USB 10\/100\/1000 LAN/{getline; print $2}')
[ -z ${ETHERNETDEVICE} ] && ETHERNETDEVICE="en7"

echo -e """
${TIMESTAMP}:
>==== START ADDR =====<
DNS: ${INTRANETROUTE} ${DEFAULTDNS}""" >> ${LOGFILE}
networksetup -getairportpower ${WIFIDEVICE} | grep -E "Wi-Fi.*${WIFIDEVICE}.*On" >> ${LOGFILE}

# sudo route delete default ${INTRANETROUTE}
# only one network card. exit
if [ 1 -eq $(ip -4 a | grep -v lo0 | grep -c flags) ]; then
  echo "ONLY one alive network card. Exit" >> ${LOGFILE}
  exit 0
# no ethernet connected. exit
elif ! ifconfig ${ETHERNETDEVICE} | grep inet > /dev/null 2>&1; then
  echo "Ethernet card cannot be off. Exit" >> ${LOGFILE}
  exit 1
else
  # if networksetup -getairportnetwork ${WIFIDEVICE} | grep -i mercury > /dev/null 2>&1; then
    # security unlock-keychain -p Marsl0 login.keychain
    # networksetup -setairportnetwork ${WIFIDEVICE} MERCURY_07FA
    # networksetup -getairportnetwork ${WIFIDEVICE} >> ${LOGFILE}
  # fi

  GATEWAYLIST="130.147.236.5 130.147.159.139 161.92.35.82 161.92.35.78"
  for gwlist in ${GATEWAYLIST}; do
    sudo route -q -n add -host ${gwlist} ${INTRANETROUTE}
  done

  FUNCTIONSITELIST="10.65.8.149 10.65.9.136 104.146.30.8 10.65.192.85 10.64.115.137 52.76.131.156 149.96.49.207 149.96.65.207 172.227.96.240 10.65.192.35 40.108.231.53 37.0.1.34"
  for fslist in ${FUNCTIONSITELIST}; do
    sudo route -q -n add -host "${fslist}" ${INTRANETROUTE}
  done

  PROXYLIST="180.166.223.109 140.207.91.234 42.99.164.34 185.46.212.34"
  for pl in ${PROXYLIST}; do
    sudo route -q -n add -host "${pl}" ${INTRANETROUTE}
  done

  SUBNETLIST="130.145/16 130.147/16 161.85/16 161.92/16 130.139/16 130.140/16 130.144/16 130.146/16 130.138/15 130.140/14 137.55/16 161.83/16 161.84/16 161.88/16 161.91/16 185.166/16"
  for snl in ${SUBNETLIST}; do
    sudo route -q -n add -net "${snl}" ${INTRANETROUTE}
  done

  networksetup -setdnsservers Wi-Fi ${INTRANETDNS} ${DEFAULTDNS}
  networksetup -setsearchdomains Wi-Fi ${INTRANETSEARCHDOMMAIN}
  # networksetup -setdnsservers Wi-Fi 130.147.236.5 161.92.35.78 119.6.6.6 223.6.6.6 61.139.2.69 218.6.200.139

  sudo rename s:latest.:: /etc/resolv.conf.latest.* | echo "done"
  sudo mv /etc/resolv.conf{,.latest."$(date +"%Y%m%d%H%M%S")"}
  for dnslist in ${INTRANETDNS} ${DEFAULTDNS}; do
    sudo bash -c "echo \"nameserver ${dnslist}\" >> /etc/resolv.conf"
  done

  for domainlist in ${INTRANETSEARCHDOMMAIN}; do
    sudo bash -c "echo \"search ${domainlist}\" >> /etc/resolv.conf"
  done

    echo -e ">=== FINISHED ADDR ===<" >> ${LOGFILE}
fi
