---@class texture
local m = {}

---@class Texture
local Texture = {}

---@param image Image an image instance
---@return Texture the texture instance
function m.from_image(image) end

---@param texture Texture the texture instance
function m.destroy(texture) end

return m