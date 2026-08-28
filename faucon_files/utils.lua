local utils = {}

function utils.roundFloat(float--[[float]], digitToKeep--[[int]])
    local ratio = 10^digitToKeep
    return math.floor(float * ratio + 0.5) / ratio
end

function utils.normalizeRedstoneOutputSignal(signal--[[int]])
    return math.max(0, math.min(15,signal))
end

return utils