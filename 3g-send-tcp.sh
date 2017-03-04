#!/bin/bash


if [ "$#" -ne 3 ]; then
	echo "./3g-send-tcp.sh <ip addres> <port> <message>"
	exit 0
fi


MODEM_DEVICE=/dev/ttyAMA0
APN="iot.aer.net"

stty -F $MODEM_DEVICE 115200

# Check serial connection.

echo -n "Checking serial connection... "

MODEM_OUTPUT=`echo AT | ./atinout - $MODEM_DEVICE -`

case $MODEM_OUTPUT
in
	*OK*)
			echo "success."
			;;
	*)
			echo "failed - make sure modem is powered up."
			exit 0
			;;
esac

# Check network registration status.

echo -n "Checking network registration status... "
MODEM_OUTPUT=`echo 'AT+CGREG?' | ./atinout - $MODEM_DEVICE - | grep '^+CGREG' | cut -d' ' -f2`
NET_STAT=`echo "${MODEM_OUTPUT}" | cut -d, -f2`

case $NET_STAT
in
	1)
		echo "success."
		;;
	0)
		echo "not registered, check SIM card."
		exit 0
		;;
	2)
		echo "registration in progress, try again later."
		exit 0
		;;
	3)
		echo "registration denied, check SIM card."
		exit 0
		;;
	*)
		echo "error"
		exit 0
		;;
esac

# Set APN.

echo -n "Setting APN... "
MODEM_OUTPUT=`echo "AT+CGSOCKCONT=1,\"IP\",\"${APN}\"" | ./atinout - $MODEM_DEVICE -`

case $MODEM_OUTPUT
in
	*OK*)
			echo "success."
			;;
	*)
			echo "failed."
			exit 0
			;;
esac

# Set up socket PDP context.

echo -n "Setting up socket PDP context... "
MODEM_OUTPUT=`echo AT+CSOCKSETPN=1 | ./atinout - $MODEM_DEVICE -`

case $MODEM_OUTPUT
in
	*OK*)
			echo "success."
			;;
	*)
			echo "failed."
			exit 0
			;;
esac

# Set up TCP/IP mode.

echo -n "Setting up TCP/IP mode... "
MODEM_OUTPUT=`echo AT+CIPMODE=0 | ./atinout - $MODEM_DEVICE -`

case $MODEM_OUTPUT
in
	*OK*)
			echo "success."
			;;
	*)
			echo "failed."
			exit 0
			;;
esac

# Open network.

echo -n "Opening network session... "
MODEM_OUTPUT=`echo AT+NETOPEN=,,1 | ./atinout - $MODEM_DEVICE -`

case $MODEM_OUTPUT
in
	*opened*)
			echo "success."
			;;
	*)
			echo "failed."
			exit 0
			;;
esac

# Get IP address.

echo -n "Getting IP address... "
MODEM_OUTPUT=`echo AT+IPADDR | ./atinout - $MODEM_DEVICE -`
IPADDR=`echo "${MODEM_OUTPUT}" | grep '^+IPADDR' | cut -d' ' -f2`

case $MODEM_OUTPUT
in
	*OK*)
			echo "${IPADDR}"
			;;
	*)
			echo "failed, closing network session."
			# Close network session, since it is open at this point.
			echo AT+NETCLOSE | ./atinout - $MODEM_DEVICE -
			exit 0
			;;
esac

# Open TCP port.

echo -n "Opening TCP connection... "
MODEM_OUTPUT=`echo "AT+CIPOPEN=0,\"TCP\",\"${1}\",${2}" | ./atinout - $MODEM_DEVICE -`

case $MODEM_OUTPUT
in
	*OK*)
			echo "success."
			;;
	*)
			echo "failed, closing network session."
			# Close network session, since it is open at this point.
			echo AT+NETCLOSE | ./atinout - $MODEM_DEVICE -
			exit 0
			;;
esac

# Send the TCP packet.

echo -n "Sending TCP packet '${3}'... "
P=$3
L=${#P}
T="AT+CIPSEND=0,${L}"
echo -n -e "${T}\r" >$MODEM_DEVICE

MODEM_OUTPUT=`echo "$P" | ./atinout - $MODEM_DEVICE -`

case $MODEM_OUTPUT
in
	*OK*)
			echo "success."
			;;
	*)
			echo "failed.."
			# Close network session, since it is open at this point.
			exit 0
			;;
esac

echo AT+CIPCLOSE=0 | ./atinout - $MODEM_DEVICE - >/dev/null
echo AT+NETCLOSE | ./atinout - $MODEM_DEVICE - >/dev/null

