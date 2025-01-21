local konfig = require("/apis/konfig")
local gui = require("/apis/ecore_gui")

local apps = {
    "SecureDoor",
    "SecureServer",
    "SecureController"
}

local app = ""

local url = "https://raw.githubusercontent.com/SuperRavenSn1per/ECoreOS/refs/heads/experimental/apps/"

local function install(file, fileName)
    local dat = http.get(url .. file).readAll()
    local f = fs.open(fileName, "w")
    f.write(dat)
    f.close()
    gui.printFormatted("Installed ", {"GITHUB/" .. file .. " ", colors.lightGray}, "as ", {fileName, colors.lightGray})
end

gui.setPrimary(term.current())

gui.clear()
gui.title(_G.name .. " v" .. _G.version .. " - App Installer", colors.blue)
gui.writeLine(3, "[BACKSPACE] to return to boot menu.")
gui.writeLine(5, "Please select an app below to install:")

gui.setPos(1,7)
for i,cApp in pairs(apps) do
    gui.printFormatted({tostring(i) .. ". ", colors.lightGray}, cApp)
end

while true do 
    local event, char = os.pullEvent()
    if event == "char" then
        app = apps[tonumber(char)]
        if app then
            gui.clear()
            gui.title(_G.name .. " v" .. _G.version .. " - Installing " .. app .. "...", colors.blue)
            gui.setPos(1, 3)
            install(app .. "/" .. "main.lua", "main.lua")
            local data = textutils.unserialise(http.get(url .. app .. "/" .. "data").readAll())
            for i,extra in pairs(data.extra_files) do
                install(app .. "/" .. extra, extra)
            end
            gui.print("Main installation complete. Setting up configuration...")
            for i,config in pairs(data.default_config) do
                konfig.set(config.name, config.value)
            end
            for i,req in pairs(data.required) do
                konfig.require(req)
            end
            gui.print("Installation complete. Rebooting...")
            sleep(3)
            os.reboot()
        end
    elseif event == "key" and char == 259 then
        shell.run("/boot/boot_1.lua")
        break
    end
end
