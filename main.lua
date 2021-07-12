local StatePlay = require("state_play")
local Audio = require("audio")

Globals = {
	Font,
}

local state = StatePlay()

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")
	local glyphs = " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-=_+|/\\:;'\"<>,.?"
	Globals.Font = love.graphics.newImageFont("font-small.png", glyphs, 1)

	Audio:loadStatic("blip", "574.mp3")
end

function love.mousepressed(x, y, button)
	state:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
	state:mousereleased(x, y, button)
end

function love.mousemoved(x, y)
	state:mousemoved(x, y)
end

function love.wheelmoved(x, y)
	state:wheelmoved(x, y)
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
