local anim8 = require("lib.anim8")
local GlobalValues = require("lua.GlobalValues")
local BlockType = require("lua.BlockType")

local Assets = {
    gfx = {
        Blocks = love.graphics.newImage("Assets/gfx/game/block.png"),
        BlockTypes = {}
    },
    sfx = {
        Stone = love.audio.newSource("Assets/sfx/game/block/stone.wav", "static"),
    }
}

function Assets.load()
    local w, h = Assets.gfx.Blocks:getDimensions()
    local grid = anim8.newGrid(GlobalValues.unitSize, GlobalValues.unitSize, w, h, 0, 0, 2)

    for _, i in pairs(BlockType) do
        i = i + 2
        Assets.gfx.BlockTypes[i] = grid(i, 1)[1]
    end
end

return Assets