---@meta

---@class window
window = {}

---@class Window
local Window = {}

---@param width number Width of the window to create
---@param height number Height of the window to create
---@param title string Title of the window
---@return Window the window instance
function window.new(width, height, title) end

---@param w Window an instance of Window
---@param color Color the color of the background (clear color)
function window.set_background_color(w, color) end

---@param w Window an instance of Window
---@param width number the minimum width of the window
---@param height number the minimum height of the window
function window.set_minimum_size(w, width, height) end

return window