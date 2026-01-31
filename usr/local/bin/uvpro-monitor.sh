#!/bin/bash
#MAC="00:00:00:00:00:00"
MAC=$(bluetoothctl devices | grep -i "UV-PRO" | awk '{print $2}')

CONNECTED=$(bluetoothctl info $MAC | grep "Connected: yes")

if [ -n "$CONNECTED" ]; then

    # If rfcomm0 does not exist, create it
    if [ ! -e /dev/rfcomm0 ]; then
        /usr/bin/rfcomm connect 0 $MAC 1 &
        sleep 1
    fi

    # Only attach AX.25 if not already attached
    if [ -e /dev/rfcomm0 ] && ! ip link show ax0 >/dev/null 2>&1; then
        /usr/sbin/kissattach /dev/rfcomm0 1
        /usr/sbin/kissparms -p 1 -t 200 -s 10 -r 10
    fi

else
    # Clean shutdown
    #if ip link show ax0 >/dev/null 2>&1; then
        killall kissattach 2>/dev/null
        sleep 1
    #fi

    /usr/bin/rfcomm release 0 2>/dev/null
fi

