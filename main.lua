local Grid = require("grid")
local Camera = require("camera")

Globals = {
	Font,
}

local gol = nil
local cam = nil

function love.load()
	local glyphs = " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-=_+|/\\:;'\"<>,.?"
	Globals.Font = love.graphics.newImageFont("font-small.png", glyphs, 1)

	gol = Grid()
	cam = Camera()
end

function love.mousepressed(xx, yy, button)
	gol:mousepressed(xx, yy, button)
end

function love.mousemoved(x, y)
	gol:mousemoved(x, y)
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	elseif key == "f" then
		love.window.setFullscreen(not love.window.getFullscreen())
	elseif key == "space" then
		gol:setIterating(true)
	end
end

function love.keyreleased(key)
	if key == "space" then
		gol:setIterating(false)
	end
end

function love.draw()
--	love.graphics.scale(0.2, 0.2)
	cam:set()
	-- cam:draw()
	gol:draw()
	cam:unset()
end

function love.update(dt)
	cam:update(dt)
	gol:update(dt)
end
