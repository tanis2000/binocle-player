local Entity = require("entity")
local layers = require("layers")
local lume = require("lib.lume")

local Mob = Entity:extend()

function Mob:new()
    Mob.super.new(self)
    self.name = "mob " .. #G.mobs+1
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
    self.max_health = 3
    self.health = self.max_health
    self.target = nil
end

function Mob:update(dt)
    Mob.super.update(self, dt)

    if self.target then
        local spd = 1
        local dir = self:dir_to(self.target)
        self.dx = self.dx + dir * spd * dt
    end

    if self:dist_case(G.game.h) <= 1
            and G.game.h:is_alive() then
        G.game.h:hurt(1)
    end


    if self.dx ~= 0 then
        self:play_animation("run")
    else
        self:play_animation("idle")
    end
end

function Mob:hurt(amount, impact_dir)
    self.health = self.health - amount

    if not self.cd:has("first_impact") then
        self:bump(impact_dir * lume.random(0.040, 0.060), 0.05)
    else
        self:bump(impact_dir * lume.random(0.005, 0.010), 0)
    end
    if self.health < 0 then
        self:kill()
        lume.remove(G.mobs, self)
    end
end

function Mob:set_target(en)
    self.target = en
end

return Mob