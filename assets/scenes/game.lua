local entity = require("entity")
local hero = require("en/hero")
local mob = require("en/mob")
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

    game.h = hero:new()
    game.h.sprite = game.player

    local m = mob:new()
    m.sprite = game.player

    local l = require("level")
    game.level = l:new()
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
        log.info("cd: " .. tostring(self.cd:get("test")))
    end
    --[[
    if input.is_key_pressed(input_mgr, key.KEY_RIGHT) then
        game.player_x = game.player_x + 100 * dt
    elseif input.is_key_pressed(input_mgr, key.KEY_LEFT) then
        game.player_x = game.player_x - 100 * dt
    end

    if input.is_key_pressed(input_mgr, key.KEY_UP) then
        game.player_y = game.player_y + 100 * dt
    elseif input.is_key_pressed(input_mgr, key.KEY_DOWN) then
        game.player_y = game.player_y - 100 * dt
    end
    ]]

    game.level:update(dt)

    game.h:pre_update()
    game.h:update(dt)
    game.h:post_update()
    --sprite.draw(game.player, gd_instance, game.player_x, game.player_y, viewport, 0, game.scale, camera)
    sprite.draw(game.h.sprite, gd_instance, game.h.sprite_x, game.h.sprite_y, viewport, 0, game.scale, cam)

    for idx in pairs(G.mobs) do
        m = G.mobs[idx]
        m:pre_update()
        m:update(dt)
        m:post_update()
        sprite.draw(m.sprite, gd_instance, m.sprite_x, m.sprite_y, viewport, 0, game.scale, cam)
    end

end

return game