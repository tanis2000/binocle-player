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

---@param camera Camera an instance of Camera
---@return number, number the horizontal position and the vertical position
function m.get_position(camera) end

return m