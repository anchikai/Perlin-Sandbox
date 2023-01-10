local Menus = require("lua.Menus")
local Settings = require("lua.Settings")

---@alias Action string

---@class Device
---@field id integer
---@field inputs { [Action]: number? }
local Device = {}
Device.__index = Device

---@param id integer
---@return Device
function Device.new(id)
	local self = {
		id = id,
		inputs = {},
	}

	setmetatable(self, Device)

	return self
end

function Device:update(dt)
	for action, duration in pairs(self.inputs) do
		self.inputs[action] = duration + dt
	end
end

---@param key love.KeyConstant
function Device:registerPressKey(key)
	local action = self:getAction("keyboard", key)
	if action and self.inputs[action] == nil then
		self.inputs[action] = 0
	end
end

---@param key love.KeyConstant
function Device:registerReleaseKey(key)
	local action = self:getAction("keyboard", key)
	if action then
		self.inputs[action] = nil
	end
end

function Device:registerPressMouse(button)
	local action = self:getAction("mouse", button)
	if action then
		self.inputs[action] = 0
	end
end

function Device:registerReleaseMouse(button)
	local action = self:getAction("mouse", button)
	if action then
		self.inputs[action] = nil
	end
end

---@param inputType "keyboard"
---@param input love.KeyConstant
---@overload fun(self: Device, inputType: "mouse", input: integer): (Action?)
---@overload fun(self: Device, inputType: "gamepad", input: love.GamepadButton): (Action?)
---@return Action?
function Device:getAction(inputType, input)
	local controlScheme = Settings.controlSchemes[self.id]
	local context = Menus.getInputContext()
	return controlScheme[inputType][context][input]
end

---@param action Action
---@param duration? number
---@return boolean
function Device:pressing(action, duration)
	if duration then
		local currentDuration = self.inputs[action]
		if currentDuration then
			return currentDuration >= duration
		else
			return false
		end
	else
		return self.inputs[action] ~= nil
	end
end

function Device:clearInputs()
	for action in pairs(self.inputs) do
		self.inputs[action] = nil
	end
end

return Device