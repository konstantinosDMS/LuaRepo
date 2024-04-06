#include <stdio.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

int main(void) {
    int res;
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);

    const char *luaCode = "function aa() \
                                print('ole_1') \
                                coroutine.yield() \
                                print('ole_2') \
                                coroutine.yield() \
                                print('ole_3') \
                            end";

    res = luaL_dostring(L, luaCode);
    if (res != LUA_OK) {
        printf("Error loading coroutine's function: %s\n", lua_tostring(L, -1));
        lua_close(L);
        return 1;
    }

    lua_getglobal(L, "aa");
    if (!lua_isfunction(L, -1)) {
        printf("Error: 'aa' is not a function\n");
        lua_close(L);
        return 1;
    }

    luaCode = "local co = coroutine.create(aa); return co"; // Return the coroutine directly
    res = luaL_dostring(L, luaCode);
    if (res != LUA_OK) {
        printf("Error creating coroutine: %s\n", lua_tostring(L, -1));
        lua_close(L);
        return 1;
    }

    lua_State *co = lua_tothread(L, -1); // Get the coroutine from the Lua state
    if (co == NULL) {
        printf("Error getting coroutine\n");
        lua_close(L);
        return 1;
    }

    int nres = 0;
    res = lua_resume(co, 0, 0, &nres); // Resume the coroutine
    if (res != LUA_YIELD) {
        printf("Error resuming coroutine: %s\n", lua_tostring(co, -1));
        lua_close(L);
        return 1;
    }

    const char *res_1 = lua_pushstring(co, "Hi"); // Push a string to the coroutine
    if (res_1 == NULL) {
        printf("Error pushing string to coroutine: %s\n", lua_tostring(co, -1));
        lua_close(L);
        return 1;
    }

    res = lua_resume(co, NULL, 1, &nres); // Resume the coroutine with the string argument
    if (res != LUA_YIELD) {
        printf("Error resuming coroutine: %s\n", lua_tostring(co, -1));
        lua_close(L);
        return 1;
    }

    // Clean up and close Lua state
    lua_close(L);
    return 0;
}
