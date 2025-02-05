_G.os_name = "ECoreOS"
_G.os_version = "1.0"

local konfig = require("/apis/konfig")

gui.setPrimary(term.current())

if konfig.get("require_login") == true then
    term.setBackgroundColor(colors.red)
    term.clear()
    term.setCursorPos(1,1)
    print(os_name .. " v" .. os_version)
    print("Login Page\n")
    write("Username > ")
    local username = read()
    print("")
    write("Password > ")
    local password = read()
else
    shell.run("/boot/boot_1.lua")
end
