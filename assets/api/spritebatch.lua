---@meta

---@class sprite_batch
sprite_batch = {}

---@class SpriteBatch
local SpriteBatch = {}

---@return SpriteBatch the SpriteBatch instance
function sprite_batch.new() end

---@param batch SpriteBatch the SpriteBatch instance
---@param gd GraphicsDevice the GraphicsDevice instance
function sprite_batch.set_gd(batch, gd) end

---@param batch SpriteBatch the SpriteBatch instance
---@param camera Camera the Camera instance
---@param shader Shader the Shader instance
---@param viewport kmAABB2 the viewport to use when drawing. It might be different than the one used by the ViewAdapter attached to the camera
---@param sort string the sorting mode to apply to this batch
function sprite_batch.begin(batch, camera, shader, viewport, sort) end

---@param batch SpriteBatch the SpriteBatch instance
---@param camera Camera the Camera instance
---@param viewport kmAABB2 the viewport to use when drawing. It might be different than the one used by the ViewAdapter attached to the camera
function sprite_batch.finish(batch, camera, viewport) end

---@param batch SpriteBatch the SpriteBatch instance
---@param texture Texture the Texture instance
---@param x number the horizontal position
---@param y number the vertical position
---@param depth number the depth
function sprite_batch.draw(batch, texture, x, y, depth) end

return sprite_batch
