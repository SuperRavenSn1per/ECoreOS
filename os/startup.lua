_G.name = "ECoreOS"
_G.version = "1.0"

local config = require("/apis/ec_config")

if config.get("require_login") == true then
    term.setBackgroundColor(colors.red)
    if not fs.exists("/.account_info") then
        term.clear()
        term.setCursorPos(1,1)
        print("----------------")
        print("| " .. _G.name .. " v" .. _G.version .. " |")
        print("----------------\n")
        print("'REQUIRE_LOGIN' is set to true but no account has been created. Please create one below.\n")
        write("New Username > ")
        local newUser = read()
        write("New Password > ")
        local newPass = read()
        local info = {}
        info.username = newUser
        info.password = newPass
        local f = fs.open("/.account_info", "w")
        f.write(textutils.serialise(info))
        f.close()
    end
    term.clear()
    term.setCursorPos(1,1)
    print("----------------")
    print("| " .. _G.name .. " v" .. _G.version .. " |")
    print("----------------\n")
    print("Please enter the correct username and password below.\n")
    write("Username > ")
    local username = read()
    write("Password > ")
    local password = read("*")
    local f = fs.open("/.account_info", "r")
    local accountInfo = textutils.unserialise(f.readAll())
    if accountInfo.username == username and accountInfo.password == password then
        shell.run("/boot/boot_1.lua")
    else
        print("\nUsername or password is incorrect!")
        shell.run("/startup.lua")
    end
else
    shell.run("/boot/boot_1.lua")
end
