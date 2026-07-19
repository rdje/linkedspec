local linkedspec = require("linkedspec")
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

local function check_contains(actual, expected, label)
  check(tostring(actual):find(expected, 1, true) ~= nil, (label or "text differs") ..
    ": expected to contain " .. expected .. ", got " .. tostring(actual))
end

local function check_same_json(actual, expected, label)
  check_equal(json.encode(actual), json.encode(expected), label)
end

local function read_file(path)
  local handle = assert(io.open(path, "rb"))
  local value = assert(handle:read("*a"))
  assert(handle:close())
  return value
end

local function write_file(path, value)
  local handle = assert(io.open(path, "wb"))
  assert(handle:write(value))
  assert(handle:close())
end

local function capture(operation)
  local ok, value = pcall(operation)
  return ok, value
end

local function shell_quote(value)
  return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function command_succeeded(command)
  local first, _, third = os.execute(command)
  if type(first) == "number" then return first == 0 end
  return first == true and (third == nil or third == 0)
end

local function with_temp_directory(operation)
  local handle = assert(io.popen("mktemp -d /private/tmp/linkedspec-lua-cursor-execution.XXXXXX", "r"))
  local root = assert(handle:read("*l"))
  assert(handle:close())
  local ok, value = pcall(operation, root)
  local cleaned = command_succeeded("rm -rf " .. shell_quote(root))
  if not cleaned then error("unable to clean cursor-execution test directory", 0) end
  if not ok then error(value, 0) end
end

local function compile_source(source)
  return linkedspec.compile_spec(linkedspec.parse_spec(source))
end

local function normalized_compiled(source)
  local parsed = linkedspec.parse_spec(source)
  local normalized = linkedspec.spec_ast.from_json(
    "SpecFile",
    json.decode(json.encode(linkedspec.spec_ast.to_json(parsed)))
  )
  return linkedspec.compile_spec(normalized)
end

local function runtime_value(compiled, input, engine_options, parse_options)
  return linkedspec.runtime_parse(
    linkedspec.runtime_engine(compiled, engine_options),
    input,
    parse_options
  ).value
end

local contract = json.decode(read_file("capability_conformance/rule_local_cursor_contract.json"))

local parent_child_cases = {
  {
    id = "and_to_or_blind",
    input = "prefix x",
    expected = json.array({ "hit" }),
    source = [[
Top::AND
 => Child
Child:
 /x/
 -> Child { return("hit") }
]],
  },
  {
    id = "or_to_and_blind",
    input = "prefix x",
    expected = json.null,
    source = [[
Top::|
 => Child
Child:AND
 /x/
 -> Child { return("hit") }
]],
  },
  {
    id = "and_to_or_action",
    input = "x junk x",
    expected = "hit",
    source = [[
Top::AND
 -> Child { return(call(Child)) }
Child:
 /x/
 -> Child { return("hit") }
]],
  },
  {
    id = "or_to_and_action",
    input = "prefix x junk x",
    expected = json.null,
    source = [[
Top::|
 -> Child { return(call(Child)) }
Child:AND
 /x/
 -> Child { return("hit") }
]],
  },
  {
    id = "and_to_or_call",
    input = "p junk x",
    expected = "hit",
    source = [[
Top::AND
 /p/
 -> Top { return(call(Child)) }
Child:
 /x/
 -> Child { return("hit") }
]],
  },
  {
    id = "or_to_and_call",
    input = "prefix p junk x",
    expected = json.null,
    source = [[
Top::|
 /p/
 -> Top { return(call(Child)) }
Child:AND
 /x/
 -> Child { return("hit") }
]],
  },
  {
    id = "and_to_or_recursion",
    input = "p junk xp junk z",
    expected = "done",
    source = [[
Top::AND
 /p/
 -> Top { return(call(Child)) }
Child:OR
 /x/ -> Child[0] { return(call(Top)) }
 /z/ -> Child[1] { return("done") }
]],
  },
  {
    id = "or_to_and_recursion",
    input = "junk p junk x z",
    expected = json.null,
    source = [[
Top::|
 /p/ -> Top[0] { return(call(Child)) }
 /z/ -> Top[1] { return("done") }
Child:AND
 /x/ -> Child { return(call(Top)) }
]],
  },
}

local structural_cases = {
  {
    id = "ordered_landmarks",
    input = "junk h junk b",
    expected = json.array({ "header", "body" }),
    source = [[
Top::AND
 => Header
 => Body
Header:
 /h/
 -> Header { return("header") }
Body:
 /b/
 -> Body { return("body") }
]],
  },
  {
    id = "anchored_choice",
    input = "prefix x",
    expected = json.null,
    source = [[
Top::|
 => X
 => Y
X:AND
 /x/
 -> X { return("x") }
Y:AND
 /y/
 -> Y { return("y") }
]],
  },
}

local function id_set(rows)
  local result = {}
  for _, row in ipairs(rows) do result[row.id] = true end
  return result
end

local function contract_id_set(rows)
  local result = {}
  for _, row in ipairs(rows) do result[row.id] = true end
  return result
end

local function sorted_keys(values)
  local result = {}
  for key in pairs(values) do result[#result + 1] = key end
  table.sort(result)
  return table.concat(result, ",")
end

check_equal(
  sorted_keys(id_set(parent_child_cases)),
  sorted_keys(contract_id_set(contract.parent_child_cases)),
  "parent-child case ids"
)
check_equal(
  sorted_keys(id_set(structural_cases)),
  sorted_keys(contract_id_set(contract.structural_replacements)),
  "structural case ids"
)

for _, case in ipairs(parent_child_cases) do
  check_same_json(
    runtime_value(compile_source(case.source), case.input),
    case.expected,
    case.id .. " live"
  )
  check_same_json(
    runtime_value(normalized_compiled(case.source), case.input),
    case.expected,
    case.id .. " normalized"
  )
end

for _, case in ipairs(structural_cases) do
  check_same_json(
    runtime_value(compile_source(case.source), case.input),
    case.expected,
    case.id .. " live"
  )
  check_same_json(
    runtime_value(normalized_compiled(case.source), case.input),
    case.expected,
    case.id .. " normalized"
  )
end

check_equal(#contract.family_cases, 36, "family row count")
for _, row in ipairs(contract.family_cases) do
  local prefix = row.header:sub(1, 5) == "Top::" and "" or
    "Root::\n I { return(\"unused\") }\n\n"
  local source = prefix .. row.header .. "\n /x/ -> Top { return(\"hit\") }\n"
  for _, route in ipairs({
    { name = "live", compiled = compile_source(source) },
    { name = "normalized", compiled = normalized_compiled(source) },
  }) do
    local ok, result = capture(function()
      return runtime_value(route.compiled, "prefix x", nil, { top_rule = "Top" })
    end)
    if row.cursor_policy == "seek" then
      check(ok and result == "hit", row.id .. " " .. route.name .. " seeks")
    else
      check(
        (ok and result == json.null) or
          (not ok and tostring(result):find("expected at least", 1, true) ~= nil),
        row.id .. " " .. route.name .. " consumes"
      )
    end
  end
end

with_temp_directory(function(root)
  local case = parent_child_cases[5]
  local path = root .. "/loaded.spec"
  write_file(path, case.source)
  local loaded = linkedspec.load_and_compile_spec(
    linkedspec.path_spec_request(path),
    linkedspec.spec_load_options({ cwd = root, search_roots = {} })
  )
  check_same_json(
    linkedspec.runtime_parse(loaded:create_engine(), case.input).value,
    case.expected,
    "loaded execution derives entered policies"
  )
end)

do
  local case = parent_child_cases[5]
  local emitter = linkedspec.trace_emitter(
    linkedspec.trace_config_enabled(linkedspec.TRACE_DEBUG),
    { stdout_writer = function() end }
  )
  local result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(compile_source(case.source)),
    case.input,
    { trace = emitter }
  )
  check_same_json(result.value, case.expected, "traced execution value")
  local entries = {}
  local decisions = {}
  for _, event in ipairs(linkedspec.trace_events(emitter)) do
    if event.topic == "lua_runtime:rule" and event.kind == linkedspec.TRACE_ENTER then
      entries[#entries + 1] = event.details
    elseif event.topic == "lua_runtime:regex_match" and event.kind == linkedspec.TRACE_DECISION then
      decisions[#decisions + 1] = event.details
    end
  end
  local entry_text = table.concat(entries, "\n")
  local decision_text = table.concat(decisions, "\n")
  check_contains(entry_text, "rule=Top ", "trace has parent entry")
  check_contains(entry_text, "family=and cursor_policy=consume", "trace has parent policy")
  check_contains(entry_text, "rule=Child ", "trace has child entry")
  check_contains(entry_text, "family=or_default cursor_policy=seek", "trace has child policy")
  check_contains(decision_text, "rule=Top cursor_policy=consume", "regex trace has parent policy")
  check_contains(decision_text, "rule=Child cursor_policy=seek", "regex trace has child policy")
end

do
  local and_compiled = compile_source([[
Top::AND
 /x/ -> Top { return("hit") }
]])
  check_same_json(
    runtime_value(and_compiled, "prefix x"),
    json.null,
    "default normal engine derives AND consume"
  )
  check_equal(
    runtime_value(and_compiled, "prefix x", { parse_mode = "seek" }),
    "hit",
    "explicit outer seek compatibility remains"
  )

  local or_compiled = compile_source([[
Top::|
 /x/ -> Top { return("hit") }
]])
  check_same_json(
    runtime_value(or_compiled, "prefix x", { parse_mode = "consume" }),
    json.null,
    "explicit outer consume compatibility remains"
  )

  check_equal(
    linkedspec.execute_generated_parser_v1(
      and_compiled,
      linkedspec.build_generated_rule_plan(and_compiled),
      "prefix x",
      "cursor-v1-and.spec"
    ),
    "hit",
    "generated v1 retains seek compatibility"
  )

  local pipe_compiled = compile_source([[
Top::|
 => X
 => Y
X:
 I { return("x") }
 /x/
Y:
 I { return("y") }
 /y/
]])
  check_equal(runtime_value(pipe_compiled, "xy"), "x", "normal compact pipe is choice")
  local pipe_plan = linkedspec.build_generated_rule_plan(pipe_compiled)
  check_equal(pipe_plan[1].family, "and_bcode", "generated v1 compact pipe retains AND family")
  check_same_json(
    linkedspec.execute_generated_parser_v1(
      pipe_compiled,
      pipe_plan,
      "xy",
      "cursor-v1-pipe.spec"
    ),
    json.array({ "x", "y" }),
    "generated v1 compact pipe retains sequence interpretation"
  )
end

if #failures == 0 then
  io.stdout:write("rule-local cursor execution: ", assertions, " assertions passed\n")
else
  io.stderr:write("rule-local cursor execution: ", #failures, " of ", assertions, " assertions failed\n")
  for _, message in ipairs(failures) do io.stderr:write("- ", message, "\n") end
  os.exit(1)
end
