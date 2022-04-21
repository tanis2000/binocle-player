---@class window
local m = {}

---@class Window
local Window = {}

---@return window Window
function m.new() end

---@param win Window
---@param color Color
---@return void
function m.set_background_color(win, color) end

---@param win Window
---@param width number Width
---@param height number Height
function m.set_minimum_size(win, width, height) end

return m