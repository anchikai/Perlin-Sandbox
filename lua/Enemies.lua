local Cave = require("lua.Cave")
local Global = require("lua.GlobalValues")
local Camera = require("lua.Camera")
local BlockType = require("lua.BlockType")

local Enemies = {
    enemies = {},
    despawnRange = 64
}

local Vector = require("lib.vector")
local Luafinding = require("lib.luafinding")

function Enemies.load()
    
end

local passableBlocks = {
    [BlockType.Air] = true,
    [BlockType.Water] = true,
    [BlockType.Torch] = true,
}

local function handleDamage(dt, time, enemy, index)
    if enemy.hit and enemy.invulnerabilityTime > 0 then
		enemy.invulnerabilityTime = enemy.invulnerabilityTime - dt
		return
	else
		enemy.hit = false
		enemy.invulnerabilityTime = time
	end
	if Cave.getBlockType(math.floor(enemy.x / Global.unitSize), math.floor(enemy.y / Global.unitSize)) == BlockType.Lava then
		enemy.hit = true
		enemy.invulnerabilityTime = enemy.invulnerabilityTime / 2
		enemy.hp = enemy.hp - 1
		if enemy.hp == 0 then
			table.remove(Enemies.enemies, index)
		end
	end
end

local function targetPlayer(dt, playerX, playerY, enemy)
	enemy.start = Vector(math.floor(enemy.x / Global.unitSize + 0.5), math.floor(enemy.y / Global.unitSize + 0.5))
	if not enemy.wandering then
		enemy.finish = Vector(math.floor(playerX / Global.unitSize), math.floor(playerY / Global.unitSize))
	end
	enemy.playerPath = Luafinding(enemy.start, enemy.finish, function(pos)
		return passableBlocks[Cave.getBlockType(pos.x, pos.y)] and math.dist(playerX, playerY, pos.x * Global.unitSize, pos.y * Global.unitSize) < Global.unitSize * Enemies.despawnRange
	end):GetPath()

	if not enemy.wandering then
		if enemy.playerPath and enemy.playerPath[2] then
			enemy.hasRandomPath = false
			enemy.path = enemy.playerPath
			local angle = math.angle(enemy.x, enemy.y, enemy.playerPath[2].x * Global.unitSize, enemy.playerPath[2].y * Global.unitSize)
			enemy.x = enemy.x + math.cos(angle) * 128 * dt
			enemy.y = enemy.y + math.sin(angle) * 128 * dt
		end
	end
end

local function targetRandom(dt, playerX, playerY, enemy)
	enemy.wandering = enemy.playerPath == nil or math.dist(playerX, playerY, enemy.x, enemy.y) >= 8 * Global.unitSize

	local rx, ry = 0, 0
	local spawnRadius = Global.unitSize * (Enemies.despawnRange / 2)
	if not enemy.hasRandomPath then
		repeat
			local r = spawnRadius * math.sqrt((love.math.random() * 0.5))
			local theta = love.math.random() * 2 * math.pi
			rx = enemy.x + r * math.cos(theta)
			ry = enemy.y + r * math.sin(theta)
		until passableBlocks[Cave.getBlockType(math.floor(rx / Global.unitSize), math.floor(ry / Global.unitSize))]

		enemy.finish = Vector(math.floor(rx / Global.unitSize), math.floor(ry / Global.unitSize))
	end
	if enemy.wandering and enemy.hasRandomPath then
		if enemy.wanderingPath and enemy.wanderingPath[2] then
			enemy.path = enemy.wanderingPath
			local angle = math.angle(enemy.x, enemy.y, enemy.wanderingPath[2].x * Global.unitSize, enemy.wanderingPath[2].y * Global.unitSize)
			enemy.x = enemy.x + math.cos(angle) * 128 * dt
			enemy.y = enemy.y + math.sin(angle) * 128 * dt

			if Vector(math.floor(enemy.x / Global.unitSize), math.floor(enemy.y / Global.unitSize)) == enemy.wanderingPath[2] then
				enemy.start = enemy.wanderingPath[2]
			end
		end
	end
	enemy.wanderingPath = Luafinding(enemy.start, enemy.finish, function(pos)
		return passableBlocks[Cave.getBlockType(pos.x, pos.y)] and math.dist(playerX, playerY, pos.x * Global.unitSize, pos.y * Global.unitSize) < Global.unitSize * Enemies.despawnRange
	end):GetPath()

	enemy.hasRandomPath = enemy.wanderingPath and enemy.wanderingPath[2]
end

local function spawning(playerX, playerY)
	if love.math.random() <= 0.0005 then
        local rx, ry
        local spawnRadius = Global.unitSize * (Enemies.despawnRange / 2)
        repeat
            local r = spawnRadius * math.sqrt((love.math.random() * 0.5))
            local theta = love.math.random() * 2 * math.pi
            rx = playerX + r * math.cos(theta)
            ry = playerY + r * math.sin(theta)
        until passableBlocks[Cave.getBlockType(math.floor(rx / Global.unitSize), math.floor(ry / Global.unitSize))]
        table.insert(Enemies.enemies, {
			x = rx,
			y = ry,
			hp = 10,
			maxHp = 10,
			hit = false,
			wandering = false,
			invulnerabilityTime = 1,
			playerPath = nil,
			wanderingPath = nil,
			hasRandomPath = false,
			path = nil,
			start = Vector(rx, ry),
			finish = Vector(math.floor(playerX / Global.unitSize), math.floor(playerY / Global.unitSize))
		})
    end
end

local function despawning(playerX, playerY, enemy, index)
	if math.dist(enemy.x, enemy.y, playerX, playerY) >= Global.unitSize * Enemies.despawnRange then
		table.remove(Enemies.enemies, index)
	end
end

function Enemies.update(dt)
    local playerX, playerY = Camera.cam:getPosition()
	for i, enemy in ipairs(Enemies.enemies) do
		handleDamage(dt, 1, enemy, i)
		targetPlayer(dt, playerX, playerY, enemy)
		targetRandom(dt, playerX, playerY, enemy)
		despawning(playerX, playerY, enemy, i)
	end
	spawning(playerX, playerY)
end

local function healthBar()
    for i, enemy in ipairs(Enemies.enemies) do
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.rectangle("fill", enemy.x, enemy.y + Global.unitSize + 3, math.map(enemy.hp, 0, enemy.maxHp, 0, Global.unitSize), 4)
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("line", enemy.x, enemy.y + Global.unitSize + 3, Global.unitSize, 4)
    end
end

function Enemies.draw()
	local playerX, playerY = Camera.cam:getPosition()
    for i, enemy in ipairs(Enemies.enemies) do
        if enemy.path and Global.debugMenu then
            for j, path in ipairs(enemy.path) do
				if enemy.wandering then
					love.graphics.setColor(0, 0, 1, 0.5)
				else
					love.graphics.setColor(0, 1, 0, 0.5)
				end
                love.graphics.rectangle("fill", path.x * Global.unitSize, path.y * Global.unitSize, Global.unitSize, Global.unitSize)
            end
        end
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.rectangle("fill", enemy.x, enemy.y, Global.unitSize, Global.unitSize)
		if Global.debugMenu then
			love.graphics.setColor(1, 1, 1, 1)
			love.graphics.print(tostring(math.floor(math.dist(playerX, playerY, enemy.x, enemy.y) / Global.unitSize)), enemy.x, enemy.y)
		end
        healthBar()
    end
end

return Enemies