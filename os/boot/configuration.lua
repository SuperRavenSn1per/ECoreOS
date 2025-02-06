local konfig = require("/apis/konfig")

local currentIndex = 1
local selection = konfig.getAll()[currentIndex]

local function drawConfig()
    term.setCursorPos(1,6)
    print("Current Selection: " .. selection.name .. "          ")
    term.setCursorPos(1,8)
    for i,setting in pairs(konfig.getAll()) do
        if i == currentIndex then
            print("> " .. string.upper(setting.name) .. ": " .. tostring(setting.value) .. "          ")
        else
            print("  " .. string.upper(setting.name) .. ": " .. tostring(setting.value) .. "          ")
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
                currentIndex = #konfig.getAll()
            end
        elseif key == "s" then
            currentIndex = currentIndex + 1
            if currentIndex > #konfig.getAll() then
                currentIndex = 1
            end
        end
        selection = konfig.getAll()[currentIndex]
        drawConfig()
    elseif event == "key" then
        if key == 257 then -- on enter
            term.setCursorPos(1, 8 + #konfig.getAll() + 1)
            if type(selection.value) == "boolean" then
                konfig.set(selection.name, not selection.value)
            else
                term.setCursorPos(1, 8 + #konfig.getAll() + 1)
                local newValue = read()
                if type(selection.value) == "number" then
                    konfig.set(selection.name, tonumber(newValue) or 0)
                elseif type(selection.value) == "string" then
                    konfig.set(selection.name, tostring(newValue))
                end
            end
            selection = konfig.getAll()[currentIndex]
            write("                       ")
            drawConfig()
            
        elseif key == 259 then -- on backspace
            shell.run("/boot/boot_1.lua")
            break
        end
    end
end
