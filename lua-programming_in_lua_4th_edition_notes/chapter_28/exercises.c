#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

/**
 * // Exercise 28.1
void loader(lua_State *L, const char *file) {
    int res;
    int x[5] = {5, 6, 7, 8, 9};

    res = luaL_loadfile(L, file);
    if (res != LUA_OK) luaL_error(L, "error loading file: %s\n", file);

    res = lua_pcall(L, 0, 0, 0);
    if (res != LUA_OK) luaL_error(L, "error running file: %s\n", file);

    // Push the function name onto the stack
    lua_getglobal(L, "f");

    // Create a table and fill it with values from array x
    lua_newtable(L);
    for (int i = 0; i < 5; i++) {
        lua_pushinteger(L, x[i]);
        lua_rawseti(L, -2, i + 1); // Set table value at index i+1
    }

    // Call the function with the table as an argument
    res = lua_pcall(L, 1, 1, 0);
    if (res != LUA_OK) luaL_error(L, "error running function: %s\n", lua_tostring(L, -1));

    // printf("%d\n", lua_gettop(L)); // got 1 (1 = table)

    // Retrieve the return value (the modified table x) from the Lua stack
    if (!lua_istable(L, -1)) luaL_error(L, "return value is not a table\n");
  
    int size = luaL_len(L, -1);
    for (int i = 1; i <= size; i++) {
        lua_rawgeti(L, -1, i); // Push table element onto the stack
        int val = luaL_checkinteger(L, -1); // Retrieve table element
        printf("%d\n", val);
        lua_pop(L, 1); // Pop table element from the stack
    }
}

int main(void) {
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);

    loader(L, "exercise_utilitiy_function.lua");

    lua_close(L);
    return 0;
}
**/

// Exercise 28.3

struct station {
    char *name;
    const char *url;
};

void loader(lua_State *L, const char *file) {
    struct station stations[] = {
        {"KXLU", ""},
        {"KCRW", ""},
        {"KUSC", ""},
        {"KPCC", ""},
        {"KPFK", ""}
    };

    int res;

    // Load the Lua file
    res = luaL_loadfile(L, file);
    if (res != LUA_OK) luaL_error(L, "error loading file: %s\n", file);

    // Execute the Lua code
    res = lua_pcall(L, 0, 0, 0);
    if (res != LUA_OK) luaL_error(L, "error running file: %s\n", file);

    // Get the global function 'f' from the Lua environment
    lua_getglobal(L, "f");

    // If 'f' is not a function, raise an error
    if (!lua_isfunction(L, -1)) {
        luaL_error(L, "function 'f' not found in Lua environment\n");
    }

    // Create a Lua table and fill it with station data
    lua_createtable(L, sizeof(stations) / sizeof(stations[0]), 0);

    for (int i = 0; i < sizeof(stations) / sizeof(stations[0]); i++) {
        lua_createtable(L, 0, 2);

        lua_pushstring(L, stations[i].name);
        lua_setfield(L, -2, "name");

        lua_pushstring(L, stations[i].url);
        lua_setfield(L, -2, "url");

        lua_rawseti(L, -2, i + 1);
    }

    // Call the Lua function 'f' with the table as an argument
    res = lua_pcall(L, 1, 1, 0);
    if (res != LUA_OK) luaL_error(L, "error running function: %s\n", lua_tostring(L, -1));

    if (!lua_istable(L, -1)) {
        luaL_error(L, "Lua function should return a table\n");
    }

/**
    // Get the length of the returned table
    int len = luaL_len(L, -1);

    // Iterate over the outer table
    for (int i = 1; i <= len; i++) {
        lua_rawgeti(L, -1, i); // Push the i-th element onto the stack

        // Check if the element is a table
        if (!lua_istable(L, -1)) {
            luaL_error(L, "error: element at index %d is not a table\n", i);
        }

        // Retrieve the elements from the inner table
        lua_rawgeti(L, -1, 1); // Push the first element (name) onto the stack
        const char *name = lua_tostring(L, -1);
        lua_pop(L, 1); // Pop the name from the stack

        lua_rawgeti(L, -1, 2); // Push the second element (url) onto the stack
        const char *url = lua_tostring(L, -1);
        lua_pop(L, 1); // Pop the url from the stack

        // Print the name and url
        printf("name: %s, url: %s\n", name, url);

        // Pop the inner table from the stack
        lua_pop(L, 1);
    }
**/

   // Initialize the iteration
    lua_pushnil(L);  // Push a nil key onto the stack

    // Iterate over the outer table (array of arrays)
    while (lua_next(L, -2)) {  // Pushes the next key-value pair onto the stack
        // Check if the value is a table
        if (!lua_istable(L, -1)) {
            luaL_error(L, "error: element is not a table\n");
        }

        // Get the size of the inner array
        int size = lua_rawlen(L, -1);

        // Check if the inner array has exactly two elements (name and URL)
        if (size != 2) {
            luaL_error(L, "error: inner array should have exactly two elements\n");
        }

        // Retrieve the name (element at index 1) and URL (element at index 2)
        lua_rawgeti(L, -1, 1);  // Get the name
        const char *name = lua_tostring(L, -1);

        lua_rawgeti(L, -2, 2);  // Get the URL
        const char *url = lua_tostring(L, -1);

        // Pop the name, URL, and the inner array from the stack
        lua_pop(L, 3);

        // Print the name and URL
        printf("name: %s, url: %s\n", name, url);
    }

    // Pop the returned table from the stack
    lua_pop(L, 1);
}

int main(void) {
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);

    loader(L, "exercise_utilitiy_table_to_url.lua");

    lua_close(L);
    return 0;
}