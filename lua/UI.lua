local Player = require("lua.Player")
local Global = require("lua.GlobalValues")
local Assets = require("lua.Assets")

local UI = {
    nuklear = require("nuklear").newUI()
}

local font = function(size)
    return love.graphics.setNewFont(size)
end

local function PlayerInventory(w, h)
    love.graphics.setFont(font(16))
    for i = 0, #Player.inventory - 1 do
        -- Hotbar
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", (w / 2) + (i * 64) - ((#Player.inventory * 64) / 2), h - 64, 64, 64)
        love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
        love.graphics.rectangle("line", (w / 2) + (i * 64) - ((#Player.inventory * 64) / 2), h - 64, 64, 64)

        -- Amount of Items (Text)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(tostring(Player.inventory[i + 1]), (w / 2) + (i * 64) - ((#Player.inventory * 64) / 2), h - 18)
    end
    -- Selected Item
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", (w / 2) + ((Player.selectedItem - 1) * 64) - ((#Player.inventory * 64) / 2), h - 64, 64, 64)

    for i = 1, #Player.inventory do
        love.graphics.draw(Assets.gfx.Blocks, Assets.gfx.BlockTypes[i + 2], (w / 2) + (i * 64) - ((#Player.inventory * 64) / 2) - 48, h - 48)
    end
end

local function CraftingMenu(w, h)
    local craftingFont = font(24)
    if Player.crafting then
        UI.nuklear:frameBegin()
        UI.nuklear:windowBegin('Crafting', (w / 2) - (w / 4), (h / 2) - (h / 4), w / 2, h / 2, 'border', 'title')
        UI.nuklear:layoutRow('dynamic', 30, 1)

        local StoneText = "Stone Upgrade: 100 Stone"
		if UI.nuklear:button(StoneText) and Player.inventory[1] >= 100 and Player.stoneUpgrade == 0 then
            Player.inventory[1] = Player.inventory[1] - 100
			Player.stoneUpgrade = 1
		end

        local IronText = "Iron Upgrade: 25 Iron"
		if UI.nuklear:button(IronText) and Player.inventory[2] >= 25 and Player.ironUpgrade == 0 then
            Player.inventory[2] = Player.inventory[2] - 25
			Player.ironUpgrade = 1
		end

        local GoldText = "Gold Upgrade: 10 Gold"
		if UI.nuklear:button(GoldText) and Player.inventory[3] >= 10 and Player.goldUpgrade == 0 then
            Player.inventory[3] = Player.inventory[3] - 10
			Player.goldUpgrade = 1
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