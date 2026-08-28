local state = require("faucon_files.state")
local peripherals =  require("faucon_files.peripherals")
local quaternion = require("libraries.quaternion")
local utils = require("faucon_files.utils")


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
local IN_INCREASE_HEIGHT = "left" -- signal 0 or 15 - keypad 1
local IN_DECREASE_HEIGHT = "right" -- signal 0 or 15 - keypad 2
local IN_MANUAL_THRUST = "front" -- signal from 0 to 15
local IN_ON_OFF_SHIP = "back" -- signal 0 or 15 - keypad 3
local IN_LANDING_GEAR = "bottom" -- signal 0 or 15 - keypad 4
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
local OUT_LANDING_GEAR = "bottom" -- signal 0 or 15
-- front right vector controls
local OUT_FRONT_RIGHT_VECTOR_FRONT = "front" -- signal from 0 to 15
local OUT_FRONT_RIGHT_VECTOR_BACK = "back" -- signal from 0 to 15
local OUT_FRONT_RIGHT_VECTOR_LEFT = "left" -- signal from 0 to 15
local OUT_FRONT_RIGHT_VECTOR_RIGHT = "right" -- signal from 0 to 15
local OUT_MIDDLE_FORWARD_THRUSTERS = "bottom" -- signal from 0 to 15
-- back left vector controls
local OUT_BACK_LEFT_VECTOR_FRONT = "front" -- signal from 0 to 15
local OUT_BACK_LEFT_VECTOR_BACK = "back" -- signal from 0 to 15
local OUT_BACK_LEFT_VECTOR_LEFT = "left" -- signal from 0 to 15
local OUT_BACK_LEFT_VECTOR_RIGHT = "right" -- signal from 0 to 15
local OUT_RIGHT_FORWARD_THRUSTERS = "bottom" -- signal from 0 to 15
-- back right vector controls
local OUT_BACK_RIGHT_VECTOR_FRONT = "front" -- signal from 0 to 15
local OUT_BACK_RIGHT_VECTOR_BACK = "back" -- signal from 0 to 15
local OUT_BACK_RIGHT_VECTOR_LEFT = "left" -- signal from 0 to 15
local OUT_BACK_RIGHT_VECTOR_RIGHT = "right" -- signal from 0 to 15
local OUT_LEFT_FORWARD_THRUSTERS = "bottom" -- signal from 0 to 15

local controls = {}

function controls.taskStabilisationLogic()
    while true do
        state.controls.thrustInput = peripherals.relay_input.getAnalogInput(IN_MANUAL_THRUST)
        if sublevel then
            if sublevel.isInPlotGrid() then
                local pose = sublevel.getLogicalPose()

                if pose.position then
                    state.sable.x = utils.roundFloat(pose.position.x, 3)
                    state.sable.y = utils.roundFloat(pose.position.y, 3)
                    state.sable.z = utils.roundFloat(pose.position.z, 3)
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

                    state.sable.yaw = utils.roundFloat((rawYawDeg + state.sable.yawOffset + 360) % 360, 3)

                    local finalPitch = rawPitchDeg
                    local finalRoll = rawRollDeg

                    if state.sable.swapPitchAndRoll then
                        finalPitch = rawRollDeg
                        finalRoll = rawPitchDeg
                    end

                    if state.sable.invertPitch then finalPitch = -finalPitch end
                    if state.sable.invertRoll then finalRoll = -finalRoll end

                    state.sable.pitch = utils.roundFloat(finalPitch, 3)
                    state.sable.roll = utils.roundFloat(finalRoll, 3)
                end
            end
        end

        if state.controls.thrustInput > 0 then
            state.controls.front_left_thruster_strength = state.controls.thrustInput
            state.controls.front_right_thruster_strength = state.controls.thrustInput
            state.controls.back_left_thruster_strength = state.controls.thrustInput
            state.controls.back_right_thruster_strength = state.controls.thrustInput

            local correctedPitch = false

            if state.sable.pitch > state.stabilization.toleratedPitchDelta then
                correctedPitch = true
                state.controls.back_left_thruster_strength = state.controls.back_left_thruster_strength + state.stabilization.stabilizationPower
                state.controls.back_right_thruster_strength = state.controls.back_right_thruster_strength + state.stabilization.stabilizationPower
                state.controls.front_left_thruster_strength = state.controls.front_left_thruster_strength - state.stabilization.stabilizationPower
                state.controls.front_right_thruster_strength = state.controls.front_right_thruster_strength - state.stabilization.stabilizationPower
                
            elseif state.sable.pitch < -state.stabilization.toleratedPitchDelta then
                correctedPitch = true

                state.controls.front_left_thruster_strength = state.controls.front_left_thruster_strength + state.stabilization.stabilizationPower
                state.controls.front_right_thruster_strength = state.controls.front_right_thruster_strength + state.stabilization.stabilizationPower
                state.controls.back_left_thruster_strength = state.controls.back_left_thruster_strength - state.stabilization.stabilizationPower
                state.controls.back_right_thruster_strength = state.controls.back_right_thruster_strength - state.stabilization.stabilizationPower
            end

            if state.sable.roll > state.stabilization.toleratedRollDelta then
                state.controls.front_right_thruster_strength = state.controls.front_right_thruster_strength + state.stabilization.stabilizationPower
                state.controls.back_right_thruster_strength = state.controls.back_right_thruster_strength + state.stabilization.stabilizationPower
                state.controls.front_left_thruster_strength = state.controls.front_left_thruster_strength - state.stabilization.stabilizationPower
                state.controls.back_left_thruster_strength = state.controls.back_left_thruster_strength - state.stabilization.stabilizationPower
            elseif state.sable.roll < - state.stabilization.toleratedRollDelta then
                state.controls.front_left_thruster_strength = state.controls.front_left_thruster_strength + state.stabilization.stabilizationPower
                state.controls.back_left_thruster_strength = state.controls.back_left_thruster_strength + state.stabilization.stabilizationPower
                state.controls.front_right_thruster_strength = state.controls.front_right_thruster_strength - state.stabilization.stabilizationPower
                state.controls.back_right_thruster_strength = state.controls.back_right_thruster_strength - state.stabilization.stabilizationPower
            end
        else
            state.controls.front_left_thruster_strength = 0
            state.controls.back_left_thruster_strength = 0
            state.controls.front_right_thruster_strength = 0
            state.controls.back_right_thruster_strength = 0
        end

        sleep(0.05)
    end
end


function controls.taskActuators()
    while true do
        peripherals.main_output_relay.setAnalogOutput(OUT_FRONT_LEFT_THRUSTER_POWER, utils.normalizeRedstoneOutputSignal(state.controls.front_left_thruster_strength))
        peripherals.main_output_relay.setAnalogOutput(OUT_FRONT_RIGHT_THRUSTER_POWER, utils.normalizeRedstoneOutputSignal(state.controls.front_right_thruster_strength))
        peripherals.main_output_relay.setAnalogOutput(OUT_BACK_LEFT_THRUSTER_POWER, utils.normalizeRedstoneOutputSignal(state.controls.back_left_thruster_strength))
        peripherals.main_output_relay.setAnalogOutput(OUT_BACK_RIGHT_THRUSTER_POWER, utils.normalizeRedstoneOutputSignal(state.controls.back_right_thruster_strength))
        sleep(0.05)
    end
end


return controls