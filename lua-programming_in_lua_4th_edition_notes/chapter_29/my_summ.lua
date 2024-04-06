function my_summation(xx)
    if (xx ~= nil and type(xx) == 'table') then
        local y = 0
        for i = 1, #xx do
            y = y + xx[i]
        end
        return y
    else
        error("argument should be a table.")
    end
end