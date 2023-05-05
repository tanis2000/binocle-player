---@meta

---@class app
app = {}

---@class App
local App = {}

---@return string the path to the assets folder with a trailing slash. i.e. /assets/
function app.assets_dir() end

---@return string the string representing the underlying technology. Useful to build the path to shaders (gl33, gles, metal)
function app.shader_prefix() end

return app