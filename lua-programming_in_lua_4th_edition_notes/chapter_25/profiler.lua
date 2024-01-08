local Counters = {}
local Names = {}

local function hook ()
    local f = debug.getinfo(2, "f").func
    local count = Counters[f]
    if count == nil then -- first time 'f' is called?
        Counters[f] = 1
        Names[f] = debug.getinfo(2, "Sn")
    else -- only increment the counter
        Counters[f] = count + 1
    end
end

function getname (func)
    local n = Names[func]
    if n.what == "C" then
        return n.name
    end
    local lc = string.format("[%s]:%d", n.short_src, n.linedefined)
    if n.what ~= "main" and n.namewhat ~= "" then
        return string.format("%s (%s)", lc, n.name)
    else
        return lc
    end
end

local f = assert(loadfile(arg[1]))
debug.sethook(hook, 'called')
f()
debug.sethook()

for func, count in pairs(Counters) do
    print(getname(func), count)
end
--[[
lua profiler.lua main_lua.lua
aaaa
aaaa
aaaa
aaaa
aaaa
aaaa
aaaa
aaaa
aaaa
aaaa
print   10
[profiler.lua]:0        2 --> this is the f() and loadfile()
[main_lua.lua]:1 (testMe)       30
sethook 1
[main_lua.lua]:0        25    
--]]


