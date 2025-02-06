local konfig = require("/apis/konfig")

local currentIndex = 1

local function drawConfig()
    term.setCursorPos(1,6)
    for i,setting in pairs(konfig.getAll()) do
        if i == currentIndex then
            print("> " .. string.upper(setting.name))
        else
            print("  " .. string.upper(setting.name))
        end
    end
end

term.setBackgroundColor(colors.blue)
tern.clear()
tern.setCursorPos(1,1)
print("EDITING CONFIGURATION\n")
print("Press [BACKSPACE] to exit or select a setting to edit below.")
