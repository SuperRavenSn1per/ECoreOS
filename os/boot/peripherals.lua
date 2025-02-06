local konfig = require("/apis/konfig")

local currentIndex = 1
local selection = konfig.getRequired()[currentIndex]

local function drawRequired()
    term.setCursorPos(1,6)
    print("Current Selection: " .. p .. "          ")
    term.setCursorPos(1,8)
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
            term.setCursorPos(1, 8 + #konfig.getRequired() + 1)
            if type(selection.value) == "boolean" then
                konfig.set(selection.name, not selection.value)
            else
                term.setCursorPos(1, 8 + #konfig.getRequired() + 1)
                local newValue = read()
                if type(selection.value) == "number" then
                    konfig.set(selection.name, tonumber(newValue) or 0)
                elseif type(selection.value) == "string" then
                    konfig.set(selection.name, tostring(newValue))
                end
            end
            term.setCursorPos(1, 8 + #konfig.getRequired() + 1)
            write("                       ")
            selection = konfig.getRequired()[currentIndex]
            drawRequired()
            
        elseif key == 259 then -- on backspace
            shell.run("/boot/boot_1.lua")
            break
        end
    end
end
