function checkEnv(var)
    -- _ENV = _G
    
    local tmp = {}
    setmetatable(tmp, { __index = _G })
    _ENV = tmp
    
    if _ENV[var] then 
        print(_ENV[var])
        return true
    else 
        --print(_ENV[var])
        return false
    end
end

