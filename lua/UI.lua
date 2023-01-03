local Player = require "lua.Player"
local UI = {}

function UI.draw(w, h)
    local font = love.graphics.setNewFont(32)
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Blocks: " .. tostring(Player.inventory.greyBlock), 0, h - font:getHeight())
end

return UI