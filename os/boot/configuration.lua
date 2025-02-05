local konfig = require("/apis/konfig")

local currentIndex = 1

local function drawConfig()
    term.setSetCursorPos(1,5)
    for i,setting in pairs(konfig.getAll()) do
        if i == currentIndex then
            print("> " .. setting.name)
        else
            print("  " .. setting.name)
        end
    end
end

term.setBackgroundColor(colors.blue)
print("EDITING CONFIGURATION\n")
print("Press [BACKSPACE] to exit or select a setting to edit below.")
