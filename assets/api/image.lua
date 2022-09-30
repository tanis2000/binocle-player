---@class image
local m = {}

---@class Image
local Image = {}

---@param filename string the filename including the path of the image to load
---@return Image the image resource id (sg_image)
function m.load(filename) end

---@param image Image the image id returned by load
---@return number, number width and height
function m.get_info(image) end

return m