#include <stdarg.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

/*
void call_va(lua_State *L, const char *func, const char *sig, ...) {
    va_list vl;
    int narg, nres; // number of arguments and results //
    
    if (luaL_loadfile(L, "extend_ur_app_utility.lua") != LUA_OK) lua_error(L);

    if (lua_pcall(L, 0, LUA_MULTRET, 0) != LUA_OK) lua_error(L); 

    va_start(vl, sig);
    float x = (float)va_arg(vl, double); // Casting to float as specified in the signature
    float y = (float)va_arg(vl, double); // Casting to float as specified in the signature
    va_end(vl);

    lua_getglobal(L, func); // push function //

    lua_pushnumber(L, x);
    lua_pushnumber(L, y);

    narg = 2;
    nres = 1;
    if (lua_pcall(L, narg, nres, 0) != 0) // do the call //
        luaL_error(L, "error calling '%s': %s", func, lua_tostring(L, -1));
    
    printf("Results: %f\n", lua_tonumberx(L, -1, 0));
    lua_pop(L, 1);
}

int main(void) {
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);
    float x = 3.0;
    float y = 2.5;
    float z = 0.0;
    call_va(L, "f", "dd>d", x, y, &z);

    lua_close(L);
    return 0;
}
*/
/**
void call_va (lua_State *L, const char *func, const char *sig, ...) {
    va_list vl;
    int narg = 0, nres, res; // number of arguments and results //
    va_start(vl, sig);
    
    res = luaL_loadfile(L, "extend_ur_app_utility.lua");
    if (res != LUA_OK) luaL_error(L, "cannot load the file \'extend_ur_app_utility.lua\'\n");
  
    nres = strlen(sig); // number of expected results //
    if (lua_pcall(L, narg, nres, 0) != 0) // do the call //
        luaL_error(L, "error calling '%s': %s", func, lua_tostring(L, -1));
    
    lua_getglobal(L, func); // push function //

    for (narg = 0; *sig; narg++) {
        luaL_checkstack(L, 1, "too many arguments");    
        switch (*sig++) {
            case 'd': // double argument //
                lua_pushnumber(L, va_arg(vl, double));
                break;
            case 'i': // int argument //
                lua_pushinteger(L, va_arg(vl, int));
                break;
            case 's': // string argument //
                lua_pushstring(L, va_arg(vl, char *));
                break;
            case '>': // end of arguments //
                goto endargs; // break the loop //
              // break;
            default:
                luaL_error(L, "invalid option (%c)", *(sig - 1));
        }
    }
    endargs:
        res = lua_pcall(L, narg, nres, 0);
        if (res != LUA_OK) luaL_error(L, "error running function 'f': %s", lua_tostring(L, -1));

        nres = -nres; // stack index of first result //
        while (*sig) { // repeat for each result //
            switch (*sig++) {
                case 'd': { // double result //
                        int isnum;
                        double n = lua_tonumberx(L, nres, &isnum);
                        if (!isnum) luaL_error(L, "wrong result type");
                        *va_arg(vl, double *) = n;
                        printf("%f\n", n);
                        break;
                    }
                case 'i': { // int result //
                        int isnum;
                        int n = lua_tointegerx(L, nres, &isnum);
                        if (!isnum) luaL_error(L, "wrong result type");
                        *va_arg(vl, int *) = n;
                        printf("%d\n", n);
                        break;
                    }
                case 's': { // string result //
                        const char *s = lua_tostring(L, nres);
                        if (s == NULL) luaL_error(L, "wrong result type");
                        *va_arg(vl, const char **) = s;
                        printf("%s\n", s);
                        break;
                    }
                default: luaL_error(L, "invalid option (%c)", *(sig - 1));
            }
            nres++;
        }
        
    va_end(vl);
}

int main(void) {
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);
    float x = 3.0;
    float y = 2.5;
    float z = 0.0;

    call_va(L, "f", "dd>d", x, y, &z);

    lua_close(L);
    return 0;
}
**/