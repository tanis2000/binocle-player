local Entity = require("entity")
local layers = require("layers")
local lume = require("lib.lume")
local Building = require("en.building")

local Card = Entity:extend()

local CardType = {
    AddHouse = 0,
    AddCommercial = 1,
    AddEnergy = 2,
    AddFactory = 3,
}

local CardArchetypes = {
    {
        card_type = CardType.AddHouse,
        granted_energy = 0,
        required_energy = 1,
        text = "build house"
    },
    {
        card_type = CardType.AddCommercial,
        granted_energy = 0,
        required_energy = 1,
        text = "build commercial"
    },
    {
        card_type = CardType.AddFactory,
        granted_energy = 0,
        required_energy = 1,
        text = "build factory"
    },
    {
        card_type = CardType.AddEnergy,
        granted_energy = 0,
        required_energy = 0,
        text = "add energy"
    },
}

function Card:new()
    Card.super.new(self)
    self.name = "card " .. #G.go.cards+1
    G.go.cards[#G.go.cards+1] = self
    self.wid = 64
    self.hei = 96
    self.depth = layers.MOBS
    self.gravity = 0
    self.required_energy = 0
    self.granted_energy = 0
    self.text = ""
    self.card_type = CardType.AddEnergy
    self:load_image("data/img/card.png", 64, 96)
    self:add_animation("idle", {
        1,
    }, 8)
    self:play_animation("idle")
end

function Card:draw()
    Card.super.draw(self)
    if self.visible then
        ttfont.draw_string(G.game.default_font, self.text, gd_instance, self:get_left() + 2, self:get_top() - 20, viewport, color.black, cam);
        local senergy = "energy req: " .. self.required_energy
        ttfont.draw_string(G.game.default_font, senergy, gd_instance, self:get_left() + 2, self:get_top() - 10, viewport, color.black, cam);
    end
end

function Card:update(dt)
    Card.super.update(self, dt)
    local mx, my = input.get_mouse_position(input_mgr, cam)
    --print(tostring(mx) .. ", " .. tostring(my))
    local px, py = self:screen_position_to_world(mx, my)
    if (self:is_inside(px, py)) then
        --print("inside " .. self.name)
        if input.is_mouse_down(input_mgr, mouse.MOUSE_LEFT) then
            print("clicked " .. self.name)
            self:apply()
        end
    end
end

function Card:apply()
    if self.required_energy > G.player.energy then
        --TODO say you do not have enough energy
        print("not enough energy")
        return
    end

    if self.card_type == CardType.AddEnergy and G.player.energy < G.player.max_energy then
        G.player.energy = G.player.energy + self.granted_energy
        -- ensure we do not overflow the energy
        if G.player.energy > G.player.max_energy then
            G.player.energy = G.player.max_energy
        end
    elseif self.card_type == CardType.AddHouse then
        G.game:add_building(Building.BuildingType.House, 1)
    end

    self:kill()
    lume.remove(G.go.cards, self)
end

function Card.random_card()
    local card = Card()
    local at = lume.randomchoice(CardArchetypes)
    card.card_type = at.card_type
    card.granted_energy = at.granted_energy
    card.required_energy = at.required_energy
    card.text = at.text
    if card.card_type == CardType.AddEnergy then
        card.energy = math.floor(lume.random(1, 2))
        card.text = card.text .. "(" .. tostring(card.energy) .. ")"
    end
    return card
end

return Card