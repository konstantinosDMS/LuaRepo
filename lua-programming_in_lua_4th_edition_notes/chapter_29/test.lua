function tryMe(k, v) 
    print(k, v) 
    if v == 20 then coroutine.yield() end 
end

tryMe(10,20)