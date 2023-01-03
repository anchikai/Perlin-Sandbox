local Global = require("lua.GlobalValues")

local Cave = {
    Grid = {}
}

local WORLD_SIZE = 64 ---@type number
WORLD_SIZE = WORLD_SIZE + 1

---@param x number
---@return number
local function round(x)
    return math.floor(x + 0.5)
end

---@param caveSize number
local function generateCave(caveSize)
    -- Fill each tile in our grid with noise.
    local baseX = 10000 * love.math.random()
    local baseY = 10000 * love.math.random()
    for y = -caveSize, caveSize do
        Cave.Grid[y] = {}
        for x = -caveSize, caveSize do
            Cave.Grid[y][x] = round(love.math.noise(baseX + 0.1 * x, baseY + 0.2 * y))
            Cave.Grid[-caveSize][x] = 2
            Cave.Grid[y][-caveSize] = 2
        end
    end
end

function Cave.load()
    generateCave(WORLD_SIZE)

    for y = -WORLD_SIZE, WORLD_SIZE - 1 do
        for x = -WORLD_SIZE, WORLD_SIZE - 1 do
            Cave.Grid[x][WORLD_SIZE - 1] = 2
            Cave.Grid[WORLD_SIZE - 1][y] = 2
        end
    end
end

---@param dt number
function Cave.update(dt)
    
end

function Cave.draw()
    for y = -WORLD_SIZE, WORLD_SIZE - 1 do
        for x = -WORLD_SIZE, WORLD_SIZE - 1 do
            if Cave.Grid[x][y] == 1 then
                love.graphics.setColor(0.2, 0.2, 0.2, 1)
                love.graphics.rectangle("fill", x * Global.unitSize, y * Global.unitSize, Global.unitSize, Global.unitSize)
            elseif Cave.Grid[x][y] == 2 then
                love.graphics.setColor(0, 0, 0, 1)
                love.graphics.rectangle("fill", x * Global.unitSize, y * Global.unitSize, Global.unitSize, Global.unitSize)
            end
        end
    end
end

return Cave