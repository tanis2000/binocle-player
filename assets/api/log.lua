---@class log
local m = {}

---@class Log
local Log = {}

---@param message string the message to log at DEBUG level
function m.debug(message) end

---@param message string the message to log at INFO level
function m.info(message) end

---@param message string the message to log at WARNING level
function m.warning(message) end

---@param message string the message to log at ERROR level
function m.error(message) end

return m