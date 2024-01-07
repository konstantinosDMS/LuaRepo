local gr = {}

local function disk1 (x, y)
    return (x - 1.0) ^ 2 + (y - 3.0) ^ 2 <= 4.5 ^ 2
end

local function disk (cx, cy, r)
    return function (x, y)
        return (x - cx) ^ 2 + (y - cy) ^ 2 <= r ^ 2
    end
end

local function rect (left, right, bottom, up)
    return function (x, y)
        return left <= x and x <= right and
        bottom <= x and x <= up
    end
end

local function complement (r)
    return function (x, y)
        return not r(x, y)
    end
end

local function union (rk, r2)
    return function (x, y)
        return rk(x, y) or r2(x, y)
    end
end
    
local function intersection (rk, r2)
    return function (x, y)
        return rk(x, y) and r2(x, y)
    end
end

local function difference (rk, r2)
    return function (x, y)
        return rk(x, y) and not r2(x, y)
    end
end

local function translate (r, dx, dy)
    return function (x, y)
        return r(x - dx, y - dy)
    end
end

local function plot (r, M, N)
    io.write("Pk\n", M, " ", N, "\n")
    -- header
    for i = 1, N do
    -- for each line
        local y = -(N - i * 2) / N  -- 0.996,  0.994
        for j = 1, M do
        -- for each column
            local x = -(j * 2 - M) / M  --  -0.996,  -0.994
            io.write(r(x, y) and "1" or "0")
        end
        io.write("\n")
    end
end

return  {
            plot = plot,
            translate = translate,
            difference = difference,
            intersection = intersection,
            union = union,
            complement = complement,
            rect = rect,
            disk = disk,
            disk1 = disk1
        }
