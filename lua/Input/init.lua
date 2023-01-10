local Menus = require("lua.Menus")
local Device = require("lua.Input.Device")
local Settings = require("lua.Settings")

---@alias InputType "mouse" | "keyboard" | "gamepad"

local Input = {
	---@type Device[]
	players = { Device.new(1), Device.new(2) },
	pressed = {},
	released = {},
	lastInput = "mouse" ---@type InputType
}

function Input.pressed.fullscreen()
	Settings.fullscreen = not Settings.fullscreen
	love.window.setFullscreen(Settings.fullscreen)
end

---@param dt number
function Input.update(dt)
	for _, player in ipairs(Input.players) do
		player:update(dt)
	end
end

---@param action Action
---@param duration? number
---@return boolean
function Input.pressing(action, duration)
	for _, player in pairs(Input.players) do
		if player:pressing(action, duration) then
			return true
		end
	end

	return false
end

function Input.clear()
	for _, player in ipairs(Input.players) do
		player:clearInputs()
	end
end

---@param inputType "keyboard"
---@param input love.KeyConstant
---@overload fun(inputType: "mouse", input: integer): (Action?, Device?)
---@overload fun(inputType: "gamepad", input: love.GamepadButton): (Action?, Device?)
---@return Action?, Device?
function Input.getAction(inputType, input)
	local context = Menus.getInputContext()
	for id, player in ipairs(Input.players) do
		local action = Settings.controlSchemes[id][inputType][context][input]
		if action then
			return action, player
		end
	end
end

local joystickCount = 1
local joystickMapping = {}

---@param joystick love.Joystick
---@return Device
function Input.getPlayerFromJoystick(joystick)
	local id = joystick:getID()
	local player = joystickMapping[id]
	if player then return player end
	joystickCount = joystickCount + 1
	player = Input.players[joystickCount]
	joystickMapping[id] = player
	return player
end

---@param key love.KeyConstant
function Input.keypressed(key)
	local context = Menus.getInputContext()
	for id, player in ipairs(Input.players) do
		local action = Settings.controlSchemes[id].keyboard[context][key]
		local handler = Input.pressed[action]
		if handler then
			handler(player)
		end
		player:registerPressKey(key)
	end
end

---@param key love.KeyConstant
function Input.keyreleased(key)
	for id, player in ipairs(Input.players) do
		local context = Menus.getInputContext()
		local action = Settings.controlSchemes[id].keyboard[context][key]
		local handler = Input.released[action]
		if handler then
			handler(player)
		end
		player:registerReleaseKey(key)
	end
end

---@param button integer
function Input.mousepressed(button)
	for _, player in ipairs(Input.players) do
		player:registerPressMouse(button)
	end
end

---@param button integer
function Input.mousereleased(button)
	for _, player in ipairs(Input.players) do
		player:registerReleaseMouse(button)
	end
end

return Input