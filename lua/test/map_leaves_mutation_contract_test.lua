-- FUTURE-PARITY-BACKLOG.19.6.2 -- frozen Lua `map_leaves!` admission.

local linkedspec = require("linkedspec")
local interpreter = require("linkedspec.interpreter")
local json = linkedspec.json

local assertions = 0
local failures = {}

local function check(condition, label)
  assertions = assertions + 1
  if not condition then failures[#failures + 1] = label or "assertion failed" end
end

local function check_equal(actual, expected, label)
  check(actual == expected, (label or "values differ") ..
    ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
end

local function check_same_json(actual, expected, label)
  check_equal(json.encode(actual), json.encode(expected), label)
end

local function check_contains(actual, expected, label)
  check(tostring(actual):find(expected, 1, true) ~= nil, (label or "text differs") ..
    ": expected to contain " .. expected .. ", got " .. tostring(actual))
end

local function read_file(path)
  local handle = assert(io.open(path, "rb"))
  local value = assert(handle:read("*a"))
  assert(handle:close())
  return value
end

local function capture(operation)
  local ok, value = pcall(operation)
  return ok, value
end

local function source_for_action(action)
  return "Top::\n -> Done { " .. action .. " }\n\nDone::\n /[a-z]+/\n"
end

local function compile_source(source)
  return linkedspec.compile_spec(
    linkedspec.parse_spec_with_staged_user_function_definitions(source)
  )
end

local function source_engine(action)
  return linkedspec.runtime_engine(compile_source(source_for_action(action)))
end

local function runtime_failure(action, options)
  local ok, failure = capture(function()
    return linkedspec.runtime_parse(source_engine(action), "xhello", options)
  end)
  check_equal(ok, false, "runtime failure expected for " .. action)
  check_equal(linkedspec.is_runtime_interpreter_error(failure), true, "typed runtime failure")
  return failure
end

local function scalar_slice(source, start_position, end_position)
  local scalars = {}
  local position = 1
  while position <= #source do
    local first = source:byte(position)
    local width = first < 0x80 and 1 or (first < 0xE0 and 2 or (first < 0xF0 and 3 or 4))
    scalars[#scalars + 1] = source:sub(position, position + width - 1)
    position = position + width
  end
  local result = {}
  for index = start_position + 1, end_position do result[#result + 1] = scalars[index] end
  return table.concat(result)
end

local function load_generated_module(source, chunk_name)
  local loader = loadstring or load
  local chunk, failure = loader(source, chunk_name)
  if chunk == nil then error(failure, 0) end
  return chunk()
end

local contract = json.decode(read_file("capability_conformance/map_leaves_mutation_contract.json"))
local composition = json.decode(read_file(
  "capability_conformance/write_map_leaves_composition_contract.json"
))

check_equal(contract.contract_id, "linkedspec-map-leaves-mutation-v1", "contract id")
check_equal(composition.contract_id, "linkedspec-write-map-leaves-composition-v1", "composition id")
check_equal(#contract.valid_syntax_cases, 4, "valid syntax count")
check_equal(#contract.invalid_syntax_cases, 14, "invalid syntax count")
check_equal(#contract.excluded_syntax_cases, 5, "excluded syntax count")
check_equal(#contract.success_cases, 10, "success count")
check_equal(#contract.failure_cases, 8, "failure count")
check_equal(#composition.callback_cases, 6, "composition callback count")
check_equal(#composition.continuation_cases, 1, "composition continuation count")

for _, fixture in ipairs(contract.valid_syntax_cases) do
  local expression = linkedspec.parse_action_expression(fixture.source)
  local actual = linkedspec.action_ast.to_json(expression)
  check_equal(actual.kind, "receiver_mutation_chain", fixture.id .. " kind")
  check_equal(actual.receiver.kind, "binding_reference", fixture.id .. " receiver kind")
  check_equal(actual.mutation.kind, "receiver_mutation_call", fixture.id .. " mutation kind")
  check_equal(actual.mutation.method, "map_leaves", fixture.id .. " method")
  check_equal(actual.mutation.source_method, "map_leaves!", fixture.id .. " source method")
  check_equal(actual.mutation.callback.kind, "block_value", fixture.id .. " callback kind")
  check_equal(actual.mutation.callback.body.kind, "action_block", fixture.id .. " body kind")
  for index, call in ipairs(actual.continuation) do
    check_equal(call.kind, "fluent_call", fixture.id .. " continuation " .. index)
  end
  if fixture.expected_ast then
    local expected = fixture.expected_ast
    for _, name in ipairs({ "kind", "source", "source_span", "receiver" }) do
      check_same_json(actual[name], expected[name], fixture.id .. " AST " .. name)
    end
    for _, name in ipairs({
      "kind", "method", "source_method", "source", "source_span", "method_span", "args_span",
    }) do
      check_same_json(actual.mutation[name], expected.mutation[name], fixture.id .. " mutation " .. name)
    end
    for _, name in ipairs({ "kind", "source", "source_span" }) do
      check_same_json(actual.mutation.callback[name], expected.mutation.callback[name],
        fixture.id .. " callback " .. name)
      check_same_json(actual.mutation.callback.body[name], expected.mutation.callback.body[name],
        fixture.id .. " body " .. name)
    end
    check_equal(#actual.continuation, #expected.continuation, fixture.id .. " continuation count")
    for index, expected_call in ipairs(expected.continuation) do
      for _, name in ipairs({
        "kind", "method", "source_method", "source", "source_span", "args_source", "args_span",
      }) do
        check_same_json(actual.continuation[index][name], expected_call[name],
          fixture.id .. " continuation " .. index .. " " .. name)
      end
    end
  else
    check_equal(actual.receiver.name, fixture.expected_receiver, fixture.id .. " receiver")
    local methods = json.array()
    for index, call in ipairs(actual.continuation) do methods[index] = call.method end
    check_same_json(methods, fixture.expected_continuation, fixture.id .. " continuation methods")
  end
end

do
  local unicode = 'tree.map_leaves!() { note = "é🙂"; return(value) }.has_key("🙂")'
  local expression = linkedspec.parse_action_expression(unicode)
  check_equal(expression.source_span["end"], 62, "Unicode chain scalar extent")
  check(expression.source_span["end"] < #unicode, "Unicode chain span is not byte-counted")
  local argument = expression.continuation[1].args[1].value
  check_equal(scalar_slice(unicode, argument.source_span.start, argument.source_span["end"]),
    '"🙂"', "Unicode continuation argument span")
end

for _, fixture in ipairs(contract.invalid_syntax_cases) do
  local ok, failure = capture(function() return linkedspec.parse_action_expression(fixture.source) end)
  check_equal(ok, false, fixture.id .. " rejects")
  check_equal(linkedspec.is_action_parse_error(failure), true, fixture.id .. " typed parse failure")
  if linkedspec.is_action_parse_error(failure) then
    local actual = linkedspec.action_parse_error_to_json(failure)
    local expected = fixture.diagnostic
    check_equal(actual.code, expected.code, fixture.id .. " code")
    check_equal(actual.stage, expected.stage, fixture.id .. " stage")
    for _, name in ipairs({ "start", "end", "unit", "provenance" }) do
      check_equal(actual.source_span[name], expected.source_span[name], fixture.id .. " span " .. name)
    end
    check_equal(actual.message, expected.message, fixture.id .. " message")
  end
end

for _, fixture in ipairs(contract.excluded_syntax_cases) do
  local expression = linkedspec.parse_action_expression(fixture.source)
  check(expression.kind ~= "receiver_mutation_chain", fixture.id .. " remains outside bang lowering")
  if fixture.classification == "invalid_identifier_not_receiver_mutation" then
    check_equal(expression.kind, "raw_perl", fixture.id .. " raw fallback")
  end
end

do
  local result = linkedspec.runtime_parse(source_engine(
    "tree = { \"a\" : \"A\" }; " ..
    "return( tree . map_leaves! ( ) { return(value) } . count_keys() )"
  ), "xhello")
  check_equal(result.value, 1, "insignificant whitespace runtime")
end

local success_sources = {
  hash_sorted_frames_and_cross_kind_leaf = [[
tree = { "b" : { "z" : "B" }, "a" : "A", "arr" : [1, 2] };
audit = [];
result = tree.map_leaves!() {
 audit += path;
 return(if(str_eq(key, "arr"), ["array-leaf"], else(cat(key, "@", depth, "=", value))))
};
return(array(tree, result, audit))]],
  array_index_frames_and_cross_kind_leaf = [[
items = ["A", ["B", "C"], { "h" : "H" }];
audit = [];
result = items.map_leaves!() {
 audit += path;
 return(if(str_eq(index, 2), { "kept" : "hash-leaf" }, else(cat(join_values("/", path), "=", value))))
};
return(array(items, result, audit))]],
  replacement_root_kind_not_revisited = [[
tree = { "leaf" : "A" }; audit = [];
result = tree.map_leaves!() { audit += path; return({ "new" : { "deep" : "X" } }) };
return(array(tree, result, audit))]],
  callback_path_and_value_are_copied = [[
items = [["A"], "B"]; audit = [];
result = items.map_leaves!() {
 audit += path; original = value; value = "local"; path = [99]; return(cat(original, "*"))
};
return(array(items, result, audit))]],
  unrelated_side_effects_persist = [[
tree = { "b" : "B", "a" : "A" }; audit = [];
result = tree.map_leaves!() { audit += path; return(cat(value, "!")) };
return(array(tree, result, audit))]],
  unrelated_receiver_mutation_allowed = [[
tree = { "a" : "A" }; other = [];
result = tree.map_leaves!() { other = [value]; return(cat(value, "!")) };
return(array(tree, result, other))]],
  empty_hash_commits_without_callback = [[
tree = {}; audit = [];
result = tree.map_leaves!() { audit += "called"; return(value) };
return(array(tree, result, audit))]],
  empty_array_commits_without_callback = [[
items = []; audit = [];
result = items.map_leaves!() { audit += "called"; return(value) };
return(array(items, result, audit))]],
  hash_continuation_runs_after_commit = [[
tree = { "b" : "B", "a" : "A" }; audit = [];
result = tree.map_leaves!() { audit += path; return(cat(value, "!")) }.count_keys();
return(array(tree, result, audit))]],
  array_continuation_runs_after_commit = [[
items = ["A", "B"]; audit = [];
result = items.map_leaves!() { audit += path; return(cat(value, "!")) }.count();
return(array(items, result, audit))]],
}

local success_extra = {
  hash_sorted_frames_and_cross_kind_leaf = json.array({ json.array({ "a" }), json.array({ "arr" }),
    json.array({ "b", "z" }) }),
  array_index_frames_and_cross_kind_leaf = json.array({ json.array({ 0 }), json.array({ 1, 0 }),
    json.array({ 1, 1 }), json.array({ 2 }) }),
  replacement_root_kind_not_revisited = json.array({ json.array({ "leaf" }) }),
  callback_path_and_value_are_copied = json.array({ json.array({ 0, 0 }), json.array({ 1 }) }),
  unrelated_side_effects_persist = json.array({ json.array({ "a" }), json.array({ "b" }) }),
  unrelated_receiver_mutation_allowed = json.array({ "A" }),
  empty_hash_commits_without_callback = json.array(),
  empty_array_commits_without_callback = json.array(),
  hash_continuation_runs_after_commit = json.array({ json.array({ "a" }), json.array({ "b" }) }),
  array_continuation_runs_after_commit = json.array({ json.array({ 0 }), json.array({ 1 }) }),
}

for _, fixture in ipairs(contract.success_cases) do
  local source = success_sources[fixture.id]
  check(source ~= nil, fixture.id .. " has an executable source")
  if source then
    local value = linkedspec.runtime_parse(source_engine(source), "xhello").value
    check_same_json(value[1], fixture.expected_bindings[fixture.binding], fixture.id .. " binding")
    check_same_json(value[2], fixture.expected_result, fixture.id .. " result")
    check_same_json(value[3], success_extra[fixture.id], fixture.id .. " callback frames/effects")
  end
end

local private_engine = source_engine("return(undef)")
check_equal(linkedspec._receiver_mutation_context_for_testing, nil, "root facade omits test context")
check_equal(linkedspec._receiver_mutation_evaluate_for_testing, nil, "root facade omits test evaluator")

for _, fixture in ipairs(contract.failure_cases) do
  local source = fixture.source
  local callback_count = 0
  local injected
  local sink
  if fixture.id == "callback_failure_is_atomic" then
    local _, seed = capture(function() return linkedspec.runtime_parse({}, "x") end)
    injected = seed
    injected.code = fixture.expected_diagnostic.code
    injected.message = fixture.expected_diagnostic.message
    source = "tree.map_leaves!() { audit += path; say(\"callback\"); return(cat(value, \"!\")) }"
    sink = function()
      callback_count = callback_count + 1
      if callback_count == 2 then error(injected, 0) end
    end
  end
  local ctx = interpreter._receiver_mutation_context_for_testing(private_engine, fixture.initial_bindings, sink)
  local ok, failure = capture(function()
    return interpreter._receiver_mutation_evaluate_for_testing(private_engine, ctx, source)
  end)
  check_equal(ok, false, fixture.id .. " rejects")
  if fixture.id == "callback_failure_is_atomic" then
    check_equal(failure.failure, injected, fixture.id .. " preserves injected failure")
    check_equal(callback_count, 2, fixture.id .. " failure callback count")
  else
    check_equal(linkedspec.is_runtime_interpreter_error(failure), true, fixture.id .. " typed failure")
    if linkedspec.is_runtime_interpreter_error(failure) then
      local diagnostic = interpreter.to_json(failure.diagnostic)
      local expected = fixture.expected_diagnostic
      for _, name in ipairs({
        "code", "operation", "binding", "method", "attempt", "actual_kind", "expected_kinds",
      }) do
        if expected[name] ~= nil then
          check_same_json(diagnostic[name], expected[name], fixture.id .. " diagnostic " .. name)
        end
      end
      for _, name in ipairs({ "start", "end", "unit", "provenance" }) do
        check_equal(diagnostic.source_span[name], expected.source_span[name], fixture.id .. " span " .. name)
      end
      check_equal(diagnostic.detail, expected.message, fixture.id .. " diagnostic message")
    end
  end
  for name, expected in pairs(fixture.expected_bindings) do
    local actual, present = interpreter._receiver_mutation_binding_for_testing(ctx, name)
    check_equal(present, true, fixture.id .. " binding present " .. name)
    check_same_json(actual, expected, fixture.id .. " rollback/effect " .. name)
  end
  if fixture.id == "receiver_absent" then
    local _, present = interpreter._receiver_mutation_binding_for_testing(ctx, "tree")
    check_equal(present, false, "absent receiver remains absent")
  end
end

do
  local ctx = interpreter._receiver_mutation_context_for_testing(private_engine,
    json.harray({ tree = json.harray({ a = "A" }) }))
  local ok, failure = capture(function()
    return interpreter._receiver_mutation_evaluate_for_testing(private_engine, ctx,
      "tree.map_leaves!() { tree = {}; return(value) }")
  end)
  check_equal(ok, false, "guard release first invocation fails")
  check_equal(failure.code, "receiver_mutation_reentrant", "guard release first code")
  local result = interpreter._receiver_mutation_evaluate_for_testing(private_engine, ctx,
    "tree.map_leaves!() { return(cat(value, \"!\")) }")
  check_same_json(result, contract.guard_release_case.expected_result, "guard releases after callback failure")
  local stored = interpreter._receiver_mutation_binding_for_testing(ctx, "tree")
  check_same_json(stored, contract.guard_release_case.expected_bindings.tree, "guard release second commit")
end

do
  local _, injected = capture(function() return linkedspec.runtime_parse({}, "x") end)
  injected.code = "continuation_failed"
  injected.message = "continuation requested failure"
  local ctx = interpreter._receiver_mutation_context_for_testing(
    private_engine,
    json.harray({ tree = json.harray({ a = "A" }) }),
    function() error(injected, 0) end
  )
  local ok, failure = capture(function()
    return interpreter._receiver_mutation_evaluate_for_testing(private_engine, ctx,
      "tree.map_leaves!() { return(cat(value, \"!\")) }.with() { say(\"fail\"); return(value) }")
  end)
  check_equal(ok, false, "continuation failure rejects")
  check_equal(failure.failure, injected, "continuation failure identity preserved")
  local stored = interpreter._receiver_mutation_binding_for_testing(ctx, "tree")
  check_same_json(stored, contract.continuation_failure_case.expected_bindings.tree,
    "continuation failure preserves bang commit")

  local discarded = linkedspec.runtime_parse(source_engine(
    "tree = { \"a\" : \"A\" }; " ..
    "tree.map_leaves!() { return(cat(value, \"!\")) }; return(tree)"
  ), "xhello")
  check_same_json(discarded.value, json.harray({ a = "A!" }), "statement-position bang commits")
end

do
  local result = linkedspec.runtime_parse(source_engine([[
initial = { "leaf" : ["A"] }; tree = initial;
mapped = tree.map_leaves!() { return(array(value.first(), { "nested" : ["B"] })) };
initial["leaf"][0] = "initial-mutated";
mapped["leaf"][0] = "returned-mutated";
tree["leaf"][1]["nested"][0] = "committed-mutated";
return(array(initial, tree, mapped))]]), "xhello")
  check_same_json(result.value, json.array({
    json.harray({ leaf = json.array({ "initial-mutated" }) }),
    json.harray({ leaf = json.array({ "A", json.harray({ nested = json.array({ "committed-mutated" }) }) }) }),
    json.harray({ leaf = json.array({ "returned-mutated", json.harray({ nested = json.array({ "B" }) }) }) }),
  }), "all aggregate boundaries detach")
end

local shadow_source = [[fn shadow_write(tree) {
 tree[0]["local"] = "A";
 return(tree)
}

Top::
 -> Done { tree = { "leaf" : [] }; result = tree.map_leaves!() { return(shadow_write(value)) }; return(array(tree, result)) }

Done::
 /[a-z]+/
]]
do
  local expected = json.harray({ leaf = json.array({ json.harray({ ["local"] = "A" }) }) })
  local result = linkedspec.runtime_parse(linkedspec.runtime_engine(compile_source(shadow_source)), "xhello")
  check_same_json(result.value, json.array({ expected, expected }), "same-spelling function shadow identity")
end

local function_body_source = [[fn mutate_locally(tree) {
 mapped = tree.map_leaves!() { return(cat(value, "!")) };
 return(array(tree, mapped))
}

Top::
 -> Done { return(mutate_locally({ "a" : "A" })) }

Done::
 /[a-z]+/
]]
do
  local expected = json.harray({ a = "A!" })
  local result = linkedspec.runtime_parse(linkedspec.runtime_engine(compile_source(function_body_source)), "xhello")
  check_same_json(result.value, json.array({ expected, expected }), "user-function body preserves typed bang carrier")
end

do
  local nonbang = linkedspec.runtime_parse(source_engine([[
tree = { "leaf" : [{ "x" : "original" }] };
result = tree.map_leaves() { value[0]["x"] = "changed"; return(value) };
return(array(tree, result))]]), "xhello")
  check_same_json(nonbang.value, json.array({
    json.harray({ leaf = json.array({ json.harray({ x = "original" }) }) }),
    json.harray({ leaf = json.array({ json.harray({ x = "changed" }) }) }),
  }), "non-bang callback cannot mutate receiver by alias")
end

local guarded_paths = {
  { 'tree += { say("operand"); "x" }', "append" },
  { 'tree[{ say("operand"); 0 }] = { say("rhs"); "x" }', "nested_write" },
  { 'set(tree, { say("operand"); [] })', "helper:set" },
  { 'push(tree, { say("operand"); "x" })', "helper:push" },
  { 'tree.push_back({ say("operand"); "x" })', "push_back" },
  { 'tree.push_front({ say("operand"); "x" })', "push_front" },
  { "tree.pop_back()", "pop_back" },
  { "tree.pop_front()", "pop_front" },
  { 'split(tree, { say("operand"); "a,b" }, ",")', "helper:split" },
  { 'split_each(tree, { say("operand"); "," })', "helper:split_each" },
  { "trim_each(tree)", "helper:trim_each" },
  { "filter_nonempty(tree)", "helper:filter_nonempty" },
  { 'filter_match(tree, { say("operand"); /^a/ })', "helper:filter_match" },
  { "lowercase_each(tree)", "helper:lowercase_each" },
  { "uppercase_each(tree)", "helper:uppercase_each" },
  { "uniq(tree)", "helper:uniq" },
  { 'substr(tree, { say("operand"); "a" }, "b")', "helper:substr" },
  { 'regex_subst(tree, { say("operand"); /a/ }, "b")', "helper:regex_subst" },
}
for _, row in ipairs(guarded_paths) do
  local events = {}
  local failure = runtime_failure(
    'tree = ["seed"]; tree.map_leaves!() { ' .. row[1] .. "; return(value) }",
    { diagnostic_sink = function(event) events[#events + 1] = event end }
  )
  if linkedspec.is_runtime_interpreter_error(failure) then
    local diagnostic = interpreter.to_json(failure.diagnostic)
    check_equal(diagnostic.code, "receiver_mutation_reentrant", row[2] .. " guarded code")
    check_equal(diagnostic.attempt, row[2], row[2] .. " guarded attempt")
  end
  check_equal(#events, 0, row[2] .. " operands do not run")
end

do
  local events = {}
  local failure = runtime_failure(
    'tree = { "a" : "A" }; tree.map_leaves!() { ' ..
      'set_key(tree, { say("operand"); "x" }, value); return(value) }',
    { diagnostic_sink = function(event) events[#events + 1] = event end }
  )
  local diagnostic = interpreter.to_json(failure.diagnostic)
  check_equal(diagnostic.code, "receiver_mutation_reentrant", "set_key guarded code")
  check_equal(diagnostic.attempt, "helper:set_key", "set_key guarded attempt")
  check_equal(#events, 0, "set_key operands do not run")

  local pure = linkedspec.runtime_parse(source_engine(
    'value = "a1"; substr(value, 1, 2); return(value)'
  ), "xhello")
  check_equal(pure.value, "a1", "ordinary three-argument substr statement remains pure")
end

do
  local _, injected = capture(function() return linkedspec.runtime_parse({}, "x") end)
  injected.code = "callback_failed"
  injected.message = "injected callback failure"
  local failure = runtime_failure(
    'tree = { "a" : "A" }; tree.map_leaves!() { say("fail"); return(value) }',
    { diagnostic_sink = function() error(injected, 0) end }
  )
  check_equal(failure, injected, "callback failure identity is propagated unchanged")
end

local composition_seen = {}
do
  local value = linkedspec.runtime_parse(source_engine([[
tree = { "leaf" : [] };
result = tree.map_leaves!() { value[0]["name"] = "A"; return(value) };
return(array(tree, result))]]), "xhello").value
  local expected = json.harray({ leaf = json.array({ json.harray({ name = "A" }) }) })
  check_same_json(value, json.array({ expected, expected }),
    "composition callback value vivifies without revisit")
  composition_seen.callback_value_vivifies_and_replaces_without_revisit = true
end

do
  local value = linkedspec.runtime_parse(source_engine([[
tree = { "a" : "A" };
result = tree.map_leaves!() { journal["seen"][0] = path; return(cat(value, "!")) };
return(array(tree, result, journal))]]), "xhello").value
  check_same_json(value, json.array({
    json.harray({ a = "A!" }),
    json.harray({ a = "A!" }),
    json.harray({ seen = json.array({ json.array({ "a" }) }) }),
  }), "composition unrelated vivification")
  composition_seen.unrelated_vivification_commits_before_receiver_commit = true
end

do
  local _, injected = capture(function() return linkedspec.runtime_parse({}, "x") end)
  local ctx = interpreter._receiver_mutation_context_for_testing(
    private_engine,
    json.harray({ tree = json.harray({ a = "A", b = "B" }) }),
    function(event)
      if event.message:gsub("%s+$", "") == "B" then error(injected, 0) end
    end
  )
  local ok = capture(function()
    return interpreter._receiver_mutation_evaluate_for_testing(private_engine, ctx,
      'tree.map_leaves!() { journal[0] = path; say(value); return(cat(value, "!")) }')
  end)
  check_equal(ok, false, "composition later callback failure")
  local tree = interpreter._receiver_mutation_binding_for_testing(ctx, "tree")
  local journal = interpreter._receiver_mutation_binding_for_testing(ctx, "journal")
  check_same_json(tree, json.harray({ a = "A", b = "B" }), "later failure rolls receiver back")
  check_same_json(journal, json.array({ json.array({ "b" }) }), "later failure keeps unrelated writes")
  composition_seen.unrelated_writes_persist_when_later_callback_fails = true
end

do
  local ctx = interpreter._receiver_mutation_context_for_testing(private_engine,
    json.harray({ tree = json.harray({ a = "A" }), other = json.array() }))
  local ok, failure = capture(function()
    return interpreter._receiver_mutation_evaluate_for_testing(private_engine, ctx,
      'tree.map_leaves!() { other[2] = { other += "rhs"; "outer" }; return(value) }')
  end)
  check_equal(ok, false, "composition unrelated write failure")
  check_equal(failure.code, "nested_write_array_gap", "composition unrelated write diagnostic")
  local tree = interpreter._receiver_mutation_binding_for_testing(ctx, "tree")
  local other = interpreter._receiver_mutation_binding_for_testing(ctx, "other")
  check_same_json(tree, json.harray({ a = "A" }), "unrelated write failure rolls receiver back")
  check_same_json(other, json.array({ "rhs" }), "unrelated write failure keeps RHS effect")
  composition_seen.failed_unrelated_write_preserves_rhs_effect_only = true
end

do
  local events = {}
  local failure = runtime_failure(
    'tree = { "a" : "A" }; tree.map_leaves!() { ' ..
      'tree[{ say("selector"); undef }] = { say("rhs"); "X" }; return(value) }',
    { diagnostic_sink = function(event) events[#events + 1] = event end }
  )
  check_equal(failure.code, "receiver_mutation_reentrant", "composition same-receiver precedence")
  check_equal(#events, 0, "composition same-receiver operands skipped")
  composition_seen.same_receiver_guard_precedes_write_evaluation = true
end

composition_seen.same_spelling_shadow_vivifies_independently = true

do
  local ctx = interpreter._receiver_mutation_context_for_testing(private_engine,
    json.harray({ tree = json.harray({ a = "A" }) }))
  local ok, failure = capture(function()
    return interpreter._receiver_mutation_evaluate_for_testing(private_engine, ctx,
      'tree.map_leaves!() { return(cat(value, "!")) }.with() { ' ..
      'tree["extra"][2] = "X"; return(value) }')
  end)
  check_equal(ok, false, "composition post-commit nested write failure")
  check_equal(failure.code, "nested_write_array_gap", "composition continuation diagnostic")
  local tree = interpreter._receiver_mutation_binding_for_testing(ctx, "tree")
  check_same_json(tree, json.harray({ a = "A!" }), "composition continuation keeps bang commit")
  composition_seen.post_commit_write_failure_preserves_map_commit = true
end

for _, fixture in ipairs(composition.callback_cases) do
  check_equal(composition_seen[fixture.id], true, fixture.id .. " composition row executed")
end
for _, fixture in ipairs(composition.continuation_cases) do
  check_equal(composition_seen[fixture.id], true, fixture.id .. " composition row executed")
end

do
  local corrupt = compile_source(source_for_action(
    'tree = { "a" : "A" }; return(tree.map_leaves!() { return(value) })'
  ))
  local payload = linkedspec.compiled_spec.action_payloads(corrupt.rules_by_label.Top)[1]
  local chain = payload.action_ast.statements[2].expr.args[1].value
  chain.receiver.source = "corrupt"

  local validator_ok, validator_failure = capture(function()
    return linkedspec.validate_receiver_mutation_serialized_state(corrupt)
  end)
  check_equal(validator_ok, false, "corrupt receiver validator rejects")
  check_equal(linkedspec.is_compiled_spec_error(validator_failure), true, "corrupt validator typed")
  check_contains(validator_failure.message, "receiver_mutation_serialized_state_invalid", "validator code")

  local runtime_ok, runtime_error = capture(function() return linkedspec.runtime_engine(corrupt) end)
  check_equal(runtime_ok, false, "corrupt receiver runtime rejects")
  check_equal(linkedspec.is_runtime_interpreter_error(runtime_error), true, "corrupt runtime typed")
  if linkedspec.is_runtime_interpreter_error(runtime_error) then
    check_equal(runtime_error.diagnostic.code, "receiver_mutation_serialized_state_invalid", "runtime code")
  end

  local emit_ok, emit_error = capture(function()
    return linkedspec.emit_lua_source_v2(corrupt, "map-leaves-mutation/corrupt.spec")
  end)
  check_equal(emit_ok, false, "corrupt receiver emitter rejects")
  check_equal(linkedspec.is_generated_source_error(emit_error), true, "corrupt emitter typed")
  if linkedspec.is_generated_source_error(emit_error) then
    check_contains(emit_error.detail, "receiver_mutation_serialized_state_invalid", "emitter code")
  end

  local plan_ok, plan_error = capture(function()
    return linkedspec.validate_generated_rule_plan_v2(
      corrupt,
      linkedspec.build_generated_rule_plan(corrupt),
      "map-leaves-mutation/corrupt.spec"
    )
  end)
  check_equal(plan_ok, false, "corrupt receiver generated plan rejects")
  check_equal(linkedspec.is_generated_source_error(plan_error), true, "corrupt plan typed")
  if linkedspec.is_generated_source_error(plan_error) then
    check_contains(plan_error.detail, "receiver_mutation_serialized_state_invalid", "plan code")
  end

  local corrupt_kind = compile_source(source_for_action(
    'tree = { "a" : "A" }; return(tree.map_leaves!() { return(value) })'
  ))
  local kind_payload = linkedspec.compiled_spec.action_payloads(corrupt_kind.rules_by_label.Top)[1]
  local kind_chain = kind_payload.action_ast.statements[2].expr.args[1].value
  kind_chain.kind = "corrupt_receiver_mutation_chain"
  local kind_validator_ok, kind_validator_failure = capture(function()
    return linkedspec.validate_receiver_mutation_serialized_state(corrupt_kind)
  end)
  check_equal(kind_validator_ok, false, "corrupt chain kind validator rejects")
  check_equal(linkedspec.is_compiled_spec_error(kind_validator_failure), true,
    "corrupt chain kind validator typed")
  local kind_runtime_ok, kind_runtime_failure = capture(function()
    return linkedspec.runtime_engine(corrupt_kind)
  end)
  check_equal(kind_runtime_ok, false, "corrupt chain kind runtime rejects")
  check_equal(linkedspec.is_runtime_interpreter_error(kind_runtime_failure), true,
    "corrupt chain kind runtime typed")
end

do
  local identity = "map-leaves-mutation/lua.spec"
  local source = source_for_action(
    'tree = { "b" : "B", "a" : "A" }; ' ..
    'return(tree.map_leaves!() { return(cat(value, "!")) }.count_keys())'
  )
  local authored = linkedspec.parse_spec(source, { source_id = identity })
  local reconstructed = linkedspec.spec_ast.from_json(
    "SpecFile",
    json.decode(json.encode(linkedspec.spec_ast.to_json(authored)))
  )
  local compiled = linkedspec.compile_spec(reconstructed)
  local descriptor = json.encode(linkedspec.to_descriptor_json(compiled))
  check_contains(descriptor, '"kind":"receiver_mutation_chain"', "descriptor chain node")
  check_contains(descriptor, '"kind":"binding_reference"', "descriptor receiver node")
  check_contains(descriptor, '"source_method":"map_leaves!"', "descriptor bang spelling")
  check_equal(linkedspec.runtime_parse(linkedspec.runtime_engine(compiled), "xhello").value,
    2, "reconstructed public route")

  local plan = linkedspec.build_generated_rule_plan(compiled)
  check_equal(linkedspec.execute_generated_parser_v2(compiled, plan, "xhello", identity),
    2, "generated direct route")

  local emitted = linkedspec.emit_lua_source_v2(compiled, identity)
  local generated = load_generated_module(emitted, "@map-leaves-mutation-lua")
  check_equal(generated.execute("xhello"), 2, "emitted module route")

  local cli = linkedspec.run_primary_cli({ "--inline-spec", source, "--input", "xhello" })
  check_equal(cli.exit_code, 0, "primary CLI exit")
  check_equal(cli.stderr, "", "primary CLI stderr")
  check_equal(json.decode(cli.stdout), 2, "primary CLI result")
end

if #failures == 0 then
  io.stdout:write("map-leaves mutation Lua dual-ABI admission: ", assertions, " assertions passed\n")
else
  io.stderr:write(
    "map-leaves mutation Lua dual-ABI admission: ",
    #failures,
    " of ",
    assertions,
    " assertions failed\n"
  )
  for _, message in ipairs(failures) do io.stderr:write("- ", message, "\n") end
  os.exit(1)
end
