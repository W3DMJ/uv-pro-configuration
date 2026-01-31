# This module queries the MAC address from the BTECH UV-PRO using the bluetoothctl call.
MAC=$(bluetoothctl devices | grep -i "UV-PRO" | awk '{print $2}')

# Obtain the connection status using the same bluetoothctl call.
CONNECTED=$(bluetoothctl info $MAC | grep "Connected: yes")

# If CONNECTED and /dev/rfcomm0 does not already exist call rfcomm 
# to create the bluetooth serial connection

if [ -n "$CONNECTED" ]; then

    # If rfcomm0 does not exist, create it
    if [ ! -e /dev/rfcomm0 ]; then
        /usr/bin/rfcomm connect 0 $MAC 1 &
        sleep 1
    fi

# If /dev/rfcomm0 exists and ax0 does not exist call kissattach to associate 
# /dev/rfcomm0 with the wl2k port defined in /etc/ax25/ports

    # Only attach AX.25 if not already attached
    if [ -e /dev/rfcomm0 ] && ! ip link show ax0 >/dev/null 2>&1; then
        /usr/sbin/kissattach /dev/rfcomm0 1
        /usr/sbin/kissparms -p 1 -t 200 -s 10 -r 10
    fi

else

# If no longer CONNECTED and ax0 exists the a call to killall kissattach 
# is made to terminate the map of /dev/rfcomm0 

    # Clean shutdown
    #if ip link show ax0 >/dev/null 2>&1; then
        killall kissattach 2>/dev/null
        sleep 1
    #fi

# Once kissattach is terminated it is now time to release the /dev/rfcomm0 
# bluetooth serial port

    /usr/bin/rfcomm release 0 2>/dev/null
fi
