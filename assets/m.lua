local M = {}

function M.normalize_deg(a) -- [-180,180]
    while a<-180 do a = a + 360 end
    while a>180 do a = a -360 end
    return a
end

function M.normalize_rad(a) --[-PI,PI]
    while a<-math.pi do a = a + math.pi * 2.0 end
    while a>math.pi do a = a - math.pi * 2.0 end
    return a
end

function M.deg_distance(a, b)
    return math.abs(M.deg_subtract(a, b))
end

function M.deg_subtract(a, b) -- returns a-b (normalized)
    return M.normalize_deg(M.normalize_deg(a) - M.normalize_deg(b))
end

function M.rad_clamp(a, ref_ang, max_delta)
    local d = M.rad_subtract(a, ref_ang)
    if d > max_delta then
        return ref_ang + max_delta
    end
    if d < -max_delta then
        return ref_ang - max_delta
    end
    return a
end

function M.rad_distance(a, b)
    return math.abs(M.rad_subtract(a, b))
end

function M.rad_close_to(cur_ang, target, max_ang_dist)
    return M.rad_distance(cur_ang, target) <= math.abs(max_ang_dist)
end

function M.rad_subtract(a, b) -- returns a-b (normalized)
    a = M.normalize_rad(a)
    b = M.normalize_rad(b)
    return M.normalize_rad(a-b)
end

function M.ang_to(fx, fy, tx, ty)
    return math.atan2(ty-fy, tx-fx)
end

function M:dist_sqr(ax, ay, bx, by)
    return (ax-bx)*(ax-bx) + (ay-by)*(ay-by)
end

function M:idist_sqr(ax, ay, bx, by)
    return (math.floor(ax)-math.floor(bx))*(math.floor(ax)-math.floor(bx)) + (math.floor(ay)-math.floor(by))*(math.floor(ay)-math.floor(by))
end

function M:dist(ax, ay, bx, by)
    return math.sqrt(self:dist_sqr(ax, ay, bx, by))
end

return M