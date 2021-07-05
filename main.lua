local StatePlay = require("state_play")

Globals = {
	Font,
}

local state = StatePlay()

function love.load()
	local glyphs = " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-=_+|/\\:;'\"<>,.?"
	Globals.Font = love.graphics.newImageFont("font-small.png", glyphs, 1)
end

function love.mousepressed(x, y, button)
	state:mousepressed(x, y, button)
end

function love.mousemoved(x, y)
	state:mousemoved(x, y)
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	elseif key == "f" then
		love.window.setFullscreen(not love.window.getFullscreen())
	end

	state:keypressed(key)
end

function love.keyreleased(key)
	state:keyreleased(key)
end

function love.update(dt)
	state:update(dt)
end

function love.draw()
	state:draw()
end
