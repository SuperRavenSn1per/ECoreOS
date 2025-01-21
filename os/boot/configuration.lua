local gui = require("/apis/ecore_gui")
local konfig = require("/apis/konfig")

gui.setPrimary(term.current())

local currentIndex = 0

local function writeSettings()
    gui.clearBox(7, gui.h)
    if currentIndex == 0 then
        gui.setBG(colors.gray)
    end
    gui.setPos(1, 7)
    gui.write("<EDIT PERIPHERALS> ")
    gui.setBG(gui.bgColor)
    gui.setPos(1, 9)
    for i,setting in pairs(konfig.getAll()) do
        if i == currentIndex then
            gui.setBG(colors.gray)
        end
        gui.printFormatted({tostring(i) .. ". " .. setting.name:upper() .. ": ", colors.lightGray}, tostring(setting.value) .. " ")
        gui.setBG(gui.bgColor)
    end
end

local function writePeripherals()
    gui.clearBox(9, gui.h)
    gui.setPos(1, 9)
    for i,p in pairs(konfig.getRequired()) do
        gui.print(p)
    end
end

gui.clear()
gui.title(_G.name .. " v" .. _G.version .. " - Configuration", colors.blue)
gui.setPos(1, 3)
gui.print("Select the setting you'd like to change.")
gui.writeLine(5, "[BACKSPACE] to return to boot menu.")
writeSettings()

local function editPeripherals()
    gui.clear()
    gui.title(_G.name .. " v" .. _G.version .. " - Peripherals", colors.blue)
    gui.writeLine(3, "[ENTER] to add a peripheral.")
    gui.writeLine(4, "[ALT] to remove a peripheral.")
    gui.writeLine(5, "[BACKSPACE] to return to configuration.")
    gui.writeFormatted(7, {"Required peripherals:", colors.lightGray})
    gui.setPos(1, 7)
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
        if char == "w" then
            currentIndex = currentIndex - 1
            if currentIndex < 0 then
                currentIndex = #konfig.getAll()
            end
            writeSettings()
        elseif char == "s" then
            currentIndex = currentIndex + 1
            if currentIndex > #konfig.getAll() then
                currentIndex = 0
            end
            writeSettings()
        elseif konfig.getAll()[tonumber(char)] then
            setting = konfig.getAll()[tonumber(char)]
            if type(setting.value) == "boolean" then
                konfig.set(setting.name, not setting.value)
            elseif type(setting.value) == "string" then
                gui.setPos(1, 9 + #konfig.getAll())
                local value = read()
                konfig.set(setting.name, tostring(value))
            elseif type(setting.value) == "number" then
                gui.setPos(1, 9 + #konfig.getAll())
                local value = read()
                konfig.set(setting.name, tonumber(value) or 0)
            end
            writeSettings()
            gui.clearLine(9 + #konfig.getAll()) 
        end
    elseif event == "key" then
        if char == 257 then
            if currentIndex ~= 0 then
                setting = konfig.getAll()[currentIndex]
                if type(setting.value) == "boolean" then
                    konfig.set(setting.name, not setting.value)
                elseif type(setting.value) == "string" then
                    gui.setPos(1, 9 + #konfig.getAll())
                    local value = read()
                    konfig.set(setting.name, tostring(value))
                elseif type(setting.value) == "number" then
                    gui.setPos(1, 9 + #konfig.getAll())
                    local value = read()
                    konfig.set(setting.name, tonumber(value) or 0)
                end
                writeSettings()
                gui.clearLine(9 + #konfig.getAll())
            else
                editPeripherals()
                break
            end
        elseif char == 259 then
            shell.run("/boot_1.lua")
            break
        end
    end
end
