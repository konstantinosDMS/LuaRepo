--[[
Although the general concept of coroutines is well understood, the details vary considerably. 
So, for those that already know something about coroutines, it is important to clarify these 
details before we go on. Lua offers what we call asymmetric coroutines. This means that it has 
a function to suspend the execution of a coroutine and a different function to resume a 
suspended coroutine. Some other languages offer symmetric coroutines, where there is only one 
function to transfer control from one coroutine to another. Some people call asymmetric 
coroutines semi-coroutines. However, other people use the same term semi-coroutine to denote a 
restricted implementation of coroutines, where a coroutine can suspend its exe-
cution only when it is not calling any function, that is, when it has no pending calls in its 
control stack. In other words, only the main body of such semi-coroutines can yield. (A generator 
in Python is an example of this meaning of semi-coroutines.)
Unlike the difference between symmetric and asymmetric coroutines, the difference between coroutines
and generators (as presented in Python) is a deep one; generators are simply not powerful enough to im-
plement some of the most interesting constructions that we can write with full coroutines. Lua offers full,
asymmetric coroutines. Those that prefer symmetric coroutines can implement them on top of the asym-
metric facilities of Lua (see Exercise 24.6).
--]]

function dispatch()
    coroutine.yield(coroutine.running())
end

function transfer()
    return coroutine.create(function()
        print('aaa')
    end)
end

transfer()
dispatch()
