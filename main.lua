local Player = require("lua.Player")
local Cave = require("lua.Cave")
local UI = require("lua.UI")

local WIDTH, HEIGHT = 1280, 720

local gamera = require("lib.gamera")
local Camera = require("lua.Camera")

---@type love.load
function love.load()
	love.window.setMode(WIDTH, HEIGHT)
	love.graphics.setBackgroundColor(1/3, 1/3, 1/3, 1)

	Camera.cam = gamera.new(
		0,
		0,
		WIDTH,
		HEIGHT
	)

	Camera.cam:setWorld(
		-math.huge,
		-math.huge,
		math.huge,
		math.huge
	)

	Cave.load()
	Player.load()
end

---@type love.update
function love.update(dt)
	Cave.update(dt)
	Player.update(dt)
	Camera.cam:setPosition(Player.x + (Player.size / 2), Player.y + (Player.size / 2))
end

---@type love.draw
function love.draw()
	Camera.cam:draw(function(l, t, w, h)
		Cave.draw()
		Player.draw()
	end)
	UI.draw(WIDTH, HEIGHT)
end

---@type love.keypressed
function love.keypressed(key, scancode, isrepeat)
	if key == "r" then
		Cave.Grid = {}
        Cave.load()
	end
end