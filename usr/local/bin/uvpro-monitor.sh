#!/bin/bash
#MAC="00:00:00:00:00:00"
AXPORT="$1"
MAC=$(bluetoothctl devices | grep -i "UV-PRO" | awk '{print $2}')
if [[ -n "$MAC" ]]; then 
    echo "Found UV-PRO: $MAC" 
fi

CONNECTED=$(bluetoothctl info $MAC | grep "Connected: yes")

if [ -n "$CONNECTED" ]; then
    echo "UV-PRO is connected. Configuring for AX.25"
    # If rfcomm0 does not exist, create it
    if [ ! -e /dev/rfcomm0 ]; then
        /usr/bin/rfcomm connect 0 $MAC 1 &
        sleep 1
    fi

    # Only attach AX.25 if not already attached
    if [ -e /dev/rfcomm0 ] && ! ip link show ax0 >/dev/null 2>&1; then
        if [[ -z "$AXPORT" ]]; then
            /usr/sbin/kissattach /dev/rfcomm0 1
            /usr/sbin/kissparms -p 1 -t 200 -s 10 -r 10
        else
            /usr/sbin/kissattach /dev/rfcomm0 "$AXPORT"
            /usr/sbin/kissparms -p "$AXPORT" -t 250 -l 50 -s 10 -r 32
            if [[ "$AXPORT" -eq 2 ]]; then 
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
                elif [[ "$HOSTNAME" == "computername_2" ]]; then 
                    IP="10.0.0.2"
                fi
	        fi
            
	        echo "Configuring IP: $IP"
            ifconfig ax0 "$IP" netmask 255.255.255.252 up
            #ip route add "$IP" dev ax2 
            
        fi
    fi

else
    echo "UV-PRO is not connected. Cleaning up."
    # Clean shutdown
    #if ip link show ax0 >/dev/null 2>&1; then
        killall kissattach 2>/dev/null
        sleep 1
    #fi

    /usr/bin/rfcomm release 0 2>/dev/null
fi

