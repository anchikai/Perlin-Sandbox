local Global = require("lua.GlobalValues")
local Camera = require("lua.Camera")
local BlockType = require("lua.BlockType")

local Cave = {
    Grid = {}
}

local WORLD_SIZE = 128 ---@type number
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
            Cave.Grid[y][x] = round(love.math.noise(baseX + 0.1 * x, baseY + 0.1 * y))
        end
    end
end

---@param caveSize number
local function addWalls(caveSize)
    for y = -caveSize, caveSize - 1 do
        for x = -caveSize, caveSize - 1 do
            Cave.Grid[-caveSize][x] = BlockType.WorldBorder
            Cave.Grid[y][-caveSize] = BlockType.WorldBorder
            Cave.Grid[x][caveSize - 1] = BlockType.WorldBorder
            Cave.Grid[caveSize - 1][y] = BlockType.WorldBorder
        end
    end
end

---@param caveSize number
local function addOres(caveSize)
    for y = -caveSize, caveSize - 1 do
        for x = -caveSize, caveSize - 1 do
            if Cave.Grid[x][y] == 1 then
                if Cave.Grid[x - 1][y] ~= BlockType.Air and Cave.Grid[x + 1][y] ~= BlockType.Air
                and Cave.Grid[x][y - 1] ~= BlockType.Air and Cave.Grid[x][y + 1] ~= BlockType.Air then
                    if love.math.random() <= 0.02 then
                        Cave.Grid[x][y] = BlockType.Iron
                    end
                    if love.math.random() <= 0.005 then
                        Cave.Grid[x][y] = BlockType.Gold
                    end
                end
            end
        end
    end
end

---@param x number
---@param y number
---@param BlockType BlockType
function Cave.setBlock(x, y, BlockType)
    Cave.Grid[x][y] = BlockType
end

function Cave.load()
    generateCave(WORLD_SIZE)
    addWalls(WORLD_SIZE)
    addOres(WORLD_SIZE)
end

---@param dt number
function Cave.update(dt)
    
end

function Cave.draw()
    for y = -WORLD_SIZE, WORLD_SIZE - 1 do
        for x = -WORLD_SIZE, WORLD_SIZE - 1 do
            local r, g, b, a = 1, 1, 1, 1
            if Cave.Grid[x][y] == BlockType.WorldBorder then
                r, g, b, a = 0, 0, 0, 1
            elseif Cave.Grid[x][y] == BlockType.Stone then
                r, g, b, a = 0.2, 0.2, 0.2, 1
            elseif Cave.Grid[x][y] == BlockType.Iron then
                r, g, b, a = 0.894, 0.769, 0.588, 1
            elseif Cave.Grid[x][y] == BlockType.Gold then
                r, g, b, a = 1, 1, 0.33, 1
            end
            if Cave.Grid[x][y] ~= BlockType.Air then
                love.graphics.setColor(r, g, b, a)
                love.graphics.rectangle("fill", x * Global.unitSize, y * Global.unitSize, Global.unitSize, Global.unitSize)
            end
        end
    end
end

return Cave