-- Exercise 24.2 --

function combinations(arr, m, result, current, start)
    if m == 0 then
        printResult(current)
        return
    end

    for i = start, #arr - m + 1 do
        table.insert(current, arr[i])
        combinations(arr, m - 1, result, current, i + 1) 
        table.remove(current)
    end
end

function printResult(combination)
    for i = 1, #combination do
        io.write(combination[i])
    end
    print()
end

local arr = {"a", "b", "c", "d"}
local m = 2
local result = {}
combinations(arr, m, result, {}, 1)

function combinations(arr, m, result, current, start)
    if m == 0 then
        -- printResult(current)
        return coroutine.yield(current)
    end

    for i = start, #arr - m + 1 do
        table.insert(current, arr[i])
        combinations(arr, m - 1, result, current, i + 1)     
        table.remove(current)
    end
end 

function combinationss(arr, m, result, current, start)
    local co = coroutine.create(function(arr, m, result, current, start) combinations(arr, m, result, current, start) end)
    return function()
        local _, val = coroutine.resume(co, arr, m, result, current, start)
        return val
    end
end

for c in combinationss({"a", "b", "c"}, 2, {}, {}, 1) do
    for i = 1, #c do
        io.write(c[i])
    end
end
