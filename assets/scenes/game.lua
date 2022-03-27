local Entity = require("entity")
local Hero = require("en/hero")
local Mob = require("en/mob")
local Enemy = require("en/enemy")
local process = require("process")

local game = process:new()

function game.init(shd)
    game.shader = shd
    local assets_dir = sdl.assets_dir()
    local image_filename = assets_dir .. "wabbit_alpha.png"
    game.img = image.load(image_filename)
    io.write("image: " .. tostring(game.img) .. "\n")
    game.tex = texture.from_image(game.img)
    io.write("tex: " .. tostring(game.tex) .. "\n")
    game.mat = material.new()

    material.set_texture(game.mat, game.tex)
    material.set_shader(game.mat, shd)
    io.write("material: " .. tostring(game.mat) .. "\n")
    game.player = sprite.from_material(game.mat)

    if game.player == nil or game.player == nullptr then
        io.write("player is nil")
    else
        io.write("player: " .. tostring(game.player) .. "\n")
    end

    game.h = Hero()
    game.h:set_pos_grid(10, 5)
    --game.h.sprite = game.player

    local enemy = Enemy()
    enemy:set_pos_grid(13, 5)

    local m = Mob()
    m.sprite = game.player

    local l = require("level")
    game.level = l:new()
    gd.set_offscreen_clear_color(gd_instance, 0, 0, 0, 1)
end


game.player_x = 100
game.player_y = 100

game.scale = lkazmath.kmVec2New()

game.scale.x = 1.0
game.scale.y = 1.0
io.write("scale: " .. tostring(game.scale) .. "\n")
io.write("scale.x: " .. tostring(game.scale.x) .. "\n")
io.write("scale.y: " .. tostring(game.scale.y) .. "\n")

io.write("gdc: " .. tostring(gdc) .. "\n")
io.write("viewport: " .. tostring(viewport) .. "\n")
io.write("camera: " .. tostring(camera) .. "\n")

function game:update(dt)
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


    game.level:update(dt)

    game.h:pre_update()
    game.h:update(dt)
    game.h:post_update()
    --sprite.draw(game.player, gd_instance, game.player_x, game.player_y, viewport, 0, game.scale, camera)
    --sprite.draw(game.h.sprite, gd_instance, game.h.sprite_x, game.h.sprite_y, viewport, 0, game.scale, cam)
    game.h:draw()
    game.h:draw_debug()

    for idx in pairs(G.mobs) do
        m = G.mobs[idx]
        m:pre_update()
        m:update(dt)
        m:post_update()
        m:draw()
        sprite.draw(m.sprite, gd_instance, m.sprite_x, m.sprite_y, viewport, 0, game.scale, cam)
    end

    for idx in pairs(G.bullets) do
        b = G.bullets[idx]
        b:pre_update()
        b:update(dt)
        b:post_update()
        b:draw()
        b:draw_debug()
    end

end

return game