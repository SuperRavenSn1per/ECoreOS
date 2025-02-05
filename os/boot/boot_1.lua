local konfig = require("/apis/konfig")

local boot = ""

local currentIndex = 1

local selections = {
    {"Boot OS", "/boot/boot_2.lua"},
    {"Edit Configuration", "/boot/configuration.lua"},
    {"App Installer", "/boot/installer.lua"}
}

local function countdown()
    local t = konfig.get("boot_time")

    repeat
        term.setCursorPos(1, 6 + #selections + 1)
        print("BOOTING IN " .. t .. "...")
        sleep(1)
        t = t - 1
    until t <= 0

    boot = "/boot/boot_2.lua"

    return
end

local function drawSelection(index)
    term.setCursorPos(1,6)
    for i,selection in pairs(selections) do
        if i == index then
            print(string.upper("[ " .. selection[1] .. " ]"))
        else
            print(string.upper("  " .. selection[1] .. "     "))
        end
    end
end

local function makeSelection()
    while true do
        local event, char = os.pullEvent()
        if event == "char" then
            if char == "w" then
                currentIndex = currentIndex - 1
                if currentIndex < 1 then
                    currentIndex = #selections
                end
                drawSelection(currentIndex)
            elseif char == "s" then
                currentIndex = currentIndex + 1
                if currentIndex > #selections then
                    currentIndex = 1
                end
                drawSelection(currentIndex)
            elseif tonumber(char) then
                if selections[tonumber(char)] then
                    boot = selections[tonumber(char)][2]
                    break
                end
            end
        elseif event == "key" then
            if char == 257 then
                boot = selections[currentIndex][2]
                break
            end
        end
    end
end

term.setBackgroundColor(colors.blue)
term.clear()
term.setCursorPos(1,1)
print("OS: " .. _G.name)
print("VERSION: " .. _G.version)
print("TERMINAL ID: " .. os.getComputerID())
print("REGKEY: " .. konfig.get("register_key"))

drawSelection(currentIndex)

parallel.waitForAny(countdown, makeSelection)

shell.run(boot)

