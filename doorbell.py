#!/usr/bin/python
import os
import signal
import subprocess
import sys
import time

# Ignore SIGCHLD
# This will prevent zombies
signal.signal(signal.SIGCHLD, signal.SIG_IGN)

# After ringing, how many seconds before we allow ourselves to ring again
DEBOUNCE_INTERVAL = 7

# The token to look for in tcpdump's output
# This should be your unique network SSID
SSID_TOKEN = sys.argv[1] if len(sys.argv) > 1 else 'Free Public Wifi'

DEVNULL = open(os.devnull, 'wb')
def do_ring():
    """ Play the doorbell.wav file. Don't wait for it to finish. """
    cmd = 'alsaplayer -o alsa --quiet ./doorbell.wav'
    soundproc = subprocess.Popen(cmd.split(), close_fds=True,
                                 stdin=DEVNULL, stdout=DEVNULL, stderr=DEVNULL)

cmd = 'tcpdump -l -K -q -i DoorbellMonitor -n -s 256'
proc = subprocess.Popen(cmd.split(), close_fds=True,
                        bufsize=0, stdout=subprocess.PIPE)
last_played = 0
while True:
    line = proc.stdout.readline()
    if not line:
        print "tcpdump exited"
        break
    if SSID_TOKEN in line:
        now = time.time()
        if now - last_played > DEBOUNCE_INTERVAL:
            last_played = now
            sys.stdout.write(line)
            sys.stdout.flush()
            do_ring()
