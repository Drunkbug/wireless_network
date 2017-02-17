since we can't make our wifi card to both listen to the monitor interface and the
wifi interface on the same channel, what we tried to do is to make 2 programs, listener.lua
will be used to listen to all the beacon frames and then calculate the average rssi while
p2.lua will be used to check for the number of packet we received during the broadcasting
We then put the data in excel and then plot the data

wireshark -X lua_script:listener.lua
wireshark -X lua_script:p2.lua

choose the according interface then start capturing
then choose Tools>Packet>Test and the result will be 
printed out the the terminal


