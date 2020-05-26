local assets_dir = sdl.assets_dir()
log.info(assets_dir .. "\n")
package.path = package.path .. ";" .. assets_dir .."?.lua" .. ";?/init.lua"

-- Imports
-- ffi can only be used with luajit (hence on desktop only, no wasm or mobile)
--local ffi = require("ffi")
const = require("const")
local entity = require("entity")

-- FFI definitions (try to avoid as much as possible)
--ffi.cdef[[
--
--typedef struct kmVec2 {
--    float x;
--    float y;
--} kmVec2;
--
--typedef struct kmAABB2 {
--    kmVec2 min; /** The max corner of the box */
--    kmVec2 max; /** The min corner of the box */
--} kmAABB2;
--
--]]

-- Constants
GL_RGBA8 = 0x8058
DESIGN_WIDTH = 504 --320
DESIGN_HEIGHT = 143 --240

-- Globals
log.info("Begin of main.lua\n");

log.debug("test entitiy: " .. entity.test_entity .. "\n")
entity.say_test()

function on_init()
    win = window.new(DESIGN_WIDTH, DESIGN_HEIGHT, "Binocle Player")
    io.write("win: " .. tostring(win) .."\n")
    bg_color = color.new(1.0, 0.0, 0.0, 1.0)
    io.write("bg_color: " .. tostring(bg_color) .."\n")
    window.set_background_color(win, bg_color)
    window.set_minimum_size(win, DESIGN_WIDTH, DESIGN_HEIGHT)

    adapter = viewport_adapter.new(win, "scaling", "pixel_perfect", DESIGN_WIDTH, DESIGN_HEIGHT, DESIGN_WIDTH, DESIGN_HEIGHT);
    io.write("adapter: " .. tostring(adapter) .."\n")

    local shd = shader.load_from_file(assets_dir .. "shaders/default_vert.glsl", assets_dir .. "shaders/default_frag.glsl")
    io.write("default shader: " .. tostring(shd) .. "\n")

    screen_shader = shader.load_from_file(assets_dir .. "shaders/screen_vert.glsl", assets_dir .. "shaders/screen_frag.glsl")
    io.write("screen shader: " .. tostring(screen_shader) .. "\n")

    render_target = gd.create_render_target(DESIGN_WIDTH, DESIGN_HEIGHT, true, GL_RGBA8)
    io.write("render_target: " .. tostring(render_target) .. "\n")

    local intro = require("scenes/intro")
    game = require("scenes/game")

    intro.init(shd)

    scene = intro
end

function on_update(dt)
    scene.on_update(dt)

    --[[
    io.write(dt)
    io.write("player: " .. tostring(player) .. "\n")
    io.write("gdc: " .. tostring(gdc) .. "\n")
    io.write("viewport: " .. tostring(viewport) .. "\n")
    io.write("scale: " .. tostring(scale) .. "\n")
    io.write("camera: " .. tostring(camera) .. "\n")
    ]]
    --io.write(tostring(scale.y))
end

function get_window()
    io.write("get_window win: " .. tostring(win) .."\n")
    return win
end

function get_adapter()
    io.write("get_adapter adapter: " .. tostring(adapter) .."\n")
    return adapter
end


io.write("End of main.lua\n");