---@class input
local m = {}

---@class Input
local Input = {}

---@return Input the input system
function m.new() end

---@param input Input the input system
---@param key number the key to check
---@return boolean true if the key is pressed at the current frame
function m.is_key_pressed(input, key) end

---@param input Input the input system
---@param key number the key to check
---@return boolean true if the key is being held down at the current frame and wasn't at the previous one.
function m.is_key_down(input, key) end

---@param input Input the input system
---@param key number the key to check
---@return boolean true if the key has been released at the current frame while it was held down at the previous one.
function m.is_key_up(input, key) end

---@param input Input the input system
---@param b boolean if true, the input system will request to quit the application
function m.set_quit_requested(input, b) end

return m