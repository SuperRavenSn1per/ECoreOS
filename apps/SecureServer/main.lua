local gui = require("/apis/ecore_gui")
local konfig = require("/apis/konfig")

gui.setPrimary(term.current())

gui.clear(colors.black)
gui.title("EBM Secure Server v1.0", colors.orange)

local function log(id, label, txt)
    gui.printFormatted({"(", colors.gray}, {tostring(id) .. " ", colors.lightGray}, {"| ", colors.gray}, {label and label or "unlabeled", colors.lightGray}, {") ", colors.gray}, txt)
end

local function verify(id)
    if not fs.exists("verified/" .. tostring(id)) then
        local f = fs.open("verified/" .. tostring(id), "w")
        f.write("{}")
        f.close()
    end
end

gui.setPos(1, 3)

while true do
    local id, msg = rednet.receive()
    local parts = {}
    for word in msg:gmatch("[^%s]+") do
        table.insert(parts, word)
    end
    if parts[1] == "verifself" then
        if tonumber(parts[2]) == id then
            verify(id)
            log(id, nil, "Terminal " .. id .. " self verified succesfully.")
            rednet.send(id, "verifconfirm " .. os.getComputerID())
        else
            log(id, nil, "Terminal attempted to verify but had an invalid signature.")
        end
    end
end
