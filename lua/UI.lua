local Player = require("lua.Player")
local Global = require("lua.GlobalValues")
local Assets = require("lua.Assets")
local BlockType = require("lua.BlockType")
local Camera = require("lua.Camera")

local UI = {
    nuklear = require("nuklear").newUI(),

    craftingX = -512,
    craftingY = 97,
    craftingW = 300,
}

local font = function(size)
    return love.graphics.setNewFont(size)
end

local function PlayerInventory(w, h)
    local slotSize = 64
    love.graphics.setFont(font(16))
    for i = 0, Player.inventorySize - 1 do
        -- Hotbar
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", (w / 2) + (i * slotSize) - (Player.inventorySize * slotSize) / 2, h - slotSize, slotSize, slotSize)
        love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
        love.graphics.rectangle("line", (w / 2) + (i * slotSize) - (Player.inventorySize * slotSize) / 2, h - slotSize, slotSize, slotSize)

        if Player.inventory[i + 1].Type ~= BlockType.Air then
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.print(tostring(Player.inventory[i + 1].Amount), (w / 2) + (i * slotSize) - (Player.inventorySize * slotSize) / 2, h - 18) -- Amount of Items (Text)
            love.graphics.draw(Assets.gfx.Blocks, Assets.gfx.BlockTypes[Player.inventory[i + 1].Type + 1], (w / 2) + (i * slotSize) - (Player.inventorySize * slotSize) / 2 + (Global.unitSize / 2), h - (Global.unitSize * 1.5)) -- The Item Sprite
        end
    end

    -- Selected Item
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", (w / 2) + ((Player.selectedItem - 1) * slotSize) - (Player.inventorySize * slotSize) / 2, h - slotSize, slotSize, slotSize)
end

---@param recipe1 number
---@param recipe2 number
---@param text string
---@param cost1 number
---@param cost2 number
---@param newItem BlockType
---@param amount number
local function multiRecipe(recipe1, recipe2, text, cost1, cost2, newItem, amount)
    UI.nuklear:layoutRowBegin('dynamic', Global.unitSize, 3)
    UI.nuklear:layoutRowPush(1/2)

    local x, y = UI.nuklear:widgetPosition()
    local width = UI.nuklear:widgetWidth()

    if UI.nuklear:button(text) then
        for i = 1, Player.inventorySize do
            for j = 1, Player.inventorySize do
                if Player.inventory[i].Type == recipe1 and Player.inventory[j].Type == recipe2
                and Player.inventory[i].Amount >= cost1 and Player.inventory[j].Amount >= cost2 then
                    for k = 1, Player.inventorySize do
                        if Player.inventory[k].Type == newItem or Player.inventory[k].Type == BlockType.Air then
                            Player.inventory[i].Amount = Player.inventory[i].Amount - cost1
                            Player.inventory[j].Amount = Player.inventory[j].Amount - cost2
                            Player.inventory[k].Type = BlockType.Torch
                            Player.inventory[k].Amount = Player.inventory[k].Amount + amount
                            break
                        end
                    end
                end
            end
        end
    end

    UI.nuklear:layoutRowPush(0.5)
    UI.nuklear:image({Assets.gfx.Blocks, Assets.gfx.BlockTypes[recipe1 + 1]}, x + width + Global.unitSize, y, Global.unitSize, Global.unitSize)
    UI.nuklear:layoutRowPush(0.1)
    UI.nuklear:label(tostring(cost1), 'bottom right')
    UI.nuklear:layoutRowPush(0.5)
    UI.nuklear:image({Assets.gfx.Blocks, Assets.gfx.BlockTypes[recipe2 + 1]}, x + width + Global.unitSize * 3, y, Global.unitSize, Global.unitSize)
    UI.nuklear:layoutRowPush(0.1)
    UI.nuklear:label(tostring(cost2), 'bottom right')
    UI.nuklear:layoutRowEnd()
end

local function upgradeOre(ore, text, cost)
    if Player.upgrades[ore] ~= 0 then return end

    UI.nuklear:layoutRowBegin('dynamic', Global.unitSize, 3)

    UI.nuklear:layoutRowPush(1/2)

    local x, y = UI.nuklear:widgetPosition()
    local width = UI.nuklear:widgetWidth()

    if UI.nuklear:button(text) then
        for i = 1, Player.inventorySize do
            if Player.inventory[i].Type == ore and Player.inventory[i].Amount >= cost then
                Player.inventory[i].Amount = Player.inventory[i].Amount - cost
                Player.upgrades[ore] = 1
                break
            end
        end
    end

    UI.nuklear:layoutRowPush(0.5)
    UI.nuklear:image({Assets.gfx.Blocks, Assets.gfx.BlockTypes[ore + 1]}, x + width + Global.unitSize, y, Global.unitSize, Global.unitSize)
    UI.nuklear:layoutRowPush(0.1)
    UI.nuklear:label(tostring(cost), 'bottom right')
    UI.nuklear:layoutRowEnd()
end

local function animateCraftingMenu()
    if Player.crafting then
        if UI.craftingX < 0 then
            UI.craftingX = UI.craftingX + 16
        end
    else
        if UI.craftingX > -UI.craftingW then
            UI.craftingX = UI.craftingX - 16
        end
    end
end

local function CraftingMenu(w, h)
    UI.nuklear:frameBegin()
    UI.nuklear:windowBegin('Crafting', UI.craftingX, UI.craftingY, UI.craftingW, h - 195, 'border', 'title', 'scrollbar')

    multiRecipe(BlockType.Stone, BlockType.Coal, "3 Torches", 12, 3, BlockType.Torch, 3)
    upgradeOre(BlockType.Stone, "Stone Upgrade", 150)
    upgradeOre(BlockType.Iron, "Iron Upgrade", 30)
    upgradeOre(BlockType.Gold, "Gold Upgrade", 15)
    upgradeOre(BlockType.Diamond, "Diamond Upgrade", 10)
    upgradeOre(BlockType.Ruby, "Ruby Upgrade", 5)

    UI.nuklear:windowEnd()
    UI.nuklear:frameEnd()
end

local function PlayerHealth()
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle("fill", Global.unitSize, Global.unitSize, Player.hp * Global.unitSize, Global.unitSize)
    love.graphics.setColor(0, 0, 0, 0.5)
    local lw = 8
    love.graphics.setLineWidth(lw)
    love.graphics.rectangle("line", Global.unitSize + (lw / 2), Global.unitSize + (lw / 2), (Player.maxHp * Global.unitSize) - (lw / 1), Global.unitSize - (lw / 1))
    love.graphics.setLineWidth(1)
    love.graphics.setFont(font(28))
    love.graphics.print(tostring(Player.hp), 32 * Player.hp + font(28):getWidth(tostring(Player.hp)) / 2, 32)
end

local function DebugMenu(w, h)
    if Global.debugMenu then
        love.graphics.setFont(font(16))
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("x: " .. tostring(math.floor(Player.x / Global.unitSize) .. " " .. "y: " ..  math.floor(Player.y / Global.unitSize)))
        local FPS = love.timer.getFPS().." FPS"
        love.graphics.print(FPS, 0, h - 16)
        love.graphics.print("Zoom: "..Camera.cam:getScale().."x", 0 + font(16):getWidth(FPS) * 2, h - 16)
    end
end

function UI.update(w, h)
    love.graphics.setColor(1, 1, 1, 1)
    animateCraftingMenu()
    CraftingMenu(w, h)
end

function UI.draw(w, h)
    PlayerInventory(w, h)
    PlayerHealth()
    DebugMenu(w, h)
    UI.nuklear:draw()
end

return UI