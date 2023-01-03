local Global = require("lua.GlobalValues")
local Cave = require("lua.Cave")
local Camera = require("lua.Camera")

local Player = {
    x = 0, ---@type number
    y = 0, ---@type number

    speed = 256, ---@type number
    size = 32, ---@type number
    range = 3,
    inventory = {
        greyBlock = 0
    }
}

---@param dt number
---@param clearance number
local function Movement(dt, clearance)
    if love.keyboard.isDown("w") and Cave.Grid[math.floor((Player.x + (Player.size / 2)) / Global.unitSize)][math.floor((Player.y - clearance) / Global.unitSize)] == 0 then
        Player.y = Player.y - Player.speed * dt
    end
    if love.keyboard.isDown("a") and Cave.Grid[math.floor((Player.x - clearance) / Global.unitSize)][math.floor((Player.y + (Player.size / 2)) / Global.unitSize)] == 0 then
        Player.x = Player.x - Player.speed * dt
    end
    if love.keyboard.isDown("s") and Cave.Grid[math.floor((Player.x + (Player.size / 2)) / Global.unitSize)][math.floor((Player.y + Player.size + clearance) / Global.unitSize)] == 0 then
        Player.y = Player.y + Player.speed * dt
    end
    if love.keyboard.isDown("d") and Cave.Grid[math.floor((Player.x + Player.size + clearance) / Global.unitSize)][math.floor((Player.y + (Player.size / 2)) / Global.unitSize)] == 0 then
        Player.x = Player.x + Player.speed * dt
    end
end

---@param range number
local function Mine(range)
    local mx, my = love.mouse.getPosition()
    local wmx, wmy = Camera.cam:toWorld(mx, my)
    if love.mouse.isDown(1) then
        if math.abs(math.floor(wmx / Global.unitSize) - math.floor(Player.x / Global.unitSize)) <= range
        and math.abs(math.floor(wmy / Global.unitSize) - math.floor(Player.y / Global.unitSize)) <= range
        and Cave.Grid[math.floor(wmx / Global.unitSize)][math.floor(wmy / Global.unitSize)] == 1 then
            Cave.Grid[math.floor(wmx / Global.unitSize)][math.floor(wmy / Global.unitSize)] = 0
            Player.inventory.greyBlock = Player.inventory.greyBlock + 1
        end
    end
end

---@param range number
local function Build(range)
    local mx, my = love.mouse.getPosition()
    local wmx, wmy = Camera.cam:toWorld(mx, my)
    if love.mouse.isDown(2) and Player.inventory.greyBlock > 0 then
        if math.abs(math.floor(wmx / Global.unitSize) - math.floor(Player.x / Global.unitSize)) <= range
        and math.abs(math.floor(wmy / Global.unitSize) - math.floor(Player.y / Global.unitSize)) <= range
        and Cave.Grid[math.floor(wmx / Global.unitSize)][math.floor(wmy / Global.unitSize)] == 0 then
            Cave.Grid[math.floor(wmx / Global.unitSize)][math.floor(wmy / Global.unitSize)] = 1
            Player.inventory.greyBlock = Player.inventory.greyBlock - 1
        end
    end
end

---@param range number
local function PlayerGridCursor(range)
    local mx, my = love.mouse.getPosition()
    local wmx, wmy = Camera.cam:toWorld(mx, my)
    if math.abs(math.floor(wmx / Global.unitSize) - math.floor(Player.x / Global.unitSize)) <= range
    and math.abs(math.floor(wmy / Global.unitSize) - math.floor(Player.y / Global.unitSize)) <= range then
        love.graphics.setColor(0, 0, 0, 1)
        love.graphics.rectangle("line", math.floor(wmx / Global.unitSize) * Global.unitSize, math.floor(wmy / Global.unitSize) * Global.unitSize, Global.unitSize, Global.unitSize)
    end
end

function Player.load()

end

---@param dt number
function Player.update(dt)
    Movement(dt, 4)
    Mine(Player.range)
    Build(Player.range)
end

function Player.draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", Player.x, Player.y, Player.size, Player.size)
    PlayerGridCursor(Player.range)
end

return Player