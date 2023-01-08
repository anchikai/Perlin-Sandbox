local Player = require("lua.Player")
local Cave = require("lua.Cave")
local UI = require("lua.UI")

local WIDTH, HEIGHT = 1280, 720

local gamera = require("lib.gamera")
local Camera = require("lua.Camera")

---@type love.load
function love.load()
	love.window.setMode(WIDTH, HEIGHT, {resizable = true, minwidth = 512, minheight = 288})
	love.graphics.setBackgroundColor(1 / 3, 1 / 3, 1 / 3, 1)

	Camera.cam = gamera.new(
		0,
		0,
		1920,
		1080
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
	WIDTH, HEIGHT = love.graphics.getDimensions()

	Cave.update(dt)
	Player.update(dt)
	Camera.cam:setPosition(Player.x + (Player.size / 2), Player.y + (Player.size / 2))
	Camera.cam:setWindow(0, 0, WIDTH, HEIGHT)
	UI.update(WIDTH, HEIGHT)
end

---@type love.draw
function love.draw()
	Camera.cam:draw(function(l, t, w, h)
		Cave.draw(l, t, w, h)
		Player.draw()
	end)
	UI.draw(WIDTH, HEIGHT)
end

function love.keypressed(key, scancode, isrepeat)
	UI.nuklear:keypressed(key, scancode, isrepeat)

	if key == "e" or (key == "escape" and Player.crafting) then
		Player.crafting = not Player.crafting
	end

	for i = 1, #Player.inventory do
		if key == tostring(i) then
			Player.selectedItem = i
		end
	end
end

---@type love.keyreleased
function love.keyreleased(key, scancode)
	UI.nuklear:keyreleased(key, scancode)
end

---@type love.mousepressed
function love.mousepressed(x, y, button, istouch, presses)
	UI.nuklear:mousepressed(x, y, button, istouch, presses)
end

---@type love.mousereleased
function love.mousereleased(x, y, button, istouch, presses)
	UI.nuklear:mousereleased(x, y, button, istouch, presses)
end

---@type love.mousemoved
function love.mousemoved(x, y, dx, dy, istouch)
	UI.nuklear:mousemoved(x, y, dx, dy, istouch)
end

---@type love.textinput
function love.textinput(text)
	UI.nuklear:textinput(text)
end

---@type love.wheelmoved
function love.wheelmoved(x, y)
	UI.nuklear:wheelmoved(x, y)

	if not Player.crafting then
		if y > 0 and Player.selectedItem > 1 then
			Player.selectedItem = Player.selectedItem - 1
		elseif y < 0 and Player.selectedItem < #Player.inventory then
			Player.selectedItem = Player.selectedItem + 1
		end
	end
end

---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@return number
function math.dist(x1, y1, x2, y2)
	return ((x2 - x1) ^ 2 + (y2 - y1) ^ 2) ^ 0.5
end