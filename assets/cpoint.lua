local const = require("const")
local cpoint = {}

function cpoint:new(x, y, xr, yr)
    if not xr then
        xr = 0.5
    end

    if not yr then
        yr = 0.5
    end

    local o = {
        cx = x,
        cy = y,
        xr = xr,
        yr = yr,
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function cpoint:set(x, y, xr, yr)
    if not xr then
        xr = 0.5
    end

    if not yr then
        yr = 0.5
    end

    self.x = x
    self.y = y
    self.xr = xr
    self.yr = yr
end

function cpoint:get_foot_x()
    return (self.cx + self.xr) * const.GRID
end

function cpoint:get_foot_y()
    return (self.cy + self.yr) * const.GRID
end

function cpoint:get_center_x()
    return self:get_foot_x()
end

function cpoint:get_center_y()
    return self:get_foot_y() - const.GRID * 0.5
end

function cpoint:dist_grid(e, pt, cx, cy, xr, yr)
    if e ~= nil then
        return dist(cx+xr, cy+yr, e.cx+e.xr, e.cy+e.yr)
    elseif pt ~= nil then
        return dist(cx+xr, cy+yr, pt.cx+pt.xr, pt.cy+pt.yr)
    else
        return dist(self.cx+self.xr, self.cy+self.yr, cx+xr, cy+yr)
    end
end

function cpoint:dist_px(e, pt, x, y)
    if e ~= nil then
        return dist(self:get_foot_x(), self:get_foot_y(), e:get_foot_x(), e:get_foot_y())
    elseif pt ~= nil then
        return dist(self:get_foot_x(), self:get_foot_y(), pt:get_foot_x(), pt:get_foot_y())
    else
        return dist(self:get_foot_x(), self:get_foot_y(), x, y)
    end
end

local function dist_sqr(ax, ay, bx, by)
    return (ax-bx)*(ax-bx) + (ay-by)*(ay-by)
end

local function dist(ax, ay, bx, by)
    return math.sqrt(dist_sqr(ax, ay, bx, by))
end

return cpoint