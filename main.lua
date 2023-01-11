local Player = require("lua.Player")
local Cave = require("lua.Cave")
local UI = require("lua.UI")
local Enemies = require("lua.Enemies")
local Assets  = require("lua.Assets")
local Global = require("lua.GlobalValues")

local WIDTH, HEIGHT = 1280, 720

local gamera = require("lib.gamera")
local Camera = require("lua.Camera")

---@type love.load
function love.load()
	love.window.setMode(WIDTH, HEIGHT, { resizable = true, minwidth = 512, minheight = 288 })
	love.graphics.setBackgroundColor(1 / 3, 1 / 3, 1 / 3, 1)
	love.window.setTitle("Roguebox")

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

	Assets.load()
	Cave.load()
	Player.load()
	Enemies.load()
end

---@type love.update
function love.update(dt)
	WIDTH, HEIGHT = love.graphics.getDimensions()

	Cave.update(dt)
	Player.update(dt)
	Enemies.update(dt)
	Camera.cam:setPosition(Player.x + (Player.size / 2), Player.y + (Player.size / 2))
	Camera.cam:setWindow(0, 0, WIDTH, HEIGHT)
	UI.update(WIDTH, HEIGHT)
end

---@type love.draw
function love.draw()
	Camera.cam:draw(function(l, t, w, h)
		Cave.draw(l, t, w, h)
		Enemies.draw()
		Player.draw()
		Cave.lighting(l, t, w, h)
	end)
	UI.draw(WIDTH, HEIGHT)
end

function love.keypressed(key, scancode, isrepeat)
	UI.nuklear:keypressed(key, scancode, isrepeat)

	if key == "e" or (key == "escape" and Player.crafting) then
		Player.crafting = not Player.crafting
	end

	for i = 1, Player.inventorySize do
		if key == tostring(i) then
			Player.selectedItem = i
		end
	end

	if key == "f3" then
		Global.debugMenu = not Global.debugMenu
	end

	if Global.debugMenu then
		if key == "k" then
			Enemies.enemies = {}
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

	if not Player.crafting and not love.keyboard.isDown("lctrl") then
		if y > 0 and Player.selectedItem > 1 then
			Player.selectedItem = Player.selectedItem - 1
		elseif y < 0 and Player.selectedItem < Player.inventorySize then
			Player.selectedItem = Player.selectedItem + 1
		end
	end
	if Global.debugMenu then
		if love.keyboard.isDown("lctrl") then
			if y > 0 then
				Camera.cam:setScale(Camera.cam.scale + 0.05)
			elseif y < 0 then
				Camera.cam:setScale(Camera.cam.scale - 0.05)
			end
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

---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@return number
function math.angle(x1, y1, x2, y2)
	return math.atan2(y2 - y1, x2 - x1)
end

function math.map(min1, max1, min2, max2)
	local interval1 = max1 - min1
	local interval2 = max2 - min2
	return function(value)
		return (value - min1) * interval2 / interval1 + min2
	end
end

print(love)