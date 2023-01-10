local P2 = math.pi/2
local P3 = 3 * math.pi/2

local function dist(ax, ay, bx, by)
	return math.sqrt((bx-ax) * (bx-ax) + (by-ay) * (by-ay))
end

---Perform a raycast on a square world
---@param map fun(x: integer, y: integer): boolean
---@param x integer
---@param y integer
---@param rayAngle number
---@return number
---@return number
---@return integer
---@return boolean
local function raycast(map, x, y, rayAngle)
    rayAngle = rayAngle % (2 * math.pi)

    local rayX, rayY

    -- Check Horizontal Lines
    local distHoriz = math.huge
    local horizX, horizY = x, y
    do
        local depthOfField = 0
        local aTan = -1/math.tan(rayAngle)
        local offsetX, offsetY = 0, 0

        if rayAngle > math.pi then -- Looking up
            rayY = math.floor(y) - 0.0001
            rayX = (y - rayY)*aTan + x
            offsetY = offsetY - 1
            offsetX = offsetX - offsetY*aTan
        elseif rayAngle < math.pi then -- Looking down
            rayY = math.floor(y) + 1
            rayX = (y - rayY)*aTan + x
            offsetY = offsetY + 64
            offsetX = offsetX - offsetY*aTan
        else -- Looking straight left or right
            rayX, rayY, depthOfField = x, y, 8
        end

        while depthOfField < 8 do
            local midX = math.floor(rayX)
            local midY = math.floor(rayY)
            if map(midX, midY) then -- Hit Wall
                horizX, horizY = rayX, rayY
                distHoriz = dist(x, y, horizX, horizY)
                depthOfField = 8
            else -- Next line
                rayX = rayX + offsetX
                rayY = rayY + offsetY
                depthOfField = depthOfField + 1
            end
        end
    end

    -- Check Vertical Lines
    local distVert = math.huge
    local vertX, vertY = x, y
    do
        local depthOfField = 0
        local nTan = -math.tan(rayAngle)
        local offsetX, offsetY = 0, 0

        if rayAngle > P2 and rayAngle < P3 then -- Looking left
            rayX = math.floor(x) - 0.0001
            rayY = (x - rayX)*nTan+y
            offsetX = offsetX - 1
            offsetY = offsetY - offsetX*nTan
        elseif rayAngle < P2 or rayAngle > P3 then -- Looking right
            rayX = math.floor(x) + 1
            rayY = (x - rayX)*nTan + y
            offsetX = offsetX + 1
            offsetY = offsetY - offsetX*nTan
        else -- Looking up or down
            rayX, rayY, depthOfField = x, y, 8
        end

        while depthOfField < 8 do
            local midX = math.floor(rayX)
            local midY = math.floor(rayY)
            if map(midX, midY) then -- Hit Wall
                vertX, vertY = rayX, rayY
                distVert = dist(x, y, vertX, vertY)
                depthOfField = 8
            else -- Next line
                rayX = rayX + offsetX
                rayY = rayY + offsetY
                depthOfField = depthOfField + 1
            end
        end
    end

    local distFinal
    if distVert <= distHoriz then -- Vertical wall hit
        rayX, rayY = vertX, vertY
        distFinal = distVert
    else -- Horizontal wall hit
        rayX, rayY = horizX, horizY
        distFinal = distHoriz
    end

    return rayX, rayY, distFinal, distVert <= distHoriz
end

return raycast