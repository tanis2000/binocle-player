local Entity = require("entity")
local Bullet = require("en.bullet")
local Fx = require("en.fx")
local layers = require("layers")
local lume = require("lib.lume")
local SayText = require("en.saytext")
local Hero = Entity:extend()

function Hero:new()
    Hero.super.new(self)
    self.name = "hero"
    self.hei = 16
    self.wid = 12
    self.depth = layers.HERO
    self.max_cats = 1
    self.cats = 0
    self.max_health = 100
    self.health = 100
    self.cats_seen = 0
    self.cats_sentences = {
        "Hmmm... a cat... maybe I can pick it up",
        "More cats, I wonder what they are doing here...",
        "Maybe I can do something with them"
    }
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
    self:add_animation("shoot", {
        12,
        13,
    }, 8)
    self:add_animation("death", {
        14,
        15,
    }, 8, false)
end

function Hero:update(dt)
    Hero.super.update(self, dt)

    local spd = 2
    if self:is_alive() and (input.is_key_pressed(input_mgr, key.KEY_LEFT) or input.is_key_pressed(input_mgr, key.KEY_A)) then
        self.dx = self.dx - spd * dt * self.time_mul
        self.dir = -1
    elseif self:is_alive() and (input.is_key_pressed(input_mgr, key.KEY_RIGHT) or input.is_key_pressed(input_mgr, key.KEY_D)) then
        self.dx = self.dx + spd * dt * self.time_mul
        self.dir = 1
    end

    if self:is_alive() and input.is_key_pressed(input_mgr, key.KEY_W) then
        if self:on_ground() then
            self.dy = 0.9
            audio.play_sound(G.sounds["jump"])
            local fx = Fx("data/img/jump.png", 6, 0.3)
            fx:set_pos_pixel(self:get_center_x(), self:get_bottom())
        end
    end

    if self:is_alive() and input.is_key_pressed(input_mgr, key.KEY_E) then
        if not self.cd:has("shoot") then
            self:shoot()
        end
    end

--[[    local camera_x = camera.x(cam)
    local camera_y = camera.y(cam)
    if input.is_key_pressed(input_mgr, key.KEY_UP) then
        camera_y = camera_y + spd * dt * self.time_mul
    elseif input.is_key_pressed(input_mgr, key.KEY_DOWN) then
        camera_y = camera_y - spd * dt * self.time_mul
    end
    camera.set_position(cam, camera_x, camera_y)]]

    self:see_cats()

    if self.health <= 0 then
        self:play_animation("death")
    elseif self.dy > 0 and not self:on_ground() then
        self:play_animation("jumpup")
    elseif not self:on_ground() then
        self:play_animation("jumpdown")
    elseif self:on_ground() and self.dx ~= 0 then
        self:play_animation("run")
    elseif self:is_shooting() then
        self:play_animation("shoot")
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
    if self.cats > 0 then
        for _, c in pairs(G.cats) do
            if c.owner == self then
                c:launch(self.dir)
                self.cd:set("shoot", 0.15)
                audio.play_sound(G.sounds["meow"])
                return
            end
        end
    end
    local b = Bullet(self)
    self.cd:set("shoot", 0.15)
    audio.play_sound(G.sounds["shoot"])
end

function Hero.add_cat(self)
    if self.cats < self.max_cats then
        self.cats = self.cats + 1
        audio.play_sound(G.sounds["pickup"])
    end
end

function Hero:remove_cat()
    if self.cats > 0 then
        self.cats = self.cats - 1
    end
end

function Hero.collect_cat(self)
    self:heal(self.cats * 7)
    self.cats = 0
    audio.play_sound(G.sounds["powerup"])
    self:say("Wow! I've got 7 lives back with this!")
end

function Hero.heal(self, amount)
    self.health = self.health + amount
    if self.health > self.max_health then
        self.health = self.max_health
    end
end

function Hero.is_shooting(self)
    return self.cd:has("shoot")
end

function Hero.say(self, s)
    print("saying "..s)
    self:clear_saying()
    SayText(self, s)
end

function Hero.clear_saying(self)
    for _, en in pairs(G.entities) do
        if en.owner and en.owner == self and en:is(SayText) then
            en:kill()
        end
    end
end

function Hero.see_cats(self)
    for _, c in pairs(G.cats) do
        if self:dist_case(c) < 3 and not self.cd:has("cat_seen") then
            self.cats_seen = self.cats_seen + 1
            if self.cats_seen < #self.cats_sentences+1 then
                print("cats")
                self:say(self.cats_sentences[self.cats_seen])
                self.cd:set("cat_seen", 10)
                return
            end
        end
    end
end

function Hero:hurt(amount)
    if self.cd:has("hurt") then
        return
    end

    self.health = self.health - amount
    if self.health <= 0 then
        self:play_animation("death")
        G.game.camera:shake(2, 0.3)
        self:bump(-self.dir * 0.4, -0.15)
    else
        audio.play_sound(G.sounds["hurt"])
        self.cd:set("hurt", 0.2)
    end
end

function Hero:is_alive()
    return not self.destroyed and self.health > 0
end

function Hero:on_land()
    local fx = Fx("data/img/land.png", 6, 0.3)
    fx:set_pos_pixel(self:get_center_x(), self:get_bottom())
end

function Hero:__tostring()
    return "Hero"
end

return Hero