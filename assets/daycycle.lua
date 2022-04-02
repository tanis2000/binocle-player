local Process = require("process")

local DayCycle = Process:extend()

function DayCycle:new()
    DayCycle.super.new(self)
    self.fullday_time = 60 -- seconds
    self.time = 0 -- 6/24 * self.fullday_time -- 6 am is when daylight starts
    self.cycle = 1
    self.bg_colors = {
        {
            r = 73/256,
            g = 77/256,
            b = 126/256,
            a = 1
        },
        {
            r = 242/256,
            g = 211/256,
            b = 171/256,
            a = 1
        },
    }

    -- TODO add random one-pixel stars in the background during night
end

function DayCycle:update(dt)
    self.time = self.time + dt
    if self.time > self.fullday_time then
        self.time = 0
        self.cycle = self.cycle + 1
        if self.cycle > 2 then
            self.cycle = 1
        end
    end
end

function DayCycle:get_bg_color()
    local ratio = self.time / self.fullday_time
    local c = self.cycle
    local nc = self.cycle + 1
    if nc > 2 then
        nc = 1
    end
    print(ratio)
    local r = self.bg_colors[nc].r * ratio
    local g = self.bg_colors[nc].g * ratio
    local b = self.bg_colors[nc].b * ratio
    local a = self.bg_colors[nc].a * ratio

    local r2 = self.bg_colors[c].r * (1 - ratio)
    local g2 = self.bg_colors[c].g * (1 - ratio)
    local b2 = self.bg_colors[c].b * (1 - ratio)
    local a2 = self.bg_colors[c].a * (1 - ratio)

    return r + r2, g +g2, b + b2, a + a2
end

function DayCycle:get_time_of_day()
    local h = math.floor(self.time / self.fullday_time * 24)
    local m = math.floor(self.time / self.fullday_time * 24 * 60 % self.fullday_time)
    return h, m
end

return DayCycle
