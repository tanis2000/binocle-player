local Process = require("process")
local Entity = require("entity")
local LPoint = require("lpoint")
local lume = require("lib.lume")
local const = require("const")

---@class GameCamera
local GameCamera = Process:extend()

function GameCamera:new()
    GameCamera.super.new(self)
    self.name = "camera"
    self.raw_focus = LPoint()
    self.raw_focus:set_level_case(0, 0)
    self.clamped_focus = LPoint()
    self.clamped_focus:set_level_case(0, 0)
    self.clamp_to_level_bounds = true
    self.dx = 0
    self.dy = 0

    ---@type Entity
    self.target = nil
    self.target_off_x = 0
    self.target_off_y = 20
    self.dead_zone_pct_x = 0.04
    self.dead_zone_pct_y = 0.10
    self.base_frict = 0.89
    self.bump_off_x = 0.0
    self.bump_off_y = 0.0
    self.zoom = 1.0
    self.tracking_speed = 1.0
    self.brake_dist_near_bounds = 0.1
    self.shake_power = 1.0
end

function GameCamera:get_left()
    return math.floor(self.clamped_focus.get_level_x() - self:get_px_wid() * 0.5)
end

function GameCamera:get_right()
    return math.floor(self.clamped_focus.get_level_x() + self:get_px_wid() * 0.5)
end

function GameCamera:get_top()
    return math.floor(self.clamped_focus.get_level_y() + self:get_px_hei() * 0.5)
end

function GameCamera:get_bottom()
    return math.floor(self.clamped_focus.get_level_y() - self:get_px_hei() * 0.5)
end

function GameCamera:get_center_x()
    return math.floor((self:get_left() + self:get_right()) * 0.5)
end

function GameCamera:get_center_y()
    return math.floor((self:get_bottom() + self:get_top()) * 0.5)
end

function GameCamera:set_zoom(v)
    self.zoom = lume.clamp(v, 1, 10)
end

function GameCamera:get_px_wid()
    return math.ceil(const.DESIGN_WIDTH / self.zoom)
end

function GameCamera:get_px_hei()
    return math.ceil(const.DESIGN_HEIGHT / self.zoom)
end

function GameCamera:is_on_screen(level_x, level_y)
    return level_x >= self:get_left() and level_x <= self:get_right()
    and level_y <= self:get_top() and level_y >= self:get_bottom()
end

function GameCamera:is_on_screen_case(cx, cy, pad)
    if not pad then
        pad = 32
    end
    return cx * const.GRID >= self:get_left() - pad and (cx+1) * const.GRID <= self:get_right() + pad
            and cy*const.GRID <= self:get_top()+pad and (cy+1) * const.GRID >= self:get_bottom() - pad
end

function GameCamera:track_entity(e, immediate, speed)
    if not speed then
        speed = 1.0
    end
    self.target = e
    self:set_tracking_speed(speed)
    if immediate or self.raw_focus:get_level_x() == 0 and self.raw_focus:get_level_y() == 0 then
        self:center_on_target()
    end
end

function GameCamera:set_tracking_speed(spd)
    self.tracking_speed = lume.clamp(spd, 0.01, 10)
end

function GameCamera:stop_tracking()
    self.target = nil
end

function GameCamera:center_on_target()
    if self.target ~= nil then
        self.raw_focus:set_level_x(self.target:get_center_x() + self.target_off_x)
        self.raw_focus:set_level_y(self.target:get_center_y() + self.target_off_y)
    end
end

function GameCamera:shake_s(t, pow)
    if not pow then
        pow = 1.0
    end

    self.cd:set_s("shaking", t, false)
    self.shake_power = pow
end

function GameCamera:bump_ang(a, dist)
    self.bump_off_x = self.bump_off_x + math.cos(a) * dist
    self.bump_off_y = self.bump_off_y + math.sin(a) * dist
end

---@field x number
---@field y number
function GameCamera:bump(x, y)
    self.bump_off_x = self.bump_off_x + x
    self.bump_off_y = self.bump_off_y + y
end

function GameCamera:apply()
    local cam_x = math.floor(self.clamped_focus:get_level_x() - self:get_px_wid() * 0.5)
    local cam_y = math.floor(self.clamped_focus:get_level_y() - self:get_px_hei() * 0.5)
    camera.set_position(cam, cam_x, cam_y)
end

function GameCamera:post_update(dt)
    GameCamera.super.post_update(self, dt)
    self:apply()
end

function GameCamera:update(dt)
    GameCamera.super.update(self, dt)
    local level = G.game.level

    -- target tracking
    if self.target ~= nil then
        local spd_x = 0.015 * self.tracking_speed * self.zoom
        local spd_y = 0.023 * self.tracking_speed * self.zoom
        local tx = self.target:get_center_x() + self.target_off_x
        local ty = self.target:get_center_y() + self.target_off_y
        local a = self.raw_focus:ang_to(nil, nil, tx, ty)
        local dist_x = math.abs(tx - self.raw_focus:get_level_x())
        if (dist_x >= self.dead_zone_pct_x * self:get_px_wid()) then
            self.dx = self.dx + math.cos(a) * (0.8 * dist_x - self.dead_zone_pct_x * self:get_px_wid()) * spd_x
        end
        local dist_y = math.abs(ty - self.raw_focus:get_level_y())
        if (dist_y >= self.dead_zone_pct_y * self:get_px_hei()) then
            self.dy = self.dy + math.sin(a) * (0.8 * dist_y - self.dead_zone_pct_y * self:get_px_hei()) * spd_y
        end
    end

    -- friction
    local frict_x = self.base_frict - self.tracking_speed * self.zoom * 0.027 * self.base_frict
    local frict_y = frict_x
    if self.clamp_to_level_bounds then
        local brake_dist = self.brake_dist_near_bounds * self:get_px_wid()
        if self.dx <= 0 then
            local brake_ratio = 1 - lume.clamp((self.raw_focus:get_level_x() - self:get_px_wid() * 0.5) / brake_dist, 0, 1)
            frict_x = frict_x * 1 - 0.9 * brake_ratio
        elseif self.dx > 0 then
            local brake_ratio = 1 - lume.clamp(((level:get_px_wid() - self:get_px_wid() * 0.5) - self.raw_focus:get_level_x()) / brake_dist, 0, 1)
            frict_x = frict_x * 1 - 0.9 * brake_ratio
        end

        brake_dist = self.brake_dist_near_bounds * self:get_px_hei()
        if self.dy > 0 then
            local brake_ratio = 1 - lume.clamp((self.raw_focus:get_level_y() - self:get_px_hei() * 0.5) / brake_dist, 0, 1)
            frict_y = frict_y * 1 - 0.9 * brake_ratio
        elseif self.dy < 0 then
            local brake_ratio = 1 - lume.clamp(((level:get_px_hei() - self:get_px_hei() * 0.5) - self.raw_focus:get_level_y()) / brake_dist, 0, 1)
            frict_y = frict_y * 1 - 0.9 * brake_ratio
        end
    end

    self.raw_focus:set_level_x(self.raw_focus:get_level_x() + self.dx)
    self.dx = self.dx * math.pow(frict_x, 1)
    if math.abs(self.dx) < 0.01 then
        self.dx = 0
    end
    self.raw_focus:set_level_y(self.raw_focus:get_level_y() + self.dy)
    self.dy = self.dy * math.pow(frict_y, 1)
    if math.abs(self.dy) < 0.01 then
        self.dy = 0
    end
    if self.clamp_to_level_bounds then
        if level:get_px_wid() < self:get_px_wid() then
            self.clamped_focus:set_level_x(level:get_px_wid() * 0.5) -- centered small level
        else
            self.clamped_focus:set_level_x(lume.clamp(self.raw_focus:get_level_x(), self:get_px_wid() * 0.5, level:get_px_wid() - self:get_px_wid() * 0.5))
        end

        if level:get_px_hei() < self:get_px_hei() then
            self.clamped_focus:set_level_y(level:get_px_hei() * 0.5) -- centered small level
        else
            self.clamped_focus:set_level_y(lume.clamp(self.raw_focus:get_level_y(), self:get_px_hei() * 0.5, level:get_px_hei() - self:get_px_hei() * 0.5))
        end
    else
        self.clamped_focus:set_level_x(self.raw_focus:get_level_x())
        self.clamped_focus:set_level_y(self.raw_focus:get_level_y())
    end
end

function GameCamera:__tostring()
    return string.format("GameCamera<%f,%f>", self.raw_focus:get_level_x(), self.raw_focus:get_level_y())
end

return GameCamera