local entity = {}

entity.cx = 0
entity.cy = 0
entity.xr = 0.5
entity.yr = 1.0

entity.dx = 0.0
entity.dy = 0.0
entity.bdx = 0.0
entity.bdy = 0.0

entity.frict = 0.82
entity.bump_frict = 0.93

entity.hei = const.GRID
entity.radius = const.GRID * 0.5

entity.sprite_x = 0
entity.sprite_y = 0
entity.sprite_scale_x = 1.0 -- the current scale (calculated per frame)
entity.sprite_scale_y = 1.0 -- the current scale (calculated per frame)
entity.sprite_scale_set_x = 1.0 -- the scale we have set
entity.sprite_scale_set_y = 1.0 -- the scale we have set

entity.time_mul = 1 -- time multiplier
entity.test_entity = "test"

function entity.say_test()
    log.info("I said test!")
end

function entity.set_pos_grid(x, y)
    entity.cx = x
    entity.cy = y
    entity.xr = 0.5
    entity.yr = 1
end

function entity.set_pos_pixel(x, y)
    entity.cx = math.floor(x/const.GRID)
    entity.cy = math.floor(y/const.GRID)
    entity.xr = (x - entity.cx * const.GRID)/const.GRID
    entity.yr = (y - entity.cy * const.GRID)/const.GRID
end

function entity.bump(x, y)
    entity.bdx = entity.bdx + x
    entity.bdy = entity.bdy + y
end

function entity.cancel_velocities()
    entity.dx = 0
    entity.dy = 0
    entity.bdx = 0
    entity.bdy = 0
end

function entity.pre_update()
    -- update cooldowns?
    -- update AI?
end

function entity.update()
    -- X
    local steps = math.ceil(math.abs((entity.dx + entity.bdx) * entity.time_mul))
    local step = ((entity.dx + entity.bdx) * entity.time_mul) / steps
    while (steps > 0) do
        entity.xr = entity.xr + step
        -- add X collisions checks
        while (entity.xr > 1) do
            entity.xr = entity.xr - 1
            entity.cx = entity.cx + 1
        end
        while (entity.xr < 0) do
            entity.xr = entity.xr + 1
            entity.cx = entity.cx - 1
        end
        steps = steps - 1
    end
    entity.dx = entity.dx * math.pow(entity.frict, entity.time_mul)
    entity.bdx = entity.bdx * math.pow(entity.bump_frict, entity.time_mul)
    if (math.abs(entity.dx) <= 0.0005 * entity.time_mul) then
        entity.dx = 0
    end
    if (math.abs(entity.bdx) <= 0.0005 * entity.time_mul) then
        entity.bdx = 0
    end

    -- Y
    steps = math.ceil(math.abs((entity.dy + entity.bdy) * entity.time_mul))
    step = ((entity.dy + entity.bdy) * entity.time_mul) / steps
    while (steps > 0) do
        entity.yr = entity.yr + step
        -- add Y collisions checks
        while (entity.yr > 1) do
            entity.yr = entity.yr - 1
            entity.cy = entity.cy + 1
        end
        while (entity.yr < 0) do
            entity.yr = entity.yr + 1
            entity.cy = entity.cy - 1
        end
        steps = steps - 1
    end
    entity.dy = entity.dy * math.pow(entity.frict, entity.time_mul)
    entity.bdy = entity.bdy * math.pow(entity.bump_frict, entity.time_mul)
    if (math.abs(entity.dy) <= 0.0005 * entity.time_mul) then
        entity.dy = 0
    end
    if (math.abs(entity.bdy) <= 0.0005 * entity.time_mul) then
        entity.bdy = 0
    end
end

function entity.post_update()
    if entity.sprite == nil then
        return
    end

    entity.sprite_x = (entity.cx + entity.xr) * const.GRID
    entity.sprite_y = (entity.cy + entity.xy) * const.GRID
    entity.sprite_scale_x = entity.dir * entity.sprite_scale_set_x
    entity.sprite_scale_y = entity.sprite_scale_set_y
end

return entity