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
    -- input management
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

    -- set the render target we want to render to
    gd.set_render_target(render_target)

    -- clear it
    window.clear(win)

    sprite.draw(game.player, gdc, game.player_x, game.player_y, viewport, 0, game.scale, camera)

    -- Gets the viewport calculated by the adapter
    vp = viewport_adapter.get_viewport(adapter)
    vp_x = viewport_adapter.get_viewport_min_x(adapter)
    vp_y = viewport_adapter.get_viewport_min_y(adapter)

    -- Reset the render target to the screen
    gd.set_render_target(nil);

    -- clear the screen to black
    gd.clear(color.black)
    gd.apply_viewport(vp);
    gd.apply_shader(gdc, screen_shader);
    gd.set_uniform_float2(screen_shader, "resolution", DESIGN_WIDTH, DESIGN_HEIGHT);
    gd.set_uniform_mat4(screen_shader, "transform", identity_matrix);
    gd.set_uniform_float2(screen_shader, "scale", inverse_multiplier, inverse_multiplier);
    gd.set_uniform_float2(screen_shader, "viewport", vp_x, vp_y);
    gd.draw_quad_to_screen(screen_shader, render_target);

end

return game