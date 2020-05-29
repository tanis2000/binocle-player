local entity = require("entity")
local hero = entity:new()

function hero:update(dt)
    entity.update(self, dt)

    local spd = 10
    if input.is_key_pressed(input_mgr, key.KEY_LEFT) then
        self.dx = self.dx - spd * dt * self.time_mul
        self.dir = -1
    elseif input.is_key_pressed(input_mgr, key.KEY_RIGHT) then
        self.dx = self.dx + spd * dt * self.time_mul
        self.dir = 1
    end
end

return hero