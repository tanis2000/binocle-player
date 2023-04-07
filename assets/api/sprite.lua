---@meta

---@class sprite
sprite = {}

---@class Sprite
local Sprite = {}

---@param sprite Sprite the sprite instance
---@param gd GraphicsDevice the gd instance
---@param x number the horizontal position
---@param y number the vertical position
---@param viewport kmAABB2 the viewport
---@param rotation number the rotation angle
---@param scaleX number the horizontal scale
---@param scaleY number the vertical scale
---@param camera Camera the camera to apply
---@param depth number the depth of the sprite
function sprite.draw(sprite, gd, x, y, viewport, rotation, scaleX, scaleY, camera, depth) end

---@param material Material the material to create the sprite from
---@return Sprite sprite a sprite instance
function sprite.from_material(material) end

---@param sprite Sprite the sprite instance
---@param subtexture SubTexture the instance of the subtexture representing the rect of the texture to use for the sprite
function sprite.set_subtexture(sprite, subtexture) end

---@param sprite Sprite the sprite instance
---@param x number the horizontal position of the origin
---@param y number the vertical position of the origin
function sprite.set_origin(sprite, x, y) end

return sprite