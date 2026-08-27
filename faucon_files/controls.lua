local state = require("faucon_files.state")
local peripherals =  require("faucon_files.peripherals")
local quaternion = require("libraries.quaternion")


-- #########################
-- inputs/outputs definition
-- #########################
-- main computer
local IN_YOKE_FWD = "front" -- signal from 0 to 15
local IN_YOKE_BWD = "back" -- signal from 0 to 15
local IN_YOKE_LEFT = "left" -- signal from 0 to 15
local IN_YOKE_RIGHT = "right" -- signal from 0 to 15
local IN_TOGGLE_FLIGHT_MODE = "top" -- signal 0 or 15
local IN_TOGGLE_HEIGHT_CONTROL = "bottom" -- signal 0 or 15
-- secondary input redstone_relay
local IN_INCREASE_HEIGHT = "top" -- signal 0 or 15
local IN_DECREASE_HEIGHT = "bottom" -- signal 0 or 15
local IN_MANUAL_THRUST = "front" -- signal from 0 to 15
local IN_ON_OFF_SHIP = "back" -- signal 0 or 15
-- main thrust redstone_relay
local OUT_FRONT_LEFT_THRUSTER_POWER = "front" -- signal from 0 to 15
local OUT_FRONT_RIGHT_THRUSTER_POWER = "right" -- signal from 0 to 15
local OUT_BACK_LEFT_THRUSTER_POWER = "left" -- signal from 0 to 15
local OUT_BACK_RIGHT_THRUSTER_POWER = "back" -- signal from 0 to 15
local OUT_LEVITITE = "bottom" -- signal 0 or 15
-- front left vector controls
local OUT_FRONT_LEFT_VECTOR_FRONT = "front" -- signal from 0 to 15
local OUT_FRONT_LEFT_VECTOR_BACK = "back" -- signal from 0 to 15
local OUT_FRONT_LEFT_VECTOR_LEFT = "left" -- signal from 0 to 15
local OUT_FRONT_LEFT_VECTOR_RIGHT = "right" -- signal from 0 to 15
-- front right vector controls
local OUT_FRONT_RIGHT_VECTOR_FRONT = "front" -- signal from 0 to 15
local OUT_FRONT_RIGHT_VECTOR_BACK = "back" -- signal from 0 to 15
local OUT_FRONT_RIGHT_VECTOR_LEFT = "left" -- signal from 0 to 15
local OUT_FRONT_RIGHT_VECTOR_RIGHT = "right" -- signal from 0 to 15
-- back left vector controls
local OUT_BACK_LEFT_VECTOR_FRONT = "front" -- signal from 0 to 15
local OUT_BACK_LEFT_VECTOR_BACK = "back" -- signal from 0 to 15
local OUT_BACK_LEFT_VECTOR_LEFT = "left" -- signal from 0 to 15
local OUT_BACK_LEFT_VECTOR_RIGHT = "right" -- signal from 0 to 15
-- back right vector controls
local OUT_BACK_RIGHT_VECTOR_FRONT = "front" -- signal from 0 to 15
local OUT_BACK_RIGHT_VECTOR_BACK = "back" -- signal from 0 to 15
local OUT_BACK_RIGHT_VECTOR_LEFT = "left" -- signal from 0 to 15
local OUT_BACK_RIGHT_VECTOR_RIGHT = "right" -- signal from 0 to 15

local controls = {}

function controls.taskStabilisationLogic()
    while true do
        if not state.altitudeControl.enabled then
            state.controls.thrustInput = peripherals.relay_input.getAnalogInput(IN_MANUAL_THRUST)
        end
        if sublevel then
            if sublevel.isInPlotGrid() then
                local pose = sublevel.getLogicalPose()

                if pose.position then
                    state.sable.x = pose.position.x
                    state.sable.y = pose.position.y
                    state.sable.z = pose.position.z
                end
            
                if pose.orientation and pose.orientation.v then
                    local q = quaternion.fromComponents(
                        pose.orientation.v.x,
                        pose.orientation.v.y,
                        pose.orientation.v.z,
                        pose.orientation.a
                    )
                    q:normalize()

                    local pitchRad, yawRad, rollRad = q:toEuler()

                    local rawPitchDeg = math.deg(pitchRad)
                    local rawYawDeg = math.deg(yawRad)
                    local rawRollDeg = math.deg(rollRad)

                    state.sable.yaw = (rawYawDeg + state.sable.yawOffset + 360) % 360

                    local finalPitch = rawPitchDeg
                    local finalRoll = rawRollDeg

                    if state.sable.swapPitchAndRoll then
                        finalPitch = rawRollDeg
                        finalRoll = rawPitchDeg
                    end

                    if state.sable.invertPitch then finalPitch = -finalPitch end
                    if state.sable.invertRoll then finalRoll = -finalRoll end

                    state.sable.pitch = finalPitch
                    state.sable.roll = finalRoll


                end
            end
        end
        sleep(0.05)
    end
end

return controls