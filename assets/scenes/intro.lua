local Process = require("process")
local MainMenu = require("scenes.main-menu")
local const = require("const")
local bit = require("lib.bitop")
local Intro = Process:extend()

function Intro:new()
    Intro.super.new(self)
    self.TEX_WIDTH = 1682
    self.TEX_HEIGHT = 479
    self.TANIS_TEX_WIDTH = 512
    self.TANIS_TEX_HEIGHT = 250
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

    self.default_font = ttfont.from_file(assets_dir .. "data/font/default.ttf", 8, G.default_shader);

    local tanis_filename = assets_dir .. "data/img/tanis.png"
    self.tanis_img = image.load(tanis_filename)
    self.tanis_tex = texture.from_image(self.tanis_img)
    self.tanis_mat = material.new()
    material.set_texture(self.tanis_mat, self.tanis_tex)
    material.set_shader(self.tanis_mat, shd)
    material.set_pipeline(self.tanis_mat, G.colorize_shader) -- NOTE: this overrides the shader, too
    material.set_uniform_float4(self.tanis_mat, "FS", "customColor", 1.0, 0, 0, 1.0)
    self.tanis = sprite.from_material(self.tanis_mat)
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
    sprite.draw(self.logo, gd_instance, x, y, viewport, 0, scale_x, scale_y, cam, 0)

    scale_x = const.DESIGN_WIDTH / self.TANIS_TEX_WIDTH * 0.25
    scale_y = const.DESIGN_HEIGHT / self.TANIS_TEX_WIDTH * 0.25

    -- Center the tanis logo in the render target
    x = (const.DESIGN_WIDTH - (self.TANIS_TEX_WIDTH * scale_x)) / 2.0
    y = (const.DESIGN_HEIGHT - (self.TANIS_TEX_HEIGHT * scale_y)) / 2.0


    sprite.draw(self.tanis, gd_instance, x, y - 40, viewport, 0, scale_x, scale_y, cam, 0)

    if input.is_key_pressed(input_mgr, key.KEY_RETURN) or input.is_mouse_down(input_mgr, mouse.MOUSE_LEFT) then
        local mainMenu = MainMenu()
        mainMenu:init(G.default_shader)
        scene = mainMenu
        self:on_destroy()
        return
    end

    local s = "Press ENTER or LEFT MOUSE CLICK to START"
    local width = ttfont.get_string_width(self.default_font, s)
    ttfont.draw_string(self.default_font, s, gd_instance, (const.DESIGN_WIDTH - width)/2, 50, viewport, color.black, cam, 0);

    s = "A sample game by Valerio Santinelli"
    width = ttfont.get_string_width(self.default_font, s)
    ttfont.draw_string(self.default_font, s, gd_instance, (const.DESIGN_WIDTH - width)/2, 170, viewport, color.black, cam, 0);
end

function Intro:on_destroy()
    print("intro:on_destroy()")
    if self.default_font ~= nil then
        ttfont.destroy(self.default_font)
        self.default_font = nil
    end
end

return Intro