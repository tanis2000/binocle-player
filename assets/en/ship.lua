local Entity = require("entity")
local Ship = Entity:extend()

function Ship:new(cx, cy)
    Ship.super.new(self)
    self.cx = cx
    self.cy = cy
end

return Ship