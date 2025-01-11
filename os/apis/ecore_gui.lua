local ecore_gui = {}

ecore_gui.primary = term.current()

ecore_gui.buttons = {}
ecore_gui.buttons.list = {}

function ecore_gui.setPrimary(screen)
    if screen then
        ecore_gui.primary = screen    
    else
        print(screen or "nil" .. " is not a valid screen!")
    end
end

function ecore_gui.clearLine(line, color)
    local w, h = ecore_gui.primary.getSize()
    local oldColor = ecore_gui.primary.getBackgroundColor()
    ecore_gui.primary.setCursorPos(1, line)
    if color then
        ecore_gui.primary.setBackgroundColor(color)
    end
    for i = 1,w do
        ecore_gui.primary.write(" ")
    end
    ecore_gui.primary.setBackgroundColor(oldColor)
    ecore_gui.primary.setCursorPos(1,line)
end

function ecore_gui.centerWrite(txt, line, offset)
    local w,h = ecore_gui.primary.getSize()
    if line == true then
        line = h / 2 + offset
    end
    ecore_gui.primary.setCursorPos(w / 2 - string.len(txt) / 2, line)
    ecore_gui.primary.write(txt)
end

function ecore_gui.title(txt, color)
    local oldColor = ecore_gui.primary.getBackgroundColor()
    ecore_gui.clearLine(1, color)
    ecore_gui.primary.setBackgroundColor(color)
    ecore_gui.centerWrite(txt, 1)
    ecore_gui.primary.setBackgroundColor(oldColor)
end

function ecore_gui.write(line, txt)
    ecore_gui.clearLine(line)
    ecore_gui.primary.write(txt)
end

function ecore_gui.writeFormatted(line, ...)
    local formatting = {...}

    ecore_gui.clearLine(line)
    for i,dat in pairs(formatting) do
        if type(dat) == "table" then
            ecore_gui.primary.setTextColor(dat[2])
            ecore_gui.primary.write(dat[1])
            ecore_gui.primary.setTextColor(colors.white)
        else
            ecore_gui.primary.write(dat)
        end
    end
end

function ecore_gui.clear(color)
    local w,h = ecore_gui.primary.getSize()
    for i = 1,h do
        ecore_gui.clearLine(i, color or nil)
    end
end

function ecore_gui.buttons.add(label, txt, x, y, color, hlColor, func, arg)
    local button = {}
    button.label = label
    button.text = txt
    button.x = x
    button.y = y
    button.color = color
    button.highlight = hlColor
    button.func = func
    button.arg = arg

    table.insert(ecore_gui.buttons.list, button)
end

function ecore_gui.buttons.draw(label, hl)
    local oldColor = ecore_gui.primary.getBackgroundColor()
    for i,button in pairs(ecore_gui.buttons.list) do
        if button.label == label then
            ecore_gui.primary.setCursorPos(button.x, button.y)
            ecore_gui.primary.setBackgroundColor(hl and button.highlight or button.color)
            ecore_gui.primary.write(" " .. button.text .. " ")
            ecore_gui.primary.setBackgroundColor(oldColor)
        end
    end
end

function ecore_gui.buttons.highlight(label)
    ecore_gui.buttons.draw(label, true)
    sleep(0.1)
    ecore_gui.buttons.draw(label)
end

function ecore_gui.buttons.drawAll()
    for i,button in pairs(ecore_gui.buttons.list) do
        ecore_gui.buttons.draw(button.label)
    end
end

function ecore_gui.buttons.update()
    while true do
        local e, b, x, y = os.pullEvent()
        if e == "mouse_click" or e == "monitor_touch" then
            for i,button in pairs(ecore_gui.buttons.list) do
                if x >= button.x and x <= button.x + string.len(button.text) + 1 and y == button.y then
                    ecore_gui.buttons.highlight(button.label)
                    button.func(button.arg)
                end
            end
        end
    end
end

return ecore_gui
