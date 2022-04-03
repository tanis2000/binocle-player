local Cooldown = require("cooldown")
local lume = require("lib.lume")
local Object = require("lib.classic")

---@class Process
local Process = Object:extend()

processes = {
    unique_id = 0
}

function Process.new(self, parent)
    self.name = "process"
    self.id = 0 -- this must be unique
    self.parent = nil
    self.children = {}
    self.paused = false
    self.cd = Cooldown()
    self.elapsed_time = 0

    processes.unique_id = processes.unique_id + 1
    self.id = processes.unique_id

    if parent ~= nil then
        parent.add_child(self)
    end
end

function Process:add_child(child)
    assert(child:is(Process))
    print("adding children " .. child:__tostring() .. " to " .. self:__tostring())
    print(child.id)
    if child.parent ~= nil then
        child.parent:remove_child(child)
    end
    child.parent = self
    table.insert(self.children, child)
end

function Process:remove_child(child)
    lume.remove(self.children, child)
    child.parent = nil
end

function Process:can_run()
    return not self.paused
end

function Process:pre_update(dt)
    self.elapsed_time = self.elapsed_time + dt
    if self:can_run() then
        self.cd:update(dt)
        if self.children ~= nil then
            for idx, child in pairs(self.children) do
                child:pre_update(dt)
            end
        end
    end
end

function Process:update(dt)
    if self:can_run() then
        if self.children ~= nil then
            for idx, child in pairs(self.children) do
                child:update(dt)
            end
        end
    end
end

function Process:post_update(dt)
    if self:can_run() then
        if self.children ~= nil then
            for idx, child in pairs(self.children) do
                child:post_update(dt)
            end
        end
    end
end

function Process.__tostring(self)
    return "Process<" .. self.name ..">"
end

return Process