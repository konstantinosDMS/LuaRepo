--[[
function cc(x)
  co = coroutine.create (function (y)
      --local z = x + y 
      print("First  args: ", x+y)
      coroutine.yield(x+y)
      print("Second args: ",  x+y)
      coroutine.yield(x+y+1)
    end)
    --return co
    print(coroutine.resume(co, 1))
    print(coroutine.resume(co, 2))
end

--cc(55)

    local co = cc(55)
    local ff, res1 = coroutine.resume(co, 1)
    print(res1)
    local ff, res2 = coroutine.resume(co, res1)
    print(res2)
--]]
--[[
local co = coroutine.create(function (msg)
                                print('Coroutine started with message:', msg) 
                                coroutine.yield(10) 
                                print('Coroutine resumed') 
                                coroutine.yield(20) 
                                print('Coroutine finished') 
                           end) 

coroutine.resume(co, 'Hi')
--]]
