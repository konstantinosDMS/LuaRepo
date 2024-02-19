#include <stdio.h>
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

int main(void) {
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);

    // Load Lua code
    luaL_dostring(L, "t = {a = 1, b = 2, c = 3}");

    // Access the table 't' in Lua
    lua_getglobal(L, "t");
    if (!lua_istable(L, -1)) {
        fprintf(stderr, "Error: 't' is not a table\n");
        lua_close(L);
        return 1;
    }

    // Iterate over the elements of the table 't'
    printf("Iterating over table 't':\n");
    lua_pushnil(L);  // Push nil to start the iteration
    while (lua_next(L, -2) != 0) { // -2 because the table 't' is at index -1
        // 'key' is at index -2 and 'value' is at index -1
        const char *key = lua_tostring(L, -2);
        int value = lua_tointeger(L, -1);
        printf("Key: %s, Value: %d\n", key, value);
        lua_pop(L, 1); // Pop the value, but keep the key for the next iteration
    }

    lua_close(L);
    return 0;
}
