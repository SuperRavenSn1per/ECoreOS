local net = {}

local BROADCAST_CHANNEL = 9999

net.modem = peripheral.find("modem")

local function getId()
    local id = 10000 + os.getComputerID()

    return id
end

local function encrypt(str)
    local enc = {}
    for char in str:gmatch("[^.]") do
        table.insert(enc, char:byte() * 2)
        table.insert(enc, "-")
    end
    enc = table.concat(enc)

    return enc
end

local function decrypt(str)
    local dec = {}
    for group in str:gmatch("[^%p]+") do
        group = group / 2
        table.insert(dec, tostring(group):char())
    end
    dec = table.concat(dec)

    return dec
end

function net.open()
    if net.modem then
        net.modem.open(getId())
        net.modem.open(BROADCAST_CHANNEL)
    end
end

function net.close()
    if net.modem then
        if net.modem.isOpen(getId()) then
            net.modem.close(getId())
            net.modem.close(BROADCAST_CHANNEL)
        end
    end
end

function net.send(id, msg)
    net.modem.transmit(id, getId(), encrypt(msg))
end

function net.broadcast(msg)
    net.modem.transmit(BROADCAST_CHANNEL, getId(), encrypt(msg))
end

function net.receive()
    local event, side, freq, id, msg = os.pullEvent("modem_message")

    msg = decrypt(msg)

    return id, msg
end

return net
