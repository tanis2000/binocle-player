---@meta

---@class fs
fs = {}

---@class Fs
local Fs = {}

---@param filename string the filename including the path of the text to load
---@return string the content of the file as a string
function fs.load_text_file(filename) end

---@param filename string the filename including the path of the file
---@return number the unix timestamp of the file. zero if the file does not exist
function fs.get_last_modification_time(filename) end

return fs