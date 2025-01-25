local gui = require("/apis/ecore_gui")
local konfig = require("/apis/konfig")

gui.setPrimary(peripheral.find("monitor"))

local input = {}

local buttonColor = colors.gray
local buttonHl = colors.blue

gui.primary.setTextScale(0.5)

local function onCorrect()

end

local function drawInputBar(color, text)
    gui.setPos(3, 2)
    gui.setBG(color or colors.lightGray)
    gui.write("           ")
    if text then
        gui.setPos(math.ceil(gui.w / 2 - #text / 2), 2)
        gui.write(text)
    end
    gui.setBG(colors.black)
end

local function addInput(num)
    if konfig.get("locked") == false then
        table.insert(input, num)
        gui.setPos(2 + #input, 2)
        gui.setBG(colors.lightGray)
        gui.write(konfig.get("hide_passcode") and "*" or num)
        gui.setBG(colors.black)
    end
end

local function backspace()
    if konfig.get("locked") == false then
        if #input > 0 then
            table.remove(input, #input)
            gui.setPos(3 + #input, 2)
            gui.setBG(colors.lightGray)
            gui.write(" ")
            gui.setBG(colors.black)   
        end
    end
end

local function enter()
    if konfig.get("locked") == false then
        input = table.concat(input)
        rednet.send(konfig.get("host_id"), "passwd " .. input)
        local id, msg = rednet.receive(5)
        if id == konfig.get("host_id") and msg == "success" then
            drawInputBar(colors.green, "CORRECT")
            parallel.waitForAll(onCorrect, function()  
                sleep(5)
                input = {}
                drawInputBar() 
            end) 
        elseif id == konfig.get("host_id") and msg == "locked" then
            konfig.set("locked", true)
            drawInputBar(colors.orange, "LOCKED")
        elseif id == nil then
            os.reboot()
        else
            drawInputBar(colors.red, "INCORRECT")
            sleep(5)
            input = {}
            drawInputBar()
        end
    end
end

local function lock()
    while true do
        local id,msg = rednet.receive()
        if id == konfig.get("host_id") then
            if msg == "lock" then
                konfig.set("locked", true)
                drawInputBar(colors.orange, "LOCKED")
            elseif msg == "unlock" then
                konfig.set("locked", false)
                drawInputBar()
            end
        end
    end
end

gui.buttons.add("one", "1", 3, 4, buttonColor, buttonHl, addInput, "1")
gui.buttons.add("two", "2", 7, 4, buttonColor, buttonHl, addInput, "2")
gui.buttons.add("three", "3", 11, 4, buttonColor, buttonHl, addInput, "3")
gui.buttons.add("four", "4", 3, 6, buttonColor, buttonHl, addInput, "4")
gui.buttons.add("five", "5", 7, 6, buttonColor, buttonHl, addInput, "5")
gui.buttons.add("six", "6", 11, 6, buttonColor, buttonHl,addInput, "6")
gui.buttons.add("seven", "7", 3, 8, buttonColor, buttonHl, addInput, "7")
gui.buttons.add("eight", "8", 7, 8, buttonColor, buttonHl, addInput, "8")
gui.buttons.add("nine", "9", 11, 8, buttonColor, buttonHl, addInput, "9")
gui.buttons.add("zero", "0", 7, 10, buttonColor, buttonHl, addInput, "0")
gui.buttons.add("confirm", ">", 11, 10, colors.green, colors.lime, enter)
gui.buttons.add("backspace", "x", 3, 10, colors.red, colors.orange, backspace)

gui.clear()
drawInputBar(konfig.get("locked") == true and colors.orange or nil, konfig.get("locked") == true and "LOCKED" or nil)

gui.setPrimary(term.current())
gui.clear()
gui.title("EBM SecureDoor v1.0", colors.red)
gui.writeLine(3, "Welcome to EBM SecureDoor! :)")
gui.writeLine(4, "This program was created by EBM Technologies")
gui.setPrimary(peripheral.find("monitor"))

gui.buttons.drawAll()
parallel.waitForAll(gui.buttons.update, lock)
