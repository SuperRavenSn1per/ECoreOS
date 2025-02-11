local konfig = {}

function konfig.getAll()
    if not fs.exists(".konfig_settings") then
        local f = fs.open(".konfig_settings", "w")
        f.write("{}")
        f.close()
    end
    local f = fs.open(".konfig_settings", "r")
    local data = f.readAll()
    local final = textutils.unserialise(data)
    f.close()

    return final
end

function konfig.get(setting)
    local data = konfig.getAll()

    for _,s in pairs(data) do
        if s.name == setting then
            return s.value
        end
    end

    return nil
end

function konfig.set(setting, newValue)
    local data = konfig.getAll()

    for _,s in pairs(data) do
        if s.name == setting then
            s.value = newValue
            local final = textutils.serialise(data)
            local f = fs.open(".konfig_settings", "w")
            f.write(final)
            f.close()

            return
        end
    end

    local newSetting = {}
    newSetting.name = setting
    newSetting.value = newValue
    table.insert(data, newSetting)
    local final = textutils.serialise(data)
    local f = fs.open(".konfig_settings", "w")
    f.write(final)
    f.close()
end

function konfig.remove(setting)
    local data = konfig.getAll()

    for i,s in pairs(data) do
        if s.name == setting then
            table.remove(data, i)
            local final = textutils.serialise(data)
            local f = fs.open(".konfig_settings", "w")
            f.write(final)
            f.close()

            return
        end
    end
end

function konfig.getRequired()
    if not fs.exists(".konfig_required") then
        local f = fs.open(".konfig_required", "w")
        f.write("{}")
        f.close()
    end

    local f = fs.open(".konfig_required", "r")
    local data = f.readAll()
    local final = textutils.unserialise(data)
    f.close()

    return final
end

function konfig.require(peripheral)
    local data = konfig.getRequired()

    for _,p in pairs(data) do
        if p == peripheral then
            return
        end
    end

    table.insert(data, peripheral)
    local final = textutils.serialise(data)
    local f = fs.open(".konfig_required", "w")
    f.write(final)
    f.close()
end

function konfig.unrequire(peripheral)
    local data = konfig.getRequired()

    for i,p in pairs(data) do
        if p == peripheral then
            table.remove(data, i)
            local final = textutils.serialise(data)
            local f = fs.open(".konfig_required", "w")
            f.write(final)
            f.close()
        end
    end
end

return konfig
