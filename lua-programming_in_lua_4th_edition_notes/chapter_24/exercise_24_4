-- Exercise 24.4 --
local lib = require "async-lib"
function run (code)
    local co = coroutine.wrap(function ()
        code()
        lib.stop()
    end)
    co()
    lib.runloop()
end

function putline (stream, line)
    local co = coroutine.running()
    local callback = (function () coroutine.resume(co) end)
    lib.writeline(stream, line, callback)
    coroutine.yield()
end

function getline (stream, line)
    co = coroutine.running()
    local callback = (function (l) iter(stream); coroutine.resume(co, l) end)
    lib.readline(stream, callback)
    local line = coroutine.yield()
    return line
end

function iter(fp)
    return function(fp)
        for line in io.lines(fp) do
            return line
        end
    end
end

run(function ()
        local t = {}
        local fp = io.open('test.txt', 'r')
        local out = io.output()
        local inp = fp

        while true do
            local line = getline(inp)
            if not line then break end
            t[#t + 1] = line
        end
        for i = #t, 1, -1 do
            putline(out, t[i] .. "\n")
        end
end)
