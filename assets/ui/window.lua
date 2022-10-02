local Process = require("process")
local Game = require("scenes.game")
local Window = Process:extend()

function Window:new()
    Window.super.new(self)
    self.default_font = nil
end


function Window:init()
    self.name = "window"
    local assets_dir = sdl.assets_dir()

    self.default_font = ttfont.from_file(assets_dir .. "data/font/default.ttf", 8, shader.defaultShader());
end

function Window:update(dt)
end

function Window:on_destroy()
    Window.super.on_destroy(self)
    ttfont.destroy(self.default_font)
end

return Window