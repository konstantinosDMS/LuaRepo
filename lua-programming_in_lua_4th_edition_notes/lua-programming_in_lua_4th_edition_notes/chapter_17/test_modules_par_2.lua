local M = require('module_complex_2')
local c1 = M.new(1, 2)
local c2 = M.new(3, 4)
local c3 = M.add(c1, c2)
print(M.tostring(c3))
