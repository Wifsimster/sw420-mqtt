require('config')
local ntp = require('ntp')
local pulse1 = 0

-- MQTT client
TOPIC = "/sensors/"..LOCATION.."/sw420/data"

ntp.sync()

-- Init client with keepalive timer 120sec
m = mqtt.Client(CLIENT_ID, 120, "", "")
ip = wifi.sta.getip()
m:lwt("/offline", '{"message":"'..CLIENT_ID..'", "topic":"'..TOPIC..'", "ip":"'..ip..'"}', 0, 0)

gpio.mode(DATA_PIN, gpio.INT)

function publish(level, amplitude)
    DATA = '{"mac":"'..wifi.sta.getmac()..'", "ip":"'..ip..'",'
    DATA = DATA..'"date":"'..ntp.date()..'","time":"'..ntp.time()..'",'
    DATA = DATA..'"level":"'..level..'","amplitude":"'..amplitude..'"}'
    m:publish(TOPIC, DATA, 0, 0, function(conn)
        print(CLIENT_ID.." sending data: "..DATA.." to "..TOPIC)
    end)
end

local function pulsein(level)
    local pulse2 = tmr.now()
    amplitude = pulse2 - pulse1
    print(level, amplitude)
    publish(level, amplitude)
    pulse1 = pulse2
    gpio.trig(DATA_PIN, level == gpio.HIGH  and "down" or "up")
end
        
print("Connecting to MQTT: "..BROKER_IP..":"..BROKER_PORT.."...")
m:connect(BROKER_IP, BROKER_PORT, 0, 1, function(conn)
    print("Connected to MQTT: "..BROKER_IP..":"..BROKER_PORT.." as "..CLIENT_ID)
    gpio.trig(DATA_PIN, "down", pulsein)
end)
