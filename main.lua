local grid = {}
local gridwidth = 120
local gridheight = 80
local cellsize = 20

local font = nil

local time = 0

local mouseCell = {
	x = 1,
	y = 1,
}

function createEmptyGrid(height, width)
	local newgrid = {}

	for row = 1, height do
		newgrid[row] = {}

		for col = 1, width do
			newgrid[row][col] = 0
		end
	end

	return newgrid
end

function initGrid()
	grid = createEmptyGrid(gridheight, gridwidth)

	grid[4][4] = 1
	grid[5][5] = 1
	grid[6][3] = 1
	grid[6][4] = 1
	grid[6][5] = 1
end

function printGrid()
	for r in ipairs(grid) do
		for c in ipairs(grid[r]) do
			io.write(grid[r][c] .. ",")
		end
		io.write("\n")
	end
	io.flush()
end

function cellValueAt(r, c)
	if r < 1  or c < 1 or r > gridheight or c > gridwidth then
		return 0
	end

	return grid[r][c]
end

function aliveCountAround(r, c)
	local count = 0

	local topleft  = cellValueAt(r - 1, c - 1)
	local top      = cellValueAt(r - 1, c    )
	local topright = cellValueAt(r - 1, c + 1)
	local left     = cellValueAt(r    , c - 1)
	local right    = cellValueAt(r    , c + 1)
	local botleft  = cellValueAt(r + 1, c - 1)
	local bottom   = cellValueAt(r + 1, c    )
	local botRight = cellValueAt(r + 1, c + 1)

	return topleft + top + topright + left + right + botleft + bottom + botRight
end

function copyTable(table)
	local copy = {}

	for row = 1, gridheight do
		copy[row] = {}

		for col = 1, gridwidth do
			copy[row][col] = table[row][col]
		end
	end

	return copy
end

function nextIteration()
	local copy = createEmptyGrid(gridheight, gridwidth)

	for r = 1, gridheight do
		for c = 1, gridwidth do
			local alive = aliveCountAround(r, c)

			if grid[r][c] == 1 then
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
			-- check for neighbours here
		end
	end

	for r = 1, gridheight do
		for c = 1, gridwidth do
			grid[r][c] = copy[r][c]
		end
	end
end

function love.load()
	initGrid()

	local glyphs = " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-=_+|/\\:;'\"<>,.?"
	font = love.graphics.newImageFont("font-small.png", glyphs, 1)
end

function love.mousemoved(x, y)
	local cellwidth = love.graphics.getWidth() / gridwidth
	local cellheight = love.graphics.getHeight() / gridheight

	local x = math.floor(x / cellwidth) + 1
	local y = math.floor(y / cellheight) + 1
	mouseCell = {
		x = x,
		y = y,
	}
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	elseif key == "f" then
		love.window.setFullscreen(not love.window.getFullscreen())
	elseif key == "space" then
		nextIteration()
	end
end

function love.draw()
	local cellwidth = love.graphics.getWidth() / gridwidth
	local cellheight = love.graphics.getHeight() / gridheight

	love.graphics.clear()
	love.graphics.setLineWidth(0.2)
	for r = 1, gridheight do
		for c = 1, gridwidth do
			if grid[r][c] == 0 then
				love.graphics.setColor(1, 1, 1, 1)
			else
				love.graphics.setColor(0, 0, 0, 1)
			end
			love.graphics.rectangle('fill', (c - 1) * cellwidth, (r - 1) * cellheight, cellwidth, cellheight)

			-- -- horiz
			-- love.graphics.setLineWidth(0.2)
			-- love.graphics.setColor(1, 1, 0, 1)
			-- love.graphics.line(0, (r - 1) * cellsize, cellsize * gridwidth, (r - 1) * cellsize)
			-- -- -- vert
			-- love.graphics.setColor(1, 0, 0, 1)
			-- love.graphics.line((c - 1) * cellsize, 0, (c - 1) * cellsize, cellsize * gridheight)
		end
	end

	love.graphics.setFont(font)
	love.graphics.setColor(1, 0, 0)
	local alive = aliveCountAround(mouseCell.y, mouseCell.x)
	love.graphics.print(string.format("Value at %d, %d = %d", mouseCell.x, mouseCell.y, grid[mouseCell.y][mouseCell.x]), 10, 10)
	love.graphics.print(string.format("Alive count at %d, %d = %d", mouseCell.x, mouseCell.y, alive), 10, 0)
end

function love.update(dt)
	-- nextIteration()
end
