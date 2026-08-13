-- FUTURE-PARITY-BACKLOG.14.3.6.3 — admitted shared Lua recognition transactions.
--
-- Ordinary Lua discovery and canonical CI execute this exact consumer once on
-- each ABI through repository-local project data:
--
--   bash tools/run_lua_project_data.sh puc lua/test/recognition_transaction_contract_test.lua
--   bash tools/run_lua_project_data.sh luajit lua/test/recognition_transaction_contract_test.lua

local json = require("linkedspec.json")
local linkedspec = require("linkedspec")
local source_location = require("linkedspec.source_location")

-- This module is deliberately private: linkedspec/init.lua must not export it.
local transaction = require("linkedspec.recognition_transaction")

local assertions = 0
local failures = {}

local function check(condition, label)
  assertions = assertions + 1
  if not condition then failures[#failures + 1] = label end
end

local function check_equal(actual, expected, label)
  check(
    actual == expected,
    label .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual)
  )
end

local function check_same_json(actual, expected, label)
  check_equal(json.encode(actual), json.encode(expected), label)
end

local function capture(operation)
  local ok, value = pcall(operation)
  return ok, value
end

local function read_file(path)
  local handle = assert(io.open(path, "rb"))
  local value = assert(handle:read("*a"))
  assert(handle:close())
  return value
end

local contract = json.decode(
  read_file("capability_conformance/recognition_transaction_contract.json")
)

local authored_source = [[Top::AND
 => Child {
  tx = recognition_checkpoint()
  matched = recognize_once(tx, call(Child))
  if(matched) {
   payload = recognition_commit(tx)
   return(payload)
  } else {
   recognition_rollback(tx)
   return("miss")
  }
 }

Child::AND
 /x/
 E { return(false) }
]]

local ordinary_cursor_source = [[Top::AND
 /a/ E {
  save_cursor()
  rewind_match_start()
  restore_cursor()
  return("ok")
 }
]]

local function compile_source(source)
  local parsed = linkedspec.parse_spec(source)
  linkedspec.validate_spec(parsed)
  return parsed, linkedspec.compile_spec(parsed)
end

local function state(cursor, boundary, marks)
  return transaction.frame_state({
    cursor = cursor,
    boundary = boundary,
    marks = marks,
  })
end

local function initial_state()
  return state(2, 1, json.harray({ a = 1 }))
end

local function staged_state()
  return state(5, 4, json.harray({ a = 3, b = 4 }))
end

local function authority(source_identity)
  return transaction.authority({
    source_authority = source_location.source_authority({
      sources = json.harray({ input = "abcdef" }),
    }),
    source_identity = source_identity,
  })
end

local function frame_state(value, frame)
  local snapshot = transaction.to_json(transaction.frame_snapshot(value, frame))
  return json.harray({
    cursor = snapshot.cursor,
    boundary = snapshot.boundary,
    marks = snapshot.marks,
  })
end

local function diagnostic_fixture(code)
  for _, row in ipairs(contract.diagnostics) do
    if row.code == code then return row end
  end
  error("missing recognition diagnostic fixture '" .. code .. "'", 0)
end

local function expect_diagnostic(code, operation, expected)
  local ok, captured = capture(operation)
  check_equal(ok, false, code .. " rejects")
  if ok then return end
  check_equal(transaction.is_error(captured), true, code .. " typed error")
  if not transaction.is_error(captured) then return end

  local record = transaction.to_json(captured)
  local fixture = diagnostic_fixture(code)
  local actual_fields = json.array()
  for key in pairs(record) do actual_fields[#actual_fields + 1] = key end
  local expected_fields = json.array()
  for _, key in ipairs(fixture.fields) do expected_fields[#expected_fields + 1] = key end
  table.sort(actual_fields)
  table.sort(expected_fields)
  check_same_json(actual_fields, expected_fields, code .. " exact fields")
  check_equal(record.code, code, code .. " code")
  for key, value in pairs(expected or {}) do
    check_equal(record[key], value, code .. " context " .. key)
  end
  check_equal(
    tostring(captured),
    "LINKEDSPEC_RECOGNITION_TRANSACTION_ERROR:" .. code,
    code .. " stable message"
  )
end

local function payload_for(operation)
  if operation == "attempt_match:false" then return false end
  if operation == "attempt_match:0" then return 0 end
  if operation == "attempt_match:" then return "" end
  if operation == "attempt_match:null" then return json.null end
  if operation == "attempt_match:value" then return "value" end
  error("unowned matched-payload operation " .. operation, 0)
end

local function all_objects(value, result)
  result = result or {}
  if type(value) ~= "table" then return result end
  result[#result + 1] = value
  for _, child in pairs(value) do
    if type(child) == "table" then all_objects(child, result) end
  end
  return result
end

local function objects_with_kind(value, kind)
  local result = {}
  for _, object in ipairs(all_objects(value)) do
    if object.kind == kind then result[#result + 1] = object end
  end
  return result
end

check_equal(contract.contract_id, "linkedspec-recognition-transaction-v1", "contract id")
check_equal(contract.format, 1, "contract format")
check_equal(
  contract.status,
  "neutral_runtime_recurring_and_public_no_drift_complete",
  "admitted Lua status"
)
for name, expected in pairs({
  current_action_ir_nodes = 133,
  dedicated_action_ir_nodes = 4,
  all_action_ir_nodes = 137,
  canonical_call_contracts = 246,
  token_positive_cases = 8,
  token_negative_cases = 17,
  effect_graph_cases = 6,
  mark_cases = 6,
  progress_cases = 8,
  diagnostics = 15,
  mutations = 58,
}) do
  check_equal(contract.expected_counts[name], expected, "count " .. name)
end
check_equal(
  contract.authored_surface.availability,
  "available in Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT; exact recurring " ..
    "and public no-drift proof is current",
  "Lua runtimes are admitted"
)
check_equal(#contract.rollout, 9, "rollout count")
for index = 1, 9 do
  check_equal(contract.rollout[index].status, "complete", "complete rollout " .. index)
end
check_equal(contract.rollout[6].leg, "puc_lua", "PUC Lua rollout")
check_equal(contract.rollout[6].status, "complete", "PUC Lua admitted")
check_equal(contract.rollout[7].leg, "luajit", "LuaJIT rollout")
check_equal(contract.rollout[7].status, "complete", "LuaJIT admitted")
check_equal(contract.rollout[8].leg, "recurring", "recurring rollout")
check_equal(contract.rollout[8].status, "complete", "recurring proof admitted")
check_equal(
  contract.rollout[8].paths[1],
  "tools/check_recognition_transaction_six_runtime.sh",
  "recurring driver path"
)
do
  local value = authority("input.spec")
  local parent = transaction.enter_invocation(value, {
    rule = "Top", origin = "root", state = initial_state(),
  })
  transaction.write_mark(value, parent, "shared", 1)
  local parent_snapshot = transaction.to_json(transaction.frame_snapshot(value, parent))
  local child = transaction.enter_invocation(value, {
    rule = "Top", origin = "Top->Top", state = state(3, 2, json.harray()),
  })
  local child_snapshot = transaction.to_json(transaction.frame_snapshot(value, child))
  check(child_snapshot.invocation > parent_snapshot.invocation, "invocation ids increase")
  check(child_snapshot.generation > parent_snapshot.generation, "mark generations increase")
  check_equal(transaction.read_mark(value, child, "shared"), nil, "child marks start empty")
  transaction.write_mark(value, child, "shared", 4)
  check_equal(transaction.read_mark(value, parent, "shared"), 1, "parent mark is isolated")
  transaction.leave_invocation(value, child)

  local next_frame = transaction.enter_invocation(value, {
    rule = "Top", origin = "Top->Top:next", state = state(3, 2, json.harray()),
  })
  local next_snapshot = transaction.to_json(transaction.frame_snapshot(value, next_frame))
  check(next_snapshot.invocation > child_snapshot.invocation, "invocation ids are not reused")
  check(next_snapshot.generation > child_snapshot.generation, "generations are not reused")
  transaction.leave_invocation(value, next_frame)

  parent_snapshot.marks.shared = 99
  check_equal(transaction.read_mark(value, parent, "shared"), 1, "snapshot marks are detached")
  transaction.leave_invocation(value, parent)
  expect_diagnostic("recognition_mark_generation_invalid", function()
    return transaction.frame_snapshot(value, parent)
  end, {
    rule = "Top", origin = "root", generation = parent_snapshot.generation,
  })
end

for _, fixture in ipairs(contract.fixtures.token_positive) do
  local value = authority("input.spec")
  local frame = transaction.enter_invocation(value, {
    rule = "Top", origin = fixture.id, state = initial_state(),
  })
  local token = transaction.checkpoint(value, frame, fixture.id)
  local attempt
  for _, operation in ipairs(fixture.ops) do
    if operation:match("^attempt_") then attempt = operation end
  end
  local matched = attempt ~= "attempt_miss"
  local payload
  if matched then
    payload = payload_for(attempt)
  else
    payload = json.null
  end
  check_equal(transaction.attempt(value, frame, token, {
    matched = matched,
    payload = payload,
    state = matched and staged_state() or initial_state(),
  }), matched, fixture.id .. " strict match")
  if fixture.ops[#fixture.ops] == "commit" then
    check_same_json(transaction.commit(value, frame, token), payload, fixture.id .. " payload")
  else
    check_equal(transaction.rollback(value, frame, token), nil, fixture.id .. " rollback")
  end
  transaction.leave_invocation(value, frame)
end

for index = 1, 2 do
  local fixture = contract.fixtures.marks[index]
  local value = authority("input.spec")
  local frame = transaction.enter_invocation(value, {
    rule = "Top", origin = fixture.id, state = initial_state(),
  })
  local token = transaction.checkpoint(value, frame, fixture.id)
  transaction.attempt(value, frame, token, {
    matched = true, payload = "payload", state = staged_state(),
  })
  if fixture.terminal == "commit" then
    transaction.commit(value, frame, token)
  else
    transaction.rollback(value, frame, token)
  end
  check_same_json(frame_state(value, frame), fixture.expected, fixture.id .. " state")
  transaction.leave_invocation(value, frame)
end

local escapes = {
  copy = true,
  comparison = true,
  aggregate_storage = true,
  function_storage = true,
  codeblock_storage = true,
  ["return"] = true,
  capture = true,
  serialization = true,
}
for _, fixture in ipairs(contract.fixtures.token_negative) do
  if escapes[fixture.violation] then
    local value = authority("input.spec")
    local frame = transaction.enter_invocation(value, {
      rule = "Top", origin = fixture.id, state = initial_state(),
    })
    local token = transaction.checkpoint(value, frame, fixture.id)
    expect_diagnostic("recognition_token_escape", function()
      return transaction.reject_escape(value, frame, token, fixture.violation)
    end, { rule = "Top", origin = fixture.id, escape = fixture.violation })
    transaction.leave_invocation(value, frame)
  end
end

do
  local value = authority("input.spec")
  local frame = transaction.enter_invocation(value, {
    rule = "Top", origin = "missing_attempt", state = initial_state(),
  })
  local token = transaction.checkpoint(value, frame, "missing_attempt")
  expect_diagnostic("recognition_attempt_count", function()
    return transaction.rollback(value, frame, token)
  end, { rule = "Top", origin = "missing_attempt", count = 0 })
  transaction.leave_invocation(value, frame)
end

do
  local value = authority("input.spec")
  local frame = transaction.enter_invocation(value, {
    rule = "Top", origin = "retry", state = initial_state(),
  })
  local token = transaction.checkpoint(value, frame, "retry")
  transaction.attempt(value, frame, token, {
    matched = false, payload = json.null, state = initial_state(),
  })
  expect_diagnostic("recognition_attempt_count", function()
    return transaction.attempt(value, frame, token, {
      matched = true, payload = "value", state = staged_state(),
    })
  end, { rule = "Top", origin = "retry", count = 2 })
  transaction.leave_invocation(value, frame)
end

do
  local value = authority("input.spec")
  local parent = transaction.enter_invocation(value, {
    rule = "Top", origin = "parent", state = initial_state(),
  })
  local token = transaction.checkpoint(value, parent, "parent")
  local child = transaction.enter_invocation(value, {
    rule = "Top", origin = "child", state = initial_state(),
  })
  expect_diagnostic("recognition_cross_invocation", function()
    return transaction.rollback(value, child, token)
  end, { rule = "Top", origin = "child" })
  transaction.leave_invocation(value, child)
  transaction.leave_invocation(value, parent)
end

do
  local first = authority("first.spec")
  local first_frame = transaction.enter_invocation(first, {
    rule = "Top", origin = "cross_source", state = initial_state(),
  })
  local token = transaction.checkpoint(first, first_frame, "cross_source")
  local second = authority("second.spec")
  local second_frame = transaction.enter_invocation(second, {
    rule = "Top", origin = "cross_source", state = initial_state(),
  })
  expect_diagnostic("recognition_cross_source", function()
    return transaction.rollback(second, second_frame, token)
  end, { rule = "Top", origin = "cross_source" })
  transaction.leave_invocation(second, second_frame)
  transaction.leave_invocation(first, first_frame)
end

do
  local value = authority("input.spec")
  local frame = transaction.enter_invocation(value, {
    rule = "Top", origin = "double_terminal", state = initial_state(),
  })
  local token = transaction.checkpoint(value, frame, "double_terminal")
  transaction.attempt(value, frame, token, {
    matched = true, payload = "value", state = staged_state(),
  })
  transaction.commit(value, frame, token)
  expect_diagnostic("recognition_token_reused", function()
    return transaction.rollback(value, frame, token)
  end, { rule = "Top", origin = "double_terminal", operation = "rollback" })
  transaction.leave_invocation(value, frame)
end

do
  local value = authority("input.spec")
  local frame = transaction.enter_invocation(value, {
    rule = "Top", origin = "token_expected", state = initial_state(),
  })
  expect_diagnostic("recognition_token_expected", function()
    return transaction.commit(value, frame, "not-a-token")
  end, { rule = "Top", origin = "token_expected" })
  transaction.leave_invocation(value, frame)
end

do
  local value = authority("input.spec")
  local parent = transaction.enter_invocation(value, {
    rule = "Top", origin = "nesting_parent", state = initial_state(),
  })
  local before = frame_state(value, parent)
  local token = transaction.checkpoint(value, parent, "nesting_parent")
  transaction.attempt(value, parent, token, {
    matched = true, payload = "value", state = staged_state(),
  })
  local child = transaction.enter_invocation(value, {
    rule = "Child", origin = "nesting_child", state = state(3, 2, json.harray()),
  })
  expect_diagnostic("recognition_nesting_forbidden", function()
    return transaction.checkpoint(value, child, "nesting_child")
  end, { rule = "Child", origin = "nesting_child" })
  check_same_json(frame_state(value, parent), before, "nested checkpoint restores parent")
  transaction.leave_invocation(value, child)
  transaction.leave_invocation(value, parent)
end

do
  local value = authority("input.spec")
  local frame = transaction.enter_invocation(value, {
    rule = "Top", origin = "discard", state = initial_state(),
  })
  local before = frame_state(value, frame)
  local token = transaction.checkpoint(value, frame, "discard")
  transaction.attempt(value, frame, token, {
    matched = true, payload = "value", state = staged_state(),
  })
  transaction.discard_token(value, frame, token)
  check_same_json(frame_state(value, frame), before, "discard restores snapshot")
  transaction.leave_invocation(value, frame)
end

do
  local value = authority("input.spec")
  local frame = transaction.enter_invocation(value, {
    rule = "Top", origin = "unwind", state = initial_state(),
  })
  local token = transaction.checkpoint(value, frame, "unwind")
  transaction.attempt(value, frame, token, {
    matched = true, payload = "value", state = staged_state(),
  })
  expect_diagnostic("recognition_terminal_required", function()
    return transaction.leave_invocation(value, frame)
  end, { rule = "Top", origin = "unwind" })
end

do
  local parsed, compiled = compile_source(authored_source)
  local compiled_json = linkedspec.compiled_spec_to_json(compiled)
  local top = compiled_json.rules_by_label.Top
  check(top ~= nil, "compiled Top exists")
  local action_objects = all_objects(top)
  local dedicated_nodes_ready = true
  for _, kind in ipairs({
    "recognition_checkpoint",
    "recognize_once",
    "recognition_commit",
    "recognition_rollback",
  }) do
    local count = #objects_with_kind(top, kind)
    check_equal(count, 1, "one " .. kind .. " node")
    if count ~= 1 then dedicated_nodes_ready = false end
  end
  if not dedicated_nodes_ready then
    io.stderr:write(
      "Lua recognition transaction invariant: missing dedicated ActionIR nodes\n"
    )
    os.exit(1)
  end
  local attempts = objects_with_kind(top, "recognize_once")
  check_equal(attempts[1].token, "tx", "attempt token slot")
  check_equal(attempts[1].rule, "Child", "attempt static child")
  local eager_calls = 0
  for _, object in ipairs(action_objects) do
    if object.kind == "call" and object.name == "Child" then eager_calls = eager_calls + 1 end
  end
  check_equal(eager_calls, 0, "transaction child is not eagerly called")

  local policy = authority("input.spec")
  for _, graph in ipairs(contract.fixtures.effect_graphs) do
    if graph.accepted then
      check_equal(transaction.classify_effects(policy, graph), nil, graph.id .. " effects")
    else
      expect_diagnostic(graph.diagnostic, function()
        return transaction.classify_effects(policy, graph)
      end, {})
    end
  end
  for _, fixture in ipairs(contract.fixtures.progress) do
    if fixture.accepted then
      check_equal(transaction.validate_progress(policy, fixture), nil, fixture.id .. " progress")
    else
      expect_diagnostic(fixture.diagnostic, function()
        return transaction.validate_progress(policy, fixture)
      end, {})
    end
  end

  local native = linkedspec.runtime_parse(linkedspec.runtime_engine(compiled), "xx").value
  check_equal(native, false, "native preserves false payload")
  local reconstructed_spec = linkedspec.spec_ast.from_json(
    "SpecFile",
    json.decode(json.encode(linkedspec.spec_ast.to_json(parsed)))
  )
  linkedspec.validate_spec(reconstructed_spec)
  local reconstructed = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(reconstructed_spec)),
    "xx"
  ).value
  check_equal(reconstructed, false, "reconstructed preserves false payload")
  local generated = linkedspec.execute_generated_parser_v2(
    compiled,
    linkedspec.build_generated_rule_plan(compiled),
    "xx",
    "recognition-transaction/lua.spec"
  )
  check_equal(generated, false, "generated plan preserves false payload")

  local _, ordinary = compile_source(ordinary_cursor_source)
  check_equal(
    linkedspec.runtime_parse(linkedspec.runtime_engine(ordinary), "a").value,
    "ok",
    "ordinary cursor stack remains separate"
  )

  local identity = "recognition-transaction/lua-emitted.spec"
  local emitted = linkedspec.emit_lua_source_v2(compiled, identity)
  local loader = loadstring or load
  local chunk, failure = loader(emitted, "@recognition_transaction_generated.lua")
  if chunk == nil then error(failure, 0) end
  local generated_module = chunk()
  check_equal(generated_module.execute("xx"), false, "emitted module preserves false payload")
  check_equal(generated_module.metadata().source_identity, identity, "emitted identity")
end

if #failures == 0 then
  io.stdout:write(
    "Lua admitted recognition-transaction contract: ", assertions,
    " assertions passed on ", linkedspec.runtime_implementation(), "\n"
  )
else
  io.stderr:write(
    "Lua admitted recognition-transaction contract: ", #failures,
    " of ", assertions, " assertions failed\n"
  )
  for _, message in ipairs(failures) do io.stderr:write("- ", message, "\n") end
  os.exit(1)
end
