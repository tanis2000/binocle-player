local Object = require("lib.classic")
local DebugGui = Object:extend();

function DebugGui:draw(dt)
    if not G.debug then
        return
    end

    imgui.SetContext("debug")
    imgui.NewFrame(win, dt)
    if imgui.Begin("Info") then
        imgui.TextUnformatted("Memory:   " .. string.format("%.2fmb", collectgarbage("count")/1024))
        imgui.TextUnformatted("Mobs:     " .. #G.mobs)
        imgui.TextUnformatted("Bullets:  " .. #G.mobs)
        imgui.TextUnformatted("Entities: " .. #G.entities)
        local cam_x, cam_y = camera.get_position(cam)
        local cam_fx = G.game.camera.raw_focus:get_level_x()
        local cam_fy = G.game.camera.raw_focus:get_level_y()
        local cam_cx = G.game.camera.clamped_focus:get_level_x()
        local cam_cy = G.game.camera.clamped_focus:get_level_y()
        imgui.TextUnformatted("Camera:   " .. string.format("cam_pos: %.2f,%.2f - raw focus: %.2f,%.2f - clamped focus: %.2f,%.2f", cam_x, cam_y, cam_fx, cam_fy, cam_cx, cam_cy))
    end
    imgui.End()

    if imgui.Begin("Entities") then
        imgui.BeginChild("Entities")
        for _, en in pairs(G.entities) do
            if imgui.TreeNode(en.name) then
                self:entity(en)
                imgui.TreePop()
            end
        end
        imgui.EndChild()
    end
    imgui.End()

    if imgui.Begin("Waves") then
        imgui.BeginChild("Waves")
        local ws = G.game.wave_system
        imgui.TextUnformatted(string.format("Current wave: %d", ws.current_wave_idx))
        if ws.current_wave then
            imgui.TextUnformatted(string.format("Spawned: %d", ws.current_wave_num_spawned))
            imgui.TextUnformatted(string.format("Running: %s", tostring(ws.running)))
            imgui.TextUnformatted(string.format("Total mobs: %d", ws.current_wave.total_mobs))
            imgui.TextUnformatted(string.format("Max concurrent: %d", ws.current_wave.max_concurrent))
        end
        for i, wave in pairs(ws.waves) do
            if imgui.TreeNode(string.format("wave %d", i)) then
                self:wave(wave)
                imgui.TreePop()
            end
        end
        imgui.EndChild()
    end

    self:gamecamera()
    imgui.End()
    imgui.Render("debug")
end

function DebugGui:entity(en)
    imgui.TextUnformatted("Name: " .. en.name)
    imgui.TextUnformatted(string.format("W,H: %.2f,%.2f", en.wid, en.hei))
    imgui.TextUnformatted(string.format("Pixel position: %.2f,%.2f", en.sprite_x, en.sprite_y))
    imgui.TextUnformatted(string.format("Center: %.2f,%.2f", en:get_center_x(), en:get_center_y()))
    imgui.TextUnformatted(string.format("Left: %.2f, Right: %.2f, Top: %.2f, Bottom: %.2f", en:get_left(), en:get_right(), en:get_top(), en:get_bottom()))
    local cx = en.cx
    local res = false
    res, cx = imgui.DragFloat("cx", cx, 1, 0, 0, "%.2f", 1)
    if res then
        print(cx)
        en:set_pos_grid(cx, en.cy)
    end
    local cy = en.cy
    res, cy = imgui.DragFloat("cy", cy, 1, 0, 0, "%.2f", 1)
    if res then
        en:set_pos_grid(en.cx, cy)
    end
    local gravity = en.gravity
    res, gravity = imgui.DragFloat("gravity", gravity, 0.001, 0, 0, "%.3f", 1)
    if res then
        en.gravity = gravity
    end
end

function DebugGui:gamecamera()
    if imgui.Begin("GameCamera") then
        local x = G.game.camera.raw_focus:get_level_x()
        local res = false
        res, x = imgui.DragFloat("Raw Focus X", x, 1, 0, 0, "%.3f", 1)
        if res then
            G.game.camera.raw_focus:set_level_x(x)
        end

        local y = G.game.camera.raw_focus:get_level_y()
        res, y = imgui.DragFloat("Raw Focus Y", y, 1, 0, 0, "%.3f", 1)
        if res then
            G.game.camera.raw_focus:set_level_y(y)
        end

        local dx = G.game.camera.dx
        res, dx = imgui.DragFloat("dx", dx, 1, 0, 0, "%.3f", 1)
        if res then
            G.game.camera.dx = dx
        end

        local dy = G.game.camera.dy
        res, dy = imgui.DragFloat("dy", dy, 1, 0, 0, "%.3f", 1)
        if res then
            G.game.camera.dy = dy
        end

        local target = G.game.camera.target
        local target_name = ""
        if target ~= nil and target.name ~= nil then
            target_name = target.name
        end

        if imgui.BeginCombo("Target", target_name) then
            for k, v in pairs(G.entities) do
                local is_selected = false
                if target_name == v.name then
                    is_selected = true
                end
                if imgui.Selectable(v.name, is_selected) then
                    G.game.camera:track_entity(v)
                end

                if is_selected then
                    imgui.SetItemDefaultFocus()
                end
            end
            imgui.EndCombo()
        end

        if imgui.Button("Center on target") then
            G.game.camera:center_on_target()
        end

        local spd = G.game.camera.tracking_speed
        res, spd = imgui.DragFloat("Tracking speed", spd, 1, 0, 0, "%.3f", 1)
        if res then
            G.game.camera.tracking_speed = spd
        end

        local clamp = G.game.camera.clamp_to_level_bounds
        _, clamp = imgui.Checkbox("Clamp to level bounds", G.game.camera.clamp_to_level_bounds)
        G.game.camera.clamp_to_level_bounds = clamp

    end
    imgui.End()
end

function DebugGui:wave(wave)
    imgui.TextUnformatted(string.format("Total mobs: %d", wave.total_mobs))
    imgui.TextUnformatted(string.format("Max concurrent: %d", wave.max_concurrent))
end

function DebugGui:update(dt)
    if dt <= 0 then
        return
    end
    self:draw(dt)
end

return DebugGui