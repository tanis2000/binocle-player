local Entity = require("entity")

local SayMark = Entity:extend()

function SayMark:new(text, trigger_distance)
    SayMark.super.new(self)
    self.text = text
    self.trigger_distance = trigger_distance
end

function SayMark:update(dt)
    SayMark.super.update(self, dt)

    if G.game.h:is_alive() and self:dist_case(G.game.h) < self.trigger_distance then
        log.info("trigger say")
        G.game.h:say(self.text)
        self:kill()
    end
end

return SayMark