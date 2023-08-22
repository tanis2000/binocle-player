---@meta

---@class ttfont
ttfont = {}

---@class TTFont
local TTFont = {}

---@param filename string the filename including the path of the TTF to load
---@param size number the font size
---@param shader Shader the shader instance to use to render the font
---@return TTFont the font instance
function ttfont.from_file(filename, size, shader) end

---@param filename string the filename including the path of the TTF to load
---@param size number the font size
---@param shader Shader the shader instance to use to render the font
---@return TTFont the font instance
function ttfont.from_assets(filename, size, shader) end

---@param font TTFont the font instance
---@param text string the text to draw
---@param gd GraphicsDevice the gd instance
---@param x number the horizontal position
---@param y number the vertical position
---@param viewport kmAABB2 the viewport
---@param color Color the color to use
---@param camera Camera the camera to apply
---@param depth number the depth of the sprite
function ttfont.draw_string(font, text, gd, x, y, viewport, color, camera, depth) end

---@param font TTFont the font instance
---@param text string the text to measure
---@return number the width of the whole text in pixels
function ttfont.get_string_width(font, text) end

---@param font TTFont the font instance
function ttfont.destroy(font) end

return ttfont