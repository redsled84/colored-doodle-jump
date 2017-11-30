local Cam = require "camera"

local colorIndex = 1
local colors = {
	{255, 255, 0},
	{0, 255, 0},
	{0, 255, 255},
	{255, 0, 0}
}
math.randomseed(os.time())
local platforms = {}
local platformWidth, platformHeight = 100, 20

local player = {
	xvel = 0,
	yvel = 0,
	runSpeed = 420,
	jumpVelocity = -700,
	width = 32,
	height = 32
}

local spamPreventionVariable = 0

function love.load()
	cam = Cam(love.graphics.getWidth()/2, love.graphics.getHeight()/2)

	local yInit = love.graphics.getHeight() - 50
	player.y = yInit - 200 - player.height

	for i = -1, -1000, -1 do

		local platform = {
			x = math.random(0, love.graphics.getWidth()-platformWidth),
			y = yInit + (i + 1) * 300,
			color = colors[math.random(1, #colors)],
			width = platformWidth,
			height = platformHeight
		}
		platforms[#platforms+1] = platform
	end

	player.x = platforms[1].x + 25
end

function aabb(a, b)
	return a.x + a.width > b.x and a.x < b.x + b.width and a.y + a.height > b.y and a.y < b.y + b.height
end

function sameColors(a, b)
	return a[1] == b[1] and a[2] == b[2] and a[3] == b[3]
end

local score = 0
function love.update(dt)
	if love.keyboard.isDown("d") then
		player.xvel = player.runSpeed
	elseif love.keyboard.isDown("a") then
		player.xvel = -player.runSpeed
	else
		player.xvel = 0
	end

	for i = #platforms, 1, -1 do
		if aabb(platforms[i], player) and player.y + player.height >= platforms[i].y and sameColors(platforms[i].color, colors[colorIndex]) then
			spamPreventionVariable = 0
			player.yvel = player.jumpVelocity
			score = score + 1
			table.remove(platforms, i)
		end
	end

	player.yvel = player.yvel + 600 * dt
	player.y = player.y + player.yvel * dt
	player.x = player.x + player.xvel * dt

	if player.x < 0 then
		player.x = 0
	elseif player.x + player.width > love.graphics.getWidth() then
		player.x = love.graphics.getWidth() - player.width
	end

	cam:lookAt(love.graphics.getWidth()/2, player.y)
end

function love.draw()
	cam:attach()

	for i = 1, #platforms do
		local platform = platforms[i]
		love.graphics.setColor(unpack(platform.color))
		love.graphics.rectangle("fill", platform.x, platform.y, platformWidth, platformHeight)
	end
	love.graphics.setColor(unpack(colors[colorIndex]))
	love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)

	cam:detach()

	love.graphics.setColor(255,255,255)
	love.graphics.print("Score: " .. score, 20, love.graphics.getHeight() - 50)
end

function love.keypressed(key)
	if key == "space" then
		player.yvel = player.jumpVelocity
	end
	if key == "escape" then
		love.event.quit()
	elseif key == "r" then
		love.event.quit("restart")
	end
	for i = 1, #colors do
		if key == tostring(i) and spamPreventionVariable <= 2 then
			colorIndex = i
			spamPreventionVariable = spamPreventionVariable + 1
			break
		end
	end
end