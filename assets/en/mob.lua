local Entity = require("entity")
local cpoint = require("cpoint")

local Mob = Entity:extend()

function Mob:new()
    Mob.super.new(self)
    self.start_pt = cpoint:new(0, 0)
    self.wander_ang = 0
    G.mobs[#G.mobs+1] = self
    return self
end

function Mob:update(dt)
    Entity.update(self, dt)
    local tx = self.start_pt:get_center_x()
    local ty = self.start_pt:get_center_y()
    local a = math.atan2(ty - self:get_center_y(), tx - self:get_center_x())
    local s = 0.1
    self.dx = self.dx + math.cos(a)*s*dt
    self.dy = self.dy + math.sin(a)*s*dt
    s = 0.05
    self.wander_ang = self.wander_ang + (math.random(3, 6) * 0.1)
    self.dx = self.dx + math.cos(self.wander_ang)*s*dt
    self.dy = self.dy + math.sin(self.wander_ang)*s*dt
end

return Mob