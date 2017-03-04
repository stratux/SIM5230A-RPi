## SIM5230A-RPi

This repository contains some simple scripts to get started with the SIM5320A on the RPi.

##How to use

1. `git clone git://git.code.sf.net/p/atinout/code atinout`
2. `cd atinout && make && make install && cd ..`
3. `git clone https://github.com/stratux/SIM5230A-RPi`
4. `cd SIM5230A-RPi`

Once everything is set up, the scripts below will be ready to use.


##Contents
1. install.sh

   Run this to add the correct "dtoverlay" to your `/boot/config.txt` file. This is required in the RPi3.
2. 3g-power-cycle.sh

   Run this to turn the 3G module on or off.
3. 3g-send-udp.sh <ip addres> <port> <message>

   Use this script to send a single TCP packet.
4. 3g-send-tcp.sh <ip addres> <port> <message>

   Use this script to open a TCP connection, send a single packet, and then close the connection.
