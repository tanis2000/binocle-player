---@class viewport_adapter
local m = {}

---@class ViewportAdapter
local ViewportAdapter = {}

---@param window Window
---@param kind string "basic", "scaling"
---@param scaling string "none", "free", "pixel_perfect", "boxing"
---@param width number
---@param height number
---@param virtual_width number
---@param virtual_height number
---@return viewport_adapter ViewportAdapter
function m.new(window, kind, scaling, width, height, virtual_width, virtual_height) end

---@param viewport_adapter ViewportAdapter an instance of ViewportAdapter
---@return kmAABB2 the viewport
function m.get_viewport(viewport_adapter) end

---@param viewport_adapter ViewportAdapter an instance of ViewportAdapter
---@return number the horizontal position of the viewport
function m.get_viewport_min_x(viewport_adapter) end

---@param viewport_adapter ViewportAdapter an instance of ViewportAdapter
---@return number the vertical position of the viewport
function m.get_viewport_min_y(viewport_adapter) end

---@param viewport_adapter ViewportAdapter an instance of ViewportAdapter
---@return number the multiplier of the viewport
function m.get_multiplier(viewport_adapter) end

---@param viewport_adapter ViewportAdapter an instance of ViewportAdapter
---@return number the inverse multiplier of the viewport
function m.get_inverse_multiplier(viewport_adapter) end

return m