local Player = require("lua.Player")

local UI = {}

local font = love.graphics.setNewFont(16)
local function PlayerInventory(w, h)
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
end

function UI.draw(w, h)
    love.graphics.setFont(font)
    PlayerInventory(w, h)
end

return UI