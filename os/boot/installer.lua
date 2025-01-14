local konfig
local gui

local apps = {
    "SecureDoor",
    "SecureServer",
    "SecureController"
}
local app = ""

local url = "https://raw.githubusercontent.com/SuperRavenSn1per/ECoreOS/refs/heads/main/"

local currentLine = 4

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

local function appInstall(file)
    install("apps/" .. app .. "/" .. file, file)
    gui.writeFormatted(currentLine, {file, colors.lime}, " installed!")
    currentLine = currentLine + 1
end

local function log(txt)
    gui.write(currentLine, txt)
    currentLine = currentLine + 1
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
            konfig = require("/apis/konfig")
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

konfig = require("/apis/konfig")
gui = require("/apis/ecore_gui")

gui.setPrimary(term.current())

gui.clear()
gui.title(_G.name .. " v" .. _G.version .. " - App Installer", colors.blue)
gui.write(3, "[BACKSPACE] to boot OS")
gui.write(5, "Please select an app below to install:")
for i,cApp in pairs(apps) do
    gui.writeFormatted(6 + i, {tostring(i) .. ". ", colors.lightGray}, cApp)
end

while true do 
    local event, char = os.pullEvent()
    if event == "char" then
        app = apps[tonumber(char)]
        if app then
            gui.clear()
            gui.title(_G.name .. " v" .. _G.version .. " - Installing " .. app .. "...", colors.blue)
            gui.primary.setCursorPos(1,3)
            log("Installing files...")
            appInstall("main.lua")
            local data = http.get(url .. "apps/" .. app .. "/" .. "data").readAll()
            local fData = textutils.unserialise(data)
            local extraFiles = fData.extra_files
            local config = fData.default_config
            for i,file in pairs(extraFiles) do
                appInstall(file)
            end
            log("Files installed! Setting default configuration...")
            for i,setting in pairs(config) do
                konfig.set(setting.name, setting.value)
            end
            log("Configuration complete! Rebooting...")
            sleep(3)
            os.reboot()
        end
    elseif event == "key" and char == 259 then
        shell.run("/boot/boot_1.lua")
        break
    end
end


