-- This program will register a menu that will open a window with a count of occurrences
-- of every address in the capture
rssi_filter = Field.new('radiotap.dbm_antsignal')
--ip_filter = Field.new('ip.addr')
--frame_type = Field.new('wlan.fc.type_subtype')
last_tick = os.time()
packet_num=0
frame_num=0
total = 0
my_ip = '10.110.45.140'
pps = {}
num = 0
local function menuable_tap()
        -- Declare the window we will use
        local tw = TextWindow.new("Address Counter")        
        -- This will contain a hash of counters of appearances of a certain address
        local ips = {}

        -- this is our tap
        local tap = Listener.new('frame','ip.addr == 10.110.45.140');
--        print(tostring(value))
        function remove()
                -- this way we remove the listener that otherwise will remain running indefinitely
                tap:remove();
        end

        -- we tell the window to call the remove() function when closed
        tw:set_atclose(remove)

        -- this function will be called once for each packet
        function tap.packet(pinfo,tvb,tapdata)                  
                
--               print(tostring(pinfo.dst)..' '..tostring(tostring(pinfo.dst) == '10.110.45.140'))

                if tostring(pinfo.dst) ==  my_ip then
                    packet_num = packet_num + 1
                    pps[num] = packet_num
--                   print(tostring(rssi)..' '..tostring(packet_num))
                    if os.time() - last_tick >= 1 then
                        print(tostring(os.time())..' '..tostring(packet_num))
                        packet_num = 0
                        last_tick = os.time()
                        num = num + 1                        
                    end
                end
                local src = ips[tostring(pinfo.src)] or 0
                local dst = ips[tostring(pinfo.dst)] or 0

                ips[tostring(pinfo.src)] = src + 1
                ips[tostring(pinfo.dst)] = dst + 1
        end

        -- this function will be called once every few seconds to update our window
        function tap.draw(t)
                tw:clear()
                for ip,num in pairs(ips) do
                        tw:append(ip .. "\t" .. num .. "\n");
                end
        end

        -- this function will be called whenever a reset is needed
        -- e.g. when reloading the capture file
        function tap.reset()
                tw:clear()
                ips = {}
        end
end

-- using this function we register our function
-- to be called when the user selects the Tools->Test->Packets menu
register_menu("Test/Packets", menuable_tap, MENU_TOOLS_UNSORTED)
