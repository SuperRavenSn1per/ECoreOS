local gui = require("/apis/ecore_gui")
local konfig = require("/apis/konfig")

gui.setPrimary(term.current())

gui.clear(colors.black)
gui.title("EBM Secure Controller v1.0", colors.gray)

gui.write(3, "Commands:")
gui.writeFormatted(4, {"verify [id] - ", colors.lightGray}, "Verifies a keypad.")
gui.writeFormatted(5, {"delete [id] - ", colors.lightGray}, "Deletes a keypad.")
gui.writeFormatted(6, {"label [id] [label] - ", colors.lightGray}, "Change or add label to keypad.")
gui.writeFormatted(7, {"changepass [id] [newpass] - ", colors.lightGray}, "Change keypad password.")
gui.writeFormatted(8, {"lock [id/all] - ", colors.lightGray}, "Lock a keypad.")
gui.writeFormatted(9, {"unlock [id/all] - ", colors.lightGray}, "Unlock a keypad.")

gui.write(11, "Command > ")
while true do
    local input = read()
    rednet.send(konfig.get("host_id"), input)
    local id,msg = rednet.receive()
    if id == konfig.get("host_id") then
        if msg == "success" then
            gui.writeFormatted(12, {"Success!", colors.green})
        else
            gui.writeFormatted(12, {"Failed!", colors.red})
            gui.writeFormatted(13, {"Error: ", colors.lightGray}, msg)
        end
        sleep(5)
        gui.clearLine(11)
        gui.clearLine(12)
        gui.clearLine(13)
        gui.write(11, "Command > ")
    end
end
