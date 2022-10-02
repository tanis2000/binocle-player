local Cache = require("lib.classic"):extend()
Cache.map = {}

function Cache.load(filename)
	if not Cache.map[filename] then
		if filename:match("%.png$") then
			local assets_dir = sdl.assets_dir()
			local image_filename = assets_dir .. filename
			Cache.map[filename] = image.load(image_filename)
		elseif filename:match("%.ogg$") or filename:match("%.wav") or filename:match("%.mp3") then
			-- TODO: cache audio
		else
			-- TODO: cache raw file
		end
	end

	return Cache.map[filename]
end

function Cache.clear()
	Cache.map = {}
end

return Cache
