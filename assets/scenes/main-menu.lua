local Process = require("process")
local Game = require("scenes.game")
local const = require("const")
local bit = require("lib.bitop")
local MainMenu = Process:extend()

function MainMenu:new()
    MainMenu.super.new(self)
    self.TEX_WIDTH = 1682
    self.TEX_HEIGHT = 479
    self.TANIS_TEX_WIDTH = 512
    self.TANIS_TEX_HEIGHT = 250
    self.default_font = nil
end


function MainMenu:init(shd)
    self.name = "main-menu"
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

    local body = http.put("https://podium.altralogica.it/l/binocle-example/members/tanis/score", "{\"score\":2}")
    local res = http.decode(body)
    log.info(res)

    body = http.get("https://podium.altralogica.it/l/binocle-example/top/0")
    res = http.decode(body)
    log.info(res)

    imgui.SetContext("game")
    print(dump(imgui))
    local colBg = imgui.ColorConvertFloat4ToU32(1, 1, 1, 1)
    local colText = imgui.ColorConvertFloat4ToU32(0, 0, 0, 1)
    local colTextDisabled = imgui.ColorConvertFloat4ToU32(0.3, 0.3, 0.3, 1)
    local colFg = imgui.ColorConvertFloat4ToU32(198 / 255, 159 / 255, 165 / 255, 1)
    local colFgActive = imgui.ColorConvertFloat4ToU32(198 / 255 * 0.8, 159 / 255 * 0.8, 165 / 255 * 0.8, 1)
    imgui.PushStyleColor(imgui.constant.Col.Text, colText)
    imgui.PushStyleColor(imgui.constant.Col.TextDisabled, colTextDisabled)
    imgui.PushStyleColor(imgui.constant.Col.WindowBg, colBg)
    imgui.PushStyleColor(imgui.constant.Col.TitleBg, colBg)
    imgui.PushStyleColor(imgui.constant.Col.TitleBgActive, colBg)
    imgui.PushStyleColor(imgui.constant.Col.Button, colFg)
    imgui.PushStyleColor(imgui.constant.Col.ButtonHovered, colBg)
    imgui.PushStyleColor(imgui.constant.Col.ButtonActive, colFgActive)

    G.using_game_gui = true
end

function MainMenu:update(dt)
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
    --sprite.draw(self.logo, gd_instance, x, y, viewport, 0, scale_x, scale_y, cam, 0)

    scale_x = const.DESIGN_WIDTH / self.TANIS_TEX_WIDTH * 0.25
    scale_y = const.DESIGN_HEIGHT / self.TANIS_TEX_WIDTH * 0.25

    -- Center the tanis logo in the render target
    x = (const.DESIGN_WIDTH - (self.TANIS_TEX_WIDTH * scale_x)) / 2.0
    y = (const.DESIGN_HEIGHT - (self.TANIS_TEX_HEIGHT * scale_y)) / 2.0


    sprite.draw(self.tanis, gd_instance, x, y - 40, viewport, 0, scale_x, scale_y, cam, 0)

    imgui.SetContext("game")
    imgui.NewFrame(win, dt, const.DESIGN_WIDTH, const.DESIGN_HEIGHT)
    --print(dump(imgui.constant.WindowFlags))
    imgui.SetNextWindowPos(0, 0)
    imgui.SetNextWindowSize(const.DESIGN_WIDTH, const.DESIGN_HEIGHT)
    if imgui.Begin("Intro GUI", nil, bit.bor(imgui.constant.WindowFlags.NoTitleBar, imgui.constant.WindowFlags.NoResize)) then
        imgui.TextUnformatted("Memory:   " .. string.format("%.2fmb", collectgarbage("count")/1024))
        imgui.TextUnformatted("Mobs:     " .. #G.mobs)
        imgui.TextUnformatted("Bullets:  " .. #G.mobs)
        imgui.TextUnformatted("Entities: " .. #G.entities)
        imgui.Button("Test")
        if self:button_centered_on_line("Start") then
            print("start pressed")
            local game = Game(self.shader)
            scene = game
            self:on_destroy()
            return
        end
    end
    imgui.End()
    imgui.Render("game")


    if not imgui.GetWantCaptureMouse() then
        --if input.is_key_pressed(input_mgr, key.KEY_RETURN) or input.is_mouse_down(input_mgr, mouse.MOUSE_LEFT) then
        --    local game = Game(self.shader)
        --    scene = game
        --    self:on_destroy()
        --    return
        --end
    end

    --local s = "Press ENTER or LEFT MOUSE CLICK to START"
    --local width = ttfont.get_string_width(self.default_font, s)
    --ttfont.draw_string(self.default_font, s, gd_instance, (const.DESIGN_WIDTH - width)/2, 50, viewport, color.black, cam, 0);
    --
    --s = "A sample game by Valerio Santinelli"
    --width = ttfont.get_string_width(self.default_font, s)
    --ttfont.draw_string(self.default_font, s, gd_instance, (const.DESIGN_WIDTH - width)/2, 170, viewport, color.black, cam, 0);
end

function MainMenu:on_destroy()
    print("intro:on_destroy()")
    if self.default_font ~= nil then
        ttfont.destroy(self.default_font)
        self.default_font = nil
    end
    G.using_game_gui = false
end

function MainMenu:button_centered_on_line(label, alignment)
    if alignment == nil then
        alignment = 0.5
    end
    local padX, padY = imgui.GetStyleFramePadding()
    local size = imgui.CalcTextSize(label).x + padX * 2
    local avail = imgui.GetContentRegionAvail().x
    local off = (avail - size) * alignment
    if (off > 0) then
        imgui.SetCursorPosX(imgui.GetCursorPosX() + off)
    end

    return imgui.Button(label)
end

return MainMenu