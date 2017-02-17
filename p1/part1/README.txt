we collect the data by filter out the beacon frame by running

wireshark -X lua_script:listener.lua 

then start capturing on the monitor interface and choose Tools>Packet>Test to
start filter out the rssi value and calculate the average of the first 20 packets
of each channel
In order to change the channel, we write another shell script which uses iwconfig
to force the monitor interface to change channel and the script also automate
the process of starting the listener.lua and piping the result to be dumped to .data file
