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
--]===]
--[[
print(debug.traceback())

stack traceback:
        /home/konstantinos/Downloads/lua/apps/reflection.lua:16: in main chunk
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
--[[
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
--]]

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
    a = 9
    print(a)
    coroutine.yield()
end

-- Create a coroutine
local co = coroutine.create(coroutineFunction)

-- Start the coroutine
coroutine.resume(co, 5)

-- Get the local variable (at level 0 -> (coroutine's chunk), 
-- at index 1 -> (coroutine's environment), at index 2 --> caller of the testMe())

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
function testMe(co)
    
    -- Start the coroutine
    -- coroutine.resume(co, 5)
    
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
    
end

-- Coroutine function
local function coroutineFunction(a)
    local localVar = "Hello from coroutine!"
    a = 9
    print(a)
    coroutine.yield()
end

local co = coroutine.create(coroutineFunction)
coroutine.resume(co, 5)

testMe(co)
--]]
--[[
5
Local variable name:    a
Local variable value:   5    
--]]
--[[
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
    a = a + 1
    print(c)
    --function bb(a)
        --print(a)
    --end
    coroutine.yield() -- always yield() to fit into debug functions
end)

coroutine.resume(co, 5, 2)
print(getvarvalue(co, "a"))
local a = 4; print(getvarvalue(co, "a"))
--]]
--[[
7
local   5
local   5
--]]

--[===[
-- Exercise 25.2 --
function setvarvalue (name, val, level, isenv)
    local value
    local found = false
    local j
    level = (level or 1) + 1 -- try local variables
    for i = 1, math.huge do
        local n, v = debug.getlocal(level, i)
        if not n then break end
        if n == name then
            j = i
            value = v
            found = true
        end
    end
    if found then debug.setlocal(level, j, val); return "local", value end -- try non-local variables
    local func = debug.getinfo(level, "f").func
    for i = 1, math.huge do
        local n, v = debug.getupvalue(func, i)
        if not n then break end
        if n == name then 
            return "upvalue", v 
        end
    end
    if isenv then return "noenv" end -- avoid loop, not found; get value from the environment
    local _, env = setvarvalue("_ENV", val, level, true)
    if env then
        local i = 0
        for k, v in pairs(env) do
            i = i + 1 
            if k == name then    
               env[name] = val
               return "global", env[name]
            end
        end
    else -- no _ENV available
        return "noenv"
    end --]]
end

--[[
    global  40
    40
--]]
--[[
local a = 5
setvarvalue("a", 10, 1)
print(a)
--]]
--[[
a 10
10    
--]]

--[[
b = 120
setvarvalue("b", 25)
print(b)
-- 25
--]===]

--[===[
-- Exercise 25.3 --
 local varsFound = {}

function getvarvalue (name, level, isenv)
    local value
    local found = false
    local tmp = {}

    level = (level or 1) + 1 -- try local variables
    for i = 1, math.huge do
        local n, v = debug.getlocal(level, i)
        if not n then break end
        if n == name then
            value = v
            found = true
        end
    end
    if found then tmp[name] = value; table.insert(varsFound, tmp); return varsFound; end -- try non-local variables
    local func = debug.getinfo(level, "f").func
    for i = 1, math.huge do
        local n, v = debug.getupvalue(func, i)
        if not n then break end
        if n == name and name == "_ENV" then return "upvalue", v 
        elseif n == name then  
            tmp[name] = v
            table.insert(varsFound, tmp)
            return varsFound
        end
    end
    if isenv then return "noenv" end -- avoid loop, not found; get value from the environment
    local _, env = getvarvalue("_ENV", level, true)
    if env then
        tmp[name] = env[name]
        table.insert(varsFound, tmp)
        return varsFound
    else -- no _ENV available
        return "noenv"
    end
end

local a = 130
local gg = getvarvalue("a")

b = 160
gg = getvarvalue("b")

local f1 = load(' function myfunc(name, level, isenv) local kostas =  555; getvarvalue(name, level, isenv); end ')

f1()

myfunc('kostas')

for i = 1, #varsFound do
    for k, v in pairs(varsFound[i]) do
        print(k, v)
    end
end
--]===]

--[===[
-- Exercise 25.4 --
-- Function to get variable values with lexical scoping
function getvarvalue(name, level)
    local value
    local found = false
    level = (level or 1) + 1

    -- Try local variables
    for i = 1, math.huge do
        local n, v = debug.getlocal(level, i)
        if not n then break end
        if n == name then
            value = v
            found = true
        end
    end

    if found then return "local", value end

    -- Try non-local variables
    local func = debug.getinfo(level, "f").func
    for i = 1, math.huge do
        local n, v = debug.getupvalue(func, i)
        if not n then break end
        if n == name then return "upvalue", v end
    end

    return "noenv"
end

function debug2()
    local env = {}  -- Create a new environment
    env.print = _G.print
    -- Set __index metamethod to use getvarvalue for variable access
    setmetatable(env, { __index = function(_, name)
        local value
        local varType
        varType, value = getvarvalue(name, 4)  -- Use level 3 to skip debug2 and debug1 frames
        if varType == "local" or varType == "upvalue" then
            return value
        else
            error("Variable '" .. name .. "' not found", 2)
        end
    end })

    while true do
        io.write("debug> ")
        local line = io.read()
        if line == "cont" then break end

        -- Run the commands in the created environment
        assert(load('print( ' .. line .. ' ) ' , "debug2", "t", env))()
    end
end

-- Test the improved debug2 function
local x = 10
debug2() 

function testDebug()
    local y = 20
    debug2()
end

testDebug()
--]===]

--[===[
-- Exercise 25.5 -- 

function getvarvalue(name, level)
    local value
    local found = false
    level = (level or 1) + 1

    -- Try local variables
    for i = 1, math.huge do
        local n, v = debug.getlocal(level, i)
        if not n then break end
        if n == name then
            value = v
            found = true
        end
    end

    if found then return "local", value end

    -- Try non-local variables
    local func = debug.getinfo(level, "f").func
    for i = 1, math.huge do
        local n, v = debug.getupvalue(func, i)
        if not n then break end
        if n == name then return "upvalue", v end
    end

    return "noenv"
end

function debug2()
    local env = {}  -- Create a new environment
    env.print = _G.print
    -- Set __index metamethod to use getvarvalue for variable access
    setmetatable(env, { __index = function(_, name)
        local value
        local varType
        varType, value = getvarvalue(name, 4)  -- Use level 3 to skip debug2 and debug1 frames
        if varType == "local" or varType == "upvalue" then
            return value
        else
            error("Variable '" .. name .. "' not found", 2)
        end
    end })

    local t_start, t_end, t_line, t_val
    while true do
        io.write("debug> ")
        local line = io.read()
        if line == "cont" then break end
        t_start, t_end = string.find(line, "=", 1)
        if t_start ~= nil and t_end ~= nil then 
            local t_line = tostring(string.sub(line, t_start - 1, t_end - 1))
            local t_val = tonumber(string.sub(line, t_end + 1, #line))
            local sbj_1 = t_line .. " = " .. t_val
            local sbj_2 = ' print( ' .. t_line .. ')'
            
            -- Run the commands in the created environment
            assert(load( sbj_1 .. ' ' .. sbj_2, "debug2", "t", env))()
        else
            assert(load(' print( ' .. line .. ' ) ' , "debug2", "t", env))()
        end
    end
end

-- Test the improved debug2 function
-- local x = 10
-- debug2() 

function testDebug()
    local y = 20
    debug2()
end

testDebug()

--]===]

--[===[
-- Exercise 25.6 --

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
 
 local array = {}
 for k, v in pairs(Counters) do
    table.insert(array, {key = k, value = v})
 end

 table.sort(array, function(a, b) return a.value > b.value end)
Counters = array

 for func, count in pairs(Counters) do
     print(getname(func), count)
 end
 --]===]

-- Exercise 25.8 --
--[===[
local debug = require "debug"

-- Maximum "steps" that can be performed
local steplimit = 1000
local count = 0

-- Counter for steps
-- Set of authorized functions
local validfunc = {}

-- Hook function to check if the called function is authorized
local function hook(event)
    local info
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
    print(string.format('func_name:%s, count:%d', info.name, count))
end

-- Load chunk
local chunkEnv = setmetatable({}, { __index = _G })
local f, errorMsg = loadfile("test_lua_exercise_25_8.lua", "t", chunkEnv)
if not f then
    error("Error loading file: " .. errorMsg)
end

-- Set hook
debug.sethook(hook, "c", 100)

-- Run chunk
f()

-- Capture the functions defined in the chunk and add them to the validfunc table
for k, v in pairs(chunkEnv) do
    if type(v) == "function" then
        validfunc[k] = true
    end
end

-- Set hook to nil to disable it after the execution
debug.sethook()

-- Print the authorized functions
for k, v in pairs(validfunc) do
    print(k, v)
end
--]===]

-- Exercise 25.7 --
local breakpoints = {}

function callhook(event, line)
    local info = debug.getinfo(2, "n")
    if breakpoints[info.func] then
        debug.sethook(linehook, "l")
    end
end

function linehook(event, line)
    if event == 'line' then
        local info = debug.getinfo(2, "n")
        local breakpoint = breakpoints[info.func]
        if breakpoint and line == breakpoint.line then
            debug.debug()
        end
    end
end

function setbreakpoint(func_name, line)
    local func = _G[func_name]
    if func then
        breakpoints[func] = { line = line }
        debug.sethook(callhook, "c")
    else
        error("Function not found: " .. func_name)
    end
end

function removebreakpoint(func_name)
    local func = _G[func_name]
    if func then
        breakpoints[func] = nil
        debug.sethook()
    else
        error("Function not found: " .. func_name)
    end
end

function myfunc()
    print('a')
    print('b')
    print('c')
    print('d')
    print('e')
end

-- Set a breakpoint in myfunc at line 3
setbreakpoint('myfunc', 3)
myfunc()

-- Remove the breakpoint in myfunc
removebreakpoint('myfunc')
myfunc()

