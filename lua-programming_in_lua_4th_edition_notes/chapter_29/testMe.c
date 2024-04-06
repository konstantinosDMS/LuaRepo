#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

int main(void) {
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);

    const char *str = " function test(xx) \
                            local co = coroutine.create(function() \
                                coroutine.yield(xx .. 'ff')  \
                                print('After yielding 1') \
                                coroutine.yield(xx .. 'vv') \
                                print('After yielding 2') \
                            end) \
                            return co \
                        end";
                        
    int res = luaL_dostring(L, str);
    if (res != LUA_OK) {
        printf("Error running Lua code: %s\n", lua_tostring(L, -1));
        lua_close(L);
        return 1;
    }  

    lua_getglobal(L, "test");
    lua_pushstring(L, "input_string");  // Push argument to the Lua function
    res = lua_pcall(L, 1, 1, 0);  // Call the Lua function with 1 argument and 1 return value
    if (res != LUA_OK) {
        printf("Error calling Lua function: %s\n", lua_tostring(L, -1));
        lua_close(L);
        return 1;
    }

    // Get the coroutine returned by the Lua function
    lua_State *co = lua_tothread(L, -1);
    if (co == NULL) {
        printf("Error: Returned value is not a coroutine\n");
        lua_close(L);
        return 1;
    }

    // Resume the coroutine until it finishes
    int nres = 0;
    while (1) {
        int res = lua_resume(co, NULL, 0, &nres);
        if (res == LUA_OK || res == LUA_YIELD) {
            if (res == LUA_YIELD) {
                printf("Yielded: %s\n", lua_tostring(co, -1));
            }
        } else {
            printf("Error resuming coroutine: %s\n", lua_tostring(co, -1));
            lua_close(L);
            return 1;
        }
        if (res == LUA_OK) {
            break; // Coroutine finished executing
        }
    }

    lua_close(L);
    return 0;
}