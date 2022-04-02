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

    if self:dist_case(G.game.h) <= 1 and G.game.h:is_alive() and G.game.h.cats < G.game.h.max_cats then
        G.game.h:add_cat()
        self.cd:set("pickup", 2, function()
            print("killed")
            self:kill()
            lume.remove(G.cats, self)
        end)
        self:play_animation("idle")
    end

    if self.dx ~= 0 then
        self:play_animation("idle")
    else
        self:play_animation("idle")
    end
end

return Cat