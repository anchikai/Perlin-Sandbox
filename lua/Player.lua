local Global = require("lua.GlobalValues")
local Cave = require("lua.Cave")
local Camera = require("lua.Camera")
local BlockType = require("lua.BlockType")
local Assets = require("lua.Assets")
local Enemies = require("lua.Enemies")
local Vector = require("lib.vector")

local Player = {
    x = 0, ---@type number
    y = 0, ---@type number

    speed = 256, ---@type number
    size = 32, ---@type number
    range = 3, ---@type number

    hp = 5, ---@type number
    maxHp = 5, ---@type number
    hit = false, ---@type boolean
    invulnerabilityTime = 1, ---@type number

    upgrades = {
        [BlockType.Stone] = 0,
        [BlockType.Iron] = 0,
        [BlockType.Gold] = 0,
        [BlockType.Diamond] = 0,
        [BlockType.Ruby] = 0,
    },

    inventory = {},
    inventorySize = 8, ---@type number
    selectedItem = 1, ---@type number
    crafting = false, ---@type boolean

    dugDeeper = false,
}

local passableBlocks = {
    [BlockType.Air] = true,
    [BlockType.Water] = true,
    [BlockType.Lava] = true,
    [BlockType.Torch] = true,
    [BlockType.Deeper] = true,
}
---@param dt number
---@param clearance number
local function Movement(dt, clearance)
    if not Player.crafting then
        if love.keyboard.isDown("w") and passableBlocks[Cave.getBlockType(math.floor(Player.x / Global.unitSize), math.floor((Player.y - (Player.size / 2)) / Global.unitSize))] then
            Player.y = Player.y - Player.speed * dt
        end
        if love.keyboard.isDown("a") and passableBlocks[Cave.getBlockType(math.floor((Player.x - (Player.size / 2)) / Global.unitSize), math.floor(Player.y / Global.unitSize))] then
            Player.x = Player.x - Player.speed * dt
        end
        if love.keyboard.isDown("s") and passableBlocks[Cave.getBlockType(math.floor(Player.x / Global.unitSize), math.floor((Player.y + (Player.size / 2)) / Global.unitSize))] then
            Player.y = Player.y + Player.speed * dt
        end
        if love.keyboard.isDown("d") and passableBlocks[Cave.getBlockType(math.floor((Player.x + (Player.size / 2)) / Global.unitSize), math.floor(Player.y / Global.unitSize))] then
            Player.x = Player.x + Player.speed * dt
        end
    end
end

local function goDeeper()
    local wpx, wpy = math.floor(Player.x / Global.unitSize), math.floor(Player.y / Global.unitSize)
    if Cave.getBlockType(wpx, wpy) == BlockType.Deeper then
        Cave.newZone(Player)
    end
end

local nonMinables = {
    [BlockType.Water] = true,
    [BlockType.Lava] = true,
    [BlockType.Deeper] = true,
}

local requiredUpgrade = {
    [BlockType.Iron] = BlockType.Stone,
    [BlockType.Gold] = BlockType.Iron,
    [BlockType.Diamond] = BlockType.Gold,
    [BlockType.Ruby] = BlockType.Diamond,
    [BlockType.Air] = BlockType.Ruby,
}

---@param range number
local function Mine(range)
    local mx, my = love.mouse.getPosition()
    local wmx, wmy = Camera.cam:toWorld(mx, my)
    if love.mouse.isDown(1) and not Player.crafting then
        if math.abs(math.floor(wmx / Global.unitSize) - math.floor(Player.x / Global.unitSize)) <= range
        and math.abs(math.floor(wmy / Global.unitSize) - math.floor(Player.y / Global.unitSize)) <= range then
            local block = Cave.getBlock(math.floor(wmx / Global.unitSize), math.floor(wmy / Global.unitSize))

            if not block then return end
            if nonMinables[block.type] then return end
            if Player.upgrades[requiredUpgrade[block.type]] == 0 then return end

            local foundType = false
            for i = 1, Player.inventorySize do
                if Player.inventory[i].Amount < 256 and Player.inventory[i].Type == block.type then
                    block.integrity = block.integrity - 1
                    if block.integrity <= 0 then

                        if Player.upgrades[BlockType.Ruby] == 1 and block.type == BlockType.Air and not Player.dugDeeper then
                            Player.inventory[i].Amount = Player.inventory[i].Amount + 1
                            foundType = true
                            Cave.setBlock(math.floor(wmx / Global.unitSize), math.floor(wmy / Global.unitSize), BlockType.Deeper)
                            Player.dugDeeper = true
                            Assets.sfx.Stone:stop()
                            Assets.sfx.Stone:play()
                        elseif block.type ~= BlockType.Air then
                            Player.inventory[i].Amount = Player.inventory[i].Amount + 1
                            foundType = true
                            Cave.setBlock(math.floor(wmx / Global.unitSize), math.floor(wmy / Global.unitSize), BlockType.Air)
                            Assets.sfx.Stone:stop()
                            Assets.sfx.Stone:play()
                        end
                    end
                    break
                end
            end

            if not foundType then
                for i = 1, Player.inventorySize do -- Idk why the fuck this doesn't work if I put the below in the above for loop
                    if Player.inventory[i].Amount < 256 and Player.inventory[i].Type == BlockType.Air then
                        block.integrity = block.integrity - 1
                        if block.integrity <= 0 and block.type ~= BlockType.Air then
                            Player.inventory[i].Type = block.type
                            Player.inventory[i].Amount = Player.inventory[i].Amount + 1
                            Assets.sfx.Stone:stop()
                            Assets.sfx.Stone:play()
                            Cave.setBlock(math.floor(wmx / Global.unitSize), math.floor(wmy / Global.unitSize), BlockType.Air)
                        end
                        break
                    end
                end
            end
        end
    end
end

local replacableBlocks = {
    [BlockType.Air] = true,
    [BlockType.Water] = true,
    [BlockType.Lava] = true,
}

---@param range number
local function Build(range)
    local mx, my = love.mouse.getPosition()
    local wmx, wmy = Camera.cam:toWorld(mx, my)

    if love.mouse.isDown(2) and not Player.crafting then
        if Vector(math.floor(wmx / Global.unitSize), math.floor(wmy / Global.unitSize)) == Vector(math.floor(Player.x / Global.unitSize), math.floor(Player.y / Global.unitSize)) then return end

        if math.abs(math.floor(wmx / Global.unitSize) - math.floor(Player.x / Global.unitSize)) <= range
        and math.abs(math.floor(wmy / Global.unitSize) - math.floor(Player.y / Global.unitSize)) <= range
        and replacableBlocks[Cave.getBlockType(math.floor(wmx / Global.unitSize), math.floor(wmy / Global.unitSize))] then
            if Player.inventory[Player.selectedItem].Amount > 0 then
                Cave.setBlock(math.floor(wmx / Global.unitSize), math.floor(wmy / Global.unitSize), Player.inventory[Player.selectedItem].Type)
                Player.inventory[Player.selectedItem].Amount = Player.inventory[Player.selectedItem].Amount - 1
                Assets.sfx.Stone:stop()
                Assets.sfx.Stone:play()
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
    local upgradeBonus = 0
    for _, value in pairs(Player.upgrades) do
        upgradeBonus = upgradeBonus + value
    end
    Player.range = defaultRange + upgradeBonus
end

local function updateInventory()
    for i = 1, Player.inventorySize do
        -- If the stack is empty, make sure its type isn't set to an actual block
        -- This is to make sure the items in the inventory can be added/removed dynamically and that slot doesn't break in some way that I'm not capable of conceiving
        if Player.inventory[i].Amount == 0 and Player.inventory[i].Type ~= BlockType.Air then
            Player.inventory[i].Type = BlockType.Air
        end
    end
end

local function handleDamage(dt, time)
    if Player.hp <= 0 then return end
    if Player.hit and Player.invulnerabilityTime > 0 then
        Player.invulnerabilityTime = Player.invulnerabilityTime - dt
        return
    else
        Player.hit = false
        Player.invulnerabilityTime = time
    end

    for i, enemy in ipairs(Enemies.enemies) do
        if math.dist(Player.x, Player.y, enemy.x, enemy.y) <= Global.unitSize and not Player.hit then
            Player.hit = true
            Player.hp = Player.hp - 1
        end
    end

    if Cave.getBlockType(math.floor(Player.x / Global.unitSize), math.floor(Player.y / Global.unitSize)) == BlockType.Lava then
        Player.hit = true
        Player.invulnerabilityTime = Player.invulnerabilityTime / 2
        Player.hp = Player.hp - 1
    end
end

function Player.load()
    if Global.CaveZone == 1 then
        for i = 1, Player.inventorySize do
            table.insert(Player.inventory, i, {Type = BlockType.Air, Amount = 0})
        end
    end
    Player.x = Player.x + 16
    Player.y = Player.y + 16
end

---@param dt number
function Player.update(dt)
    Movement(dt, 2)
    updateRange(3)
    updateInventory()
    Mine(Player.range)
    Build(Player.range)
    handleDamage(dt, 1)
    goDeeper()
end

function Player.draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", Player.x - (Player.size / 2), Player.y - (Player.size / 2), Player.size, Player.size)
    PlayerGridCursor(Player.range)
end

return Player