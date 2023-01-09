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
    love.graphics.setFont(font(16))
    for i = 0, Player.inventorySize - 1 do
        -- Hotbar
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", (w / 2) + (i * 64) - 160, h - 64, 64, 64)
        love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
        love.graphics.rectangle("line", (w / 2) + (i * 64) - 160, h - 64, 64, 64)

        if Player.inventory[i + 1].Type ~= BlockType.Air then
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.print(tostring(Player.inventory[i + 1].Amount), (w / 2) + (i * 64) - 160, h - 18) -- Amount of Items (Text)
            love.graphics.draw(Assets.gfx.Blocks, Assets.gfx.BlockTypes[Player.inventory[i + 1].Type + 2], (w / 2) + (i * 64) - 160 + (Global.unitSize / 2), h - (Global.unitSize * 1.5)) -- The Item Sprite
        end
    end

    -- Selected Item
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", (w / 2) + ((Player.selectedItem - 1) * 64) - 160, h - 64, 64, 64)
end

local function CraftingMenu(w, h)
    if Player.crafting then
        UI.nuklear:frameBegin()
        UI.nuklear:windowBegin('Crafting', (w / 2) - (w / 4), (h / 2) - (h / 4), w / 2, h / 2, 'border', 'title', 'scrollbar')
        UI.nuklear:layoutRow('dynamic', 30, 1)

        local StoneText, IronText, GoldText = "Stone Upgrade: 100 Stone", "Iron Upgrade: 25 Iron", "Gold Upgrade: 10 Gold"
        if Player.stoneUpgrade == 0 and UI.nuklear:button(StoneText) then
            for i = 1, Player.inventorySize do
                if Player.inventory[i].Type == BlockType.Stone and Player.inventory[i].Amount >= 100 then
                    Player.inventory[i].Amount = Player.inventory[i].Amount - 100
                    Player.stoneUpgrade = 1
                    break
                end
            end
        end
        if Player.ironUpgrade == 0 and UI.nuklear:button(IronText) then
            for i = 1, Player.inventorySize do
                if Player.inventory[i].Type == BlockType.Iron and Player.inventory[i].Amount >= 25 then
                    Player.inventory[i].Amount = Player.inventory[i].Amount - 25
                    Player.ironUpgrade = 1
                    break
                end
            end
        end
        if Player.goldUpgrade == 0 and UI.nuklear:button(GoldText) then
            for i = 1, Player.inventorySize do
                if Player.inventory[i].Type == BlockType.Gold and Player.inventory[i].Amount >= 10 then
                    Player.inventory[i].Amount = Player.inventory[i].Amount - 10
                    Player.goldUpgrade = 1
                    break
                end
            end
        end

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

function UI.update(w, h)
    CraftingMenu(w, h)
end

function UI.draw(w, h)
    PlayerInventory(w, h)
    PlayerHealth()
    UI.nuklear:draw()
end

return UI