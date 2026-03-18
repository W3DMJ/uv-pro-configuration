#!/bin/bash

# Usage:
#   script.sh --connect [AXPORT]
#   script.sh --disconnect
#   script.sh [AXPORT]     # legacy behavior

ACTION=""
AXPORT=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        connect)
            ACTION="connect"
            shift
            ;;
        disconnect)
            ACTION="disconnect"
            shift
            ;;
        *)
            AXPORT="$1"
            shift
            ;;
    esac
done

# Find MAC of UV‑PRO
MAC=$(bluetoothctl devices | grep -i "UV-PRO" | awk '{print $2}')

if [[ -z "$MAC" ]]; then
    echo "No UV-PRO device found."
    exit 1
fi

echo "Found UV-PRO: $MAC"

# -----------------------------
# FUNCTIONS
# -----------------------------

connect_and_configure() {
    echo "Connecting and configuring UV-PRO…"

    CONNECTED=$(bluetoothctl info "$MAC" | grep "Connected: yes")

    if [[ -z "$CONNECTED" ]]; then
        echo "Connecting to UV-PRO ..."
        /usr/bin/rfcomm bind 0 "$MAC" 1 &
        sleep 5
    else 
        $(bluetoothctl connect "$MAC")
        CONNECTED=$(bluetoothctl info "$MAC" | grep "Connected: yes")
        if [[ -z "$CONNECTED" ]]; then
            /usr/bin/rfcomm bind 0 "$MAC" 1
            sleep 5
            
        fi
    fi

    # Attach AX.25 if not already attached
    if [ -e /dev/rfcomm0 ] && ! ip link show ax0 >/dev/null 2>&1; then
        if [[ -z "$AXPORT" ]]; then
            /usr/sbin/kissattach /dev/rfcomm0 1
            /usr/sbin/kissparms -p 1 -t 200 -s 10 -r 10
        else
            /usr/sbin/kissattach /dev/rfcomm0 "$AXPORT"
            /usr/sbin/kissparms -p "$AXPORT" -t 250 -l 50 -s 10 -r 32

            # Host-specific IP config
            if [[ "$AXPORT" -eq 2 || "$AXPORT" -eq 3 ]]; then
                echo "Configuring $HOSTNAME"
                if [[ "$HOSTNAME" == "[computername_1]" ]]; then
                    IP="10.0.0.1"
                elif [[ "$HOSTNAME" == "[computername_2]" ]]; then
                    IP="10.0.0.2"
                fi

                echo "Configuring IP: $IP"
                ifconfig ax0 "$IP" netmask 255.255.255.252 up
            fi
        fi
    else
        echo "/dev/rfcomm0 not found"
        echo "UV-PRO was not configured."
        exit
    fi

    echo "UV-PRO configured."
}

disconnect_cleanup() {
    echo "Disconnecting UV-PRO and cleaning up…"

    killall kissattach 2>/dev/null
    sleep 1

    /usr/bin/rfcomm release 0 2>/dev/null

    MAC=$(bluetoothctl devices | grep -i "UV-PRO" | awk '{print $2}')
    bluetoothctl disconnect "$MAC"

    echo "Cleanup complete."
}

# -----------------------------
# MAIN LOGIC
# -----------------------------

case "$ACTION" in
    connect)
        connect_and_configure
        exit 0
        ;;
    disconnect)
        disconnect_cleanup
        exit 0
        ;;
esac

# Default legacy behavior
#CONNECTED=$(bluetoothctl info "$MAC" | grep "Connected: yes")

if [[ -n "$CONNECTED" ]]; then
    connect_and_configure
else
    disconnect_cleanup
fi
