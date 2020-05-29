local entity = {
    cx = 0,
    cy = 0,
    xr = 0.5,
    yr = 1.0,

    dx = 0.0,
    dy = 0.0,
    bdx = 0.0,
    bdy = 0.0,

    frict = 0.82,
    bump_frict = 0.93,

    hei = const.GRID,
    radius = const.GRID * 0.5,

    sprite_x = 0,
    sprite_y = 0,
    sprite_scale_x = 1.0, -- the current scale (calculated per frame)
    sprite_scale_y = 1.0, -- the current scale (calculated per frame)
    sprite_scale_set_x = 1.0, -- the scale we have set
    sprite_scale_set_y = 1.0, -- the scale we have set

    time_mul = 1, -- time multiplier
    dir = 1, -- direction the entity is facing
}

function entity:new (o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    G.all[#G.all+1] = self
    return o
end

function entity:set_pos_grid(x, y)
    self.cx = x
    self.cy = y
    self.xr = 0.5
    self.yr = 1
end

function entity:set_pos_pixel(x, y)
    self.cx = math.floor(x/const.GRID)
    self.cy = math.floor(y/const.GRID)
    self.xr = (x - self.cx * const.GRID)/const.GRID
    self.yr = (y - self.cy * const.GRID)/const.GRID
end

function entity:bump(x, y)
    self.bdx = self.bdx + x
    self.bdy = self.bdy + y
end

function entity:cancel_velocities()
    self.dx = 0
    self.dy = 0
    self.bdx = 0
    self.bdy = 0
end

function entity:pre_update()
    -- update cooldowns?
    -- update AI?
end

function entity:update(dt)
    -- X
    local steps = math.ceil(math.abs((self.dx + self.bdx) * self.time_mul))
    local step = ((self.dx + self.bdx) * self.time_mul) / steps
    while (steps > 0) do
        self.xr = self.xr + step
        -- add X collisions checks
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
    steps = math.ceil(math.abs((self.dy + self.bdy) * self.time_mul))
    step = ((self.dy + self.bdy) * self.time_mul) / steps
    while (steps > 0) do
        self.yr = self.yr + step
        -- add Y collisions checks
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
end

function entity:post_update()
    if self.sprite == nil then
        return
    end

    self.sprite_x = (self.cx + self.xr) * const.GRID
    self.sprite_y = (self.cy + self.yr) * const.GRID
    self.sprite_scale_x = self.dir * self.sprite_scale_set_x
    self.sprite_scale_y = self.sprite_scale_set_y
end

function entity:get_foot_x()
    return (self.cx + self.xr) * const.GRID
end

function entity:get_foot_y()
    return (self.cy + self.yr) * const.GRID
end

function entity:get_head_x()
    return self:get_foot_x()
end

function entity:get_head_y()
    return self:get_foot_y() - self.hei
end

function entity:get_center_x()
    return self:get_foot_x()
end

function entity:get_center_y()
    return self:get_foot_y() - self.hei * 0.5
end

return entity