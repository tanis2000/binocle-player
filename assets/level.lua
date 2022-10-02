local const = require("const")
local Process = require("process")
local map = require("maps.ld51-main")
local layers = require("layers")
local lume = require("lib.lume")
local SayMark = require("en.saymark")
local Ship = require("en.ship")
local Collector = require("en.collector")

local Level = Process:extend()

Level.PlatformEndLeft = 1
Level.PlatformEndRight = 2

function Level:new()
    Level.super.new(self)
    self.name = "level"
    self.map = map
    self.coll_map = {}
    self.hero_spawners = {}
    self.cat_spawners = {}
    self.mob_spawners = {}
    self.collectors = {}
    self.marks_map = {}
    self.width = map.width
    self.height = map.height
    self.scale = lkazmath.kmVec2New()
    self.scale.x = 1.0
    self.scale.y = 1.0
    for idx in pairs(map.layers) do
        local layer = map.layers[idx]
        if layer.name == "collisions" then
            -- Setup collisions
            for i in pairs(layer.data) do
                local value = layer.data[i]
                local cy = layer.height - 1 - math.floor((i-1) / layer.width)
                local cx = math.floor((i-1) % layer.width)
                if value ~= 0 then
                    --print(cx, cy)
                    self:set_collision(cx, cy, true)
                end
            end

            -- Setup marks
            for cy = 0, self.map.height do
                for cx = 0, self.map.width do
                    if not self:has_collision(cx, cy) and self:has_collision(cx, cy-1) then
                        if self:has_collision(cx+1, cy) or not self:has_collision(cx+1, cy-1) then
                            self:set_mark(cx, cy, Level.PlatformEndRight)
                        end
                        if self:has_collision(cx-1, cy) or not self:has_collision(cx-1, cy-1) then
                            self:set_mark(cx, cy, Level.PlatformEndLeft)
                        end
                    end
                end
            end
        end
        if layer.name == "spawners" then
            for i in pairs(layer.objects) do
                local obj = layer.objects[i]
                if obj.name == "hero" then
                    local spawner = {
                        cx = obj.x / const.GRID,
                        cy = self.map.width - (obj.y / const.GRID),
                    }
                    self.hero_spawners[#self.hero_spawners+1] = spawner
                end
                if obj.name == "cat" then
                    local spawner = {
                        cx = obj.x / const.GRID,
                        cy = self.map.width - (obj.y / const.GRID),
                    }
                    self.cat_spawners[#self.cat_spawners+1] = spawner
                end
                if obj.name == "mob" then
                    local spawner = {
                        cx = obj.x / const.GRID,
                        cy = self.map.width - (obj.y / const.GRID),
                    }
                    self.mob_spawners[#self.mob_spawners+1] = spawner
                end
                if obj.name == "collector" then
                    local cx = obj.x / const.GRID
                    local cy = self.map.width - (obj.y / const.GRID)
                    Collector(cx, cy)
                end
            end
        end
        if layer.name == "interactive" then
            for i in pairs(layer.objects) do
                local obj = layer.objects[i]
                if obj.name == "collector" then
                    local collector = {
                        cx = obj.x / const.GRID,
                        cy = self.map.width - (obj.y / const.GRID),
                    }
                    self.collectors[#self.collectors+1] = collector
                end
                if obj.name == "say" then
                    local s = SayMark(obj.properties["text"], obj.properties["trigger_distance"])
                    local cx = obj.x / const.GRID
                    local cy = self.map.width - (obj.y / const.GRID)
                    s:set_pos_grid(cx, cy)
                end
                if obj.name == "ship" then
                    local cx = obj.x / const.GRID
                    local cy = self.map.width - (obj.y / const.GRID)
                    Ship(cx, cy)
                end
            end
        end
    end

    local assets_dir = sdl.assets_dir()
    for idx in pairs(self.map.tilesets) do
        log.info("idx: " .. idx)
        local ts = self.map.tilesets[idx]
        local image_filename = assets_dir .. "maps/" .. ts.image
        local img = image.load(image_filename)
        local tex = texture.from_image(img)
        local mat = material.new()
        material.set_texture(mat, tex)
        material.set_shader(mat, shader.defaultShader())
        self.tiles = {}
        log.info("num tiles: " .. tostring(ts.tilecount))
        for i = 0, ts.tilecount do
            --log.info(tostring(i))
            self.tiles[i] = {}
            self.tiles[i].gid = i
            self.tiles[i].sprite = sprite.from_material(mat)
            local cy = math.floor(i / const.GRID)
            local cx = math.floor(i % const.GRID)
            local sub = subtexture.subtexture_with_texture(tex, 16 * cx, (ts.imageheight - 16) - (16 * cy), self.map.tilewidth, self.map.tileheight)
            sprite.set_subtexture(self.tiles[i].sprite, sub)
            sprite.set_origin(self.tiles[i].sprite, 0, 0)
        end
        self.tileset = {
            sprite = sprite.from_material(mat),
        }
    end

    return self
end

function Level:coord_id(cx, cy)
    return cx + cy * self.width
end

function Level:set_collision(x, y, v)
    if self:is_valid(x, y) then
        if v then
            self.coll_map[self:coord_id(x, y)] = v
        else
            self.coll_map[self:coord_id(x, y)] = nil
        end
    end
end

function Level:is_valid(cx, cy)
    return cx >= 0 and cx < self.width and cy >= 0 and cy <= self.height
end

function Level:has_collision(x, y)
    --print(x, y)
    if not self:is_valid(x, y) then
        return true
    else
        local v = self.coll_map[self:coord_id(x, y)]
        --print(v)
        if v ~= nil then
            return true
        end
    end
    return false
end

function Level:has_wall_collision(cx, cy)
    return self:has_collision(cx, cy)
end

function Level:set_mark(x, y, v)
    print("setting mark " .. tostring(v) .. " at " .. tostring(x) .. "," .. tostring(y))
    if self:is_valid(x, y) then
        if v then
            self.marks_map[self:coord_id(x, y)] = v
        else
            self.marks_map[self:coord_id(x, y)] = nil
        end
    end
end

function Level:has_mark(x, y, mark)
    --print("looking for mark " .. tostring(mark) .. " at " .. tostring(x) .. tostring(y))
    if not self:is_valid(x, y) then
        return false
    else
        local v = self.marks_map[self:coord_id(x, y)]
        --print("found mark " .. tostring(v))
        if v ~= nil  and v == mark then
            return true
        end
    end
    return false
end

function Level:render()
    for idx in pairs(self.map.layers) do
        local layer = self.map.layers[idx]
        if layer.name == "collisions" or layer.name == "objects" or layer.name == "fg" then
            for i in pairs(layer.data) do
                --log.info(tostring(i))
                local value = layer.data[i] - 1
                local cy = math.floor((i-1) / layer.width)
                local cx = math.floor((i-1) % layer.width)
                if value ~= -1 then
                    -- io.write("v: " .. tostring(value) .. "cx: " .. cx .. "cy: " .. cy .. "\n")
                    sprite.draw(self.tiles[value].sprite, gd_instance, cx * const.GRID, (layer.height-1) * const.GRID - cy * const.GRID, viewport, 0, self.scale.x, self.scale.y, cam)
                end
            end
        end
    end
    --sprite.draw(self.tileset.sprite, gd_instance, 0, 0, viewport, 0, self.scale, camera)
    --sprite.draw(self.tiles[32].sprite, gd_instance, 0, 0, viewport, 0, self.scale, camera)
end

function Level:update(dt)
    -- log.info("level update")
    Level.super.update(self, dt)
    --self:render()
end

function Level:post_update(dt)
    Level.super.post_update(self, dt)
    self:render()
end

function Level:get_c_wid()
    return self.width
end

function Level:get_c_hei()
    return self.height
end

function Level:get_px_wid()
    return self:get_c_wid() * const.GRID
end

function Level:get_px_hei()
    return self:get_c_hei() * const.GRID
end

function Level:get_hero_spawner()
    return self.hero_spawners[1]
end

function Level:get_cat_spawner()
    if #self.cat_spawners > 0 then
        return lume.randomchoice(self.cat_spawners)
    else
        return nil
    end
end

function Level:get_mob_spawner()
    if #self.mob_spawners > 0 then
        return lume.randomchoice(self.mob_spawners)
    else
        return nil
    end
end

return Level