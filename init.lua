require('config')

print("Starting ESP"..node.chipid().."...")

wifi.setmode(wifi.STATION)
wifi.sta.config(AP,PWD)
wifi.sta.connect()

print('MAC address:', wifi.sta.getmac())

if (wifi.getmode() == wifi.STATION) then
    local joinCounter = 0
    local joinMaxAttempts = 5
    tmr.alarm(0, 3000, 1, function()
       local ip = wifi.sta.getip()
       if ip == nil and joinCounter < joinMaxAttempts then
          print('Connecting to WiFi Access Point ...')
          joinCounter = joinCounter +1
       else
          if joinCounter == joinMaxAttempts then
             print('Failed to connect to WiFi Access Point.')
          else
             print('IP: ',ip)
             if file.open("main.lua") ~= nil then
                dofile("main.lua")
             else 
              print("main.lua doesn't exist !")
             end
          end
          tmr.stop(0)
          joinCounter = nil
          joinMaxAttempts = nil
          collectgarbage()
       end
    end)
end