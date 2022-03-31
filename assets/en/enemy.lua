local Entity = require("entity")
local layers = require("layers")

local Enemy = Entity:extend()

function Enemy:new()
    Enemy.super.new(self)
    self.name = "enemy " .. #G.mobs+1
    G.mobs[#G.mobs+1] = self
    self.hei = 32
    self.wid = 32
    self.depth = layers.MOBS
    self:load_image("img/enemy.png", 32, 32)
    self:add_animation("idle", {
        1,
        2
    }, 8)
    self:add_animation("run", {
        3,
        4
    }, 14)
end

function Enemy:update(dt)
    Enemy.super.update(self, dt)

    if self.dx ~= 0 then
        self:play_animation("run")
    else
        self:play_animation("idle")
    end
end

return Enemy