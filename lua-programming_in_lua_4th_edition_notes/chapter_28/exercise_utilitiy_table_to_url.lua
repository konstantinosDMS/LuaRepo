function f(pin)
    local x = {}
    table.insert(x, { name = "KXLU", url = "http://www.kxlu.com"})
    table.insert(x, { name = "KCRW", url = "http://www.kcrw.com"})
    table.insert(x, { name = "KUSC", url = "http://www.kusc.com"})
    table.insert(x, { name = "KPCC", url = "http://www.kpcc.com"})
    table.insert(x, { name = "KPFK", url = "http://www.kpfk.com"})
    
    local res = {}
    for i = 1, #pin do
        for k, v in pairs(pin[i]) do
            -- print(k, v)
            for j = 1, #x do
                for g, h in pairs(x[j]) do
                    -- print(g, h)
                    if v == h then
                        table.insert(res, {x[j].name, x[j].url})
                    end
                end
            end
        end
    end
    
    return res
end