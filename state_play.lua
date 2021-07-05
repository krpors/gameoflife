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
		["d"] = function() self.grid:clear() end
	}

	self.debugStrings = {
	}
end

function StatePlay:mousepressed(x, y, button)
	self.grid:mousepressed(x, y, button)
end

function StatePlay:mousemoved(x, y)
	self.grid:mousemoved(x, y)
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
	}
end

function StatePlay:draw()
	self.grid:draw()

	love.graphics.setFont(Globals.Font)
	love.graphics.setColor(1, 1, 1, 1)
	for i, str in ipairs(self.debugStrings) do
		love.graphics.print(str, 5, 12 * (i - 1) + 5)
	end
end


return StatePlay
