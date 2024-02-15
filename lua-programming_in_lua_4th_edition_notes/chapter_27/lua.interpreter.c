#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stddef.h>
#include <assert.h>

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
//#include "luaconf.h"

// custom interpreter //

/*
int main (void) {
    char buff[256];
    int error;
    lua_State *L = luaL_newstate();  // opens Lua //
    luaL_openlibs(L); // opens the standard libraries //
    while (fgets(buff, sizeof(buff), stdin) != NULL) {
        error = luaL_loadstring(L, buff) || lua_pcall(L, 0, 0, 0);
        if (error) {
            fprintf(stderr, "%s\n", lua_tostring(L, -1));
            lua_pop(L, 1); // pop error message from the stack //
        }
    }
    lua_close(L);
    return 0;
}
*/

// lua_lalloc() //
// custom allocator //
/*
 static void *l_alloc (void *ud, void *ptr, size_t osize, size_t nsize) {
       (void)ud;  (void)osize;  // not used //
       if (nsize == 0) {
         free(ptr);
         return NULL;
       }
       else
         return realloc(ptr, nsize);
 }
*/

/*
int custom_panic(lua_State *L) {
    fprintf(stderr, "Panic! %s\n", lua_tostring(L, -1));
    exit(EXIT_FAILURE);
}

int main() {
    // Create Lua state
    lua_State *L = luaL_newstate();

    // Set custom panic function
    lua_atpanic(L, custom_panic);

    // Load and execute Lua code that triggers a panic
    if (luaL_dostring(L, "assert(false, 'This is a fatal error!')") != LUA_OK) {
        fprintf(stderr, "Error executing Lua code: %s\n", lua_tostring(L, -1));
        lua_close(L);
        return EXIT_FAILURE;
    }

    // The panic function will be called if the execution reaches here due to the error
    // Close Lua state
    lua_close(L);

    return EXIT_SUCCESS;
}
*/

/*
int my_lua_function(lua_State *L) {
    printf("Inside Lua function\n");
    lua_pushnumber(L, 42);
    return 1; // Number of values returned
}

int main() {
    lua_State *L = luaL_newstate();

    // Register the Lua function
    lua_pushcfunction(L, my_lua_function);
    lua_setglobal(L, "my_lua_function");

    // Call the Lua function using lua_pcallk
    int status = lua_pcallk(L, 1, 1, 0, 0, 0);

    if (status != LUA_OK) {
        fprintf(stderr, "Error calling Lua function: %s\n", lua_tostring(L, -1));
    }

    lua_close(L);
    return 0;
}
*/
/**
int string_reader(lua_State *L, void *data, size_t *size) {
    const char *luaCode = (const char *)data;
    //printf("%s\n", luaCode);
    *size = strlen(luaCode);
    lua_pushlstring(L, luaCode, *size);
    return LUA_OK;
}

int main() {
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);

    const char *luaCode = "print(\"Hello, Lua!\")";
    
    // Load Lua code from a string using lua_load
    //if (lua_load(L, (lua_Reader)string_reader, (void *)luaCode, "chunk", "t") == LUA_OK) {
    if (luaL_loadstring(L, luaCode) == LUA_OK) {
        // Execute the loaded chunk
        if (lua_pcall(L, 0, 0, 0) != LUA_OK) {  
            fprintf(stderr, "Error: %s\n", lua_tostring(L, -1));
            exit(0);
        }
    } else {
        fprintf(stderr, "Error loading Lua code\n");
    }

    lua_close(L);
    return 0;
}
**/
/**
static int my_stack(lua_State *L){
    const char *myFunc = "function jj() print('Hello from Lua!') end";
    
    lua_Debug ar;
    int gg = lua_getstack(L, 0, &ar);
    
    if (gg == 0) {
        fprintf(stderr, "No stack information available\n");
    } else {
        printf("  Stack level: %d\n", 0);
        printf("  Function: %s\n", ar.name ? ar.name : "(no name)");
        printf("  Source: %s\n", ar.short_src);
        printf("  Line: %d\n", ar.currentline);
    }
}

int main() {
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);

    lua_pushcfunction(L, my_stack);
    lua_call(L, 0, 0);
    
    lua_close(L);
    return 0;
}
**/
/**
int main(){
    size_t len;
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);

    // Assume you have some Lua string on the stack //
    lua_pushstring(L, "Hello, Lua!");

    const char *s = lua_tolstring(L, -1, &len); // any Lua string //

    // The following assertions may lead to a segmentation fault //
    // because lua_tolstring does not guarantee a null-terminated string //
    assert(s[len] == '\0');
    printf("s[len] = \'\\0\'\n");
    assert(strlen(s) <= len);
    printf("strlen(s) = %li\n", strlen(s));
    // Instead, you should use the len returned by lua_tolstring
    printf("Length of Lua string: %zu\n", len);

    // Clean up Lua state
    lua_close(L);
    return 0;
}
**/

static void stackDump (lua_State *L) {
    int i;
    int top = lua_gettop(L); // depth of the stack 
    for (i = 1; i <= top; i++) { // repeat for each level 
        int t = lua_type(L, i);
        switch (t) {
            case LUA_TSTRING: { // strings 
                printf("LUA_TSTRING: '%s'", lua_tostring(L, i));
                break;
            }
            case LUA_TBOOLEAN: { // Booleans 
                printf("LUA_TBOOLEAN: %s", (lua_toboolean(L, i) ? "true" : "false"));
              break;
           }
            case LUA_TNUMBER: { // numbers
                if (lua_isinteger(L, i)){ 
                    printf("LUA_TNUMBER INTEGER: %lld", lua_tointeger(L, i));
                    break;
                }
                printf("LUA_TNUMBER FLOAT: %g", lua_tonumber(L, i));
                break;
            }
            default: { // other values 
                printf("Default Case: %s", lua_typename(L, t));
                break;
            }
        }   
        printf(" "); // put a separator 
    }
    printf("\n"); // end the listing 
}
/**
int main(){
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);
    int isnum = 1;

    const char *str = "Hello from stack!";
    size_t len = strlen(str);

    lua_pushlstring(L, str, len);
    lua_pushboolean(L, 1);
    lua_pushinteger(L, 55);
    lua_pushnumber(L, 55.44);
    stackDump(L);
}
**/
/*
int main (void) {
    lua_State *L = luaL_newstate();
    lua_pushboolean(L, 1);
    lua_pushnumber(L, 10);
    lua_pushnil(L);
    lua_pushstring(L, "hello");
    // stackDump(L);
    // will print:
    //    true
    //    10
    //    nil
    //    'hello'
    
    lua_pushvalue(L, -4); //stackDump(L);
    // will print: true 10 nil 'hello' true //
    lua_replace(L, 3); //stackDump(L);
    // will print: true 10 true 'hello' //
    lua_settop(L, 6); //stackDump(L);
    // will print: true 10 true 'hello' nil nil //
    lua_rotate(L, 3, 1); //stackDump(L);
    // will print: true 10 nil true true hello nil //
    lua_remove(L, -3); stackDump(L);
    // will print: true 10 nil 'hello' //

    lua_settop(L, -5); stackDump(L);
    // will print: true //
    lua_close(L);
    return 0;
}
*/

// Exercise 27.2 //
/*
int main(){
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);
    lua_pushnumber(L, 3.5);
    lua_pushstring(L, "hello");
    lua_pushnil(L);
    //stackDump(L);
    lua_rotate(L, 1, -1);
    //stackDump(L);
    lua_pushvalue(L, -2);
    //stackDump(L);
    lua_remove(L, 1);
    //stackDump(L);
    lua_insert(L, -2);
    stackDump(L);
    lua_close(L);
    return 0;
}
*/
// Exercise 27.4 //

// typedef void * (*Lua_Alloc) (void *ud, void *ptr, size_t osize, size_t nsize); //

// Structure to store memory limit and current usage

typedef struct {
    size_t memory_limit;
    size_t memory_used;
} MemoryLimitData;

// Custom Lua allocator function
static void *limited_allocator(void *ud, void *ptr, size_t osize, size_t nsize) {
    MemoryLimitData *data = (MemoryLimitData *)ud;

    // If allocating memory
    if (nsize > 0) {
        // Check if the new allocation will exceed the memory limit
        if (data->memory_used + (nsize - osize) > data->memory_limit) {
            return NULL;  // Exceeds memory limit, return NULL
        }

        data->memory_used += nsize - osize;
    } else {
        data->memory_used -= osize;
    }

    // Call the original allocator
    return realloc(ptr, nsize);
}

// Lua function to set the memory limit
static int lua_setlimit(lua_State *L) {
    MemoryLimitData *data = (MemoryLimitData *)lua_touserdata(L, lua_upvalueindex(1));
    size_t new_limit = (size_t)luaL_checkinteger(L, 1);

    if (new_limit < data->memory_used) {
        return luaL_error(L, "New limit (%zu) is less than current memory usage (%zu)", new_limit, data->memory_used);
    }

    data->memory_limit = new_limit;
    return 0;
}

// Create a Lua state with the limited allocator
lua_State *luaL_newstate_with_limit(size_t memory_limit) {
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);

    if (L != NULL) {
        // Allocate and initialize MemoryLimitData
        MemoryLimitData *data = (MemoryLimitData *)malloc(sizeof(MemoryLimitData));
        if (data != NULL) {
            data->memory_limit = memory_limit;
            data->memory_used = 0;

            // Set the custom allocator with user data
            lua_setallocf(L, limited_allocator, data);

            // Set the setlimit function in Lua
            lua_pushlightuserdata(L, data);
            lua_pushcclosure(L, lua_setlimit, 1);
            lua_setglobal(L, "setlimit");
            printf("Memory Limit: %ld\n", data->memory_limit);
            printf("Memory Used: %ld\n", data->memory_used);
        } else {
            lua_close(L);
            L = NULL;
        }
    }

    return L;
}

// Example usage
int main() {
    // Create a Lua state with a memory limit of 1000 bytes
    lua_State *L = luaL_newstate_with_limit(1200);

    if (L != NULL) {
        // Load and execute Lua script (e.g., script.lua)
        int result = luaL_dofile(L, "script.lua");
        
        if (result != LUA_OK) {
            const char *errorMessage = lua_tostring(L, -1);
            printf("Error loading Lua script: %s\n", errorMessage);
        }

        // Close the Lua state
        lua_close(L);
    }

    return 0;
}
