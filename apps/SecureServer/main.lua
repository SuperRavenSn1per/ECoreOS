local gui = require("/apis/ecore_gui")
local konfig = require("/apis/konfig")

gui.setPrimary(term.current())

gui.clear(colors.black)
gui.title("EBM Secure Server v1.0", colors.orange)

local function fetchData(id)
    if fs.exists("verified/" .. tostring(id)) then
        local f = fs.open("verified/" .. tostring(id), "r")
        local data = textutils.unserialise(f.readAll())

        return data
    end

    return {accessLevel = 0}
end

local function log(id, txt)
    local tData = fetchData(id)
    gui.printFormatted({"(", colors.gray}, {tostring(id) .. " ", colors.lightGray}, {"| ", colors.gray}, {tData.label or "unlabeled", colors.lightGray}, {") ", colors.gray}, txt)
    local x, y = gui.getPos()
    if y >= gui.h - 1 then
        gui.title("EBM Secure Server v1.0", colors.orange)
        gui.clearLine(2)
        gui.setPos(x,y)
    end
end

local function changeData(id, data, newValue)
    if fs.exists("verified/" .. tostring(id)) then
        local tData = fetchData(id)
        if tData then
            tData[data] = newValue
            local f = fs.open("verified/" .. tostring(id), "w")
            f.write(textutils.serialise(tData))
            f.close()
        end
    end
end

local function verify(id)
    if not fs.exists("verified/" .. tostring(id)) then
      local f = fs.open("verified/" .. tostring(id), "w")
      f.write("{}")
      f.close()
      changeData(id, "accessLevel", 1)
      changeData(id, "type", "unspecified")
      changeData(id, "label", "unlabeled")
    end
end

local commands = {
    ["verifself"] = {0, function(id, requestId)
        if tonumber(requestId) == id then
            verify(id)
            log(id, "Terminal " .. id .. " self verified succesfully.")
                
            return "verifconfirm " .. os.getComputerID()
        else
            log(id, "Terminal attempted to verify but had an invalid signature.")

            return -1, "Invalid signature."
        end
    end},
    ["call"] = {1, function(id)
        if fs.exists("verified/" .. id) then
            log(id, "Terminal online.")

            return "here"
        else
            log(id, "Unverified terminal attempted to connect.")
            
            return -1, "Unverified."
        end
    end},
    ["changetype"] = {1, function(id, newType)
        local tData = fetchData(id)
        if fs.exists("verified/" .. id) then
            if newType == "keypad" or newType == "monitor" or newType == "alarm" or newType == "elevator" then
                log(id, "Changed type to '" .. newType .. "'")
                changeData(id, "type", newType)
                if newType == "keypad" and not tData.password then
                    changeData(id, "password", "0000")
                end
                    
                return "success"
            else
                log(id, "Invalid type '" .. newType .. "'")

                return -1, "Invalid type."
            end
        else
            log(id, "Unauthorized terminal attempted to change label.")  

            return -1, "Unauthorized."
        end
    end},
    ["passwd"] = {1, function(id, password)
        local tData = fetchData(id)
        if tData.password == password then
            log(id, "Correct password entered.")

            return "correct"
        else
            log(id, "Incorrect password entered.")

            return -1, "Incorrect."
        end
    end},
    ["controlverif"] = {1, function(id)
        log(id, "Terminal wants to register as a controller. Allow it? (Y/n)")
        local input = read()
        if input:lower() == "y" then
            log(id, "Terminal is now a controller.")
            changeData(id, "accessLevel", 2)
            changeData(id, "label", "controller_" .. tostring(id))
            changeData(id, "type", "controller")
                
            return "controlconfirm"
        else
            log(id, "Denied.")

            return -1, "Denied."
        end
    end},
    ["verify"] = {2, function(id, newId)
        verify(newId)
        log(id, "Verified new terminal " .. newId)

        return "success"
    end},
    ["unverify"] = {2, function(id, delId)
        if fs.exists("verified/" .. delId) then
            fs.delete("verified/" .. delId)
            log(id, "Terminal " .. delId .. " has been unverified.")

            return "success"
        else
            return -1, "Terminal does not exist."    
        end
    end},
    ["label"] = {2, function(id, newId, newLabel)
        if fs.exists("verified/" .. newId) then
            changeData(newId, "label", newLabel)
            log(id, "Changed label of " .. newId .. " to '" .. newLabel .. "'") 

            return "success"
        else
            return -1, "Terminal does not exist."    
        end
    end},
    ["changepass"] = {2, function(id, newId, newPass)
        if fs.exists("verified/" .. newId) then
            changeData(newId, "password", newPass)
            log(id, "Changed password of terminal " .. newId)

            return "success"
        else
            return -1, "Terminal does not exist."    
        end
    end},
    ["lock"] = {2, function(id, newId)
        if newId == "all" then
            for i,verif in pairs(fs.list("verified/")) do
                local tData = fetchData(verif)
                if tData.type == "keypad" then
                    rednet.send(tonumber(verif), "lock")
                end
            end
            log(id, "Lockdown initiated!")

            return "success"
        else
            if fs.exists("verified/" .. newId) then
                rednet.send(tonumber(newId), "lock")
                log(id, "Terminal " .. newId .. " has been locked.")

                return "success"
            else
                return -1, "Terminal does not exist."
            end
        end
    end},
    ["unlock"] = {2, function(id, newId)
        if newId == "all" then
            for i,verif in pairs(fs.list("verified/")) do
                local tData = fetchData(verif)
                if tData.type == "keypad" then
                    rednet.send(tonumber(verif), "unlock")
                end
            end
            log(id, "Lockdown ended!")

            return "success"
        else
            if fs.exists("verified/" .. newId) then
                rednet.send(tonumber(newId), "unlock")
                log(id, "Terminal " .. newId .. " has been unlocked.")

                return "success"
            else
                return -1, "Terminal does not exist."
            end
        end
    end}
}

gui.setPos(1, 3)
while true do
    local id, msg = rednet.receive()
    local tData = fetchData(id)
    local parts = {}
    for word in msg:gmatch("[^%s]+") do
        table.insert(parts, word)
    end
    local command = parts[1]
    local args = {}
    for i = 2,#parts do
        table.insert(args, parts[i])
    end
    if commands[command] and tData.accessLevel >= commands[command][1] then
        local ok, response, reason = pcall(function() local r,r2 = commands[command][2](id, table.unpack(args)) return r,r2 end)
        if not ok or response == -1 then
            rednet.send(id, reason)
        else
            rednet.send(id, response)
        end
    else
        log(id, "Invalid command given or terminal is unauthorized!")
        rednet.send(id, "Invalid command or unknown error!")
    end
end
