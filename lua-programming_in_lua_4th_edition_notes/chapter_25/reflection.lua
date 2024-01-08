--[[


--]]
--[===[
function traceback ()
    for level = 1, math.huge do
        local info = debug.getinfo(level, "Sl")
        if not info then break end
        if info.what == "C" then -- is a C function?
            print(string.format("%d\tC function", level))
        else -- a Lua function
            print(string.format("%d\t[%s]:%d", level, info.short_src, info.currentline))
        end
    end
end

traceback()

print(debug.traceback())
--[[
stack traceback:
        /home/konstantinos/Downloads/lua/apps/reflection.lua:20: in main chunk
        [C]: in ?
--]]
--]===]
--[===[
function foo (a, b)
    local x
    do local c = a - b end
    local a = 1
    while true do
        local name, value = debug.getlocal(1, a)
        if not name then break end
        print(name, value)
        a = a + 1
    end
end

foo(10, 20)
--]===]
--[===[
function foo (...)
    local x
    local t, r, e = ...
    do local c = t + e  end
    local a = -1
    while true do
        local name, value = debug.getlocal(1, a)
        if not name then break end
        print(name, value)
        a = a - 1
    end
end

foo(10, 20, 30)
--]===]
--[[
    (vararg)        10
    (vararg)        20
    (vararg)        30
--]]
--[===[
function foo (...)
    local x
    local t, r, e = ...
    do local c = t + e  end
    local a = -1
    local name, value
    while true do
        name = debug.setlocal(1, a, 15)
        if not name then break end
        name, value = debug.getlocal(1, a)
        print(name, value)
        a = a - 1
    end
end

foo(10, 20, 30)
--[[
(vararg)        15
(vararg)        15
(vararg)        15    
--]]
--]===]
--[===[
function getvarvalue (name, level, isenv)
    local value
    local found = false
    level = (level or 1) + 1 -- try local variables
    for i = 1, math.huge do
        local n, v = debug.getlocal(level, i)
        if not n then break end
        if n == name then
            value = v
            found = true
        end
    end
    if found then return "local", value end -- try non-local variables
    local func = debug.getinfo(level, "f").func
    for i = 1, math.huge do
        local n, v = debug.getupvalue(func, i)
        if not n then break end
        if n == name then return "upvalue", v end
    end
    if isenv then return "noenv" end -- avoid loop, not found; get value from the environment
    local _, env = getvarvalue("_ENV", level, true)
    if env then
        return "global", env[name]
    else -- no _ENV available
        return "noenv"
    end
end

a = "xx"; print(getvarvalue("a")) -- local xx
local a = 4; print(getvarvalue("a")) -- local  4
--]===]
--[===[
debug.sethook(print, "l")
co = coroutine.create(function ()
        local x = 10
        coroutine.yield()
        error("some error")
    end)

coroutine.resume(co)
print(debug.traceback(co))
--[[
stack traceback:
        [C]: in function 'coroutine.yield'
        /home/konstantinos/Downloads/lua/apps/reflection.lua:121: in function </home/konstantinos/Downloads/lua/apps/reflection.lua:119>    
--]]
print(coroutine.resume(co)) -- false
print(debug.traceback(co)) -- stack traceback:
--[[
[C]: in function 'coroutine.yield'
/home/konstantinos/Downloads/lua/apps/reflection.lua:121: in function </home/konstantinos/Downloads/lua/apps/reflection.lua:119>
false   /home/konstantinos/Downloads/lua/apps/reflection.lua:122: some error
stack traceback:
[C]: in function 'error'
/home/konstantinos/Downloads/lua/apps/reflection.lua:122: in function </home/konstantinos/Downloads/lua/apps/reflection.lua:119>
--]]
print(debug.getlocal(co, 1, 1)) -- x       10
--]===]

--[===[
function trace (event, line)
    local s = debug.getinfo(2).short_src
    print(s .. ":" .. line)
end

debug.sethook(trace, "l")

function printMe()
    print('a')
end

printMe()
--]===]
--[===[
function debug1 ()
    while true do
        io.write("debug> ")
        local line = io.read()
        if line == "cont" then break end
        assert(load(line))()
    end
end

debug1()
--]===]
--[===[
local debug = require "debug"
local count = 0
local memlimit = 1000  -- maximum memory (in KB) that can be used
local steplimit = 1000  -- maximum "steps" that can be performed

local function checkmem ()
	if collectgarbage("count") > memlimit then
		error("script uses too much memory")
	end
end

-- set of authorized functions
local validfunc = {
	[string.upper] = true,
	[string.lower] = true,
-- other authorized functions
}

local function step ()
	checkmem()
	count = count + 1
	if count > steplimit then
		error("script uses too much CPU")
	end
end

local function hook (event)
	if event == "call" then
		local info = debug.getinfo(2, "fn")
		if not validfunc[info.func] then
			error("calling bad function: " .. (info.name or "?"))
		end
	end

	count = count + 1
	if count > steplimit then
		error("script uses too much CPU")
	end
end

local f = assert(loadfile(arg[1], "t", {}))
debug.sethook(step, "", 100)
debug.sethook(hook, "", 100)
f()
--]===]
--[[
local s = "123456789012345"
for i = 1, 36 do s = s .. s end
--]]

--[[
(load restricted to small text chunks, file access restricted to a fixed directory, 
or pattern matching restricted to small subjects). As a rule of thumb, all functions
from the mathematical library are safe. Most functions from the string library are safe; 
just be careful with resource-consuming ones. The debug and package libraries are off-limits; 
almost everything there can be dangerous. The functions setmetatable and getmetatable are also 
tricky: first, they can allow access to otherwise inaccessible values; moreover, they allow the 
creation of tables with finalizers, where someone can install all sorts of “time bombs” (code 
that can be executed outside the sandbox, when the
table is collected).
--]]
--[[
-- Coroutine function
local function coroutineFunction(a)
    local localVar = "Hello from coroutine!"
    print(a)
    coroutine.yield()
end

-- Create a coroutine
local co = coroutine.create(coroutineFunction)

-- Start the coroutine
coroutine.resume(co, 5)

-- Get the local variable at level 0 (coroutine's chunk)
local level = 1
local index = 1
local n, v = debug.getlocal(co, level, index)

-- Print the result
if n then
    print("Local variable name:", n)
    print("Local variable value:", v)
else
    print("No local variable found at level", level, "and index", index)
end
--]]
--[[
5
Local variable name:    a
Local variable value:   5    
--]]
--[===[
-- Exercise 25.1 -- 
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

        local _, env = getvarvalue(co, "_ENV", level, true)
        if env then
            return "global", env[name]
        else
            return "noenv"
        end
    else
        return "coroutine_dead"
    end
end

local co = coroutine.create(function(a, b)
    local c = a + b
    print(c)
    coroutine.yield() -- always yield() to fit into debug functions
end)

coroutine.resume(co, 5, 2)
print(getvarvalue(co, "a"))
local a = 4; print(getvarvalue(co, "a"))

--[[
7
local   5
local   5
--]===]

-- Exercise 25.2 --
function setvarvalue(name, value, level, isenv)
    local b = 20
    for i = 1, math.huge do
        local n, v = debug.getlocal(level, i)
        if not n then break end
        if n == name then
            debug.setlocal(level, i, value)
        end
    end     

    for i = 1, math.huge do
        local n, v = debug.getlocal(level, i)
        if not n then break end
        if n == name then return string.format("%s %s", n, v) end
    end

    -- try non-local variables
    local func = debug.getinfo(level, "f").func
    for i = 1, math.huge do
        local n, v = debug.getupvalue(func, i)
        if not n then break end
        if n == name then return "upvalue", v end
    end
    if isenv then return "noenv" end
    -- avoid loop
    -- not found; get value from the environment
    local _, env = setvarvalue("_ENV", value, level, true)
    if env then
        local func = debug.getinfo(level, "f").func
        debug.setupvalue(func, env[name], value)
        
        return "global", env[name]
    else
        -- no _ENV available
        return "noenv"
    end
end
--[===[
local a = 5
print(setvarvalue("a", 10, 2))
print(a)
--[[
a 10
10    
--]]

print(setvarvalue("b", 25, 1))
--]===]

aa = 20
print(setvarvalue("aa", 40, 2))
print(aa)


