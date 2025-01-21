_G.name = "ECoreOS"
_G.version = "1.0"

local gui = require("/apis/ecore_gui")
local konfig = require("/apis/konfig")

if konfig.get("require_login") == true then
    gui.clear()
    gui.title(_G.name .. " v" .. _G.version .. " - Login", colors.red)
    gui.writeLine(3, "Username: ")
    gui.writeLine(4, "Password: ")
    gui.setPos(1 + string.len("Username: "), 3)
    local username = read()
    gui.setPos(1 + string.len("Password: "), 4)
    local password = read("*")
    if username ~= konfig.get("username") and password ~= konfig.get("password") then
        gui.writeFormatted(6, {"Incorrect username or password!", colors.red})
        sleep(3)
        os.reboot()
    else
        shell.run("/boot/boot_1.lua")
    end
else
    shell.run("/boot/boot_1.lua")
end
