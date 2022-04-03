local util = {
}

function util.line(x, y, x2, y2, fn)
    local dx = x
    local dy = y
    local res = nil
    local distX = math.abs(x2 - x)
    local distY = math.abs(y2 - y)
    local len = math.max(distX, distY)

    for i = 1, len do
        res = fn(math.floor(dx), math.floor(dy))
        if res then
            break
        end

        dx = dx + distX / len
        dy = dy + distY / len
    end

    return res

end

return util