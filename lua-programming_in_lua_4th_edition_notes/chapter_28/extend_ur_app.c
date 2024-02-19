#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

#define MAX_COLOR 255

struct ColorTable {
    char *name;
    unsigned char red, green, blue;
} colortable[] = {
    {"WHITE", MAX_COLOR, MAX_COLOR, MAX_COLOR},
    {"RED", MAX_COLOR, 0, 0},
    {"GREEN", 0, MAX_COLOR, 0},
    {"BLUE", 0, 0, MAX_COLOR},
    {NULL, 0, 0, 0} /* sentinel */
};

int getglobint (lua_State *L, char *var) {
    int isnum, result;
    lua_getglobal(L, var);
    
    result = (int)lua_tointegerx(L, -1, &isnum);
    if (!isnum) luaL_error(L, "'%s' should be a number\n", var);
    lua_pop(L, 1); // remove result from the stack 
    return result;
}

void setcolorfield (lua_State *L, const char *index, int value) {
    /**
    lua_pushstring(L, index); // key //
    lua_pushnumber(L, (double)value / MAX_COLOR); // value //
    lua_settable(L, -3);
    **/

    lua_pushnumber(L, (double)value / MAX_COLOR);
    lua_setfield(L, -2, index);
}

void setcolor (lua_State *L, struct ColorTable *ct) {
    // lua_newtable(L); /* creates a table */
    lua_createtable(L, 0, 3);
    setcolorfield(L, "red", ct->red);
    setcolorfield(L, "green", ct->green);
    setcolorfield(L, "blue", ct->blue);
    lua_setglobal(L, ct->name); /* 'name' = table */
}

// assume that table is on the top of the stack 
int getcolorfield (lua_State *L, const char *key) {
    int result, isnum;
    
    /**
    lua_pushstring(L, key); // push key //
    lua_gettable(L, -2); // get background[key] //
    **/

    int clr = lua_getfield(L, -1, key);
    if (clr != LUA_TNUMBER) luaL_error(L, "invalid component '%s' in color", key);

    result = (int)(lua_tonumberx(L, -1, &isnum) * MAX_COLOR);
    if (!isnum)
        luaL_error(L, "invalid component '%s' in color", key);
    lua_pop(L, 1); // remove number //
    return result;
}

void load (lua_State *L, const char *fname, int *w, int *h, int *r, int *g, int *b) {
    if (luaL_loadfile(L, fname) || lua_pcall(L, 0, 0, 0))
        luaL_error(L, "cannot run config. file: %s", lua_tostring(L, -1));

    *w = getglobint(L, "width");
    *h = getglobint(L, "height");
    
    lua_getglobal(L, "background");
    if (!lua_istable(L, -1))
        luaL_error(L, "'background' is not a table");
    
    *r = getcolorfield(L, "red");
    *g = getcolorfield(L, "green");
    *b = getcolorfield(L, "blue");
    
    lua_pop(L, 1);
}

int main(void) {
    int red, green, blue;
    
    lua_State *L = luaL_newstate();
    luaL_openlibs(L);

    /**
    int w, h, r, g, b;
    load (L, "window.lua", &w, &h, &r, &g, &b);

    printf("width: %d, height: %d, background-color: r = %d, g = %d, b = %d\n", w, h, r, g, b);
    **/

    int i = 0;
    while (colortable[i].name != NULL) {
        setcolor(L, &colortable[i++]);
        printf("color_name: %s, red: %d, blue: %d, green:%d\n", colortable[i].name, 
                         colortable[i].red, colortable[i].blue, colortable[i].green);
    }
    
    /**
    if (luaL_loadfile(L, "window.lua") || lua_pcall(L, 0, 0, 0))
        luaL_error(L, "cannot run config. file: %s", lua_tostring(L, -1));

    lua_getglobal(L, "background");

    if (lua_isstring(L, -1)) { // value is a string? //
        const char *colorname = lua_tostring(L, -1); // get string //
        int i;
        
        // search the color table //
        for (i = 0; colortable[i].name != NULL; i++) {
            if (strcmp(colorname, colortable[i].name) == 0)
            break;
        }

        if (colortable[i].name == NULL) // string not found? //
            luaL_error(L, "invalid color name (%s)", colorname);
        else {  // use colortable[i] 
            red = colortable[i].red;
            green = colortable[i].green;
            blue = colortable[i].blue;
        }
    } else if (lua_istable(L, -1)) {
        red = getcolorfield(L, "red");
        green = getcolorfield(L, "green");
        blue = getcolorfield(L, "blue");
    } else luaL_error(L, "invalid value for 'background'");

    printf("red: %d, green: %d, blue: %d\n", red, green, blue);
    **/
   
    lua_close(L);
    return 0;
}
