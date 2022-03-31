local Entity = require("entity")
local Hero = require("en/hero")
local Mob = require("en/mob")
local Enemy = require("en/enemy")
local Process = require("process")
local DebugGui = require("debuggui")
local GameCamera = require("gamecamera")

local Game = Process:extend()

function Game:new(shd)
    Game.super.new(self)
    self.name = "game"
    self.shader = shd
    local assets_dir = sdl.assets_dir()
    local image_filename = assets_dir .. "wabbit_alpha.png"
    self.img = image.load(image_filename)
    io.write("image: " .. tostring(self.img) .. "\n")
    self.tex = texture.from_image(self.img)
    io.write("tex: " .. tostring(self.tex) .. "\n")
    self.mat = material.new()

    material.set_texture(self.mat, self.tex)
    material.set_shader(self.mat, shd)
    io.write("material: " .. tostring(self.mat) .. "\n")
    self.player = sprite.from_material(self.mat)

    if self.player == nil or self.player == nullptr then
        io.write("player is nil")
    else
        io.write("player: " .. tostring(self.player) .. "\n")
    end

    self.h = Hero()
    self.h:set_pos_grid(10, 5)
    --game.h.sprite = game.player

    local enemy = Enemy()
    enemy:set_pos_grid(13, 5)

    --local m = Mob()
    --m.sprite = self.player

    local l = require("level")
    self.level = l:new()
    self:add_child(l)
    gd.set_offscreen_clear_color(gd_instance, 0, 0, 0, 1)

    self.debugGui = DebugGui()

    self.default_font = ttfont.from_file(assets_dir .. "font/default.ttf", 8, shader.defaultShader());

    self.camera = GameCamera()
    self:add_child(self.camera)
    self.camera:track_entity(self.h)

    -- TODO remove this stuff when we get rid of the old mob
    self.player_x = 100
    self.player_y = 100

    self.scale = lkazmath.kmVec2New()

    self.scale.x = 1.0
    self.scale.y = 1.0
    -- TODO end of removal
end

function Game:pre_update(dt)
    Game.super.pre_update(self, dt)

    for idx in pairs(G.entities) do
        en = G.entities[idx]
        en:pre_update(dt)
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
        en:update(dt)
    end

    --for idx in pairs(G.bullets) do
    --    b = G.bullets[idx]
    --    b:pre_update(dt)
    --    b:update(dt)
    --end

    self.debugGui:update(dt)
end

function Game:post_update(dt)
    Game.super.post_update(self, dt)

    for _, en in pairs(self:get_on_screen_entities()) do
        en:post_update(dt)
        en:draw()
        en:draw_debug()
        --sprite.draw(m.sprite, gd_instance, m.sprite_x, m.sprite_y, viewport, 0, self.scale, cam)
    end

    --for _, b in pairs(G.bullets) do
    --    b:post_update(dt)
    --    b:draw()
    --    b:draw_debug()
    --end

    --self.h:post_update(dt)
    --self.h:draw()
    --self.h:draw_debug()

    self:garbage_collect()
end

function Game:get_on_screen_entities()
    local entities = {}

    for _, en in pairs(G.entities) do
        table.insert(entities, en)
    end

    table.sort(entities, function(en1, en2)
        return en1.depth < en2.depth
    end)

    return entities
end


function Game:garbage_collect()
    for idx in pairs(G.entities) do
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

return Game