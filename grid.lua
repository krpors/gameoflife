local Object = require("classic")
local Lume = require("lume")

local Grid = Object:extend()

function Grid:new()
    self.width = 100
    self.height = 100
	self.cellsize = 25
	self.generation = 0
    self.grid = self:createEmptyGrid()
	self.wrap = true

    self.color1 = { 1, 1, 1, 1 }
    self.color2 = { 0, 0, 0, 1 }

    self.time = 0
	self.period = 0.5

    self.iterate = false

	self.mouse = {
		x = 1,
		y = 1,
	}

    self.highlight = {
        x = 1,
        y = 1,
    }

    self.a = ""

	self.stencil = {
		{ 1 },
	}

	self.neighbourColors = {
		[0] = { 100 / 255,  99 / 255,  80 / 255 },
		[1] = { 100 / 255,  93 / 255,  62 / 255 },
		[2] = { 100 / 255,  85 / 255,  46 / 255 },
		[3] = { 100 / 255,  70 / 255,  30 / 255 },
		[4] = { 100 / 255,  55 / 255,  23 / 255 },
		[5] = {  98 / 255,  30 / 255,  16 / 255 },
		[6] = {  89 / 255,  12 / 255,  11 / 255 },
		[7] = {  75 / 255,  10 / 255,  14 / 255 },
		[8] = {  50 / 255,   6 / 255,  15 / 255 },
	}

	self:initializeGrid()
end

function Grid:initializeGrid()
	self.lineGrid = {}

	-- horizontal lines:
	for y = 1, self.height * self.cellsize, self.cellsize do
		local line = { 0, y, self.width * self.cellsize, y}
		table.insert(self.lineGrid, line)
	end

	for x = 1, self.width * self.cellsize, self.cellsize do
		local line = { x, 0, x, self.height * self.cellsize}
		table.insert(self.lineGrid, line)
	end
end

function Grid:adjustCellSize(amount)
	self.cellsize = self.cellsize + amount
	self:initializeGrid()
end

function Grid:clear()
	self.grid = self:createEmptyGrid()
	self.generation = 0
end

function Grid:createEmptyGrid()
	local newgrid = {}

	for row = 1, self.height do
		newgrid[row] = {}

		for col = 1, self.width do
			newgrid[row][col] = 0
		end
	end

	return newgrid
end

function Grid:cellValueAt(r, c)
	local newr = r
	local newc = c

	-- wrap around boundaries:
	if self.wrap then
		if r < 1 then newr = self.height end
		if c < 1 then newc = self.width  end
		if r > self.height then newr = 1 end
		if c > self.width then newc = 1  end
	else
		if r < 1  or c < 1 or r > self.height or c > self.width then
			return 0
		end
	end

	return self.grid[newr][newc]
end

function Grid:getAliveCountFor(r, c)
	local count = 0

	local topleft  = self:cellValueAt(r - 1, c - 1)
	local top      = self:cellValueAt(r - 1, c    )
	local topright = self:cellValueAt(r - 1, c + 1)
	local left     = self:cellValueAt(r    , c - 1)
	local right    = self:cellValueAt(r    , c + 1)
	local botleft  = self:cellValueAt(r + 1, c - 1)
	local bottom   = self:cellValueAt(r + 1, c    )
	local botRight = self:cellValueAt(r + 1, c + 1)

	return topleft + top + topright + left + right + botleft + bottom + botRight
end

function Grid:setIterating(bool)
    self.iterate = bool
end

function Grid:nextIteration()
	local copy = self:createEmptyGrid()

	for r = 1, self.height do
		for c = 1, self.width do
			local alive = self:getAliveCountFor(r, c)

			if self.grid[r][c] == 1 then
				if alive == 2 or alive == 3 then
					-- keep livin'
					copy[r][c] = 1
				elseif alive >= 4 then
					-- overpopulation, so die
					copy[r][c] = 0
				end
			else
				-- dead cell, see if we can go alive
				if alive == 3 then
					-- alive!
					copy[r][c] = 1
				end
			end
		end
	end

	for r = 1, self.height do
		for c = 1, self.width do
			self.grid[r][c] = copy[r][c]
		end
	end
end

function Grid:placeStencil(y, x)
	-- Use a predefined 'stencil' as a template:
	for r, row in ipairs(self.stencil) do
		for c, _col in ipairs(row) do
			-- TODO: check within bounds of width/height
			self.grid[r + y - 1][c + x - 1] = self.stencil[r][c]
		end
	end
end

function Grid:mousepressed(x, y, button)
    local row = math.floor(y / self.cellsize) + 1
    local col = math.floor(x / self.cellsize) + 1

	row = Lume.clamp(row, 1, self.height)
	col = Lume.clamp(col, 1, self.width)

	if button == 1 then
		self:placeStencil(row, col)
	else
		self.grid[row][col] = 0
	end
end

function Grid:mousemoved(x, y)
	local x = math.floor(x / self.cellsize) + 1
	local y = math.floor(y / self.cellsize) + 1

	self.mouse.x = x
	self.mouse.y = y

    self.a = string.format("Alive count around (%d, %d) = %d", x, y, self:getAliveCountFor(y, x))

    self.highlight.x = x - 1
    self.highlight.y = y - 1
end

function Grid:update(dt)
    self.time = self.time + dt

    if self.iterate and self.time > self.period then
        self:nextIteration()
		self.generation = self.generation + 1
        self.time = 0
    end
end

function Grid:draw()
	love.graphics.clear()
	for r = 1, self.height do
		for c = 1, self.width do
			if self.grid[r][c] == 0 then
				love.graphics.setColor(self.color2)
			else
				local alc = self:getAliveCountFor(r, c)
				local color = self.neighbourColors[alc]
				love.graphics.setColor(color)
			end
			love.graphics.rectangle('fill', (c - 1) * self.cellsize, (r - 1) * self.cellsize, self.cellsize, self.cellsize)

		end
	end

	love.graphics.setColor(1, 1, 1, 0.2)
	for i, line in pairs(self.lineGrid) do
		love.graphics.line(line)
	end

	-- draw stencil
	love.graphics.setColor(0, 1, 0, 0.5)
	for r, row in ipairs(self.stencil) do
		for c, col in ipairs(row) do
			if self.stencil[r][c] == 1 then
				love.graphics.rectangle("fill",
					(c + self.mouse.x - 2) * self.cellsize,
					(r + self.mouse.y - 2) * self.cellsize, self.cellsize, self.cellsize)
			end
		end
	end
end

return Grid
