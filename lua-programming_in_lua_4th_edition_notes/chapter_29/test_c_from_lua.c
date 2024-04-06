#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <dirent.h>
#include <errno.h>

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

/***
static int l_sin(lua_State *L) {
    double d = luaL_checknumber(L, -1);
    printf("%f\n", d);
    lua_pushnumber(L, sin(d));
    printf("%f\n", lua_tonumber(L, -1));
    return 1;
}

int main(void) {
    int res;
    lua_State *L = luaL_newstate();
    if (L == NULL) {
        printf("Error opening lua state.\n");
        exit(1);
    }
    luaL_openlibs(L);

    lua_pushcfunction(L, l_sin);
    lua_setglobal(L, "mysin");

    char * lua_Code = "print(mysin(1.57))";
    res = luaL_dostring(L, lua_Code);
    if (res != LUA_OK) {
        printf("Error running code: %s\n", lua_tostring(L, -1));
        exit(1);
    }

    /*res = luaL_dofile(L, "test_c_from_lua.lua");
    if (res != LUA_OK) {
        printf("Error running code: %s\n", lua_tostring(L, -1));
        exit(1);
    }*/

//    lua_close(L);
//    return 0;
//}
/*
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

    closedir(dir);
    return 1; // table is already on top
}
*/
/*
int main(void) {
    int res;
    lua_State *L = luaL_newstate();
    if (L == NULL) {
        printf("Error opening lua state.\n");
        exit(1);
    }
    luaL_openlibs(L);

    lua_pushcfunction(L, l_dir);

    lua_setglobal(L, "dir");
    lua_getglobal(L, "dir");
    lua_pushstring(L, ".");

    res = lua_pcall(L, 1, 1, 0);
    if (res != LUA_OK) {
        printf("Error running code: %s\n", lua_tostring(L, -1));
        exit(1);
    }

    if (!lua_istable(L, -1)) {
        printf("Error: dir() did not return a table.\n");
        lua_close(L);
        exit(1);
    }

    int len = luaL_len(L, -1);
    if (len != 0) {
        for (int i = 1; i <= len; i++) {
            lua_pushinteger(L, i);
            lua_gettable(L, -2);
            const char *name = lua_tostring(L, -1);
            printf("%s\n", name);
            lua_pop(L, 1);
        }
    }

    lua_close(L);
    return 0;
}
*/

// Through lua_pcall and lua_call, a C function called from Lua can call Lua back.
// See test_callback_lua.c, test_callback_lua.lua.

// Attempt to yield C-Function, into protected mode. This will work as the lua-function
// is inside a resumed coroutine. See next example for a case C-boundary msg. 
/*
static int luaB_pcall(lua_State *L) {
    int status;
    luaL_checkany(L, 1); // Ensure at least one parameter is provided, parameter is 'test'

    // Get the number of arguments passed to luaB_pcall
    int nargs = lua_gettop(L);

    // Call lua_pcall with appropriate arguments
    status = lua_pcall(L, nargs-1, LUA_MULTRET, 0);

    // Check if the function called through lua_pcall yielded
    if (status == LUA_YIELD) {
        luaL_error(L, "Attempt to yield inside a protected call");
        return 0; // Never reached, but to silence compiler warnings
    }

    // Push the status as a boolean value onto the Lua stack
    lua_pushboolean(L, (status == LUA_OK));
    // printf("lua status %d\n", status == LUA_OK); // 1

    // Move the boolean value to the top of the stack
    lua_insert(L, 1);

    printf("%s, %d\n", "From lua", lua_gettop(L)); // it is lua's stack frame = 1
    // printf("%d\n", lua_gettop(L)); // 1

    // Return the total number of values on the Lua stack
    return lua_gettop(L);
}
*/
/*
int main(void) {
    int res;
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);

    // Register luaB_pcall as a Lua function
    lua_register(L, "pcall", luaB_pcall);

    const char *str = "function test() \
                            local co = coroutine.create(function() \
                                print('me') \
                                return coroutine.yield() \
                            end) \
                            return coroutine.resume(co) \
                       end \
                       pcall(test)";

    res = luaL_dostring(L, str);
    if (res != LUA_OK) {
        printf("Error running Lua code: %s\n", lua_tostring(L, -1));
        lua_close(L);
        return 1;
    }

    // printf("%s, %d\n", "From C-Function", lua_gettop(L)); //it is C's stack frame = 0
    lua_close(L);
    return 0;
}
*/

// Internally, Lua uses the C longjmp facility to yield a coroutine. Therefore, if a C 
// function foo calls an API function and this API function yields (directly or indirectly 
// by calling another function that yields), Lua cannot return to foo any more, because the 
// longjmp removes its frame from the C stack. 

/* Getting 10      20

PANIC: unprotected error in call to Lua API (Error loading luaCode. [string 
 "local co = function(x, y)  print(x, y)  corou..."]:1: Error calling function: 
  attempt to yield across a C-call boundary */

/*
int mypcall(lua_State *L) {
    if (!lua_isfunction(L, 1)) {
        return luaL_error(L, "Argument must be a function");
    }

    lua_pushvalue(L, 1); // Push the function
    lua_pushinteger(L, 10);
    lua_pushinteger(L, 20);

    int status = lua_pcall(L, 2, 0, 0); // Use lua_pcallk with a NULL context

    if (status != LUA_OK) {
        return luaL_error(L, "Error calling function: %s", lua_tostring(L, -1));
    }

    return lua_gettop(L); // Return the number of results
}
*/
/*
int main(void) {
    lua_State *L = luaL_newstate();
    if (L == NULL) {
        luaL_error(L, "Error creating lua state. %s\n", lua_tostring(L, -1));
        exit(1);
    }
    luaL_openlibs(L);

    lua_State *L1 = lua_newthread(L); //lua_tothread(L, -1); // Get the coroutine thread
    if (L1 == NULL) {
        luaL_error(L, "Error creating L1 thread. %s\n", lua_tostring(L, -1));
        exit(1);
     }

    //lua_register(L1, "mypcall", mypcall);
    lua_pushcfunction(L1, mypcall);
    lua_setglobal(L1, "mypcall");

    char *luaCode = "local co = function(x, y) "
                    " print(x, y) "
                    " coroutine.yield() " 
                    " end "
                    " mypcall(co) ";

    int res = luaL_dostring(L1, luaCode);
    if (res != LUA_OK) {
        luaL_error(L1, "Error loading luaCode. %s\n", lua_tostring(L1, -1));
        exit(1);
    }

    lua_getglobal(L1, "co");
    if (!lua_isthread(L1, -1)) {
        luaL_error(L1, "Error getting global Thread co. %s\n", lua_tostring(L1, -1));
        exit(1);
    }

    int nres = 0;
    res = lua_resume(L1, NULL, 0, &nres);
    if (res == LUA_YIELD) {
        printf("Lua yielded.\n");
        // Now you can resume the coroutine using `coroutine.resume` in Lua
    } else if (res == LUA_OK) {
        printf("Lua resumed - completed.\n");
    } else {
        printf("Error running coroutine: %s\n", lua_tostring(L1, -1));
    }

    lua_close(L);
    exit(0);
}
*/

// Attempt to yield C-Function, into protected mode. - Continuation Function - pcallk()
/**
static int finishpcall (lua_State *L, int status, intptr_t ctx) { //boolean from lua_pcallk(...);
    (void)ctx; // unused parameter
    status = (status != LUA_OK && status != LUA_YIELD);

    lua_pushboolean(L, (status == 0)); // boolean, userdata
    // printf("%d\n", (status == LUA_OK)); // 1

    lua_insert(L, 1); // status is first result

    // printf("%s, %d\n", "From lua", lua_gettop(L)); // it is lua's stack frame = 1
    lua_getglobal(L, "co"); // boolean, userdata, number

    //printf("%s, %d\n", "From lua", lua_gettop(L)); // it is lua's stack frame = 2

    int nresults;
    lua_resume(lua_tothread(L, 2), NULL, 0, &nresults);
    lua_resume(lua_tothread(L, 2), NULL, 0, &nresults);

    // int k = lua_gettop(L);
    // for (int i = 1 ; i <= k ; i ++) {
    //     printf("%s\n", lua_typename(L, i));
    //}

    return lua_gettop(L); // return status + all results
}
*/
/*
static int luaB_pcall (lua_State *L) { // boolean
    int status;
    luaL_checkany(L, 1);
    status = lua_pcallk(L, lua_gettop(L) - 1, LUA_MULTRET, 0, 0, finishpcall);
    // DO NOT EVEN THINK ABOUT TO CLEAR THE LUA'S STACK => segmentation fault
    // int k = lua_gettop(L);
    // for (int i = 1 ; i <= k ; i ++) {
        // lua_pop(L, 1);
    // }
   return finishpcall(L, status, 0);
}

int main(void) {
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);

    // Register luaB_pcall as a Lua function
    lua_register(L, "pcall", luaB_pcall);

    const char *str = "function test() \
                            local co = coroutine.create(function() \
                                print('me') \
                                coroutine.yield() \
                                print('me me') \
                            end) \
                            return co \
                       end \
                       pcall(test)";

    int res = luaL_dostring(L, str);
    if (res != LUA_OK) {
        printf("Error running Lua code: %s\n", lua_tostring(L, -1));
        lua_close(L);
        return 1;
    }

    //printf("%s, %d\n", "From C-Function", lua_gettop(L)); //it is C's stack frame = 0

    lua_close(L);
    return 0;
}
*/

// C - Modules, see test_c_modules.c.

// Exercise 29.1
/*
int main(void) {
    int res;
    lua_State *L = luaL_newstate();
    if (L == NULL) {
        printf("Error opening lua state.\n");
        exit(1);
    }

    luaL_openlibs(L);

    res = luaL_dofile(L, "my_summ.lua");
    if (res != LUA_OK) {
        luaL_error(L, "Error running my_summ.lua file.\n");
    }

    lua_getglobal(L, "my_summation");

    res = luaL_dofile(L, "my_lua_file.lua");
    if (res != LUA_OK) {
        printf("Error running code: %s\n", lua_tostring(L, -1));
        exit(1);
    }

    lua_close(L);
    return 0;
}
*/
/**
int my_summation(lua_State *L) {
    double sum = 0;
    luaL_checktype(L, 1, LUA_TTABLE); // Ensure the argument is a table

    // Iterate through arguments and sum them up
    int n = luaL_len(L, 1);
    for (int i = 1; i <= n; i++) {
        lua_rawgeti(L, 1, i); // Get the i-th element from the table
        sum += luaL_checknumber(L, -1); // Add the element to the sum
        lua_pop(L, 1); // Pop the element from the stack
    }

    // Push the result onto the Lua stack
    lua_pushnumber(L, sum);

    return 1;  // Number of return values
}

int main(void) {
    lua_State *L = luaL_newstate();
    if (L == NULL) {
        printf("Error opening Lua state.\n");
        return 1;
    }

    // Open standard Lua libraries
    luaL_openlibs(L);

    // Register C function my_summation to Lua
    lua_pushcfunction(L, my_summation);
    lua_setglobal(L, "my_summation");

    // Load and execute Lua script from file
    int res = luaL_dofile(L, "my_lua_file.lua");
    if (res != LUA_OK) {
        printf("Error running code: %s\n", lua_tostring(L, -1));
        return 1;
    }

    // Close Lua state
    lua_close(L);
    return 0;
}
*/

// Exercise 29.2
/**
static int my_table_pack(lua_State *L) {
    luaL_checktype(L, -1, LUA_TTABLE);
    int n = luaL_len(L, -1);

    lua_pushinteger(L, n);
    lua_seti(L, 1, n + 1);
    // printf("%lld\n", luaL_len(L, -1));

    return 1;
}

static int my_print(lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);

    if (lua_type(L, -1) == LUA_TTABLE) {
        int my_len = luaL_len(L, 1);
        for (int i = 1; i <= my_len; i ++){
            lua_rawgeti(L, 1, i);
            if (i == my_len) printf("(#: %lld )", lua_tointeger(L, -1));
            else printf("%lld ", lua_tointeger(L, -1));
            lua_pop(L, 1);
        }
    }
    return 1;
}

int main(void) {
    lua_State *L = luaL_newstate();
    if (L == NULL) {
        printf("Error opening Lua state.\n");
        return 1;
    }

    // Open standard Lua libraries
    luaL_openlibs(L);

    // Register C function my_table_pack to Lua
    lua_pushcfunction(L, my_table_pack);
    lua_setglobal(L, "my_table_pack");

    // Register C function my_table_pack to Lua
    lua_pushcfunction(L, my_print);
    lua_setglobal(L, "my_print");

    // Load and execute Lua script from file
    int res = luaL_dostring(L, "my_print(my_table_pack({1, 2, 3}))");
    if (res != LUA_OK) {
        printf("Error running code: %s\n", lua_tostring(L, -1));
        return 1;
    }

    // Close Lua state
    lua_close(L);
    return 0;
}
*/

// Exercise 29.3
/**
static int reverse_array(lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);

    int my_len = luaL_len(L, 1);

    int *my_Arr = (int *)malloc(my_len * sizeof(int));
    int *reverse_my_Arr = (int *)malloc(my_len * sizeof(int));

    for (int i = 0; i < my_len; i++) {
        lua_geti(L, 1, i + 1);
        my_Arr[i] = lua_tointeger(L, -1);
        lua_pop(L, 1);
    }

    for (int i = 0; i < my_len; i++) {
        reverse_my_Arr[i] = my_Arr[my_len - i - 1];
    }

    lua_newtable(L);

    for (int i = 0; i < my_len; i++) {
        lua_pushinteger(L, reverse_my_Arr[i]);
        lua_rawseti(L, -2, i + 1); // Set value at index i + 1 in the new table
    }

    // Print elements of the new table
    for (int i = 0; i < my_len; i++) {
        lua_rawgeti(L, -1, i + 1); // Retrieve value at index i + 1
        printf("%lld\n", lua_tointeger(L, -1));
        lua_pop(L, 1);
    }

    free(my_Arr);
    free(reverse_my_Arr);

    return 1;
}

int main(void) {
    lua_State *L = luaL_newstate();
    if (L == NULL) {
        luaL_error(L, "Error opening LUA state. %s", lua_tostring(L, -1));
    }

    // Open standard Lua libraries
    luaL_openlibs(L);

    // Register C function my_table_pack to Lua
    lua_pushcfunction(L, reverse_array);
    lua_setglobal(L, "reverse_array");

    // Load and execute Lua script from file
    int res = luaL_dofile(L, "reverse.lua");
    if (res != LUA_OK) {
        luaL_error(L, "Error running code: %s\n", lua_tostring(L, -1));
        lua_close(L);
        return 1;
    }

    // Close Lua state
    lua_close(L);
    return 0;
}
*/

// Exercise 29.4
/***
static int foreach(lua_State *L){
    luaL_checktype(L, 1, LUA_TTABLE);
    luaL_checktype(L, 2, LUA_TFUNCTION);

    lua_getglobal(L, "print");
    if (!lua_rawequal(L, -1, 2)) {
        lua_pop(L, 1);
        return luaL_error(L, "Second argument must be the 'print' function");
    }
    lua_pop(L, 1);

    lua_pushnil(L);
    while (lua_next(L, 1) != 0) {
        lua_pushvalue(L, 2); // push print
        lua_pushvalue(L, -3); // push key
        lua_pushvalue(L, -3); // push value
        lua_call(L, 2, 0);
        lua_pop(L, 1);
    }

    return 0;
}

int main(void) {
    int res;
    lua_State *L = luaL_newstate();
    if (L == NULL) luaL_error(L, "Error creating new state. %s\n", lua_tostring(L, -1));

    luaL_openlibs(L);

    lua_pushcfunction(L, foreach);
    lua_setglobal(L, "foreach");

    char *lua_Code = "foreach({x = 10, y = 20}, print)";

    res = luaL_dostring(L, lua_Code);
    if (res != LUA_OK) {
        luaL_error(L, "Error running lua_Code. %s\n", lua_tostring(L, -1));
    }

    lua_close(L);
    exit(0);
}
*/
// Exercise 29.5
/*
int foreach(lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    luaL_checktype(L, 2, LUA_TFUNCTION);

    lua_getglobal(L, "print");
    if (!lua_rawequal(L, -1, -2)) {
        lua_pop(L, 1);
        return luaL_error(L, "Second argument must be the 'print' function");
    }
    lua_pop(L, 1);

    lua_pushnil(L);
    while (lua_next(L, 1) != 0) {
        lua_pushvalue(L, 2); // push print
        lua_pushvalue(L, -3); // push key
        lua_pushvalue(L, -3); // push value
        lua_call(L, 2, 0);
        lua_pop(L, 1);
    }
    
    // Yielding from within the coroutine
    return lua_yield(L, 0);
}

int main(void) {
    int res;
    lua_State *L = luaL_newstate();
    if (L == NULL) {
        luaL_error(L, "Error creating new state. %s\n", lua_tostring(L, -1));
        exit(1);
    }

    luaL_openlibs(L);

    lua_pushcfunction(L, foreach);
    lua_setglobal(L, "foreach");

    const char *lua_Code =
        "co = coroutine.create(function() "
        "  foreach({x = 10, y = 20}, print) "
        " print(\"kkkkkkk\") "
        "  end) "
        "coroutine.resume(co) ";

    res = luaL_dostring(L, lua_Code);
    if (res != LUA_OK) {
        luaL_error(L, "Error running lua_Code. %s\n", lua_tostring(L, -1));
    }

    lua_getglobal(L, "co");
    // printf("%d\n", lua_isthread(L, -1)); // 1
  
    int nres = 0;
    lua_resume(lua_tothread(L, -1), L, 0, &nres);

    lua_close(L);
    exit(0);
}
*/
/*
int yield_func(lua_State *L, int status, lua_KContext ctx) {
    printf("fffff\n");
    return lua_gettop(L);
}

int foreach(lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    luaL_checktype(L, 2, LUA_TFUNCTION);

    lua_getglobal(L, "print");
    if (!lua_rawequal(L, -1, -2)) {
        lua_pop(L, 1);
        return luaL_error(L, "Second argument must be the 'print' function");
    }
    lua_pop(L, 1);

    lua_pushnil(L);
    while (lua_next(L, 1) != 0) {
        lua_pushvalue(L, 2); // push print
        lua_pushvalue(L, -3); // push key
        lua_pushvalue(L, -3); // push value
        lua_call(L, 2, 0);
        lua_pop(L, 1);
    }
    
    // Yielding from within the coroutine
    return lua_yieldk(L, 0, LUA_OK, (lua_KFunction)yield_func);
}
*/
/*
int main(void) {
    int res;
    lua_State *L = luaL_newstate();
    if (L == NULL) {
        luaL_error(L, "Error creating new state. %s\n", lua_tostring(L, -1));
        exit(1);
    }

    luaL_openlibs(L);

    lua_pushcfunction(L, foreach);
    lua_setglobal(L, "foreach");

    const char *lua_Code =
        "co = coroutine.create(function() "
        "  foreach({x = 10, y = 20}, print) "
        "  print(\"kkkkkkk\") "
        "  end) "
        "coroutine.resume(co) ";

    res = luaL_dostring(L, lua_Code);
    if (res != LUA_OK) {
        luaL_error(L, "Error running lua_Code. %s\n", lua_tostring(L, -1));
    }

    lua_getglobal(L, "co");
    // printf("%d\n", lua_isthread(L, -1)); // 1
  
    int nres = 0;
    lua_resume(lua_tothread(L, -1), L, 0, &nres);

    lua_close(L);
    exit(0);
}
*/
// x       10
// y       20
// fffff
// kkkkkkk
/*
int yield_func(lua_State *L, int status, lua_KContext ctx) {
      printf("mpmpmp!\n");
}

int foreach(lua_State *L) {
    luaL_checktype(L, 1, LUA_TTABLE);
    luaL_checktype(L, 2, LUA_TFUNCTION);

    lua_getglobal(L, "print");
    if (!lua_rawequal(L, -1, -2)) {
        lua_pop(L, 1);
        return luaL_error(L, "Second argument must be the 'print' function");
    }
    lua_pop(L, 1);

    lua_pushnil(L);
    while (lua_next(L, 1) != 0) {
        lua_pushvalue(L, 2); // push print
        lua_pushvalue(L, -3); // push key
        lua_pushvalue(L, -3); // push value
        lua_call(L, 2, 0);
        lua_pop(L, 1);
    }
    
    // Yielding from within the coroutine
    return lua_yieldk(L, 0, NULL, (lua_KFunction)yield_func);
}
*/
/*
int main(void) {
    int res;
    lua_State *L = luaL_newstate();
    if (L == NULL) {
        luaL_error(L, "Error creating new state. %s\n", lua_tostring(L, -1));
        exit(1);
    }

    luaL_openlibs(L);

    // Into NEW THREAD
    lua_State *L1 = lua_newthread(L);
    if (L1 == NULL) {
        luaL_error(L, "Error creating thread L1. %s\n", lua_tostring(L, -1));
        exit(1);
    }

    lua_pushcfunction(L1, foreach);
    lua_setglobal(L1, "foreach");

    const char *lua_Code =
        "co = coroutine.create(function() "
        "  foreach({x = 10, y = 20}, print) "
        "  print(\"fdfdfdfd\") "
        "  end) "
        "coroutine.resume(co)";

    res = luaL_dostring(L1, lua_Code);
    if (res != LUA_OK) {
        luaL_error(L1, "Error running lua_Code. %s\n", lua_tostring(L1, -1));
        exit(1);
    }

    int nres;
    lua_getglobal(L, "co");
    lua_resume(lua_tothread(L, -1), NULL, 0, &nres);

    lua_close(L);
    exit(0);
}
*/
/*
int my_func(lua_State *L, int status, lua_KContext ctx) {
    printf("sssssssssssss\n");
    return 1;
}

int main() {
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);

    const char *lua_code =
        "function my_coroutine()\n"
        "    print('Coroutine started')\n"
        "    print('Yielding...')\n"
        "    coroutine.yield()\n"
        "    print('Resumed after yield')\n"
        "    print('Yielding again...')\n" // Additional yield point
        "    coroutine.yield()\n"           // Additional yield point
        "    print('Resumed after second yield')\n"
        "    return 10\n"
        "end\n";

    // Load Lua code
    if (luaL_loadstring(L, lua_code) != LUA_OK) {
        printf("Error loading Lua code: %s\n", lua_tostring(L, -1));
        lua_close(L);
        return 1;
    }

    // Run Lua code (creating the coroutine)
    if (lua_pcallk(L, 0, 0, 0, my_func) != LUA_OK) {
        printf("Error running Lua code: %s\n", lua_tostring(L, -1));
        lua_close(L);
        return 1;
    }

    // Retrieve the coroutine function from the global environment
    lua_getglobal(L, "my_coroutine");

    // Create the coroutine
    lua_State *coroutine = lua_newthread(L);
    lua_pushvalue(L, -2); // Push the function to be called
    lua_xmove(L, coroutine, 1); // Move the function from L to coroutine

    // Resume the coroutine
    int nres;
    int res = lua_resume(coroutine, NULL, 0, &nres);

    if (res == LUA_YIELD) {
        printf("Coroutine yielded\n");
    } else if (res == LUA_OK) {
        printf("Coroutine completed with return value: %d\n", lua_tointeger(coroutine, -1));
    } else {
        printf("Error running coroutine: %s\n", lua_tostring(coroutine, -1));
    }

    // Resume the coroutine again after the first yield
    res = lua_resume(coroutine, NULL, 0, &nres);

    if (res == LUA_YIELD) {
        printf("Coroutine yielded again\n");
    } else if (res == LUA_OK) {
        printf("Coroutine completed with return value: %d\n", lua_tointeger(coroutine, -1));
    } else {
        printf("Error running coroutine: %s\n", lua_tostring(coroutine, -1));
    }

    // Close Lua state
    lua_close(L);

    return 0;
}
*/
/*
    Coroutine started
    Yielding...
    Coroutine yielded
    Resumed after yield
    Yielding again...
    Coroutine yielded again
*/


