-- This Lua function calls the C function 'mysin'
local result = mysin(1.57)
print("Result from C function:", result)

-- This Lua function calls another Lua function through the C function 'call_lua_code'
local lua_code = [[
    print("Executing Lua code from C function")
    print("Hello from Lua!")
]]
call_lua_code(lua_code) -- By this statement, lua will add to  the stack the 
                        -- lua_code value. So the C-Function's statement 
                        -- const char *lua_code = lua_tostring(L, -1);
                        -- will get this value from C-Function
