local assets_dir = sdl.assets_dir()
log.info(assets_dir .. "\n")
package.path = package.path .. ";" .. assets_dir .."?.lua" .. ";?/init.lua"

-- Imports
-- ffi can only be used with luajit (hence on desktop only, no wasm or mobile)
--local ffi = require("ffi")
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

-- Globals
log.info("Begin of main.lua\n");

log.debug("test entitiy: " .. entity.test_entity .. "\n")
entity.say_test()

local image_filename = assets_dir .. "wabbit_alpha.png"
local img = image.load(image_filename)
io.write("image: " .. tostring(img) .. "\n")
local tex = texture.from_image(img)
io.write("tex: " .. tostring(tex) .. "\n")

local shd = shader.load_from_file(assets_dir .. "default.vert", assets_dir .. "default.frag")
io.write("shader: " .. tostring(shd) .. "\n")
local mat = material.new()

material.set_texture(mat, tex)
material.set_shader(mat, shd)
io.write("material: " .. tostring(mat) .. "\n")

local player = sprite.from_material(mat)
if player == nil or player == nullptr then
    io.write("player is nil")
else
    io.write("player: " .. tostring(player) .. "\n")
end

local player_x = 100
local player_y = 100

local scale = lkazmath.kmVec2New()
--ffi.new("kmVec2")

scale.x = 1.0
scale.y = 1.0
io.write("scale: " .. tostring(scale) .. "\n")
io.write("scale.x: " .. tostring(scale.x) .. "\n")
io.write("scale.y: " .. tostring(scale.y) .. "\n")

io.write("gd: " .. tostring(gd) .. "\n")
io.write("viewport: " .. tostring(viewport) .. "\n")
io.write("camera: " .. tostring(camera) .. "\n")

function on_update(dt)
    --[[
    io.write(dt)
    io.write("player: " .. tostring(player) .. "\n")
    io.write("gd: " .. tostring(gd) .. "\n")
    io.write("viewport: " .. tostring(viewport) .. "\n")
    io.write("scale: " .. tostring(scale) .. "\n")
    io.write("camera: " .. tostring(camera) .. "\n")
    ]]
    --io.write(tostring(scale.y))

    if input.is_key_pressed(input_mgr, key.KEY_RIGHT) then
        player_x = player_x + 100 * dt
    elseif input.is_key_pressed(input_mgr, key.KEY_LEFT) then
        player_x = player_x - 100 * dt
    end

    if input.is_key_pressed(input_mgr, key.KEY_UP) then
        player_y = player_y + 100 * dt
    elseif input.is_key_pressed(input_mgr, key.KEY_DOWN) then
        player_y = player_y - 100 * dt
    end

    sprite.draw(player, gd, player_x, player_y, viewport, 0, scale, camera)
end

io.write("End of main.lua\n");