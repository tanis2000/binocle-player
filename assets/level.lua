local const = require("const")
local Process = require("process")
local map = require("maps/s4m_ur4i-metroidvania-1")

local Level = Process:extend()

function Level:new()
    Level.super.new(self)
    self.name = "level"
    self.map = map
    self.coll_map = {}
    self.width = map.width
    self.height = map.height
    self.scale = lkazmath.kmVec2New()
    self.scale.x = 1.0
    self.scale.y = 1.0
    for idx in pairs(map.layers) do
        local layer = map.layers[idx]
        if layer.name == "collisions" then
            for i in pairs(layer.data) do
                local value = layer.data[i]
                local cy = layer.height - 1 - math.floor((i-1) / layer.width)
                local cx = math.floor((i-1) % layer.width)
                if value ~= 0 then
                    --print(cx, cy)
                    self:set_collision(cx, cy, true)
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

function Level:render()
    for idx in pairs(self.map.layers) do
        local layer = self.map.layers[idx]
        if layer.name == "collisions" or layer.name == "background" then
            for i in pairs(layer.data) do
                --log.info(tostring(i))
                local value = layer.data[i] - 1
                local cy = math.floor((i-1) / layer.width)
                local cx = math.floor((i-1) % layer.width)
                if value ~= -1 then
                    -- io.write("v: " .. tostring(value) .. "cx: " .. cx .. "cy: " .. cy .. "\n")
                    sprite.draw(self.tiles[value].sprite, gd_instance, cx * const.GRID, (layer.height-1) * const.GRID - cy * const.GRID, viewport, 0, self.scale, cam)
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


return Level