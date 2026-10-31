assert(loadfile("lua/src/linkedspec/interpreter.lua"))
assert(loadfile("lua/test/run.lua"))
dofile("lua/test/definedness_result_receivers_test.lua")
dofile("lua/test/lexical_result_guard_composition_test.lua")
