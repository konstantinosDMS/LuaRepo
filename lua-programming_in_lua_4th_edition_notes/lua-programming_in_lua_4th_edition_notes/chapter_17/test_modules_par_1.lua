local M = require ("module_complex_1")

local c1 = M.new(5, 3)
local c2 = M.new(3, 8) 
local c3 = M.add(c1, c2)
print(M.tostring(c3))

local c4 = M.add(M.i, c2)
print(M.tostring(c4))
