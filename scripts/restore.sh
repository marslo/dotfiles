#!/bin/bash

fileList="../Configs/HOME/.marslo/.devops/.settings \
  ../Configs/HOME/.marslo/.mac/.mymac_public \
  ../Configs/SSH/config.bak.20170810 \
  ../Configs/SSH/config.bak.20170908 \
  ../Configs/SSH/config \
  ../Configs/HOME/.marslo/.cygwin_marslo \
  ../Configs/HOME/.marslo/.bello_mac \
  "

for i in ${fileList}; do
  sed -re "s:phcompany:philips:g" -i $i
  sed -re "s:PHCOMPANY:PHILIPS:g" -i $i
  sed -re "s:mysite:cdi:g" -i $i
  sed -re "s:pwww:pww:g" -i $i
done
