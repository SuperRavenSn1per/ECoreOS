local gui = require("/apis/ecore_gui")
local konfig = require("/apis/konfig")

gui.setPrimary(term.current())

local currentLine = 3

local function addStatus(txt, statusType)
    local color = statusType == "s" and colors.lime or statusType == "w" and colors.orange or statusType == "e" and colors.red
    local symbol = statusType == "s" and "+" or statusType == "w" and "?" or statusType == "e" and "!"
    gui.writeFormatted(currentLine, "[", {symbol, color}, "] ", {txt, colors.lightGray})
    if statusType == "e" then
        sleep(3)
        os.reboot()
    end
    currentLine = currentLine + 1
end

gui.clear()
gui.title(_G.name .. " v" .. _G.version .. " - Booting...", colors.blue)
local w,h = term.getSize()
gui.write(h, _G.credit)

addStatus("Welcome to ECoreOS. Booting now!", "s")
if konfig.get("require_host") == true and konfig.get("require_modem") == false then
    addStatus("REQUIRE_HOST is true, but not REQUIRE_MODEM!", "w")
    addStatus("Changing REQUIRE_HOST to false.", "s")
    konfig.set("require_host", false)
end
if konfig.get("require_modem") == true then
    addStatus("Modem required. Checking for modem...", "s")
    if peripheral.find("modem") then
        addStatus("Modem found!", "s")
        peripheral.find("modem", rednet.open)
    else
        addStatus("Modem not found. Please add a modem!", "e")
    end
else
    addStatus("Modem not required.", "s")
end
if konfig.get("require_host") == true then
    addStatus("Host required. Contacting host...", "s")
    rednet.send(konfig.get("host_id"), "call")
    local id, msg = rednet.receive(5)
    if not id or id ~= konfig.get("host_id") or msg ~= "here" then
        addStatus("Host not found.", "e")
    else
        addStatus("Host found.", "s")
    end
else
    addStatus("Host not required.", "s")
end
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
