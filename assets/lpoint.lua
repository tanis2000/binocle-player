local const = require("const")
local M = require("m")
local Object = require("lib.classic")

---@class LPoint
local LPoint = Object:extend()

function LPoint:new()
    self.cx = 0
    self.cy = 0
    self.xr = 0
    self.yr = 0
end

function LPoint:get_cxf()
    return self.cx+self.xr
end

function LPoint:get_cyf()
    return self.cy+self.yr
end

function LPoint:get_level_x()
    return (self.cx+self.xr) * const.GRID
end

function LPoint:get_level_y()
    return (self.cy+self.yr) * const.GRID
end

function LPoint:set_level_x(v)
    return self:set_level_pixel_x(v)
end

function LPoint:set_level_y(v)
    return self:set_level_pixel_y(v)
end

function LPoint:get_level_xi()
    return math.floor(self:get_level_x())
end

function LPoint:get_level_yi()
    return math.floor(self:get_level_y())
end

function LPoint:get_screen_x()
    return self:get_level_x() * const.SCALE
end

function LPoint:get_screen_y()
    return self:get_level_y() * const.SCALE
end

function LPoint:set_level_case(x, y, xr, yr)
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

function LPoint:set_level_pixel(x, y)
    self:set_level_pixel_x(x)
    self:set_level_pixel_y(y)
end

function LPoint:set_level_pixel_x(x)
    self.cx = math.floor(x / const.GRID)
    self.xr = (x % const.GRID) / const.GRID
end

function LPoint:set_level_pixel_y(y)
    self.cy = math.floor(y / const.GRID)
    self.yr = (y % const.GRID) / const.GRID
end

function LPoint:dist_case(e, pt, tcx, tcy, txr, tyr)
    if not tcx then
        tcx = 0
    end

    if not tcy then
        tcy = 0
    end

    if not txr then
        txr = 0.5
    end

    if not tyr then
        tyr = 0.5
    end

    if e ~= nil then
        return M.dist(self.cx+self.xr, self.cy+self.yr, e.cx+e.xr, e.cy+e.yr)
    elseif pt ~= nil then
        return M.dist(self.cx+self.xr, self.cy+self.yr, pt.cx+pt.xr, pt.cy+pt.yr)
    else
        return M.dist(self.cx+self.xr, self.cy+self.yr, tcx+txr, tcy+tyr)
    end
end

--- Distance to something else, in level pixels
---@field e Entity
---@field pt LPoint
---@field lvl_x number
---@field lvl_y number
---@return number
function LPoint:dist_px(e, pt, lvl_x, lvl_y)
    if not lvl_x then
        lvl_x = 0
    end

    if not lvl_y then
        lvl_y = 0
    end

    if e ~= nil then
        return M.dist(self:get_level_x(), self:get_level_y(), e:get_attach_x(), e:get_attach_y())
    elseif pt ~= nil then
        return M.dist(self:get_level_x(), self:get_level_y(), pt:get_level_x(), pt:get_level_y())
    else
        return M.dist(self:get_level_x(), self:get_level_y(), lvl_x, lvl_y)
    end
end

--- Angle in radians to something else, in level pixels
---@field e Entity
---@field pt LPoint
---@field lvl_x number
---@field lvl_y number
---@return number
function LPoint:ang_to(e, pt, lvl_x, lvl_y)
    if not lvl_x then
        lvl_x = 0
    end

    if not lvl_y then
        lvl_y = 0
    end

    if e ~= nil then
        return math.atan2((e.cy+e.yr)-self:get_cyf(), (e.cx+e.xr)-self:get_cxf())
    elseif pt ~= nil then
        return math.atan2(pt:get_cyf()-self:get_cyf(), pt:get_cxf()-self:get_cxf())
    else
        return math.atan2(lvl_y-self:get_level_y(), lvl_x-self:get_level_x())
    end
end

function LPoint:__tostring()
    return string.format("LPoint<%f,%f / %d,%d>", self:get_cxf(), self:get_cyf(), self:get_level_xi(), self:get_level_yi())
end

return LPoint