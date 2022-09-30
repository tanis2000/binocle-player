---@meta

---@class texture
texture = {}

---@class Texture
local Texture = {}

---@param image Image an image instance
---@return Texture the texture instance
function texture.from_image(image) end

---@param texture Texture the texture instance
function texture.destroy(texture) end

return texture