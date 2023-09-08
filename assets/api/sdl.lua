---@meta

---@class sdl
sdl = {}

---@return string the path to the assets folder
function sdl.assets_dir() end

---@param org string the organization name
---@param app string the application name
---@return string the path to the preferences folder where file can be written
function sdl.preferences_dir(org, app) end

---@param filename string the filename to load
---@return string the content of the file
function sdl.load_text_file(filename) end

---@param filename string the filename to write to
---@param content string the content to write
---@param size number the size of the content
function sdl.save_text_file(filename, content, size) end

return sdl