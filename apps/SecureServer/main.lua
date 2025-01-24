local gui = require("/apis/ecore_gui")
local konfig = require("/apis/konfig")

gui.setPrimary(term.current())

gui.clear(colors.black)
gui.title("EBM Secure Server v1.0", colors.orange)

local function log(id, label, txt)
    gui.printFormatted({"(", colors.gray}, {tostring(id) .. " ", colors.lightGray}, {"| ", colors.gray}, {label and label or "unlabeled", colors.lightGray}, {") ", colors.gray}, txt)
    local x, y = gui.getPos()
    if y >= gui.h - 1 then
        gui.title("EBM Secure Server v1.0", colors.orange)
        gui.clearLine(2)
        gui.setPos(x,y)
    end
end

local function fetchData(id)
    if fs.exists("verified/" .. tostring(id)) then
        local f = fs.open("verified/" .. tostring(id), "r")
        local data = textutils.unserialise(f.readAll())

        return data
    end

    return {accessLevel = 0}
end

local function changeData(id, data, newValue)
    if fs.exists("verified/" .. tostring(id)) then
        local tData = fetchData(id)
        if tData then
            tData[data] = newValue
            local f = fs.open("verified/" .. tostring(id))
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
    end
end

local commands = {
    ["verifself"] = {0, function(id, requestId)
        if tonumber(requestId) == id then
            verify(id)
            log(id, nil, "Terminal " .. id .. " self verified succesfully.")
            rednet.send(id, "verifconfirm " .. os.getComputerID())
        else
            log(id, nil, "Terminal attempted to verify but had an invalid signature.")
        end
    end},
    ["call"] = {1, function(id)
        if fs.exists("verified/" .. id) then
            log(id, nil, "Terminal online.")
            rednet.send(id, "here")
        else
            log(id, nil, "Unverified terminal attempted to connect.")
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
        commands[command][2](id, table.unpack(args))
    else
        log(id, nil, "Invalid command given or terminal is unauthorized!")
    end
end
