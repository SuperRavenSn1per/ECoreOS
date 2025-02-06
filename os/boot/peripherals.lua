local konfig = require("/apis/konfig")
local gui = require("/apis/ecore_gui")

gui.setPrimary(term.current())

local currentIndex = 1
local selection = konfig.getRequired()[currentIndex]

local function drawRequired()
    gui.clearBox(7, gui.h)
    term.setCursorPos(1,7)
    print("Current Selection: " .. selection .. "          ")
    term.setCursorPos(1,9)
    for i,p in pairs(konfig.getRequired()) do
        if i == currentIndex then
            print("> " .. p .. "          ")
        else
            print("  " .. p .. "          ")
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
                currentIndex = #konfig.getRequired()
            end
        elseif key == "s" then
            currentIndex = currentIndex + 1
            if currentIndex > #konfig.getRequired() then
                currentIndex = 1
            end
        end
        selection = konfig.getRequired()[currentIndex]
        drawRequired()
    elseif event == "key" then
        if key == 257 then -- on enter
            term.setCursorPos(1, 9 + #konfig.getRequired() + 1)
            local newRequired = read()
            konfig.require(newRequired)
            selection = konfig.getRequired()[currentIndex]
            drawRequired()
    elseif key == 261 then -- on del
            konfig.unrequire(selection)
            drawRequired()
    elseif key == 259 then -- on backspace
            shell.run("/boot/boot_1.lua")
            break
        end
    end
end
