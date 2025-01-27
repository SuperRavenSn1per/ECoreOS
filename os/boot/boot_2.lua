local gui = require("/apis/ecore_gui")
local konfig = require("/apis/konfig")

gui.setPrimary(term.current())

local function addStatus(txt, statusType)
    local color = statusType == "u" and colors.gray or statusType == "s" and colors.lime or statusType == "w" and colors.orange or statusType == "e" and colors.red
    local symbol = statusType == "u" and "-" or statusType == "s" and "+" or statusType == "w" and "?" or statusType == "e" and "!"
    gui.printFormatted("[", {symbol, color}, "] ", {txt, colors.lightGray})
    if statusType == "e" then
        sleep(5)
        os.reboot()
    end
end

local function generateRegKey()
    local seed = math.random(100,999)
    local length = tonumber(tostring(seed):len())
    local P1 = seed * 5
    local P2 = P1 / 3

    local key = length .. seed .. P1 .. P2
    key = math.floor(key)
    key = tostring(key):sub(1,6)

    return key
end

gui.clear()
gui.title(_G.name .. " v" .. _G.version .. " - Booting...", colors.blue)

gui.setPos(1,3)
addStatus("Welcome to ECoreOS! Booting now...", "u")
addStatus("Checking for required peripherals...", "u")
if konfig.get("host_id") >= 0 then
    addStatus("Host is required but no modem is. Setting modem to required, change HOST_ID to less than 0 if a host is not required.", "w")
    konfig.require("modem")
end
if #konfig.getRequired() == 0 then
    addStatus("No peripherals required!", "s")
else
    for i,p in pairs(konfig.getRequired()) do
        if peripheral.find(p) then
            addStatus("'" .. p .. "' " .. "is present.", "s")
        else
            addStatus("'" .. p .. "' " .. " is required but not present.", "e")
        end
    end
    addStatus("All required peripherals are present!", "s")
end
if peripheral.find("modem") then
    addStatus("Opening Rednet on modem...", "u")
    peripheral.find("modem", rednet.open)
    addStatus("Rednet is opened!", "s")
end
addStatus("Checking if host is required...", "u")
if konfig.get("host_id") < 0 then
    addStatus("No host is required!", "s")
else
    addStatus("Host is required. Pinging...", "u")
    rednet.send(konfig.get("host_id"), "call")
    local id, msg = rednet.receive(3)
    if not id or id ~= konfig.get("host_id") or msg ~= "here" then
        addStatus("Host did not respond. Trying to verify a new host...", "w")
        rednet.broadcast("verifself " .. os.getComputerID())
        local id, msg = rednet.receive(3)
        local parts = {}
        local newHost
        if msg then
            for word in msg:gmatch("[^%s]+") do
                table.insert(parts, word)
            end
            newHost = parts[2]
        end
        if not id or parts[1] ~= "verifconfirm" then
            addStatus("No valid host was found. Please set up host and try again.", "e")
        else
            addStatus("A valid host responded. Setting " .. newHost .. " as host ID.", "s")
            konfig.set("host_id", tonumber(newHost))
        end
    else
        addStatus("Host responded.", "s")
    end
end
if konfig.get("type") ~= "nil" and konfig.get("register_key") == "nil" then
    addStatus("This device is unregistered. Attempting to register...", "u")
    local regKey = generateRegKey()
    rednet.send(konfig.get("host_id"), "regself " .. konfig.get("type") .. "_" .. regKey)
    local id,msg = rednet.receive(5)
    if id == konfig.get("host_id") and msg == "regsuccess" then
        addStatus("Registration successfull!", "s")
        konfig.set("register_key", regKey)
    else
        addStatus("Registration failed!", "e")
    end
end
addStatus("Boot process complete.", "s")
if fs.exists("/main.lua") then
    shell.run("/main.lua")
else
    addStatus("main.lua is not set up. Press [R] to reboot.", "w")
    while true do
        local event, char = os.pullEvent("char")
        if char:upper() == "R" then
            os.reboot()
        end
    end
end
