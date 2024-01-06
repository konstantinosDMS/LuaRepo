lib.runloop();
lib.readline(stream, callback);
lib.writeline(stream, line, callback);
lib.stop();

local cmdQueue = {} -- queue of pending operations

local lib = {}

function lib.readline (stream, callback)
    local nextCmd = function ()
        callback(stream:read())
    end
    table.insert(cmdQueue, nextCmd)
end

function lib.writeline (stream, line, callback)
    local nextCmd = function ()
        callback(stream:write(line))    
    end
    table.insert(cmdQueue, nextCmd)
end

function lib.stop ()
    table.insert(cmdQueue, "stop")
end

function lib.runloop ()
    while true do
        local nextCmd = table.remove(cmdQueue, 1)
        if nextCmd == "stop" then
            break
        else
            nextCmd() -- perform next operation
        end
    end
end

return lib

local t = {}
local inp = io.input() -- input stream
local out = io.output() -- output stream

for line in inp:lines() do
    t[#t + 1] = line
end

for i = #t, 1, -1 do
    out:write(t[i], "\n")
end

local t = {}
local inp = io.input()
-- input stream
local out = io.output()
-- output stream
for line in inp:lines() do
t[#t + 1] = line
end
for i = #t, 1, -1 do
out:write(t[i], "\n")
end

local lib = require "async-lib"
local t = {}
local inp = io.input()
local out = io.output()
local i
-- write-line handler
local function putline ()
	i = i - 1
	if i == 0 then -- no more lines?
		lib.stop() -- finish the main loop
	else -- write line and prepare next one
		lib.writeline(out, t[i] .. "\n", putline)
	end
end

-- read-line handler
local function getline (line)
	if line then
		t[#t + 1] = line
		lib.readline(inp, getline)
	else
		i = #t + 1
		putline()
	end
end-- not EOF?

-- save line
-- read next one
-- end of file
-- prepare write loop
-- enter write loop
lib.readline(inp, getline)
lib.runloop() -- ask to read first line
-- run the main loop

local lib = require "async-lib"
function run (code)
    local co = coroutine.wrap(function ()
    code()
    lib.stop() -- finish event loop when done
    end)
    co() -- start coroutine
    lib.runloop() -- start event loop
end

function putline (stream, line)
    local co = coroutine.running() -- calling coroutine
    local callback = (function () coroutine.resume(co) end)
    lib.writeline(stream, line, callback)
    coroutine.yield()
end

function getline (stream, line)
    local co = coroutine.running() -- calling coroutine
    local callback = (function (l) coroutine.resume(co, l) end)
    lib.readline(stream, callback)
    local line = coroutine.yield()
    return line
end

run(function ()
    local t = {}
    local inp = io.input()
    local out = io.output()
    while true do
        local line = getline(inp)
        if not line then break end
        t[#t + 1] = line
    end
    for i = #t, 1, -1 do
        putline(out, t[i] .. "\n")
    end
end)

