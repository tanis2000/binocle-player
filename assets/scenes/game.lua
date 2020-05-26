local game = {}

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

function game.on_update(dt)
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

    sprite.draw(game.player, gdc, game.player_x, game.player_y, viewport, 0, game.scale, camera)
end

return game