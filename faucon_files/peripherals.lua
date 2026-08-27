local peripherals = {}

peripherals.relay_input = peripheral.wrap("redstone_relay_1")
peripherals.main_output_relay = peripheral.wrap("redstone_relay_2")
peripherals.front_left_vector_relay = peripheral.wrap("redstone_relay_3")
peripherals.front_right_vector_relay = peripheral.wrap("redstone_relay_4")
peripherals.back_left_vector_relay = peripheral.wrap("redstone_relay_5")
peripherals.back_right_vector_relay = peripheral.wrap("redstone_relay_6")

function peripherals.checkSetup()
    local error = false

    -- peripherals checks
    if not peripherals.relay_input then
        print("Error : no input relay found")
        error = true
    end

    if not peripherals.main_output_relay then
        print("Error : no main output relay found")
        error = true
    end

    if not peripherals.front_left_vector_relay then
        print("Error : no front left vector relay found")
        error = true
    end

    if not peripherals.front_right_vector_relay then
        print("Error : no front right vector relay found")
        error = true
    end

    if not peripherals.back_left_vector_relay then
        print("Error : no back left vector relay found")
        error = true
    end

    if not peripherals.back_right_vector_relay then
        print("Error : no back right vector relay found")
        error = true
    end

    if not sublevel then 
        print("Error : CC:Sable API missing")
        error = true
    end

    if not sublevel.isInPlotGrid() then
        print("Error : the ship isn't assembled")
        error = true
    end

    return not error
end

return peripherals