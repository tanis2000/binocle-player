local intro = {}

intro.TEX_WIDTH = 1682
intro.TEX_HEIGHT = 479

function intro.init(shd)
    local assets_dir = sdl.assets_dir()
    local image_filename = assets_dir .. "img/binocle-logo-full.png"
    intro.img = image.load(image_filename)
    intro.tex = texture.from_image(intro.img)
    intro.mat = material.new()

    material.set_texture(intro.mat, intro.tex)
    material.set_shader(intro.mat, shd)
    intro.logo = sprite.from_material(intro.mat)
    intro.shader = shd

    intro.azure_color = color.new(191.0 / 255.0, 1.0, 1.0, 1.0)
    intro.white_color = color.new(1.0, 1.0, 1.0, 1.0)
    intro.black_color = color.new(0, 0, 0, 1.0)
end

function intro.on_update(dt)
    io.write("rt: " .. tostring(render_target) .. "\n")
    io.write("win: " .. tostring(win) .. "\n")

    -- set the render target we want to render to
    gd.set_render_target(render_target)

    -- clear it
    window.clear(win)

    -- By default we scale our logo by 1/3
    scale = lkazmath.kmVec2New();
    scale.x = DESIGN_WIDTH / intro.TEX_WIDTH
    scale.y = DESIGN_HEIGHT / intro.TEX_WIDTH

    -- Create a viewport that corresponds to the size of our render target
    center = lkazmath.kmVec2New();
    center.x = DESIGN_WIDTH / 2;
    center.y = DESIGN_HEIGHT / 2;
    viewport = lkazmath.kmAABB2New();
    lkazmath.kmAABB2Initialize(viewport, center, DESIGN_WIDTH, DESIGN_HEIGHT, 0)

    -- A simple identity matrix
    identity_matrix = lkazmath.kmMat4New()
    lkazmath.kmMat4Identity(identity_matrix)
    --[[
    // Center the logo in the render target
    uint64_t x = (uint64_t)((DESIGN_WIDTH - (sprite->material->albedo_texture->width * scale.x)) / 2.0f);
    uint64_t y = (uint64_t)((DESIGN_HEIGHT - (sprite->material->albedo_texture->height * scale.x)) / 2.0f);
    ]]
    x = (DESIGN_WIDTH - (intro.TEX_WIDTH * scale.x)) / 2.0
    y = (DESIGN_HEIGHT - (intro.TEX_HEIGHT * scale.y)) / 2.0

    io.write("x: " .. tostring(x) .. " y: " .. tostring(y) .. "\n")
    sprite.draw(intro.logo, gdc, x, y, viewport, 0, scale, camera)

    -- Gets the viewport calculated by the adapter
    vp = viewport_adapter.get_viewport(adapter)
    io.write("vp: " .. tostring(vp) .. "\n")
    vp_x = viewport_adapter.get_viewport_min_x(adapter)
    vp_y = viewport_adapter.get_viewport_min_y(adapter)
    io.write("vp_x: " .. tostring(vp_x) .. "\n")
    io.write("vp_y: " .. tostring(vp_y) .. "\n")
    -- Reset the render target to the screen
    gd.set_render_target(nil);
    gd.clear(intro.black_color)
    gd.apply_viewport(vp);
    gd.apply_shader(gdc, screen_shader);
    gd.set_uniform_float2(screen_shader, "resolution", DESIGN_WIDTH, DESIGN_HEIGHT);
    gd.set_uniform_mat4(screen_shader, "transform", identity_matrix);
    gd.set_uniform_float2(screen_shader, "scale", inverse_multiplier, inverse_multiplier);
    gd.set_uniform_float2(screen_shader, "viewport", vp_x, vp_y);
    gd.draw_quad_to_screen(screen_shader, render_target);

    if input.is_key_pressed(input_mgr, key.KEY_SPACE) then
        io.write("game: " .. tostring(game) .. "\n")
        game.init(intro.shader)
        scene = game
    end
end

return intro