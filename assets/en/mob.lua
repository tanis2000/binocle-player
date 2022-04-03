local Entity = require("entity")
local layers = require("layers")
local lume = require("lib.lume")
local Level = require("level")

local Mob = Entity:extend()

function Mob:new()
    Mob.super.new(self)
    self.name = "mob " .. #G.mobs+1
    G.mobs[#G.mobs+1] = self
    self.hei = 20
    self.wid = 32
    self.depth = layers.MOBS
    self:load_image("data/img/mob.png", 32, 32)
    self:add_animation("idle", {
        1,
    }, 8)
    self:add_animation("run", {
        2,
        3,
        4
    }, 14)
    self.max_health = 3
    self.health = self.max_health
    self.target = nil
end

function Mob:update(dt)
    Mob.super.update(self, dt)

    -- Aggro the hero
    if G.game.h:is_alive()
            and self:dist_case(G.game.h) <= 10
            and self:on_ground()
            and math.abs(self.cy - G.game.h.cy) <= 2
            and self:sight_check(G.game.h) then
        self.target = G.game.h
        self.dir = self:dir_to(self.target)
        self:bump(0, 0.1)
        print("target qcquired")
    end

    local spd = 1

    if self.target then
        if self:sight_check(self.target) and math.abs(self.cy - self.target.cy) <= 1 then
            -- Track the target
            self.dir = self:dir_to(self.target)
            self.dx = self.dx + self.dir * spd * 1.2 * dt
        else
            -- Wander aggressively
            if not self.cd:has("aggro_search") then
                self.cd:set("aggro_search", lume.random(0.5, 0.9))
                self.dir = self.dir * -1
                self.cd:set("aggro_wander", lume.random(0.1, 0.4))
            end
            if self.cd:has("aggro_wander") then
                self.dx = self.dx + spd * 2 * self.dir * dt
            end
        end
    else
        self.dx = self.dx + spd * self.dir * dt
        if G.game.level:has_mark(self.cx, self.cy, Level.PlatformEndLeft) and self.dir == -1 and self.xr <0.5
        or G.game.level:has_mark(self.cx, self.cy, Level.PlatformEndRight) and self.dir == 1 and self.xr >0.5 then
            self.dir = self.dir * -1
        end
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