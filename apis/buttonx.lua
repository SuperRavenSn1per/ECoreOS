local bx = {}

bx.primary = term.current()

bx.buttons = {}

function bx.setPrimary(screen)
    if screen then
        bx.primary = screen    
    else
        print(screen or "nil" .. " is not a valid screen!")
    end
end

function bx.addButton(label, txt, x, y, color, hlColor, func)
    local button = {}
    button.label = label
    button.text = txt
    button.x = x
    button.y = y
    button.color = color
    button.highlight = hlColor
    button.func = func

    table.insert(bx.buttons, button)
end

function bx.drawButton(label, hl)
    local oldColor = bx.primary.getBackgroundColor()
    for i,button in pairs(bx.buttons) do
        if button.label == label then
            bx.primary.setCursorPos(button.x, button.y)
            bx.primary.setBackgroundColor(hl and button.highlight or button.color)
            bx.primary.write(" " .. button.text .. " ")
            bx.primary.setBackgroundColor(oldColor)
        end
    end
end

function bx.highlightButton(label)
    bx.drawButton(label, true)
    sleep(0.1)
    bx.drawButton(label)
end

function bx.drawButtons()
    for i,button in pairs(bx.buttons) do
        bx.drawButton(button.label)
    end
end

function bx.update()
    while true do
        local e, b, x, y = os.pullEvent("mouse_click")
        if e == "mouse_click" or e == "monitor_touch" then
            for i,button in pairs(bx.buttons) do
                if x >= button.x and x <= button.x + string.len(button.text) + 1 and y == button.y then
                    bx.highlightButton(button.label)
                    button.func()
                end
            end
        end
    end
end

return bx

