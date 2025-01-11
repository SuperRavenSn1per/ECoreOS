local konfig
local gui

local url = "https://raw.githubusercontent.com/SuperRavenSn1per/ECoreOS/refs/heads/main/"

local function install(file, fileName)
    local dat = http.get(url .. file).readAll()
    local f = fs.open(fileName, "w")
    f.write(dat)
    f.close()
end

local function pre_install(file, fileName)
    install(file, fileName)
    print(file .. " -> " .. fileName)
end

if not fs.exists("/boot/boot_1.lua") then
    term.clear()
    term.setCursorPos(1,1)
    print("ECoreOS Installer\n")
    print("Would you like to install ECoreOS? (Y/n)\n")
    while true do
        write("> ")
        local input = read()
        if string.lower(input) == "y" then
            print("Installing files...")
            pre_install("os/startup.lua", "/startup.lua")
            pre_install("os/boot/boot_1.lua", "/boot/boot_1.lua")
            pre_install("os/boot/configuration.lua", "/boot/configuration.lua")
            pre_install("os/boot/installer.lua", "/boot/installer.lua")
            pre_install("os/apis/ecore_gui.lua", "/apis/ecore_gui.lua")
            pre_install("os/apis/konfig.lua", "/apis/konfig.lua")
            konfig = require("/apis/konfig.lua")
            print("Setting default configuration...")
            konfig.set("require_modem", false)
            konfig.set("require_host", false)
            konfig.set("host_id", 0)
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
end

