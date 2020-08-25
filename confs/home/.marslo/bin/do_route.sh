#!/bin/bash
#
# =============================================================================
#    FileName: do_route.sh
#      Author: marslo
#       Email: marslo.jiao@gmail.com
#     Created: 2018-01-18 11:46:51
#  LastChange: 2018-01-18 11:52:10
# =============================================================================

INTRANETROUTE="130.147.181.1"

sudo route -nv add -host 161.92.35.78     ${INTRANETROUTE}
sudo route -vn add -host 130.147.236.5    ${INTRANETROUTE}
sudo route -vn add -host 180.166.223.109  ${INTRANETROUTE}
sudo route -vn add -host 161.92.35.82     ${INTRANETROUTE}

# Proxy
sudo route -vn add -host 180.166.223.109  ${INTRANETROUTE}
sudo route -vn add -host 140.207.91.234   ${INTRANETROUTE}
sudo route -vn add -host 42.99.164.34     ${INTRANETROUTE}
sudo route -vn add -host 185.46.212.34    ${INTRANETROUTE}

# subnet
sudo route -nv add -net 130.145/16        ${INTRANETROUTE}
sudo route -nv add -net 130.147/16        ${INTRANETROUTE}
sudo route -nv add -net 161.85/16         ${INTRANETROUTE}

sudo route -nv add -net 130.139/16        ${INTRANETROUTE}
sudo route -nv add -net 130.140/16        ${INTRANETROUTE}
sudo route -nv add -net 130.146/16        ${INTRANETROUTE}
sudo route -nv add -net 130.138/15        ${INTRANETROUTE}
sudo route -nv add -net 130.140/14        ${INTRANETROUTE}

sudo route -nv add -net 137.55/16         ${INTRANETROUTE}
sudo route -nv add -net 161.83/16         ${INTRANETROUTE}
sudo route -nv add -net 161.84/16         ${INTRANETROUTE}
sudo route -nv add -net 161.88/16         ${INTRANETROUTE}
sudo route -nv add -net 161.91/16         ${INTRANETROUTE}
sudo route -nv add -net 161.92/16         ${INTRANETROUTE}
sudo route -nv add -net 185.166/16        ${INTRANETROUTE}
