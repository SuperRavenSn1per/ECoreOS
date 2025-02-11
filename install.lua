local url = "https://raw.githubusercontent.com/SuperRavenSn1per/ECoreOS/refs/heads/experimental/os/"

local function install(file, fileName)
    local dat = http.get(url .. file).readAll()
    local f = fs.open(fileName, "w")
    f.write(dat)
    f.close()
    print("GITHUB/" .. file .. " -> " .. fileName)
end

term.clear()
term.setCursorPos(1,1)
print("ECoreOS Installer\n")
print("Would you like to install ECoreOS? (Y/n)\n")
while true do
    write("> ")
    local input = read()
    if string.lower(input) == "y" then
        print("Installing files...")
        install("startup.lua", "/startup.lua")
        install("boot/boot_1.lua", "/boot/boot_1.lua") 
        install("boot/boot_2.lua", "/boot/boot_2.lua")
        install("boot/configuration.lua", "/boot/configuration.lua")
        install("boot/installer.lua", "/boot/installer.lua")
        install("boot/peripherals.lua", "/boot/peripherals.lua")
        install("apis/ec_gui.lua", "/apis/ec_gui.lua")
        install("apis/ec_config.lua", "/apis/ec_config.lua")
        install("apis/ec_regkey.lua", "/apis/ec_regkey.lua")
        config = require("/apis/ec_config")
        print("Setting default configuration...")
        config.set("host_id", -1)
        config.set("require_login", false)
        config.set("type", "nil")
        config.set("register_key", "nil")
        config.set("boot_time", 10)
        print("Installation complete! Rebooting...")
        sleep(3)
        os.reboot()
    elseif string.lower(input) == "n" then
        term.clear()
        term.setCursorPos(1,1)
        print("Installation cancelled!")
        break
    else
        print("Invalid input. Please try again!")
    end
end
