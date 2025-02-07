-- Config Options
-- Area of the Total Display
local bounds = {
    bl = {x=1.8456, y=4.34, z=0.22},
    br = {x=1.8456, y=4.82, z=0.22},
    tl = {x=1.8456, y=4.34, z=0.34},
    tr = {x=1.8456, y=4.82, z=0.34}
}

local textureDict = 'addon_prop_truck_scales'
local modelHash = `addon_prop_truck_scales`

local callThreshhold = 5000
local lastCallTime = 60000

local adjust = 0.006  -- Make each segment slightly smaller

-- Initialize Tables and load textures
RequestStreamedTextureDict(textureDict, false)
local states = {"off0", "off0", "off0", "off0", "off0", "off0"}
local offsets = {}
local pointTable = {}

-- Calculates Coords for each Segment Polygon
local function firstCall()
    local plyPos = GetEntityCoords(PlayerPedId())
    local obj = GetClosestObjectOfType(plyPos.x, plyPos.y, plyPos.z, 50.0, modelHash, false, false, false)
    
    Citizen.Wait(1000)
    
    -- Calculate step size based on total width of whole display and amount of segments
    local stepSize = math.abs(bounds.tr.y-bounds.tl.y) / #states
    
    for index = 1, #states do
        local yOffset = stepSize * (index - 1)
    
        pointTable[index] = {
            topleft = {x = bounds.tl.x, y = bounds.tl.y + yOffset + adjust, z = bounds.tl.z},
            topright = {x = bounds.tl.x, y = bounds.tl.y + yOffset + stepSize - adjust, z = bounds.tl.z},
            bottomleft = {x = bounds.bl.x, y = bounds.bl.y + yOffset + adjust, z = bounds.bl.z},
            bottomright = {x = bounds.bl.x, y = bounds.bl.y + yOffset + stepSize - adjust, z = bounds.bl.z}
        }
    end

    for index, points in pairs(pointTable) do
        offsets[index] = {}
        for corner, coords in pairs(points) do
            local worldCoords = GetOffsetFromEntityInWorldCoords(obj, coords.x, coords.y, coords.z)
            offsets[index][corner] = {x = worldCoords.x, y = worldCoords.y, z = worldCoords.z}
        end
    end
end

-- Function to draw two textured polygons
local function drawSegment(display, state)
    DrawTexturedPoly(display.bottomright.x, display.bottomright.y, display.bottomright.z,
                     display.topright.x, display.topright.y, display.topright.z,
                     display.topleft.x, display.topleft.y, display.topleft.z,
                     255, 255, 255, 255, textureDict, state, 
                     1.0, 1.0, 1.0, 1.0, 0.0, 1.0, 0.0, 0.0, 1.0)

    DrawTexturedPoly(display.topleft.x, display.topleft.y, display.topleft.z,
                     display.bottomleft.x, display.bottomleft.y, display.bottomleft.z,
                     display.bottomright.x, display.bottomright.y, display.bottomright.z,
                     255, 255, 255, 255, textureDict, state,
                     0.0, 0.0, 1.0, 0.0, 1.0, 1.0, 1.0, 1.0, 0.0)
end

-- Function to assign state to each number in string
local function processString(text)
    local formatstr = (text:match("%d+")):reverse()
    -- Turns off display if weights is 0 
    if formatstr == '0' then
        for index, state in ipairs(states) do
            states[index] = 'off0'
        end
        return
    end

    -- Iterate through the array from right to left, assigning the first String number to the last pos in array and so on
    for index = #states, 1, -1 do
        local strIndex = #states - index + 1
        local digit = string.sub(formatstr, strIndex, strIndex)
        if digit == '' then digit = '0' end
        states[index] = 'segment'..digit
    end
end

-- Main Function which gets called by client.lua
function Draw3DText(x,y,z,text,scl, color)
    -- If time since last call is over Threshhold, recalculate offsets and coordinates
    local currentTime = GetGameTimer()
    if currentTime - lastCallTime > callThreshhold then
        firstCall()
    end
    lastCallTime = currentTime

    -- Matches the first digit sequence in text and passes it to processString
    local formatstr = string.match(text, "%d+")
    processString(formatstr)

    -- Draws each segmnent one at a time
    for i = 1, #states do
        drawSegment(offsets[i], states[i])
    end
end

function notify(notificationText)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(notificationText)
    DrawNotification(true, true)
end
