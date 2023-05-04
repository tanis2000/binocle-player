---@meta

---@class shader
shader = {}

---@class Shader
local Shader = {}

---@return Shader shader the default shader that writes to the offscreen texture
function shader.defaultShader() end

---@return Shader shader the screen shader
function shader.screenShader() end

return shader