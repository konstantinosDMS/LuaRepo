function setvarvalue(name, value, level, isenv)
    for i = 1, math.huge do
        local n, v = debug.getlocal(level + 1, i)
        if not n then break end
        if n == name then
            debug.setlocal(level + 1, i, value)
            return string.format("%s %s", n, value)
        end
    end

    local func = debug.getinfo(level + 1, "f").func
    for i = 1, math.huge do
        local n, v = debug.getupvalue(func, i)
        if not n then break end
        if n == name then
            debug.setupvalue(func, i, value)
            return "upvalue", value
        end
    end

    if isenv then
        local _, env = debug.getlocal(level + 1, 1)
        if env then
            env[name] = value
            return "global", value
        else
            return "noenv"
        end
    end

    return "notfound"
end
--[[
local a = 5
print(setvarvalue("a", 10, 1))
print(a)  -- Output: a 10
--]]
-- Uncomment the following block for additional testing
--[[
print(setvarvalue("b", 25, 1))
--]]
aa = 20
print(setvarvalue("aa", 40, 2))
print(aa)


