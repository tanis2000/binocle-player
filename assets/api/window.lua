---@class window
local m = {}

---@class Window
local Window = {}

---@param width number Width of the window to create
---@param height number Height of the window to create
---@param title string Title of the window
---@return window Window
function m.new(width, height, title) end

---@param window Window an instance of Window
---@param color Color the color of the background (clear color)
function m.set_background_color(window, color) end

---@param window Window an instance of Window
---@param width number the minimum width of the window
---@param height number the minimum height of the window
function m.set_minimum_size(window, width, height) end

return m