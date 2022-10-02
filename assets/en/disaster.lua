local Entity = require("entity")
local layers = require("layers")
local const = require("const")
local Building = require("en.building")
local lume = require("lib.lume")

local Disaster = Entity:extend()

Disaster.Type = {
    Earthquake = 0,
    Tornado = 1,
    Famine = 2,
    Crisis = 3,
    Strike = 4,
}

Disaster.ArcheTypes = {
    {
        type = Disaster.Type.Earthquake
    },
    {
        type = Disaster.Type.Tornado
    },
    {
        type = Disaster.Type.Famine
    },
    {
        type = Disaster.Type.Crisis
    },
    {
        type = Disaster.Type.Strike
    },
}

function Disaster:new()
    Disaster.super.new(self)
    self.name = "disaster " .. #G.go.disasters+1
    G.go.disasters[#G.go.disasters+1] = self
    self.depth = layers.TEXT
    self.gravity = 0
    self.disaster_type = Disaster.Type.Earthquake
    self.s = ""
    self.cd:set("keep_saying", 2.5)
end


function Disaster:draw()
    Disaster.super.draw(self)
    --print("drawing disaster")

    local width = ttfont.get_string_width(G.game.default_font, self.s)
    local x = (const.DESIGN_WIDTH - width) / 2
    local y = const.DESIGN_HEIGHT / 2

    self:set_pos_pixel(x, y)
    --log.info("drawing" .. self.s)
    ttfont.draw_string(G.game.default_font, self.s, gd_instance, x, y, viewport, color.red, cam);
end

function Disaster:update(dt)
    --print("disaster update")
    Disaster.super.update(self, dt)
    if not self.cd:has("keep_saying") then
        log.info("removing disaster")
        self:kill()
    end
end

function Disaster.random_disaster()
    local d = Disaster()
    local at = lume.randomchoice(Disaster.ArcheTypes)
    d.disaster_type = at.type
    log.info("drew disaster of type " .. d.disaster_type)
    return d
end

function Disaster:apply()
    log.info("applying disaster " .. tostring(self.disaster_type))
    if self.disaster_type == Disaster.Type.Earthquake then
        self.s = "An earthquake hits your town. All buildings suffer damage"
        for i = #G.go.buildings, 1, -1 do
            local b = G.go.buildings[i]
            b:hurt(1)
        end
        audio.play_sound(G.sounds["earthquake"])
    elseif self.disaster_type == Disaster.Type.Tornado then
        self.s = "A tornado hits your town. Some buildings suffer damage"
        for i = #G.go.buildings, 1, -1 do
            local b = G.go.buildings[i]
            local hit = lume.random(0, 1) < 0.2 -- 20% chance to be hit
            if hit then
                b:hurt(1)
            end
        end
        audio.play_sound(G.sounds["tornado"])
    elseif self.disaster_type == Disaster.Type.Famine then
        self.s = "Famine spreads in your town. Houses suffer damage"
        for i = #G.go.buildings, 1, -1 do
            local b = G.go.buildings[i]
            if b.building_type == Building.BuildingType.House then
                b:hurt(1)
            end
        end
        audio.play_sound(G.sounds["famine"])
    elseif self.disaster_type == Disaster.Type.Crisis then
        self.s = "Economic crisis spreads in your town. Commercials suffer damage"
        for i = #G.go.buildings, 1, -1 do
            local b = G.go.buildings[i]
            if b.building_type == Building.BuildingType.Commercial then
                b:hurt(1)
            end
        end
        audio.play_sound(G.sounds["crisis"])
    elseif self.disaster_type == Disaster.Type.Strike then
        self.s = "Workers go on strike. Factories suffer damage"
        for i = #G.go.buildings, 1, -1 do
            local b = G.go.buildings[i]
            if b.building_type == Building.BuildingType.Factory then
                b:hurt(1)
            end
        end
        audio.play_sound(G.sounds["strike"])
    end

end


return Disaster