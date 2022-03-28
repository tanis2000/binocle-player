local Object = require("lib.classic")

---@class CooldownInstance
local CooldownInstance = Object:extend()

function CooldownInstance.new(self, name, seconds, func)
    CooldownInstance.super.new(self)
    self.name = name
    self.total = seconds
    self.remaining = seconds
    self.func = func
end

function CooldownInstance.__tostring(self)
    return "name: " .. self.name .. ", total: " .. self.total .. ", remaining: " .. self.remaining
end

---@class Cooldown
local Cooldown = Object:extend()

function Cooldown.new(self)
    Cooldown.super.new(self)
    self.cooldowns = {}
end

function Cooldown:set(name, seconds, func)
    local cd = CooldownInstance(name, seconds, func)
    self.cooldowns[name] = cd
end

function Cooldown:update(dt)
    local count = 0
    --io.write("cooldowns:" .. tostring(self) .. "\n")
    for idx in pairs(self.cooldowns) do
        --log.info("this cd: "..tostring(self.cooldowns[idx]))
        self.cooldowns[idx].remaining = self.cooldowns[idx].remaining - dt
        if self.cooldowns[idx].remaining <= 0 then
            self.unset(self, self.cooldowns[idx].name)
        end
        count = count + 1
    end
    --log.info("count "..tostring(count))
end

function Cooldown:has(name)
    if self.cooldowns[name] then
        if self.cooldowns[name].remaining > 0 then
            return true
        end
    end
    return false
end

function Cooldown:unset(name)
    if self.cooldowns[name] then
        self.cooldowns[name] = nil
    end
end

function Cooldown:get(name)
    if self:has(name) then
        return self.cooldowns[name].remaining
    else
        return 0
    end
end

function Cooldown.__tostring(self)
    for idx, cd in pairs(self.cooldowns) do
        return string.format("%s\n", cd)
    end
end

return Cooldown
