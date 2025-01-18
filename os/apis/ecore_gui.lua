local gui = {}

gui.primary = nil
gui.w = 0
gui.h = 0
gui.bgColor = colors.black

gui.buttons = {}
gui.buttons.list = {}

function gui.setPrimary(screen, color)
    local w,h
    local ok, err = pcall(function() w,h = screen.getSize() end)
    if not ok then
        error("'" .. screen .. "' is not a valid screen.")
    else
        gui.primary = screen
        gui.w = w
        gui.h = h
        gui.bgColor = color or colors.black
    end
end

function gui.write(txt)
    gui.primary.write(txt)
end

function gui.setBG(color)
    gui.primary.setBackgroundColor(color)
end

function gui.setFG(color)
    gui.primary.setTextColor(color)
end

function gui.setPos(x, y)
    gui.primary.setCursorPos(x, y)
end

function gui.getPos()
    local x, y = gui.primary.getCursorPos()
    
    return x, y
end

local function skipLine()
    local x, y = gui.getPos()
    gui.setPos(1, y + 1)
end

function gui.clearLine(line, color)
    gui.setPos(1, line)
    if color then
        gui.setBG(color)
    end
    for i = 1,gui.w do
        gui.write(" ")
    end
    gui.setBG(gui.bgColor)
    gui.setPos(1,line)
end

function gui.clear(color)
    for i = 1,gui.h do
        gui.clearLine(i, color or nil)
    end
end

function gui.clearBox(startY, endY, color)
    for i = startY,endY do
        gui.clearLine(i, color or nil)
    end
end

function gui.centerWrite(txt, line, offset)
    if line == true then
        line = gui.h / 2 + offset
    end
    gui.setPos(math.ceil(gui.w / 2 - string.len(txt) / 2), line)
    gui.write(txt)
end

function gui.title(txt, color)
    gui.clearLine(1, color)
    gui.setBG(color)
    gui.centerWrite(txt, 1)
    gui.setBG(gui.bgColor)
end

function gui.writeLine(line, txt)
    gui.clearLine(line)
    gui.write(txt)
end

function gui.writeFormatted(line, ...)
    local formatting = {...}

    gui.clearLine(line)
    for i,dat in pairs(formatting) do
        if type(dat) == "table" then
            gui.setFG(dat[2])
            gui.write(dat[1])
            gui.setFG(colors.white)
        else
            gui.write(dat)
        end
    end
end

function gui.print(str)
    local words = {}
    for word in str:gmatch("[^%s]+") do
       table.insert(words, word)
    end
    for i,word in pairs(words) do
        local x = gui.getPos()
        if x + #word > gui.w then
            skipLine()
        end
        gui.write(word)
        gui.write(i == #words and "" or " ")
    end
    skipLine()
end

function gui.printFormatted(...)
    local formatting = {...}

    for i,dat in pairs(formatting) do
        if type(dat) == "table" then
            gui.setFG(dat[2])
            local words = {}
            for word in dat[1]:gmatch("[^%s]+") do
               table.insert(words, word)
            end
            for i,word in pairs(words) do
                local x = gui.getPos()
                if x + #word > gui.w then
                    skipLine()
                end
                gui.write(word)
                if dat[1]:sub(#dat[1], #dat[1]) == " " then
                    gui.write(" ")
                else
                    gui.write(i == #words and "" or " ")
                end
            end
            gui.setFG(colors.white)
        else
            local words = {}
            for word in dat:gmatch("[^%s]+") do
               table.insert(words, word)
            end
            for i,word in pairs(words) do
                local x = gui.getPos()
                if x + #word > gui.w then
                    skipLine()
                end
                gui.write(word)
                if dat:sub(#dat, #dat) == " " then
                    gui.write(" ")
                else
                    gui.write(i == #words and "" or " ")
                end
            end
        end
    end
    skipLine()
end

function gui.buttons.add(label, txt, x, y, color, hlColor, func, arg)
    local button = {}
    button.label = label
    button.text = txt
    button.x = x
    button.y = y
    button.color = color
    button.highlight = hlColor
    button.func = func
    button.arg = arg

    table.insert(gui.buttons.list, button)
end

function gui.buttons.draw(label, hl)
    local oldColor = gui.primary.getBackgroundColor()
    for i,button in pairs(gui.buttons.list) do
        if button.label == label then
            gui.setPos(button.x, button.y)
            gui.setBG(hl and button.highlight or button.color)
            gui.write(" " .. button.text .. " ")
            gui.setBG(oldColor)
        end
    end
end

function gui.buttons.highlight(label)
    gui.buttons.draw(label, true)
    sleep(0.1)
    gui.buttons.draw(label)
end

function gui.buttons.drawAll()
    for i,button in pairs(gui.buttons.list) do
        gui.buttons.draw(button.label)
    end
end

function gui.buttons.update()
    while true do
        local e, b, x, y = os.pullEvent()
        if e == "mouse_click" or e == "monitor_touch" then
            for i,button in pairs(gui.buttons.list) do
                if x >= button.x and x <= button.x + string.len(button.text) + 1 and y == button.y then
                    gui.buttons.highlight(button.label)
                    button.func(button.arg)
                end
            end
        end
    end
end

return gui
