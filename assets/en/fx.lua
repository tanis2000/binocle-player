local lume = require("lib.lume")
local M = require("m")
local Entity = require("entity")
local Fx = Entity:extend()

function Fx:new(filename, frames, duration)
    Fx.super.new(self)
    local img = G.cache.load(filename)
    local original_image_width, original_image_height = image.get_info(img)
    local frame_width = original_image_width / frames
    self.hei = frame_width
    self.wid = original_image_height
    self:load_image(filename, frame_width, original_image_height)
    local f = {}
    for frame = 1, frames do
        lume.push(f, frame)
    end
    self:add_animation("main", f, frames / duration, function()
        self:kill()
    end)
    self:play_animation("main")
    self.has_collisions = false
    self.name = "fx"
end

return Fx