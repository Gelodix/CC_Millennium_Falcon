local state = {
    stabilization = {
        enabled = true,
        toleratedPitchDelta = 0.5,
        toleratedRollDelta = 0.5,
        stabilizationPower = 2,
    },
    sable = {
        x = 0,
        y = 0,
        z = 0,
        pitch = 0,
        roll = 0,
        yaw = 0,
        yawOffset = 0,
        swapPitchAndRoll = false,
        invertPitch = false,
        invertRoll = true,
    },
    altitudeControl = {
        enabled = false,
        currentAltitude = 0,
        aimedAltitude = 0,
        powerBeforeGoingUp = 9,

    },
    controls = {
        shipEnabled = true,
        thrustInput = 0,
        staticFlightMode = true,
        increaseAltitude = false,
        decreaseAltitude = false,
        toggle_flight_mode_unpressed = true,
        toggle_height_control_unpressed =  true,
        toggle_landing_gear_unpressed = true,
        front_left_thruster_strength = 0,
        front_right_thruster_strength = 0,
        back_left_thruster_strength = 0,
        back_right_thruster_strength = 0,
    },
}

return state