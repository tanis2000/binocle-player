local Entity = require("entity")
local layers = require("layers")
local lume = require("lib.lume")

local Building = Entity:extend()

Building.BuildingType = {
    House = 0,
    Commercial = 1,
    Factory = 2
}

Building.ArcheTypes = {
    House = {
        health = 1
    }
}

function Building:new()
    Building.super.new(self)
    self.name = "building " .. #G.go.buildings+1
    G.go.buildings[#G.go.buildings+1] = self
    self.wid = 16
    self.hei = 16
    self.depth = layers.BUILDINGS
    self.gravity = 0
    self.health = 3
    self.building_type = self.BuildingType.House
    self:load_image("data/img/buildings.png", 16, 16)
    self:add_animation("house1", { 1, }, 8)
    self:add_animation("house2", { 2, }, 8)
    self:add_animation("house3", { 3, }, 8)
    self:add_animation("comm1", { 4, }, 8)
    self:add_animation("comm2", { 5, }, 8)
    self:add_animation("comm3", { 6, }, 8)
    self:add_animation("fact1", { 7, }, 8)
    self:add_animation("fact2", { 8, }, 8)
    self:add_animation("fact3", { 9, }, 8)
    self:play_animation("house3")
end

function Building:draw()
    Building.super.draw(self)
    if self.visible then
        local text = tostring(self.health)
        ttfont.draw_string(G.game.default_font, text, gd_instance, self:get_left() + 2, self:get_top() - 10, viewport, color.black, cam);
    end
end

function Building:update(dt)
    Building.super.update(self, dt)
end

return Building