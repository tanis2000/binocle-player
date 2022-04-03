local Entity = require("entity")
local Hero = require("en/hero")
local Mob = require("en.mob")
local Process = require("process")
local DebugGui = require("debuggui")
local GameCamera = require("gamecamera")
local Cat = require("en.cat")
local Gui = require("gui")
local const = require("const")
local lume = require("lib.lume")
local DayCycle = require("daycycle")
local WaveSystem = require("wavesystem")

local Game = Process:extend()

function Game:new(shd)
    Game.super.new(self)
    self.name = "game"
    self.shader = shd
    local assets_dir = sdl.assets_dir()
    self.h = Hero()

    local l = require("level")
    self.level = l:new()
    self:add_child(l)

    local hs = self.level:get_hero_spawner()
    self.h:set_pos_grid(hs.cx, hs.cy)

    gd.set_offscreen_clear_color(gd_instance, 73/256, 77/256, 126/256, 1)
    gd.set_offscreen_clear_color(gd_instance, 242/256, 211/256, 171/256, 1)

    self.debugGui = DebugGui()

    self.default_font = ttfont.from_file(assets_dir .. "font/default.ttf", 8, shader.defaultShader());

    self.camera = GameCamera()
    self:add_child(self.camera)
    self.camera:track_entity(self.h)
    self.camera:center_on_target()

    self:spawn_cats(3)

    self.gui = Gui()
    print(self.gui)
    self:add_child(self.gui)

    self.day_cycle = DayCycle()
    self:add_child(self.day_cycle)

    self.wave_system = WaveSystem()
    self:add_child(self.wave_system)
    self.day_cycle:set_on_cycle_switch_fn(function(cycle)
        if cycle == 2 and not self.wave_system.running then
            self.wave_system:start_wave()
        end
    end)
end

function Game:pre_update(dt)
    Game.super.pre_update(self, dt)

    for idx in pairs(G.entities) do
        en = G.entities[idx]
        if not en.destroyed then
            en:pre_update(dt)
        end
    end
end

function Game:update(dt)
    Game.super.update(self, dt)
    -- input management
    if input.is_key_pressed(input_mgr, key.KEY_SPACE) then
        self.cd:set("test", 5, nil)
    end

    if self.cd:has("test") then
        --log.info("cd: " .. tostring(self.cd:get("test")))
    end

    if input.is_key_pressed(input_mgr, key.KEY_L) then
        camera.set_position(cam, camera.x(cam) + 100 * dt, camera.y(cam))
        io.write(camera.x(cam).."\n")
    elseif input.is_key_pressed(input_mgr, key.KEY_J) then
        camera.set_position(cam, camera.x(cam) - 100 * dt, camera.y(cam))
    end

    if input.is_key_pressed(input_mgr, key.KEY_I) then
        camera.set_position(cam, camera.x(cam), camera.y(cam) + 100 * dt)
    elseif input.is_key_pressed(input_mgr, key.KEY_K) then
        camera.set_position(cam, camera.x(cam), camera.y(cam) - 100 * dt)
    end


    self.level:update(dt)

    --self.h:pre_update(dt)
    --self.h:update(dt)


    for idx in pairs(G.entities) do
        en = G.entities[idx]
        if not en.destroyed then
            en:update(dt)
        end
    end

    --for idx in pairs(G.bullets) do
    --    b = G.bullets[idx]
    --    b:pre_update(dt)
    --    b:update(dt)
    --end

    self.gui:update_position(self.camera:get_left(), self.camera:get_top())
    self.gui.max_cats = self.h.max_cats
    self.gui.carried_cats = self.h.cats
    self.gui.health = self.h.health
    self.gui.max_health = self.h.max_health
    self.gui.hour, self.gui.minute = self.day_cycle:get_time_of_day()
    gd.set_offscreen_clear_color(gd_instance, self.day_cycle:get_bg_color())


    self.wave_system:update_position(self.camera:get_left(), self.camera:get_bottom(), self.camera:get_px_wid(), self.camera:get_px_hei())

    self.debugGui:update(dt)
end

function Game:post_update(dt)
    Game.super.post_update(self, dt)

    for _, en in pairs(self:get_on_screen_entities()) do
        if not en.destroyed then
            en:post_update(dt)
            en:draw()
            en:draw_debug()
        end
    end

    self:garbage_collect()
end

function Game:get_on_screen_entities()
    local entities = {}

    local l = self.camera:get_left() - const.GRID
    local b = self.camera:get_bottom() - const.GRID
    local r = self.camera:get_right() + const.GRID
    local t = self.camera:get_top() + const.GRID

    for _, en in pairs(G.entities) do
        if en:get_left() > l and en:get_right() < r and en:get_bottom() > b and en:get_top() < t then
            table.insert(entities, en)
        end
    end

    table.sort(entities, function(en1, en2)
        return en1.depth < en2.depth
    end)

    return entities
end


function Game:garbage_collect()
    for idx in lume.ripairs(G.entities) do
        en = G.entities[idx]
        if en.destroyed then
            print("dispose")
            en:on_dispose()
        end
    end
end

function Game:on_destroy()
    ttfont.destroy(self.default_font)
end

function Game:spawn_cats(num)
    for i = 1, num do
        local sp = self.level:get_cat_spawner()
        local c = Cat()
        c:set_pos_grid(sp.cx, sp.cy)
    end
end

return Game