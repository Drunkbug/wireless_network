-- This program will register a menu that will open a window with a count of occurrences
-- of every address in the capture
value = Field.new('radiotap.dbm_antsignal')
-- get AP field
ssidField = Field.new("wlan.bssid")

start_tick = os.time()
last_tick = os.time()
roomName = ""
local function menuable_tap()
    local APs = {}
    -- Declare the window we will use
    --local tw = TextWindow.new("Address Counter")        
    -- This will contain a hash of counters of appearances of a certain address

    -- this is our tap
    local tap = Listener.new("wlan","wlan.fc.type_subtype != 0x15 && wlan.fc.type_subtype != 0x0e");
--        print(tostring(value))
    function remove()
            -- this way we remove the listener that otherwise will remain running indefinitely
            tap:remove();
    end

    -- we tell the window to call the remove() function when closed
    --tw:set_atclose(remove)

    -- this function will be called once for each packet
    function tap.packet(pinfo,tvb,tapdata)                  
      local rssi = value()
      local rssiString = tostring(rssi)
		  -- get ssid
      local ssidRaw = ssidField()
      local ssid = tostring(ssidRaw)
	  	-- if detect new AP and not exist in table
		  if ((ssid ~= "nil") and (APs[ssid] == nil) and (ssid ~= "ff:ff:ff:ff:ff:ff")) then
        -- ssid range from smallest to largest
        APs[ssid] = {}
			  APs[ssid][1] = rssiString
			  APs[ssid][2] = rssiString
      elseif ((ssid ~= "nil") and (APs[ssid] ~= nil) and (rssi ~= nil)) then
        if (tonumber(APs[ssid][1]) > tonumber(rssiString)) then 
          APs[ssid][1] = rssiString
        elseif (tonumber(APs[ssid][2]) < tonumber(rssiString)) then
          APs[ssid][2] = rssiString
        end
		  end
      -- when reach maximum packets number, print out average
      if (os.time() - last_tick >= 1) then
        for k,v in pairs(APs) do
          print(tostring(k) .. ":" .. tostring(APs[k][1]) .. "~" .. tostring(APs[k][2]))
        end
        print "---";
        last_tick = os.time()
      end

      if (os.time() - start_tick >= 10) then
        for k,v in pairs(APs) do
          file = io.open(roomName .. ".room", "a")
          file:write(tostring(k) .. ":" .. tostring(APs[k][1]) .. "~" .. tostring(APs[k][2]) .. "\n")
        end
      end
 

    end

    -- this function will be called once every few seconds to update our window
    function tap.draw(t)
      --tw:clear()
    end

    -- this function will be called whenever a reset is needed
    -- e.g. when reloading the capture file
    function tap.reset()
      APs = {}
      --tw:clear()
    end
end

-- to be called when the user selects the Tools->Test->Packets menu
--register_menu("Test/Packets", menuable_tap, MENU_TOOLS_UNSORTED)
local out 
repeat
  io.write("room name: ")
  io.flush()
  roomName=io.read()
until roomName ~= nil
start_tick = os.time()
menuable_tap()
