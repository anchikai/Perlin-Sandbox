local Cave = require("lua.Cave")
local Global = require("lua.GlobalValues")
local Player = require("lua.Player")

local Enemies = {}

function Enemies.update(dt)
    if love.math.random() <= 0.002 then
        local rx, ry
        repeat
           rx = love.math.random(-Cave.Size, Cave.Size)
           ry = love.math.random(-Cave.Size, Cave.Size)
        until Cave.Grid[rx][ry] == 0
        table.insert(Enemies, {
            x = rx * Global.unitSize,
            y = ry * Global.unitSize,
        })
    end
    for i, enemy in ipairs(Enemies) do
        if Cave.Grid[math.floor(enemy.x / Global.unitSize)][math.floor(enemy.y / Global.unitSize)] == 0 then
            enemy.x = enemy.x - math.cos(math.angle(Player.x, Player.y, enemy.x, enemy.y)) * 2
            enemy.y = enemy.y - math.sin(math.angle(Player.x, Player.y, enemy.x, enemy.y)) * 2
        end

        if math.dist(enemy.x, enemy.y, Player.x, Player.y) <= Global.unitSize and not Player.hit then
            Player.hit = true
            Player.hp = Player.hp - 1
        elseif Player.hit and Player.invulnerabilityTime > 0 then
            Player.invulnerabilityTime = Player.invulnerabilityTime - dt
        end
        if Player.invulnerabilityTime <= 0 then
            Player.hit = false
            Player.invulnerabilityTime = 1
        end
    end
end

function Enemies.draw()
    for i, enemy in ipairs(Enemies) do
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.rectangle("fill", enemy.x, enemy.y, 32, 32)
    end
end

return Enemies