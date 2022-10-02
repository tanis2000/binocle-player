local Process = require("process")
local Game = require("scenes.game")
local GameOver = Process:extend()

function GameOver:new()
    GameOver.super.new(self)
    self.TEX_WIDTH = 1682
    self.TEX_HEIGHT = 479
    self.default_font = nil
end


function GameOver:init(shd)
    self.name = "gameover"
    self.shader = shd

    gd.set_offscreen_clear_color(gd_instance, 1, 1, 1, 1)

    local assets_dir = sdl.assets_dir()
    self.default_font = ttfont.from_file(assets_dir .. "data/font/default.ttf", 8, shader.defaultShader());
end

function GameOver:update(dt)
    GameOver.super.update(self, dt)

    local s = "Press ENTER or LEFT MOUSE CLICK to RESTART"
    local width = ttfont.get_string_width(self.default_font, s)
    ttfont.draw_string(self.default_font, s, gd_instance, (DESIGN_WIDTH - width)/2, 50, viewport, color.black, cam);

    local h, m, se = self:seconds_to_clock(G.player.high_score)
    s = string.format("HIGH SCORE: %d:%d:%d", h, m, se)
    width = ttfont.get_string_width(self.default_font, s)
    ttfont.draw_string(self.default_font, s, gd_instance, (DESIGN_WIDTH - width)/2, 80, viewport, color.black, cam);

    h, m, se = self:seconds_to_clock(G.player.elapsed_time)
    s = string.format("YOUR SCORE: %d:%d:%d", h, m, se)
    width = ttfont.get_string_width(self.default_font, s)
    ttfont.draw_string(self.default_font, s, gd_instance, (DESIGN_WIDTH - width)/2, 100, viewport, color.black, cam);

    h, m, se = self:seconds_to_clock(G.player.elapsed_time)
    s = "YOUR TOWN AS BEEN DESTROYED BY"
    width = ttfont.get_string_width(self.default_font, s)
    ttfont.draw_string(self.default_font, s, gd_instance, (DESIGN_WIDTH - width)/2, 160, viewport, color.red, cam);

    h, m, se = self:seconds_to_clock(G.player.elapsed_time)
    s = G.player.last_disaster_text
    width = ttfont.get_string_width(self.default_font, s)
    ttfont.draw_string(self.default_font, s, gd_instance, (DESIGN_WIDTH - width)/2, 140, viewport, color.red, cam);

    if input.is_key_pressed(input_mgr, key.KEY_RETURN) or input.is_mouse_down(input_mgr, mouse.MOUSE_LEFT) then
        local game = Game(self.shader)
        game.game_over_type = GameOver
        scene = game
        G.game = game
        self:on_destroy()
        return
    end

end

function GameOver:on_destroy()
    print("gameover:on_destroy()")
    ttfont.destroy(self.default_font)
end

function GameOver:seconds_to_clock(seconds)
    local hours = math.floor(seconds/3600)
    local minutes = math.floor(seconds/60 - hours * 60)
    local secs = math.floor(seconds - hours * 3600 - minutes * 60)
    return hours, minutes, secs
end

return GameOver