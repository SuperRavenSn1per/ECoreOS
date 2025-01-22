local gui = require("/apis/ecore_gui")
local konfig = require("/apis/konfig")
local net = require("/apis/ecore_net")

gui.setPrimary(term.current())

gui.clear(colors.black)
gui.title("EBM Secure Server v1.0", colors.orange)

local function log(id, label, txt)
    gui.printFormatted({"(", colors.gray}, {tostring(id) .. " ", colors.lightGray}, {"| ", colors.gray}, {label, colors.lightGray}, {") ", colors.gray}, txt)
end

local function changeData(terminal, value, newValue)
    local f = fs.open("/verified/" .. terminal, "r")
    local data = f.readAll()
    local fData = textutils.unserialise(data)
    f.close()
    fData[value] = newValue
    local f = fs.open("/verified/" .. terminal, "w")
    f.write(textutils.serialise(fData))
    f.close()
end

local commands = {
    ["verify"] = function(sender, id)
        if not fs.exists("/verified/" .. id) then
            local f = fs.open("/verified/" .. id, "w")
            local default = {}
            default.label = "unlabeled"
            default.password = "0000"
            default.locked = false
            f.write(textutils.serialise(default))
            f.close()
            net.send(sender, "success")
            log(sender, "control", "Terminal " .. id .. " has been verified.")
        else
            net.send(sender, "Terminal already verified!")
            log(sender, "control", "Terminal " .. id .. " already verified!")
        end
    end,
    ["delete"] = function(sender, id)
        if fs.exists("/verified/" .. id) then
            fs.delete("/verified/" .. id)
            net.send(sender, "success")
            log(sender, "control", "Terminal " .. id .. " has been deleted.")
        else
            net.send(sender, "Terminal does not exist!")
            log(sender, "control", "Terminal " .. id .. " does not exist!")
        end
    end,
    ["label"] = function(sender, id, label)
        if fs.exists("/verified/" .. id) then
            changeData(id, "label", label)
            net.send(sender, "success")
            log(sender, "control", "Terminal " .. id .. " has been labeled.")
        else
            net.send(sender, "Terminal does not exist!")
            log(sender, "control", "Terminal " .. id .. " does not exist!")
        end
    end,
    ["changepass"] = function(sender, id, newpass)
        if fs.exists("/verified/" .. id) then
            changeData(id, "password", newpass)
            net.send(sender, "success")
            log(sender, "control", "Terminal " .. id .. " password changed.")
        else
            net.send(sender, "Terminal does not exist!")
            log(sender, "control", "Terminal " .. id .. " does not exist!")
        end
    end,
    ["lock"] = function(sender, id)
        if id == "all" then
            for i,terminal in pairs(fs.list("/verified/")) do
                changeData(terminal, "locked", true)
                net.send(tonumber(terminal), "lock")
                net.send(sender, "success")
            end
            log(sender, "control", "Lockdown initiated!")
        else
            if fs.exists("/verified/" .. id) then
                changeData(id, "locked", true)
                net.send(tonumber(id), "lock")
                net.send(sender, "success")
                log(sender, "control", "Terminal " .. id .. " has been locked.")
            else
                net.send(sender, "Terminal does not exist!")
                log(sender, "control", "Terminal " .. id .. " does not exist!")
            end
        end
    end,
    ["unlock"] = function(sender, id)
        if id == "all" then
            for i,terminal in pairs(fs.list("/verified/")) do
                changeData(terminal, "locked", false)
                net.send(tonumber(terminal), "unlock")
                net.send(sender, "success")
            end
            log(sender, "control", "Lockdown ended!")
        else
            if fs.exists("/verified/" .. id) then
                changeData(id, "locked", false)
                net.send(tonumber(id), "unlock")
                net.send(sender, "success")
                log(sender, "control", "Terminal " .. id .. " has been unlocked.")
            else
                net.send(sender, "Terminal does not exist!")
                log(sender, "control", "Terminal " .. id .. " does not exist!")
            end
        end
    end,
}

if not fs.exists("/verified") then
    fs.makeDir("/verified")
end

gui.setPos(1, 3)

while true do
    id, msg = net.receive()
    local args = {}
    for string in msg:gmatch("[^%s]+") do
        table.insert(args, string)
    end
    if msg == "call" then
        net.send(id, "here")
    end
    if fs.exists("/verified/".. tostring(id)) then
        local f = fs.open("/verified/" .. tostring(id), "r")
        local data = f.readAll()
        local tData = textutils.unserialise(data)
        if args[1]:lower() == "pass" then
            if args[2] == tData.password and tData.locked == false then
                net.send(id, "correct")
                log(id, tData.label, "Correct password entered.")
            elseif tData.locked == true then
                net.send(id, "locked")
                log(id, tData.label, "Denied. Terminal is locked.")
            else
                net.send(id, "incorrect")
                log(id, tData.label, "Incorrect password entered.")
            end
        end
    elseif id == konfig.get("controller_id") then
        local ok, err = pcall(function() commands[args[1]](id, args[2], args[3]) end)
        if not ok then
            net.send(id, "Unknown error or command not valid!")
            log(id, "control", "Error: " .. err)
        end
    end
end
