local const = require("const")
local entity = require("entity")
local Intro = require("scenes/intro")
local cache  = require("cache")

main = {}

---@type table
---Global state
G = {
    cache = cache,
    default_shader = nil,
    game = nil,
    entities = {}, -- all entities
    mobs = {}, -- all mobs
    cats = {}, -- all cats
    bullets = {}, -- all bullets
    title = "Binocle Player",
    musics = {},
    sounds = {},
    debug = false,
    ---@type Level
    level = nil,
}
local assets_dir = sdl.assets_dir()
log.info(assets_dir .. "\n")

log.info("Begin of main.lua\n");

-- Global constants
color.azure = color.new(192.0 / 255.0, 1.0, 1.0, 1.0)
color.white = color.new(1.0, 1.0, 1.0, 1.0)
color.black = color.new(0, 0, 0, 1.0)
color.trans_green = color.new(0, 1, 0, 0.5)

local quit_requests = 0
---@class Intro
local intro

function on_init()
    ---@type Window
    win = window.new(const.DESIGN_WIDTH * const.SCALE, const.DESIGN_HEIGHT * const.SCALE, G.title)
    io.write("win: " .. tostring(win) .."\n")
    local bg_color = color.black
    io.write("bg_color: " .. tostring(bg_color) .."\n")
    window.set_background_color(win, bg_color)
    window.set_minimum_size(win, const.DESIGN_WIDTH, const.DESIGN_HEIGHT)

    input_mgr = input.new()
    io.write("input_mgr: " .. tostring(input_mgr) .."\n")

    adapter = viewport_adapter.new(win, "scaling", "pixel_perfect",
        const.DESIGN_WIDTH, const.DESIGN_HEIGHT, const.DESIGN_WIDTH, const.DESIGN_HEIGHT);
    io.write("adapter: " .. tostring(adapter) .."\n")

    cam = camera.new(adapter)
    io.write("cam: " .. tostring(cam) .."\n")

    --default_shader = shader.load_from_file(assets_dir .. "shaders/default_vert.glsl",
    --    assets_dir .. "shaders/default_frag.glsl")
    --io.write("default shader: " .. tostring(default_shader) .. "\n")
    --
    --screen_shader = shader.load_from_file(assets_dir .. "shaders/screen_vert.glsl",
    --    assets_dir .. "shaders/screen_frag.glsl")
    --io.write("screen shader: " .. tostring(screen_shader) .. "\n")

    gd_instance = gd.new()
    gd.init(gd_instance, win)
    io.write("gd_instance: " .. tostring(gd_instance) .. "\n")

    sb = sprite_batch.new()
    sprite_batch.set_gd(sb, gd_instance)
    io.write("sb: " .. tostring(sb) .. "\n")

    -- Create a viewport that corresponds to the size of our render target
    center = lkazmath.kmVec2New();
    center.x = const.DESIGN_WIDTH / 2;
    center.y = const.DESIGN_HEIGHT / 2;
    viewport = lkazmath.kmAABB2New();
    lkazmath.kmAABB2Initialize(viewport, center, const.DESIGN_WIDTH, const.DESIGN_HEIGHT, 0)

    audio_instance = audio.new()
    audio.init(audio_instance)
    io.write("audio_instance: " .. tostring(audio_instance) .. "\n")

    local music = audio.load_music(audio_instance, assets_dir .. "data/music/theme.mp3")
    G.musics["main"] = music
    audio.play_music(audio_instance, music)
    audio.set_music_volume(audio_instance, G.musics["main"], 0.5)
end

function main.on_update(dt)
    --io.write("dt: " .. tostring(dt) .. "\n")
    if not scene then
        G.default_shader = shader.defaultShader()
    end
    sprite_batch.begin(sb, cam, G.default_shader)
    if not scene then
        load_sfx("jump", "data/sfx/jump.wav")
        load_sfx("hurt", "data/sfx/hurt.wav")
        load_sfx("shoot", "data/sfx/shoot.wav")
        load_sfx("purr", "data/sfx/purr.wav")
        load_sfx("meow", "data/sfx/meow.mp3")
        load_sfx("pickup", "data/sfx/pickup.wav")
        load_sfx("powerup", "data/sfx/powerup.wav")

        intro = Intro()
        intro:init(G.default_shader)

        scene = intro
        --return
    end
    --io.write("scene: " .. tostring(scene.name) .. "\n")

    scene:pre_update(dt)

    if input.is_key_down(input_mgr, key.KEY_1) then
        G.debug = not G.debug
        print(G.debug)
    end

    if input.is_key_down(input_mgr, key.KEY_ESCAPE) then
        quit_requests = quit_requests + 1
        print(quit_requests)
        if quit_requests > 1 then
            input.set_quit_requested(input_mgr, true)
        end
    end

    scene:update(dt)

    scene:post_update(dt)
    for idx, music in pairs(G.musics) do
        audio.update_music_stream(audio_instance, music)
    end

    gd.render_screen(gd_instance, win, const.DESIGN_WIDTH, const.DESIGN_HEIGHT, viewport, cam)
    if G.debug then
        imgui.RenderToScreen(gd_instance, win, viewport, cam)
    end

    sprite_batch.finish(sb, cam)
    --collectgarbage()
end

function on_destroy()
    if G.game ~= nil then
        G.game:on_destroy()
    end
    if scene ~= nil then
        scene:on_destroy()
    end
end

function load_sfx(name, filename)
    local sound = audio.load_sound(audio_instance, assets_dir .. filename)
    G.sounds[name] = sound
    audio.set_sound_volume(G.sounds[name], 1.0)
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

function get_gd_instance()
    io.write("get_gd_instance gd: " .. tostring(gd_instance) .."\n")
    return gd_instance
end

function get_sprite_batch_instance()
    io.write("get_sprite_batch_instance sb: " .. tostring(sb) .."\n")
    return sb
end

function get_audio_instance()
    io.write("get_audio_instance audio_instance: " .. tostring(audio_instance) .."\n")
    return audio_instance
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

