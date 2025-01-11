local gui = require("/apis/ecore_gui")
local konfig = require("/apis/konfig")

gui.setPrimary(term.current())

local function writeSettings()
    for i,setting in pairs(konfig.getAll()) do
        gui.writeFormatted(7 + i, {tostring(i) .. ". " .. setting.name:upper() .. ": ", colors.lightGray}, setting.value)
    end
end

gui.clear()
gui.title(_G.name .. " v" .. _G.version .. " - Configuration", colors.blue)
local w,h = term.getSize()
gui.write(h, _G.credit)
gui.write(3, "Press the number of the setting")
gui.write(4, "you'd like to change")
gui.write(6, "[BACKSPACE] to boot OS")

writeSettings()

while true do 
    local event, char = os.pullEvent()
    if event == "char" then
        local setting = konfig.getAll()[tonumber(char)]
        if setting then
            if type(setting.value) == "boolean" then
                konfig.set(setting.name, not setting.value)
            elseif type(setting.value) == "string" then
                term.setCursorPos(1, 9 + #konfig.getAll())
                local value = read()
                konfig.set(setting.name, tostring(value))
            elseif type(setting.value) == "number" then
                term.setCursorPos(1, 9 + #konfig.getAll())
                local value = read()
                konfig.set(setting.name, tonumber(value) or 0)
            end
            writeSettings()
            gui.clearLine(9 + #konfig.getAll())
        end
    elseif event == "key" and char == 259 then
        shell.run("/boot/boot_1.lua")
        break
    end
end
