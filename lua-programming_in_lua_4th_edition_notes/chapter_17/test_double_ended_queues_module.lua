-- Exercise 17.1 --
local deqm = require ('double_ended_queues_module')
local lst = deqm.listNew()

deqm.pushFirst(lst, 8)
deqm.toString(lst)
print("=============")
deqm.pushLast(lst, 9)
deqm.toString(lst)
print("=============")
deqm.popFirst(lst)
deqm.toString(lst)
print("=============")
deqm.popLast(lst)
deqm.toString(lst)

