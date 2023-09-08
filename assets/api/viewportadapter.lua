---@meta

---@class viewport_adapter
viewport_adapter = {}

---@class ViewportAdapter
local ViewportAdapter = {}

---@param window Window
---@param kind string "basic", "scaling"
---@param scaling string "none", "free", "pixel_perfect", "boxing"
---@param width number
---@param height number
---@param virtual_width number
---@param virtual_height number
---@return ViewportAdapter viewport_adapter viewport adapter instance
function viewport_adapter.new(window, kind, scaling, width, height, virtual_width, virtual_height) end

---@param viewport_adapter ViewportAdapter an instance of ViewportAdapter
---@return kmAABB2 the viewport
function viewport_adapter.get_viewport(viewport_adapter) end

---@param viewport_adapter ViewportAdapter an instance of ViewportAdapter
---@return number the horizontal position of the viewport
function viewport_adapter.get_viewport_min_x(viewport_adapter) end

---@param viewport_adapter ViewportAdapter an instance of ViewportAdapter
---@return number the vertical position of the viewport
function viewport_adapter.get_viewport_min_y(viewport_adapter) end

---@param viewport_adapter ViewportAdapter an instance of ViewportAdapter
---@return number the multiplier of the viewport
function viewport_adapter.get_multiplier(viewport_adapter) end

---@param viewport_adapter ViewportAdapter an instance of ViewportAdapter
---@return number the inverse multiplier of the viewport
function viewport_adapter.get_inverse_multiplier(viewport_adapter) end

return viewport_adapter
