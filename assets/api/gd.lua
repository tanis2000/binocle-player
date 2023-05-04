---@class gd
local m = {}

---@meta

---@class GraphicsDevice
local GraphicsDevice = {}

---@class TextureFormat
local TextureFormat = {
    ['GL_RGBA8'] = 0x8058
}

---@return gd GraphicsDevice
function m.new() end

---@param gd GraphicsDevice an instance of GraphicsDevice
---@param win Window an instance of Window
function m.init(gd, win) end

---@param gd GraphicsDevice an instance of GraphicsDevice
---@param window Window an instance of Window
---@param width number width
---@param height number height
---@param viewport kmAABB2 the viewport
---@param camera Camera the camera to apply
function m.render_screen(gd, window, width, height, viewport, camera) end

---@param gd GraphicsDevice an instance of GraphicsDevice
---@param r number red 0..1
---@param g number green 0..1
---@param b number blue 0..1
---@param a number alpha 0..1
function m.set_offscreen_clear_color(gd, r, g, b, a) end

---@param vs_src string the vertex shader source code
---@param fs_src string the fragment shader source code
---@return shader the instance of the shader that contains the shader descriptor and later on the reference to the compiled shader and the reference to the pipeline
function m.create_shader_desc(vs_src, fs_src) end

---@param shader shader the shader instance
---@param stage string the shader stage, either VS or FS
---@param idx number the index of the uniform, starting at 0
---@param name string the name of the uniform (case sensitive)
---@param type string the type of the uniform (float, vec2, vec3, vec4, mat4)
function m.add_uniform_to_shader_desc(shader, stage, idx, name, type) end

---Compiles the shader description into a shader and keeps a reference to the compiled shader as part of the shader instance itself
---@param shader shader the shader instance
function m.create_shader(shader) end

---Creates the pipeline for the shader based on the offscreen pipeline and using the shader defined in the shader instance
---@param shader shader the shader instance
function m.create_pipeline(shader) end

return m