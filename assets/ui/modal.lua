local Process = require("process")
local Game = require("scenes.game")
local lume = require("lib.lume")
local Window = require("ui.window")

local Modal = Window:extend()

function Modal:new()
    Modal.super.new(self)
end


function Modal:init()
    self.name = "modal " .. #G.modals+1
    G.modals[#G.modals+1] = self
end

function Modal:update(dt)
    Modal.super.update(self, dt)
end

function Modal:post_update(dt)
    Modal.super.post_update(self, dt)
end

function Modal:has_any()
    for _, m in pairs(G.modals) do
        if not m.destroyed then
            return true
        end
    end
    return false
end

function Modal:on_destroy()
    Modal.super.on_destroy(self)
    lume.remove(G.modals, self)
    if not self:has_any() then
        G.game.resume()
    end
end

return Modal