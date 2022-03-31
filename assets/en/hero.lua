local Entity = require("entity")
local Bullet = require("en.bullet")
local Fx = require("en.fx")
local Hero = Entity:extend()

function Hero:new()
    Hero.super.new(self)
    self.hei = 32
    self.wid = 32
    self:load_image("img/player.png", 32, 32)
    self:add_animation("idle", {
        1,
        2
    }, 8)
    self:add_animation("run", {
        3,
        4
    }, 14)
end

function Hero:update(dt)
    Hero.super.update(self, dt)

    local spd = 5
    if input.is_key_pressed(input_mgr, key.KEY_LEFT) or input.is_key_pressed(input_mgr, key.KEY_A) then
        self.dx = self.dx - spd * dt * self.time_mul
        self.dir = -1
    elseif input.is_key_pressed(input_mgr, key.KEY_RIGHT) or input.is_key_pressed(input_mgr, key.KEY_D) then
        self.dx = self.dx + spd * dt * self.time_mul
        self.dir = 1
    end

    if input.is_key_pressed(input_mgr, key.KEY_SPACE) then
        if self:on_ground() then
            self.dy = 0.9
            audio.play_sound(G.sounds["jump"])
            local fx = Fx("img/jump.png", 6, 0.3)
            fx:set_pos_pixel(self:get_center_x(), self:get_bottom())
        end
    end

    if input.is_key_pressed(input_mgr, key.KEY_E) then
        if not self.cd:has("shoot") then
            self:shoot()
        end
    end

    local camera_x = camera.x(cam)
    local camera_y = camera.y(cam)
    if input.is_key_pressed(input_mgr, key.KEY_UP) then
        camera_y = camera_y + spd * dt * self.time_mul
    elseif input.is_key_pressed(input_mgr, key.KEY_DOWN) then
        camera_y = camera_y - spd * dt * self.time_mul
    end
    camera.set_position(cam, camera_x, camera_y)

    if self.dx ~= 0 then
        self:play_animation("run")
    else
        self:play_animation("idle")
    end
end

function Hero:post_update(dt)
    Hero.super.post_update(self, dt)
end
function Hero.shoot(self)
    local b = Bullet(self)
    self.cd:set("shoot", 0.1)
end

return Hero