-- dofile(), loadfile(): loads a chunk of code,
-- loadfile() does not run it bt it compiles it and returns it as a function
-- dofile() => raise errors
-- load, loadfile() => returns error codes (returns nil plus error message)
-- whn we call a file several times we call loadfile once and
-- call its results several times (it compiles the files once)
-- load reads a chunk from a function or a string not from a file
-- load, loadfile accepts precompiled code

--[[
-- dofile() code --
function dofile(filename)
    local f = assert(loadfile(filename)) -- assert raise the error on loadfile error
    return f()
end
--]]

--i = 0;
--f = load("i = i + 1")

--[[
f() -- i = i + 1
print(i)  -- 1
f()
print(i)  -- 2
--]]

-- or --

--i = 0;
--[[
print(i)
s = "i = i + 1"
f = load(s)
f() 
print(i) -- 1
--]]

--[[
s = "i = i + 1"
load(s)()
print(i) -- 1 => it returns the function wth body i = i + 1 and running it 
--]]

--[[
s = "i = i + 1"
assert(load(s))()
print(i)  --1
--]]

--[[
f = load("i = i + 1")
f() -- 1, 2
i = 0
f()
print(i) -- 1
--]]

--[===[
i = 0
local i = 1
f1 = load("i = i + 1; print(i)") -- this form has not scope, so ti uses the global 
-- variable i = 0
-- it uses 2 compilations , one for i = i + 1 and one as function () i = i + 1 end
f1()  -- 1
-- print(i) -- 1
local f2 = function() i = i + 1; print(i) end -- this form has lectical scope, so it 
-- use the local variable i = 1
-- it is more quick than first case cause it uses on one compilation the function () .. end scope
f2() -- 2
-- print(i) -- 2
--]===]

--[[
print("Enter an expression:")
expression = io.read()
func = assert(load("return " .. expression))
print("The value of the expression is " .. func()) -- 1 + 2 = 3
--]]

--[[
print "enter function to be plotted (with variable 'x'):"
local line = io.read()
local f = assert(load("return " .. line))
for i = 1, 20 do
    x = i -- global 'x' (to be visible from the chunk)
    print(string.rep("*", f()))
end

print(x) -- x = 20, x = global variable
--]]

-- load() wth first argument as reader function, 
-- reader function called successively until to get nil
-- following code is equivalent to loadfile()

--[===[
local filename = "test9.txt"

-- Define a reader function using io.lines
local function reader()
    -- return io.lines(filename, "*L")
    return io.lines(filename, 1024) -- one chunk of 1024 bytes
end

-- Load and execute each line separately
for line in reader() do
    local chunk, err = load(line, "@" .. filename)
    --[[
        This line loads the Lua code from the line variable and associates 
        it with the chunk name formed by concatenating @ with the value of 
        filename. The @ character is often used to indicate that the chunk 
        name represents a source file.
    --]]

    if chunk then
        local success, result = pcall(chunk)
        if success then
            print("Execution successful for line:", line)
        else
            print("Error during execution for line '" .. line .. "':", result)
        end
    else
        print("Error loading chunk for line '" .. line .. "':", err)
    end
end
--]===]
-- Lua treats any independent chunk as the body of an anonymous 
-- variadic function. For instance, 
-- load("a = 1") -- returns the equivalent of the following expression:
-- function (...) a = 1 end

--[[
f = load("a = 1")
f()
print(a) -- 1
--]]

--[[
print(a) 

local kk = function (...) a = 1 end
kk(1, 2)
print(a) -- 1
--]]

--[[
f = load("local a = 10; print(a + 20)") -- load can have local vars
f() -- 30
--]]

--[[
print "enter function to be plotted (with variable 'x'):"
local line = io.read()
local f = assert(load("local x = ...; return " .. line .. ", x"))
for i = 1, 20 do
    line, x = f(i) -- to get the local x
    print(string.rep("*", line), x)
end

print(x) -- 20
--]]

-- The functions load and loadfile never raise errors. In case of any kind of error, 
-- they return nil plus an error message:
-- print(load("i i"))  -- nil [string "i i"]:1: syntax error near 'i'
--[[

-- function foo() into foo.lua -- 
function foo(a)
    print('a')
end

local f = loadfile("foo.lua") -- compiles foo.lua chunk
if f then
    f() -- define foo() by running the code
    foo("ok")
else
    print("Error loading file")
end
--]]
-- or --
--[[
local f = loadfile("foo.lua") -- executes the code
if f  then 
    print(foo('kosytas')) -- nil
    f() -- define foo = function () print('a') end
    foo("ok") -- run the foo()
end
--]]

--[[
lua compiler for precompiled lua files, called as binary chunk
luac -o mylua.lc mylua.lua

precompiled code is running wth the command lua mylua.lc
and it goes everywhere i can use precompiled code load, loadfile
--]]
--[[
p = loadfile("test10.txt")
f = io.open("test11.txt", "wb")
f:write(string.dump(p))
f:close()
--]]
--[[
print "enter a number:"
n = io.read("n")
if not n then error("invalid input") end
--]]
--[[
print("Enter a number:")
n = assert(io.read("*n"), "invalid input")
--]]
--[[
-- Beware, however, that assert is a regular function. As such, Lua always evaluates 
-- its arguments before calling the function. If we write something like
n = io.read()
assert(tonumber(n), "invalid input: " .. n .. " is not a number")
Lua will always do the concatenation, even when n is a number. It may be wiser to use an 
explicit test in such cases
--]]

--[[
When a function finds an unexpected situation (an exception), it can assume two basic 
behaviors: it can return an error code (typically nil or false) or it can raise an error, 
calling error. There are no fixed rules for choosing between these two options, but I use 
the following guideline: an exception that is easily avoided should raise an error; 
otherwise, it should return an error code, suppose x is table then wth the following exception
    local res = math.sin(x)
    if not res then  -- error?
        error-handling code

    However, we could as easily check this exception before calling the function:
        if not tonumber(x) then
            error handling code

    -- here the io.read() should run to bring the error
    -- so there is no way to handle errors before running
    -- the function

    local file, msg
    repeat
        print "enter a file name:"
        local name = io.read()
        if not name then return end
        -- no input
        file, msg = io.open(name, "r")
        if not file then print(msg) end
    until file

    file = assert(io.open(name, "r")) --> stdin:1: no-file: No such file or directory
    This is a typical Lua idiom: if io.open fails, assert will raise an error. Notice how the error message,
    which is the second result from io.open, goes as the second argument to assert.
--]]
--[===[
-- Error handling --
local ok, msg = pcall(function () -- pcall() catches the error retrurn the
    -- Error code wth whtever value i pass to it
    -- some code
    if --[[ unexpected_condition --]] then error() --[[throw exception - Error object]]-- end
    -- some code
    -- print(a[i]) -- potential error: 'a' may not be a table
    -- some code
    end)
    if ok then
        -- no errors while running protected code
        regular code
    else
        -- protected code raised an error: take appropriate action
        error-handling code
    end
--]===]
-- The function pcall calls its first argument in protected mode, so that it 
-- catches any errors while the function is running. The function pcall never 
-- raises any error, no matter what. If there are no errors, pcall returns true,
-- plus any values returned by the call. Otherwise, it returns false, plus the error message
-- Despite its name, the error message does not have to be a string; a better name is error object, because
-- pcall will return any Lua value that we pass to error:
--[[
local status, err = pcall(function () error({code=121}) end)
print(err.code) --> 121
--]]
-- These mechanisms provide all we need to do exception handling in Lua. We throw an exception with
-- error and catch it with pcall. The error message identifies the kind of error.

--[[
When there is an internal error (such as an attempt to index a non-table value), Lua
generates the error object, which in that case is always a string; otherwise, the error object is the value
passed to the function error. Whenever the object is a string, Lua tries to add some information about
the location where the error happened:
--]]
--[[
local status, err = pcall(function () error("my error") end)
print(err)  --> stdin:1: my error
-- The location information gives the chunk's name (stdin, in the 
-- example) plus the line number (1, in the example).
--]]
--[[
The function error has an additional second parameter, which gives the level where it should report the
error. We use this parameter to blame someone else for the error. For instance, suppose we write a function
whose first task is to check whether it was called correctly:
--]]
--[===[
function foo_1(str)
    if type(str) ~= "string" then
        error("string expected")  -- here is whr lua reports the error
        -- it need to report foo_1() as the function error
    end
    -- regular code
    end

-- foo_1({x=1})

-- Then, someone calls this function with a wrong argument:
function foo_2 (str)
    if type(str) ~= "string" then
        error("string expected", 2)
    end
    -- regular code
end

foo({x = 1}) -- here is whr lua reports the error function, who call 
-- the error function, lvl_1 = owr own function foo(str), lvl_2 is the
-- caller

-- xpcal(function() ... end, error_message_handler_function() ...)
-- here we have access to stack whr first error function () throws
-- the error object or string with debug.debug error_handles to search then
-- error on the stack, and debug.traceback to traceback the error
-- end
-- ) end)
--]===]
--[====[
--  Exercise 16.1  --

-- local loadwithprefix = function(...) return (...) .. ":" .. 1 + 2 end
-- print(loadwithprefix('kostas')) -- kostas: 3 --]]
-- it needs metatable to set the enovronment variable to local scope
local loadwithprefix_1 = function(declaration, prefix, code)
    local code1, code2, code3, error1, error2, error3 = nil, nil, nil, nil, nil, nil
    return function()
        code1 = load(declaration)
        if code1 then
            code2 = load(prefix)
            if code2 then 
                code3 = load(code)
                if code3 then
                    return code1, code3, code2
                else 
                    error('Error when compiling code')
                end
            else
                error('Error while compiling prefix')
            end 
        else
            print('error compiling declaration')
        end
    end
end

local declaration = 'local j = 0'
local code = 'j = j + 3'
local prefix = 'return j'  

local res1, res2, res3, err, result
result = loadwithprefix_1(declaration, prefix, code)
res1, res2, res3, err = result ()

if res1 ~= nil and res2 ~= nil and res3 ~= nil then
    print(res1(), res2(), res3())
end
--]====]
--[===[
local loadwithprefix_2 = function(prefix, code)
	local var1, var2 , error1, error2 = nil, nil, nil, nil 
	return function()
		local var1, error1 = load('local ff = ' .. prefix .. '; return ff')
		if var1 ~= nil then
			local var2, error2 = load(code)
			if var2 ~= nil then 
				return var1, var2
			else
				print('Failed load the chunk - code')
			end
		else 
			print('Failed load the chunk - prefix')
		end
	end
end

prefix = '\'kostas :\''
code = 'i = 0; i = i + 3; return i'
myfunc = loadwithprefix_2(prefix, code)
res1, res2 = myfunc()
if res1 ~= nil and res2 ~= nil then
    print(res1(), res2())  -- kostas : 3
else 
    print('Error ...')
end
--]===]

--[[
1) no concatentation meaning every piece of data should be loaded() seperately

2) should have functional implementation 
function(...) ... i = i + 1 end (load = functional => implentation)

3) should be implement only wth load() function()    

4) the data should be in the format
fff('return i')
fff('i = i + 3') -- to demonstrate i = i + 3; return i
--]]

--[===[
-- [[ lua's implementation of load() function wth different chunks of code, prefix and code chunks]]
local rr
local cnt = 0

rr = function(...) 
        cnt = cnt + 1
        if cnt  == 2 then return ... end
        if cnt < 2 then return rr(..., cnt) end
        return ... 
    end
  
local dd = function(...) local g = 0; g = g + 3; print(rr(g)) end
print(dd())
--]===]
--[===[
-- implenetation wth load() function 
local loadwithprefix_3 = function(prefix, code)
    local hex_prefix, error_prefix, hex_code, error_code = nil, nil, nil, nil

    hex_prefix, error_prefix = load(prefix)
    if hex_prefix then
        hex_code, error_code = load(code)
        if hex_code then
            return hex_prefix, hex_code
        end
    end
end

prefix = 'return i'
code = 'i = 0; i = i + 3'
local hx_prefix, hx_code = loadwithprefix_3(prefix, code)
if hx_prefix and hx_code then
    hx_code()
    print(hx_prefix()) -- 3
end
--]===]
--[[
local function loadwithprefix(prefix, code)
    local prefxflg = true
    return function(...) 
        local arg = table.pack(...)
        if prefxflg then 
            prefxflg = false
            return load('local x = ' .. arg[1] .. prefix)
        else 
            return load(' return ' .. code)
        end
      end
end

local line = io.read()
local prefix = ' return x; '
local code = function() return line end
local fg = loadwithprefix(prefix, code())

for i = 1, math.huge do
    print(string.rep('*', fg(i)()))    
end
--]]

-- This is the better solution i was able to make it run as the assignment asks for --
--[[
function loadwithprefix(prefix, code)
    local prfxflg = false

    return function(...)
        local x = select(1, ...)
        local env = { x = x, __index = { _G = _G } }

        if not prfxflg then
            prfxflg = true
            return load(prefix, nil, nil, env)
        else
            return load(' return ' .. code(), nil, nil, env)
        end
    end
end

local aa = io.read()
local prefix = ' local x = x ; return x; '
local code = function() return aa end
local res = loadwithprefix(prefix, code)

for i = 1, 10 do
    print(string.rep('*', res(i)()))
end
--]]

--[[
-- Exercise 16.2 --

local multiload = function(prefix, suffix, code)
    local hex_data, err, x_data, hex_code, local_hex_data = nil, nil, nil, nil, nil
    local local_hex_code, err = load(tostring(prefix), "local-hex-code", "t", _G)
    if local_hex_code then 
        local_hex_data, err = pcall(local_hex_code)
        if not local_hex_data then print('Error on local-data', err) end
    else print('Error on local-hex-code', err) end

    local hex_code, err = load(code, "hex_code", "t", _G)
    if hex_code ~= nil then 
        hex_data, err = pcall(hex_code)
        if not hex_data then print('Error on hex_data', err, _G) end
    else print('Error in hex_code - lines', err) end

    local x_code, err = load(suffix, 'print(x)', 't', _G)
    if x_code ~= nil then 
        x_data, err = pcall(x_code) 
        if not x_data then print('Error on x_data', err) end
    else print('Error in x_code - print()', err) end
end

local prefix, suffix = '', ''

prefix = ' x = 10; '
suffix = ' print(x); '

multiload(prefix, suffix, io.lines("test13.txt", "*L"))
--]]
--[[
local x = 10

-- Function to execute loaded code
local function executeLoadedCode(code)
    local env = { x = x }  -- Create a custom environment with the desired local variables
    setmetatable(env, { __index = _G })  -- Allow access to global variables if needed

    local chunk, err = load(code, "chunk", "t", env)
    if chunk then
        local success, result = pcall(chunk)
        if not success then
            print("Error executing loaded code:", result)
        end
    else
        print("Error loading code:", err)
    end
end

-- Example usage
local loadedCode = 'print(x)'
executeLoadedCode(loadedCode)
--]]
--[[
-- Exercise 16.3 --

function stringrep (s, n)
    local str = str or ''
    str = str .. ' function stringrep_' .. n .. '(s) '
        
    local r = ""
    if n > 0 then
        while n > 1 do
            if n % 2 ~= 0 then r = r .. ' ' .. s end
            s = s .. ' ' .. s
            n = math.floor( n /2 ) 
        end
        r = r .. ' ' .. s
        str = str .. ' ' .. r .. ' ' .. ' return  ' .. ' end '
        return str
    end
end

local func, err, res_func = nil, nil, nil
code = stringrep("print(s)", 2)
print(code) --  function stringrep_2(s)   print(s)  return  end 
func, err = load(code, "=load", "t", _G)
if not func then print('Failed loading code') end
res_func, err = pcall(func)
if res_func then 
    stringrep_2('kostas')
else print('Error loading func')
end
--]]

--  Exercise 16.4  -- 
	
--[[
local function f()
    error("An error occurred!")
end

local success, result = pcall(pcall, f)

print(success)  -- Output: true cause first pcall is valid called wth pcall 
                -- first argument and f function as second argument
print(result)   -- Output: false cause 2nd pcall f() throws an exception
--]]
--[[
local function f() end

local success, result = pcall(pcall, f())  -- false bad argument #1 to 'pcall' (value expected)
print(success)
print(result)
--]]

