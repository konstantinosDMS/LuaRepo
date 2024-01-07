-- Permutations --
function permgen (a, n)
    n = n or #a -- default for 'n' is size of 'a'
    if n <= 1 then
        -- nothing to change?
        printResult(a)
    else
        for i = 1, n do
            -- put i-th element as the last one
            a[n], a[i] = a[i], a[n]
            -- generate all permutations of the other elements
            permgen(a, n - 1)
            -- restore i-th element
            a[n], a[i] = a[i], a[n]
        end
    end
end

function printResult(a)
    for  i = 1, #a do
        io.write(a[i])
    end
    print('\n')
end

permgen({1, 2, 3, 4})

2341
3241
3421
4321
2431
4231
4312
3412
3142
1342
4132
1432
2413
4213
4123
1423
2143
1243
2314
3214
3124
1324
2134
1234

function permgen (a, n)
    n = n or #a -- default for 'n' is size of 'a'
    if n <= 1 then
        -- nothing to change?
        coroutine.yield(a)
    else
        for i = 1, n do
            -- put i-th element as the last one
            a[n], a[i] = a[i], a[n]
            -- generate all permutations of the other elements
            permgen(a, n - 1)
            -- restore i-th element
            a[n], a[i] = a[i], a[n]
        end
    end
end

function printResult(a)
    for  i = 1, #a do
        io.write(a[i])
    end
    print('\n')
end

function permutations (a)
    local co = coroutine.create(function () permgen(a) end)
    return function ()
        -- iterator
        local code, res = coroutine.resume(co)
        return res
    end
end

for p in permutations{"a", "b", "c"} do
    printResult(p)
end

function permgen (a, n)
    n = n or #a -- default for 'n' is size of 'a'
    if n <= 1 then
        -- nothing to change?
        coroutine.yield(a)
    else
        for i = 1, n do
            -- put i-th element as the last one
            a[n], a[i] = a[i], a[n]
            -- generate all permutations of the other elements
            permgen(a, n - 1)
            -- restore i-th element
            a[n], a[i] = a[i], a[n]
        end
    end
end

function printResult(a)
    for  i = 1, #a do
        io.write(a[i])
    end
    print('\n')
end

function permutations (a)
  return coroutine.wrap(function() permgen(a)  end)
end

for p in permutations{"a", "b", "c"} do
    printResult(p)
end

