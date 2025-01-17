local gui = {}

gui.primary = nil

gui.bgColor = nil

gui.w = 0
gui.h = 0

gui.objects = {
    inputs = {}
}

gui.currentSelection = nil


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

local function skipLine()
    local x,y = gui.primary.getCursorPos()
    gui.primary.setCursorPos(1, y + 1)
end

function gui.write(str)
    gui.primary.write(str)
end

function gui.print(str)
    local words = {}
    for word in str:gmatch("[^%s]+") do
       table.insert(words, word)
    end
    for i,word in pairs(words) do
        local x = gui.primary.getCursorPos()
        if x + #word > gui.w then
            skipLine()
        end
        gui.write(word)
        gui.write(i == #words and "" or " ")
    end
    skipLine()
end

function gui.writeLine(line, str)
    gui.clearLine(line)
    gui.primary.setCursorPos(1, line)
    gui.write(str)
end

function gui.writeFormatted(...)
    local formatting = {...}

    for i,dat in pairs(formatting) do
        if type(dat) == "table" then
            gui.primary.setTextColor(dat[2])
            gui.write(dat[1])
            gui.primary.setTextColor(colors.white)
        else
            gui.write(dat)
        end
    end
end

function gui.writeLineFormatted(line, ...)
    local formatting = {...}

    gui.clearLine(line)
    gui.primary.setCursorPos(1, line)
    for i,dat in pairs(formatting) do
        if type(dat) == "table" then
            gui.primary.setTextColor(dat[2])
            gui.write(dat[1])
            gui.primary.setTextColor(colors.white)
        else
            gui.write(dat)
        end
    end
end

function gui.printFormatted(...)
    local formatting = {...}

    for i,dat in pairs(formatting) do
        if type(dat) == "table" then
            gui.primary.setTextColor(dat[2])
            local words = {}
            for word in dat[1]:gmatch("[^%s]+") do
               table.insert(words, word)
            end
            for i,word in pairs(words) do
                local x = gui.primary.getCursorPos()
                if x + #word > gui.w then
                    skipLine()
                end
                gui.write(word)
                gui.write(i == #words and not dat[3] and "" or " ")
            end
            gui.primary.setTextColor(colors.white)
        else
            local words = {}
            for word in dat:gmatch("[^%s]+") do
               table.insert(words, word)
            end
            for i,word in pairs(words) do
                local x = gui.primary.getCursorPos()
                if x + #word > gui.w then
                    skipLine()
                end
                gui.write(word)
                gui.write(i == #words and "" or " ")
            end
        end
    end
    skipLine()
end


function gui.clearLine(line)
    gui.primary.setCursorPos(1, line)
    for i = 1, gui.w do
        gui.write(" ")
    end
end

function gui.clear()
    for i = 1,gui.h do
        gui.clearLine(i)
    end
end

function gui.setTitle(title, color)
    if color then
        gui.primary.setBackgroundColor(color)
    end
    gui.clearLine(1)
    gui.primary.setCursorPos(math.ceil(gui.w / 2 - #title / 2), 1)
    gui.primary.write(title)
    gui.primary.setBackgroundColor(gui.bgColor)
end

function gui.addObject(objType, objLabel, ...)
    local args = {...}
    local object = {}

    if objType == "input" then
        object.type = objType
        object.label = objLabel
        object.length = args[1]
        object.x = args[2]
        object.y = args[3]
        object.color = args[4]
        if args[6] then
            local inTable = {}
            for char in args[6]:gmatch("[^.]") do
                table.insert(inTable, char)
            end
            args[6] = inTable
        end
        object.func = args[5]
        object.input = args[6] or {}
        object.enabled = false
        object.maxX = object.x + object.length
    elseif objType == "button" then
        object.type = objType
        object.label = objLabel
        object.text = args[1]
        object.x = args[2]
        object.y = args[3]
        object.color = args[4]
        object.hlColor = args[5]
        object.enabled = false
        object.func = args[7]
        object.maxX = object.x + #object.text + 2
    end

    table.insert(gui.objects, object)
end

function gui.drawObject(identifier)
    if identifier == "all" then
        for i,object in ipairs(gui.objects) do
            gui.primary.setCursorPos(object.x, object.y)
            gui.primary.setBackgroundColor(object.color)
            if object.type == "input" then
                for i = 1,object.length do
                    gui.primary.write(" ")
                end
                gui.primary.setCursorPos(object.x, object.y)
                for i,char in pairs(object.input) do
                    write(char)
                end
                object.enabled = true
            elseif object.type == "button" then
                gui.primary.write(" " .. object.text .. " ")
                object.enabled = true
            end
        end
    elseif identifier == "input" or identifier == "button" then
        for i,object in ipairs(gui.objects) do
            if object.type == identifier then
                gui.primary.setCursorPos(object.x, object.y)
                gui.primary.setBackgroundColor(object.color)
                if object.type == "input" then
                    for i = 1,object.length do
                        gui.primary.write(" ")
                    end
                    gui.primary.setCursorPos(object.x, object.y)
                    for i,char in pairs(object.input) do
                        write(char)
                    end
                    object.enabled = true
                elseif object.type == "button" then
                    gui.primary.write(" " .. object.text .. " ")
                    object.enabled = true
                end
            end
        end
    else
        for i,object in ipairs(gui.objects) do
            if object.label == identifier then
                gui.primary.setCursorPos(object.x, object.y)
                gui.primary.setBackgroundColor(object.color)
                if object.type == "input" then
                    for i = 1,object.length do
                        gui.primary.write(" ")
                    end
                    gui.primary.setCursorPos(object.x, object.y)
                    for i,char in pairs(object.input) do
                        write(char)
                    end
                    object.enabled = true
                elseif object.type == "button" then
                    gui.primary.write(" " .. object.text .. " ")
                    object.enabled = true
                end
            end
        end
    end
end

function gui.hideObject(identifier)
    if identifier == "all" then
        for i,object in ipairs(gui.objects) do
            gui.primary.setBackgroundColor(gui.bgColor)
            gui.primary.setCursorPos(object.x, object.y)
            for i = object.x,object.maxX do
                gui.primary.write(" ")
            end
            object.enabled = false
        end
    elseif identifier == "input" or identifier == "button" then
        for i,object in ipairs(gui.objects) do
            if object.type == identifier then
                gui.primary.setBackgroundColor(gui.bgColor)
                gui.primary.setCursorPos(object.x, object.y)
                for i = object.x,object.maxX do
                    gui.primary.write(" ")
                end
                object.enabled = false
            end
        end
    else
        for i,object in ipairs(gui.objects) do
            if object.label == identifier then
                gui.primary.setBackgroundColor(gui.bgColor)
                gui.primary.setCursorPos(object.x, object.y)
                for i = object.x,object.maxX do
                    gui.primary.write(" ")
                end
                object.enabled = false
            end
        end
    end
end

function gui.update()
    while true do
        local event, char, x, y = os.pullEvent()
        if event == "monitor_touch" or event == "mouse_click" then
            for i,object in ipairs(gui.objects) do
                if x >= object.x and x <= object.maxX and y == object.y then
                    if object.enabled == true then
                        if object.type == "input" then
                            gui.primary.setCursorPos(object.x + #object.input, object.y)
                            gui.currentSelection = object
                            gui.primary.setBackgroundColor(object.color)
                        elseif object.type == "button" then
                            object.func()
                        end
                    end
                end
            end
        elseif event == "char" then
            if gui.currentSelection then
                if  #gui.currentSelection.input < gui.currentSelection.length then
                    gui.primary.write(char)
                    table.insert(gui.currentSelection.input, char)
                end
            end
        elseif event == "key" then
            if char == keys.backspace and gui.currentSelection then
                if #gui.currentSelection.input > 0 then
                    local x,y = gui.primary.getCursorPos()
                    gui.primary.setCursorPos(x - 1, y)
                    write(" ")
                    gui.primary.setCursorPos(x - 1, y)
                    table.remove(gui.currentSelection.input, #gui.currentSelection.input)
                end
            elseif char == keys.enter then
                if gui.currentSelection then
                    if gui.currentSelection.func then
                        gui.currentSelection.func(gui.currentSelection.label, table.concat(gui.currentSelection.input))
                    end
                    gui.currentSelection = nil
                end
            end
        end
    end
end

return gui
