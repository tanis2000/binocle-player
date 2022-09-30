---@meta

---@class material
material = {}

---@class Material
local Material = {}

---@return Material an empty instance of a material
function material.new() end

---@param material Material the material instance
---@param texture Texture the texture
function material.set_texture(material, texture) end

---@param material Material the material instance
---@param shader Shader the shader
function material.set_shader(material, shader) end

---@param material Material the material instance
function material.destroy(material) end

return material