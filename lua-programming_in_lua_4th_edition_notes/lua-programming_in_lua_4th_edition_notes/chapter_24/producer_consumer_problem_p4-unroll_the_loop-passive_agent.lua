function producer ()
    while true do
        local x = io.read()
        send(x)
    end
end
    -- produce new value
    -- send it to consumer
function consumer ()
    while true do
        local x = receive()
        io.write(x, "\n")
    end
end

     -- For this particular example, it is easy to change the structure of one of the functions, 
     -- unrolling its loop and making it a passive agent.

function recieve(prod, x)
    local _, val = coroutine.resume(prod, x)
    return val
end

function send(x)
    while true do 
        coroutine.yield(x)
    end
end

-- Define the main coroutine
local mainCoroutine = coroutine.create(function()
    while true do
        local x = io.read()
        producerCoroutine = coroutine.create(function()
            send(x)
        end)
        coroutine.resume(producerCoroutine)

        consumerCoroutine = coroutine.create(function()
            local y = recieve(producerCoroutine)
            io.write(y, "\n")
        end)
        coroutine.resume(consumerCoroutine)
    end
end)

-- Start the main coroutine
coroutine.resume(mainCoroutine)
