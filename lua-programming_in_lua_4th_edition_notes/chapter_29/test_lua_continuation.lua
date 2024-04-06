local function testMe(k, v)
    if v == 20 then
        print('aaaaddddaaaaddd')
        coroutine.yield(co)
        --print(k, v)
    end
end

foreach({x = 10, y = 20}, function(arr)
                            for k, v in pairs(arr) do
                                testMe(k, v)
                            end
        end)
