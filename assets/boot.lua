local assets_dir = sdl.assets_dir()
package.path = package.path .. ";" .. assets_dir .."?.lua" .. ";?/init.lua"

local traceback = debug.traceback
local delta_time = 0

local function on_error(msg)
    print("msg: " .. msg .. "\n" .. traceback())
    input.set_quit_requested(input_mgr, true)
end

local function call(fn, ...)
    if fn then return fn(...) end
end

local function on_update_main(dt)
    call(main.on_update, dt)
end

local function on_update_main_fn()
    return on_update_main(delta_time)
end

function on_update(dt)
    delta_time = dt
    xpcall(on_update_main_fn, on_error)
end


xpcall(function() require "main" end, on_error)