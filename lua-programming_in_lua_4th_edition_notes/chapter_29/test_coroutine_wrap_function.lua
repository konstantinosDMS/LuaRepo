co = coroutine.wrap(function ()
        print(pcall(coroutine.yield))
    end)

co() -- It does nothing