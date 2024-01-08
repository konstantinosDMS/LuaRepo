-- Exercise 17.4 --
-- Custom searcher that searches for Lua files and C libraries
local custom_searcher = function(module_name)
    local lua_path = "./?.lua"
    local so_path = "./?.so;/usr/lib/lua5.2/?.so;/usr/share/lua5.2/?.lua;./?/?/?.lua"

    -- Attempt to find a Lua file
    local lua_file = package.searchpath(module_name, lua_path)
    if lua_file then
        return loadfile(lua_file)
    end

    -- Attempt to find a C library
    local so_file = package.searchpath(module_name, so_path)
    if so_file then
        local loader = package.loadlib(so_file, "luaopen_" .. module_name)
        if loader then
            return loader
        end
    end

    -- Module not found
    return nil
end

-- Insert the custom searcher at the beginning of package.searchers
table.insert(package.searchers, 1, custom_searcher)

-- Example usage
local success, module = pcall(require, "kostas.lua.apps.foo")

if success then
    print("Module loaded successfully")
else
    print("Error loading module:", module)
end

custom_searcher('kostas.lua.apps.foo')
