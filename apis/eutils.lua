local eutils = {}

eutils.primary = term.current()

function eutils.setPrimary(screen)
    if screen then
        eutils.primary = screen    
    else
        print(screen or "nil" .. " is not a valid screen!")
    end
end

function eutils.clearLine(line, color)
    local w, h = eutils.primary.getSize()
    local oldColor = eutils.primary.getBackgroundColor()
    eutils.primary.setCursorPos(1, line)
    if color then
        eutils.primary.setBackgroundColor(color)
    end
    for i = 1,w do
        eutils.primary.write(" ")
    end
    eutils.primary.setBackgroundColor(oldColor)
    eutils.primary.setCursorPos(1,line)
end

function eutils.centerWrite(txt, line, offset)
    local w,h = eutils.primary.getSize()
    if line == true then
        line = h / 2 + offset
    end
    eutils.primary.setCursorPos(math.floor(w / 2 - string.len(txt) / 2), line)
    eutils.primary.write(txt)
end

function eutils.title(txt, color)
    local oldColor = eutils.primary.getBackgroundColor()
    eutils.clearLine(1, color)
    eutils.primary.setBackgroundColor(color)
    eutils.centerWrite(txt, 1)
    eutils.primary.setBackgroundColor(oldColor)
end

function eutils.writeFormatted(line, ...)
    local formatting = {...}

    eutils.clearLine(line)
    for i,dat in pairs(formatting) do
        if type(dat) == "table" then
            eutils.primary.setTextColor(dat[2])
            eutils.primary.write(dat[1])
            eutils.primary.setTextColor(colors.white)
        else
            eutils.primary.write(dat)
        end
    end
end

return eutils

