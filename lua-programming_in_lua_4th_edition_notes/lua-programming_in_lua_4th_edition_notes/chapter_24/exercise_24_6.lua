-- Exercise 24.6 --
local co

function transfer()
    return coroutine.create(function()
        print('aaa')
        coroutine.yield(co)
    end)
end

function dispatch()
    local co = transfer()
    coroutine.resume(co)
    dispatch()
end

transfer()
dispatch()
