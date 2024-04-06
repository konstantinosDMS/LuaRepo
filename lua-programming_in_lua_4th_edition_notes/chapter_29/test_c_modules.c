#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <dirent.h>
#include <errno.h>

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

static int l_dir (lua_State *L) {
    DIR *dir;
    struct dirent *entry;
    int i;
    const char *path = luaL_checkstring(L, 1);

    // open directory

    dir = opendir(path);
    if (dir == NULL) { // error opening the directory?
        lua_pushnil(L); // return nil...
        lua_pushstring(L, strerror(errno)); // and error message
        return 2; // number of results
    }

    // create result table
    lua_newtable(L);
    i = 1;
    while ((entry = readdir(dir)) != NULL) { // for each entry
        lua_pushinteger(L, i++); // push key
        lua_pushstring(L, entry->d_name); // push value
        lua_settable(L, -3); // table[i] = entry name
    }

    int nlen = luaL_len(L, -1);
    for (int i = 1; i <= nlen; i++) {
        lua_geti(L, -1, i);
        printf("%s\n", lua_tostring(L, -1));
        lua_pop(L, 1);
    }

    closedir(dir);
    return 1; // table is already on top
}

static const struct luaL_Reg mylib [] = {
    {"dir", l_dir},
    {NULL, NULL} /* sentinel */
};

//main lua function
int luaopen_test_c_modules (lua_State *L) {
    luaL_newlib(L, mylib);
    return 1;
}