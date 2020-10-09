main = {}
G = {
    all = {}, -- all entities
    mobs = {}, -- all mobs
}
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
DESIGN_WIDTH = 320
DESIGN_HEIGHT = 240

-- Globals
log.info("Begin of main.lua\n");

color.azure = color.new(192.0 / 255.0, 1.0, 1.0, 1.0)
color.white = color.new(1.0, 1.0, 1.0, 1.0)
color.black = color.new(0, 0, 0, 1.0)

function on_init()
    win = window.new(DESIGN_WIDTH, DESIGN_HEIGHT, "Binocle Player")
    io.write("win: " .. tostring(win) .."\n")
    bg_color = color.black
    io.write("bg_color: " .. tostring(bg_color) .."\n")
    window.set_background_color(win, bg_color)
    window.set_minimum_size(win, DESIGN_WIDTH, DESIGN_HEIGHT)

    input_mgr = input.new()

    adapter = viewport_adapter.new(win, "scaling", "pixel_perfect",
        DESIGN_WIDTH, DESIGN_HEIGHT, DESIGN_WIDTH, DESIGN_HEIGHT);
    io.write("adapter: " .. tostring(adapter) .."\n")

    cam = camera.new(adapter)
    io.write("cam: " .. tostring(cam) .."\n")

    default_shader = shader.load_from_file(assets_dir .. "shaders/default_vert.glsl",
        assets_dir .. "shaders/default_frag.glsl")
    io.write("default shader: " .. tostring(default_shader) .. "\n")

    screen_shader = shader.load_from_file(assets_dir .. "shaders/screen_vert.glsl",
        assets_dir .. "shaders/screen_frag.glsl")
    io.write("screen shader: " .. tostring(screen_shader) .. "\n")

    render_target = gd.create_render_target(DESIGN_WIDTH, DESIGN_HEIGHT, true, GL_RGBA8)
    io.write("render_target: " .. tostring(render_target) .. "\n")

    local intro = require("scenes/intro")
    io.write("intro: " .. tostring(intro) .."\n")

    intro.init(default_shader)

    scene = intro

end

function main.on_update(dt)
    io.write("dt: " .. tostring(dt) .. "\n")
    if not scene then
        log.error("no scene to run")
        return
    end
    io.write("scene: " .. tostring(scene.name) .. "\n")

    scene:pre_update(dt)

    -- set the render target we want to render to
    gd.set_render_target(render_target)

    -- clear it
    window.clear(win)

    -- Create a viewport that corresponds to the size of our render target
    center = lkazmath.kmVec2New();
    center.x = DESIGN_WIDTH / 2;
    center.y = DESIGN_HEIGHT / 2;
    viewport = lkazmath.kmAABB2New();
    lkazmath.kmAABB2Initialize(viewport, center, DESIGN_WIDTH, DESIGN_HEIGHT, 0)

    -- A simple identity matrix
    identity_matrix = lkazmath.kmMat4New()
    lkazmath.kmMat4Identity(identity_matrix)

    scene:update(dt)

    -- Gets the viewport calculated by the adapter
    vp = viewport_adapter.get_viewport(adapter)
    io.write("vp: " .. tostring(vp) .. "\n")
    vp_x = viewport_adapter.get_viewport_min_x(adapter)
    vp_y = viewport_adapter.get_viewport_min_y(adapter)
    io.write("vp_x: " .. tostring(vp_x) .. "\n")
    io.write("vp_y: " .. tostring(vp_y) .. "\n")
    -- Reset the render target to the screen
    gd.set_render_target(nil);
    gd.clear(color.black)
    gd.apply_viewport(vp);
    gd.apply_shader(gdc, screen_shader);
    gd.set_uniform_float2(screen_shader, "resolution", DESIGN_WIDTH, DESIGN_HEIGHT);
    gd.set_uniform_mat4(screen_shader, "transform", identity_matrix);
    gd.set_uniform_float2(screen_shader, "scale", inverse_multiplier, inverse_multiplier);
    gd.set_uniform_float2(screen_shader, "viewport", vp_x, vp_y);
    gd.draw_quad_to_screen(screen_shader, render_target);

    scene:post_update(dt)

end

function get_window()
    io.write("get_window win: " .. tostring(win) .."\n")
    return win
end

function get_adapter()
    io.write("get_adapter adapter: " .. tostring(adapter) .."\n")
    return adapter
end

function get_camera()
    io.write("get_camera cam: " .. tostring(cam) .."\n")
    return cam
end

function get_input_mgr()
    io.write("get_input_mgr input_mgr: " .. tostring(input_mgr) .."\n")
    return input_mgr
end

function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

io.write("End of main.lua\n")

