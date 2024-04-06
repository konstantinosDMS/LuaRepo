local mylib = require "test_c_modules" -- Load the module "test_c_modules"
mylib.dir("../") -- Call the 'dir' function from the loaded module

--[[ one file: gcc -shared -o test_c_modules.so -fPIC test_c_modules.c --]]
--[[ 
    multiple files:clearclear
    gcc -c -fPIC test_c_modules.c test_c_modules.c
    gcc -shared -o test_c_modules.so test_c_modules_1.o test_c_modules_2.o
--]]