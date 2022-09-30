---@class gd
local m = {}

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

return m