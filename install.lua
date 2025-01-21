local url = "https://raw.githubusercontent.com/SuperRavenSn1per/ECoreOS/refs/heads/main/os/"

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
        install("apis/ecore_gui.lua", "/apis/ecore_gui.lua")
        install("apis/konfig.lua", "/apis/konfig.lua")
        konfig = require("/apis/konfig")
        print("Setting default configuration...")
        konfig.set("host_id", -1)
        konfig.set("require_login", false)
        konfig.set("username", "admin")
        konfig.set("password", "0000")
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
