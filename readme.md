#!/bin/bash

# Input parameter is equal to which axports port you want to use. If none is provided then 1 is used which is wl2k
AXPORT="$1"

# Detect connected bluetooth radio if any and store the MAC address
MAC=$(bluetoothctl devices | grep -i "UV-PRO" | awk '{print $2}')
if [[ -n "$MAC" ]]; then 
    echo "Found UV-PRO: $MAC" 
fi

# Determine if the radio is connected
CONNECTED=$(bluetoothctl info $MAC | grep "Connected: yes")

# If connected then map /dev/rfcomm0 to radio with stored MAC Address. Channel 1 seems to be the bluetooth serial port
if [ -n "$CONNECTED" ]; then
    echo "UV-PRO is connected. Configuring for AX.25"
    # If rfcomm0 does not exist, create it
    if [ ! -e /dev/rfcomm0 ]; then
        /usr/bin/rfcomm connect 0 $MAC 1 &
        sleep 1
    fi

# if not already attached, execute kissattach and set kissparams to the desired port
    # Only attach AX.25 if not already attached
    if [ -e /dev/rfcomm0 ] && ! ip link show ax0 >/dev/null 2>&1; then
        if [[ -z "$AXPORT" ]]; then
            /usr/sbin/kissattach /dev/rfcomm0 1
            /usr/sbin/kissparms -p 1 -t 200 -s 10 -r 10
        else
            /usr/sbin/kissattach /dev/rfcomm0 "$AXPORT"
            /usr/sbin/kissparms -p "$AXPORT" -t 250 -l 50 -s 10 -r 32
            if [[ "$AXPORT" -eq 2 ]]; then 

# change [computername_1] and [computername_2] to your systems' names so appropriate IP address is configured for the correct system
                echo "Configuring $HOSTNAME"
		        if [[ "$HOSTNAME" == "[computername_1]" ]]; then 
                    IP="10.0.0.1" 
               elif [[ "$HOSTNAME" == "[computername_2]" ]]; then 
                    IP="10.0.0.2"
                fi
            elif [[ "$AXPORT" -eq 3 ]]; then 
                echo "Configuring $HOSTNAME"
		        if [[ "$HOSTNAME" == "[computername_1]" ]]; then 
                    IP="10.0.0.1" 
                elif [[ "$HOSTNAME" == "[computername_2]" ]]; then 
                    IP="10.0.0.2"
                fi
	        fi
# assign ip address to ax0 and set the interface to up            
	        echo "Configuring IP: $IP"
            ifconfig ax0 "$IP" netmask 255.255.255.252 up
            #ip route add "$IP" dev ax2 
            
        fi
    fi

else
# if bluetooth has been disconnected, cleanup connections and release the resources
    echo "UV-PRO is not connected. Cleaning up."
    # Clean shutdown
    #if ip link show ax0 >/dev/null 2>&1; then
        killall kissattach 2>/dev/null
        sleep 1
    #fi

    /usr/bin/rfcomm release 0 2>/dev/null
fi


# For /etc/ax25/axports update [NOCALL] to your callsign

# /etc/ax25/axports
#
# The format of this file is:
#
# name callsign speed paclen window description
#
1	WL2K		115200	255	2	UVPRO Bluetooth TNC
2	NOCALL-2	115200  255	2  	Peer-to-peer IP link
3	NOCALL-3	115200  255	2  	Peer-to-peer IP link
