local process = require("process")
local intro = process:new()

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

function intro:update(dt)
    -- By default we scale our logo by 1/3
    scale = lkazmath.kmVec2New();
    scale.x = DESIGN_WIDTH / intro.TEX_WIDTH
    scale.y = DESIGN_HEIGHT / intro.TEX_WIDTH

    -- Center the logo in the render target
    x = (DESIGN_WIDTH - (intro.TEX_WIDTH * scale.x)) / 2.0
    y = (DESIGN_HEIGHT - (intro.TEX_HEIGHT * scale.y)) / 2.0

    io.write("x: " .. tostring(x) .. " y: " .. tostring(y) .. "\n")
    sprite.draw(intro.logo, gdc, x, y, viewport, 0, scale, cam)

    if input.is_key_pressed(input_mgr, key.KEY_SPACE) then
        local game = require("scenes/game")
        io.write("game: " .. tostring(game) .. "\n")
        game.init(intro.shader)
        scene = game
    end
end

return intro