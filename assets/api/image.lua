---@meta

---@class image
image = {}

---@class Image
local Image = {}

---Load an image using the SDL system
---@param filename string the filename including the path of the image to load
---@return Image the image resource id (sg_image)
function image.load(filename) end

---Load an image using the fs system (constrained to the assets folder)
---@param filename string the filename including the path of the image to load
---@return Image the image resource id (sg_image)
function image.load_from_assets(filename) end

---@param image Image the image id returned by load
---@return number, number width and height
function image.get_info(image) end

return image