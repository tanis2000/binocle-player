local assets_dir = sdl.assets_dir()
package.path = package.path .. ";" .. assets_dir .."?.lua" .. ";?/init.lua"

local traceback = debug.traceback

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

function on_update(dt)
    xpcall(function() return on_update_main(dt) end, on_error)
end

xpcall(function() require "main" end, on_error)