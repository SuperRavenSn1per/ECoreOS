local gui = require("/apis/ecore_gui")
local konfig = require("/apis/konfig")

local password = "1271"

gui.setPrimary(peripheral.find("monitor"))

local input = {}

local buttonColor = colors.gray
local buttonHl = colors.blue

gui.primary.setTextScale(0.5)

local function onCorrect()
    
end

local function drawInputBar(color)
    gui.primary.setCursorPos(3, 2)
    gui.primary.setBackgroundColor(color or colors.lightGray)
    gui.primary.write("           ")
    gui.primary.setCursorPos(3,2)
    gui.primary.setBackgroundColor(colors.black)
end

local function addInput(num)
    table.insert(input, num)
    gui.primary.setCursorPos(2 + #input, 2)
    gui.primary.setBackgroundColor(colors.lightGray)
    gui.primary.write(konfig.get("hide_passcode") and "*" or num)
    gui.primary.setBackgroundColor(colors.black)
end

local function backspace()
    if #input > 0 then
       table.remove(input, #input)
       gui.primary.setCursorPos(3 + #input, 2)
       gui.primary.setBackgroundColor(colors.lightGray)
       gui.primary.write(" ")
       gui.primary.setBackgroundColor(colors.black)   
    end
end

local function enter()
    input = table.concat(input)
    if input == password then
        drawInputBar(colors.lime)
        onCorrect()
        sleep(1)
        input = {}
        drawInputBar()
    else
        drawInputBar(colors.red)
        sleep(1)
        input = {}
        drawInputBar()
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
drawInputBar()

gui.setPrimary(term.current())
gui.clear()
gui.title("EBM SecureDoor v1.0", colors.red)
gui.write(3, "Welcome to EBM SecureDoor! :)")
gui.write(4, "This program was created by EBM Technologies")
gui.setPrimary(peripheral.find("monitor"))

gui.buttons.drawAll()
gui.buttons.update()
