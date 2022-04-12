local lume = require("lib.lume")
local M = require("m")
local Entity = require("entity")
local layers = require("layers")

local Bullet = Entity:extend()

function Bullet:new(owner)
    Bullet.super.new(self)
    self.owner = owner
    self.hei = 2
    self.wid = 4
    self.pivot_x = 0.5
    self.pivot_y = 0.5
    self.depth = layers.BULLETS
    self:load_image("data/img/bullet.png", 16, 16)
    self.has_collisions = false
    self:set_pos_pixel(owner:get_center_x(), owner:get_center_y())

    self.speed = 1.0
    self.ang = owner:dir_to_ang()
    self.name = "bullet " .. #G.bullets+1
    table.insert(G.bullets, self)
end

function Bullet:update(dt)
    self.dx = math.cos(self.ang)*0.55*self.speed
    self.dy = math.sin(self.ang)*0.55*self.speed

    Bullet.super.update(self, dt)

    local dist = M.rad_distance(self.ang, 0)
    if dist <= math.pi / 2.0 then
        self.dir = 1
    else
        self.dir = -1
    end

    for _, en in pairs(G.mobs) do
        if en:is_alive() and self:get_center_x() >= en:get_center_x()-en.radius
        and self:get_center_x() <= en:get_center_x()+en.radius
        and self:get_bottom() >= en:get_bottom() and self:get_bottom() <= en:get_bottom() + en.hei then
            -- hit the mob
            print("hit")
            -- remove this from the scene
            self:kill()
            lume.remove(G.bullets, self)
            en:hurt(1, self.dir)
        end
    end

    if not G.game.level:is_valid(self.cx, self.cy) or G.game.level:has_collision(self.cx, self.cy) then
        -- remove this from the scene
        print("wall")
        self:kill()
        lume.remove(G.bullets, self)
    end
end

return Bullet