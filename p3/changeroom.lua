-- This program will register a menu that will open a window with a count of occurrences
-- of every address in the capture
value = Field.new('radiotap.dbm_antsignal')
-- get AP field
ssidField = Field.new("wlan.bssid")

start_tick = os.time()
last_tick = os.time()
filter = ""
result = {}
mode = 1

local function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
return f ~= nil
end

-- get all lines from file
local function read_lines(file)
  if not file_exists(file) then return {} end
  APs = {}
  for line in io.lines(file) do 
    APs[#APs + 1] = line
  end
  return APs
end

local function generate_filter(APs, acc)
  for k, v in pairs(APs) do
    acc = acc .. "wlan.bssid==" .. v .. " || "
  end
  acc = acc:sub(1,-4)
  print (acc)
  return acc
end


local function menuable_tap()
    -- Declare the window we will use
    --local tw = TextWindow.new("Address Counter")        
    -- This will contain a hash of counters of appearances of a certain address

    -- this is our tap
    local tap = Listener.new("wlan", "wlan.fc.type_subtype != 0x15 && wlan.fc.type_subtype != 0x0e && (" .. filter .. ")");
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
      if (mode == 1) then
	  	  -- if detect new AP and not exist in table
		    if ((ssid ~= "nil") and (result[ssid] == nil) and (ssid ~= "ff:ff:ff:ff:ff:ff")) then
          -- ssid range from smallest to largest
          result[ssid] = {}
          -- total rssi
			    result[ssid][1] = rssiString
          -- frame number
			    result[ssid][2] = 1 
          -- average
          result[ssid][3] = tonumber(result[ssid][1]) / result[ssid][2]
        elseif ((ssid ~= "nil") and (result[ssid] ~= nil) and (rssi ~= nil)) then
          result[ssid][1] = result[ssid][1] + tonumber(rssiString) 
          result[ssid][2] = result[ssid][2] + 1
          result[ssid][3] = tonumber(result[ssid][1]) / result[ssid][2]
		    end

        if (os.time() - start_tick >= 10) then
          for k,v in pairs(result) do
            print(tostring(k) .. ": " .. tostring(result[k][3]))
          end
          print ("===========================================")
          print ("calculation done, now move your laptop...")
          print ("===========================================")
          mode = 2
        end
      -- moving mode
      elseif (mode == 2) then
        local distance
        if (os.time() - last_tick >= 1) then
          if ((ssid ~= "nil") and (rssi ~= nil) and (result[ssid] ~= nil)) then
            distance = 10^((math.abs(math.abs(result[ssid][3]) - math.abs(tonumber(rssiString))))/(10*4))
            print ("current distance: " .. distance)
            last_tick = os.time()
          end
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
      result = {}
      --tw:clear()
    end
end

-- to be called when the user selects the Tools->Test->Packets menu
--register_menu("Test/Packets", menuable_tap, MENU_TOOLS_UNSORTED)
--
print ("reading accesspoints...\n")
local apFile ="accesspoints.txt"
local APs = read_lines(apFile)
print ("done.\n")

print ("generating filter...\n")
local acc = ""
filter = generate_filter(APs, acc)

start_tick = os.time()
print ("===========================================")
print ("start gathering current data...")
print ("===========================================")
menuable_tap()

