local Process = require("process")

local TimeSystem = Process:extend()

function TimeSystem:new()
    TimeSystem.super.new(self)
    self.seconds_per_turn = 10
    self.on_turn_end_cb = nil
    self.on_turn_end_cb_args = nil
    self.cd:set("buzz2", self.seconds_per_turn-2, self.buzz, self)
    self.cd:set("buzz1", self.seconds_per_turn-1, self.buzz, self)
    self.cd:set("turn", self.seconds_per_turn, self.end_of_turn, self)
end

function TimeSystem:end_of_turn()
    print("end of turn "..tostring(self))
    self.cd:set("buzz2", self.seconds_per_turn-2, self.buzz, self)
    self.cd:set("buzz1", self.seconds_per_turn-1, self.buzz, self)
    self.cd:set("turn", self.seconds_per_turn, self.end_of_turn, self)
    audio.play_sound(G.sounds["countdown-final"])
    if self.on_turn_end_cb ~= nil then
        self.on_turn_end_cb(self.on_turn_end_cb_args)
    end
end

function TimeSystem:buzz()
    audio.play_sound(G.sounds["countdown"])
end

function TimeSystem:update(dt)
    G.player.elapsed_time = G.player.elapsed_time + dt
end

function TimeSystem:set_on_turn_end(fn, ...)
    self.on_turn_end_cb = fn
    self.on_turn_end_cb_args = ...
end

return TimeSystem
