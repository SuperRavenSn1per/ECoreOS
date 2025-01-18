_G.name = "ECoreOS"
_G.version = "1.0"

local gui = require("/apis/ecore_gui")

gui.setPrimary(term.current())

local boot = ""

local selections = {
    {"Boot OS", "/boot/boot_1.lua"},
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
    boot = "/boot/boot_1.lua"

    return
end

local function makeSelection()
    while true do
        local event, char = os.pullEvent("char")
        if selections[tonumber(char)] then
            boot = selections[tonumber(char)][2]

            return
        end
    end
end

gui.clear()
gui.title(_G.name .. " v" .. _G.version .. " - Boot Menu", colors.blue)
gui.writeLine(3, "Press number key of selection below:")
gui.setPos(1, 5)

for i,selection in pairs(selections) do
    gui.printFormatted({i .. ". ", colors.lightGray}, selection[1])
end

parallel.waitForAny(countdown, makeSelection)

shell.run(boot)
