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

---@param material Material the material instance
---@param shader Shader the shader instance that contains the shader itself, the descriptor and the pipeline
function material.set_pipeline(material, shader) end

---@param material Material the material instance
---@param stage string the shader stage, either VS or FS
---@param name string the name of the uniform (case-sensitive)
---@param value number the value of the uniform
function material.set_uniform_float(material, stage, name, value) end

return material