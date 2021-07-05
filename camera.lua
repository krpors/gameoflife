local Object = require("classic")

local Camera = Object:extend()

function Camera:new()
	self.translation = {
		x = 20,
		y = 20
	}
	self.scale = 1
	self.rotation = 0
end

function Camera:set()
	love.graphics.push()
end

function Camera:unset()
	love.graphics.pop()
end

function Camera:update(dt)
	local swidth, sheight, flags = love.window.getMode()
end

function Camera:draw()
	love.graphics.rotate(self.rotation)
	love.graphics.scale(self.scale, self.scale)
	love.graphics.translate(self.translation.x, self.translation.y)
end

return Camera
