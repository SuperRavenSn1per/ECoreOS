local konfig = require("/apis/konfig")

local currentIndex = 1

local function drawConfig()
    term.setCursorPos(1,6)
    print("Current Selection: " .. konfig.getAll()[currentIndex].name .. "          ")
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
        drawConfig()
    end
end
