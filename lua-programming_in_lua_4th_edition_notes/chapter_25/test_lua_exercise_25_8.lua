local debug = require "debug"
local count = 0

local function hook (event)
    if event == "call" then
        local info = debug.getinfo(1, "fn")
    end
    
    count = count + 1
    if count > 1000 then
        error("script uses too much CPU")
    end
end

for i = 1, 10 do
    hook('call')    
end
