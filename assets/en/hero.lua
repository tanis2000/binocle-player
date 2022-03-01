local entity = require("entity")
local hero = entity:new()

function hero:update(dt)
    entity.update(self, dt)

    local spd = 10
    if input.is_key_pressed(input_mgr, key.KEY_LEFT) or input.is_key_pressed(input_mgr, key.KEY_A) then
        self.dx = self.dx - spd * dt * self.time_mul
        self.dir = -1
    elseif input.is_key_pressed(input_mgr, key.KEY_RIGHT) or input.is_key_pressed(input_mgr, key.KEY_D) then
        self.dx = self.dx + spd * dt * self.time_mul
        self.dir = 1
    end

    local camera_x = camera.x(cam)
    local camera_y = camera.y(cam)
    if input.is_key_pressed(input_mgr, key.KEY_UP) then
        camera_y = camera_y + spd * dt * self.time_mul
    elseif input.is_key_pressed(input_mgr, key.KEY_DOWN) then
        camera_y = camera_y - spd * dt * self.time_mul
    end
    camera.set_position(cam, camera_x, camera_y)

end

return hero