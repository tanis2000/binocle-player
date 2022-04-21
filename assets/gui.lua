local Process = require("process")
local const = require("const")

---@class Gui
---@type Gui
local Gui = Process:extend()

function Gui:new()
    Gui.super.new(self)
    self.x = 0
    self.y = const.DESIGN_HEIGHT
    self.max_cats = 1
    self.carried_cats = 0
    self.max_health = 10
    self.health = 10
    self.hour = 0
    self.minute = 0
    self.camera = camera.new(adapter)
end

function Gui:update(dt)
    Gui.super.update(self, dt)
end

function Gui:post_update(dt)
    Gui.super.post_update(self, dt)
    self:render()
end

function Gui:render()
    local s = string.format("Health: %d/%d   Cats: %d/%d   Time:%d:%d", self.health, self.max_health, self.carried_cats, self.max_cats, self.hour, self.minute)
    ttfont.draw_string(G.game.default_font, s, gd_instance, self.x + 10, self.y - 10, viewport, color.white, self.camera);
end

function Gui:update_position(x, y)
--    self.x = x
--    self.y = y
end

return Gui