-- Exercise 17.2 --
local grm = require('geometric_region_module')

c1 = grm.disk(0, 0, 1)
grm.plot(grm.difference(c1, grm.translate(c1, 0.3, 0)), 500, 500)
