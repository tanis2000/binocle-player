local node = {
    __index = node
}

function node.new(arg0)
    local res = {}
    setmetatable(res, {
        __index = function (table, key)
            return node[key]
        end
    })
    res.score = arg0

    return res
end

function node.push(arg0, arg1)
    table.insert(arg0, arg1)
    arg0:float_up(#arg0)
end

function node.update(arg0, arg1)
    for slot5_a1033, slot6_a1028 in ipairs(arg0) do
        if slot6_a1028 == arg1 then
            return arg0:sink_down(slot5_a1033)
        end
    end
end

function node.pop(arg0)
    local slot1_a1049 = arg0[1]
    local slot2_a1044 = table.remove(arg0)

    if #arg0 > 0 then
        arg0[1] = slot2_a1044

        arg0:sink_down(1)
    end

    return slot1_a1049
end

function node.float_up(arg0, arg1)
    local slot2_a1072 = arg0[arg1]
    local slot3_a1069 = arg0.score(slot2_a1072)

    while arg1 > 1 do
        local slot4_a1074 = math.floor(arg1 / 2)
        local slot5_a1070 = arg0[slot4_a1074]

        if arg0.score(slot5_a1070) <= slot3_a1069 then
            break
        end

        arg0[slot4_a1074] = slot2_a1072
        arg0[arg1] = slot5_a1070
        arg1 = slot4_a1074
    end
end

function node.sink_down(arg0, arg1)
    local slot2_a1124 = arg0[arg1]
    local slot3_a1114 = arg0.score(slot2_a1124)

    while true do
        local slot4_a1122 = nil
        local slot5_a1112 = nil
        local slot6_a1118 = arg1 * 2
        local slot7_a1099 = slot6_a1118 - 1

        if slot7_a1099 < #arg0 then
            local slot8_a1093 = arg0[slot7_a1099]
            slot5_a1112 = arg0.score(slot8_a1093)

            if slot5_a1112 < slot3_a1114 then
                slot4_a1122 = slot7_a1099
            end
        end

        if slot6_a1118 < #arg0 then
            if arg0.score(arg0[slot6_a1118]) < (slot4_a1122 and slot5_a1112 or slot3_a1114) then
                slot4_a1122 = slot6_a1118
            end
        end

        if not slot4_a1122 then
            break
        end

        local slot8_a1123 = arg0[slot4_a1122]
        arg0[slot4_a1122] = slot2_a1124
        arg0[arg1] = slot8_a1123
        arg1 = slot4_a1122
    end
end

local path = {
    find = function (arg0)
        assert(arg0, "expected table argument")

        local source = assert(arg0.source, "expected 'source' node")
        local destination = assert(arg0.destination, "expected 'destination' node")
        local distance = assert(arg0.distance, "expected 'distance' function")
        local neighbors = assert(arg0.neighbors, "expected 'neighbors' function")
        local fn = arg0.heuristic or distance
        local slot6_a1234 = {
            [source] = 0
        }
        local slot7_a1242 = {
            [source] = fn(source, destination)
        }
        local n = node.new(function (arg0)
            return slot7_a1242[arg0]
        end)

        local slot9_a1212 = {}
        local slot10_a1231 = {}
        local neighborsList = {}

        n:push(source)

        while true do
            local procNode = n:pop()

            if not procNode then
                break
            end

            slot9_a1212[procNode] = true

            if procNode == destination then
                local res = {}
                local slot14_a1193 = destination

                while slot14_a1193 ~= source do
                    table.insert(res, slot14_a1193)

                    slot14_a1193 = slot10_a1231[slot14_a1193]
                end

                return res
            end

            neighbors(neighborsList, procNode)

            for i = 1, #neighborsList do
                local neigh = neighborsList[i]
                neighborsList[i] = nil

                if not slot9_a1212[neigh] then
                    local slot18_a1233 = slot6_a1234[procNode] + distance(procNode, neigh)
                    local slot19_a1243 = slot7_a1242[neigh]

                    if not slot19_a1243 or slot18_a1233 < slot6_a1234[neigh] then
                        slot10_a1231[neigh] = procNode
                        slot6_a1234[neigh] = slot18_a1233
                        slot7_a1242[neigh] = slot18_a1233 + fn(neigh, destination)

                        if not slot19_a1243 then
                            n:push(neigh)
                        else
                            n:update(neigh)
                        end
                    end
                end
            end
        end
    end
}

return path
