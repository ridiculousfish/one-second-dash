#!/bin/bash

# The WiFi SSID that your Dash will try to connect to 
SSID_NAME='Free Public WiFi'

# The channel of that SSID that Dash will try to connect to
# You can either choose this at network creation time,
# or determine it afterwards via tcpdump
CHANNEL=6

# The capability field of your WiFi dongle
# You can determine this via `iw phy`
CAP_FIELD="Capabilities: 0x172"

# cd to directory containing this script
cd $(dirname $(readlink -f $0))

# tcpdump or someone else eventually gives up
# and tears down our monitor interface. Loop to
# recreate it.
# The break allows us to control-C out of this loop.
while true; do
  sudo ./setup_monitor_interface.sh "$CHANNEL" "$CAP_FIELD" 2>&1
  sudo ./doorbell.py "$SSID_NAME" 2>&1 || break
done
