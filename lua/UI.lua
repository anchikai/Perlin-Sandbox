local Player = require("lua.Player")
local Global = require("lua.GlobalValues")
local Assets = require("lua.Assets")
local BlockType = require("lua.BlockType")

local UI = {
    nuklear = require("nuklear").newUI()
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

---@param text string
---@param cost1 number
---@param cost2 number
---@param newItem BlockType
---@param amount number
local function multiRecipe(text, cost1, cost2, newItem, amount)
    if UI.nuklear:button(text) then
        for i = 1, Player.inventorySize do
            for j = 1, Player.inventorySize do
                if Player.inventory[i].Type == BlockType.Stone and Player.inventory[j].Type == BlockType.Coal
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
end

local function upgradeOre(ore, text, cost)
    if Player.upgrades[ore] == 0 and UI.nuklear:button(text) then
        for i = 1, Player.inventorySize do
            if Player.inventory[i].Type == ore and Player.inventory[i].Amount >= cost then
                Player.inventory[i].Amount = Player.inventory[i].Amount - cost
                Player.upgrades[ore] = 1
                break
            end
        end
    end
end

local function CraftingMenu(w, h)
    if Player.crafting then
        UI.nuklear:frameBegin()
        UI.nuklear:windowBegin('Crafting', (w / 2) - (w / 4), (h / 2) - (h / 4), w / 2, h / 2, 'border', 'title', 'scrollbar')
        UI.nuklear:layoutRow('dynamic', 30, 1)

        multiRecipe("3 Torch: 12 Stone, 3 Coal", 12, 3, BlockType.Torch, 3)
        upgradeOre(BlockType.Stone, "Stone Upgrade: 150 Stone", 150)
        upgradeOre(BlockType.Iron, "Iron Upgrade: 30 Iron", 30)
        upgradeOre(BlockType.Gold, "Gold Upgrade: 15 Gold", 15)
        upgradeOre(BlockType.Diamond, "Diamond Upgrade: 10 Diamond", 10)
        upgradeOre(BlockType.Ruby, "Ruby Upgrade: 5 Ruby", 5)

        UI.nuklear:windowEnd()
        UI.nuklear:frameEnd()
    end
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
        love.graphics.print(love.timer.getFPS().." FPS", 0, h - 16)
    end
end

function UI.update(w, h)
    CraftingMenu(w, h)
end

function UI.draw(w, h)
    PlayerInventory(w, h)
    PlayerHealth()
    DebugMenu(w, h)
    UI.nuklear:draw()
end

return UI