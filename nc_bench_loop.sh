#!/bin/bash

#########################################################################################
# DESC: docker entry point
#########################################################################################
# Copyright (c) Chris Ruettimann <chris@bitbull.ch>

# This software is licensed to you under the GNU General Public License.
# There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/gpl.txt

# HOW IT WORKS:
# 1) parse ENV
# 2) create benchmark vars
# 3) loop the benchmark
#
# INSTALL:
#   https://github.com/joe-speedboat/docker.nextcloud_benchmark

set -o pipefail

set +e

# Script trace mode
if [ "${DEBUG_MODE,,}" == "true" ]; then
    set -o xtrace
fi

NC_BENCH_CONF=/tmp/nc_benchmark.conf
NC_BENCH_SCRIPT=/usr/bin/nc_benchmark.sh

# picks a random value from $1 range, eg: IN=1-100 OUT=55
# if no range is given, it returns the IN value
range_handler() {
   IN="$1"
   echo "$1" | grep -q -- '.-.' 
   if [ $? -eq 0 ]
   then
      shuf -i $IN -n1
   elif [ "$IN" != "x" ]
   then
      echo $IN
   fi
}

echo "
      ####################### DOCKER ENV INPUT VARS #############
      NC_FQDN=$NC_FQDN
      NC_USER=$NC_USER
      NC_PASS=$NC_PASS
      BENCH_COUNT=$BENCH_COUNT
      TEST_BLOCK_SIZE_MB=$TEST_BLOCK_SIZE_MB
      TEST_FILES_COUNT=$TEST_FILES_COUNT
      SPEED_LIMIT_UP_MBIT=$SPEED_LIMIT_UP_MBIT
      SPEED_LIMIT_DOWN_MBIT=$SPEED_LIMIT_DOWN_MBIT
      ###########################################################
"

BENCH_RUN=0
BENCH_COUNT="${BENCH_COUNT:=0}"
while true
do
   # loop forever if BENCH_COUNT=0
   if [ $BENCH_COUNT -ne 0 ]
   then
      BENCH_RUN=$(($BENCH_RUN+1))
      [ $BENCH_RUN -gt $BENCH_COUNT ] && break
   fi

   # pick random values from ranges given as arguements, if needed
   echo "      ###########################################################"
   TEST_BLOCK_SIZE_MB_PICK=$(range_handler $TEST_BLOCK_SIZE_MB)   ; echo "      TEST_BLOCK_SIZE_MB_PICK=$TEST_BLOCK_SIZE_MB_PICK"
   TEST_FILES_COUNT_PICK=$(range_handler $TEST_FILES_COUNT)       ; echo "      TEST_FILES_COUNT_PICK=$TEST_FILES_COUNT_PICK"
   SPEED_LIMIT_UP_MBIT_PICK=$(range_handler $SPEED_LIMIT_UP_MBIT)     ; echo "      SPEED_LIMIT_UP_MBIT_PICK=$SPEED_LIMIT_UP_MBIT_PICK"
   SPEED_LIMIT_DOWN_MBIT_PICK=$(range_handler $SPEED_LIMIT_DOWN_MBIT) ; echo "      SPEED_LIMIT_DOWN_MBIT_PICK=$SPEED_LIMIT_DOWN_MBIT_PICK"
   echo "      ###########################################################"

   # speed limit is kind of crapy
   SPEED_LIMIT_UP="${SPEED_LIMIT_UP_MBIT_PICK:=$(shuf -i 10-100 -n1)}"
   SPEED_LIMIT_UP=$(( $SPEED_LIMIT_UP * 1024 / 8 )) # make kbyte, accepted by curl
   
   SPEED_LIMIT_DOWN="${SPEED_LIMIT_DOWN_MBIT_PICK:=$(shuf -i 10-100 -n1)}"
   SPEED_LIMIT_DOWN=$(( $SPEED_LIMIT_DOWN * 1024 / 8 )) # make kbyte, accepted by curl
   
# create benchmark config for this run
echo "
CLOUD=\"${NC_FQDN}\"
USR=\"${NC_USER}\"
PW=\"${NC_PASS}\"
BENCH_COUNT=\"${BENCH_COUNT}\"
TEST_BLOCK_SIZE_MB=\"{TEST_BLOCK_SIZE_MB_PICK:=$(shuf -i 10-1024 -n1)}\"
TEST_FILES_COUNT=\"${TEST_FILES_COUNT_PICK:=$(shuf -i 10-200 -n1)}\"
SPEED_LIMIT_UP=\"${SPEED_LIMIT_UP}K\"
SPEED_LIMIT_DOWN=\"${SPEED_LIMIT_DOWN}K\"
LOCAL_DIR=/tmp
BENCH_DIR=\"$(curl ifconfig.me 2>/dev/null | tr '.' '_')_$HOSTNAME\"
" > $NC_BENCH_CONF

   echo "      ####################### STARTING: $BENCH_RUN ######################"
   cat $NC_BENCH_CONF | sed 's/^/      /'
   echo "      #########################################################"
   echo "INFO: Testing connectivity: https://$NC_FQDN "
   curl -k -s -L https://$NC_FQDN 2>&1 >/dev/null 
   if [ $? -eq 0 ]
   then
     $NC_BENCH_SCRIPT $NC_BENCH_CONF || true
   else
     echo "ERROR: I CANT REACH THIS NEXTCLOUD, SO I WAIT A MOMENT"
   fi   
   SLEEP=$(shuf -i 5-15 -n1)
   echo SLEEPING $SLEEP seconds
   sleep $SLEEP
done

echo "INFO: BENCH_RUN has reached $BENCH_COUNT, all the work is done. BYE :-)"



