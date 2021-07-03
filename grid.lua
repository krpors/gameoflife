local Object = require("classic")

local Grid = Object:extend()

function Grid:new()
    self.width = 100
    self.height = 100
    self.cellsize = 20
    self.grid = self:createEmptyGrid()


    self.time = 0

    self.iterate = false


    self.grid[4][4] = 1
    self.grid[5][5] = 1
    self.grid[6][3] = 1
    self.grid[6][4] = 1
    self.grid[6][5] = 1

    self.grid[9][4] = 1
    self.grid[10][5] = 1
    self.grid[11][3] = 1
    self.grid[11][4] = 1
    self.grid[11][5] = 1

    self.a = ""
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
end

function Grid:update(dt)
    self.time = self.time + dt

    if self.iterate then
        self:nextIteration()
        self.time = 0
    end
end

function Grid:draw()
	love.graphics.clear()
	for r = 1, self.height do
		for c = 1, self.width do
			if self.grid[r][c] == 0 then
				love.graphics.setColor(1, 1, 1, 1)
			else
				love.graphics.setColor(0, 0, 0, 1)
			end
			love.graphics.rectangle('fill', (c - 1) * self.cellsize, (r - 1) * self.cellsize, self.cellsize, self.cellsize)

			-- horiz
			-- love.graphics.setLineWidth(1)
			-- love.graphics.setColor(0, 0, 0, 1)
			-- love.graphics.line(0, (r - 1) * self.cellsize, self.cellsize * self.width, (r - 1) * self.cellsize)
            -- love.graphics.line(0, 0, 10, 10) -- FIXME: This bugs?

			-- love.graphics.setColor(0, 0, 0, 1)
			-- love.graphics.line((c - 1) * self.cellsize, 0, (c - 1) * self.cellsize, self.cellsize * self.height)
		end
	end

    love.graphics.setFont(Globals.Font)
	love.graphics.setColor(0, 0, 0, 1)
	love.graphics.print(self.a, 10, 10)
    love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print(self.a, 11, 11)
end

return Grid
