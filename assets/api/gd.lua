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

---@param w number width
---@param h number height
---@param use_depth boolean use depth
---@param format TextureFormat render target texture format
function m.create_render_target(w, h, use_depth, format) end

return m