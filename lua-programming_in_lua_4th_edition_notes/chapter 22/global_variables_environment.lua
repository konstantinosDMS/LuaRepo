--[[
print(_G._G == _G) -- true
for n in pairs(_G) do print(n) end
--]]
--[===[
-- Suppose we have a variable name stored in another variable
local varname = "myGlobalVariable"

-- Let's set the value of the global variable
_G[varname] = "Hello, World!"

-- Now, let's use load to get the value of the global variable
local code = "return " .. varname
local getGlobalValue = load(code)
-- print(type(getGlobalValue)) -- anonymous function
-- print(getGlobalValue()) -- Hello World!
-- Execute the compiled code
local value = getGlobalValue()

-- Print the result
print(value) -- Hello, World!

getGlobalValue = _G[varname]
print(getGlobalValue) -- Hello, World!
--]]

-- _G[varname] = value
_G[varname] = value
--]===]
--[===[
function getfield (f)
    local v = _G -- start with the table of global
    for w in string.gmatch(f, "[%a_][%w_]*") do
        v = v[w]         
    end
    return v
end

--[[
local ff = getfield('io.read')
-- print(type(ff)) -- function(read function)
print(ff) -- function: 0x5575830ed4e0
--]]

-- for n in pairs(_G) do print(n) end

function setfield (f, v)
    local t = _G -- start with the table of globals
    for w, d in string.gmatch(f, "([%a_][%w_]*)(%.?)") do
        if d == "." then -- not last name?
            t[w] = t[w] or {} -- create table if absent
            t = t[w] -- get the table
        else -- last name
            t[w] = v -- do the assignment
        end
    end
end

--[[
setfield("t.x.y", 10)
print(t.x.y) --> 10
print(getfield("t.x.y")) --> 10
--]]

local a = {}
a.b = {}
a.b.c = 5
print(a.b.c) -- 5
setfield('a.b.c', 5)
print(getfield('a.b.c'))
--]===]
--[===[
local a = {}
a.b = {}
a.b.c = 5

-- Ensure each level exists
_G[a] = _G[a] or {}
_G[a.b] = _G[a.b] or {}

-- Assign the value
_G[a.b].c = 5
print(_G[a.b].c)  -- Output: 5
--]===]

--[[
local a = {}

function a:new()
    local instance = { x = 5 }
    
    setmetatable(instance, {
        __index = function(self, key)
            return self.x
        end
    })
    
    return instance
end

local aa = a:new()
print(aa.x)  -- Outputs: 5
print(aa.y)  -- Outputs: 5 (due to __index metamethod)
--]]


-- A first approach simply detects any access to absent keys in the global table
--[[
setmetatable(_G, {
    __newindex = function (_, n)
        error("attempt to write to undeclared variable " .. n, 2)
    end,
    __index = function (_, n)
        error("attempt to read undeclared variable " .. n, 2)
    end,
})
--]]
-- a = 10 -- global_vars.lua:103: attempt to write to undeclared variable a
-- print(a) -- global_vars.lua:104: attempt to read undeclared variable a

-- local a = 5 -- it's ok, local a = 5 is a declared variable
-- print(a) -- 5

-- print(false or false) -- false
--[[
local function setDeclare(var, val)
    rawset(_G, var, val or false)
end

setDeclare('kostas', 5)
print(kostas) -- 5
--]]
--[[
setmetatable(_G, {__newindex = function (t, n, v)
    local w = debug.getinfo(2, "S").what  -- called from regular lua function
    if w ~= "main" and w ~= "C" then
        error("attempt to write to undeclared variable " .. n, 2)
    end
        rawset(t, n, v)
    end
})
--]]
--[[
local a = 10 -- it's ok = main
-- The call debug.getinfo(2, "S") returns a table whose field what tells whether the 
-- function that called the metamethod is a main chunk, a regular Lua function, or a C function.

function testMe()
    b = 20 -- global_vars.lua:148: attempt to write to undeclared variable b, =function
end

testMe()
--]]
--[[
setmetatable(_G, {
    __newindex = function (t, n, v)
        local w = debug.getinfo(2, "S").what  -- kaleitai apo regular lua function
        if w ~= "main" and w ~= "C" then
            error("attempt to write to undeclared variable " .. n, 2)
        end
            rawset(t, n, v)
    end,
    __index = function(t, n)
         if rawget(_G, n) == nil then
           print (n .. ' is undeclared ') -- b is undeclared
         end
    end,
})
--]]
-- print(kk) -- kk is undeclared 
-- local kk = nil
--print(kk) -- nil
--]]
--[[
c = nil -- rawset() does not allow it ot be declared
print(c) -- c is undeclared
--]]
--[[
local declaredNames = {}
setmetatable(_G, {
    __newindex = function (t, n, v)
        if not declaredNames[n] then
            local w = debug.getinfo(2, "S").what
            if w ~= "main" and w ~= "C" then
                error("attempt to write to undeclared variable "..n, 2)
            end
            declaredNames[n] = true
        end
        rawset(t, n, v) -- do the actual set
    end,
    __index = function (_, n)
        if not declaredNames[n] then
            error("attempt to read undeclared variable "..n, 2)
        else
            return declaredNames[n]
        end
    end,
})

-- print(_ENV == _G) -- true
_ENV['r'] = 55 -- Also _G has r = 55 variable
--]]
--[[
The Lua distribution comes with a module strict.lua that implements a global-variable check that
uses essentially the code in Figure 22.2, “Checking global-variable declaration”. It is a good habit to use
it when developing Lua code.    
--]]

--[[
a = 5 -- calls __newindex
print('a = ' .. a) -- 5, call a from _G

b = nil -- calls __newindex
print('b = ' .. tostring(b)) -- calls __index
print(b) -- true cause __index returns true, not the actual _G[b] = nil value

local a -- normal declaration
a = 5 -- write to _G
print('a = ' .. a) -- 5, call a from _G
--]]

--[[
load('strict.lua')
require('strict.lua')
--]]

--[[
Instead, we will start with the concept of free names. A free name is a name that is not bound to 
an explicit declaration, that is, it does not occur inside the scope of a corresponding local 
variable. For instance, both x and y are free names in the following chunk, but z is not:
--]]

--[[
local z = 10
x = y + z -- x, y free vars
--]]
--[[
-- equivalent to --
local z = 10
_ENV.x = _ENV.y + z
--]]
--[[
-- compiler's chunk of code --
local _ENV = 'some_value'
return function (...)
    local z = 10
    _ENV.x = _ENV.y + z
end
--]]
--[[
-- or better --
local _ENV = 'the_global_environment'
return function (...)
    local z = 10
    _ENV.x = _ENV.y + z
end
--]]

--[[
a = 10
local print, sin = print, math.sin
_ENV = nil
print(13) --> 13 -- print, sin are local declared
print(sin(13)) --> 0.42016703682664, print, sin are local declared
-- print(math.cos(13)) -- error!,  attempt to index a nil value (upvalue '_ENV')
-- print(a) -- global_vars.lua:245: attempt to index a nil value (upvalue '_ENV'), 
            -- Any assignment to a free name (a “global variable”) will raise a similar error.
--]]
--[[
a = 13
local a = 12 -- (local)
print(a) --> 12
print(_ENV.a) --> 13 (global)
--]]

--[[
-- We can do the same with _G: --
a = 13 -- global
local a = 12
print(a) --> 12 (local)
print(_G.a) --> 13 (global)
--]]

--[[
local x = 10
local _ENV = { y = 20 }

-- print(x) -- Accessing local variable, global_vars.lua:266: attempt to call a nil value (global 'print')
-- print(y) -- Accessing variable from the custom environment
--]]

--[[
local myVariable = "Hello, World!"
_G.myVariable = myVariable

print(myVariable)   -- Accessing the local variable directly, Hello, World!
print(_G.myVariable) -- Accessing the global variable through _G, Hello, World!
--]]

--[[
Usually, _G and _ENV refer to the same table but, despite that, they are quite different entities. _ENV is a
local variable, and all accesses to “global variables” in reality are accesses to it. _G is a global variable with
no special status whatsoever. By definition, _ENV always refers to the current environment; _G usually
refers to the global environment, provided it is visible and no one changed its value.    
--]]
--[[
-- change current environment to a new empty table
_ENV = {}
--_ENV = {_G = _G}
--local print = _ENV._G.print
a = 1 -- create a field in _ENV
print(a) --> stdin:4: attempt to call a nil value (global 'print')
--]]
--[[
a = 15 -- create a global variable
_ENV = {g = _G} -- change current environment
a = 1 -- create a field in _ENV
g.print(_ENV.a, g.a) --> 1 15
--]]
--[[
-- or --
a = 15 -- create a global variable
_ENV = {_G = _G} -- change current environment
a = 1 -- create a field in _ENV
_G.print(_ENV.a, _G.a) --> 1 15
--]]

--[[
a = 1
local newgt = {}-- create new environment
setmetatable(newgt, {__index = _G})
_ENV = newgt-- set it
print(a) --> 1
a = 10
print(a, _G.a)--> 10 1
_G.a = 20
print(_G.a) --> 20
--]]
--[[
_ENV = {_G = _G}
local function foo ()
    _G.print(a) -- compiled as '_ENV._G.print(_ENV.a)'
end

a = 10
foo() --> 10
_ENV = {_G = _G, a = 20}
foo() --> 20
--]]
--[[
a = 2
do
    local _ENV = {print = print, a = 14}
    print(a) --> 14
end
print(a) --> 2 (back to the original _ENV)
--]]
--[[
function factory (_ENV)
    return function () return a end
end

f1 = factory{a = 6}
f2 = factory{a = 7}
print(f1()) --> 6
print(f2()) --> 7
--]]
--[[
-- for modules --
local M = {}
local _G = _G
_ENV = nil

-- or --
-- module setup
local M = {}
-- Import Section:
-- declare everything this module needs from outside
local sqrt = math.sqrt
local io = io
-- no more external access after this point
_ENV = nil
--]]

--[[
env = {}
loadfile("config.lua", "t", env)()
--]]
--[[
f = load("b = 10; return a")
env = {a = 20}
debug.setupvalue(f, 1, env)
print(f())--> 20
print(env.b)--> 10
--]]

--[[
prefix = "_ENV = ...;"
f = loadwithprefix(prefix, io.lines(filename, "*L"))
-- ...
env1 = {}
f(env1)
env2 = {}
f(env2)
--]]

--[===[
-- Exercise 22.1 --

function getfield (f)
    local v = _G -- start with the table of globals
    for w in string.gmatch(f, "[%a]+", 1) do
        v = v[w]
    end
    return v
end

local a = getfield('io.write')
print(a)
--]===]

--[[
-- Exercise 22.2 --

local foo
do
    local _ENV = _ENV
    for v in pairs(_ENV)
 do
    print(v)
 end
    function foo () print(X) end
end
-- print(local_ENV) -- nil
X = 13
_ENV = nil
foo() -- 13
X = 0 -- global_vars.lua:406: attempt to index a nil value (upvalue '_ENV')
--]]

--[[
-- Exercise 22.3 --
local print = print
function foo (_ENV, a)
    print(a + b)
end
foo({b = 14}, 12) -- 26
foo({b = 10}, 1) -- 11
--]]
--[[
local print = print
function foo (_ENV, a)
    print(a + b)
end
foo({b = 14}, 12) -- 26
foo({b = 10}, 1) -- 11

do
    local print = print
    function foo(_ENV, a)
        print(a + b)
    end
end

foo({b = 14}, 12)
foo({b = 10}, 1)
_ENV = nil
--]]
