local Assets = {
    gfx = {
        Blocks = love.graphics.newImage("Assets/gfx/game/block.png"),
        BlockTypes = {
            love.graphics.newQuad(0, 0, 32, 32, 224, 32),
            love.graphics.newQuad(32, 0, 32, 32, 224, 32),
            love.graphics.newQuad(64, 0, 32, 32, 224, 32),
            love.graphics.newQuad(96, 0, 32, 32, 224, 32),
            love.graphics.newQuad(128, 0, 32, 32, 224, 32),
            love.graphics.newQuad(160, 0, 32, 32, 224, 32),
            love.graphics.newQuad(192, 0, 32, 32, 224, 32),
        }
    },
    sfx = {
        Stone = love.audio.newSource("Assets/sfx/game/block/stone.wav", "static"),
    }
}

return Assets