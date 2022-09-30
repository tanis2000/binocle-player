---@class fs
local m = {}

---@class Fs
local Fs = {}

---@param filename string the filename including the path of the text to load
---@return string the content of the file as a string
function m.load_text_file(filename) end

---@param filename string the filename including the path of the file
---@return number the unix timestamp of the file. zero if the file does not exist
function m.get_last_modification_time(filename) end

return m