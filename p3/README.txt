How to run the program:
(To get more accurate data, please allow channel hopping (airodump wlan0mon))
1. get nearby accesspoints:
tshart -X lua_script:accesspoints.lua -i wlan0mon -Q
The script will get nearby access points and store them into accesspoints.txt file
2. get finger prints for each room:
tshart -X lua_script:fingerprints.lua -i wlan0mon -Q
The script will asking you for room name and will store the finger prints data into roomName.room file
3. indicate wich room you are:
tshart -X lua_script:changeroom.lua -i wlan0mon -Q
The scripts will start gathering finger prints for current location,
then print out the distance from current location to the staring point.
If the distance >= 3, you may changed to another room.





