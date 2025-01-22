local gui = require("/apis/ecore_gui")
local konfig = require("/apis/konfig")

gui.setPrimary(term.current())

local boot = ""

local currentIndex = 1

local selections = {
    {"Boot OS", "/boot/boot_2.lua"},
    {"Configuration", "/boot/configuration.lua"},
    {"App Installer", "/boot/installer.lua"}
}

local function countdown()
    local t = 5
    repeat
        gui.writeLine(5 + #selections + 1, "Booting OS in " .. tostring(t) .. "...")
        sleep(1)
        t = t - 1
    until t == 0
    boot = "/boot/boot_2.lua"

    return
end

local function drawSelection(index)
    gui.setPos(1, 5)
    for i,selection in pairs(selections) do
        if i == index then
            gui.setBG(colors.gray)
        end
        gui.printFormatted({i .. ". ", colors.lightGray}, selection[1] .. " ")
        gui.setBG(gui.bgColor)
    end
end

local function makeSelection()
    while true do
        local event, char = os.pullEvent()
        if event == "char" then
            if char == "w" then
                currentIndex = currentIndex - 1
                if currentIndex < 1 then
                    currentIndex = #selections
                end
                drawSelection(currentIndex)
            elseif char == "s" then
                currentIndex = currentIndex + 1
                if currentIndex > #selections then
                    currentIndex = 1
                end
                drawSelection(currentIndex)
            elseif tonumber(char) then
                if selections[tonumber(char)] then
                    boot = selections[tonumber(char)][2]
                    break
                end
            end
        elseif event == "key" then
            if char == 257 then
                boot = selections[currentIndex][2]
                break
            end
        end
    end
end

gui.clear()
gui.title(_G.name .. " v" .. _G.version .. " - Boot Menu", colors.blue)
gui.writeLine(3, "Make a selection below:")
drawSelection(currentIndex)

parallel.waitForAny(countdown, makeSelection)

shell.run(boot)

