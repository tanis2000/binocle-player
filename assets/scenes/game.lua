local Entity = require("entity")
local Hero = require("en/hero")
local Mob = require("en.mob")
local Process = require("process")
local DebugGui = require("debuggui")
local GameCamera = require("gamecamera")
local Card = require("en.card")
local Building = require("en.building")
local Disaster = require("en.disaster")
local Gui = require("gui")
local const = require("const")
local lume = require("lib.lume")
local DayCycle = require("daycycle")
local TimeSystem = require("sys.timesystem")

local Game = Process:extend()

function Game:new(shd)
    Game.super.new(self)
    G.game = self
    self.name = "game"
    self.shader = shd
    local assets_dir = sdl.assets_dir()
    self.h = Hero()
    self.h:set_pos_grid(2, 7)

    local l = require("level")
    self.level = l:new()
    self:add_child(l)

    local hs = self.level:get_hero_spawner()
    if hs ~= nil then
        self.h:set_pos_grid(hs.cx, hs.cy)
    end

    gd.set_offscreen_clear_color(gd_instance, 73/256, 77/256, 126/256, 1)
    gd.set_offscreen_clear_color(gd_instance, 242/256, 211/256, 171/256, 1)

    self.debugGui = DebugGui()

    self.default_font = ttfont.from_file(assets_dir .. "data/font/default.ttf", 8, shader.defaultShader());

    self.camera = GameCamera()
    self:add_child(self.camera)
    --self.camera:track_entity(self.h)
    --self.camera:center_on_target()

    self:spawn_cats(3)

    self.gui = Gui()
    print(self.gui)
    self:add_child(self.gui)

    self.day_cycle = DayCycle()
    self:add_child(self.day_cycle)

    self:reset()

    self.time_system = TimeSystem()
    self:add_child(self.time_system)
    self.time_system:set_on_turn_end(self.on_turn_end, self)

    self:add_initial_cards()
    self:add_initial_buildings()
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

    if input.is_key_pressed(input_mgr, key.KEY_2) then
        self:pause()
    end

    if input.is_key_pressed(input_mgr, key.KEY_3) then
        self:resume()
    end

    if input.is_key_pressed(input_mgr, key.KEY_4) then
        for _, b in pairs(G.go.buildings) do
            b:hurt(3)
        end
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

    if self:is_game_over() then
        self:update_high_score()
        local game_over = self.game_over_type()
        game_over:init(self.shader)
        scene = game_over
        G.game = nil
        self:on_destroy()
        return
    end
end

function Game:get_on_screen_entities()
    local entities = {}

    local l = self.camera:get_left() - const.GRID * 4
    local b = self.camera:get_bottom() - const.GRID * 4
    local r = self.camera:get_right() + const.GRID * 4
    local t = self.camera:get_top() + const.GRID * 4

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
    if self.default_font ~= nil then
        ttfont.destroy(self.default_font)
        self.default_font = nil
    end
end

function Game:spawn_cats(num)
    for i = 1, num do
        local sp = self.level:get_cat_spawner()
        if sp ~= nil then
            local c = Cat()
            c:set_pos_grid(sp.cx, sp.cy)
        end
    end
end

function Game:add_initial_cards()
    for i = 1, G.player.num_initial_cards do
        local card = Card.random_card()
        card:set_pos_grid((i)*4, 1)
    end
end

function Game:add_initial_buildings()
    local house = Building()
    house:set_pos_grid(6, 10)
end

function Game:add_building(building_type, level)
    local b = Building()
    b.building_type = building_type
    b.level = level
    b.health = level
    b:set_pos_grid(5 + #G.go.buildings, 10)
end

function Game:reposition_buildings()
    for i, b in pairs(G.go.buildings) do
        b:set_pos_grid(5 + i, 10)
    end
end

function Game:upgrade_random_building(levels)
    -- find buildings with less than the max level, if any
    local available = {}
    for _, b in pairs(G.go.buildings) do
        if b.level < G.player.max_building_level then
            available[#available+1] = b
        end
    end
    local b
    if #available > 0 then
        b = lume.randomchoice(available)
    else
        b = lume.randomchoice(G.go.buildings)
    end
    b.level = b.level + levels
    if b.level > G.player.max_building_level then
        b.level = G.player.max_building_level
    end
    b.health = b.level
    print("upgrading building " .. tostring(b) .. " to level " .. tostring(b.level))
end

function Game:on_turn_end()
    self:draw_new_cards()
    self:apply_disaster()
    self:refill_energy()
end

function Game:draw_new_cards()
    local cards_to_draw = G.player.max_cards - #G.go.cards
    if cards_to_draw == 0 then
        return
    end
    for i = 1, cards_to_draw do
        Card.random_card()
    end

    for i = 1, #G.go.cards do
        local card = G.go.cards[i]
        card:set_pos_grid((i)*4, 1)
    end
end

function Game:apply_disaster()
    local d = Disaster.random_disaster()
    d:apply()
    G.player.last_disaster_text = d.s
end

function Game:refill_energy()
    G.player.energy = G.player.starting_energy
end

function Game:is_game_over()
    return #G.go.buildings == 0 and G.player.elapsed_time > 0
end

function Game:update_high_score()
    if G.player.elapsed_time > G.player.high_score then
        G.player.high_score = G.player.elapsed_time
    end
end

function Game:reset()
    G.player.elapsed_time = 0
    G.player.energy = G.player.starting_energy
    for i = #G.go.buildings, 1, -1 do
        local b = G.go.buildings[i]
        b:kill()
        lume.remove(G.go.buildings, b)
    end
    for i = #G.go.cards, 1, -1 do
        local c = G.go.cards[i]
        c:kill()
        lume.remove(G.go.cards, c)
    end
    for i = #G.go.disasters, 1, -1 do
        local d = G.go.disasters[i]
        d:kill()
        lume.remove(G.go.disasters, c)
    end
end

return Game