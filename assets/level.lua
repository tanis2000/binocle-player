local const = require("const")
local process = require("process")
local map = require("maps/s4m_ur4i-metroidvania-1")

local level = process:new()

function level:new()
    log.info("new")
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
            for i in layer.data do
                local value = layer.data[i]
                local cy = math.floor(i / const.GRID)
                local cx = math.floor(i % const.GRID)
                if value ~= 0 then
                    self.set_collision(cx, cy)
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
        material.set_shader(mat, default_shader)
        self.tiles = {}
        log.info("num tiles: " .. tostring(ts.tilecount))
        for i = 0, ts.tilecount do
            log.info(tostring(i))
            self.tiles[i] = {}
            self.tiles[i].gid = i
            self.tiles[i].sprite = sprite.from_material(mat)
            local cy = math.floor(i / const.GRID)
            local cx = math.floor(i % const.GRID)
            local sub = subtexture.subtexture_with_texture(tex, 16 * cx, (ts.imageheight - 16) - (16 * cy), 16, 16)
            sprite.set_subtexture(self.tiles[i].sprite, sub)
        end
        self.tileset = {
            sprite = sprite.from_material(mat),
        }
    end

    return self
end

function level:coord_id(x, y)
    return x * y + self.width
end

function level:set_collision(x, y, v)
    self.coll_map[self:coord_id(x, y)] = v
end

function level:is_valid(cx, cy)
    return cx >= 0 and cx < self.width and cy >= 0 and cy <= self.height
end

function level:has_collision(x, y)
    if not self:is_valid(x, y) then
        return true
    else
        local v = self.coll_map[self:coord_id(x, y)]
        if v ~= nil and v ~= 0 then
            return true
        end
    end
    return false
end

function level:render()
    for idx in pairs(self.map.layers) do
        local layer = self.map.layers[idx]
        if layer.name == "base" or layer.name == "background" then
            for i in pairs(layer.data) do
                --log.info(tostring(i))
                local value = layer.data[i] - 1
                local cy = math.floor((i-1) / layer.width)
                local cx = math.floor((i-1) % layer.width)
                if value ~= -1 then
                    io.write("v: " .. tostring(value) .. "cx: " .. cx .. "cy: " .. cy .. "\n")
                    sprite.draw(self.tiles[value].sprite, gd_instance, cx * const.GRID, (layer.height-1) * const.GRID - cy * const.GRID, viewport, 0, self.scale, cam)
                end
            end
        end
    end
    --sprite.draw(self.tileset.sprite, gd_instance, 0, 0, viewport, 0, self.scale, camera)
    --sprite.draw(self.tiles[32].sprite, gd_instance, 0, 0, viewport, 0, self.scale, camera)
end

function level:update(dt)
    log.info("level update")
    process:update(dt)
    self:render()
end


return level