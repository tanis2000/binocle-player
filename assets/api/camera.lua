---@class camera
local m = {}

---@class Camera
local Camera = {}

---@param adapter ViewportAdapter
---@return camera Camera
function m.new(adapter) end

---@param camera Camera an instance of Camera
---@return number the horizontal position
function m.x(camera) end

---@param camera Camera an instance of Camera
---@return number the vertical position
function m.y(camera) end

---@param camera Camera
---@param x number horizontal position
---@param y number vertical position
function m.set_position(camera, x, y) end

return m