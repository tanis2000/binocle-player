local const = require("const")
local entity = require("entity")
local Intro = require("scenes/intro")
local cache  = require("cache")

-- Initialize the LuaPanda debugger (we use a custom version)
require("LuaPanda").start("127.0.0.1", 8818);

main = {}

---@type table
---Global state
G = {
    profiling = {
        enabled = false,
        profiler = 'lua-profiler', -- can be 'profiler' or 'lua-profiler'
    },
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
    colorize_shader = nil,
    grass_shader = nil,
    using_game_gui = false,
    player_name = "",
    preferences_dir = "",
    save_filename = "save.txt",
}

log.info("Checking is LUAJIT is available")
if jit ~= nil then
    log.info("LUAJIT is available")
    log.info("LUAJIT version " .. jit.version)
    log.info("LUAJIT engine status is " .. tostring(jit.status()))

    if G.profiling.enabled then
        if G.profiling.profiler == 'lua-profiler' then
            prof = require("lib.lua-profiler")
            local overrides = {
                fW = 99, -- Change the file column to 100 characters (from 20)
                fnW = 99, -- Change the function column to 120 characters (from 28)
            }
            prof.configuration(overrides)
            prof.start()
        else
            prof = require("lib.profiler")
            prof.start("f10sp")
        end
    end
end

local assets_dir = sdl.assets_dir()
log.info(assets_dir .. "\n")

log.info("Begin of main.lua\n");

-- Global constants
color.azure = color.new(192.0 / 255.0, 1.0, 1.0, 1.0)
color.white = color.new(1.0, 1.0, 1.0, 1.0)
color.black = color.new(0, 0, 0, 1.0)
color.debug_bounds = color.new(0, 1, 0, 0.2)
color.debug_origin = color.new(0, 1, 0, 0.7)

local quit_requests = 0
---@class Intro
local intro

function on_init()
    ---@type Window
    win = window.new(const.DESIGN_WIDTH * const.SCALE, const.DESIGN_HEIGHT * const.SCALE, G.title)
    log.info("win: " .. tostring(win))
    local bg_color = color.black
    log.info("bg_color: " .. tostring(bg_color))
    window.set_background_color(win, bg_color)
    window.set_minimum_size(win, const.DESIGN_WIDTH, const.DESIGN_HEIGHT)

    input_mgr = input.new()
    log.info("input_mgr: " .. tostring(input_mgr))

    adapter = viewport_adapter.new(win, "scaling", "pixel_perfect",
        const.DESIGN_WIDTH, const.DESIGN_HEIGHT, const.DESIGN_WIDTH, const.DESIGN_HEIGHT);
    log.info("adapter: " .. tostring(adapter))

    cam = camera.new(adapter)
    log.info("cam: " .. tostring(cam))

    --default_shader = shader.load_from_file(assets_dir .. "shaders/default_vert.glsl",
    --    assets_dir .. "shaders/default_frag.glsl")
    --log.info("default shader: " .. tostring(default_shader))
    --
    --screen_shader = shader.load_from_file(assets_dir .. "shaders/screen_vert.glsl",
    --    assets_dir .. "shaders/screen_frag.glsl")
    --log.info("screen shader: " .. tostring(screen_shader))

    gd_instance = gd.new()
    gd.init(gd_instance, win)
    log.info("gd_instance: " .. tostring(gd_instance))

    -- BEGIN experimental code to setup a shader, pipeline and renderer
    local vs = fs.load_text_file("/assets/shaders/" .. app.shader_prefix() .. "/colorize_colorize" .. app.shader_vs_suffix());
    local frag = fs.load_text_file("/assets/shaders/" .. app.shader_prefix() .. "/colorize_colorize" .. app.shader_fs_suffix());
    local shader = gd.create_shader_desc("colorize", vs, frag)
    gd.add_uniform_to_shader_desc(shader, "FS", 0, "customColor", "vec4")
    gd.create_shader(shader)
    gd.create_pipeline(shader)
    G.colorize_shader = shader

    log.info("Creating grass shader and pipeline")
    vs = fs.load_text_file("/assets/shaders/" .. app.shader_prefix() .. "/grass_grass" .. app.shader_vs_suffix());
    frag = fs.load_text_file("/assets/shaders/" .. app.shader_prefix() .. "/grass_grass" .. app.shader_fs_suffix());
    local grass_shader = gd.create_shader_desc("grass", vs, frag)
    gd.add_uniform_to_shader_desc(grass_shader, "FS", 0, "time", "float")
    gd.add_uniform_to_shader_desc(grass_shader, "FS", 1, "verticalOffset", "float")
    gd.add_uniform_to_shader_desc(grass_shader, "FS", 2, "horizontalOffset", "float")
    gd.create_shader(grass_shader)
    gd.create_pipeline(grass_shader)
    G.grass_shader = grass_shader
    log.info("Done creating grass shader and pipeline")
    -- END experimental code to setup a shader, pipeline and renderer

    sb = sprite_batch.new()
    sprite_batch.set_gd(sb, gd_instance)
    log.info("sb: " .. tostring(sb))

    -- Create a viewport that corresponds to the size of our render target
    local center = lkazmath.kmVec2New();
    center.x = const.DESIGN_WIDTH / 2;
    center.y = const.DESIGN_HEIGHT / 2;
    viewport = lkazmath.kmAABB2New();
    lkazmath.kmAABB2Initialize(viewport, center, const.DESIGN_WIDTH, const.DESIGN_HEIGHT, 0)

    audio_instance = audio.new()
    audio.init(audio_instance)
    log.info("audio_instance: " .. tostring(audio_instance))

    local music = audio.load_music(audio_instance, assets_dir .. "data/music/theme.mp3")
    G.musics["main"] = music
    audio.play_music(audio_instance, music)
    audio.set_music_volume(audio_instance, G.musics["main"], 0)
    --audio.set_music_volume(audio_instance, G.musics["main"], 0.5)

    G.preferences_dir = sdl.preferences_dir("altralogica", "binocle-player")
    G.player_name = sdl.load_text_file(G.preferences_dir .. G.save_filename)
    if G.player_name == nil then
        G.player_name = ""
    end
end

function main.on_update(dt)
    --log.info("dt: " .. tostring(dt))
    if not scene then
        G.default_shader = shader.defaultShader()
    end
    sprite_batch.begin(sb, cam, G.default_shader, viewport, "BINOCLE_SPRITE_SORT_MODE_FRONT_TO_BACK")
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
    --log.info("scene: " .. tostring(scene.name))

    scene:pre_update(dt)

    if input.is_key_down(input_mgr, key.KEY_1) then
        G.debug = not G.debug
        log.info(tostring(G.debug))
    end

    if input.is_key_down(input_mgr, key.KEY_ESCAPE) then
        quit_requests = quit_requests + 1
        log.info(tostring(quit_requests))
        if quit_requests > 1 then
            input.set_quit_requested(input_mgr, true)
        end
    end

    scene:update(dt)

    scene:post_update(dt)
    for idx, music in pairs(G.musics) do
        audio.update_music_stream(audio_instance, music)
    end

    local screenViewport = viewport_adapter.get_viewport(adapter)
    gd.render_screen(gd_instance, win, const.DESIGN_WIDTH, const.DESIGN_HEIGHT, screenViewport, cam)
    if G.debug then
        imgui.SetContext("debug")
        imgui.RenderToScreen("debug", gd_instance, win, const.DESIGN_WIDTH, const.DESIGN_HEIGHT, screenViewport, cam, true)
    end
    if G.using_game_gui then
        imgui.SetContext("game")
        imgui.RenderToScreen("game", gd_instance, win, const.DESIGN_WIDTH, const.DESIGN_HEIGHT, screenViewport, cam, false)
    end

    sprite_batch.finish(sb, cam, viewport)
    --collectgarbage()
end

function on_destroy()
    if G.game ~= nil then
        G.game:on_destroy()
    end
    if scene ~= nil then
        scene:on_destroy()
    end
    if jit ~= nil then
        if G.profiling.enabled then
            if G.profiling.profiler == 'lua-profiler' then
                prof.stop()
                prof.report('profiler.log')
            else
                prof.stop()
            end
        end
    end
end

function load_sfx(name, filename)
    local sound = audio.load_sound(audio_instance, assets_dir .. filename)
    G.sounds[name] = sound
    audio.set_sound_volume(G.sounds[name], 1.0)
end

function get_window()
    log.info("get_window win: " .. tostring(win))
    return win
end

function get_adapter()
    log.info("get_adapter adapter: " .. tostring(adapter))
    return adapter
end

function get_camera()
    log.info("get_camera cam: " .. tostring(cam))
    return cam
end

function get_input_mgr()
    log.info("get_input_mgr input_mgr: " .. tostring(input_mgr))
    return input_mgr
end

function get_gd_instance()
    log.info("get_gd_instance gd: " .. tostring(gd_instance))
    return gd_instance
end

function get_sprite_batch_instance()
    log.info("get_sprite_batch_instance sb: " .. tostring(sb))
    return sb
end

function get_audio_instance()
    log.info("get_audio_instance audio_instance: " .. tostring(audio_instance))
    return audio_instance
end

function get_design_width()
    log.info("get_design_width: " .. tostring(const.DESIGN_WIDTH))
    return const.DESIGN_WIDTH
end

function get_design_height()
    log.info("get_design_height: " .. tostring(const.DESIGN_HEIGHT))
    return const.DESIGN_HEIGHT
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

log.info("End of main.lua")

