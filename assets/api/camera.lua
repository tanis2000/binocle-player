---@meta

---@class camera
camera = {}

---@class Camera
local Camera = {}

---@param adapter ViewportAdapter
---@return Camera camera the Camera instance
function camera.new(adapter) end

---@param camera Camera an instance of Camera
---@return number the horizontal position
function camera.x(camera) end

---@param camera Camera an instance of Camera
---@return number the vertical position
function camera.y(camera) end

---@param camera Camera
---@param x number horizontal position
---@param y number vertical position
function camera.set_position(camera, x, y) end

---@param camera Camera an instance of Camera
---@return number, number the horizontal position and the vertical position
function camera.get_position(camera) end

return camera