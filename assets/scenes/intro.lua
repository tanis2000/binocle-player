local Process = require("process")
local Game = require("scenes.game")
local const = require("const")
local Intro = Process:extend()

function Intro:new()
    Intro.super.new(self)
    self.TEX_WIDTH = 1682
    self.TEX_HEIGHT = 479
    self.default_font = nil
end


function Intro:init(shd)
    self.name = "intro"
    local assets_dir = sdl.assets_dir()
    local image_filename = assets_dir .. "data/img/binocle-logo-full.png"
    self.img = image.load(image_filename)
    self.tex = texture.from_image(self.img)
    self.mat = material.new()

    io.write("intro.mat: " .. tostring(self.mat) .."\n")
    io.write("material: " .. tostring(material) .."\n")
    io.write("shd: " .. tostring(shd) .."\n")
    material.set_texture(self.mat, self.tex)
    material.set_shader(self.mat, shd)
    self.logo = sprite.from_material(self.mat)
    self.shader = shd

    self.azure_color = color.new(191.0 / 255.0, 1.0, 1.0, 1.0)
    self.white_color = color.new(1.0, 1.0, 1.0, 1.0)
    self.black_color = color.new(0, 0, 0, 1.0)

    gd.set_offscreen_clear_color(gd_instance, 1, 1, 1, 1)

    self.default_font = ttfont.from_file(assets_dir .. "data/font/default.ttf", 8, shader.defaultShader());
end

function Intro:update(dt)
    -- By default we scale our logo by 1/3
    --local scale = lkazmath.kmVec2New();
    --scale.x = const.DESIGN_WIDTH / self.TEX_WIDTH
    --scale.y = const.DESIGN_HEIGHT / self.TEX_WIDTH

    local scale_x = const.DESIGN_WIDTH / self.TEX_WIDTH
    local scale_y = const.DESIGN_HEIGHT / self.TEX_WIDTH

    -- Center the logo in the render target
    local x = (const.DESIGN_WIDTH - (self.TEX_WIDTH * scale_x)) / 2.0
    local y = (const.DESIGN_HEIGHT - (self.TEX_HEIGHT * scale_y)) / 2.0

    --io.write("x: " .. tostring(x) .. " y: " .. tostring(y) .. "\n")
    sprite.draw(self.logo, gd_instance, x, y, viewport, 0, scale_x, scale_y, cam)

    --io.write("input: " .. tostring(dump(input)) .. "\n")
    --io.write("input_mgr: " .. tostring(dump(input_mgr)) .. "\n")
    if input.is_key_pressed(input_mgr, key.KEY_RETURN) or input.is_mouse_down(input_mgr, mouse.MOUSE_LEFT) then
        local game = Game(self.shader)
        scene = game
        self:on_destroy()
        return
    end

    local s = "Press ENTER or LEFT MOUSE CLICK to START"
    local width = ttfont.get_string_width(self.default_font, s)
    ttfont.draw_string(self.default_font, s, gd_instance, (const.DESIGN_WIDTH - width)/2, 50, viewport, color.black, cam);

    s = "A sample game by Valerio Santinelli"
    width = ttfont.get_string_width(self.default_font, s)
    ttfont.draw_string(self.default_font, s, gd_instance, (const.DESIGN_WIDTH - width)/2, 170, viewport, color.black, cam);
end

function Intro:on_destroy()
    print("intro:on_destroy()")
    if self.default_font ~= nil then
        ttfont.destroy(self.default_font)
        self.default_font = nil
    end
end

return Intro