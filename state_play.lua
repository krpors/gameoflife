local Object = require("classic")
local Grid = require("grid")

local StatePlay = Object:extend()

local Stencil = Object:extend()

local stencilSingle = {
	name = "Single",
	grid = {
		{ 1 },
	}
}

local stencilGlider = {
	name = "Glider",
	grid = {
		{ 0, 1, 0},
		{ 0, 0, 1},
		{ 1, 1, 1},
	}
}

local stencilLWSS = {
	name = "Lightweight spaceship",
	grid = {
		{ 0, 1, 1, 1, 1 },
		{ 1, 0, 0, 0, 1 },
		{ 0, 0, 0, 0, 1 },
		{ 1, 0, 0, 1, 0 },
	}
}

local stencilRPentomino = {
	name = "R-pentomino",
	grid = {
		{ 0, 1, 1 },
		{ 1, 1, 0 },
		{ 0, 1, 0 },
	}
}

local stencilDiehard = {
	name = "Diehard",
	grid = {
		{ 0, 0, 0, 0, 0, 0, 1, 0 },
		{ 1, 1, 0, 0, 0, 0, 0, 0 },
		{ 0, 1, 0, 0, 0, 1, 1, 1 },
	}
}

local stencilAcorn = {
	name = "Acorn",
	grid = {
		{ 0, 1, 0, 0, 0, 0, 0 },
		{ 0, 0, 0, 1, 0, 0, 0 },
		{ 1, 1, 0, 0, 1, 1, 1 },
	}
}


function StatePlay:new()
	self.grid = Grid()

	self.stencilIndex = 1
	self.stencils = {
		stencilSingle,
		stencilGlider,
		stencilLWSS,
		stencilRPentomino,
		stencilDiehard,
		stencilAcorn,
	}

	self.clickOrigin = { x = 1, y = 1}
	self.scale = 1
	self.translationTemp = {x = 0, y = 0}
	self.translation = { x = 0, y = 0}

	self.keymapping = {
		["["] = function() self.grid.period = self.grid.period - 0.05 end,
		["]"] = function() self.grid.period = self.grid.period + 0.05 end,
		["space"] = function() self.grid:setIterating(not self.grid.iterate) end,
		["."] = function()
			self.stencilIndex = self.stencilIndex + 1
			if self.stencilIndex > #self.stencils then self.stencilIndex = 1 end
			self.grid.stencil = self.stencils[self.stencilIndex].grid
		end,
		[","] = function()
			self.stencilIndex = self.stencilIndex - 1
			if self.stencilIndex < 1 then self.stencilIndex = #self.stencils end
			self.grid.stencil = self.stencils[self.stencilIndex].grid
		end,
		["up"] = function() self.grid:adjustCellSize(1) end,
		["down"] = function() self.grid:adjustCellSize(-1) end,
		["d"] = function() self.grid:clear() end,
		["b"] = function() self.grid.wrap = not self.grid.wrap end
	}

	self.debugStrings = {
	}
end

function StatePlay:mousepressed(x, y, button)
	if button == 3 then
		self.pressed = true
		self.clickOrigin.x = x
		self.clickOrigin.y = y
	end
	self.grid:mousepressed(x, y, button)
end

function StatePlay:mousereleased(x, y, button)
	if button == 3 then
		self.pressed = false
		self.translationTemp.x = self.translation.x
		self.translationTemp.y = self.translation.y
	end
end

function StatePlay:mousemoved(x, y)
	self.grid:mousemoved(x, y)

	if self.pressed then
		print(self.clickOrigin.x, self.clickOrigin.y)
		local diffx = self.clickOrigin.x - x
		local diffy = self.clickOrigin.y - y
		self.translation.x = (self.translationTemp.x - diffx)
		self.translation.y = (self.translationTemp.y - diffy)
	end
end

function StatePlay:wheelmoved(x, y)
    if y > 0 then
        self.scale = self.scale + 0.1
    elseif y < 0 then
        self.scale = self.scale - 0.1
    end

	self.grid.scale = self.scale
end


function StatePlay:keypressed(key)
	if self.keymapping[key] then
		self.keymapping[key]()
	end
end

function StatePlay:keyreleased(key)
end

function StatePlay:update(dt)
	self.grid:update(dt)

	self.debugStrings = {
		string.format("Playing: %s", self.grid.iterate),
		string.format("Period: %1.2f", self.grid.period),
		string.format("Stencil: %d (%s)", self.stencilIndex, self.stencils[self.stencilIndex].name),
		string.format("Generation: %d", self.grid.generation),
		string.format("Wrapping: %s", self.grid.wrap),
	}
end

function StatePlay:draw()
	love.graphics.push()
	love.graphics.scale(self.scale, self.scale)
	love.graphics.translate(self.translation.x, self.translation.y)
	self.grid:draw()
	love.graphics.pop()

	love.graphics.setFont(Globals.Font)
	love.graphics.setColor(1, 1, 1, 1)
	for i, str in ipairs(self.debugStrings) do
		love.graphics.print(str, 5, 12 * (i - 1) + 5)
	end

end


return StatePlay
