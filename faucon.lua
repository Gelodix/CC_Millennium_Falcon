local controls =  require("faucon_files.controls")
local state = require("faucon_files.state")

local function show_data()
    while true do 
        term.clear()
        term.setCursorPos(1,1)
        print("Position : ")
        print("- X : " .. state.sable.x)
        print("- Y : " .. state.sable.y)
        print("- Z : " .. state.sable.z)
        print("Angles :")
        print("- Pitch : " .. state.sable.pitch)
        print("- Roll : " .. state.sable.roll)
        print("- Yaw : " .. state.sable.yaw)
        sleep(0)
    end
end

parallel.waitForAll(show_data, controls.taskStabilisationLogic)