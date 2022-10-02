local Entity = require("entity")
local layers = require("layers")
local const = require("const")
local FloatingText = Entity:extend()

function FloatingText:new(s)
    FloatingText.super.new(self)
    self.depth = layers.TEXT
    self.s = s
    self.cd:set("keep_saying", 1.5 + 0.10 * string.len(s))
end

function FloatingText:update(dt)
    FloatingText.super.update(self, dt)

    if not self.cd:has("keep_saying") then
        print("removing saying")
        self:kill()
    end
end

function FloatingText:draw()
    FloatingText.super.draw(self)

    local width = ttfont.get_string_width(G.game.default_font, self.s)
    local x = (const.DESIGN_WIDTH - width) / 2
    local y = const.DESIGN_HEIGHT / 2 + 10
    self:set_pos_pixel(x, y)
    ttfont.draw_string(G.game.default_font, self.s, gd_instance, x, y, viewport, color.white, cam);
end

return FloatingText