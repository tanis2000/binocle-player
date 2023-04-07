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
---@param color Color the color to use
---@param camera Camera the camera to apply
---@param depth number the depth of the sprite
function sprite.draw(sprite, gd, x, y, viewport, color, camera, depth) end

return sprite