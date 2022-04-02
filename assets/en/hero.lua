local Entity = require("entity")
local Bullet = require("en.bullet")
local Fx = require("en.fx")
local layers = require("layers")
local lume = require("lib.lume")
local Hero = Entity:extend()

function Hero:new()
    Hero.super.new(self)
    self.hei = 32
    self.wid = 32
    self.depth = layers.HERO
    self.max_cats = 1
    self.cats = 0
    self.max_health = 100
    self.health = 100
    self:load_image("data/img/hero.png", 32, 32)
    self:add_animation("idle1", {
        1,
    }, 8)
    self:add_animation("idle2", {
        2,
        3,
    }, 8)
    self:add_animation("run", {
        4,
        5,
        6,
        7,
        8,
        9,
    }, 14)
    self:add_animation("jumpup", {
        10,
    }, 14)
    self:add_animation("jumpdown", {
        11,
    }, 14)
end

function Hero:update(dt)
    Hero.super.update(self, dt)

    local spd = 2
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

    self:collect_cats()

    if self.dy > 0 and not self:on_ground() then
        self:play_animation("jumpup")
    elseif not self:on_ground() then
        self:play_animation("jumpdown")
    elseif self:on_ground() and self.dx ~= 0 then
        self:play_animation("run")
    else
        local rnd = lume.random(0, 1)
        if rnd < 0.4 then
            self:play_animation("idle2")
        else
            self:play_animation("idle1")
        end
    end
end

function Hero:post_update(dt)
    Hero.super.post_update(self, dt)
end
function Hero.shoot(self)
    local b = Bullet(self)
    self.cd:set("shoot", 0.15)
end

function Hero.add_cat(self)
    if self.cats < self.max_cats then
        self.cats = self.cats + 1
    end
end

function Hero.collect_cats(self)
    for _, c in pairs(G.game.level.collectors) do
        if self:dist_case_free(c.cx, c.cy) <= 1 then
            self:heal(self.cats * 7)
            self.cats = 0
        end
    end
end

function Hero.heal(self, amount)
    self.health = self.health + amount
    if self.health > self.max_health then
        self.health = self.max_health
    end
end
return Hero