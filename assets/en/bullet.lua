local Entity = require("entity")
local Bullet = Entity:extend()

function Bullet:new()
    Bullet.super.new(self)
    G.bullets[#G.bullets+1] = self
    self.hei = 4
    self.wid = 8
    self:load_image("img/bullet.png", 8, 4)

    self.speed = 1.0
    self.ang = 0
end

function Bullet:update(dt)
    self.dx = math.cos(self.ang)*0.55*self.speed
    self.dy = math.sin(self.ang)*0.55*self.speed
    self.dir = 1

    Bullet.super.update(self, dt)

    for idx, en in pairs(G.mobs) do
        if en:is_alive() and self:get_center_x() >= en:get_center_x()-en.radius
        and self:get_center_x() <= en:get_center_x()+en.radius
        and self:get_bottom() >= en:get_bottom() - en.hei and self:get_bottom() <= en:get_bottom() then
            -- hit the mob
            print("hit")
            -- remove this from the scene
        end
    end

    if not G.game.level:is_valid(self.cx, self.cy) or G.game.level:has_collision(self.cx, self.cy) then
        -- remove this from the scene
    end
end

return Bullet