local regkey = {}

function regkey.generate()
    local seed = math.random(100,999)
    local len = tonumber(tostring(seed):len())
    local P1 = seed * 5
    local P2 = P1 / 3

    local key = len .. seed .. P1 .. P2
    key = math.floor(key)
    key = tostring(key):sub(1,6)

    return key
end

function regkey.verify()
    local len = key:sub(1,1)
    local seed = key:sub(2, 1 + length)
    local P1 = seed * 5
    local P2 = P1 / 3
    local final = len .. seed .. P1 .. P2
    final = math.floor(final)
    final = tostring(final):sub(1,6)

    if final == key then
        return true
    else
        return false
    end
end

return regkey
