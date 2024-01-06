function recieve(prod, x)
    local _, val = coroutine.resume(prod, x)
    return val
end

function send(x)
    coroutine.yield(x)
end

function producer()
    return coroutine.create(function(a, b) 
        while true do
            local x = io.read()
            send(x)
        end
    end)
end

function consumer(prod)
    while true do
        local x = recieve(prod)
        io.write(x, '\n')
    end
end

coroutine.resume(consumer(producer()))
