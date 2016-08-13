#!/bin/bash

# This script sets up the monitor interface

# Exit on error
set -e
set -x

if [[ $# -ne 2 ]]; then
   progname=$(basename $0)
   echo "Usage: $progname <channel> <cap_field>"
fi

CHANNEL=$1
CAP_FIELD=$2

PHYIDX=""
for IDX in $(seq 10); do
  if iw phy phy$IDX info | grep -q "$CAP_FIELD" 2>/dev/null; then
    PHYIDX=$IDX
    break
  fi
done

if test -z "$PHYIDX" ; then
  echo "Unable to find phy with $CAP_FIELD"
  exit 1
fi

# Delete wlan interface if it exists
# Assume it's same index as phy
iw dev | grep -q "wlan$PHYIDX" && \
  sudo iw dev wlan$PHYIDX del

# Add monitor, bring it up, set its channel
MONITOR_NAME=DoorbellMonitor
sudo iw dev $MONITOR_NAME del 2>/dev/null || true
sudo iw phy phy$PHYIDX interface add $MONITOR_NAME type monitor

sudo ifconfig $MONITOR_NAME up
sudo iw dev $MONITOR_NAME set channel $CHANNEL
