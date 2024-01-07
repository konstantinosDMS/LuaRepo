-- Exercise 24.3 --
local lib = require "async-lib"
function run (code)
    local co = coroutine.wrap(function ()
        code()
        lib.stop()
    end)
    co()
    lib.runloop()
end

local co 
co = coroutine.running()
local callback = (function () coroutine.resume(co) end)
function putline (stream, line)
    lib.writeline(stream, line, callback)
    coroutine.yield()
end

co = coroutine.running()
local callback = (function (l) coroutine.resume(co, l) end)
function getline (stream, line)
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
