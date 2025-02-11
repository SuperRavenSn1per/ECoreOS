local config = require("/apis/ec_config")
local gui = require("/apis/ec_gui")

gui.setPrimary(term.current(), colors.blue)

local currentIndex = 1
local selection = config.getRequired()[currentIndex] or "nil"

local function drawRequired()
    gui.clearBox(7, gui.h)
    term.setCursorPos(1,7)
    print("Current Selection: " .. selection)
    term.setCursorPos(1,9)
    for i,p in pairs(config.getRequired()) do
        if i == currentIndex then
            print("> " .. p)
        else
            print("  " .. p)
        end
    end
end

term.setBackgroundColor(colors.blue)
term.clear()
term.setCursorPos(1,1)
print("EDITING PERIPHERALS\n")
print("Press [BACKSPACE] to exit")
print("Press [ENTER] to add a new peripheral")
print("Press [DEL] to delete selected peripheral")
drawRequired()

while true do
    local event, key = os.pullEvent()
    if event == "char" then
        if key == "w" then
            currentIndex = currentIndex - 1
            if currentIndex <= 0 then
                currentIndex = #config.getRequired()
            end
        elseif key == "s" then
            currentIndex = currentIndex + 1
            if currentIndex > #config.getRequired() then
                currentIndex = 1
            end
        end
        selection = config.getRequired()[currentIndex] or "nil"
        drawRequired()
    elseif event == "key" then
        if key == 257 then -- on enter
            term.setCursorPos(1, 9 + #config.getRequired() + 1)
            local newRequired = read()
            config.require(newRequired)
            selection = config.getRequired()[currentIndex] or "nil"
            drawRequired()
    elseif key == 261 then -- on del
            config.unrequire(selection)
            currentIndex = 1
            selection = config.getRequired()[currentIndex] or "nil"
            drawRequired()
    elseif key == 259 then -- on backspace
            shell.run("/boot/boot_1.lua")
            break
        end
    end
end
