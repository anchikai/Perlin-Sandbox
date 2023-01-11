local Cave = require("lua.Cave")
local Global = require("lua.GlobalValues")
local Camera = require("lua.Camera")
local BlockType = require("lua.BlockType")

local Enemies = {
    enemies = {},
    despawnRange = 32
}

local Vector = require("lib.vector")
local Luafinding = require("lib.luafinding")

function Enemies.load()
    
end

local passableBlocks = {
    [BlockType.Air] = true,
    [BlockType.Water] = true,
    [BlockType.Torch] = true,
}

function Enemies.update(dt)
    local playerX, playerY = Camera.cam:getPosition()
    if love.math.random() <= 0.0005 then
        local rx, ry
        local spawnRadius = Global.unitSize * (Enemies.despawnRange / 2)
        repeat
            local r = spawnRadius * math.sqrt((love.math.random() * 0.5) + 0.5)
            local theta = love.math.random() * 2 * math.pi
            rx = playerX + r * math.cos(theta)
            ry = playerY + r * math.sin(theta)
        until Cave.getBlockType(math.floor(rx / Global.unitSize), math.floor(ry / Global.unitSize)) == 0
        table.insert(Enemies.enemies, {
            x = rx,
            y = ry,
            hp = 10,
            path = nil,
            start = Vector(rx, ry),
            finish = Vector(math.floor(playerX / Global.unitSize), math.floor(playerY / Global.unitSize))
        })
    end
    for i, enemy in ipairs(Enemies.enemies) do
        enemy.start = Vector(math.floor(enemy.x / Global.unitSize + 0.5), math.floor(enemy.y / Global.unitSize + 0.5))
        enemy.finish = Vector(math.floor(playerX / Global.unitSize), math.floor(playerY / Global.unitSize))
        enemy.path = Luafinding(enemy.start, enemy.finish, function(pos)
            return passableBlocks[Cave.getBlockType(pos.x, pos.y)] and math.dist(playerX, playerY, pos.x * Global.unitSize, pos.y * Global.unitSize) < Global.unitSize * Enemies.despawnRange
        end):GetPath()

        if enemy.path then
            if enemy.path[2] then
                local angle = math.angle(enemy.x, enemy.y, enemy.path[2].x * Global.unitSize, enemy.path[2].y * Global.unitSize)
                enemy.x = enemy.x + math.cos(angle) * 128 * dt
                enemy.y = enemy.y + math.sin(angle) * 128 * dt
            end
        end
        -- Despawning
        if math.dist(enemy.x, enemy.y, playerX, playerY) >= Global.unitSize * Enemies.despawnRange then
            table.remove(Enemies.enemies, i)
        end
    end
end

function Enemies.draw()
    for i, enemy in ipairs(Enemies.enemies) do
        love.graphics.setColor(0, 1, 0, 0.5)
        if enemy.path and Global.debugMenu then
            for j, path in ipairs(enemy.path) do
                love.graphics.rectangle("fill", path.x * Global.unitSize, path.y * Global.unitSize, Global.unitSize, Global.unitSize)
            end
        end
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.rectangle("fill", enemy.x, enemy.y, Global.unitSize, Global.unitSize)
    end
end

return Enemies