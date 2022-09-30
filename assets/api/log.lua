---@meta

---@class log
log = {}

---@class Log
local Log = {}

---@param message string the message to log at DEBUG level
function log.debug(message) end

---@param message string the message to log at INFO level
function log.info(message) end

---@param message string the message to log at WARNING level
function log.warning(message) end

---@param message string the message to log at ERROR level
function log.error(message) end

return log