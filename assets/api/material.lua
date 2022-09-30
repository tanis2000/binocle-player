---@class material
local m = {}

---@class Material
local Material = {}

---@return Material an empty instance of a material
function m.new() end

---@param material Material the material instance
---@param texture Texture the texture
function m.set_texture(material, texture) end

---@param material Material the material instance
---@param shader Shader the shader
function m.set_shader(material, shader) end

---@param material Material the material instance
function m.destroy(material) end

return m