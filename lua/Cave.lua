local Global = require("lua.GlobalValues")
local BlockType = require("lua.BlockType")
local Assets = require("lua.Assets")

local Cave = {
    Grid = {},
    Size = 256
}

---@param x number
---@return number
local function round(x)
    return math.floor(x + 0.5)
end

---@param caveSize number
local function generateCave(caveSize)
    local baseX = 10000 * love.math.random()
    local baseY = 10000 * love.math.random()

    -- Stone
    for y = 1, caveSize do
        Cave.Grid[y] = {}
        for x = 1, caveSize do
            Cave.Grid[y][x] = round(love.math.noise(baseX + 0.1 * x, baseY + 0.1 * y))
        end
    end
end

---@param caveSize number
local function addWalls(caveSize)
    for y = 1, caveSize do
        for x = 1, caveSize do
            Cave.Grid[1][x] = BlockType.WorldBorder
            Cave.Grid[y][1] = BlockType.WorldBorder
            Cave.Grid[x][caveSize] = BlockType.WorldBorder
            Cave.Grid[caveSize][y] = BlockType.WorldBorder
        end
    end
end

---@param caveSize number
local function addOres(caveSize)
    for y = 1, caveSize do
        for x = 1, caveSize do
            if Cave.Grid[x][y] == 1 then
                if Cave.Grid[x][y] ~= BlockType.Air and Cave.Grid[x][y] ~= BlockType.Air
                and Cave.Grid[x][y] ~= BlockType.Air and Cave.Grid[x][y] ~= BlockType.Air then
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
    generateCave(Cave.Size)
    addWalls(Cave.Size)
    addOres(Cave.Size)
end

---@param dt number
function Cave.update(dt)
    
end

function Cave.draw(l, t, w, h)
    local r, b = l + w, t + h
    love.graphics.setColor(1, 1, 1, 1)
    for y = 1, Cave.Size do
        for x = 1, Cave.Size do
            if Cave.Grid[x][y] ~= BlockType.Air then
                if x > math.floor(l / Global.unitSize) - 1 and x < math.floor(r / Global.unitSize) + 1
                and y > math.floor(t / Global.unitSize) - 1 and y < math.floor(b / Global.unitSize) + 1 then
                    love.graphics.draw(Assets.gfx.Blocks, Assets.gfx.BlockTypes[Cave.Grid[x][y] + 2], x * Global.unitSize, y * Global.unitSize)
                end
            end
        end
    end
end

return Cave