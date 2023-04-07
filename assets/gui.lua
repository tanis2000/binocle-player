local Process = require("process")
local layers = require("layers")

---@class Gui
---@type Gui
local Gui = Process:extend()

function Gui:new()
    Gui.super.new(self)
    self.x = 0
    self.y = 0
    self.max_cats = 1
    self.carried_cats = 0
    self.max_health = 10
    self.health = 10
    self.hour = 0
    self.minute = 0
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
    ttfont.draw_string(G.game.default_font, s, gd_instance, self.x + 10, self.y - 10, viewport, color.white, cam, layers.TEXT);
end

function Gui:update_position(x, y)
    self.x = x
    self.y = y
end

function Gui:seconds_to_clock(seconds)
    local hours = math.floor(seconds/3600)
    local minutes = math.floor(seconds/60 - hours * 60)
    local secs = math.floor(seconds - hours * 3600 - minutes * 60)
    return hours, minutes, secs
end

return Gui