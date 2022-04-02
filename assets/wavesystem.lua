local Process = require("process")
local Mob = require("en.mob")

local WaveSystem = Process:extend()

function WaveSystem:new()
    WaveSystem.super.new(self)
    self.x = 0
    self.y = 0
    self.w = 0
    self.h = 0
    self.current_wave = nil
    self.current_wave_idx = 0
    self.current_wave_num_spawned = 0
    self.running = false
    self.waves = {
        {
            total_mobs = 10,
            max_concurrent = 6,
        },
        {
            total_mobs = 20,
            max_concurrent = 8,
        },
        {
            total_mobs = 35,
            max_concurrent = 12,
        },
        {
            total_mobs = 50,
            max_concurrent = 20,
        },
        {
            total_mobs = 80,
            max_concurrent = 30,
        },
    }

    self.announce_font = ttfont.from_file(sdl.assets_dir() .. "font/default.ttf", 32, shader.defaultShader());
end

function WaveSystem:reset()
    self.current_wave = nil
    self.current_wave_idx = 0
    self.current_wave_num_spawned = 0
end

function WaveSystem:start_wave()
    if self.current_wave_idx == nil then
        self.current_wave_idx = 1
    else
        self.current_wave_idx = self.current_wave_idx + 1
    end
    self.current_wave = self.waves[self.current_wave_idx]
    self.current_wave_num_spawned = 0
    self.running = true
    self.cd:set("announce", 2)
end

function WaveSystem:update(dt)
    WaveSystem.super.update(self, dt)
    if not self.current_wave then
        return
    end

    if #G.mobs < self.current_wave.max_concurrent
    and self.current_wave_num_spawned < self.current_wave.total_mobs then
        local sp = G.game.level:get_mob_spawner()
        self:spawn_mob(sp.cx, sp.cy)
        self.current_wave_num_spawned = self.current_wave_num_spawned + 1
    end

    if self.cd:has("announce") then
        self:announce()
    end
end

function WaveSystem:announce()
    local s = string.format("Wave %d", self.current_wave_idx)
    local width = ttfont.get_string_width(self.announce_font, s)
    ttfont.draw_string(self.announce_font, s, gd_instance, self.x + (self.w - width)/2, self.y + (self.h - 32)/2, viewport, color.black, cam);
end

function WaveSystem:update_position(x, y, w, h)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
end

function WaveSystem:spawn_mob(cx, cy)
    local mob = Mob()
    mob:set_pos_grid(cx, cy)
    mob:set_target(G.game.h)
end

return WaveSystem