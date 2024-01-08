local M = {} -- the module

local function new (r, i) -- creates a new complex number
    return {r = r, i = i}
end

M.new = new -- add 'new' to the module

M.i = new(tonumber(0), 1) -- constant 'i'

function M.add (c1, c2)
    return new(c1.r + c2.r, c1.i + c2.i)
end

function M.sub (c1, c2)
    return new(c1.r - c2.r, c1.i - c2.i)
end

function M.mul (c1, c2)
    return new(c1.r * c2.r - c1.i * c2.i, c1.r * c2.i + c1.i * c2.r)
end

local function inv (c)
    local n = c.r ^ 2 + c.i ^ 2
    return new(c.r / n, -c.i / n)
end

function M.div (c1, c2)
    return M.mul(c1, inv(c2))
end

function M.tostring (c)
    return string.format(" %g + %gi ", c.r, c.i)
end

return M
