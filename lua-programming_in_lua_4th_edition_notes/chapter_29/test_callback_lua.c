#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

static int l_sin(lua_State *L) {
    double d = luaL_checknumber(L, -1);
    lua_pushnumber(L, sin(d));
    return 1;
}

static int call_lua_code(lua_State *L) {
    const char *lua_code = lua_tostring(L, -1);
    
    int res = luaL_dostring(L, lua_code);
    if (res != LUA_OK) {
        lua_pushstring(L, lua_tostring(L, -1)); // Push error message to Lua stack
        return lua_error(L); // Return error to Lua
    }
    return 0;
}

int main(void) {
    lua_State *L = luaL_newstate();
    if (L == NULL) {
        printf("Error opening Lua state.\n");
        exit(1);
    }
    luaL_openlibs(L);

    lua_pushcfunction(L, l_sin);
    lua_setglobal(L, "mysin");

    lua_pushcfunction(L, call_lua_code);
    lua_setglobal(L, "call_lua_code");

    int res = luaL_dofile(L, "test_lua_callback.lua");
    if (res != LUA_OK) {
        printf("Error running Lua code: %s\n", lua_tostring(L, -1));
        lua_close(L);
        exit(1);
    }

    lua_close(L);
    return 0;
}
