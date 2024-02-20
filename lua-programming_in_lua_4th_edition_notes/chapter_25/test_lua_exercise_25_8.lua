local debug = require "debug"
local count = 0

local function hook_1 (event)
    if event == "call" then
        print('count')
    end
end

for i = 1, 10 do
    hook_1('call')    
end

--[===[
local debug = require "debug"
local co = coroutine.create(function(a, b)
                                local c = a + b
                                coroutine.yield()
                                print(c)                                
                            end)

coroutine.resume(co, 7, 5)

function getvarvalue(co, name, level, isenv)
    local value
    local found = false
    level = level or 1

    -- Check if the coroutine is still running
    if coroutine.status(co) ~= "dead" then
        for i = 1, math.huge do
            local n, v = debug.getlocal(co, level, i)
            if not n then break end
            if n == name then
                value = v
                found = true
            end
        end

        if found then return "local", value end

        local func = debug.getinfo(co, level, "f").func
        for i = 1, math.huge do
            local n, v = debug.getupvalue(func, i)
            if not n then break end
            if n == name then return "upvalue", v end
        end

        if isenv then return "noenv" end

        -- Search in the main Lua environment
        local main_env = _G
        value = main_env[name]
        if value ~= nil then
            return "global", value
        end

        return "noenv"
    else
        return "coroutine_dead"
    end
end

print(getvarvalue(co, "a", 1)) -- local   7
print(getvarvalue(co, "b", 1)) -- local   5
print(getvarvalue(co, "c", 1)) -- local   12          
gg = 14
print(debug.getinfo(co, 1)) -- table: 0x561f20f445d0 (the coroutine's environment)
print(debug.getinfo(co, 2)) -- nil
print(debug.getinfo(co, 0)) -- table: 0x561f20f448c0
print(getvarvalue(co, "gg", 0)) -- 14
--]===]






