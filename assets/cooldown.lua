local cooldown = {
    cooldowns = {
--[[
        __tostring = function()
            for idx in pairs(self) do
                return tostring(self[idx])
            end
        end
        ]]
    }
}

function cooldown:set(name, seconds, func)
    local cd = {
        name = name,
        total = seconds,
        remaining = seconds,
        func = func,
        __tostring = function()
            return "name: " .. self.name .. ", total: " .. self.total .. ", remaining: " .. self.remaining
        end
    }
    self.cooldowns[name] = cd
end

function cooldown:update(dt)
    local count = 0
    io.write("cooldowns:" .. tostring(self) .. "\n")
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

function cooldown:has(name)
    if self.cooldowns[name] then
        if self.cooldowns[name].remaining > 0 then
            return true
        end
    end
    return false
end

function cooldown:unset(name)
    if self.cooldowns[name] then
        self.cooldowns[name] = nil
    end
end

function cooldown:get(name)
    if self:has(name) then
        return self.cooldowns[name].remaining
    else
        return 0
    end
end

return cooldown
