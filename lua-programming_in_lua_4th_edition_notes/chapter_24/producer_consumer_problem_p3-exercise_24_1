function send(cons, x)
    local _, value = coroutine.resume(cons, x)
    return value
end

function recieve(x)
   return coroutine.yield(x)
end

function producer(cons)
    while true do
        local x = io.read()
        send(cons, x)
    end 
end

function consumer()
    return coroutine.create(function(x)   
        while true do
            io.write(x, '\n')
            x = recieve(x)
        end
    end)
end

producer(consumer())
