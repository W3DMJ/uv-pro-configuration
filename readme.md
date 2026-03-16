# Configure /etc/ax25/axports update [NOCALL] to your callsign
# /etc/ax25/axports
#
# The format of this file is:
#
# name callsign speed paclen window description
#
1	WL2K		115200	255	2	UVPRO Bluetooth TNC
2	NOCALL-2	115200  255	2  	Peer-to-peer IP link
3	NOCALL-3	115200  255	2  	Peer-to-peer IP link

# To connect the UV-Pro run 'sudo uv-monitor.sh --connect [AXPORT NUMBER]' (see /etc/ax25/axports for axport number).
# To disconnect the UV-Pro run 'sudo uv-monitor.sh --disconnect'
