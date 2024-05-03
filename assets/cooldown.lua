local Object = require("lib.classic")

---@class CooldownInstance
local CooldownInstance = Object:extend()

function CooldownInstance.new(self, name, seconds, func, ...)
    CooldownInstance.super.new(self)
    self.name = name
    self.total = seconds
    self.remaining = seconds
    self.func = func
    self.args = ...
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

function Cooldown:set(name, seconds, func, ...)
    local cd = CooldownInstance(name, seconds, func, ...)
    -- log.info(tostring(cd))
    self.cooldowns[name] = cd
end

function Cooldown:update(dt)
    local count = 0
    --log.info("cooldowns:" .. tostring(self))
    for idx in pairs(self.cooldowns) do
        --log.info("this cd: "..tostring(self.cooldowns[idx]))
        self.cooldowns[idx].remaining = self.cooldowns[idx].remaining - dt
        if self.cooldowns[idx].remaining <= 0 then
            local func = self.cooldowns[idx].func
            local args = self.cooldowns[idx].args
            self.unset(self, self.cooldowns[idx].name)
            if func then
                func(args)
            end
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

---@return number The ratio of the remaining cooldown from 1 -> 0
function Cooldown:get_ratio(name)
    if self:has(name) then
        local cd = self.cooldowns[name]
        if cd.remaining <= 0 then
            return 0
        end
        return cd.remaining/cd.total
    end
    return 0
end

function Cooldown.__tostring(self)
    for idx, cd in pairs(self.cooldowns) do
        return string.format("%s\n", cd)
    end
end

return Cooldown
