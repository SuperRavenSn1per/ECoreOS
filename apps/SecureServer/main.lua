local gui = require("/apis/ecore_gui")
local konfig = require("/apis/konfig")

gui.setPrimary(term.current())

gui.clear(colors.black)
gui.title("EBM Secure Server v1.0", colors.orange)

local regTypes = {
    ["keypad"] = 1,
    ["controller"] = 2
}

local function fetchData(id, dataName)
    if fs.exists("verified/" .. tostring(id)) then
        local f = fs.open("verified/" .. tostring(id), "r")
        local data = textutils.unserialise(f.readAll())
        if dataName then
            data = data[dataName]
        end

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

local function verifyRegKey(key)
    local length = key:sub(1,1)
    local seed = key:sub(2, 1 + length)
    local P1 = seed * 5
    local P2 = P1 / 3
    local final = length .. seed .. P1 .. P2
    final = math.floor(final)
    final = tostring(final):sub(1,6)

    if final == key then
        return true
    else
        return false
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
      changeData(id, "reg_key", nil)
    end
end

local function register(id, regType, regKey)
    if fs.exists("verified/" .. tostring(id)) then
        changeData(id, "type", regType)
        changeData(id, "reg_key", regKey)
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
    ["regself"] = {1, function(id, reg)
        local parts = {}

        for part in reg:gmatch("[^_]+") do
            table.insert(parts, part)
        end

        local regType = parts[1]
        local regKey = parts[2]
    
        if not regType or not regKey then
            log(id, "Terminal tried to self-register with invalid format.")
            return -1,"Invalid message format."
        end
        if not regTypes[regType] then
            log(id, "Terminal tried to self-register with invalid registration type.")
            return -1,"Invalid registration type."
        end
        if not verifyRegKey(regKey) then
            log(id, "Terminal tried to self-register with invalid registration key.")
            return -1,"Invalid registration key."
        end
        if regType == "controller" then
            log(id, "Terminal is attempting to self-register as a controller. Allow it?")
            local input = read()
            if input:lower() ~= "y" and input:lower() ~= "yes" then
                log(id, "Denied.")
                return -1,"Denied by operator."
            end
        end
        register(id, regType, regKey)
        log(id, "Successfully self-registered as '" .. regType .. "'")
        return "regsuccess"
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
    ["verify"] = {2, function(id, newId)
        verify(newId)
        log(id, "Verified new terminal " .. newId)

        return "success"
    end},
    ["unverify"] = {2, function(id, delId)
        if fs.exists("verified/" .. delId) then
            fs.delete("verified/" .. delId)

            return "success"
        else
            return -1, "Terminal does not exist."    
        end
    end},
    ["label"] = {2, function(id, newId, newLabel)
        if fs.exists("verified/" .. newId) then
            changeData(newId, "label", newLabel)

            return "success"
        else
            return -1, "Terminal does not exist."    
        end
    end},
    ["changepass"] = {2, function(id, newId, newPass)
        if fs.exists("verified/" .. newId) then
            changeData(newId, "password", newPass)

            return "success"
        else
            return -1, "Terminal does not exist."    
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
            rednet.send(id, "Error: " .. (reason or response))
        else
            rednet.send(id, response)
        end
    else
        log(id, "Invalid command given or terminal is unauthorized!")
    end
end
