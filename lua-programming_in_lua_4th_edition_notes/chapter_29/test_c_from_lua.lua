function test_c_from_lua()
    print(mysin("1.57"))
end

test_c_from_lua()

--[[
function select(xx) 
    if (xx ~= nil and type(xx) == 'table') then    
        local y = 0 
        for i = 1, #xx do 
            y = y + xx[i] 
        end 
        return y 
    end 
end 

print(select({1,2,3}))
--]]
