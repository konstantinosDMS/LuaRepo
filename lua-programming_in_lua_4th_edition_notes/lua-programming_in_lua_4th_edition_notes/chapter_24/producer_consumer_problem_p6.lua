function receive (producer)
    local status, value = coroutine.resume(producer)
    return value
end

function send (x)
    coroutine.yield(x)
end

function producer ()
    while true do
        local x = io.read()
        send(x)
    end
end
    
function consumer (producer)
    while true do
        local x = receive(producer)
        io.write(x, "\n")
    end
end
  
producer = coroutine.create(producer)
coroutine.create(consumer(producer))
