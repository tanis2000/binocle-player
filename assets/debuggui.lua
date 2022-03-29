local Object = require("lib.classic")
local DebugGui = Object:extend();

function DebugGui:draw(dt)
    imgui.NewFrame(win, dt)
    if imgui.Begin("Test") then
        imgui.TextUnformatted("Memory:   " .. string.format("%.2fmb", collectgarbage("count")/1024))
        imgui.TextUnformatted("Mobs:     " .. #G.mobs)
        imgui.TextUnformatted("Bullets:  " .. #G.mobs)
        imgui.TextUnformatted("Entities: " .. #G.entities)
    end
    imgui.End()

    if imgui.Begin("Entities") then
        for _, en in pairs(G.entities) do
            imgui.TextUnformatted("Name: " .. en.name)
        end
    end
    imgui.End()
    imgui.Render()
end
function DebugGui:update(dt)
    if dt <= 0 then
        return
    end
    self:draw(dt)
end

return DebugGui