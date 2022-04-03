local Entity = require("entity")
local layers = require("layers")
local lume = require("lib.lume")

local Cat = Entity:extend()

function Cat:new()
    Cat.super.new(self)
    self.name = "cat " .. #G.mobs+1
    G.cats[#G.cats+1] = self
    self.hei = 32
    self.wid = 32
    self.depth = layers.MOBS
    self.owner = nil
    self.caged = false
    self:load_image("data/img/cat.png", 32, 32)
    self:add_animation("idle", {
        1,
    }, 8)
    self:add_animation("carry", {
        2,
    }, 8)
end

function Cat:update(dt)
    Cat.super.update(self, dt)

    if self:dist_case(G.game.h) <= 1
            and G.game.h:is_alive()
            and G.game.h.cats < G.game.h.max_cats
            and not self.caged then
        G.game.h:add_cat()
        self.owner = G.game.h
        --self.cd:set("pickup", 2, function()
        --    print("killed")
        --    self:kill()
        --    lume.remove(G.cats, self)
        --end)
        --self:play_animation("idle")
    end

    for _, c in pairs(G.game.level.collectors) do
        if self:dist_case_free(c.cx, c.cy) <= 1
                and not self.caged
                and G.game.day_cycle.cycle == 1
                and not G.game.wave_system.running
                and self.owner then
            self.owner:collect_cat()
            self.owner = nil
            self.caged = true
            self:set_pos_grid(c.cx, c.cy)
            self.xr = lume.random(0.2, 0.8)
        end
    end

    for _, en in pairs(G.mobs) do
        if en:is_alive()
                and self:get_center_x() >= en:get_center_x()-en.radius
                and self:get_center_x() <= en:get_center_x()+en.radius
                and self:get_bottom() >= en:get_bottom()
                and self:get_bottom() <= en:get_bottom() + en.hei
                and self.cd:has("projectile") then
            -- hit the mob
            print("hit")
            en:hurt(1, self.dir)
        end
    end

    if self.owner then
        self:set_pos_pixel(self.owner:get_center_x(), self.owner:get_top() - 2)
    end

    if self.owner and not self.owner:is_alive() then
        self:drop_from_owner()
    end

    if self:dist_case(G.game.h) <= 3 and not self.cd:has("purr") then
        audio.play_sound(G.sounds["purr"])
        self.cd:set("purr", 5)
    end

    if self.dx ~= 0 then
        self:play_animation("idle")
    else
        self:play_animation("idle")
    end
end

function Cat:launch(dir)
    self:set_pos_pixel(self.owner:get_center_x(), self.owner:get_center_y())
    self.dx = dir * 1.5
    self.owner:remove_cat()
    self.cd:set("projectile", 0.5)
    self.owner = nil
end

function Cat:drop_from_owner()
    self:set_pos_pixel(self.owner:get_center_x(), self.owner:get_center_y())
    self.owner:remove_cat()
    self.owner = nil
end

return Cat