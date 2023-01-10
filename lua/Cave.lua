local Global = require("lua.GlobalValues")
local BlockType = require("lua.BlockType")
local Assets = require("lua.Assets")
local Vector = require("lib.vector")
local Camera = require("lua.Camera")

local Cave = {
    Grid = {}
}

local chunkSize = 64

---@class Block
---@field type integer
---How much health the block has before breaking
---@field integrity integer

---@class Chunk
---@field pos Vector
---@field grid Block[][]

---@type Chunk[]
local loadedChunks = {}

---@param x number
---@return number
local function round(x)
    return math.floor(x + 0.5)
end

local baseX, baseY = 10000 * love.math.random(), 10000 * love.math.random()
local rubyBaseX, rubyBaseY = 10000 * love.math.random(), 10000 * love.math.random()
local diamondBaseX, diamondBaseY = 10000 * love.math.random(), 10000 * love.math.random()
local goldBaseX, goldBaseY = 10000 * love.math.random(), 10000 * love.math.random()
local ironBaseX, ironBaseY = 10000 * love.math.random(), 10000 * love.math.random()

---@param chunk Chunk
local function addOres(chunk)
    for y = 2, chunkSize - 1 do
        for x = 2, chunkSize - 1 do
            local rubyNoise = love.math.noise(rubyBaseX + 0.1 * (chunk.pos.x + x), rubyBaseY + 0.1 * (chunk.pos.y + y))
            local diamondNoise = love.math.noise(diamondBaseX + 0.1 * (chunk.pos.x + x), diamondBaseY + 0.1 * (chunk.pos.y + y))
            local goldNoise = love.math.noise(goldBaseX + 0.1 * (chunk.pos.x + x), goldBaseY + 0.1 * (chunk.pos.y + y))
            local ironNoise = love.math.noise(ironBaseX + 0.1 * (chunk.pos.x + x), ironBaseY + 0.1 * (chunk.pos.y + y))

            if chunk.grid[x][y].type == BlockType.Stone then
                if chunk.grid[x - 1][y].type ~= BlockType.Air and chunk.grid[x + 1][y].type ~= BlockType.Air
                and chunk.grid[x][y - 1].type ~= BlockType.Air and chunk.grid[x][y + 1].type ~= BlockType.Air then
                    if rubyNoise >= 0.9975 then
                        chunk.grid[x][y].type = BlockType.Ruby
                    elseif diamondNoise >= 0.9925 then
                        chunk.grid[x][y].type = BlockType.Diamond
                    elseif goldNoise >= 0.975 then
                        chunk.grid[x][y].type = BlockType.Gold
                    elseif ironNoise >= 0.95 then
                        chunk.grid[x][y].type = BlockType.Iron
                    end
                end
            end
        end
    end
end

---@param chunk Chunk
local function generateCave(chunk)
    -- Stone
    for x = 1, chunkSize do
        chunk.grid[x] = {}
        for y = 1, chunkSize do
            chunk.grid[x][y] = {
                type = round(love.math.noise(baseX + 0.1 * (chunk.pos.x + x), baseY + 0.1 * (chunk.pos.y + y))),
                integrity = 3,
            }
        end
    end
end

---@param pos Vector
---@return Chunk
local function generateChunk(pos)
    local chunk = {
        pos = pos,
        grid = {}
    }

    -- Make the normal part of the chunk (Stone)
    generateCave(chunk)

    addOres(chunk)

    return chunk
end

local function updateChunks()
    -- Get bounds for visible chunks
    local camX, camY, camWidth, camHeight = Camera.cam:getVisible()
    local minX = (camX / Global.unitSize)
    local minY = (camY / Global.unitSize)
    local maxX = ((camX + camWidth) / Global.unitSize)
    local maxY = ((camY + camHeight) / Global.unitSize)

    local boundedMinX = math.floor(minX / chunkSize) * chunkSize
    local boundedMinY = math.floor(minY / chunkSize) * chunkSize
    local boundedMaxX = math.ceil(maxX / chunkSize) * chunkSize
    local boundedMaxY = math.ceil(maxY / chunkSize) * chunkSize

    -- Add every chunk that is inside these bounds
    for y = boundedMinY, boundedMaxY, chunkSize do
        for x = boundedMinX, boundedMaxX, chunkSize do
            local pos = Vector(x, y)
            local chunk = loadedChunks[pos:ID()]
            if not chunk then
                loadedChunks[pos:ID()] = generateChunk(pos)
            end
        end
    end
end

---@param x number
---@param y number
---@param Block BlockType
function Cave.setBlock(x, y, Block)
    local chunkX = math.floor(x / chunkSize) * chunkSize
    local chunkY = math.floor(y / chunkSize) * chunkSize
    local chunkPos = Vector(chunkX, chunkY)
    local chunk = loadedChunks[chunkPos:ID()]
    if not chunk then
        -- chunk = generateChunk(chunkPos)
        -- loadedChunks[chunkPos:ID()] = chunk
        return
    end

    local relX = x - chunkX + 1
    local relY = y - chunkY + 1
    chunk.grid[relX][relY].type = Block
end

---@param x integer
---@param y integer
---@return BlockType?
function Cave.getBlockType(x, y)
    local block = Cave.getBlock(x, y)

    if block then
        return block.type
    else
        return nil
    end
end

function Cave.getBlock(x, y)
    local chunkX = math.floor(x / chunkSize) * chunkSize
    local chunkY = math.floor(y / chunkSize) * chunkSize
    local chunkPos = Vector(chunkX, chunkY)
    local chunk = loadedChunks[chunkPos:ID()]
    if not chunk then
        -- chunk = generateChunk(chunkPos)
        -- loadedChunks[chunkPos:ID()] = chunk
        return
    end

    local relX = x - chunkX + 1
    local relY = y - chunkY + 1
    local block = chunk.grid[relX] and chunk.grid[relX][relY]
    return block
end

function Cave.load()
    updateChunks()
end

---@param dt number
function Cave.update(dt)
    updateChunks()
end

function Cave.draw(l, t, w, h)
    local r, b = l + w, t + h
    love.graphics.setColor(1, 1, 1, 1)
    for y = math.floor(t / Global.unitSize) - 2, math.floor(b / Global.unitSize) + 2 do
        for x = math.floor(l / Global.unitSize) - 2, math.floor(r / Global.unitSize) + 2 do
            local block = Cave.getBlockType(x, y)
            if block ~= nil and block ~= BlockType.Air then
                love.graphics.draw(Assets.gfx.Blocks, Assets.gfx.BlockTypes[block + 2], x * Global.unitSize, y * Global.unitSize)
            end
        end
    end
end

return Cave