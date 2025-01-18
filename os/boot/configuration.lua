local gui = require("/apis/ecore_gui")
local konfig = require("/apis/konfig")

gui.setPrimary(term.current())

local function writeSettings()
    gui.clearBox(9, gui.h)
    gui.setPos(1, 9)
    for i,setting in pairs(konfig.getAll()) do
        gui.printFormatted({tostring(i) .. ". " .. setting.name:upper() .. ": ", colors.lightGray}, tostring(setting.value))
    end
end

local function writePeripherals()
    gui.clearBox(8, gui.h)
    gui.setPos(1, 8)
    for i,p in pairs(konfig.getRequired()) do
        gui.print(p)
    end
end

gui.clear()
gui.title(_G.name .. " v" .. _G.version .. " - Configuration", colors.blue)
gui.setPos(1, 3)
gui.print("Press the number of the setting you'd like to change.")
gui.writeLine(6, "[BACKSPACE] to return to boot menu.")
gui.writeLine(7, "[CTRL] to edit required peripherals.")
writeSettings()

local function editPeripherals()
    gui.clear()
    gui.title(_G.name .. " v" .. _G.version .. " - Peripherals", colors.blue)
    gui.writeLine(3, "[ENTER] to add a peripheral.")
    gui.writeLine(4, "[ALT] to remove a peripheral.")
    gui.writeLine(5, "[BACKSPACE] to return to configuration.")
    gui.writeFormatted(7, {"Required peripherals:", colors.lightGray})
    gui.setPos(1, 8)
    writePeripherals()
    while true do
        local event, key = os.pullEvent("key")
        if key == 257 then
            gui.setPos(1, 9 + #konfig.getRequired())
            local value = read()
            konfig.require(value)
            writePeripherals()
        elseif key == 342 then
            gui.setPos(1, 9 + #konfig.getRequired())
            local value = read()
            konfig.unrequire(value)
            writePeripherals()
        elseif key == 259 then
            shell.run("/boot/configuration.lua")
            break
        end
    end
end

while true do 
    local event, char = os.pullEvent()
    if event == "char" then
        local setting = konfig.getAll()[tonumber(char)]
        if setting then
            if type(setting.value) == "boolean" then
                konfig.set(setting.name, not setting.value)
            elseif type(setting.value) == "string" then
                gui.setPos(1, 10 + #konfig.getAll())
                local value = read()
                konfig.set(setting.name, tostring(value))
            elseif type(setting.value) == "number" then
                gui.setPos(1, 10 + #konfig.getAll())
                local value = read()
                konfig.set(setting.name, tonumber(value) or 0)
            end
            writeSettings()
            gui.clearLine(10 + #konfig.getAll())
        end
    elseif event == "key" then
        if char == 259 then
            shell.run("/startup.lua")
            break
        elseif char == 341 then
            editPeripherals()
            break
        end
    end
end
