local Process = require("process")
local Game = require("scenes.game")
local GameOver = require("scenes.gameover")
local MainMenu = Process:extend()

function MainMenu:new()
    MainMenu.super.new(self)
    self.default_font = nil
end


function MainMenu:init(shd)
    self.name = "mainmenu"
    self.shader = shd

    gd.set_offscreen_clear_color(gd_instance, 1, 1, 1, 1)

    local assets_dir = sdl.assets_dir()
    self.default_font = ttfont.from_file(assets_dir .. "data/font/default.ttf", 8, shader.defaultShader());
end

function MainMenu:update(dt)
    if input.is_key_pressed(input_mgr, key.KEY_RETURN) or input.is_mouse_down(input_mgr, mouse.MOUSE_LEFT) then
        local game = Game(self.shader)
        game.game_over_type = GameOver
        scene = game
        G.game = game
        self:on_destroy()
        return
    end

    local s = "Press ENTER or LEFT MOUSE CLICK to START"
    local width = ttfont.get_string_width(self.default_font, s)
    ttfont.draw_string(self.default_font, s, gd_instance, (DESIGN_WIDTH - width)/2, 50, viewport, color.black, cam);

    s = "Unlucky Town - A game by Valerio Santinelli"
    width = ttfont.get_string_width(self.default_font, s)
    ttfont.draw_string(self.default_font, s, gd_instance, (DESIGN_WIDTH - width)/2, 170, viewport, color.black, cam);

end

function MainMenu:on_destroy()
    print("mainmenu:on_destroy()")
    if self.default_font ~= nil then
        ttfont.destroy(self.default_font)
        self.default_font = nil
    end
end

return MainMenu