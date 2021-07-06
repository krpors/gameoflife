local Log = require("logger")

local Bla = {
	sound = {}
}

local AudioManager = {}
AudioManager.__index = AudioManager

AudioManager.static = {}
AudioManager.stream = {}

function AudioManager:loadStatic(identifier, file, pitch)
	self:load(identifier, file, pitch, "static")
end

function AudioManager:loadStream(identifier, file, pitch)
	self:load(identifier, file, pitch, "stream")
end

function AudioManager:load(identifier, file, pitch, sourceType)
	Log.info("Loading %s sound file '%s' from file '%s'", sourceType, identifier, file)

	self.static[identifier] = {
		index = 1,
		list = {},
	}

	for i = 1, 10 do
		local source = love.audio.newSource(file, sourceType)
		table.insert(self.static[identifier].list, source)
	end

	-- self.static[identifier] = love.audio.newSource(file, sourceType)
	-- self.static[identifier]:setPitch(pitch or 1)
end

function AudioManager:play(identifier, pitch)
	local source = self.static[identifier]

	source.list[source.index]:setPitch(pitch or 1)
	source.list[source.index]:play()

	if source.index >= table.getn(source.list) then
		source.index = 1
	else
		source.index = source.index + 1
	end

	-- self.static[identifier]:play()
end

function AudioManager:stop(identifier)
	self.static[identifier]:stop()
end

return setmetatable(AudioManager, {})
