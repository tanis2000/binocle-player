local Entity = require("entity")
local layers = require("layers")
local Collector = Entity:extend()

function Collector:new(cx, cy)
    Collector.super.new(self)
    self.cx = cx
    self.cy = cy
    self.depth = layers.BG
    self.wid = 64
    self.hei = 40
    self:load_image("data/img/collector.png", 64, 64)
    self:add_animation("close", {
        1,
    }, 8)
    self:add_animation("open", {
        2,
        3,
        4,
        5,
    }, 8)
end

function Collector:update(dt)
    Collector.super.update(self, dt)
    if G.game.day_cycle.cycle == 1 then
        self:play_animation("open")
    else
        self:play_animation("close")
    end
end

return Collector