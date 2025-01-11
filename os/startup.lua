_G.name = "ECoreOS"
_G.version = "1.0"
_G.credit = "Made by EBM Technologies"

local do_boot = true
local program

local eutils = require("/apis/ecore_gui")

eutils.setPrimary(term.current())

local function countdown()
    local t = 5
    repeat
        eutils.write(9, "OS booting in " .. t .. "...")
        sleep(1)
        t = t - 1
    until t == 0
end

local function selection()
    while true do
        local event, char = os.pullEvent("char")
        if char == "1" then
            break
        elseif char == "2" then
            do_boot = false
            program = "/boot/configuration.lua"
            break
        elseif char == "3" then
            do_boot = false
            program = "/boot/installer.lua"
            break
        end
    end
end

eutils.clear()
eutils.title(_G.name .. " v" .. _G.version .. " - Boot Menu", colors.blue)
local w,h = term.getSize()
eutils.write(h, _G.credit)
eutils.write(3, "Press number key of option below:")
eutils.writeFormatted(5, {"1. ", colors.lightGray}, "Boot OS")
eutils.writeFormatted(6, {"2. ", colors.lightGray}, "Configuration")
eutils.writeFormatted(7, {"3. ", colors.lightGray}, "App Installer")

parallel.waitForAny(countdown, selection)
if do_boot then 
    shell.run("/boot/boot_1.lua")
else
    shell.run(program)
end
