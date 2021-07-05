local Object = require("classic")


local Stack = Object:extend()

function Stack:new()
	self.t = {}
end

function Stack:push(obj)
	table.insert(self.t, obj)
end

function Stack:pop()
	local last = self.t[#self.t]
	self.t[#self.t] = nil
	return last
end

function Stack:peek()
	return self.t[#self.t]
end

function Stack:__tostring()
	return string.format("Stack [%d], top is [%s]", #self.t, self.t[1])
end

return Stack
