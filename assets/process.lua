local cooldown = require("cooldown")

processes = {
    unique_id = 0
}

local process = {}

function process:new(o, parent)
    o = o or {
        name = "process",
        id = 0, -- this must be unique
        parent = nil,
        children = {},
        paused = false,
        cd = cooldown,
        __tostring = function()
            return "process<" .. self.name ..">"
        end
    }
    setmetatable(o, self)
    self.__index = self

    processes.unique_id = processes.unique_id + 1
    o.id = processes.unique_id

    if parent ~= nil then
        parent.add_child(o)
    end

    return o
end

function process:add_child(child)
    if child.parent ~= nil then
        child.parent.remove_child(child)
    end
    child.parent = self
    self.children[#self.children + 1] = child.unique_id
end

function process:remove_child(child)
    for idx in pairs(self.children) do
        if self.children[idx] == child.unique_id then
            self.children[idx] = nil
        end
    end
end

function process:can_run()
    return not self.paused
end

function process:pre_update(dt)
    if self:can_run() then
        self.cd:update(dt)

        for idx in pairs(self.children) do
            self.children[idx].pre_update(dt)
        end
    end
end

function process:update(dt)
    if self:can_run() then
        if self.children ~= nil then
            for idx in pairs(self.children) do
                self.children[idx].update(dt)
            end
        end
    end
end

function process:post_update(dt)
    if self:can_run() then
        for idx in pairs(self.children) do
            self.children[idx].post_update(dt)
        end
    end
end

return process