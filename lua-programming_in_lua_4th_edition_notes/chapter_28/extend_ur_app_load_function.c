#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

/* call a function 'f' defined in Lua */
double f(lua_State *L, double x, double y) {
    int isnum;
    double z;   
    
    /* push functions and arguments */
    lua_getglobal(L, "f"); /* function to be called */
    lua_pushnumber(L, x); /* push 1st argument */
    lua_pushnumber(L, y); /* push 2nd argument */

    /* do the call (2 arguments, 1 result) */
    if (lua_pcall(L, 2, 1, 0) != LUA_OK) luaL_error(L, "error running function 'f': %s", lua_tostring(L, -1));

    /* retrieve result */
    z = lua_tonumberx(L, -1, &isnum);

    if (!isnum) luaL_error(L, "function 'f' should return a number");

    lua_pop(L, 1); /* pop returned value */
    return z;
}

int main(void) {
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);

    int resFile;
    resFile = luaL_loadfile(L, "extend_ur_app_utility.lua");
    if (resFile != LUA_OK) luaL_error(L, "cannot load the file \'extend_ur_app_utility.lua\'\n");
    resFile = lua_pcall(L, 0, LUA_MULTRET, 0);   
    if (resFile != LUA_OK) luaL_error(L, "cannot run the file \'extend_ur_app_utility.lua\'\n");

    double res = f(L, 3.0, (3 * 1.75));
    printf("%f\n", res);

    lua_close(L);
    return 0;
}