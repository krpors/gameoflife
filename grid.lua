local Object = require("classic")

local Grid = Object:extend()

function Grid:new()
    self.width = 100
    self.height = 100
    self.cellsize = 20
    self.grid = self:createEmptyGrid()

    self.color1 = { 1, 1, 1 }
    self.color2 = { 0, 0, 0 }

    self.time = 0

    self.iterate = false

    self.highlight = {
        x = 1,
        y = 1,
    }

    self.a = ""

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

	self.lineGrid = {
	}

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
	if r < 1  or c < 1 or r > self.height or c > self.width then
		return 0
	end

	return self.grid[r][c]
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
					copy[r][c] = 1
				elseif alive >= 4 then
					-- overpopulation
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

function Grid:mousepressed(x, y, button)
    local row = math.floor(y / self.cellsize) + 1
    local col = math.floor(x / self.cellsize) + 1

    local val = self.grid[row][col]
    if val == 0 then
        val = 1
    else
        val = 0
    end

    self.grid[row][col] = val
end

function Grid:mousemoved(x, y)
	local x = math.floor(x / self.cellsize) + 1
	local y = math.floor(y / self.cellsize) + 1

    self.a = string.format("Alive count around (%d, %d) = %d", x, y, self:getAliveCountFor(y, x))

    self.highlight.x = x - 1
    self.highlight.y = y - 1
end

function Grid:update(dt)
    self.time = self.time + dt

    if self.iterate and self.time > 0.1 then
        self:nextIteration()
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

    love.graphics.setColor(1, 0, 0, 0.2)
    love.graphics.rectangle("fill", self.highlight.x * self.cellsize, self.highlight.y * self.cellsize, self.cellsize, self.cellsize)

    love.graphics.setFont(Globals.Font)
	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.print(self.a, 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print(self.a, 11, 11)
end

return Grid
