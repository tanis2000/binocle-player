local lume = require("lib.lume")
local const = require("const")
local Object = require("lib.classic")
local Cooldown = require("cooldown")
local M = require("m")
local util = require("util")
local layers = require("layers")

---@class Entity
local Entity = Object:extend()

function Entity.new(self)
    self.cx = 0
    self.cy = 0
    self.xr = 0.5
    self.yr = 0

    self.dx = 0.0
    self.dy = 0.0
    self.bdx = 0.0
    self.bdy = 0.0

    self.gravity = 0.025

    self.frict = 0.82
    self.bump_frict = 0.93

    self.hei = const.GRID
    self.wid = const.GRID
    self.radius = const.GRID * 0.5

    self.depth = 0

    -- Defines X alignment of entity at its attach point (0 to 1.0)
    self.pivot_x = 0.5
    -- Defines Y alignment of entity at its attach point (0 to 1.0)
    self.pivot_y = 0

    self.sprite = nil
    self.material = nil
    self.texture = nil

    self.sprite_x = 0
    self.sprite_y = 0
    self.sprite_scale_x = 1.0 -- the current scale (calculated per frame)
    self.sprite_scale_y = 1.0 -- the current scale (calculated per frame)
    self.sprite_scale_set_x = 1.0 -- the scale we have set
    self.sprite_scale_set_y = 1.0 -- the scale we have set
    self.visible = true

    self.time_mul = 1 -- time multiplier
    self.dir = 1 -- direction the entity is facing

    self.animations = {}
    self.animation = nil
    self.animation_timer = 0
    self.animation_frame = 1

    self.destroyed = false

    self.image = nil

    self.has_collisions = true
    self.cd = Cooldown()

    self.name = "entity " .. #G.entities+1
    G.entities[#G.entities+1] = self
end

---Load an image
---@param filename string the path to the image to load
---@param width number the width of a single frame
---@param height number the height of a single frame
function Entity:load_image(filename, width, height)
    self.image = G.cache.load(filename)
    self.texture = texture.from_image(self.image)
    self.material = material.new()

    material.set_texture(self.material, self.texture)
    material.set_shader(self.material, G.default_shader)
    self.sprite = sprite.from_material(self.material)
    self.frames = {}
    local original_image_width, original_image_height = image.get_info(self.image)
    for y = 0, original_image_height / height - 1 do
        for x = 0, original_image_width / width - 1 do
            print(self.name .. " image x "..tostring(x) .. " y " .. tostring(y) .. " w " .. tostring(width) .. " h " .. tostring(height))
            local frame = subtexture.subtexture_with_texture(self.texture, x * width, y * height, width, height)
            sprite.set_subtexture(self.sprite, frame)
            table.insert(self.frames, frame)
        end
    end
    sprite.set_origin(self.sprite, width * self.pivot_x, height * self.pivot_y)
end

function Entity.set_pos_grid(self, x, y)
    self.cx = math.floor(x)
    self.cy = math.floor(y)
    self.xr = 0.5
    self.yr = 0
end

function Entity.set_pos_pixel(self, x, y)
    self.cx = math.floor(x/const.GRID)
    self.cy = math.floor(y/const.GRID)
    self.xr = (x - self.cx * const.GRID)/const.GRID
    self.yr = (y - self.cy * const.GRID)/const.GRID
end

function Entity.bump(self, x, y)
    self.bdx = self.bdx + x
    self.bdy = self.bdy + y
end

function Entity.cancel_velocities(self)
    self.dx = 0
    self.dy = 0
    self.bdx = 0
    self.bdy = 0
end

function Entity.on_ground(self)
    return G.game.level:has_wall_collision(self.cx, self.cy-1) and self.yr == 0 and self.dy <= 0
end

function Entity.pre_update(self, dt)
    self.cd:update(dt)
    -- update AI?
end

function Entity.on_touch_wall(self)

end

function Entity.on_land(self)

end

function Entity.on_pre_step_x(self)
    -- Right collision
    if self.has_collisions and self.xr > 0.8 and G.game.level:has_wall_collision(self.cx+1, self.cy) then
        self:on_touch_wall(1)
        self.xr = 0.8
    end

    -- Left collision
    if self.has_collisions and self.xr < 0.2 and G.game.level:has_wall_collision(self.cx-1, self.cy) then
        self:on_touch_wall(-1)
        self.xr = 0.2
    end
end

function Entity.on_pre_step_y(self)
    -- Down
    if self.has_collisions and self.yr < 0.0 and G.game.level:has_wall_collision(self.cx, self.cy - 1) then
        self.dy = 0
        self.yr = 0
        self.bdx = self.bdx * 0.5
        self.bdy = 0
        self:on_land()
    end

    -- Up
    if self.has_collisions and self.yr > 0.5 and G.game.level:has_wall_collision(self.cx, self.cy + 1) then
        self.yr = 0.5
    end
end

function Entity.update(self, dt)
    -- X
    local steps = math.ceil(math.abs((self.dx + self.bdx) * self.time_mul))
    local step = ((self.dx + self.bdx) * self.time_mul) / steps
    while (steps > 0) do
        self.xr = self.xr + step
        -- add X collisions checks
        self:on_pre_step_x()
        while (self.xr > 1) do
            self.xr = self.xr - 1
            self.cx = self.cx + 1
        end
        while (self.xr < 0) do
            self.xr = self.xr + 1
            self.cx = self.cx - 1
        end
        steps = steps - 1
    end
    self.dx = self.dx * math.pow(self.frict, self.time_mul)
    self.bdx = self.bdx * math.pow(self.bump_frict, self.time_mul)
    if (math.abs(self.dx) <= 0.0005 * self.time_mul) then
        self.dx = 0
    end
    if (math.abs(self.bdx) <= 0.0005 * self.time_mul) then
        self.bdx = 0
    end

    -- Y
    if not self:on_ground() then
        self.dy = self.dy - self.gravity
    end

    steps = math.ceil(math.abs((self.dy + self.bdy) * self.time_mul))
    step = ((self.dy + self.bdy) * self.time_mul) / steps
    while (steps > 0) do
        self.yr = self.yr + step
        -- add Y collisions checks
        self:on_pre_step_y()
        while (self.yr > 1) do
            self.yr = self.yr - 1
            self.cy = self.cy + 1
        end
        while (self.yr < 0) do
            self.yr = self.yr + 1
            self.cy = self.cy - 1
        end
        steps = steps - 1
    end
    self.dy = self.dy * math.pow(self.frict, self.time_mul)
    self.bdy = self.bdy * math.pow(self.bump_frict, self.time_mul)
    if (math.abs(self.dy) <= 0.0005 * self.time_mul) then
        self.dy = 0
    end
    if (math.abs(self.bdy) <= 0.0005 * self.time_mul) then
        self.bdy = 0
    end

    self:update_animation(dt)
end

function Entity.post_update(self)
    if self.sprite == nil then
        return
    end

    self.sprite_x = (self.cx + self.xr) * const.GRID
    self.sprite_y = (self.cy + self.yr) * const.GRID
    self.sprite_scale_x = self.dir * self.sprite_scale_set_x
    self.sprite_scale_y = self.sprite_scale_set_y
end

function Entity:draw_debug()
    if G.debug then
        local s = string.format("(%.0f,%.0f) (%.0f, %.0f)", self.cx, self.cy, self:get_center_x(), self:get_center_y())
        ttfont.draw_string(G.game.default_font, s, gd_instance, self:get_center_x(), self:get_top(), viewport, color.white, cam, layers.TEXT);
        gd.draw_rect(gd_instance, self:get_center_x(), self:get_center_y(), self.wid, self.hei, color.trans_green, viewport, cam)
    end
end

function Entity:draw()
    if self.visible and self.sprite then
        sprite.draw(self.sprite, gd_instance, self.sprite_x, self.sprite_y, viewport, 0, self.sprite_scale_x, self.sprite_scale_y, cam, layers.MOBS)
        --sprite.draw_batch(sb, self.sprite, gd_instance, self.sprite_x, self.sprite_y, viewport, 0, self.sprite_scale_x, self.sprite_scale_y, cam, 0)
    end
end

function Entity.get_left(self)
    return self:get_attach_x() + (0.0 - self.pivot_x) * self.wid
end

function Entity.get_right(self)
    return self:get_attach_x() + (1.0 - self.pivot_x) * self.wid
end

function Entity.get_top(self)
    return self:get_attach_y() + (1.0 - self.pivot_y) * self.hei
end

function Entity.get_bottom(self)
    return self:get_attach_y() + (0.0 - self.pivot_y) * self.hei
end

function Entity.get_center_x(self)
    return self:get_attach_x() + (0.5 - self.pivot_x) * self.wid
end

function Entity.get_center_y(self)
    return self:get_attach_y() + (0.5 - self.pivot_y) * self.hei
end

function Entity.get_attach_x(self)
    return (self.cx + self.xr) * const.GRID
end

function Entity.get_attach_y(self)
    return (self.cy + self.yr) * const.GRID
end

function Entity.is_inside(self, px, py)
    return (px >= self:get_left() and px <= self:get_right() and py >= self:get_bottom() and py <= self:get_top())
end

function Entity.add_animation(self, idx, frames, period, loop)
    self.animations[idx] = {
        frames = lume.clone(frames),
        period = period ~= 0 and 1 / math.abs(period) or 1,
        loop = loop == nil and true or loop
    }
end

function Entity.play_animation(self, idx, force)
    self.animation = self.animations[idx]

    if force or self.animation ~= self.animation then
        self.animationTimer = self.animation.period
        self.animationFrame = 1
        self.frame = lume.first(self.animation.frames)
    end
end

function Entity.stop_animation(self)
    self.animation = nil
end

function Entity.update_animation(self, dt)
    if not self.animation then
        return
    end

    self.animation_timer = self.animation_timer - dt

    if self.animation_timer <= 0 then
        self.animation_frame = self.animation_frame + 1

        local anim = self.animation

        if self.animation_frame > #anim.frames then
            if anim.loop == true then
                self.animation_frame = 1
            else
                self:stop_animation()

                if type(anim.loop) == "function" then
                    anim.loop()
                end

                return
            end
        end

        self.animation_timer = self.animation_timer + anim.period
        self.frame = anim.frames[self.animation_frame]
        sprite.set_subtexture(self.sprite, self.frames[self.frame])
    end
end

function Entity.is_alive(self)
    return not self.destroyed
end

function Entity.kill(self)
    self.destroyed = true
end

function Entity.on_dispose(self)
    -- TODO dispose of sprite, material, texture, etc...
    lume.remove(G.entities, self)
    if self.sprite then
        sprite.destroy(self.sprite)
        self.sprite = nil
    end
    if self.material then
        material.destroy(self.material)
        self.material = nil
    end
    --texture.destroy(self.texture)
end

function Entity.dir_to(self, en)
    if en:get_center_x() < self:get_center_x() then
        return -1
    end
    return 1
end

function Entity.dir_to_ang(self)
    if self.dir == 1 then
        return 0
    end
    return math.pi
end

function Entity.dist_case(self, en)
    return M.dist(self.cx + self.xr, self.cy + self.yr, en.cx + en.xr, en.cy + en.yr)
end

function Entity.dist_case_free(self, tcx, tcy, txr, tyr)
    if not txr then
        txr = 0.5
    end

    if not tyr then
        tyr = 0.5
    end

    return M.dist(self.cx + self.xr, self.cy + self.yr, tcx + txr, tcy + tyr)
end

function Entity.can_see_through(cx, cy)
    return not G.game.level:has_wall_collision(cx, cy) or self.cx == cx and self.cy == cy
end

function Entity:sight_check(en, tcx, tcy)
    if en then
        return util.line(self.cx, self.cy, en.cx, en.cy, Entity.can_see_through)
    else
        return util.line(self.cx, self.cy, tcx, tcy, Entity.can_see_through)
    end
end

function Entity:screen_position_to_world(sx, sy)
    local px, py = viewport_adapter.get_screen_to_virtual_viewport(adapter, sx, sy)
    px = px / const.SCALE
    py = py / const.SCALE
    px = px + camera.x(cam)
    py = py + camera.y(cam)
    --print(tostring(px) .. ", " .. tostring(py))
    return px, py
end

return Entity