local config = require("/apis/ec_config")
local gui = require("/apis/ec_gui")

gui.setPrimary(term.current(), colors.blue)

local currentIndex = 1
local selection = config.getAll()[currentIndex]

local function drawConfig()
    gui.clearBox(6, gui.h)
    term.setCursorPos(1,6)
    print("Current Selection: " .. selection.name)
    term.setCursorPos(1,8)
    for i,setting in pairs(config.getAll()) do
        if i == currentIndex then
            print("> " .. string.upper(setting.name) .. ": " .. tostring(setting.value))
        else
            print("  " .. string.upper(setting.name) .. ": " .. tostring(setting.value))
        end
    end
end

term.setBackgroundColor(colors.blue)
term.clear()
term.setCursorPos(1,1)
print("EDITING CONFIGURATION\n")
print("Press [BACKSPACE] to exit or select a setting to edit below.")
drawConfig()

while true do
    local event, key = os.pullEvent()
    if event == "char" then
        if key == "w" then
            currentIndex = currentIndex - 1
            if currentIndex <= 0 then
                currentIndex = #config.getAll()
            end
        elseif key == "s" then
            currentIndex = currentIndex + 1
            if currentIndex > #config.getAll() then
                currentIndex = 1
            end
        end
        selection = config.getAll()[currentIndex]
        drawConfig()
    elseif event == "key" then
        if key == 257 then -- on enter
            term.setCursorPos(1, 8 + #config.getAll() + 1)
            if type(selection.value) == "boolean" then
                config.set(selection.name, not selection.value)
            else
                term.setCursorPos(1, 8 + #config.getAll() + 1)
                local newValue = read()
                if type(selection.value) == "number" then
                    config.set(selection.name, tonumber(newValue) or 0)
                elseif type(selection.value) == "string" then
                    config.set(selection.name, tostring(newValue))
                end
            end
            selection = config.getAll()[currentIndex]
            drawConfig()
        elseif key == 259 then -- on backspace
            shell.run("/boot/boot_1.lua")
            break
        end
    end
end
