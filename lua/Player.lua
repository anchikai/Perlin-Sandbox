local Global = require("lua.GlobalValues")
local Cave = require("lua.Cave")
local Camera = require("lua.Camera")
local BlockType = require("lua.BlockType")

local Player = {
    x = 0, ---@type number
    y = 0, ---@type number

    speed = 256, ---@type number
    size = 32, ---@type number
    range = 3, ---@type number
    hp = 5, ---@type number
    maxHp = 5, ---@type number

    stoneUpgrade = 0, ---@type number
    ironUpgrade = 0, ---@type number
    goldUpgrade = 0, ---@type number

    inventory = {
        0, -- Stone
        0, -- Iron
        0, -- Gold
        0,
        0,
    },
    selectedItem = 1, ---@type number
    crafting = false, ---@type boolean
}

---@param dt number
---@param clearance number
local function Movement(dt, clearance)
    if not Player.crafting then
        if love.keyboard.isDown("w") and Cave.Grid[math.floor((Player.x + (Player.size / 2)) / Global.unitSize)][math.floor((Player.y - clearance) / Global.unitSize)] == BlockType.Air then
            Player.y = Player.y - Player.speed * dt
        end
        if love.keyboard.isDown("a") and Cave.Grid[math.floor((Player.x - clearance) / Global.unitSize)][math.floor((Player.y + (Player.size / 2)) / Global.unitSize)] == BlockType.Air then
            Player.x = Player.x - Player.speed * dt
        end
        if love.keyboard.isDown("s") and Cave.Grid[math.floor((Player.x + (Player.size / 2)) / Global.unitSize)][math.floor((Player.y + Player.size + clearance) / Global.unitSize)] == BlockType.Air then
            Player.y = Player.y + Player.speed * dt
        end
        if love.keyboard.isDown("d") and Cave.Grid[math.floor((Player.x + Player.size + clearance) / Global.unitSize)][math.floor((Player.y + (Player.size / 2)) / Global.unitSize)] == BlockType.Air then
            Player.x = Player.x + Player.speed * dt
        end
    end
end

---@param range number
local function Mine(range)
    local mx, my = love.mouse.getPosition()
    local wmx, wmy = Camera.cam:toWorld(mx, my)
    if love.mouse.isDown(1) then
        if math.abs(math.floor(wmx / Global.unitSize) - math.floor(Player.x / Global.unitSize)) <= range
        and math.abs(math.floor(wmy / Global.unitSize) - math.floor(Player.y / Global.unitSize)) <= range then
            local block = Cave.Grid[math.floor(wmx / Global.unitSize)][math.floor(wmy / Global.unitSize)]

            if block == BlockType.Iron and Player.stoneUpgrade == 0 then return end
            if block == BlockType.Gold and Player.ironUpgrade == 0 then return end
            if block > BlockType.Air and Player.inventory[block] < 100 then
                Cave.setBlock(math.floor(wmx / Global.unitSize), math.floor(wmy / Global.unitSize), BlockType.Air)
                Player.inventory[block] = Player.inventory[block] + 1
            end
        end
    end
end

---@param range number
local function Build(range)
    local mx, my = love.mouse.getPosition()
    local wmx, wmy = Camera.cam:toWorld(mx, my)
    if love.mouse.isDown(2) then
        if math.abs(math.floor(wmx / Global.unitSize) - math.floor(Player.x / Global.unitSize)) <= range
        and math.abs(math.floor(wmy / Global.unitSize) - math.floor(Player.y / Global.unitSize)) <= range
        and Cave.Grid[math.floor(wmx / Global.unitSize)][math.floor(wmy / Global.unitSize)] == BlockType.Air then
            if Player.inventory[Player.selectedItem] > 0 then
                Cave.setBlock(math.floor(wmx / Global.unitSize), math.floor(wmy / Global.unitSize), Player.selectedItem)
                Player.inventory[Player.selectedItem] = Player.inventory[Player.selectedItem] - 1
            end
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

---@param defaultRange number
local function updateRange(defaultRange)
    Player.range = defaultRange + Player.stoneUpgrade + Player.ironUpgrade + Player.goldUpgrade
end

function Player.load()

end

---@param dt number
function Player.update(dt)
    Movement(dt, 2)
    updateRange(3)
    Mine(Player.range)
    Build(Player.range)
end

function Player.draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", Player.x, Player.y, Player.size, Player.size)
    PlayerGridCursor(Player.range)
end

return Player