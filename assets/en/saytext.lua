local Entity = require("entity")
local layers = require("layers")
local SayText = Entity:extend()

function SayText:new(owner, s)
    SayText.super.new(self)
    self.depth = layers.TEXT
    self.owner = owner
    log.info(tostring(owner))
    self.s = s
    self.cd:set("keep_saying", 2.5 + 0.10 * string.len(s))
end

function SayText:update(dt)
    SayText.super.update(self, dt)

    if not self.cd:has("keep_saying") then
        log.info("removing saying")
        self:kill()
    end
end

function SayText:draw()
    SayText.super.draw(self)

    local width = ttfont.get_string_width(G.game.default_font, self.s)
    local x = self.owner:get_center_x() - width / 2
    local y = self.owner:get_top() + 8 * 2
    self:set_pos_pixel(x, y)
    ttfont.draw_string(G.game.default_font, self.s, gd_instance, x, y, viewport, color.white, cam, layers.TEXT);
end

return SayText