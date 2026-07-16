local total = 0
local failed = 0

local function fail(message)
  error(message, 2)
end

local function assert_equal(actual, expected, label)
  if actual ~= expected then
    fail((label or "values differ") .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
  end
end

local function assert_contains(actual, expected, label)
  if not tostring(actual):find(expected, 1, true) then
    fail((label or "text differs") .. ": expected to contain " .. expected .. ", got " .. tostring(actual))
  end
end

local function assert_error_contains(operation, expected, label)
  local ok, message = pcall(operation)
  if ok then
    fail((label or "operation") .. ": expected an error")
  end
  assert_contains(message, expected, label)
end

local function test(name, operation)
  total = total + 1
  local ok, message = pcall(operation)
  if ok then
    io.stdout:write("ok ", total, " - ", name, "\n")
  else
    failed = failed + 1
    io.stdout:write("not ok ", total, " - ", name, "\n")
    io.stdout:write("# ", tostring(message), "\n")
  end
end

local linkedspec = require("linkedspec")
local corpus_runner = require("linkedspec.corpus_runner")
local json = linkedspec.json
local ast = linkedspec.spec_ast
local scalar_numeric = require("linkedspec.scalar_numeric")

local function shell_quote(value)
  return "'" .. value:gsub("'", "'\\''") .. "'"
end

local function command_succeeded(command)
  local first, _, third = os.execute(command)
  if type(first) == "number" then
    return first == 0
  end
  return first == true and (third == nil or third == 0)
end

local function make_temp_directory()
  local handle = assert(io.popen("mktemp -d /private/tmp/linkedspec-lua-corpus.XXXXXX", "r"))
  local root = assert(handle:read("*l"))
  assert(handle:close())
  return root
end

local function write_file(path, value)
  local handle = assert(io.open(path, "wb"))
  assert(handle:write(value))
  assert(handle:close())
end

local function read_file(path)
  local handle = assert(io.open(path, "rb"))
  local value = assert(handle:read("*a"))
  assert(handle:close())
  return value
end

local function sorted_keys(value)
  local keys = {}
  for key in pairs(value) do keys[#keys + 1] = key end
  table.sort(keys)
  return keys
end

local function sorted_values(value)
  local values = {}
  for index, item in ipairs(value) do values[index] = item end
  table.sort(values)
  return values
end

local function make_directory(path)
  if not command_succeeded("mkdir -p " .. shell_quote(path)) then
    fail("unable to create test directory: " .. path)
  end
end

local function with_temp_directory(operation)
  local root = make_temp_directory()
  local ok, message = pcall(operation, root)
  local cleaned = command_succeeded("rm -rf " .. shell_quote(root))
  if not cleaned then
    fail("unable to remove test directory: " .. root)
  end
  if not ok then
    error(message, 0)
  end
end

local function write_manifest(root, cases, options)
  options = options or {}
  local case_values = {}
  for index, name in ipairs(cases) do
    case_values[index] = name
  end
  local manifest = json.harray({
    format = options.format or 1,
    case_count = options.case_count or #cases,
    cases = json.array(case_values),
  })
  write_file(root .. "/manifest.json", json.encode(manifest))
end

local function write_fixture(root, name, options)
  options = options or {}
  local fixture = root .. "/" .. name
  make_directory(fixture)
  write_file(fixture .. "/input.spec", options.spec_source or "Top::\n /x/\n")
  write_file(fixture .. "/input.txt", options.input_text or "x")
  if options.expected_source ~= false then
    write_file(fixture .. "/expected.json", options.expected_source or '"ok"')
  end
end

local function run_corpus_runner(args)
  local output = assert(io.tmpfile())
  local error_output = assert(io.tmpfile())
  local status = corpus_runner.run(args, output, error_output)
  output:seek("set", 0)
  error_output:seek("set", 0)
  local output_text = assert(output:read("*a"))
  local error_text = assert(error_output:read("*a"))
  output:close()
  error_output:close()
  return status, output_text, error_text
end

local function native_resolution_contract()
  return json.decode(read_file("capability_conformance/native_spec_resolution_contract.json"))
end

local function fixture_path(root, portable_path)
  return root .. "/" .. portable_path
end

local function write_resolution_entry(root, entry)
  local path = fixture_path(root, entry.path)
  if entry.kind == "file" then
    make_directory(assert(path:match("^(.*)/[^/]+$")))
    write_file(path, "fixture")
  elseif entry.kind == "directory" or entry.kind == "non_regular" then
    make_directory(path)
  else
    fail("unsupported resolution fixture kind: " .. tostring(entry.kind))
  end
end

local function bytes_from_hex(value)
  if #value % 2 ~= 0 then fail("hex byte fixture must have even length") end
  local chunks = {}
  for index = 1, #value, 2 do
    chunks[#chunks + 1] = string.char(assert(tonumber(value:sub(index, index + 1), 16)))
  end
  return table.concat(chunks)
end

test("native module identity is exact", function()
  assert_equal(linkedspec.backend_name(), "lua", "backend name")
  assert_equal(linkedspec.cli_entrypoint(), "lua/bin/linkedspec-lua", "CLI entrypoint")
  assert_equal(
    linkedspec.corpus_runner_entrypoint(),
    "lua/bin/corpus_runner.lua",
    "corpus runner entrypoint"
  )
end)

test("backend status is a fresh structured value", function()
  local first = linkedspec.backend_status()
  local second = linkedspec.backend_status()
  assert_equal(first.backend, "lua", "status backend")
  assert_equal(first.package, "linkedspec", "status package")
  assert_equal(first.version, "0.1.0", "status version")
  assert_equal(
    first.parity,
    "runtime-corpus-primary-cli",
    "status parity"
  )
  assert_equal(first.runtime, linkedspec.runtime_implementation(), "status runtime")
  first.backend = "mutated"
  assert_equal(second.backend, "lua", "status copy isolation")
end)

test("trace controls expose ordered levels immutable config and structured primitives", function()
  assert_equal(linkedspec.parse_trace_level("quiet"), linkedspec.TRACE_NONE, "quiet alias")
  assert_equal(linkedspec.parse_trace_level("med"), linkedspec.TRACE_MEDIUM, "medium alias")
  assert_equal(linkedspec.parse_trace_level("verbose"), linkedspec.TRACE_DEBUG, "debug alias")
  assert_equal(linkedspec.parse_trace_level(" 250 ").value, 250, "numeric threshold")
  assert_equal(linkedspec.trace_level_name(linkedspec.parse_trace_level(250)), "high", "numeric bucket")
  assert_equal(linkedspec.trace_allows(linkedspec.TRACE_HIGH, linkedspec.TRACE_MEDIUM), true, "ordered allow")
  assert_equal(linkedspec.trace_allows(linkedspec.TRACE_MEDIUM, linkedspec.TRACE_HIGH), false, "ordered reject")
  assert_equal(linkedspec.trace_allows(linkedspec.TRACE_NONE, linkedspec.TRACE_NONE), false, "none is quiet")
  assert_error_contains(function()
    linkedspec.parse_trace_level("loud")
  end, "unsupported trace level 'loud'", "invalid trace level")

  local disabled = linkedspec.trace_config_disabled()
  local enabled = linkedspec.with_trace_emoji(
    linkedspec.with_trace_level(disabled, linkedspec.TRACE_FULL)
  )
  assert_equal(disabled.level, linkedspec.TRACE_NONE, "config update preserves source")
  assert_equal(disabled.emoji, false, "source emoji remains disabled")
  assert_equal(enabled.level, linkedspec.TRACE_FULL, "updated level")
  assert_equal(enabled.emoji, true, "updated emoji")
  assert_equal(linkedspec.is_trace_config(enabled), true, "typed config")
  assert_error_contains(function()
    enabled.level = linkedspec.TRACE_LOW
  end, "trace values are immutable", "immutable trace config")

  local environment = linkedspec.trace_config_from_environment({
    LINKEDSPEC_DUMP_VERBOSITY = "debug",
    LINKEDSPEC_TRACE_FILE = "  trace.log  ",
    LINKEDSPEC_TRACE_MIRROR_STDOUT = "yes",
    LINKEDSPEC_TRACE_RESET_FILE = "1",
    LINKEDSPEC_TRACE_EMOJI = "true",
  })
  assert_equal(environment.level, linkedspec.TRACE_DEBUG, "environment fallback level")
  assert_equal(environment.trace_file, "trace.log", "environment trace path")
  assert_equal(environment.sink_mode, linkedspec.TRACE_MIRROR, "environment mirror")
  assert_equal(environment.reset_file, true, "environment reset")
  assert_equal(environment.emoji, true, "environment emoji")

  local stdout = {}
  local emitter = linkedspec.trace_emitter(
    linkedspec.trace_config_enabled(linkedspec.TRACE_DEBUG),
    { stdout_writer = function(payload) stdout[#stdout + 1] = payload end }
  )
  local scope = linkedspec.enter_trace_scope(emitter, "compile", "start", linkedspec.TRACE_HIGH)
  assert_equal(
    linkedspec.trace_decision(emitter, "use_cache", false, "miss", linkedspec.TRACE_DEBUG),
    false,
    "decision result"
  )
  linkedspec.emit_trace_event(emitter, linkedspec.TRACE_MARK, "checkpoint", "ready", linkedspec.TRACE_MEDIUM)
  linkedspec.log_trace_output(emitter, linkedspec.TRACE_LOW, "runtime message", "ctx=run")
  linkedspec.log_trace_dump(emitter, linkedspec.TRACE_FULL, "compiled descriptor dump")
  linkedspec.exit_trace_scope(emitter, scope, "done")

  local rendered = table.concat(stdout)
  assert_contains(rendered, "[HIGH][enter] -> compile start", "enter rendering")
  assert_contains(rendered, "[DEBUG][decision]   use_cache taken=0 reason=miss", "decision rendering")
  assert_contains(rendered, "[MEDIUM][mark]   checkpoint ready", "mark rendering")
  assert_contains(rendered, "[LOW][log]   log_output runtime message context=ctx=run", "log rendering")
  assert_contains(rendered, "[FULL][dump]   log_dump compiled descriptor dump", "dump rendering")
  assert_contains(rendered, "[HIGH][exit] <- compile done", "exit rendering")
  local events = linkedspec.trace_events(emitter)
  assert_equal(#events, 6, "structured event count")
  assert_equal(linkedspec.trace_event_to_json(events[1]).kind, "enter", "event JSON kind")
  assert_equal(linkedspec.trace_event_to_json(events[2]).level_value, 500, "event JSON level")
  local lines = linkedspec.trace_lines(emitter)
  lines[1] = "caller mutation"
  assert_equal(linkedspec.trace_lines(emitter)[1] ~= "caller mutation", true, "line snapshot isolation")
end)

test("trace sinks and direct runtime entrypoints stay caller-owned and result-neutral", function()
  with_temp_directory(function(root)
    local route_path = root .. "/route.log"
    write_file(route_path, "stale\n")
    local routed_stdout = {}
    local route_config = linkedspec.with_trace_reset_file(linkedspec.with_trace_file(
      linkedspec.trace_config_enabled(linkedspec.TRACE_DEBUG),
      route_path
    ))
    local routed_emitter = linkedspec.trace_emitter(route_config, {
      stdout_writer = function(payload) routed_stdout[#routed_stdout + 1] = payload end,
    })
    linkedspec.emit_trace_event(routed_emitter, linkedspec.TRACE_MARK, "route", "fresh", linkedspec.TRACE_LOW)
    assert_equal(table.concat(routed_stdout), "", "route suppresses stdout")
    assert_equal(read_file(route_path), "[LOW][mark] route fresh\n", "route resets and writes")

    local append_config = linkedspec.with_trace_reset_file(route_config, false)
    local append_emitter = linkedspec.trace_emitter(append_config)
    linkedspec.emit_trace_event(append_emitter, linkedspec.TRACE_MARK, "route", "append", linkedspec.TRACE_LOW)
    assert_equal(
      read_file(route_path),
      "[LOW][mark] route fresh\n[LOW][mark] route append\n",
      "route appends when reset is disabled"
    )

    local mirror_path = root .. "/mirror.log"
    local mirror_stdout = {}
    local mirror_config = linkedspec.with_trace_emoji(linkedspec.with_trace_reset_file(
      linkedspec.with_trace_sink_mode(
        linkedspec.with_trace_file(linkedspec.trace_config_enabled(linkedspec.TRACE_HIGH), mirror_path),
        linkedspec.TRACE_MIRROR
      )
    ))
    local mirror_emitter = linkedspec.trace_emitter(mirror_config, {
      stdout_writer = function(payload) mirror_stdout[#mirror_stdout + 1] = payload end,
    })
    linkedspec.emit_trace_event(mirror_emitter, linkedspec.TRACE_MARK, "mirror", "same", linkedspec.TRACE_HIGH)
    assert_equal(table.concat(mirror_stdout), read_file(mirror_path), "mirror bytes")
    assert_contains(read_file(mirror_path), "🧭 mirror same", "emoji rendering")

    local source = "Top::\n /x/\n"
    local engine = linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(source)))
    local untraced = linkedspec.runtime_parse(engine, "x")
    local quiet_stdout = {}
    local quiet_emitter = linkedspec.trace_emitter(linkedspec.trace_config_disabled(), {
      stdout_writer = function(payload) quiet_stdout[#quiet_stdout + 1] = payload end,
    })
    local quiet = linkedspec.runtime_parse(engine, "x", { trace = quiet_emitter })
    assert_equal(
      json.encode(linkedspec.interpreter.to_json(quiet)),
      json.encode(linkedspec.interpreter.to_json(untraced)),
      "quiet trace result neutrality"
    )
    assert_equal(table.concat(quiet_stdout), "", "quiet trace stdout")
    assert_equal(#linkedspec.trace_events(quiet_emitter), 0, "quiet trace events")

    local direct_stdout = {}
    local direct_emitter = linkedspec.trace_emitter(linkedspec.trace_config_enabled(linkedspec.TRACE_HIGH), {
      stdout_writer = function(payload) direct_stdout[#direct_stdout + 1] = payload end,
    })
    local direct = linkedspec.runtime_execute(engine, "x", { trace = direct_emitter })
    assert_equal(
      json.encode(linkedspec.interpreter.to_json(direct)),
      json.encode(linkedspec.interpreter.to_json(untraced)),
      "direct trace result neutrality"
    )
    assert_equal(#linkedspec.trace_events(direct_emitter), 4, "parse and runtime rule scopes")
    assert_contains(table.concat(direct_stdout), "lua_runtime:parse top_rule=Top", "direct parse enter")
    assert_contains(table.concat(direct_stdout), "matched=true cursor=1", "direct parse exit")

    local failure_stdout = {}
    local failure_emitter = linkedspec.trace_emitter(linkedspec.trace_config_enabled(linkedspec.TRACE_HIGH), {
      stdout_writer = function(payload) failure_stdout[#failure_stdout + 1] = payload end,
    })
    local failure_ok = pcall(linkedspec.runtime_parse, engine, "x", {
      top_rule = "Missing",
      trace = failure_emitter,
    })
    assert_equal(failure_ok, false, "traced failure remains a failure")
    assert_equal(#linkedspec.trace_events(failure_emitter), 2, "failure scope balance")
    assert_equal(linkedspec.trace_events(failure_emitter)[2].kind, linkedspec.TRACE_EXIT, "failure exit event")
    assert_contains(table.concat(failure_stdout), "error=rule 'Missing' is not compiled", "failure exit detail")

    local runtime_path = root .. "/runtime.log"
    local runtime_options = { top_rule = "Top" }
    local traced = linkedspec.runtime_parse_with_trace(
      engine,
      "x",
      linkedspec.with_trace_reset_file(linkedspec.with_trace_file(
        linkedspec.trace_config_enabled(linkedspec.TRACE_HIGH),
        runtime_path
      )),
      runtime_options
    )
    assert_equal(runtime_options.trace, nil, "wrapper does not mutate caller options")
    assert_equal(
      json.encode(linkedspec.interpreter.to_json(traced)),
      json.encode(linkedspec.interpreter.to_json(untraced)),
      "routed wrapper result neutrality"
    )
    assert_contains(read_file(runtime_path), "lua_runtime:parse", "routed runtime scope")
    assert_contains(read_file(runtime_path), "matched=true cursor=1", "routed runtime exit")
  end)

  assert_error_contains(function()
    local engine = linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec("Top::\n /x/\n")))
    linkedspec.runtime_parse(engine, "x", { trace = {} })
  end, "trace must be a LinkedSpecTraceEmitter", "invalid trace emitter")
end)

test("primary CLI help and strict argument schema are exact", function()
  local expected_help = read_file("cli_conformance/cases/help/stdout.txt"):gsub(
    "{{COMMAND}}",
    function() return "lua/bin/linkedspec-lua" end
  )
  local help = linkedspec.run_primary_cli({ "--help" })
  assert_equal(help.exit_code, 0, "help status")
  assert_equal(help.stdout, expected_help, "help stdout")
  assert_equal(help.stderr, "", "help stderr")

  local usage = linkedspec.run_primary_cli({ "status", "--UNKNOWN", "extra" })
  local message = "unexpected positional argument 'status'; unknown option '--UNKNOWN'; " ..
    "unexpected positional argument 'extra'"
  assert_equal(usage.exit_code, 2, "usage status")
  assert_equal(usage.stdout, "", "usage stdout")
  assert_equal(usage.stderr, "linkedspec: " .. message .. "\n\n" .. expected_help, "usage stderr")
  assert_equal(type(linkedspec.parse_spec), "function", "native parser API")
end)

test("primary CLI delegates named file and inline execution to native APIs", function()
  with_temp_directory(function(root)
    local source = "Top::\n /x/ -> Done { return(hash(\"z\", 0, \"a\", " ..
      "hash(\"d\", 4, \"b\", 2))) }\n\nDone::\n /x/\n"
    write_file(root .. "/Demo.spec", source)
    write_file(root .. "/input.txt", "x\n")
    local context = { cwd = root, repo_root = root }

    local named = linkedspec.run_primary_cli({ "--spec", "Demo", "--input", "x" }, context)
    assert_equal(named.exit_code, 0, "named status")
    assert_equal(named.stdout, '{"a":{"b":2,"d":4},"z":0}\n', "named canonical JSON")
    assert_equal(named.stderr, "", "named stderr")

    local file = linkedspec.run_primary_cli({
      "--spec-file",
      "Demo.spec",
      "--input-file",
      "input.txt",
    }, context)
    assert_equal(file.exit_code, 0, "file status")
    assert_equal(file.stdout, '{"a":{"b":2,"d":4},"z":0}\n', "file canonical JSON")

    local inline = linkedspec.run_primary_cli({
      "--inline-spec",
      "Top::\n /x/ -> Done { return(\"alternate\") }\n\nAlternate:\n /b/ -> Done { " ..
        "return(\"alternate\") }\n\nDone::\n /[xb]/\n",
      "--input",
      "b",
      "--top-rule",
      "Alternate",
      "--parse-mode",
      "consume",
    }, context)
    assert_equal(inline.exit_code, 0, "inline status")
    assert_equal(inline.stdout, '"alternate"\n', "inline result")
  end)
end)

test("primary CLI preserves strict UTF-8 phase order and canonical trace routing", function()
  with_temp_directory(function(root)
    local context = { cwd = root, repo_root = root }
    local source = "Top::\n /x/ -> Done { return(input_text()) }\n\nDone::\n /x/\n"
    write_file(root .. "/invalid.txt", "x" .. string.char(0xC3, 0x28, 0xFF) .. "\n")
    local invalid_input = linkedspec.run_primary_cli({
      "--inline-spec",
      source,
      "--input-file",
      "invalid.txt",
    }, context)
    assert_equal(invalid_input.exit_code, 1, "invalid input status")
    assert_equal(invalid_input.stdout, "", "invalid input stdout")
    assert_equal(invalid_input.stderr, "linkedspec: input load failed\n", "invalid input stderr")

    local compile_first = linkedspec.run_primary_cli({
      "--inline-spec",
      "not a spec",
      "--input-file",
      "missing.txt",
    }, context)
    assert_equal(compile_first.exit_code, 1, "compile-first status")
    assert_equal(compile_first.stderr, "linkedspec: parser compilation failed\n", "compile-first stderr")

    write_file(root .. "/trace.log", "stale\n")
    local traced = linkedspec.run_primary_cli({
      "--inline-spec",
      source,
      "--input",
      "xé",
      "--trace",
      "full",
      "--trace-file",
      "trace.log",
      "--trace-mode",
      "route",
      "--trace-reset",
    }, context)
    assert_equal(traced.exit_code, 0, "trace status")
    assert_equal(traced.stdout, '"xé"\n', "trace JSON remains clean")
    assert_equal(traced.stderr, "", "trace stderr")
    local trace_text = read_file(root .. "/trace.log")
    assert_contains(trace_text, "[linkedspec][high] arguments source_bytes=57 input_bytes=3\n", "trace argument bytes")
    assert_contains(trace_text, "[linkedspec][full] result json_bytes=5\n", "trace result bytes")
  end)
end)

test("strict JSON preserves null array and harray identity", function()
  local value = json.decode('{"z":0,"a":[true,null,{"é":"😀"}]}')
  assert_equal(json.kind(value), "harray", "root JSON kind")
  assert_equal(json.kind(value.a), "array", "nested JSON kind")
  assert_equal(value.a[2], json.null, "JSON null sentinel")
  assert_equal(json.kind(value.a[3]), "harray", "nested harray kind")
  assert_equal(value.a[3]["é"], "😀", "Unicode value")
  assert_equal(json.encode(value), '{"a":[true,null,{"é":"😀"}],"z":0}', "canonical JSON")
end)

test("JSON Unicode escapes and strict UTF-8 are exact", function()
  assert_equal(json.decode('"\\uD83D\\uDE00"'), "😀", "surrogate pair")
  assert_error_contains(function()
    json.decode('"' .. string.char(0xC3) .. '"')
  end, "not valid UTF-8", "invalid UTF-8 JSON")
  assert_error_contains(function()
    json.decode('{"a":1,"a":2}')
  end, "duplicate object key", "duplicate key")
  assert_error_contains(function()
    json.decode('"\\uD83D"')
  end, "high surrogate", "unpaired surrogate")
  assert_error_contains(function()
    json.encode({ "ambiguous" })
  end, "plain Lua tables are ambiguous", "plain table encoding")
end)

test("native spec requests consume every neutral name-validation case", function()
  local contract = native_resolution_contract()
  assert_equal(linkedspec.spec_loader.node_type(linkedspec.named_spec_request("Demo")), "SpecRequest", "request type")
  for _, case in ipairs(contract.name_validation_cases) do
    local request = linkedspec.named_spec_request(case.value)
    local ok, result = pcall(linkedspec.validate_spec_request, request)
    if case.expect.status == "ok" then
      assert_equal(ok, true, case.id .. " accepted")
      assert_equal(result, true, case.id .. " result")
    else
      assert_equal(ok, false, case.id .. " rejected")
      assert_equal(linkedspec.is_spec_pipeline_error(result), true, case.id .. " typed error")
      assert_equal(result.stage, case.expect.stage, case.id .. " stage")
      assert_equal(result.code, case.expect.code, case.id .. " code")
      assert_equal(result.request_kind, "name", case.id .. " request kind")
      assert_equal(result.requested, case.value, case.id .. " requested identity")
    end
  end

  for _, value in ipairs({ "\194\160Demo", "Demo\226\128\128", "De\194\133mo" }) do
    local ok, result = pcall(linkedspec.validate_spec_request, linkedspec.named_spec_request(value))
    assert_equal(ok, false, "supplemental Unicode boundary rejected")
    assert_equal(linkedspec.is_spec_pipeline_error(result), true, "supplemental Unicode typed error")
    assert_equal(result.stage, "validate_spec_name", "supplemental Unicode stage")
    assert_equal(result.code, "invalid_spec_name", "supplemental Unicode code")
  end

  for _, value in ipairs({ "", "source\0.spec", "\255" }) do
    local ok, result = pcall(linkedspec.validate_spec_request, linkedspec.path_spec_request(value))
    assert_equal(ok, false, "supplemental path boundary rejected")
    assert_equal(linkedspec.is_spec_pipeline_error(result), true, "supplemental path typed error")
    assert_equal(result.stage, "validate_spec_path", "supplemental path stage")
    assert_equal(result.code, "invalid_spec_path", "supplemental path code")
  end
end)

test("native spec resolution consumes every neutral path and file-kind case", function()
  local contract = native_resolution_contract()
  for _, case in ipairs(contract.resolution_cases) do
    with_temp_directory(function(root)
      for _, entry in ipairs(case.entries) do write_resolution_entry(root, entry) end
      local cwd = fixture_path(root, case.cwd)
      make_directory(cwd)
      local roots = {}
      for index, search_root in ipairs(case.search_roots) do
        roots[index] = fixture_path(root, search_root)
      end
      local options = linkedspec.spec_load_options({ cwd = cwd, search_roots = roots })
      assert_equal(linkedspec.spec_loader.node_type(options), "SpecLoadOptions", case.id .. " options type")
      local request = case.request.kind == "name" and linkedspec.named_spec_request(case.request.value) or
        linkedspec.path_spec_request(case.request.value)
      local ok, result = pcall(linkedspec.resolve_spec, request, options)
      if case.expect.status == "ok" then
        assert_equal(ok, true, case.id .. " resolved")
        assert_equal(linkedspec.spec_loader.node_type(result), "ResolvedSpec", case.id .. " resolved type")
        assert_equal(result.path, fixture_path(root, case.expect.path), case.id .. " path")
        assert_equal(result.origin, case.expect.origin, case.id .. " origin")
        assert_equal(result.request.kind, case.request.kind, case.id .. " retained kind")
        assert_equal(result.request.requested, case.request.value, case.id .. " retained request")
      else
        assert_equal(ok, false, case.id .. " rejected")
        assert_equal(linkedspec.is_spec_pipeline_error(result), true, case.id .. " typed error")
        assert_equal(result.stage, case.expect.stage, case.id .. " stage")
        assert_equal(result.code, case.expect.code, case.id .. " code")
        local expected_path = case.expect.resolved_path and fixture_path(root, case.expect.resolved_path) or nil
        assert_equal(result.resolved_path, expected_path, case.id .. " resolved error path")
      end
    end)
  end
end)

test("native spec loading consumes every neutral strict UTF-8 case", function()
  local contract = native_resolution_contract()
  for _, case in ipairs(contract.text_cases) do
    with_temp_directory(function(root)
      write_file(root .. "/source.spec", bytes_from_hex(case.bytes_hex))
      local request = linkedspec.path_spec_request("source.spec")
      local options = linkedspec.spec_load_options({ cwd = root, search_roots = {} })
      local ok, result = pcall(linkedspec.load_spec, request, options)
      if case.expect.status == "ok" then
        assert_equal(ok, true, case.id .. " loaded")
        assert_equal(linkedspec.spec_loader.node_type(result), "LoadedSpec", case.id .. " loaded type")
        assert_equal(result.source_text, case.expect.text, case.id .. " exact text")
        assert_equal(result.resolved.path, root .. "/source.spec", case.id .. " loaded path")
      else
        assert_equal(ok, false, case.id .. " rejected")
        assert_equal(linkedspec.is_spec_pipeline_error(result), true, case.id .. " typed error")
        assert_equal(result.stage, case.expect.stage, case.id .. " stage")
        assert_equal(result.code, case.expect.code, case.id .. " code")
        assert_equal(result.resolved_path, root .. "/source.spec", case.id .. " decoded path")
      end
    end)
  end

  with_temp_directory(function(root)
    local missing_ok, missing = pcall(
      linkedspec.resolve_spec,
      linkedspec.named_spec_request("Missing"),
      linkedspec.spec_load_options({ cwd = root, search_roots = {} })
    )
    assert_equal(missing_ok, false, "missing name fails")
    assert_equal(
      json.encode(linkedspec.spec_pipeline_error_to_json(missing)),
      '{"code":"spec_path_not_found","request_kind":"name","requested":"Missing",' ..
        '"stage":"resolve_spec_path","summary":"Spec path not found","type":"spec_pipeline_error"}',
      "missing name JSON"
    )
  end)
end)

test("native spec pipeline composes functions and source-identified engines", function()
  with_temp_directory(function(root)
    local specs = root .. "/specs"
    make_directory(specs)
    local source = table.concat({
      'fn label() {return("hit")}',
      "",
      "Top::",
      " /x/",
      " E { return(label()) }",
      "",
    }, "\n")
    local path = specs .. "/Demo.spec"
    write_file(path, source)

    local request = linkedspec.named_spec_request("Demo")
    local options = linkedspec.spec_load_options({
      cwd = root .. "/cwd",
      search_roots = { specs },
    })
    local loaded = linkedspec.load_and_compile_spec(request, options)
    assert_equal(linkedspec.spec_loader.node_type(loaded), "LoadedCompiledSpec", "composed result type")
    assert_equal(loaded.loaded.resolved.request.kind, "name", "retained request kind")
    assert_equal(loaded.loaded.resolved.request.requested, "Demo", "retained requested value")
    assert_equal(loaded.loaded.resolved.path, path, "retained resolved path")
    assert_equal(loaded.loaded.source_text, source, "retained exact source")
    assert_equal(linkedspec.compiled_spec.node_type(loaded.compiled), "CompiledSpec", "compiled state type")
    assert_equal(#loaded.compiled:functions(), 1, "compiled top-level function")

    local engine_options = { parse_mode = "seek", max_iterations = 250 }
    local engine = loaded:create_engine(engine_options)
    assert_equal(engine_options.spec_name, nil, "caller options gain no name")
    assert_equal(engine_options.spec_path, nil, "caller options gain no path")
    assert_equal(engine.spec_name, "Demo", "named engine identity")
    assert_equal(engine.spec_path, path, "named engine path")
    assert_equal(linkedspec.runtime_parse(engine, "x").value, "hit", "loaded function execution")

    local runtime_ok, runtime_error = pcall(
      linkedspec.runtime_parse,
      engine,
      "x",
      { top_rule = "Missing" }
    )
    assert_equal(runtime_ok, false, "identified runtime failure")
    assert_equal(runtime_error.diagnostic.spec_name, "Demo", "runtime diagnostic name")
    assert_equal(runtime_error.diagnostic.spec_path, path, "runtime diagnostic path")

    local path_loaded = linkedspec.load_and_compile_spec(
      linkedspec.path_spec_request(path),
      linkedspec.spec_load_options({ cwd = root, search_roots = { root .. "/unused" } })
    )
    local path_engine = linkedspec.create_loaded_spec_engine(path_loaded)
    assert_equal(path_engine.spec_name, nil, "exact-path engine has no logical name")
    assert_equal(path_engine.spec_path, path, "exact-path engine identity")
    assert_equal(linkedspec.runtime_parse(path_engine, "x").value, "hit", "exact-path execution")

    local inline = linkedspec.parse_spec_with_staged_user_function_definitions(source)
    local inline_engine = linkedspec.runtime_engine(linkedspec.compile_spec(inline))
    assert_equal(linkedspec.runtime_parse(inline_engine, "x").value, "hit", "inline path unchanged")
  end)
end)

test("native spec pipeline maps parse validation compile and missing-name failures", function()
  with_temp_directory(function(root)
    write_file(root .. "/parse.spec", "not a spec\n")
    write_file(root .. "/validation.spec", "Only:\n /x/\n")
    write_file(
      root .. "/compile.spec",
      "Top::\n /x/\n E { return(array" .. "(items)) }\n" -- selector-rejection fixture
    )
    local options = linkedspec.spec_load_options({ cwd = root, search_roots = {} })
    local cases = {
      { path = "parse.spec", stage = "parse_spec", code = "spec_parse_failed" },
      { path = "validation.spec", stage = "validate_spec", code = "spec_validation_failed" },
      { path = "compile.spec", stage = "compile_spec", code = "spec_compile_failed" },
    }
    for _, case in ipairs(cases) do
      local ok, result = pcall(
        linkedspec.load_and_compile_spec,
        linkedspec.path_spec_request(case.path),
        options
      )
      assert_equal(ok, false, case.stage .. " rejected")
      assert_equal(linkedspec.is_spec_pipeline_error(result), true, case.stage .. " typed error")
      assert_equal(result.stage, case.stage, case.stage .. " stage")
      assert_equal(result.code, case.code, case.stage .. " code")
      assert_equal(result.request_kind, "path", case.stage .. " request kind")
      assert_equal(result.requested, case.path, case.stage .. " requested value")
      assert_equal(result.resolved_path, root .. "/" .. case.path, case.stage .. " resolved path")
    end

    local missing_ok, missing = pcall(
      linkedspec.load_and_compile_spec,
      linkedspec.named_spec_request("Missing"),
      options
    )
    assert_equal(missing_ok, false, "missing name rejected before parsing")
    assert_equal(
      json.encode(linkedspec.spec_pipeline_error_to_json(missing)),
      '{"code":"spec_path_not_found","request_kind":"name","requested":"Missing",' ..
        '"stage":"resolve_spec_path","summary":"Spec path not found","type":"spec_pipeline_error"}',
      "full-pipeline missing name JSON"
    )
  end)
end)

test("one caller-owned emitter crosses the complete native parser pipeline", function()
  with_temp_directory(function(root)
    local source = table.concat({
      'fn label() {return("hit")}',
      "",
      "Top::",
      " /x/",
      " E { return(label()) }",
      "",
    }, "\n")
    local path = root .. "/pipeline.spec"
    local route_path = root .. "/pipeline.trace"
    write_file(path, source)

    local request = linkedspec.path_spec_request(path)
    local baseline_loaded = linkedspec.load_and_compile_spec(
      request,
      linkedspec.spec_load_options({ cwd = root, search_roots = {} })
    )
    local baseline_result = linkedspec.runtime_parse(baseline_loaded:create_engine(), "x")

    local emitter = linkedspec.trace_emitter(
      linkedspec.with_trace_reset_file(linkedspec.with_trace_file(
        linkedspec.trace_config_enabled(linkedspec.TRACE_DEBUG),
        route_path
      ))
    )
    local original_factory = linkedspec.trace.trace_emitter
    local hidden_factory_calls = 0
    linkedspec.trace.trace_emitter = function(...)
      hidden_factory_calls = hidden_factory_calls + 1
      return original_factory(...)
    end
    local traced_ok, traced_or_error = pcall(function()
      local options = linkedspec.spec_load_options({
        cwd = root,
        search_roots = {},
        trace = emitter,
      })
      local loaded = linkedspec.load_and_compile_spec(request, options)
      local engine_options = { trace = emitter }
      local engine = loaded:create_engine(engine_options)
      assert_equal(engine_options.trace, emitter, "engine options retain caller emitter")
      return {
        loaded = loaded,
        result = linkedspec.runtime_parse(engine, "x", { trace = emitter }),
      }
    end)
    linkedspec.trace.trace_emitter = original_factory
    if not traced_ok then error(traced_or_error, 0) end

    assert_equal(hidden_factory_calls, 0, "pipeline creates no hidden emitter")
    assert_equal(
      json.encode(linkedspec.to_descriptor_json(traced_or_error.loaded.compiled)),
      json.encode(linkedspec.to_descriptor_json(baseline_loaded.compiled)),
      "traced compilation is descriptor-neutral"
    )
    assert_equal(
      json.encode(linkedspec.interpreter.to_json(traced_or_error.result)),
      json.encode(linkedspec.interpreter.to_json(baseline_result)),
      "traced runtime is result-neutral"
    )

    local events = linkedspec.trace_events(emitter)
    local cursor = 0
    for _, topic in ipairs({
      "lua_io:load_and_compile_spec",
      "lua_io:load_spec",
      "lua_io:resolve_spec",
      "lua_io:resolve_spec:candidate",
      "lua_io:load_spec:content",
      "lua_io:load_and_compile_spec:loaded",
      "lua_frontend:parse_spec_with_functions",
      "lua_frontend:function_parser_spec:cache",
      "lua_frontend:function_parser_execute",
      "lua_runtime:create_engine",
      "lua_runtime:parse",
      "lua_staged:parse_spec_with_function_asts",
      "lua_frontend:function_shell_spec",
      "lua_frontend:function_projection",
      "lua_frontend:parse_spec",
      "lua_staged:function_body_dispatch",
      "lua_staged:execute_jobs",
      "lua_staged:job",
      "lua_staged:job:resolve",
      "lua_staged:job:load",
      "lua_staged:job:compile",
      "lua_staged:job:execute",
      "lua_staged:function_body_dispatch:stitch",
      "lua_frontend:validate_spec",
      "lua_compiler:compile_spec",
      "lua_compiler:function_registry",
      "lua_io:create_engine",
      "lua_runtime:create_engine",
      "lua_runtime:parse",
      "lua_runtime:rule",
    }) do
      local found
      for index = cursor + 1, #events do
        if events[index].topic == topic then
          found = index
          break
        end
      end
      if found == nil then fail("missing ordered full-pipeline trace topic " .. topic) end
      cursor = found
    end

    local enters = 0
    local exits = 0
    for _, event in ipairs(events) do
      if event.kind == linkedspec.TRACE_ENTER then enters = enters + 1 end
      if event.kind == linkedspec.TRACE_EXIT then exits = exits + 1 end
    end
    assert_equal(exits, enters, "full-pipeline scopes stay balanced")
    assert_contains(read_file(route_path), "lua_staged:job:execute", "routed staged phase")
    assert_contains(read_file(route_path), "lua_runtime:rule", "routed runtime rule")
  end)
end)

test("full-pipeline tracing filters levels stays quiet and preserves attributed failures", function()
  with_temp_directory(function(root)
    local valid_path = root .. "/valid.spec"
    local invalid_path = root .. "/invalid.spec"
    write_file(valid_path, "Top::\n /x/\n")
    write_file(invalid_path, "Only:\n /x/\n")

    local function run_with(emitter)
      local loaded = linkedspec.load_and_compile_spec(
        linkedspec.path_spec_request(valid_path),
        linkedspec.spec_load_options({ cwd = root, search_roots = {}, trace = emitter })
      )
      local engine = loaded:create_engine({ trace = emitter })
      return linkedspec.runtime_parse(engine, "x", { trace = emitter })
    end

    local quiet_output = {}
    local quiet = linkedspec.trace_emitter(linkedspec.trace_config_disabled(), {
      stdout_writer = function(payload) quiet_output[#quiet_output + 1] = payload end,
    })
    local quiet_result = run_with(quiet)
    assert_equal(#linkedspec.trace_events(quiet), 0, "disabled full pipeline has no events")
    assert_equal(table.concat(quiet_output), "", "disabled full pipeline has no output")

    local low = linkedspec.trace_emitter(linkedspec.trace_config_enabled(linkedspec.TRACE_LOW), {
      stdout_writer = function() end,
    })
    local low_result = run_with(low)
    assert_equal(#linkedspec.trace_events(low), 0, "low filters medium and high pipeline events")
    assert_equal(
      json.encode(linkedspec.interpreter.to_json(low_result)),
      json.encode(linkedspec.interpreter.to_json(quiet_result)),
      "level filtering is result-neutral"
    )

    local medium = linkedspec.trace_emitter(linkedspec.trace_config_enabled(linkedspec.TRACE_MEDIUM), {
      stdout_writer = function() end,
    })
    run_with(medium)
    local medium_events = linkedspec.trace_events(medium)
    assert_equal(#medium_events > 0, true, "medium admits phase decisions")
    for _, event in ipairs(medium_events) do
      assert_equal(event.kind, linkedspec.TRACE_DECISION, "medium filters high scopes")
    end

    local baseline_ok, baseline_error = pcall(
      linkedspec.load_and_compile_spec,
      linkedspec.path_spec_request(invalid_path),
      linkedspec.spec_load_options({ cwd = root, search_roots = {} })
    )
    assert_equal(baseline_ok, false, "baseline validation failure")
    local failure = linkedspec.trace_emitter(linkedspec.trace_config_enabled(linkedspec.TRACE_DEBUG), {
      stdout_writer = function() end,
    })
    local traced_ok, traced_error = pcall(
      linkedspec.load_and_compile_spec,
      linkedspec.path_spec_request(invalid_path),
      linkedspec.spec_load_options({ cwd = root, search_roots = {}, trace = failure })
    )
    assert_equal(traced_ok, false, "traced validation failure")
    assert_equal(linkedspec.is_spec_pipeline_error(traced_error), true, "traced error remains attributed")
    assert_equal(traced_error.stage, "validate_spec", "traced error stage")
    assert_equal(
      json.encode(linkedspec.spec_pipeline_error_to_json(traced_error)),
      json.encode(linkedspec.spec_pipeline_error_to_json(baseline_error)),
      "traced failure JSON is neutral"
    )
    local validation_exit
    local enters = 0
    local exits = 0
    for _, event in ipairs(linkedspec.trace_events(failure)) do
      if event.kind == linkedspec.TRACE_ENTER then enters = enters + 1 end
      if event.kind == linkedspec.TRACE_EXIT then
        exits = exits + 1
        if event.topic == "lua_frontend:validate_spec" then validation_exit = event end
      end
    end
    assert_equal(validation_exit ~= nil, true, "validation failure closes its phase scope")
    assert_contains(validation_exit.details, "no top rule found", "validation failure detail")
    assert_equal(exits, enters, "failure scopes stay balanced")

    assert_error_contains(function()
      linkedspec.spec_load_options({ cwd = root, search_roots = {}, trace = {} })
    end, "trace must be a LinkedSpecTraceEmitter", "invalid pipeline emitter")
  end)
end)

test("checked-in corpus validates all 105 strict fixtures", function()
  local validation = linkedspec.load_corpus_fixtures("rust/linkedspec-runtime/tests/corpus")
  assert_equal(validation.manifest.format, 1, "manifest format")
  assert_equal(validation.manifest.case_count, 105, "manifest count")
  assert_equal(#validation.fixtures, 105, "fixture count")
  assert_equal(validation.fixtures[1].name, "proof_edge_array_literal", "first fixture")
  assert_equal(json.kind(validation.fixtures[1].expected_json), "array", "expected JSON kind")
end)

test("corpus runner validates by default and rejects manifest drift", function()
  local status, output_text, error_text = run_corpus_runner({
    "--corpus",
    "rust/linkedspec-runtime/tests/corpus",
  })
  assert_equal(status, 0, "corpus runner status")
  assert_contains(output_text, "fixtures: 105", "corpus runner count")
  assert_contains(output_text, "execution not requested", "execution boundary")
  assert_equal(error_text, "", "corpus runner stderr")

  with_temp_directory(function(root)
    write_manifest(root, { "missing" })
    local invalid_status, invalid_output, invalid_error = run_corpus_runner({ "--corpus", root })
    assert_equal(invalid_status, 2, "invalid manifest status")
    assert_equal(invalid_output, "", "invalid manifest stdout")
    assert_contains(invalid_error, "missing fixture dirs: [missing]", "invalid manifest stderr")
  end)

  with_temp_directory(function(root)
    write_manifest(root, { "mismatch" })
    write_fixture(root, "mismatch", {
      spec_source = "Top::\n /x/ E { return(\"actual\") }\n",
      expected_source = '"expected"',
    })
    local failed_status, failed_output, failed_error = run_corpus_runner({
      "--corpus",
      root,
      "--execute",
    })
    assert_equal(failed_status, 1, "fixture failure status")
    assert_contains(failed_output, "FAIL mismatch [compare]", "fixture failure report")
    assert_contains(failed_output, "summary: 0 passed, 1 failed", "fixture failure summary")
    assert_equal(failed_error, "", "fixture failure stderr")
  end)
end)

test("corpus manifest rejects format names duplicates and count drift", function()
  assert_error_contains(function()
    linkedspec.load_corpus_fixtures("/private/tmp/linkedspec-lua-corpus-does-not-exist")
  end, "corpus directory missing", "missing corpus root")
  with_temp_directory(function(root)
    write_manifest(root, { "alpha" }, { format = 2 })
    write_fixture(root, "alpha")
    assert_error_contains(function()
      linkedspec.load_corpus_fixtures(root)
    end, "unsupported corpus manifest format 2", "manifest format")
  end)
  with_temp_directory(function(root)
    write_manifest(root, { "../bad" })
    assert_error_contains(function()
      linkedspec.load_corpus_fixtures(root)
    end, "invalid corpus manifest case name: ../bad", "manifest case name")
  end)
  with_temp_directory(function(root)
    write_manifest(root, { "alpha", "alpha" })
    assert_error_contains(function()
      linkedspec.load_corpus_fixtures(root)
    end, "duplicate case names", "duplicate cases")
  end)
  with_temp_directory(function(root)
    write_manifest(root, { "alpha" }, { case_count = 2 })
    write_fixture(root, "alpha")
    assert_error_contains(function()
      linkedspec.load_corpus_fixtures(root)
    end, "case_count=2 does not match cases.len()=1", "manifest count")
  end)
end)

test("corpus manifest rejects missing and stale fixture directories", function()
  with_temp_directory(function(root)
    write_manifest(root, { "alpha", "beta" })
    write_fixture(root, "alpha")
    assert_error_contains(function()
      linkedspec.load_corpus_fixtures(root)
    end, "missing fixture dirs: [beta]", "missing fixture")
  end)
  with_temp_directory(function(root)
    write_manifest(root, { "alpha" })
    write_fixture(root, "alpha")
    write_fixture(root, "stale")
    assert_error_contains(function()
      linkedspec.load_corpus_fixtures(root)
    end, "extra fixture dirs: [stale]", "stale fixture")
  end)
end)

test("corpus fixture files require strict UTF-8 and valid expected JSON", function()
  with_temp_directory(function(root)
    write_manifest(root, { "alpha" })
    write_fixture(root, "alpha", { expected_source = false })
    assert_error_contains(function()
      linkedspec.load_corpus_fixtures(root)
    end, "expected.json file missing", "missing expected JSON")
  end)
  with_temp_directory(function(root)
    write_manifest(root, { "alpha" })
    write_fixture(root, "alpha", { expected_source = "{" })
    assert_error_contains(function()
      linkedspec.load_corpus_fixtures(root)
    end, "malformed expected.json for corpus case alpha", "malformed expected JSON")
  end)
  with_temp_directory(function(root)
    write_manifest(root, { "alpha" })
    write_fixture(root, "alpha", { input_text = string.char(0xFF) })
    assert_error_contains(function()
      linkedspec.load_corpus_fixtures(root)
    end, "input.txt is not valid UTF-8 at byte 1", "invalid fixture UTF-8")
  end)
end)

test("corpus library executes controlled scalar aggregate dispatch lifecycle function and boundary cases", function()
  with_temp_directory(function(root)
    local cases = {
      "scalar_output",
      "nested_aggregate_output",
      "rule_dispatch_output",
      "lifecycle_output_shape",
      "boundary_capture",
      "user_function_call",
    }
    write_manifest(root, cases)
    write_fixture(root, "scalar_output", {
      spec_source = [[
Top::
 /x/ -> Done { return("scalar-ok") }

Done::
 /[a-z]+/
]],
      input_text = "xhello",
      expected_source = '"scalar-ok"',
    })
    write_fixture(root, "nested_aggregate_output", {
      spec_source = [[
Top::
 /n/ -> Done { return(hash("items", array("a", hash("b", 2)), "flag", true, "none", undef)) }

Done::
 /ested/
]],
      input_text = "nested",
      expected_source = json.encode(json.harray({
        flag = true,
        items = json.array({ "a", json.harray({ b = 2 }) }),
        none = json.null,
      })),
    })
    write_fixture(root, "rule_dispatch_output", {
      spec_source = [[
Top::AND
 I { set(out, []) }
 => First { push(out, retv) }
 => Second { push(out, retv) }
 E { return(copy(out)) }

First:
 /a/
 E { return("first") }

Second:
 /b/
 E { return("second") }
]],
      input_text = "ab",
      expected_source = json.encode(json.array({ "first", "second" })),
    })
    write_fixture(root, "lifecycle_output_shape", {
      spec_source = [[
Top::OR{1}
 I { push(events, "I") }
 LS { push(events, "LS") }
 /x/
 LE { push(events, "LE") }
 IT { push(events, "IT") }
 EX { push(events, "EX") }
 LX { push(events, "LX") }
 E { return(hash("cursor", cursor_pos(), "events", copy(events))) }
]],
      expected_source = json.encode(json.harray({
        cursor = 1,
        events = json.array({ "I", "LS", "LE", "IT", "EX", "LX" }),
      })),
    })
    write_fixture(root, "boundary_capture", {
      spec_source = [[
Top::
 /BEGIN/
 E {
   body = capture_until_boundary(Boundary, EarlierBoundary)
   return(hash("body", body, "cursor", cursor_pos(), "rest", cursor_rest()))
 }

Boundary: /END/
EarlierBoundary: /STOP/
]],
      input_text = "BEGIN body STOP later END",
      expected_source = json.encode(json.harray({
        body = " body ",
        cursor = 11,
        rest = "STOP later END",
      })),
    })
    write_fixture(root, "user_function_call", {
      spec_source = [[
fn wrap(value) {return(hash("wrapped", value))}
Top::
 /x/
 E { return(wrap(match_text())) }
]],
      expected_source = json.encode(json.harray({ wrapped = "x" })),
    })

    local execution = linkedspec.execute_corpus_fixtures(root, {
      trace_config = linkedspec.trace_config_enabled(linkedspec.TRACE_DEBUG),
    })
    assert_equal(linkedspec.corpus_node_type(execution), "CorpusExecutionResult", "execution record type")
    assert_equal(linkedspec.is_corpus_execution_result(execution), true, "execution record identity")
    assert_equal(#execution.results, 6, "controlled result count")
    assert_equal(linkedspec.corpus_execution_passed(execution), true, "controlled execution")
    assert_equal(linkedspec.corpus_passed_count(execution), 6, "controlled pass count")
    assert_equal(#linkedspec.corpus_failures(execution), 0, "controlled failure count")

    local scalar = linkedspec.corpus_fixture_result(execution, "scalar_output")
    assert_equal(linkedspec.corpus_node_type(scalar), "CorpusFixtureExecutionResult", "fixture record type")
    assert_equal(linkedspec.is_corpus_fixture_execution_result(scalar), true, "fixture record identity")
    assert_equal(scalar.actual_value, "scalar-ok", "scalar value")
    assert_equal(scalar.matched, true, "scalar matched")
    assert_equal(scalar.cursor_code_unit, 1, "scalar byte endpoint")
    assert_equal(scalar.cursor_char_offset, 1, "scalar character endpoint")
    assert_equal(scalar.failure_stage, nil, "scalar failure stage")

    local aggregate = linkedspec.corpus_fixture_result(execution, "nested_aggregate_output")
    assert_equal(json.encode(aggregate.actual_value), json.encode(aggregate.expected_json), "aggregate value")
    local dispatch = linkedspec.corpus_fixture_result(execution, "rule_dispatch_output")
    assert_equal(json.encode(dispatch.actual_output), '[["first","second"]]', "dispatch wrapped output")
    local lifecycle = linkedspec.corpus_fixture_result(execution, "lifecycle_output_shape")
    assert_equal(json.encode(lifecycle.actual_output),
      '[{"cursor":1,"events":["I","LS","LE","IT","EX","LX"]}]', "lifecycle output")

    local boundary = linkedspec.corpus_fixture_result(execution, "boundary_capture")
    assert_equal(boundary.cursor_code_unit, 11, "boundary byte endpoint")
    assert_equal(boundary.cursor_char_offset, 11, "boundary character endpoint")
    local saw_boundary_trace = false
    for _, line in ipairs(boundary.trace_lines) do
      if line:find("lua_runtime:source_boundary", 1, true) then saw_boundary_trace = true end
    end
    assert_equal(saw_boundary_trace, true, "boundary trace retained")
    assert_equal(
      json.encode(linkedspec.corpus_fixture_result(execution, "user_function_call").actual_value),
      '{"wrapped":"x"}',
      "automatic function parse"
    )
    assert_error_contains(function()
      linkedspec.corpus_fixture_result(execution, "missing")
    end, "executed corpus fixture not found: missing", "missing execution result")
  end)
end)

test("corpus library records staged failures and continues through every selected fixture", function()
  with_temp_directory(function(root)
    local cases = {
      "parse_failure",
      "validate_failure",
      "runtime_failure",
      "output_mismatch",
      "no_match",
      "passing_after_failures",
    }
    write_manifest(root, cases)
    write_fixture(root, "parse_failure", { spec_source = "not a spec", expected_source = '"unused"' })
    write_fixture(root, "validate_failure", {
      spec_source = "Top:\n /x/\n",
      expected_source = '"unused"',
    })
    write_fixture(root, "runtime_failure", {
      spec_source = "Top::\n /x/\n E { invented_helper() }\n",
      expected_source = '"unused"',
    })
    write_fixture(root, "output_mismatch", {
      spec_source = "Top::\n /x/\n E { return(\"actual\") }\n",
      expected_source = '"expected"',
    })
    write_fixture(root, "no_match", {
      spec_source = "Top::\n /z/\n",
      expected_source = '"unused"',
    })
    write_fixture(root, "passing_after_failures", {
      spec_source = "Top::\n /x/\n E { return(\"ok\") }\n",
      expected_source = '"ok"',
    })

    local execution = linkedspec.execute_corpus_fixtures(root)
    assert_equal(#execution.results, 6, "all failure fixtures reported")
    assert_equal(linkedspec.corpus_execution_passed(execution), false, "failure execution status")
    assert_equal(linkedspec.corpus_passed_count(execution), 1, "failure execution pass count")
    assert_equal(#linkedspec.corpus_failures(execution), 5, "failure execution failure count")
    assert_equal(linkedspec.corpus_fixture_result(execution, "parse_failure").failure_stage, "parse", "parse stage")
    assert_equal(
      linkedspec.corpus_fixture_result(execution, "validate_failure").failure_stage,
      "validate",
      "validation stage"
    )
    local runtime = linkedspec.corpus_fixture_result(execution, "runtime_failure")
    assert_equal(runtime.failure_stage, "execute", "runtime stage")
    assert_contains(runtime.failure, "unsupported runtime helper", "runtime failure detail")
    assert_equal(linkedspec.is_runtime_diagnostic(runtime.diagnostic), true, "runtime diagnostic identity")
    assert_equal(runtime.diagnostic.spec_name, "runtime_failure", "runtime diagnostic spec name")
    assert_contains(runtime.diagnostic.spec_path, "/runtime_failure/input.spec", "runtime diagnostic spec path")
    local mismatch = linkedspec.corpus_fixture_result(execution, "output_mismatch")
    assert_equal(mismatch.failure_stage, "compare", "comparison stage")
    assert_contains(mismatch.failure, 'expected (reference, wrapped): ["expected"]', "comparison expected output")
    assert_equal(mismatch.actual_value, "actual", "comparison actual value")
    local no_match = linkedspec.corpus_fixture_result(execution, "no_match")
    assert_equal(no_match.failure_stage, "match", "no-match stage")
    assert_equal(no_match.matched, false, "no-match flag retained")
    assert_equal(no_match.cursor_code_unit, 0, "no-match byte endpoint retained")
    assert_equal(no_match.cursor_char_offset, 0, "no-match character endpoint retained")
    assert_equal(
      linkedspec.corpus_fixture_passed(linkedspec.corpus_fixture_result(execution, "passing_after_failures")),
      true,
      "passing fixture after failures"
    )
  end)
end)

test("corpus library selects named and bounded fixtures after full validation", function()
  with_temp_directory(function(root)
    write_manifest(root, { "mismatched", "first", "second" })
    write_fixture(root, "mismatched", {
      spec_source = "Top::\n /x/ E { return(\"actual\") }\n",
      expected_source = '"expected"',
    })
    write_fixture(root, "first", {
      spec_source = "Top::\n /x/ E { return(\"first\") }\n",
      expected_source = '"first"',
    })
    write_fixture(root, "second", {
      spec_source = "Top::\n /x/ E { return(\"second\") }\n",
      expected_source = '"second"',
    })

    local named = linkedspec.execute_corpus_fixtures(root, { case_names = { "second", "first" } })
    assert_equal(linkedspec.corpus_execution_passed(named), true, "named selection status")
    assert_equal(named.results[1].name, "second", "named selection first")
    assert_equal(named.results[2].name, "first", "named selection second")
    local bounded = linkedspec.execute_corpus_fixtures(root, { offset = 1, limit = 1 })
    assert_equal(#bounded.results, 1, "bounded result count")
    assert_equal(bounded.results[1].name, "first", "bounded selection")
    local capped = linkedspec.execute_corpus_fixtures(root, { offset = 1, limit = 10 })
    assert_equal(#capped.results, 2, "capped result count")

    assert_error_contains(function()
      linkedspec.execute_corpus_fixtures(root, { case_names = { "missing" } })
    end, "selected corpus case not found in manifest: missing", "missing selection")
    assert_error_contains(function()
      linkedspec.execute_corpus_fixtures(root, { case_names = { "first", "first" } })
    end, "selection contains duplicate case name: first", "duplicate selection")
    assert_error_contains(function()
      linkedspec.execute_corpus_fixtures(root, { case_names = { "first" }, limit = 1 })
    end, "case selection cannot be combined with offset or limit", "mixed selection")
    assert_error_contains(function()
      linkedspec.execute_corpus_fixtures(root, { offset = -1 })
    end, "offset must be a non-negative integer", "negative offset")
    assert_error_contains(function()
      linkedspec.execute_corpus_fixtures(root, { limit = 0 })
    end, "limit must be a positive integer", "zero limit")
    assert_error_contains(function()
      linkedspec.execute_corpus_fixtures(root, { offset = 3 })
    end, "offset 3 is outside fixture count 3", "outside offset")
  end)
end)

test("corpus library permanently admits the ordered 40-case core prefix", function()
  local execution = linkedspec.execute_corpus_fixtures(
    "rust/linkedspec-runtime/tests/corpus",
    { offset = 0, limit = 40 }
  )
  assert_equal(execution.validation.manifest.case_count, 105, "core full manifest count")
  assert_equal(#execution.results, 40, "core selected count")
  assert_equal(execution.results[1].name, "proof_edge_array_literal", "core first fixture")
  assert_equal(
    execution.results[40].name,
    "terse_2_2_5_2_attached_switch_blocks",
    "core last fixture"
  )
  assert_equal(linkedspec.corpus_execution_passed(execution), true, "core execution status")
  assert_equal(linkedspec.corpus_passed_count(execution), 40, "core pass count")
  assert_equal(#linkedspec.corpus_failures(execution), 0, "core failure count")

  for index, result in ipairs(execution.results) do
    assert_equal(result.name, execution.validation.manifest.cases[index], "core manifest order " .. index)
    assert_equal(linkedspec.corpus_fixture_passed(result), true, "core fixture status " .. result.name)
    assert_equal(result.matched, true, "core match " .. result.name)
    assert_equal(result.cursor_code_unit, 1, "core byte endpoint " .. result.name)
    assert_equal(result.cursor_char_offset, 1, "core character endpoint " .. result.name)
    assert_equal(result.failure_stage, nil, "core failure stage " .. result.name)
    assert_equal(result.failure, nil, "core failure text " .. result.name)
    assert_equal(
      json.encode(result.actual_output),
      json.encode(json.array({ result.expected_json })),
      "core exact wrapped output " .. result.name
    )
  end
end)

test("corpus library permanently admits the six governed capability fixtures", function()
  local expected_names = {
    "capability_cursor_control_surface",
    "capability_pure_helper_surface",
    "capability_position_helper_surface",
    "capability_control_marker_surface",
    "capability_capture_anonymous_surface",
    "capability_capture_named_surface",
  }
  local expected_endpoints = { 2, 1, 2, 1, 5, 5 }
  local execution = linkedspec.execute_corpus_fixtures(
    "rust/linkedspec-runtime/tests/corpus",
    { offset = 99, limit = #expected_names }
  )
  assert_equal(execution.validation.manifest.case_count, 105, "capability full manifest count")
  assert_equal(#execution.results, #expected_names, "capability selected count")
  assert_equal(linkedspec.corpus_execution_passed(execution), true, "capability execution status")
  assert_equal(linkedspec.corpus_passed_count(execution), #expected_names, "capability pass count")
  assert_equal(#linkedspec.corpus_failures(execution), 0, "capability failure count")

  for index, name in ipairs(expected_names) do
    local result = execution.results[index]
    assert_equal(result.name, name, "capability selected order " .. index)
    assert_equal(
      result.name,
      execution.validation.manifest.cases[99 + index],
      "capability manifest order " .. index
    )
    assert_equal(linkedspec.corpus_fixture_passed(result), true, "capability fixture status " .. name)
    assert_equal(result.matched, true, "capability match " .. name)
    assert_equal(result.cursor_code_unit, expected_endpoints[index], "capability byte endpoint " .. name)
    assert_equal(result.cursor_char_offset, expected_endpoints[index], "capability character endpoint " .. name)
    assert_equal(result.failure_stage, nil, "capability failure stage " .. name)
    assert_equal(result.failure, nil, "capability failure text " .. name)
    assert_equal(
      json.encode(result.actual_output),
      json.encode(json.array({ result.expected_json })),
      "capability exact wrapped output " .. name
    )
  end
end)

test("corpus library permanently admits the ordered 59-case advanced and shipped window", function()
  local expected_cases = {
    { "terse_2_2_6_2_attached_while_blocks", 1 },
    { "terse_2_3_4_deep_pure_helper_composition", 1 },
    { "terse_2_3_4_1_bare_hash_helper_arg_composition", 1 },
    { "terse_2_3_4_1_bare_array_helper_arg_composition", 1 },
    { "terse_2_3_4_2_inline_if_value_control", 1 },
    { "terse_2_3_4_2_inline_switch_value_control", 1 },
    { "terse_15_2_3_bare_value_reads_and_case_labels", 1 },
    { "terse_2_3_5_1_array_receiver_value_chains", 1 },
    { "terse_2_3_5_2_hash_receiver_value_chains", 1 },
    { "terse_2_3_5_3_string_receiver_value_chains", 1 },
    { "terse_2_3_5_4_number_receiver_value_chains", 1 },
    { "terse_7_3_array_numeric_reducer_receiver_methods", 1 },
    { "terse_3_2_1_numeric_word_aliases", 1 },
    { "terse_3_2_2_arithmetic_symbol_callees", 1 },
    { "terse_3_2_3_2_string_comparison_helpers", 1 },
    { "terse_3_2_3_3_numeric_comparison_word_aliases", 1 },
    { "terse_3_2_3_4_numeric_comparison_symbol_callees", 1 },
    { "terse_3_3_1_scalar_assignment_expressions", 1 },
    { "terse_3_3_2_aggregate_assignment_expressions", 1 },
    { "terse_3_3_3_mutation_assignment_expressions", 1 },
    { "terse_3_3_4_assignment_expression_closure", 1 },
    { "terse_4_3_2_user_function_runtime", 1 },
    { "terse_2_3_5_5_block_valued_receiver_chains", 1 },
    { "terse_14_3_with_helper_trailing_block", 1 },
    { "terse_14_4_receiver_with_trailing_block", 1 },
    { "terse_12_3_hash_tree_traversal_receiver_blocks", 1 },
    { "terse_13_3_array_tree_traversal_receiver_blocks", 1 },
    { "terse_2_3_5_6_typed_wrapper_quoted_names", 1 },
    { "tclite_command_subst", 2 },
    { "tclite_double_quote", 2 },
    { "lispish_x_y", 5 },
    { "top_rule_body_recursion_sexpr", 7 },
    { "top_rule_lx_recursion_nested", 7 },
    { "top_rule_lx_recursion_sequence", 7 },
    { "hlink_raw_string", 10 },
    { "hlink_raw_escaped_brackets", 14 },
    { "hlink_curly_brace", 5 },
    { "hlink_bracket_body", 5 },
    { "hlink_mixed_bracket_brace", 13 },
    { "portmap_bare", 3 },
    { "portmap_bit", 6 },
    { "portmap_slice", 8 },
    { "portmap_constant", 4 },
    { "portmap_concatenation", 12 },
    { "ebnf_expression_rules", 40 },
    { "ebnf_logging_annotation", 39 },
    { "spec_spec_minimal_rule", 10 },
    { "spec_spec_action_edge", 47 },
    { "spec_spec_user_function_definition", 94 },
    { "spec_spec_comment_skip", 18 },
    { "regdef_nested_register_fields", 79 },
    { "tablegrep_simple_term", 15 },
    { "simenv_multiline_value", 27 },
    { "vhdl_library_use", 43 },
    { "ds_vhistory_version_entry", 62 },
    { "pplugin_empty", 0 },
    { "tkgui_empty", 0 },
    { "lib_reader_sattribute", 28 },
    { "lib_reader_cattribute", 31 },
  }
  local execution = linkedspec.execute_corpus_fixtures(
    "rust/linkedspec-runtime/tests/corpus",
    { offset = 40, limit = #expected_cases }
  )
  assert_equal(execution.validation.manifest.case_count, 105, "advanced full manifest count")
  assert_equal(#execution.results, #expected_cases, "advanced selected count")
  assert_equal(linkedspec.corpus_execution_passed(execution), true, "advanced execution status")
  assert_equal(linkedspec.corpus_passed_count(execution), #expected_cases, "advanced pass count")
  assert_equal(#linkedspec.corpus_failures(execution), 0, "advanced failure count")

  for index, expected in ipairs(expected_cases) do
    local name = expected[1]
    local endpoint = expected[2]
    local result = execution.results[index]
    assert_equal(result.name, name, "advanced selected order " .. index)
    assert_equal(
      execution.validation.manifest.cases[40 + index],
      name,
      "advanced manifest order " .. index
    )
    assert_equal(linkedspec.corpus_fixture_passed(result), true, "advanced fixture status " .. name)
    assert_equal(result.matched, true, "advanced match " .. name)
    assert_equal(result.cursor_code_unit, endpoint, "advanced byte endpoint " .. name)
    assert_equal(result.cursor_char_offset, endpoint, "advanced character endpoint " .. name)
    assert_equal(result.failure_stage, nil, "advanced failure stage " .. name)
    assert_equal(result.failure, nil, "advanced failure text " .. name)
    assert_equal(
      json.encode(result.actual_output),
      json.encode(json.array({ result.expected_json })),
      "advanced exact wrapped output " .. name
    )
  end
end)

test("corpus library and developer runner execute the complete ordered 105-case manifest", function()
  local corpus_path = "rust/linkedspec-runtime/tests/corpus"
  local execution = linkedspec.execute_corpus_fixtures(corpus_path)
  assert_equal(execution.validation.manifest.format, 1, "full manifest format")
  assert_equal(execution.validation.manifest.case_count, 105, "full manifest count")
  assert_equal(#execution.results, 105, "full result count")
  assert_equal(execution.results[1].name, "proof_edge_array_literal", "full first fixture")
  assert_equal(execution.results[105].name, "capability_capture_named_surface", "full last fixture")
  assert_equal(linkedspec.corpus_execution_passed(execution), true, "full execution status")
  assert_equal(linkedspec.corpus_passed_count(execution), 105, "full pass count")
  assert_equal(#linkedspec.corpus_failures(execution), 0, "full failure count")

  for index, result in ipairs(execution.results) do
    assert_equal(result.name, execution.validation.manifest.cases[index], "full manifest order " .. index)
    assert_equal(linkedspec.corpus_fixture_passed(result), true, "full fixture status " .. result.name)
    assert_equal(result.matched, true, "full match " .. result.name)
    assert_equal(result.failure_stage, nil, "full failure stage " .. result.name)
    assert_equal(result.failure, nil, "full failure text " .. result.name)
    assert_equal(
      json.encode(result.actual_output),
      json.encode(json.array({ result.expected_json })),
      "full exact wrapped output " .. result.name
    )
  end

  local status, output_text, error_text = run_corpus_runner({ "--corpus", corpus_path, "--execute" })
  assert_equal(status, 0, "full runner status")
  assert_contains(output_text, "format: 1", "full runner format")
  assert_contains(output_text, "fixtures: 105", "full runner count")
  assert_contains(output_text, "PASS proof_edge_array_literal", "full runner first fixture")
  assert_contains(output_text, "PASS capability_capture_named_surface", "full runner last fixture")
  assert_contains(output_text, "summary: 105 passed, 0 failed", "full runner summary")
  assert_equal(output_text:find("FAIL ", 1, true), nil, "full runner failures")
  assert_equal(error_text, "", "full runner stderr")
end)

test("source AST round-trips with neutral fields and provenance", function()
  local payload = json.harray({ kind = "action_block" })
  local job = ast.staged_parse_job({
    job_id = "parse_job:function_body:functions.0.body_source",
    parent_ast_path = { "functions", "0", "body_source" },
    node_kind = "function_definition",
    payload_kind = "action_block",
    text = "return(trim(value))",
    source_span = ast.staged_source_span({ start = 10, ["end"] = 28, line_start = 1, line_end = 1 }),
    parser_spec_id = "actionir-body.spec",
    top_rule = "action_block",
    result_policy = "replace_field",
    result_field = "body_ast",
    failure_policy = "diagnostic",
  })
  local function_definition = ast.function_definition({
    name = "normalize",
    params = { "value" },
    arity = 1,
    body_source = "return(trim(value))",
    body_payload = payload,
    body_parse_job = job,
    body_ast = json.harray({ kind = "code_block", statements = json.array() }),
    source = "fn normalize(value) { return(trim(value)) }",
    source_span = ast.source_span({ line_start = 1, line_end = 1 }),
    body_span = ast.source_span({ line_start = 1, line_end = 1 }),
  })
  local minimal_function = ast.function_definition({
    name = "noop",
    params = {},
    arity = 0,
    body_source = "return()",
    source = "fn noop() { return() }",
    source_span = ast.source_span({ line_start = 2, line_end = 2 }),
    body_span = ast.source_span({ line_start = 2, line_end = 2 }),
  })
  payload.kind = "mutated"
  local mode = ast.and_bounded_rule_mode({ min = 1, max = 2 })
  local spec = ast.spec_file({
    functions = { function_definition, minimal_function },
    rules = {
      ast.rule({
        header = ast.rule_header({
          label = "Top",
          is_top = true,
          mode = mode,
          rest = "/x/ -> Child[0] { return(normalize(retv)) }",
          line = 2,
        }),
        body = {
          ast.body_element({
            kind = ast.regex_body_kind({ pattern = "x" }),
            source = "/x/",
            line = 2,
          }),
          ast.body_element({
            kind = ast.action_edge_body_kind({
              targets = { ast.edge_target({ label = "Child" }) },
              code = "return(normalize(retv))",
              fluent_chain = { ast.fluent_call({ method = "push", args = "" }) },
            }),
            source = "-> Child[0] { return(normalize(retv)) }.push",
            line = 2,
          }),
          ast.body_element({
            kind = ast.code_block_body_kind({ lifecycle = "I", code = "set(count, 0)" }),
            source = "I { set(count, 0) }",
            line = 3,
          }),
        },
      }),
    },
  })

  local projected = ast.to_json(spec)
  local encoded = json.encode(projected)
  local decoded = ast.from_json("SpecFile", json.decode(encoded))
  assert_equal(ast.node_type(decoded), "SpecFile", "spec node type")
  assert_equal(decoded.functions[1].body_payload.kind, "action_block", "payload defensive copy")
  assert_equal(decoded.functions[1].body_parse_job.job_id, job.job_id, "parse-job provenance")
  assert_equal(decoded.functions[2].body_parse_job, nil, "optional parse job")
  assert_equal(decoded.functions[2].body_payload, nil, "optional body payload")
  assert_equal(ast.top_rule(decoded).header.label, "Top", "top rule")
  assert_equal(ast.find_rule(decoded, "Top").header.mode.name, "AndBounded", "find rule")
  assert_equal(ast.rule_mode_is_and(ast.top_rule(decoded).header.mode), true, "AND mode")
  assert_equal(ast.rule_mode_rep_min(ast.top_rule(decoded).header.mode), 1, "mode minimum")
  assert_equal(ast.rule_mode_rep_max(ast.top_rule(decoded).header.mode), 2, "mode maximum")
  assert_equal(ast.node_type(decoded.rules[1].body[3].kind), "CodeBlockBodyElementKind", "codeblock identity")
  assert_equal(json.encode(ast.to_json(decoded)), encoded, "lossless AST JSON")
end)

test("source AST covers every body element variant", function()
  local call = ast.fluent_call({ method = "push", args = "value" })
  local target = ast.edge_target({ label = "Child", index = 2 })
  local kinds = {
    ast.regex_body_kind({ pattern = "x" }),
    ast.action_edge_body_kind({ targets = { target }, fluent_chain = { call } }),
    ast.blind_edge_body_kind({ target = "Child", fluent_chain = { call } }),
    ast.code_block_body_kind({ lifecycle = "E", code = "return(retv)" }),
    ast.plain_block_body_kind({ code = "return(retv)" }),
    ast.split_marker_body_kind({ marker = "---" }),
    ast.lifecycle_marker_body_kind({ marker = "I" }),
    ast.fluent_chain_body_kind({ calls = { call } }),
    ast.conditional_body_kind({ word = "if" }),
    ast.raw_body_kind({ text = "legacy" }),
  }
  for index, kind in ipairs(kinds) do
    local element = ast.body_element({ kind = kind, source = "source", line = index })
    local decoded = ast.from_json("BodyElement", json.decode(json.encode(ast.to_json(element))))
    assert_equal(ast.node_type(decoded.kind), ast.node_type(kind), "body kind " .. index)
  end
end)

test("source AST rejects malformed types and unsupported variants", function()
  assert_error_contains(function()
    ast.rule_mode("Unknown")
  end, "unsupported rule mode Unknown", "unknown rule mode")
  assert_error_contains(function()
    ast.from_json("BodyElementKind", json.harray({ kind = "unknown" }))
  end, "unsupported body element kind unknown", "unknown body kind")
  assert_error_contains(function()
    ast.spec_file({ rules = { "not a rule" } })
  end, "must contain only Rule nodes", "typed rule list")
  assert_error_contains(function()
    ast.spec_file({ rules = { [2] = "sparse" } })
  end, "contiguous one-based integer indexes", "dense rule list")
  assert_error_contains(function()
    ast.function_definition({
      name = "bad",
      params = {},
      arity = 0,
      body_source = "",
      body_payload = {},
      source = "fn bad() {}",
      source_span = ast.source_span({ line_start = 1, line_end = 1 }),
      body_span = ast.source_span({ line_start = 1, line_end = 1 }),
    })
  end, "must be a typed JSON value", "ambiguous payload")
end)

local function body_kind(rule, index)
  return rule.body[index].kind
end

local function starts_with_top_level_function(source)
  for line in (source .. "\n"):gmatch("(.-)\n") do
    local text = line:match("^%s*(.-)%s*$")
    if text ~= "" and text:sub(1, 1) ~= "#" then
      return text:match("^fn%s") ~= nil
    end
  end
  return false
end

local function nul_delimited_paths(command)
  local handle = assert(io.popen(command, "r"))
  local output = handle:read("*a")
  assert(handle:close())
  local paths = {}
  local start = 1
  while start <= #output do
    local ending = assert(output:find("\0", start, true))
    paths[#paths + 1] = output:sub(start, ending - 1)
    start = ending + 1
  end
  table.sort(paths)
  return paths
end

local function read_file(path)
  local handle = assert(io.open(path, "rb"))
  local value = handle:read("*a")
  assert(handle:close())
  return value
end

test("source parser handles headers inline bodies and modes", function()
  local modes = {
    { "R1:AND", "And" },
    { "R2:OR+", "OrPlus" },
    { "R3::*", "Star" },
    { "R4:?", "Optional" },
    { "R5:AND{2,4}", "AndBounded" },
    { "R6:OR{3}", "OrBounded" },
    { "R7:&", "Single" },
    { "R8:|", "Pipe" },
  }
  for _, item in ipairs(modes) do
    local parsed = linkedspec.parse_spec(item[1] .. "\n /x/")
    assert_equal(parsed.rules[1].header.mode.name, item[2], item[1])
    assert_equal(ast.node_type(body_kind(parsed.rules[1], 1)), "RegexBodyElementKind", item[1] .. " regex")
  end
  local inline = linkedspec.parse_spec('Top:: /x/ I { return(entry_text()) } E.return("done")')
  assert_equal(#inline.rules[1].body, 3, "inline element count")
  assert_equal(ast.node_type(body_kind(inline.rules[1], 1)), "RegexBodyElementKind", "inline regex")
  assert_equal(ast.node_type(body_kind(inline.rules[1], 2)), "CodeBlockBodyElementKind", "inline block")
  assert_equal(body_kind(inline.rules[1], 3).code, 'return("done")', "inline fluent lifecycle")
end)

test("source parser keeps header-line regex slots", function()
  local single = linkedspec.parse_spec("Top::\n -> semi\n\nsemi : /;/")
  assert_equal(body_kind(ast.find_rule(single, "semi"), 1).pattern, ";", "single header regex")
  local pair = linkedspec.parse_spec("Top::\n -> bracket\n\nbracket : /\\(/ /\\)/")
  assert_equal(body_kind(ast.find_rule(pair, "bracket"), 1).pattern, "\\(", "first header regex")
  assert_equal(body_kind(ast.find_rule(pair, "bracket"), 2).pattern, "\\)", "second header regex")
end)

test("source parser handles action blind grouped indexed and fluent edges", function()
  local parsed = linkedspec.parse_spec([[
Top::->Child.push
 -> Child[1] .return(array("?child:", copy(Child)))
 -> A | B { return(entry_text()) }
 =>Helper.trim()

Child: /x/ /y/
Helper: /h/
]])
  local top = ast.top_rule(parsed)
  assert_equal(#top.body, 4, "top edge count")
  assert_equal(body_kind(top, 1).targets[1].label, "Child", "compact target")
  assert_equal(body_kind(top, 1).fluent_chain[1].method, "push", "compact fluent")
  assert_equal(body_kind(top, 2).targets[1].index, 1, "indexed target")
  assert_equal(body_kind(top, 2).fluent_chain[1].args, 'array("?child:", copy(Child))', "nested args")
  assert_equal(body_kind(top, 3).targets[2].label, "B", "grouped target")
  assert_equal(body_kind(top, 3).code, "return(entry_text())", "grouped code")
  assert_equal(body_kind(top, 4).target, "Helper", "blind target")
  assert_equal(body_kind(top, 4).fluent_chain[1].method, "trim", "blind fluent")
end)

test("source parser attaches multiline action fluent continuations", function()
  local parsed = linkedspec.parse_spec([[
Top::
 -> item
  .if(on)
    .push(item, out)
  .else()
    .return_undef()
  .endif()

item: /x/
]])
  local calls = body_kind(ast.top_rule(parsed), 1).fluent_chain
  assert_equal(#calls, 5, "continuation count")
  assert_equal(calls[1].method, "if", "first continuation")
  assert_equal(calls[2].args, "item, out", "continuation args")
  assert_equal(calls[5].method, "endif", "last continuation")
end)

test("source parser normalizes attached when otherwise blocks", function()
  local parsed = linkedspec.parse_spec([[
Top::
 -> Done.when(false) {
    return("bad")
 }.otherwise {
    return("fallback")
 }
 I.when(false) { set(out, "bad") } otherwise { set(out, "fallback") }

Done:
 /x/
]])
  local top = ast.top_rule(parsed)
  assert_contains(body_kind(top, 1).code, "when(false)", "action when")
  assert_contains(body_kind(top, 1).code, 'return("fallback")', "action otherwise")
  assert_contains(body_kind(top, 2).code, "otherwise", "lifecycle otherwise")
  assert_contains(body_kind(top, 2).code, 'set(out, "fallback")', "lifecycle fallback")
end)

test("source parser uses semicolons only between compact same-line statements", function()
  local parsed = linkedspec.parse_spec([[
Top::
 I.set(out, undef).set(out, "ok").return(out)
 /a/ E {
   set(out, "a")
   set(other, 'b')
   return(out)
 }
 /b/ EX { set(out, "a"); set(other, 'b'); return(out) }
]])
  local top = ast.top_rule(parsed)
  assert_equal(body_kind(top, 1).code, 'set(out, undef); set(out, "ok"); return(out)', "compact separators")
  assert_equal(
    body_kind(top, 3).code,
    'set(out, "a")\nset(other, \'b\')\nreturn(out)',
    "physical newline separators"
  )
  assert_equal(
    body_kind(top, 5).code,
    'set(out, "a"); set(other, \'b\'); return(out)',
    "same-line separators without trailing semicolon"
  )
end)

test("source parser handles multiline fluent arguments and quoted braces", function()
  local parsed = linkedspec.parse_spec([[
Top::
 I.return({
  "type" => "function_definition_error",
  "source_text" => entry_text()
 })
 /a/ I { print("literal { brace"); print('literal } brace') }
 /b/ E { return("ok") }
]])
  local top = ast.top_rule(parsed)
  assert_contains(body_kind(top, 1).code, '"source_text" => entry_text()', "multiline fluent argument")
  assert_contains(body_kind(top, 3).code, 'print("literal { brace")', "double-quoted brace")
  assert_contains(body_kind(top, 3).code, "print('literal } brace')", "single-quoted brace")
  assert_equal(ast.node_type(body_kind(top, 4)), "RegexBodyElementKind", "post-brace regex")
end)

test("source parser preserves raw lines and returns typed parse errors", function()
  local raw = linkedspec.parse_spec("Top::\n raw compatibility line")
  assert_equal(ast.node_type(body_kind(ast.top_rule(raw), 1)), "RawBodyElementKind", "raw fallback")
  local ok, parse_error = pcall(
    linkedspec.parse_spec,
    "fn normalize(value) { return(trim(value)) }\n\nTop::\n /x/"
  )
  assert_equal(ok, false, "top-level function rejection")
  assert_equal(linkedspec.is_spec_parse_error(parse_error), true, "typed parse error")
  assert_equal(parse_error.line, 1, "parse error line")
  local utf8_ok, utf8_error = pcall(linkedspec.parse_spec, "Top::\n /" .. string.char(0xFF) .. "/")
  assert_equal(utf8_ok, false, "invalid UTF-8 source rejection")
  assert_equal(linkedspec.is_spec_parse_error(utf8_error), true, "invalid UTF-8 typed error")
  assert_contains(utf8_error.message, "not valid UTF-8 at byte", "invalid UTF-8 position")
end)

test("source parser accepts every shipped spec", function()
  local paths = nul_delimited_paths("find specs -maxdepth 1 -type f -name '*.spec' -print0")
  if #paths == 0 then
    fail("shipped spec inventory is empty")
  end
  for _, path in ipairs(paths) do
    local parsed = linkedspec.parse_spec(read_file(path))
    if #parsed.rules == 0 then
      fail("shipped spec parsed without rules: " .. path)
    end
  end
end)

test("source parser accepts every rule-only corpus spec", function()
  local validation = linkedspec.load_corpus_fixtures("rust/linkedspec-runtime/tests/corpus")
  local parsed_count = 0
  local skipped_function_shells = 0
  for _, fixture in ipairs(validation.fixtures) do
    if starts_with_top_level_function(fixture.spec_source) then
      skipped_function_shells = skipped_function_shells + 1
    else
      local parsed = linkedspec.parse_spec(fixture.spec_source)
      if #parsed.rules == 0 then
        fail("corpus spec parsed without rules: " .. fixture.name)
      end
      parsed_count = parsed_count + 1
    end
  end
  if parsed_count <= 80 then
    fail("too few rule-only corpus specs parsed: " .. parsed_count)
  end
  if skipped_function_shells == 0 then
    fail("expected at least one staged function-shell corpus spec")
  end
end)

local function assert_validation_error(operation, expected, label)
  local ok, validation_error = pcall(operation)
  if ok then
    fail((label or "validation") .. ": expected an error")
  end
  assert_equal(linkedspec.is_spec_validation_error(validation_error), true, (label or "validation") .. " type")
  assert_contains(validation_error.message, expected, label)
end

local function validation_function(name, params, arity)
  return ast.function_definition({
    name = name,
    params = params,
    arity = arity == nil and #params or arity,
    body_source = "return(value)",
    source = "fn " .. name .. "(" .. table.concat(params, ", ") .. ") { return(value) }",
    source_span = ast.source_span({ line_start = 1, line_end = 1 }),
    body_span = ast.source_span({ line_start = 1, line_end = 1 }),
  })
end

local function spec_with_functions(functions)
  return ast.spec_file({
    functions = functions,
    rules = {
      ast.rule({
        header = ast.rule_header({
          label = "Top",
          is_top = true,
          mode = ast.default_rule_mode(),
          rest = "",
          line = 1,
        }),
        body = {
          ast.body_element({
            kind = ast.regex_body_kind({ pattern = "x" }),
            source = "/x/",
            line = 2,
          }),
        },
      }),
    },
  })
end

test("source validator checks top and duplicate rule labels", function()
  assert_validation_error(function()
    linkedspec.validate_spec(linkedspec.parse_spec("Top:\n /a/"))
  end, "no top rule", "missing top")
  assert_validation_error(function()
    linkedspec.validate_spec(linkedspec.parse_spec("Top::\n /a/\n\nTop:\n /b/"))
  end, "duplicate rule label", "duplicate rule")
end)

test("source validator checks edge families targets and slots", function()
  assert_validation_error(function()
    linkedspec.validate_spec(linkedspec.parse_spec([[
Top::
 /a/ -> A
 /b/ => B
A: /a/
B: /b/
]]))
  end, "mixes action", "mixed edges")
  assert_validation_error(function()
    linkedspec.validate_spec(linkedspec.parse_spec("Top::\n /a/ -> Ghost"))
  end, "undefined rule", "missing target")
  assert_validation_error(function()
    linkedspec.validate_spec(linkedspec.parse_spec("Top::\n /a/ -> Child[1]\n\nChild:\n /b/"))
  end, "regex slot 1", "bad target slot")
  assert_validation_error(function()
    linkedspec.validate_spec(linkedspec.parse_spec("Top::\n -> A | B\n\nA: /a/\nB: /b/"))
  end, "grouped action-edge targets", "grouped target block")
end)

test("source validator checks raw syntax and regex structure", function()
  assert_validation_error(function()
    linkedspec.validate_spec(linkedspec.parse_spec("Top::\n unsupported helper line"))
  end, "unrecognized body syntax", "raw syntax")
  assert_validation_error(function()
    linkedspec.validate_spec(linkedspec.parse_spec("Top::\n /[invalid/"))
  end, "invalid regex pattern", "regex structure")
end)

test("source validator supports strict unused-rule behavior", function()
  local parsed = linkedspec.parse_spec("Top::\n /a/ -> Child\n\nChild:\n /b/")
  assert_equal(linkedspec.validate_spec(parsed), nil, "non-strict validation")
  assert_validation_error(function()
    linkedspec.validate_spec(parsed, { strict_syntax = true })
  end, "unused rule(s) in strict mode: Top", "strict unused top")
  assert_equal(
    linkedspec.validate_spec(linkedspec.parse_spec("Top::\n /a/ -> Top"), { strict_syntax = true }),
    nil,
    "strict recursive top"
  )
end)

test("source validator locks all 246 helper and control names", function()
  local action_names = require("linkedspec.action_call_names")
  assert_equal(action_names.count(), 246, "current call-name count")
  assert_equal(#action_names.current_names(), 246, "current call-name list count")
  assert_equal(action_names.current_names()[1], "!=", "current call-name list is sorted")
  assert_equal(action_names.is_known("trim"), true, "trim reservation")
  assert_equal(action_names.is_known("with"), true, "with reservation")
  assert_equal(action_names.is_known("otherwise"), true, "alias reservation")
  assert_equal(action_names.is_known("not_a_helper"), false, "unknown name")
end)

test("complete named marks admit exactly seven names into the shared inventory", function()
  local action_names = require("linkedspec.action_call_names")
  local contract = json.decode(read_file("capability_conformance/complete_named_mark_contract.json"))
  local staged = action_names.complete_named_mark_names()
  local count = 0
  for _, helper in ipairs(contract.helpers) do
    count = count + 1
    assert_equal(staged[helper.name], true, helper.name .. " contract name")
    assert_equal(action_names.is_known(helper.name), true, helper.name .. " known")
    assert_equal(action_names.is_shared_inventory_name(helper.name), true, helper.name .. " shared")
    local resolution = linkedspec.resolve_action_expression_contracts(
      linkedspec.parse_action_expression(helper.name .. "(probe)")
    )
    assert_equal(resolution.ok, true, helper.name .. " contract")
    assert_equal(resolution.contracts[1].family, "capture_mark", helper.name .. " family")
  end
  local staged_count = 0
  for _ in pairs(staged) do staged_count = staged_count + 1 end
  assert_equal(count, 7, "contract helper count")
  assert_equal(staged_count, 7, "complete named-mark helper count")
  assert_equal(action_names.count(), 246, "shared inventory includes complete named marks")
end)

test("source validator checks function registry records", function()
  assert_equal(linkedspec.validate_spec(spec_with_functions({ validation_function("normalize", { "value" }) })), nil)
  assert_validation_error(function()
    linkedspec.validate_spec(spec_with_functions({
      validation_function("normalize", { "value" }),
      validation_function("normalize", { "other" }),
    }))
  end, "duplicate user function", "duplicate function")
  assert_validation_error(function()
    linkedspec.validate_spec(spec_with_functions({ validation_function("Top", { "value" }) }))
  end, "collides with rule label", "function rule collision")
  assert_validation_error(function()
    linkedspec.validate_spec(spec_with_functions({ validation_function("trim", { "value" }) }))
  end, "built-in helper", "function helper collision")
  assert_validation_error(function()
    linkedspec.validate_spec(spec_with_functions({ validation_function("normalize", { "value", "value" }) }))
  end, "duplicate parameter", "duplicate function param")
  assert_validation_error(function()
    linkedspec.validate_spec(spec_with_functions({ validation_function("normalize", { "ctx" }) }))
  end, "parameter 'ctx' is reserved", "reserved function param")
  assert_validation_error(function()
    linkedspec.validate_spec(spec_with_functions({ validation_function("normalize", { "value" }, 2) }))
  end, "does not match parameter count", "function arity")
end)

test("source validator accepts every shipped spec", function()
  local paths = nul_delimited_paths("find specs -maxdepth 1 -type f -name '*.spec' -print0")
  for _, path in ipairs(paths) do
    linkedspec.validate_spec(linkedspec.parse_spec(read_file(path)))
  end
end)

test("source validator accepts every rule-only corpus spec", function()
  local validation = linkedspec.load_corpus_fixtures("rust/linkedspec-runtime/tests/corpus")
  local validated_count = 0
  for _, fixture in ipairs(validation.fixtures) do
    if not starts_with_top_level_function(fixture.spec_source) then
      linkedspec.validate_spec(linkedspec.parse_spec(fixture.spec_source))
      validated_count = validated_count + 1
    end
  end
  assert_equal(validated_count, 102, "validated rule-only corpus count")
end)

local function utf8_character_count(value)
  local count = 0
  local position = 1
  while position <= #value do
    local first = value:byte(position)
    if first <= 0x7F then
      position = position + 1
    elseif first <= 0xDF then
      position = position + 2
    elseif first <= 0xEF then
      position = position + 3
    else
      position = position + 4
    end
    count = count + 1
  end
  return count
end

local function line_at_character_offset(source, offset)
  local line = 1
  local character_index = 0
  local position = 1
  while position <= #source and character_index < offset do
    local first = source:byte(position)
    local width = first <= 0x7F and 1 or (first <= 0xDF and 2 or (first <= 0xEF and 3 or 4))
    if source:sub(position, position + width - 1) == "\n" then
      line = line + 1
    end
    position = position + width
    character_index = character_index + 1
  end
  return line
end

local function definition_span(source, start_offset, end_offset)
  return json.harray({
    start = start_offset,
    ["end"] = end_offset,
    line_start = line_at_character_offset(source, start_offset),
    line_end = line_at_character_offset(source, end_offset),
  })
end

local function definition_node(source, name, params, body_source)
  local source_byte_start = assert(source:find("fn " .. name, 1, true))
  local body_byte_start = assert(source:find(body_source, source_byte_start, true))
  local body_byte_end = body_byte_start + #body_source
  local source_byte_end = assert(source:find("}", body_byte_end, true)) + 1
  local source_start = utf8_character_count(source:sub(1, source_byte_start - 1))
  local source_end = utf8_character_count(source:sub(1, source_byte_end - 1))
  local body_start = utf8_character_count(source:sub(1, body_byte_start - 1))
  local body_end = utf8_character_count(source:sub(1, body_byte_end - 1))
  local source_text = source:sub(source_byte_start, source_byte_end - 1)
  local source_span = definition_span(source, source_start, source_end)
  local body_span = definition_span(source, body_start, body_end)
  local typed_params = json.array(params)
  local pending_path = json.array({ "functions", "__pending_source_order__", "body_source" })
  return json.harray({
    type = "function_definition",
    kind = "user_function_definition",
    version = 1,
    name = name,
    params = typed_params,
    arity = #params,
    source_text = source_text,
    source_span = source_span,
    body_source = body_source,
    body_span = body_span,
    body_payload = json.harray({
      kind = "staged_payload",
      version = 1,
      node_kind = "function_definition",
      payload_kind = "function_body",
      parent_ast_path = pending_path,
      function_name = name,
      params = typed_params,
      arity = #params,
      text = body_source,
      source_span = body_span,
      provenance = json.array({ json.harray({ kind = "source_slice", source_span = body_span }) }),
    }),
    body_parse_job = json.harray({
      kind = "parse_job",
      version = 1,
      job_id = "parse_job:function_body:" .. name .. ":actionir-body.spec:action_block",
      parent_ast_path = pending_path,
      node_kind = "function_definition",
      payload_kind = "function_body",
      function_name = name,
      params = typed_params,
      arity = #params,
      text = body_source,
      source_span = body_span,
      parser_spec_id = "actionir-body.spec",
      top_rule = "action_block",
      result_policy = "replace_field",
      result_field = "body_ast",
      failure_policy = "fail",
      diagnostic_owner = "function_body",
    }),
  })
end

local function variadic_definition_node(source, name, positional_params, rest_param, body_source)
  local node = definition_node(source, name, positional_params, body_source)
  local signature = json.harray({
    kind = "callable_signature",
    version = 1,
    positional_params = json.array(positional_params),
    rest_param = rest_param,
    min_arity = #positional_params,
    max_arity = json.null,
  })
  node.version = 2
  node.params = nil
  node.arity = nil
  node.signature = json.decode(json.encode(signature))
  for _, staged_name in ipairs({ "body_payload", "body_parse_job" }) do
    local staged = node[staged_name]
    staged.params = nil
    staged.arity = nil
    staged.signature = json.decode(json.encode(signature))
  end
  return node
end

local function codeblock_definition_node(source, name, fixed_params, codeblock_param, body_source)
  local params = {}
  for index, param in ipairs(fixed_params) do params[index] = param end
  params[#params + 1] = codeblock_param
  local node = definition_node(source, name, params, body_source)
  local parameter_kinds = json.harray()
  parameter_kinds[codeblock_param] = "codeblock"
  node.params = nil
  node.arity = nil
  node.fixed_params = json.array(fixed_params)
  node.codeblock_param = codeblock_param
  node.parameter_kinds = json.decode(json.encode(parameter_kinds))
  for _, staged_name in ipairs({ "body_payload", "body_parse_job" }) do
    local staged = node[staged_name]
    staged.params = nil
    staged.arity = nil
    staged.fixed_params = json.array(fixed_params)
    staged.codeblock_param = codeblock_param
    staged.parameter_kinds = json.decode(json.encode(parameter_kinds))
  end
  return node
end

test("function shell preserves the exact fixed-v1 variadic-v2 signature union", function()
  local source = table.concat({
    'fn pair(left, right) { return([left, right]) }',
    'fn all_values(...items) { return(items) }',
    'fn collect(prefix, ...items) { return({ "prefix" : prefix, "items" : items }) }',
    "",
    "Top::",
    " /x/",
    "",
  }, "\n")
  local nodes = json.array({
    definition_node(source, "pair", { "left", "right" }, " return([left, right]) "),
    variadic_definition_node(source, "all_values", {}, "items", " return(items) "),
    variadic_definition_node(
      source,
      "collect",
      { "prefix" },
      "items",
      ' return({ "prefix" : prefix, "items" : items }) '
    ),
  })

  local projection = linkedspec.project_user_function_definition_asts(source, nodes)
  local fixed_json = ast.to_json(projection.functions[1])
  assert_equal(fixed_json.signature, nil, "fixed signature absent")
  assert_equal(fixed_json.arity, 2, "fixed exact arity")
  assert_equal(fixed_json.params[2], "right", "fixed ordered params")

  for index, expected in ipairs({
    { name = "all_values", minimum = 0, positional_count = 0 },
    { name = "collect", minimum = 1, positional_count = 1 },
  }) do
    local definition = projection.functions[index + 1]
    local projected = ast.to_json(definition)
    assert_equal(ast.node_type(definition.signature), "CallableSignature", expected.name .. " signature type")
    assert_equal(projected.params, nil, expected.name .. " params absent")
    assert_equal(projected.arity, nil, expected.name .. " arity absent")
    assert_equal(projected.signature.kind, "callable_signature", expected.name .. " signature kind")
    assert_equal(projected.signature.version, 1, expected.name .. " signature version")
    assert_equal(#projected.signature.positional_params, expected.positional_count, expected.name .. " prefix count")
    assert_equal(projected.signature.rest_param, "items", expected.name .. " rest name")
    assert_equal(projected.signature.min_arity, expected.minimum, expected.name .. " minimum")
    assert_equal(projected.signature.max_arity, json.null, expected.name .. " unbounded maximum")
    for _, staged_name in ipairs({ "body_payload", "body_parse_job" }) do
      local staged = projected[staged_name]
      assert_equal(staged.params, nil, expected.name .. " " .. staged_name .. " params absent")
      assert_equal(staged.arity, nil, expected.name .. " " .. staged_name .. " arity absent")
      assert_equal(
        json.encode(staged.signature),
        json.encode(projected.signature),
        expected.name .. " " .. staged_name .. " exact signature copy"
      )
    end
    local round_trip = ast.from_json("FunctionDefinition", projected)
    assert_equal(
      ast.callable_signatures_equal(round_trip.signature, definition.signature),
      true,
      expected.name .. " AST round-trip"
    )
  end

  local staged = linkedspec.parse_spec_with_staged_user_function_definition_asts(source, nodes)
  assert_equal(linkedspec.validate_spec(staged), nil, "variadic staged validation")
  local compiled = linkedspec.compile_spec(staged)
  local compiled_json = linkedspec.compiled_spec_to_json(compiled)
  assert_equal(
    compiled_json.functions_by_name.all_values.signature.rest_param,
    "items",
    "compiled variadic signature"
  )
  assert_equal(compiled_json.functions_by_name.all_values.params, nil, "compiled v2 params absent")
  local descriptor = linkedspec.to_descriptor_json(compiled)
  local descriptor_contract = json.decode(
    read_file("capability_conformance/outward_descriptor_contract.json")
  )
  local variant = descriptor_contract.function_record_variants.variadic_v2
  assert_equal(
    table.concat(sorted_keys(descriptor.functions.all_values), ","),
    table.concat(sorted_values(variant.record_fields), ","),
    "variadic descriptor exact fields"
  )
  assert_equal(descriptor.functions.all_values.version, variant.function_version, "variadic descriptor version")
  assert_equal(
    json.encode(descriptor.functions.all_values.signature),
    json.encode(descriptor.functions.all_values.body_payload.signature),
    "variadic descriptor staged signature copy"
  )
end)

test("function shell rejects drifting variadic signature records", function()
  local source = 'fn collect(prefix, ...items) { return(items) }\nTop::\n /x/\n'
  local function fresh_node()
    return variadic_definition_node(source, "collect", { "prefix" }, "items", " return(items) ")
  end

  local mixed = fresh_node()
  mixed.params = json.array({ "prefix" })
  assert_error_contains(function()
    linkedspec.project_user_function_definition_asts(source, json.array({ mixed }))
  end, "version 2 must store arity only in signature", "mixed v2 storage")

  local extra_field = fresh_node()
  extra_field.signature.extra = true
  assert_error_contains(function()
    linkedspec.project_user_function_definition_asts(source, json.array({ extra_field }))
  end, "invalid callable signature fields", "signature extra field")

  local bounded = fresh_node()
  bounded.signature.max_arity = 2
  assert_error_contains(function()
    linkedspec.project_user_function_definition_asts(source, json.array({ bounded }))
  end, "max_arity must be null", "bounded variadic maximum")

  local drifted = fresh_node()
  drifted.body_parse_job.signature.rest_param = "other"
  assert_error_contains(function()
    linkedspec.project_user_function_definition_asts(source, json.array({ drifted }))
  end, "body_parse_job signature does not match signature", "staged signature drift")

  local duplicate = linkedspec.parse_spec_with_user_function_definition_asts(
    source,
    json.array({ variadic_definition_node(source, "collect", { "items" }, "items", " return(items) ") })
  )
  local duplicate_ok, duplicate_error = pcall(linkedspec.validate_spec, duplicate)
  assert_equal(duplicate_ok, false, "duplicate rest rejected")
  assert_equal(linkedspec.is_spec_validation_error(duplicate_error), true, "duplicate rest type")
  assert_equal(duplicate_error.code, "duplicate_parameter", "duplicate rest code")

  local reserved_source = 'fn collect(prefix, ...return) { return(prefix) }\nTop::\n /x/\n'
  local reserved = linkedspec.parse_spec_with_user_function_definition_asts(
    reserved_source,
    json.array({
      variadic_definition_node(reserved_source, "collect", { "prefix" }, "return", " return(prefix) ")
    })
  )
  local reserved_ok, reserved_error = pcall(linkedspec.validate_spec, reserved)
  assert_equal(reserved_ok, false, "reserved rest rejected")
  assert_equal(linkedspec.is_spec_validation_error(reserved_error), true, "reserved rest type")
  assert_equal(reserved_error.code, "reserved_parameter", "reserved rest code")
end)

test("function shell preserves exact final codeblock parameter metadata", function()
  local source = table.concat({
    'fn apply(value, callback: codeblock) { return(value) }',
    "Top::",
    " /x/",
    "",
  }, "\n")
  local node = codeblock_definition_node(
    source,
    "apply",
    { "value" },
    "callback",
    " return(value) "
  )
  local projection = linkedspec.project_user_function_definition_asts(source, json.array({ node }))
  local definition = projection.functions[1]
  local projected = ast.to_json(definition)
  assert_equal(projected.params[1], "value", "codeblock fixed parameter")
  assert_equal(projected.params[2], "callback", "codeblock final parameter")
  assert_equal(projected.arity, 2, "codeblock exact arity")
  assert_equal(projected.parameter_kinds.callback, "codeblock", "definition parameter kind")
  assert_equal(projected.fixed_params, nil, "raw fixed params removed")
  assert_equal(projected.codeblock_param, nil, "raw codeblock param removed")
  for _, staged_name in ipairs({ "body_payload", "body_parse_job" }) do
    local staged = projected[staged_name]
    assert_equal(staged.params[2], "callback", staged_name .. " canonical params")
    assert_equal(staged.arity, 2, staged_name .. " canonical arity")
    assert_equal(staged.parameter_kinds.callback, "codeblock", staged_name .. " parameter kind")
    assert_equal(staged.fixed_params, nil, staged_name .. " raw fixed params removed")
    assert_equal(staged.codeblock_param, nil, staged_name .. " raw codeblock param removed")
  end
  local round_trip = ast.from_json("FunctionDefinition", projected)
  assert_equal(
    ast.parameter_kinds_equal(round_trip.parameter_kinds, definition.parameter_kinds),
    true,
    "codeblock metadata AST round-trip"
  )

  local staged = linkedspec.parse_spec_with_staged_user_function_definition_asts(
    source,
    json.array({ codeblock_definition_node(source, "apply", { "value" }, "callback", " return(value) ") })
  )
  assert_equal(linkedspec.validate_spec(staged), nil, "codeblock staged validation")
  assert_equal(staged.functions[1].body_parse_job.parameter_kinds.callback, "codeblock", "staged job metadata")
  local compiled = linkedspec.compile_spec(staged)
  local compiled_json = linkedspec.compiled_spec_to_json(compiled)
  assert_equal(
    compiled_json.functions_by_name.apply.parameter_kinds.callback,
    "codeblock",
    "compiled registry metadata"
  )
  local descriptor = linkedspec.to_descriptor_json(compiled)
  local descriptor_contract = json.decode(
    read_file("capability_conformance/outward_descriptor_contract.json")
  )
  local variant = descriptor_contract.function_record_variants.final_codeblock_v3
  assert_equal(
    table.concat(sorted_keys(descriptor.functions.apply), ","),
    table.concat(sorted_values(variant.record_fields), ","),
    "codeblock descriptor exact fields"
  )
  assert_equal(descriptor.functions.apply.version, variant.function_version, "codeblock descriptor version")
  assert_equal(
    json.encode(descriptor.functions.apply.parameter_kinds),
    json.encode(descriptor.functions.apply.body_parse_job.parameter_kinds),
    "codeblock descriptor staged parameter-kinds copy"
  )
end)

test("function shell rejects drifting and invalid codeblock declarations", function()
  local source = 'fn apply(value, callback: codeblock) { return(value) }\nTop::\n /x/\n'
  local function fresh_node()
    return codeblock_definition_node(source, "apply", { "value" }, "callback", " return(value) ")
  end

  local drifted = fresh_node()
  drifted.body_parse_job.parameter_kinds = json.harray({ value = "codeblock" })
  assert_error_contains(function()
    linkedspec.project_user_function_definition_asts(source, json.array({ drifted }))
  end, "must declare only the final parameter as codeblock", "codeblock sidecar drift")

  local cases = {
    {
      header = "fn bad(callback: codeblock, tail)",
      code = "codeblock_parameter_must_be_final",
    },
    {
      header = "fn bad(callback: codeblock(item))",
      code = "codeblock_declaration_has_no_argument_list",
    },
    {
      header = "fn bad(: codeblock)",
      code = "invalid_codeblock_parameter_name",
    },
    {
      header = "fn bad(callback: closure)",
      code = "unknown_parameter_type",
    },
  }
  for _, item in ipairs(cases) do
    local invalid_source = item.header .. "\nTop::\n /x/\n"
    local error_node = json.harray({
      type = "function_definition_error",
      kind = "user_function_definition_error",
      message = "invalid user function definition",
      source_text = item.header,
      source_span = definition_span(invalid_source, 0, utf8_character_count(item.header)),
    })
    local ok, parse_error = pcall(
      linkedspec.project_user_function_definition_asts,
      invalid_source,
      json.array({ error_node })
    )
    assert_equal(ok, false, item.code .. " rejects")
    assert_equal(linkedspec.is_spec_parse_error(parse_error), true, item.code .. " parse type")
    assert_contains(parse_error.message, item.code, item.code .. " diagnostic")
  end
end)

test("function shell projects spec-owned nodes with Unicode character spans", function()
  local source = table.concat({
    "# préface",
    'fn zero() {return("zero")}',
    "Top::",
    " /x/ -> Done { return(zero()) }",
    "",
    "Done:",
    " /[a-z]+/",
    "",
    "fn after(value) { return(value) }",
    "",
  }, "\n")
  local nodes = json.array({
    definition_node(source, "zero", {}, 'return("zero")'),
    definition_node(source, "after", { "value" }, " return(value) "),
  })

  local no_scan_ok, no_scan_error = pcall(
    linkedspec.parse_spec_with_user_function_definition_asts,
    source,
    json.array()
  )
  assert_equal(no_scan_ok, false, "no raw function scanner")
  assert_equal(linkedspec.is_spec_parse_error(no_scan_error), true, "no-scan parse error")

  local projection = linkedspec.project_user_function_definition_asts(source, nodes)
  assert_equal(#projection.functions, 2, "projected function count")
  assert_equal(projection.functions[1].name, "zero", "first function")
  assert_equal(projection.functions[2].name, "after", "second function")
  assert_contains(projection.stripped_source, "# préface", "Unicode source preservation")
  assert_contains(projection.stripped_source, "Top::", "rule source preservation")
  assert_equal(projection.stripped_source:find("fn zero", 1, true), nil, "function source stripped")
  local zero = projection.functions[1]
  assert_equal(zero.body_parse_job.parent_ast_path[2], "0", "normalized job path")
  assert_equal(zero.body_payload.parent_ast_path[2], "0", "normalized payload path")
  assert_contains(zero.body_parse_job.job_id, "functions.0.body_source", "normalized job id")
  assert_equal(zero.body_parse_job.version, 1, "job version")
  assert_equal(zero.body_ast, nil, "body AST stays undispatched")

  local parsed = linkedspec.parse_spec_with_user_function_definition_asts(source, nodes)
  assert_equal(#parsed.functions, 2, "composed functions")
  assert_equal(#parsed.rules, 2, "composed rules")
  assert_equal(linkedspec.validate_spec(parsed), nil, "composed validation")
end)

test("function shell rejects spec-produced error and drifting sidecars", function()
  local bad_source = "fn bad(value\nTop::\n /x/\n"
  local error_node = json.harray({
    type = "function_definition_error",
    kind = "user_function_definition_error",
    message = "invalid user function definition",
    source_text = "fn bad(value",
    source_span = definition_span(bad_source, 0, 12),
  })
  local error_ok, parse_error = pcall(
    linkedspec.project_user_function_definition_asts,
    bad_source,
    json.array({ error_node })
  )
  assert_equal(error_ok, false, "function error node rejection")
  assert_equal(linkedspec.is_spec_parse_error(parse_error), true, "function error parse type")
  assert_contains(parse_error.message, "parse error at line 1", "function error message")

  local source = 'fn zero() {return("zero")}\nTop::\n /x/\n'
  local node = definition_node(source, "zero", {}, 'return("zero")')
  node.body_parse_job.text = 'return("drift")'
  assert_error_contains(function()
    linkedspec.project_user_function_definition_asts(source, json.array({ node }))
  end, "body_parse_job text does not match body_source", "sidecar drift")
end)

test("function shell normalizes nested spec output shapes", function()
  local source = 'fn zero() {return("zero")}\nTop::\n /x/\n'
  local node = definition_node(source, "zero", {}, 'return("zero")')
  local direct = linkedspec.definition_nodes_from_user_function_definition_output(node)
  assert_equal(#direct, 1, "direct output shape")
  local wrapped = linkedspec.definition_nodes_from_user_function_definition_output(
    json.array({ json.array({ node }) })
  )
  assert_equal(#wrapped, 1, "nested output shape")
  assert_equal(wrapped[1].name, "zero", "nested output node")
  assert_error_contains(function()
    linkedspec.definition_nodes_from_user_function_definition_output("invalid")
  end, "unsupported output shape", "unsupported output")
end)

test("spec-defined function parser automatically composes Unicode function shells", function()
  local source = table.concat({
    "# préface λ",
    'fn pair(left, right) { return([left, right]) }',
    'fn collect(prefix, ...items) { return(items) }',
    'fn apply(value, callback: codeblock) { return(value) }',
    "Top::",
    " /x/",
    "",
  }, "\n")

  local before = linkedspec.user_function_definition_parser_metadata()
  local nodes = linkedspec.parse_user_function_definition_asts(source)
  local after = linkedspec.user_function_definition_parser_metadata()
  assert_equal(before.type, "user_function_definition_ast_parser", "parser metadata type")
  assert_equal(before.spec_name, "user_function_definition.spec", "parser spec identity")
  assert_equal(before.spec_origin, "path_exact", "module-relative exact resolution")
  assert_contains(before.spec_path, "specs/user_function_definition.spec", "bundled spec path")
  assert_equal(before.top_rule, "user_function_definitions", "parser top rule")
  assert_equal(before.build_count, 1, "single initial parser build")
  assert_equal(after.build_count, 1, "compiled parser cache reuse")

  assert_equal(#nodes, 3, "automatic function node count")
  assert_equal(nodes[1].name, "pair", "fixed function order")
  assert_equal(nodes[1].source_span.line_start, 2, "Unicode-prefixed source line")
  assert_equal(nodes[2].signature.rest_param, "items", "variadic signature")
  assert_equal(nodes[3].codeblock_param, "callback", "codeblock signature")

  local staged = linkedspec.parse_spec_with_staged_user_function_definitions(source)
  assert_equal(#staged.functions, 3, "automatic composed function count")
  assert_equal(#staged.rules, 1, "automatic composed rule count")
  assert_equal(staged.functions[1].body_ast.kind, "action_block", "fixed body dispatch")
  assert_equal(staged.functions[2].body_ast.kind, "action_block", "variadic body dispatch")
  assert_equal(staged.functions[3].body_ast.kind, "action_block", "codeblock body dispatch")
  assert_equal(linkedspec.validate_spec(staged), nil, "automatic composed validation")
  assert_equal(
    linkedspec.user_function_definition_parser_metadata().build_count,
    1,
    "composed parse reuses compiled parser"
  )
end)

test("spec-defined function parser preserves typed failure ownership", function()
  local parse_ok, parse_error = pcall(
    linkedspec.user_function_definition_ast_parser_from_spec_source,
    "fn invalid() { return(undef) }\nTop::\n /x/\n"
  )
  assert_equal(parse_ok, false, "parser-spec parse rejection")
  assert_equal(linkedspec.is_user_function_definition_parser_error(parse_error), true, "parser parse type")
  assert_equal(parse_error.stage, "parse_parser_spec", "parser parse stage")

  local validation_ok, validation_error = pcall(
    linkedspec.user_function_definition_ast_parser_from_spec_source,
    "Only:\n /x/\n"
  )
  assert_equal(validation_ok, false, "parser-spec validation rejection")
  assert_equal(
    linkedspec.is_user_function_definition_parser_error(validation_error),
    true,
    "parser validation type"
  )
  assert_equal(validation_error.stage, "validate_parser_spec", "parser validation stage")

  local execution_parser = linkedspec.user_function_definition_ast_parser_from_spec_source([[
user_function_definitions::
 I { return(no_such_helper()) }
]])
  local execution_ok, execution_error = pcall(
    linkedspec.parse_user_function_definition_asts,
    "Top::\n /x/\n",
    execution_parser
  )
  assert_equal(execution_ok, false, "parser execution rejection")
  assert_equal(
    linkedspec.is_user_function_definition_parser_error(execution_error),
    true,
    "parser execution type"
  )
  assert_equal(execution_error.stage, "execute_parser_spec", "parser execution stage")

  local output_parser = linkedspec.user_function_definition_ast_parser_from_spec_source([[
user_function_definitions::
 I { return("unsupported") }
]])
  local output_ok, output_error = pcall(
    linkedspec.parse_user_function_definition_asts,
    "Top::\n /x/\n",
    output_parser
  )
  assert_equal(output_ok, false, "parser output-shape rejection")
  assert_equal(linkedspec.is_user_function_definition_parser_error(output_error), true, "parser output type")
  assert_equal(output_error.stage, "normalize_output", "parser output stage")

  local projection_ok, projection_error = pcall(
    linkedspec.parse_spec_with_staged_user_function_definitions,
    "fn bad(value\nTop::\n /x/\n"
  )
  assert_equal(projection_ok, false, "projection rejection")
  assert_equal(linkedspec.is_spec_parse_error(projection_error), true, "projection typed owner")

  local _, staged_sentinel = pcall(
    linkedspec.execute_staged_parse_jobs,
    { json.harray() }
  )
  assert_equal(
    linkedspec.is_staged_parser_registry_error(staged_sentinel),
    true,
    "staged sentinel type"
  )
  local staged_registry = linkedspec.staged_parser_registry
  local original_dispatch = staged_registry.parse_spec_with_staged_user_function_definition_asts
  staged_registry.parse_spec_with_staged_user_function_definition_asts = function()
    error(staged_sentinel, 0)
  end
  local staged_ok, staged_error = pcall(
    linkedspec.parse_spec_with_staged_user_function_definitions,
    "Top::\n /x/\n"
  )
  staged_registry.parse_spec_with_staged_user_function_definition_asts = original_dispatch
  assert_equal(staged_ok, false, "staged body rejection")
  assert_equal(linkedspec.is_staged_parser_registry_error(staged_error), true, "staged typed owner")
end)

test("function shell rejects overlapping source spans", function()
  local source = 'fn zero() {return("zero")}\nTop::\n /x/\n'
  local node = definition_node(source, "zero", {}, 'return("zero")')
  assert_error_contains(function()
    linkedspec.project_user_function_definition_asts(source, json.array({ node, node }))
  end, "function definition spans overlap", "overlapping functions")
end)

test("ActionIR blocks use newline and same-line semicolon separators", function()
  local block = linkedspec.parse_action_block(
    'set(results, []); push(results, retv)\nreturn(copy(results))'
  )
  assert_equal(linkedspec.action_ast.node_type(block), "ActionBlock", "block type")
  assert_equal(#block.statements, 3, "statement count")
  assert_equal(block.statements[1].expr.name, "set", "first helper")
  assert_equal(block.statements[2].expr.name, "push", "same-line second helper")
  assert_equal(block.statements[3].expr.name, "return", "newline helper")
  for _, statement in ipairs(block.statements) do
    assert_equal(statement.drops_value, true, "statement value drop")
  end

  local newline_only = linkedspec.parse_action_block("first()\nsecond()\nthird()")
  assert_equal(#newline_only.statements, 3, "newline-only statements")
  assert_equal(newline_only.statements[3].source, "third()", "no trailing separator")

  local portable_newlines = linkedspec.parse_action_block("first()\r\nsecond()\rthird()")
  assert_equal(#portable_newlines.statements, 3, "CRLF and CR statements")
  assert_equal(portable_newlines.statements[2].source, "second()", "CR-delimited statement")
end)

test("ActionIR parses literals and all four LinkedSpec value kinds", function()
  local scalar = linkedspec.parse_action_expression("42.5")
  assert_equal(scalar.kind, "number", "scalar kind")
  assert_equal(scalar.value, 42.5, "decimal value")
  assert_equal(linkedspec.parse_action_expression("true").kind, "boolean", "boolean kind")
  assert_equal(linkedspec.parse_action_expression("undef").kind, "undef", "undef kind")

  local regex = linkedspec.parse_action_expression("/a\\\\sb/i")
  assert_equal(regex.kind, "regex", "regex kind")
  assert_equal(regex.pattern, "a\\\\sb", "regex payload")
  assert_equal(regex.flags, "i", "regex flags")

  local single_quoted = linkedspec.parse_action_expression([['"|\s']])
  assert_equal(single_quoted.kind, "string", "single-quoted kind")
  assert_equal(single_quoted.value, '"|\\s', "single-quoted value")
  assert_equal(single_quoted.quote, "'", "single-quote provenance")
  local substr_call = linkedspec.parse_action_expression([[substr(value, '"|\s', "", go)]])
  assert_equal(substr_call.kind, "call", "single-quoted helper call")
  assert_equal(substr_call.args[2].value.value, '"|\\s', "single-quoted helper argument")

  local array = linkedspec.parse_action_expression("[value, true, []]")
  assert_equal(array.kind, "array_literal", "array kind")
  assert_equal(#array.items, 3, "array item count")
  local harray = linkedspec.parse_action_expression('{ key : value, "fixed" : [value] }')
  assert_equal(harray.kind, "hash_literal", "harray kind")
  assert_equal(#harray.entries, 2, "harray entry count")
  local codeblock = linkedspec.parse_action_expression('{ set(x, "a"); x }')
  assert_equal(codeblock.kind, "block_value", "codeblock kind")
  assert_equal(#codeblock.block.statements, 2, "codeblock statement count")
end)

test("ActionIR parses access assignments nested calls and keyword arguments", function()
  local access = linkedspec.parse_action_expression('foo["a"][i][0]')
  assert_equal(access.kind, "nested_access", "nested access kind")
  assert_equal(access.base, "foo", "nested access base")
  assert_equal(#access.segments, 3, "nested access depth")
  assert_equal(access.segments[1].kind, "key", "key segment")
  assert_equal(access.segments[2].kind, "index", "index segment")

  assert_equal(linkedspec.parse_action_expression("items = [value]").kind, "assign_scalar", "scalar assignment")
  assert_equal(linkedspec.parse_action_expression("items += value").kind, "assign_array_append", "append assignment")
  assert_equal(
    linkedspec.parse_action_expression("meta[key] = { stage : value }").kind,
    "assign_hash_index",
    "hash assignment"
  )
  assert_equal(
    linkedspec.parse_action_expression('payload["children"][0]["name"] = value').kind,
    "assign_nested_access",
    "nested assignment"
  )

  local nested_call = linkedspec.parse_action_expression("array(items = [value], copy(items))")
  assert_equal(nested_call.kind, "call", "nested call kind")
  assert_equal(nested_call.args[1].value.kind, "assign_scalar", "assignment argument")
  assert_equal(nested_call.args[2].value.kind, "call", "nested call argument")
  local assignment_arg = linkedspec.parse_action_expression("helper(value, option=true)")
  assert_equal(assignment_arg.args[2].argument_kind, "positional", "assignment argument role")
  assert_equal(assignment_arg.args[2].value.kind, "assign_scalar", "assignment argument value")
  local keyword = linkedspec.action_ast.keyword_argument("option", assignment_arg.args[1].value)
  assert_equal(linkedspec.action_ast.node_type(keyword), "ActionArgument", "typed keyword argument")
  assert_equal(keyword.argument_kind, "keyword", "keyword constructor role")
  assert_equal(keyword.name, "option", "keyword constructor name")
end)

test("ActionIR final codeblock syntax is generic and structurally equivalent", function()
  local trailing = linkedspec.parse_action_expression("func_helper_method(value) { return(value) }")
  local explicit = linkedspec.parse_action_expression("func_helper_method(value, { return(value) })")
  assert_equal(trailing.kind, "call", "trailing helper kind")
  assert_equal(trailing.trailing_block_arg, true, "trailing helper marker")
  assert_equal(#trailing.args, #explicit.args, "equivalent argument count")
  assert_equal(trailing.args[#trailing.args].value.kind, "block_value", "trailing final argument")
  assert_equal(explicit.args[#explicit.args].value.kind, "block_value", "explicit final argument")
  assert_equal(
    trailing.args[#trailing.args].value.block.statements[1].expr.name,
    explicit.args[#explicit.args].value.block.statements[1].expr.name,
    "equivalent codeblock body"
  )

  local receiver = linkedspec.parse_action_expression('"x".func_helper_method() { return(value) }')
  local explicit_receiver = linkedspec.parse_action_expression('"x".func_helper_method({ return(value) })')
  assert_equal(receiver.kind, "fluent_chain", "receiver chain kind")
  assert_equal(receiver.calls[1].method, "func_helper_method", "generic receiver method")
  assert_equal(receiver.calls[1].receiver_trailing_block_arg, true, "receiver trailing marker")
  assert_equal(receiver.calls[1].args[1].value.kind, "block_value", "receiver final argument")
  assert_equal(#receiver.calls[1].args, #explicit_receiver.calls[1].args, "receiver equivalent argument count")
  assert_equal(explicit_receiver.calls[1].args[1].value.kind, "block_value", "explicit receiver final argument")

  local chain = linkedspec.parse_action_expression('(items += value).count()')
  assert_equal(chain.receiver.kind, "assign_array_append", "assignment receiver")
  assert_equal(chain.calls[1].method, "count", "receiver method")
end)

test("ActionIR parses attached controls and preserves unsupported structure", function()
  local branches = linkedspec.parse_action_block(
    'if(false) { set(out, "bad") } elseif(true) { set(out, "yes") } else { set(out, "no") }'
  )
  assert_equal(#branches.statements, 3, "branch count")
  assert_equal(branches.statements[1].expr.kind, "control_if", "if kind")
  assert_equal(branches.statements[2].expr.branch_role, "elseif", "elseif role")
  assert_equal(branches.statements[3].expr.kind, "control_else", "else kind")

  local while_node = linkedspec.parse_action_expression("while(flag) { next() }")
  assert_equal(while_node.kind, "control_while", "while kind")
  local switch_node = linkedspec.parse_action_expression(
    'switch(kind) { case("a") { return("hit") } default { return("miss") } }'
  )
  assert_equal(switch_node.kind, "control_switch", "switch kind")
  assert_equal(#switch_node.cases, 1, "case count")
  assert_equal(switch_node.default.kind, "control_default", "default kind")

  local raw = linkedspec.parse_action_expression("@invalid")
  assert_equal(raw.kind, "raw_perl", "raw structural kind")
  assert_equal(raw.reason, "unsupported_expression", "raw reason")
end)

test("ActionIR uses Unicode character spans and typed JSON projection", function()
  local chain = linkedspec.parse_action_expression('"é".trim()')
  assert_equal(chain.source_span.start, 0, "Unicode chain start")
  assert_equal(chain.source_span["end"], 10, "Unicode chain end")
  assert_equal(chain.receiver.source_span["end"], 3, "Unicode receiver end")
  local projected = linkedspec.action_ast.to_json(chain)
  assert_equal(json.kind(projected), "harray", "projected node kind")
  assert_equal(json.kind(projected.calls), "array", "projected list kind")
  assert_equal(json.decode(json.encode(projected)).kind, "fluent_chain", "projected JSON round-trip")

  assert_error_contains(function()
    linkedspec.parse_action_expression(string.char(0xC3))
  end, "not valid UTF-8", "invalid ActionIR UTF-8")
end)

test("ActionIR contracts resolve canonical helpers through nested nodes", function()
  local block = linkedspec.parse_action_block(table.concat({
    "set(out, +(1, 2))",
    'if(gt(out, 0)) { return(cat("ok", out)) }',
    '" x ".trim().with() { return(value) }',
  }, "\n"))
  local resolution = linkedspec.resolve_action_block_contracts(block)
  assert_equal(resolution.ok, true, "nested contract result")

  local by_source = {}
  for _, contract in ipairs(resolution.contracts) do
    by_source[contract.source_name] = contract
  end
  assert_equal(by_source.set.canonical_name, "set", "set contract")
  assert_equal(by_source["+"].canonical_name, "num_add", "numeric symbol canonicalization")
  assert_equal(by_source["+"].family, "numeric", "numeric family")
  assert_equal(linkedspec.action_contracts.canonicalized(by_source["+"]), true, "numeric canonicalized")
  assert_equal(by_source.gt.canonical_name, "num_gt", "numeric word canonicalization")
  assert_equal(by_source.gt.positional_arg_count, 2, "numeric argument count")
  assert_equal(by_source["if"].surface, "control", "control surface")
  assert_equal(by_source.trim.surface, "receiver_method", "receiver surface")
  assert_equal(by_source.with.family, "control", "trailing block family")
  assert_equal(#resolution.diagnostics, 0, "nested diagnostics")
end)

test("ActionIR contracts map structural assignments and current equals alias", function()
  local block = linkedspec.parse_action_block(
    'name = "ok"; items += name; meta[name] = [name]; ' ..
    'payload["children"][0]["name"] = name; =(other, "value")'
  )
  local resolution = linkedspec.resolve_action_block_contracts(block)
  assert_equal(resolution.ok, true, "assignment contract result")

  local canonical = {}
  for _, contract in ipairs(resolution.contracts) do
    canonical[contract.source_name] = contract.canonical_name
  end
  assert_equal(canonical["="], "set", "scalar assignment contract")
  assert_equal(canonical["+="], "push", "append assignment contract")
  assert_equal(canonical["[]="], "set_key", "hash assignment contract")
  assert_equal(canonical["nested_access="], "nested_access_assignment", "nested assignment contract")

  local equals_call
  for _, contract in ipairs(resolution.contracts) do
    if contract.source_name == "=" and contract.surface == "function" then
      equals_call = contract
    end
  end
  assert_equal(equals_call.canonical_name, "set", "equals helper alias")
  assert_equal(equals_call.positional_arg_count, 2, "equals helper arity")
end)

test("ActionIR contracts diagnose unknown helpers and raw fallback", function()
  local block = linkedspec.parse_action_block("mystery_helper(value); @invalid")
  local resolution = linkedspec.resolve_action_block_contracts(block)
  assert_equal(resolution.ok, false, "diagnostic result")
  assert_equal(#resolution.contracts, 0, "diagnostic contract count")
  assert_equal(#resolution.diagnostics, 2, "diagnostic count")
  assert_equal(resolution.diagnostics[1].code, "unknown_helper", "unknown diagnostic")
  assert_equal(resolution.diagnostics[1].helper_name, "mystery_helper", "unknown helper name")
  assert_equal(resolution.diagnostics[2].code, "raw_perl", "raw diagnostic")
  assert_contains(resolution.diagnostics[1].message, "canonical ActionIR helper contract", "generic diagnostic")
end)

test("ActionIR contracts share the exact current names and typed JSON", function()
  assert_equal(linkedspec.is_known_action_ir_call_name("cat"), true, "known string helper")
  assert_equal(linkedspec.is_known_action_ir_call_name("push_back"), true, "known array helper")
  assert_equal(linkedspec.is_known_action_ir_call_name("sorted_keys"), true, "known hash helper")
  assert_equal(linkedspec.is_known_action_ir_call_name("capture_until_boundary"), true, "known capture helper")
  assert_equal(linkedspec.is_known_action_ir_call_name("save_cursor"), true, "known runtime helper")
  assert_equal(linkedspec.is_known_action_ir_call_name("BACKTRACK"), false, "retired control")
  assert_equal(linkedspec.is_known_action_ir_call_name("mystery_helper"), false, "unknown name")
  assert_equal(linkedspec.canonical_action_helper_name(">="), "num_ge", "comparison alias")

  local resolution = linkedspec.resolve_action_expression_contracts(
    linkedspec.parse_action_expression("gt(value, 0)")
  )
  local projected = linkedspec.action_contracts.to_json(resolution)
  assert_equal(json.kind(projected), "harray", "contract JSON object")
  assert_equal(json.kind(projected.contracts), "array", "contract JSON list")
  assert_equal(projected.contracts[1].canonical_name, "num_gt", "contract JSON canonical name")
  assert_equal(projected.contracts[1].canonicalized, true, "contract JSON canonicalized")
  assert_equal(json.decode(json.encode(projected)).ok, true, "contract JSON round-trip")
end)

test("ActionIR contracts resolve registered functions before helper fallback", function()
  local registry = {
    resolve_call = function(_, name, arity)
      if name ~= "normalize" then
        return nil
      elseif arity == 2 then
        return { matched = true, arity_mismatch = false, expected_arities = { 2 } }
      end
      return { matched = false, arity_mismatch = true, expected_arities = { 2 } }
    end,
  }
  local block = linkedspec.parse_action_block(table.concat({
    'normalize("x") { return(value) }',
    'normalize("x")',
    'mystery("z")',
  }, "\n"))
  local resolution = linkedspec.resolve_action_block_contracts(block, { function_registry = registry })

  local normalize_contracts = {}
  for _, contract in ipairs(resolution.contracts) do
    if contract.source_name == "normalize" then
      normalize_contracts[#normalize_contracts + 1] = contract
    end
  end
  assert_equal(#normalize_contracts, 1, "matched user contract count")
  assert_equal(normalize_contracts[1].family, "user_function", "user function family")
  assert_equal(normalize_contracts[1].positional_arg_count, 2, "final codeblock counts as argument")
  assert_equal(resolution.diagnostics[1].code, "user_function_arity_mismatch", "user arity diagnostic")
  assert_contains(resolution.diagnostics[1].message, "expects arity 2, got 1", "user arity message")
  assert_equal(resolution.diagnostics[2].code, "unknown_helper", "post-registry unknown helper")

  assert_error_contains(function()
    linkedspec.resolve_action_expression_contracts(
      linkedspec.parse_action_expression("normalize(value)"),
      { function_registry = {} }
    )
  end, "must expose resolve_call", "registry interface")
end)

local function registry_function(name, params, index, body_ast, body_source_override, signature, parameter_kinds)
  local body_source = body_source_override or "return(value)"
  local path = { "functions", tostring(index), "body_source" }
  local payload = json.harray({
    kind = "staged_payload",
    node_kind = "function_definition",
    payload_kind = "function_body",
    parent_ast_path = json.array(path),
    function_name = name,
    text = body_source,
  })
  local job_options = {
    version = 1,
    job_id = "parse_job:function_body:functions." .. index .. ".body_source",
    parent_ast_path = path,
    node_kind = "function_definition",
    payload_kind = "function_body",
    function_name = name,
    text = body_source,
    source_span = ast.staged_source_span({ start = 0, ["end"] = #body_source, line_start = 1, line_end = 1 }),
    parser_spec_id = "actionir-body.spec",
    top_rule = "action_block",
    result_policy = "replace_field",
    result_field = "body_ast",
    failure_policy = "fail",
    diagnostic_owner = "function_body",
  }
  if signature == nil then
    payload.params = json.array(params)
    payload.arity = #params
    job_options.params = params
    job_options.arity = #params
    if parameter_kinds ~= nil then
      payload.parameter_kinds = json.decode(json.encode(parameter_kinds))
      job_options.parameter_kinds = parameter_kinds
    end
  else
    payload.signature = ast.to_json(signature)
    job_options.signature = signature
  end
  local source_params = table.concat(params, ", ")
  if signature ~= nil then
    source_params = source_params == "" and ("..." .. signature.rest_param) or
      (source_params .. ", ..." .. signature.rest_param)
  end
  return ast.function_definition({
    name = name,
    params = params,
    arity = #params,
    signature = signature,
    parameter_kinds = parameter_kinds,
    body_source = body_source,
    body_payload = payload,
    body_parse_job = ast.staged_parse_job(job_options),
    body_ast = body_ast,
    source = "fn " .. name .. "(" .. source_params .. ") { " .. body_source .. " }",
    source_span = ast.source_span({ line_start = 1, line_end = 1 }),
    body_span = ast.source_span({ line_start = 1, line_end = 1 }),
  })
end

local function variadic_registry_function(name, positional_params, rest_param, index, body_ast, body_source)
  local signature = ast.callable_signature({
    kind = "callable_signature",
    version = 1,
    positional_params = positional_params,
    rest_param = rest_param,
    min_arity = #positional_params,
    max_arity = nil,
  })
  return registry_function(
    name,
    positional_params,
    index,
    body_ast,
    body_source,
    signature
  )
end

local function assert_registry_error(operation, expected, code, label)
  local ok, registry_error = pcall(operation)
  if ok then fail((label or "registry") .. ": expected an error") end
  assert_equal(
    linkedspec.user_function_registry.is_registry_error(registry_error),
    true,
    (label or "registry") .. " type"
  )
  assert_contains(registry_error.message, expected, label)
  if code then assert_equal(registry_error.code, code, (label or "registry") .. " code") end
  return registry_error
end

test("user function registry preserves order jobs definitions and exact arity", function()
  local body_ast = json.harray({ kind = "action_block", statements = json.array() })
  local zero = registry_function("zero", {}, 0, body_ast)
  local normalize = registry_function("normalize", { "value" }, 1)
  local registry = linkedspec.user_function_registry_from_functions({ zero, normalize })
  zero.body_source = "mutated_after_registry"

  assert_equal(linkedspec.user_function_registry.node_type(registry), "UserFunctionRegistry", "registry type")
  assert_equal(table.concat(registry:names(), ","), "zero,normalize", "registry order")
  assert_equal(#registry:body_parse_jobs(), 2, "body job count")
  assert_equal(registry:body_parse_jobs()[2].function_name, "normalize", "body job order")
  assert_equal(registry:has_name("zero"), true, "known function")
  assert_equal(registry:has_name("missing"), false, "missing function")

  local exact = registry:resolve_call("zero", 0)
  assert_equal(exact.matched, true, "exact match")
  assert_equal(exact.entry.index, 0, "zero-based entry index")
  assert_equal(exact.entry.definition.body_ast.kind, "action_block", "body AST preservation")
  assert_equal(exact.entry.definition.body_source, "return(value)", "definition snapshot")
  local mismatch = registry:resolve_call("normalize", 2)
  assert_equal(mismatch.name_known, true, "known mismatch")
  assert_equal(mismatch.arity_mismatch, true, "arity mismatch")
  assert_equal(mismatch.expected_arities[1], 1, "expected arity")
  assert_equal(registry:resolve_call("missing", 0).name_known, false, "missing resolution")

  local projected = linkedspec.user_function_registry.to_json(registry)
  assert_equal(json.kind(projected.functions), "array", "registry JSON functions")
  assert_equal(projected.functions[1].index, 0, "registry JSON index")
  assert_equal(json.kind(projected.body_parse_jobs), "array", "registry JSON jobs")
  local descriptor = linkedspec.user_function_registry.to_descriptor_json(exact.entry)
  assert_equal(descriptor.kind, "user_function_definition", "descriptor kind")
  assert_equal(descriptor.source_text, zero.source, "descriptor source")

  assert_registry_error(function()
    linkedspec.user_function_registry_from_functions({ zero, zero })
  end, "duplicate user function 'zero'", nil, "duplicate registry")
end)

test("registered final codeblock calls normalize contextual spellings without promoting harrays", function()
  local parameter_kinds = json.harray({ callback = "codeblock" })
  local apply = registry_function(
    "apply",
    { "value", "callback" },
    0,
    json.harray({ kind = "action_block", statements = json.array() }),
    "return(value)",
    nil,
    parameter_kinds
  )
  local registry = linkedspec.user_function_registry_from_functions({ apply })
  local entry = registry:lookup("apply")
  local contract = linkedspec.action_contracts.user_function_final_codeblock_contract(entry.definition)
  assert_equal(contract.min_before_codeblock, 1, "user codeblock minimum prefix")
  assert_equal(contract.max_before_codeblock, 1, "user codeblock maximum prefix")
  assert_equal(contract.final_parameter.name, "callback", "user codeblock final name")
  assert_equal(contract.final_parameter.kind, "codeblock", "user codeblock final kind")

  local attached_source = 'apply("x") { return(value) }'
  local parenthesized_source = 'apply("x", { return(value) })'
  local attached = linkedspec.parse_action_expression(attached_source)
  local parenthesized = linkedspec.parse_action_expression(parenthesized_source)
  local normalized_attached = linkedspec.action_contracts.normalize_contextual_codeblock_call(
    "function",
    attached,
    registry
  )
  local normalized_parenthesized = linkedspec.action_contracts.normalize_contextual_codeblock_call(
    "function",
    parenthesized,
    registry
  )
  local attached_argument = normalized_attached.args[2].value
  local parenthesized_argument = normalized_parenthesized.args[2].value
  for label, argument in pairs({
    attached = attached_argument,
    parenthesized = parenthesized_argument,
  }) do
    assert_equal(argument.kind, "codeblock_argument", label .. " normalized kind")
    assert_equal(argument.version, 1, label .. " normalized version")
    assert_equal(argument.signature.kind, "callable_signature", label .. " signature kind")
    assert_equal(#argument.signature.positional_params, 0, label .. " zero positional signature")
    assert_equal(argument.signature.min_arity, 0, label .. " minimum arity")
    assert_equal(argument.signature.max_arity, 0, label .. " maximum arity")
    assert_equal(argument.body_ast.statements[1].expr.name, "return", label .. " body AST")
  end
  assert_equal(attached_argument.body_source, parenthesized_argument.body_source, "equivalent body source")
  assert_equal(attached.args[2].value.kind, "block_value", "attached source AST remains structural")
  assert_equal(parenthesized.args[2].value.kind, "block_value", "parenthesized source AST remains structural")
  assert_equal(normalized_attached.contextual_codeblock_arg, true, "attached contextual marker")
  assert_equal(normalized_parenthesized.contextual_codeblock_arg, true, "parenthesized contextual marker")

  local harray_call = linkedspec.parse_action_expression('apply("x", { "value" : value })')
  local normalized_harray = linkedspec.action_contracts.normalize_contextual_codeblock_call(
    "function",
    harray_call,
    registry
  )
  assert_equal(normalized_harray.args[2].value.kind, "hash_literal", "harray is never promoted")
  assert_equal(normalized_harray.contextual_codeblock_arg, nil, "harray has no contextual marker")

  local resolution = linkedspec.resolve_action_expression_contracts(attached, { function_registry = registry })
  assert_equal(resolution.ok, true, "normalized registered contract resolves")
  assert_equal(resolution.contracts[1].family, "user_function", "normalized user contract family")
  local projected = linkedspec.action_ast.to_json(normalized_attached)
  assert_equal(projected.args[2].kind, "codeblock_argument", "normalized ActionIR JSON kind")
  assert_equal(projected.args[2].signature.rest_param, json.null, "contextual rest parameter absent")
end)

test("user function registry resolves variadic arity and binds fresh typed rest arrays", function()
  local body_ast = json.harray({ kind = "action_block", statements = json.array() })
  local all_values = variadic_registry_function(
    "all_values",
    {},
    "items",
    0,
    body_ast,
    "return(items)"
  )
  local collect = variadic_registry_function(
    "collect",
    { "prefix" },
    "items",
    1,
    body_ast,
    "return(items)"
  )
  local registry = linkedspec.user_function_registry_from_functions({ all_values, collect })

  assert_equal(registry:resolve_call("all_values", 0).matched, true, "zero-rest minimum")
  assert_equal(registry:resolve_call("all_values", 4).matched, true, "zero-rest unbounded")
  assert_equal(registry:resolve_call("collect", 1).matched, true, "prefix empty rest")
  assert_equal(registry:resolve_call("collect", 5).matched, true, "prefix unbounded rest")
  local missing = registry:resolve_call("collect", 0)
  assert_equal(missing.arity_mismatch, true, "variadic missing prefix")
  assert_equal(missing.expected_arities[1], 1, "variadic numeric minimum")
  assert_equal(missing.expected_arity_descriptions[1], "at least 1", "variadic arity description")

  local accepted = linkedspec.resolve_action_expression_contracts(
    linkedspec.parse_action_expression('collect("p", "a", "b")'),
    { function_registry = registry }
  )
  assert_equal(accepted.ok, true, "variadic positional contract")
  assert_equal(accepted.contracts[1].family, "user_function", "variadic contract family")
  local rejected = linkedspec.resolve_action_expression_contracts(
    linkedspec.parse_action_expression("collect()"),
    { function_registry = registry }
  )
  assert_equal(rejected.diagnostics[1].code, "user_function_arity_mismatch", "variadic minimum code")
  assert_contains(rejected.diagnostics[1].message, "expects arity at least 1", "variadic minimum message")

  local source_array = json.array({ 2, json.harray({ nested = true }) })
  local source_harray = json.harray({ key = json.array({ 3 }) })
  local source_block = linkedspec.parse_action_expression('{ return("callback") }')
  local frame = linkedspec.prepare_user_function_invocation(
    registry,
    "collect",
    { "p", 1, source_array, source_harray, false, json.null, source_block }
  )
  assert_equal(frame.variables.prefix, "p", "variadic fixed-prefix binding")
  assert_equal(json.kind(frame.variables.items), "array", "variadic scalar-view rest kind")
  assert_equal(json.kind(frame.arrays.items), "array", "variadic typed rest store")
  assert_equal(#frame.variables.items, 6, "variadic rest count")
  assert_equal(frame.variables.items[1], 1, "variadic ordered scalar")
  assert_equal(json.kind(frame.variables.items[2]), "array", "variadic nested array identity")
  assert_equal(json.kind(frame.variables.items[3]), "harray", "variadic harray identity")
  assert_equal(frame.variables.items[4], false, "variadic boolean identity")
  assert_equal(frame.variables.items[5], json.null, "variadic null identity")
  assert_equal(
    linkedspec.runtime_value_kind(frame.variables.items[6]),
    "codeblock",
    "variadic codeblock identity"
  )
  assert_equal(#frame.arguments, 7, "variadic frame retains every argument")

  frame.variables.items[2][1] = 99
  frame.variables.items[3].key[1] = 99
  frame.variables.items[6].kind = "mutated"
  assert_equal(source_array[1], 2, "variadic caller array isolation")
  assert_equal(source_harray.key[1], 3, "variadic caller harray isolation")
  assert_equal(source_block.kind, "block_value", "variadic caller codeblock isolation")
  assert_equal(frame.arrays.items[2][1], 2, "variadic typed store isolation")

  local first_empty = linkedspec.prepare_user_function_invocation(registry, "all_values", {})
  local second_empty = linkedspec.prepare_user_function_invocation(registry, "all_values", {})
  first_empty.variables.items[1] = "changed"
  assert_equal(#second_empty.variables.items, 0, "variadic empty rest freshness")
end)

test("user function registry stitches body AST without mutating the source spec", function()
  local definition = registry_function("normalize", { "value" }, 0)
  local spec = spec_with_functions({ definition })
  local body_ast = json.harray({
    kind = "action_block",
    statements = json.array({ json.harray({ kind = "action_stmt" }) }),
  })
  local stitched = linkedspec.stitch_function_body_ast(
    spec,
    "parse_job:function_body:functions.0.body_source",
    body_ast
  )
  assert_equal(spec.functions[1].body_ast, nil, "source spec unchanged")
  assert_equal(stitched.functions[1].body_ast.kind, "action_block", "stitched body AST")
  body_ast.kind = "mutated"
  assert_equal(stitched.functions[1].body_ast.kind, "action_block", "stitched defensive copy")
  assert_equal(stitched.rules[1].header.label, "Top", "rules preserved")

  local registry = linkedspec.user_function_registry_from_spec(stitched)
  local resolution = linkedspec.resolve_action_expression_contracts(
    linkedspec.parse_action_expression("normalize(value)"),
    { function_registry = registry }
  )
  assert_equal(resolution.ok, true, "concrete registry contract result")
  assert_equal(resolution.contracts[1].family, "user_function", "concrete registry precedence")

  assert_registry_error(function()
    linkedspec.stitch_function_body_ast(spec, "missing-job", json.harray({ kind = "action_block" }))
  end, "not found", nil, "missing stitch job")
end)

test("staged parser registry orders dispatches stitches and diagnoses sidecar drift", function()
  local later = registry_function("later", {}, 1, nil, 'return("b")')
  local earlier = registry_function("earlier", {}, 0, nil, 'return("a")')
  local results = linkedspec.execute_staged_parse_jobs({
    later.body_parse_job,
    earlier.body_parse_job,
  })

  assert_equal(#results, 2, "staged result count")
  assert_equal(results[1].queue_index, 0, "staged first queue index")
  assert_equal(results[1].job.job_id, earlier.body_parse_job.job_id, "staged path ordering")
  assert_equal(results[2].job.job_id, later.body_parse_job.job_id, "staged later ordering")
  local encoded = linkedspec.staged_parser_registry_to_json(results[1])
  assert_equal(encoded.kind, "staged_parse_result", "staged result kind")
  assert_equal(encoded.resolved_spec_id, linkedspec.ACTION_IR_BODY_RESOLVED_SPEC_ID, "resolved spec")
  assert_equal(encoded.registry_provider, "builtin", "registry provider")
  assert_equal(encoded.compiled_parser.top_rule, linkedspec.ACTION_IR_BODY_TOP_RULE, "compiled top rule")
  assert_equal(encoded.cache_key.content_digest, linkedspec.ACTION_IR_BODY_ADAPTER_DIGEST, "adapter digest")
  assert_equal(
    encoded.cache_key.fingerprint,
    table.concat({
      linkedspec.ACTION_IR_BODY_RESOLVED_SPEC_ID,
      linkedspec.ACTION_IR_BODY_ADAPTER_DIGEST,
      "none",
      linkedspec.ACTION_IR_BODY_TOP_RULE,
      "spec-language-v1",
      "actionir-v1",
      "staged-parsing-v1",
      "actionir_ast_v1",
    }, "|"),
    "staged cache fingerprint"
  )
  assert_equal(encoded.result.kind, "action_block", "staged action block")
  assert_equal(encoded.result.statements[1].expr.name, "return", "staged action call")

  local source_spec = spec_with_functions({ earlier, later })
  local dispatch = linkedspec.dispatch_function_body_parse_jobs(source_spec)
  assert_equal(
    linkedspec.staged_parser_registry.node_type(dispatch),
    "StagedFunctionBodyDispatchResult",
    "dispatch type"
  )
  assert_equal(source_spec.functions[1].body_ast, nil, "dispatch source remains unchanged")
  assert_equal(dispatch.spec.functions[1].body_ast.kind, "action_block", "first stitched body")
  assert_equal(dispatch.spec.functions[2].body_ast.kind, "action_block", "second stitched body")
  dispatch.results[1].result.kind = "mutated"
  assert_equal(dispatch.spec.functions[1].body_ast.kind, "action_block", "stitched body is isolated")

  local source = table.concat({
    'fn zero() {return("zero")}',
    "Top::",
    " /x/ -> Done { return(zero()) }",
    "",
    "Done:",
    " /[a-z]+/",
  }, "\n")
  local staged_spec = linkedspec.parse_spec_with_staged_user_function_definition_asts(
    source,
    json.array({ definition_node(source, "zero", {}, 'return("zero")') })
  )
  assert_equal(#staged_spec.functions, 1, "composed staged function count")
  assert_equal(staged_spec.functions[1].body_ast.kind, "action_block", "composed staged body")
  assert_equal(staged_spec.rules[1].header.label, "Top", "composed staged rules")

  local unsupported_json = ast.to_json(later.body_parse_job)
  unsupported_json.parser_spec_id = "missing.spec"
  local unsupported_job = ast.from_json("StagedParseJob", unsupported_json)
  local unsupported_ok, unsupported_error = pcall(
    linkedspec.execute_staged_parse_job,
    unsupported_job
  )
  assert_equal(unsupported_ok, false, "unsupported staged provider rejects")
  assert_equal(
    linkedspec.is_staged_parser_registry_error(unsupported_error),
    true,
    "unsupported staged provider error type"
  )
  assert_contains(unsupported_error.message, "phase=resolve", "unsupported staged phase")
  assert_contains(unsupported_error.message, "parser_spec_id=missing.spec", "unsupported staged identity")

  local drifted = registry_function("drifted", {}, 0, nil, 'return("x")')
  drifted.body_parse_job.result_field = "wrong_field"
  local drift_ok, drift_error = pcall(function()
    linkedspec.dispatch_function_body_parse_jobs(spec_with_functions({ drifted }))
  end)
  assert_equal(drift_ok, false, "staged sidecar drift rejects")
  assert_equal(linkedspec.is_staged_parser_registry_error(drift_error), true, "staged drift error type")
  assert_contains(drift_error.message, "result_field must be 'body_ast'", "staged drift field")

  local duplicate_first = registry_function("duplicate_first", {}, 0, nil, 'return("x")')
  local duplicate_second = registry_function("duplicate_second", {}, 1, nil, 'return("y")')
  duplicate_second.body_parse_job.job_id = duplicate_first.body_parse_job.job_id
  local duplicate_ok, duplicate_error = pcall(function()
    linkedspec.dispatch_function_body_parse_jobs(
      spec_with_functions({ duplicate_first, duplicate_second })
    )
  end)
  assert_equal(duplicate_ok, false, "duplicate staged job id rejects")
  assert_equal(
    linkedspec.is_staged_parser_registry_error(duplicate_error),
    true,
    "duplicate staged job error type"
  )
  assert_contains(duplicate_error.message, "duplicate staged function-body job_id", "duplicate staged job")
end)

test("user function invocation frames copy supplied four-kind values into fresh stores", function()
  local definition = registry_function("bind_all", { "scalar", "items", "meta", "callback" }, 0)
  local registry = linkedspec.user_function_registry_from_functions({ definition })
  local source_items = json.array({ "a", json.harray({ nested = true }) })
  local source_meta = json.harray({ key = json.array({ 1, 2 }) })
  local source_block = linkedspec.parse_action_expression("{ return(value) }")
  assert_equal(linkedspec.runtime_value_kind(source_block), "codeblock", "supplied structural codeblock kind")
  local frame = linkedspec.prepare_user_function_invocation(
    registry,
    "bind_all",
    { "ready", source_items, source_meta, source_block }
  )

  assert_equal(linkedspec.user_function_registry.node_type(frame), "UserFunctionInvocationFrame", "frame type")
  assert_equal(frame.variables.scalar, "ready", "scalar binding")
  assert_equal(json.kind(frame.variables.items), "array", "array scalar binding")
  assert_equal(json.kind(frame.arrays.items), "array", "typed array store")
  assert_equal(json.kind(frame.harrays.meta), "harray", "typed harray store")
  assert_equal(frame.variables.callback.kind, "block_value", "codeblock binding")
  assert_equal(frame.variables.outside, nil, "no caller capture")
  assert_equal(frame.active_path[1], "bind_all", "active path")

  frame.arrays.items[1] = "changed"
  frame.harrays.meta.key[1] = 99
  frame.variables.callback.kind = "mutated"
  assert_equal(source_items[1], "a", "caller array isolated")
  assert_equal(source_meta.key[1], 1, "caller harray isolated")
  assert_equal(source_block.kind, "block_value", "caller codeblock isolated")
  local second = linkedspec.prepare_user_function_invocation(
    registry,
    "bind_all",
    { "ready", source_items, source_meta, source_block }
  )
  assert_equal(second.arrays.items[1], "a", "fresh array store")
  assert_equal(second.harrays.meta.key[1], 1, "fresh harray store")
end)

test("user function invocation frames diagnose arity unknown calls and recursion", function()
  local first = registry_function("first", { "value" }, 0)
  local registry = linkedspec.user_function_registry_from_functions({ first })
  assert_registry_error(function()
    linkedspec.prepare_user_function_invocation(registry, "first", {})
  end, "expects arity 1, got 0", "user_function_arity_mismatch", "frame arity")
  assert_registry_error(function()
    linkedspec.prepare_user_function_invocation(registry, "missing", {})
  end, "unknown user function", "unknown_user_function", "frame unknown")
  local recursion = assert_registry_error(function()
    linkedspec.prepare_user_function_invocation(
      registry,
      "first",
      { "value" },
      { "first", "second" },
      { rule_label = "Top" }
    )
  end, "first -> second -> first in rule Top", "user_function_recursion", "frame recursion")
  assert_equal(recursion.stage, "user_function_call", "recursion stage")
  assert_equal(recursion.summary, "Lua user function recursion failed", "recursion summary")
  assert_equal(recursion.rule_label, "Top", "recursion rule")
  assert_equal(recursion.handler_source_label, "lua_runtime:function:first", "recursion handler source")
end)

local function staged_user_function_runtime(functions, rule_source)
  local parsed_rules = linkedspec.parse_spec(rule_source).rules
  local source_spec = ast.spec_file({ functions = functions, rules = parsed_rules })
  local staged_spec = linkedspec.dispatch_function_body_parse_jobs(source_spec).spec
  return linkedspec.runtime_engine(linkedspec.compile_spec(staged_spec))
end

local function assert_user_function_runtime_error(engine, code, expected, label)
  local ok, runtime_error = pcall(linkedspec.runtime_parse, engine, "x")
  if ok then fail((label or code) .. ": expected an error") end
  assert_equal(linkedspec.is_runtime_interpreter_error(runtime_error), true, (label or code) .. " type")
  assert_equal(runtime_error.code, code, (label or code) .. " code")
  if expected then assert_contains(runtime_error.message, expected, label or code) end
  assert_equal(runtime_error.diagnostic.stage, runtime_error.stage, (label or code) .. " diagnostic stage")
  return runtime_error
end

test("runtime executes staged fixed user functions in isolated stores and preserves value composition", function()
  local functions = {
    registry_function("pair", { "first", "second" }, 0, nil, "[first, second]"),
    registry_function("identity", { "value" }, 1, nil, "return(value)"),
    registry_function("nested", { "value" }, 2, nil, 'pair(value, "nested")'),
    registry_function("early", { "value" }, 3, nil, 'if(value) { return("early") }; "late"'),
    registry_function("mutate_items", { "items" }, 4, nil, 'items += "inner"; return(items)'),
    registry_function("mutate_meta", { "meta" }, 5, nil, 'meta["inner"] = "yes"; return(meta)'),
    registry_function("read_outside", {}, 6, nil, "return(outside)"),
  }
  local engine = staged_user_function_runtime(functions, [[
Top::
 /x/ E {
   counter = 0
   outside = "caller"
   items = ["outer"]
   meta = { "outer" : "yes" }
   ordered = pair(counter = counter.add(1), counter = counter.add(1))
   identity(counter = counter.add(1))
   return({
     "ordered" : ordered,
     "counter" : counter,
     "nested" : nested("value"),
     "early_true" : early(true),
     "early_false" : early(false),
     "mutated_items" : mutate_items(items),
     "caller_items" : items,
     "mutated_meta" : mutate_meta(meta),
     "caller_meta" : meta,
     "outside_isolated" : read_outside(),
     "array_chain" : pair("a", "b").join_values("|"),
     "string_chain" : identity("  text  ").trim(),
     "number_chain" : identity(4).add(3),
     "hash_chain" : identity({ "b" : 2, "a" : 1 }).sorted_keys().join_values(",")
   })
 }
]])
  local result = linkedspec.runtime_parse(engine, "x").value
  assert_equal(json.encode(result), json.encode(json.harray({
    ordered = json.array({ 1, 2 }),
    counter = 3,
    nested = json.array({ "value", "nested" }),
    early_true = "early",
    early_false = "late",
    mutated_items = json.array({ "outer", "inner" }),
    caller_items = json.array({ "outer" }),
    mutated_meta = json.harray({ outer = "yes", inner = "yes" }),
    caller_meta = json.harray({ outer = "yes" }),
    outside_isolated = json.null,
    array_chain = "a|b",
    string_chain = "text",
    number_chain = 7,
    hash_chain = "a,b",
  })), "fixed user function runtime result")
end)

test("runtime executes contextual final codeblocks in the current user function frame", function()
  local parameter_kinds = json.harray({ callback = "codeblock" })
  local functions = {
    registry_function(
      "apply",
      { "value", "callback" },
      0,
      nil,
      "return(callback())",
      nil,
      parameter_kinds
    ),
    registry_function(
      "inspect",
      { "value", "callback" },
      1,
      nil,
      'callback(); return({ "value" : value, "scratch" : scratch })',
      nil,
      parameter_kinds
    ),
  }
  local engine = staged_user_function_runtime(functions, [[
Top::
 /x/ E {
   value = "caller"
   scratch = "caller-scratch"
   attached = apply("a") { return(cat(value, "!")) }
   parenthesized = apply("a", { return(cat(value, "!")) })
   chained = apply("a", { return(cat(value, "!")) }).uppercase()
   observed = inspect("inside", {
     value = value.uppercase()
     scratch = "callback-scratch"
     return(value)
   })
   return({
     "attached" : attached,
     "parenthesized" : parenthesized,
     "chained" : chained,
     "observed" : observed,
     "caller_value" : value,
     "caller_scratch" : scratch
   })
 }
]])
  local result = linkedspec.runtime_parse(engine, "x").value
  assert_equal(json.encode(result), json.encode(json.harray({
    attached = "a!",
    parenthesized = "a!",
    chained = "A!",
    observed = json.harray({ value = "INSIDE", scratch = "callback-scratch" }),
    caller_value = "caller",
    caller_scratch = "caller-scratch",
  })), "contextual user function codeblock result")
end)

test("runtime contextual final codeblocks reject missing wrong-kind and nonzero calls", function()
  local parameter_kinds = json.harray({ callback = "codeblock" })
  local apply = registry_function(
    "apply",
    { "value", "callback" },
    0,
    nil,
    "return(callback())",
    nil,
    parameter_kinds
  )
  for _, case in ipairs({
    {
      label = "missing contextual callback",
      source = 'Top::\n /x/ E { return(apply("x")) }\n',
      kind = "missing",
    },
    {
      label = "harray contextual callback",
      source = 'Top::\n /x/ E { return(apply("x", { "key" : "value" })) }\n',
      kind = "harray",
    },
  }) do
    local runtime_error = assert_user_function_runtime_error(
      staged_user_function_runtime({ apply }, case.source),
      "final_argument_not_codeblock",
      nil,
      case.label
    )
    assert_equal(runtime_error.helper_name, "apply", case.label .. " owner")
    assert_equal(runtime_error.value_kind, case.kind, case.label .. " kind")
  end

  local nonzero = registry_function(
    "invoke_nonzero",
    { "callback" },
    0,
    nil,
    'return(callback("unexpected"))',
    nil,
    json.harray({ callback = "codeblock" })
  )
  local arity = assert_user_function_runtime_error(
    staged_user_function_runtime(
      { nonzero },
      'Top::\n /x/ E { return(invoke_nonzero({ return("unused") })) }\n'
    ),
    "codeblock_arity_mismatch",
    "expects exactly 0 positional arguments, got 1",
    "contextual callback arity"
  )
  assert_equal(arity.expected, "exactly 0", "contextual callback expected arity")
  assert_equal(arity.got, 1, "contextual callback actual arity")
end)

test("runtime contextual final codeblocks reject active self invocation", function()
  local recurse = registry_function(
    "invoke_recursive",
    { "callback" },
    0,
    nil,
    "return(callback())",
    nil,
    json.harray({ callback = "codeblock" })
  )
  local runtime_error = assert_user_function_runtime_error(
    staged_user_function_runtime(
      { recurse },
      'Top::\n /x/ E { return(invoke_recursive({ return(callback()) })) }\n'
    ),
    "codeblock_recursion_unsupported",
    "callback -> callback",
    "contextual callback recursion"
  )
  assert_equal(runtime_error.cycle, "callback -> callback", "contextual callback recursion cycle")
end)

test("runtime governed helpers and registered functions precede contextual parameters", function()
  local codeblock_kind = json.harray({ uppercase = "codeblock" })
  local callback_kind = json.harray({ callback = "codeblock" })
  local functions = {
    registry_function("callback", {}, 0, nil, 'return("static-user-function")'),
    registry_function(
      "apply_helper",
      { "uppercase" },
      1,
      nil,
      'return(uppercase("static-helper"))',
      nil,
      codeblock_kind
    ),
    registry_function(
      "apply_function",
      { "callback" },
      2,
      nil,
      "return(callback())",
      nil,
      callback_kind
    ),
  }
  local engine = staged_user_function_runtime(functions, [[
Top::
 /x/ E {
   return({
     "helper" : apply_helper({ return("dynamic-helper") }),
     "function" : apply_function({ return("dynamic-function") })
   })
 }
]])
  local result = linkedspec.runtime_parse(engine, "x").value
  assert_equal(json.encode(result), json.encode(json.harray({
    helper = "STATIC-HELPER",
    ["function"] = "static-user-function",
  })), "static callable precedence")
end)

test("runtime executes the unchanged neutral variadic callable fixture", function()
  local contract = json.decode(read_file("capability_conformance/callable_signature_contract.json"))
  local source = contract.fixture.spec_source
  local nodes = json.array({
    definition_node(source, "pair", { "left", "right" }, " return([left, right]) "),
    variadic_definition_node(source, "all_values", {}, "items", " return(items) "),
    variadic_definition_node(
      source,
      "collect",
      { "prefix" },
      "items",
      ' return({ "prefix" : prefix, "items" : items }) '
    ),
  })
  local staged = linkedspec.parse_spec_with_staged_user_function_definition_asts(source, nodes)
  local engine = linkedspec.runtime_engine(linkedspec.compile_spec(staged))
  local result = linkedspec.runtime_parse(engine, contract.fixture.input).value
  assert_equal(json.encode(result), json.encode(contract.fixture.expected), "neutral variadic fixture result")
end)

test("runtime evaluates variadic arguments once and isolates each rest array", function()
  local functions = {
    variadic_registry_function("all_values", {}, "items", 0, nil, "return(items)"),
    variadic_registry_function(
      "mutate_rest",
      {},
      "items",
      1,
      nil,
      'items += "inner"; return(items)'
    ),
  }
  local engine = staged_user_function_runtime(functions, [[
Top::
 /x/ E {
   counter = 0
   source = ["outer"]
   ordered = all_values(counter = counter.add(1), counter = counter.add(1))
   return({
     "ordered" : ordered,
     "counter" : counter,
     "caller_source" : source,
     "nested_rest" : mutate_rest(source),
     "first_empty" : mutate_rest(),
     "second_empty" : mutate_rest(),
     "codeblock_count" : all_values({ return("callback") }).count()
   })
 }
]])
  local result = linkedspec.runtime_parse(engine, "x").value
  assert_equal(json.encode(result), json.encode(json.harray({
    ordered = json.array({ 1, 2 }),
    counter = 2,
    caller_source = json.array({ "outer" }),
    nested_rest = json.array({ json.array({ "outer" }), "inner" }),
    first_empty = json.array({ "inner" }),
    second_empty = json.array({ "inner" }),
    codeblock_count = 1,
  })), "variadic runtime order and freshness")
end)

test("runtime variadic calls diagnose minimum arity and keyword arguments", function()
  local collect = variadic_registry_function(
    "collect",
    { "prefix" },
    "items",
    0,
    nil,
    'return({ "prefix" : prefix, "items" : items })'
  )
  local minimum = assert_user_function_runtime_error(
    staged_user_function_runtime({ collect }, "Top::\n /x/ E { return(collect()) }\n"),
    "user_function_arity_mismatch",
    "expects arity at least 1, got 0",
    "variadic minimum arity"
  )
  assert_equal(minimum.helper_name, "collect", "variadic minimum function owner")

  local keyword_engine = staged_user_function_runtime(
    { collect },
    'Top::\n /x/ E { return(collect("p")) }\n'
  )
  local payload = keyword_engine.compiled_spec.rules_by_label.Top.lifecycle_action_payloads[1]
  local call = payload.action_ast.statements[1].expr.args[1].value
  call.args[1] = linkedspec.action_ast.keyword_argument(
    "prefix",
    linkedspec.parse_action_expression('"p"')
  )
  payload.contracts = linkedspec.resolve_action_block_contracts(
    payload.action_ast,
    { function_registry = keyword_engine.compiled_spec.function_registry }
  )
  local keyword = assert_user_function_runtime_error(
    keyword_engine,
    "user_function_keyword_arguments_unsupported",
    "accepts positional arguments only",
    "variadic keyword argument"
  )
  assert_equal(keyword.expected, "positional arguments", "variadic keyword expected surface")
  assert_equal(keyword.got, 1, "variadic keyword count")
  assert_equal(payload.contracts.ok, false, "variadic keyword contract rejects")
  assert_equal(
    payload.contracts.diagnostics[1].code,
    "user_function_keyword_arguments_unsupported",
    "variadic keyword contract diagnostic"
  )
end)

test("runtime user functions diagnose arity keywords and recursion before helper fallback", function()
  local identity = registry_function("identity", { "value" }, 0, nil, "return(value)")
  local arity = assert_user_function_runtime_error(
    staged_user_function_runtime({ identity }, "Top::\n /x/ E { return(identity()) }\n"),
    "user_function_arity_mismatch",
    "expects arity 1, got 0",
    "fixed arity"
  )
  assert_equal(arity.helper_name, "identity", "fixed arity function owner")

  local keyword_engine = staged_user_function_runtime(
    { identity },
    'Top::\n /x/ E { return(identity("x")) }\n'
  )
  local keyword_payload = keyword_engine.compiled_spec.rules_by_label.Top.lifecycle_action_payloads[1]
  local keyword_call = keyword_payload.action_ast.statements[1].expr.args[1].value
  keyword_call.args[1] = linkedspec.action_ast.keyword_argument(
    "value",
    linkedspec.parse_action_expression('"x"')
  )
  keyword_payload.contracts = linkedspec.resolve_action_block_contracts(
    keyword_payload.action_ast,
    { function_registry = keyword_engine.compiled_spec.function_registry }
  )
  local keyword = assert_user_function_runtime_error(
    keyword_engine,
    "user_function_keyword_arguments_unsupported",
    "accepts positional arguments only",
    "keyword argument"
  )
  assert_equal(keyword.expected, "positional arguments", "keyword expected surface")
  assert_equal(keyword.got, 1, "keyword count")
  local keyword_contract = keyword_payload.contracts
  assert_equal(keyword_contract.ok, false, "keyword contract rejects")
  assert_equal(
    keyword_contract.diagnostics[1].code,
    "user_function_keyword_arguments_unsupported",
    "keyword contract diagnostic"
  )

  local direct = registry_function("direct", { "value" }, 0, nil, "direct(value)")
  local direct_error = assert_user_function_runtime_error(
    staged_user_function_runtime({ direct }, 'Top::\n /x/ E { return(direct("x")) }\n'),
    "user_function_recursion",
    "direct -> direct",
    "direct recursion"
  )
  assert_equal(direct_error.cycle, "direct -> direct", "direct recursion cycle")

  local first = registry_function("recur_alpha", { "value" }, 0, nil, "recur_beta(value)")
  local second = registry_function("recur_beta", { "value" }, 1, nil, "recur_alpha(value)")
  local mutual_error = assert_user_function_runtime_error(
    staged_user_function_runtime({ first, second }, 'Top::\n /x/ E { return(recur_alpha("x")) }\n'),
    "user_function_recursion",
    "recur_alpha -> recur_beta -> recur_alpha",
    "mutual recursion"
  )
  assert_equal(
    mutual_error.cycle,
    "recur_alpha -> recur_beta -> recur_alpha",
    "mutual recursion cycle"
  )
end)

test("runtime requires staged user function body AST authority", function()
  local missing = registry_function("missing_body", {}, 0, nil, 'return("x")')
  local missing_rules = linkedspec.parse_spec('Top::\n /x/ E { return(missing_body()) }\n').rules
  local missing_engine = linkedspec.runtime_engine(linkedspec.compile_spec(ast.spec_file({
    functions = { missing },
    rules = missing_rules,
  })))
  assert_user_function_runtime_error(
    missing_engine,
    "user_function_body_ast_missing",
    "does not have a staged action-block body_ast",
    "missing staged body"
  )

  local mismatched = registry_function(
    "mismatched_body",
    {},
    0,
    json.harray({ kind = "action_block", statements = json.array() }),
    'return("x")'
  )
  local mismatch_rules = linkedspec.parse_spec('Top::\n /x/ E { return(mismatched_body()) }\n').rules
  local mismatch_engine = linkedspec.runtime_engine(linkedspec.compile_spec(ast.spec_file({
    functions = { mismatched },
    rules = mismatch_rules,
  })))
  assert_user_function_runtime_error(
    mismatch_engine,
    "user_function_body_ast_mismatch",
    "does not match its governed body source",
    "mismatched staged body"
  )
end)

local function compiled_test_rule(label, is_top, mode, body)
  return ast.rule({
    header = ast.rule_header({
      label = label,
      is_top = is_top,
      mode = mode or ast.default_rule_mode(),
      rest = "",
      line = 1,
    }),
    body = body,
  })
end

local function assert_compiled_error(operation, expected, label)
  local ok, compiled_error = pcall(operation)
  if ok then fail((label or "compiled spec") .. ": expected an error") end
  assert_equal(linkedspec.is_compiled_spec_error(compiled_error), true, (label or "compiled spec") .. " type")
  assert_contains(compiled_error.message, expected, label)
  return compiled_error
end

test("compiled spec preserves ordered rules modes dependencies and ActionIR payloads", function()
  local normalize = registry_function(
    "normalize",
    { "value" },
    0,
    json.harray({ kind = "action_block", statements = json.array() })
  )
  local top = compiled_test_rule("Top", true, ast.and_bounded_rule_mode({ min = 1, max = 2 }), {
    ast.body_element({ kind = ast.regex_body_kind({ pattern = "a" }), source = "/a/", line = 1 }),
    ast.body_element({
      kind = ast.action_edge_body_kind({
        targets = { ast.edge_target({ label = "Child", index = 0 }) },
        code = 'return(normalize(" x "))',
      }),
      source = '/a/ -> Child { return(normalize(" x ")) }',
      line = 1,
    }),
    ast.body_element({
      kind = ast.code_block_body_kind({ lifecycle = "I", code = "set(meta, { ok : true })" }),
      source = "I { set(meta, { ok : true }) }",
      line = 2,
    }),
    ast.body_element({
      kind = ast.plain_block_body_kind({ code = 'return("plain")' }),
      source = '{ return("plain") }',
      line = 3,
    }),
  })
  local child = compiled_test_rule("Child", false, nil, {
    ast.body_element({ kind = ast.regex_body_kind({ pattern = "x" }), source = "/x/", line = 4 }),
  })
  local source = ast.spec_file({ functions = { normalize }, rules = { top, child } })
  local compiled = linkedspec.compile_spec(source)

  assert_equal(linkedspec.compiled_spec.node_type(compiled), "CompiledSpec", "compiled type")
  assert_equal(table.concat(compiled.definition_order, ","), "Top,Child", "definition order")
  assert_equal(table.concat(compiled.compiled_rule_order, ","), "Top,Child", "compiled order")
  assert_equal(compiled:rule("Top").mode_metadata.name, "AndBounded", "mode name")
  assert_equal(compiled:rule("Top").mode_metadata.is_and, true, "mode and")
  assert_equal(compiled:rule("Top").mode_metadata.rep_min, 1, "mode minimum")
  assert_equal(compiled:rule("Top").mode_metadata.rep_max, 2, "mode maximum")
  assert_equal(compiled:rule("Top").action_edges[1].regex_index, 0, "same-line parent regex")
  assert_equal(compiled.dependency_regex_state.dependency_regex_map.Top.patterns[1], "x", "dependency pattern")

  local payloads = linkedspec.compiled_spec.action_payloads(compiled:rule("Top"))
  assert_equal(#payloads, 3, "action payload count")
  assert_equal(payloads[1].action_ast.kind, "action_block", "action AST")
  assert_equal(payloads[1].contracts.ok, true, "registry-aware contracts")
  assert_equal(payloads[1].contracts.contracts[2].family, "user_function", "registered contract")
  assert_equal(payloads[2].lifecycle, "I", "lifecycle identity")
  assert_equal(payloads[3].role, "plain_block", "plain payload role")

  top.header.label = "Mutated"
  top.body[1].kind.pattern = "mutated"
  assert_equal(compiled:rule("Top").label, "Top", "source rule snapshot")
  assert_equal(compiled:rule("Top").regex_patterns[1], "a", "source regex snapshot")
end)

test("compiled spec resolves child regex slots and keeps last definition order", function()
  local first_a = compiled_test_rule("A", true, nil, {
    ast.body_element({ kind = ast.regex_body_kind({ pattern = "old" }), source = "/old/", line = 1 }),
  })
  local b = compiled_test_rule("B", false, nil, {
    ast.body_element({
      kind = ast.action_edge_body_kind({ targets = { ast.edge_target({ label = "A", index = 0 }) } }),
      source = "-> A",
      line = 2,
    }),
  })
  local last_a = compiled_test_rule("A", false, nil, {
    ast.body_element({ kind = ast.regex_body_kind({ pattern = "new" }), source = "/new/", line = 3 }),
  })
  local compiled = linkedspec.compile_spec(
    ast.spec_file({ rules = { first_a, b, last_a } }),
    { validate_source = false }
  )

  assert_equal(table.concat(compiled.definition_order, ","), "A,B,A", "source definition order")
  assert_equal(table.concat(compiled.compiled_rule_order, ","), "B,A", "last definition order")
  assert_equal(compiled.redefined_rule_labels[1], "A", "redefined label")
  assert_equal(compiled:rule("A").regex_patterns[1], "new", "last definition wins")
  assert_equal(compiled:rule("B").regex_patterns[1], "new", "child pattern appended")
  assert_equal(compiled:rule("B").action_edges[1].regex_index, 0, "appended regex index")
  assert_equal(
    linkedspec.compiled_spec.to_json(compiled.dependency_regex_state).kind,
    "compiled_dependency_regex_state",
    "dependency state kind"
  )
end)

test("compiled descriptor matches the exact outward contract", function()
  local body_ast = json.harray({ kind = "action_block", statements = json.array() })
  local normalize = registry_function("normalize", { "value" }, 0, body_ast)
  local collect = variadic_registry_function("collect", { "prefix" }, "items", 1, body_ast)
  local parameter_kinds = json.harray({ callback = "codeblock" })
  local apply = registry_function(
    "apply",
    { "value", "callback" },
    2,
    body_ast,
    nil,
    nil,
    parameter_kinds
  )
  local compiled = linkedspec.compile_spec(spec_with_functions({ normalize, collect, apply }))
  local descriptor = linkedspec.to_descriptor_json(compiled)
  local contract = json.decode(read_file("capability_conformance/outward_descriptor_contract.json"))

  assert_equal(
    table.concat(sorted_keys(descriptor), ","),
    table.concat(sorted_values(contract.top_level_keys), ","),
    "descriptor top-level keys"
  )
  for _, key in ipairs(contract.required_meta_keys) do
    if descriptor.meta[key] == nil then fail("descriptor missing meta key " .. key) end
  end
  for key, expected in pairs(contract.model_values) do
    assert_equal(descriptor.meta[key], expected, "descriptor model " .. key)
  end
  assert_equal(descriptor.spec.Top.handler.kind, "lua_interpreter_rule", "Lua handler identity")
  assert_equal(descriptor.spec.Top.handler.status, "compiled_state_only", "handler boundary")
  assert_equal(descriptor.meta.function_order[1], "normalize", "function order")
  assert_equal(descriptor.meta.function_order[2], "collect", "variadic function order")
  assert_equal(descriptor.meta.function_order[3], "apply", "codeblock function order")
  assert_equal(descriptor.meta.function_count, 3, "function count")
  for _, expected in ipairs({
    { name = "normalize", variant = "fixed_v1", index = 0 },
    { name = "collect", variant = "variadic_v2", index = 1 },
    { name = "apply", variant = "final_codeblock_v3", index = 2 },
  }) do
    local record = descriptor.functions[expected.name]
    local variant = contract.function_record_variants[expected.variant]
    assert_equal(
      table.concat(sorted_keys(record), ","),
      table.concat(sorted_values(variant.record_fields), ","),
      expected.name .. " function record keys"
    )
    assert_equal(record.version, variant.function_version, expected.name .. " function record version")
    assert_equal(record.index, expected.index, expected.name .. " function record index")
  end
  assert_equal(descriptor.functions.normalize.body_ast.kind, "action_block", "function body AST")
  assert_equal(
    json.encode(descriptor.functions.collect.signature),
    json.encode(descriptor.functions.collect.body_parse_job.signature),
    "variadic descriptor signature preservation"
  )
  assert_equal(
    json.encode(descriptor.functions.apply.parameter_kinds),
    json.encode(descriptor.functions.apply.body_payload.parameter_kinds),
    "codeblock descriptor parameter-kinds preservation"
  )
  assert_equal(json.decode(json.encode(descriptor)).meta.parse_mode, "seek", "descriptor JSON round-trip")
end)

test("compiled spec reports typed dependency failures after optional validation", function()
  local bad_slot = compiled_test_rule("Top", true, nil, {
    ast.body_element({
      kind = ast.action_edge_body_kind({ targets = { ast.edge_target({ label = "Child", index = 1 }) } }),
      source = "-> Child[1]",
      line = 1,
    }),
  })
  local child = compiled_test_rule("Child", false, nil, {
    ast.body_element({ kind = ast.regex_body_kind({ pattern = "x" }), source = "/x/", line = 2 }),
  })
  local slot_error = assert_compiled_error(function()
    linkedspec.compile_spec(ast.spec_file({ rules = { bad_slot, child } }), { validate_source = false })
  end, "regex slot 1", "compiled slot")
  assert_equal(slot_error.rule_label, "Top", "slot rule identity")
  assert_equal(slot_error.target_label, "Child", "slot target identity")

  local missing = compiled_test_rule("Top", true, nil, {
    ast.body_element({
      kind = ast.action_edge_body_kind({ targets = { ast.edge_target({ label = "Ghost", index = 0 }) } }),
      source = "-> Ghost",
      line = 1,
    }),
  })
  assert_compiled_error(function()
    linkedspec.compile_spec(ast.spec_file({ rules = { missing } }), { validate_source = false })
  end, "undefined rule 'Ghost'", "compiled missing")
end)

test("compile_spec consumes the public parsed source AST", function()
  local parsed = linkedspec.parse_spec([[
Top::
 /x/ -> Top {
   set_key(meta, 'kind', "parsed")
   return(meta)
 }
]])
  local compiled = linkedspec.compile_spec(parsed)
  local top = compiled:rule("Top")
  assert_equal(top.regex_patterns[1], "x", "parsed regex")
  assert_equal(top.action_edges[1].has_parent_regex, true, "parsed edge parent regex")
  assert_equal(top.action_edges[1].action_payload.action_ast.statements[1].expr.kind, "call", "parsed action AST")
  assert_equal(top.action_edges[1].action_payload.contracts.ok, true, "parsed action contracts")
end)

local function assert_runtime_regex_error(operation, expected, stage, label)
  local ok, regex_error = pcall(operation)
  if ok then fail((label or "runtime regex") .. ": expected an error") end
  assert_equal(linkedspec.is_runtime_regex_error(regex_error), true, (label or "runtime regex") .. " type")
  assert_contains(regex_error.message, expected, label)
  if stage then assert_equal(regex_error.stage, stage, (label or "runtime regex") .. " stage") end
  return regex_error
end

test("native PCRE2 adapter covers the governed regex dialect", function()
  assert_equal(linkedspec.runtime_regex_engine(), "pcre2-native", "runtime regex engine")
  assert_contains(linkedspec.runtime_regex_engine_version(), ".", "PCRE2 version")

  local inline = linkedspec.compile_runtime_regex_alternation({ "(?i)abc" })
  assert_equal(inline:consume_match("ABC", 0):text(), "ABC", "inline flags")
  local posix = linkedspec.compile_runtime_regex_alternation({ "[[:alpha:]]++" })
  assert_equal(posix:consume_match("éclair", 0):text(), "éclair", "POSIX and possessive")
  local named = linkedspec.compile_runtime_regex_alternation({ "(?P<word>\\w+)" })
  assert_equal(named:consume_match("value", 0):named_capture("word"), "value", "Python named capture")
  local recursive = linkedspec.compile_runtime_regex_alternation({ "(\\[(?:[^\\[\\]]++|(?R))*\\])" })
  assert_equal(recursive:consume_match("[a[b]c]", 0):text(), "[a[b]c]", "recursive pattern")
  local reset = linkedspec.compile_runtime_regex_alternation({ "prefix\\Kvalue" })
  local reset_match = reset:consume_match("prefixvalue", 0)
  assert_equal(reset_match:text(), "value", "match-start reset text")
  assert_equal(reset_match.byte_start, 6, "match-start reset offset")

  local negative_lookbehind = linkedspec.compile_runtime_regex_alternation({ [[(?<!\\)/]] })
  assert_equal(negative_lookbehind:seek_match("/", 0):text(), "/", "negative lookbehind match")
  assert_equal(negative_lookbehind:seek_match([[\/]], 0), nil, "negative lookbehind rejection")
  local positive_lookbehind = linkedspec.compile_runtime_regex_alternation({ [[(?<=a)b]] })
  assert_equal(positive_lookbehind:seek_match("ab", 0):text(), "b", "positive lookbehind match")
end)

test("runtime alternation preserves seek consume and source-order identity", function()
  local alternation = linkedspec.compile_runtime_regex_alternation({ "b.", "a." })
  local seek = alternation:match("zzab", 0, "seek")
  assert_equal(seek.alternative_index, 1, "earliest alternative")
  assert_equal(seek.byte_start, 2, "seek start")
  assert_equal(seek:text(), "ab", "seek text")
  assert_equal(alternation:match("zzab", 2, "consume").alternative_index, 1, "consume match")
  assert_equal(alternation:consume_match("zzab", 1), nil, "consume anchor")

  local tie = linkedspec.compile_runtime_regex_alternation({ "a.", "ab" }):seek_match("zzab", 0)
  assert_equal(tie.alternative_index, 0, "source-order tie break")
  local compiled = linkedspec.compile_spec(linkedspec.parse_spec("Top::\n /a/\n /b/\n"))
  local from_rule = linkedspec.compile_runtime_regex_alternation(compiled:rule("Top"))
  assert_equal(from_rule:consume_match("b", 0).alternative_index, 1, "compiled-rule alternatives")
end)

test("runtime matches expose compact captures and Unicode positions", function()
  local input = "é\nac"
  local alternation = linkedspec.compile_runtime_regex_alternation({
    "(?P<first>a)(b)?(?P<last>c)",
  })
  local match = alternation:seek_match(input, 0)
  assert_equal(match.byte_start, 3, "byte start")
  assert_equal(match.byte_end, 5, "byte end")
  assert_equal(match:char_start(), 2, "character start")
  assert_equal(match:char_end(), 4, "character end")
  assert_equal(match:char_length(), 2, "character length")
  assert_equal(match.groups[1], "ac", "whole group")
  assert_equal(match.groups[2], "a", "first group")
  assert_equal(match.groups[3], "", "non-participating group slot")
  assert_equal(match.groups[4], "c", "last group")
  assert_equal(table.concat(match.captures, ","), "a,c", "compacted captures")
  assert_equal(match.named.first, "a", "first named capture")
  assert_equal(match.named.last, "c", "last named capture")
  assert_equal(match:start_line_column().line, 2, "match line")
  assert_equal(match:start_line_column().column, 1, "match column")
  assert_equal(linkedspec.matching.byte_offset_to_char_offset(input, 3), 2, "byte-to-char offset")
  assert_equal(linkedspec.matching.char_offset_to_byte_offset(input, 2), 3, "char-to-byte offset")
  local projected = linkedspec.matching.to_json(match)
  assert_equal(json.decode(json.encode(projected)).named.last, "c", "matching JSON")
end)

test("runtime match registers separate entry local and zero-width presence", function()
  local zero = linkedspec.compile_runtime_regex_alternation({ "" }):consume_match("abc", 0)
  assert_equal(zero:is_zero_width(), true, "zero-width match")
  assert_equal(zero:made_progress_from(0), false, "zero-width progress")
  assert_equal(zero:is_zero_progress_from(0), true, "zero-progress identity")

  local initial = linkedspec.runtime_match_registers("abc")
  assert_equal(initial.entry_match, nil, "initial entry absence")
  assert_equal(initial.local_match, nil, "initial local absence")
  local matched = initial:with_local_match(zero)
  assert_equal(matched.entry_match, zero, "top entry seeded")
  assert_equal(matched.local_match, zero, "local match stored")
  assert_equal(matched:zero_progress_since(0), true, "register zero progress")
  local child = matched:enter_child()
  assert_equal(child.entry_match, zero, "child entry from caller local")
  assert_equal(child.local_match, nil, "child local starts absent")
  assert_equal(child.capture_start_byte, 0, "child capture anchor")
  local projected = linkedspec.matching.to_json(child)
  assert_equal(projected.entry_match.zero_width, true, "present zero-width entry")
  assert_equal(projected.local_match, nil, "absent local omitted")

  local advanced = matched:with_cursor_byte(2):with_capture_start_byte(1)
  assert_equal(advanced.cursor_byte, 2, "updated cursor")
  assert_equal(advanced.capture_start_byte, 1, "updated capture anchor")
  assert_equal(matched.cursor_byte, 0, "source registers unchanged")
end)

test("runtime matching returns typed dialect input and boundary failures", function()
  local compile_error = assert_runtime_regex_error(function()
    linkedspec.compile_runtime_regex_alternation({ "(" })
  end, "regex compile error for alternative 0", "regex_compile", "invalid regex")
  assert_equal(compile_error.alternative_index, 0, "compile alternative")

  local alternation = linkedspec.compile_runtime_regex_alternation({ "." })
  assert_runtime_regex_error(function()
    alternation:seek_match("é", 1)
  end, "not a UTF-8 character boundary", "regex_offset", "invalid boundary")
  assert_runtime_regex_error(function()
    alternation:seek_match(string.char(0xFF), 0)
  end, "not valid UTF-8", "regex_input", "invalid input")
  assert_runtime_regex_error(function()
    alternation:match("x", 0, "scan")
  end, "unsupported parse mode", "parse_mode", "invalid mode")

  local other_match = alternation:consume_match("x", 0)
  assert_runtime_regex_error(function()
    linkedspec.runtime_match_registers("y", { local_match = other_match })
  end, "does not belong to register input", nil, "foreign match")
end)

test("runtime interpreter repeats default rules and preserves direct result shape", function()
  local compiled = linkedspec.compile_spec(linkedspec.parse_spec("Top::\n /a/\n"))
  local result = linkedspec.runtime_parse(linkedspec.runtime_engine(compiled), "aaa")
  assert_equal(linkedspec.interpreter.node_type(result), "RuntimeParseResult", "parse result type")
  assert_equal(result.matched, true, "default matched")
  assert_equal(result.cursor_code_unit, 3, "default repeated cursor")
  assert_equal(result.cursor_char_offset, 3, "default character cursor")
  assert_equal(result.value, json.null, "default value")
  assert_equal(result.output[1], json.null, "one-value output wrapper")
  assert_equal(json.decode(json.encode(linkedspec.interpreter.to_json(result))).matched, true, "result JSON")

  local seek = linkedspec.runtime_parse(linkedspec.runtime_engine(compiled), "za")
  assert_equal(seek.cursor_code_unit, 2, "seek advances to match")
  local consume = linkedspec.runtime_parse(
    linkedspec.runtime_engine(compiled, { parse_mode = "consume" }),
    "za"
  )
  assert_equal(consume.matched, false, "consume stays anchored")
  assert_equal(consume.cursor_code_unit, 0, "consume cursor")
end)

test("runtime public parse initializes after complete leading blank and comment lines", function()
  local boundary_engine = linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec([[
Top::
 I { initial = cursor_pos(); initial_rest = cursor_rest() }
 /x/
 E { return(array(initial, initial_rest)) }
]])))

  local leading = linkedspec.runtime_parse(boundary_engine, "\n \t# é\nx")
  assert_equal(leading.value[1], 7, "leading trivia character start")
  assert_equal(leading.value[2], "x", "leading trivia remaining input")
  assert_equal(leading.cursor_code_unit, 9, "leading trivia byte endpoint")
  assert_equal(leading.cursor_char_offset, 8, "leading trivia character endpoint")

  local terminal_comment = linkedspec.runtime_parse(boundary_engine, " \t# é")
  assert_equal(terminal_comment.value[1], 5, "terminal comment character start")
  assert_equal(terminal_comment.value[2], "", "terminal comment reaches input end")
  assert_equal(terminal_comment.cursor_code_unit, 6, "terminal comment byte endpoint")
  assert_equal(terminal_comment.cursor_char_offset, 5, "terminal comment character endpoint")

  local ordinary = linkedspec.runtime_parse(boundary_engine, "  x")
  assert_equal(ordinary.value[1], 0, "ordinary leading spaces stay content")
  assert_equal(ordinary.value[2], "  x", "ordinary nontrivia input is unchanged")

  local history_engine = linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec([[
Top::
 I { cur = undef; items = [] }
 -> object { cur = call(object) }
 -> version { push(items, call(version)) }
 LX { return(array(cur[1], copy(items))) }

object: /(?i)\nobject:\s+(\S+)/ I { return(array("?object:", flat_array(entry_groups()))) }
version: /(?i)\nversion:\s+(\S+)/ I { return(array("?version:", flat_array(entry_groups()))) }
]])))
  local history = linkedspec.runtime_parse(
    history_engine,
    "\n \t# generated report\nobject: /proj/foo\nversion: 1\n"
  )
  assert_equal(
    json.encode(history.value),
    json.encode(json.array({
      json.null,
      json.array({ json.array({ "?version:", "1" }) }),
    })),
    "leading trivia history boundary"
  )

  local indexed_engine = linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec([[
Top::
 /x/
 LE { payload = ["tag", "name"]; return(payload[1]) }
]])))
  assert_equal(
    linkedspec.runtime_parse(indexed_engine, "x").value,
    "name",
    "ordinary scalar-held indexed read"
  )
end)

test("runtime action edges dispatch children and publish retv", function()
  local source = [[
Top::
 /a/ -> Child
 E { return(retv) }

Child:
 /b/
 E { return("child") }
]]
  local result = linkedspec.runtime_execute(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(source))),
    "ab"
  )
  assert_equal(result.matched, true, "action dispatch matched")
  assert_equal(result.value, "child", "retv result")
  assert_equal(result.cursor_code_unit, 2, "child cursor")
  assert_equal(result.output[1], "child", "direct output")

  local current_edge = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec([[
Top::
 /a/ -> Child { return(retv) }

Child:
 /b/
 E { return("edge-child") }
]]))),
    "ab"
  )
  assert_equal(current_edge.value, "edge-child", "current-edge retv dispatch")
  assert_equal(current_edge.cursor_code_unit, 2, "current-edge child cursor")
end)

test("runtime blind AND and OR dispatch preserve mode behavior", function()
  local function terminal(label, pattern, value)
    return compiled_test_rule(label, false, ast.rule_mode("Single"), {
      ast.body_element({ kind = ast.regex_body_kind({ pattern = pattern }), source = "/" .. pattern .. "/", line = 1 }),
      ast.body_element({
        kind = ast.code_block_body_kind({ lifecycle = "LE", code = 'return("' .. value .. '")' }),
        source = 'LE { return("' .. value .. '") }',
        line = 2,
      }),
    })
  end
  local and_top = compiled_test_rule("Top", true, ast.rule_mode("And"), {
    ast.body_element({ kind = ast.blind_edge_body_kind({ target = "A" }), source = "=> A", line = 1 }),
    ast.body_element({ kind = ast.blind_edge_body_kind({ target = "B" }), source = "=> B", line = 2 }),
  })
  local and_spec = ast.spec_file({ rules = { and_top, terminal("A", "a", "A"), terminal("B", "b", "B") } })
  local and_result = linkedspec.runtime_parse(linkedspec.runtime_engine(linkedspec.compile_spec(and_spec)), "ab")
  assert_equal(and_result.matched, true, "blind AND matched")
  assert_equal(json.kind(and_result.value), "array", "blind AND value")
  assert_equal(table.concat(and_result.value, ","), "A,B", "blind AND child order")

  local or_top = compiled_test_rule("Top", true, ast.rule_mode("Or"), {
    ast.body_element({ kind = ast.blind_edge_body_kind({ target = "A" }), source = "=> A", line = 1 }),
    ast.body_element({ kind = ast.blind_edge_body_kind({ target = "B" }), source = "=> B", line = 2 }),
    ast.body_element({
      kind = ast.code_block_body_kind({ lifecycle = "E", code = "return(retv)" }),
      source = "E { return(retv) }",
      line = 3,
    }),
  })
  local or_spec = ast.spec_file({ rules = { or_top, terminal("A", "a", "A"), terminal("B", "b", "B") } })
  local or_result = linkedspec.runtime_parse(linkedspec.runtime_engine(linkedspec.compile_spec(or_spec)), "b")
  assert_equal(or_result.value, "B", "blind OR first success")
end)

test("runtime lifecycle order and local stores survive guarded repetition", function()
  local body = {}
  local function lifecycle_element(name, code, line)
    body[#body + 1] = ast.body_element({
      kind = ast.code_block_body_kind({ lifecycle = name, code = code }),
      source = name .. " { " .. code .. " }",
      line = line,
    })
  end
  lifecycle_element("I", 'set(state, "entered")', 1)
  lifecycle_element("LS", 'set(loop, "start")', 2)
  body[#body + 1] = ast.body_element({ kind = ast.regex_body_kind({ pattern = "a" }), source = "/a/", line = 3 })
  lifecycle_element("LE", "set(last, match_text())", 4)
  lifecycle_element("IT", 'set(iteration, "done")', 5)
  lifecycle_element("EX", 'set(extended, "done")', 6)
  lifecycle_element("LX", 'set(loop, "exit")', 7)
  lifecycle_element("E", "return(state)", 8)
  local spec = ast.spec_file({ rules = { compiled_test_rule("Top", true, ast.rule_mode("Plus"), body) } })
  local result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(spec)),
    "a"
  )
  assert_equal(result.value, "entered", "local scalar store")
  local names = {}
  for index, event in ipairs(result.lifecycle_events) do names[index] = event.lifecycle end
  assert_equal(table.concat(names, ","), "I,LS,LE,IT,LS,EX,LX,E", "lifecycle order")
end)

test("runtime interpreter guards bounds recursion zero progress and unsupported helpers", function()
  local bounded = compiled_test_rule("Top", true, ast.or_bounded_rule_mode({ min = 2, max = 2 }), {
    ast.body_element({ kind = ast.regex_body_kind({ pattern = "a" }), source = "/a/", line = 1 }),
  })
  local ok, bounded_error = pcall(function()
    linkedspec.runtime_parse(
      linkedspec.runtime_engine(linkedspec.compile_spec(ast.spec_file({ rules = { bounded } }))),
      "a"
    )
  end)
  assert_equal(ok, false, "bounded failure")
  assert_equal(linkedspec.is_runtime_interpreter_error(bounded_error), true, "bounded typed error")
  assert_contains(bounded_error.message, "expected at least 2 matches", "bounded detail")

  local recursive = compiled_test_rule("Top", true, ast.rule_mode("Or"), {
    ast.body_element({ kind = ast.regex_body_kind({ pattern = "" }), source = "//", line = 1 }),
    ast.body_element({ kind = ast.blind_edge_body_kind({ target = "Top" }), source = "=> Top", line = 1 }),
  })
  local recursive_result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(
      ast.spec_file({ rules = { recursive } }),
      { validate_source = false }
    )),
    ""
  )
  assert_equal(recursive_result.matched, false, "recursion cutoff")

  local zero = compiled_test_rule("Top", true, ast.rule_mode("Star"), {
    ast.body_element({ kind = ast.regex_body_kind({ pattern = "" }), source = "//", line = 1 }),
  })
  local zero_result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(ast.spec_file({ rules = { zero } }))),
    ""
  )
  assert_equal(zero_result.matched, true, "zero-width match remains present")
  assert_equal(zero_result.cursor_code_unit, 0, "zero-progress cutoff")

  local unsupported = linkedspec.compile_spec(linkedspec.parse_spec("Top::\n /x/ E { invented_helper() }\n"))
  local helper_ok, helper_error = pcall(
    linkedspec.runtime_parse,
    linkedspec.runtime_engine(unsupported),
    "x"
  )
  assert_equal(helper_ok, false, "unsupported runtime helper")
  assert_equal(linkedspec.is_runtime_interpreter_error(helper_error), true, "unsupported typed error")
end)

test("runtime trace events expose exact interpreter decisions without changing results", function()
  local function emitter()
    return linkedspec.trace_emitter(linkedspec.trace_config_enabled(linkedspec.TRACE_DEBUG), {
      stdout_writer = function() end,
    })
  end

  local function find_event(one_emitter, topic, details)
    for _, event in ipairs(linkedspec.trace_events(one_emitter)) do
      if event.topic == topic and (details == nil or event.details:find(details, 1, true)) then
        return event
      end
    end
    fail("missing trace event " .. topic .. (details and (" containing " .. details) or ""))
  end

  local source = [[
Top::AND
 I { mark_here(init_mark) }
 /BEGIN[ ]*/
 @capture_slice
 @mark(slot_mark)
 -> Child {
   save_cursor()
   body = capture_until_boundary(Boundary)
   restore_cursor()
   rewind_match_start()
   rewind_entry_start()
   mark_here(action_mark)
 }
 E {
   return({
     "body" : body,
     "action_mark" : mark_pos(action_mark),
     "slot_mark" : mark_pos(slot_mark)
   })
 }

Child:
 /CHILD[ ]*/
 E { return("child") }

Boundary: /STOP/
]]
  local engine = linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(source)))
  local untraced = linkedspec.runtime_parse(engine, "BEGIN CHILD gap STOP")
  local traced_emitter = emitter()
  local traced = linkedspec.runtime_parse(engine, "BEGIN CHILD gap STOP", { trace = traced_emitter })
  assert_equal(
    json.encode(linkedspec.interpreter.to_json(traced)),
    json.encode(linkedspec.interpreter.to_json(untraced)),
    "instrumented result identity"
  )
  assert_equal(traced.value.body, "gap ", "boundary result")

  find_event(traced_emitter, "lua_runtime:rule", "rule=Top entry_regex=0 mode=And")
  find_event(traced_emitter, "lua_runtime:regex_match", "rule=Top mode=AND expected_index=0")
  find_event(traced_emitter, "lua_runtime:regex_match", "rule=Child entry_regex=0")
  find_event(traced_emitter, "lua_runtime:child_dispatch", "edge_family=action rule=Top target=Child[0]")
  find_event(traced_emitter, "lua_runtime:lifecycle_block", "rule=Top lifecycle=I")
  find_event(traced_emitter, "lua_runtime:lifecycle_block", "rule=Top lifecycle=E")
  for _, helper in ipairs({ "save_cursor", "restore_cursor", "rewind_match_start", "rewind_entry_start" }) do
    find_event(traced_emitter, "lua_runtime:cursor_control", "helper=" .. helper .. " rule=Top")
  end
  find_event(traced_emitter, "lua_runtime:source_boundary", "helper=capture_until_boundary rule=Top")
  find_event(traced_emitter, "lua_runtime:source_boundary", "found=1")
  find_event(traced_emitter, "lua_runtime:mark_capture", "source=helper rule=Top helper=mark_here")
  find_event(traced_emitter, "lua_runtime:mark_capture", "source=rule_slot rule=Top kind=capture_boundary")
  find_event(traced_emitter, "lua_runtime:mark_capture", "source=rule_slot rule=Top kind=named_mark")

  local enter_count = 0
  local exit_count = 0
  for _, event in ipairs(linkedspec.trace_events(traced_emitter)) do
    if event.kind == linkedspec.TRACE_ENTER then enter_count = enter_count + 1 end
    if event.kind == linkedspec.TRACE_EXIT then exit_count = exit_count + 1 end
  end
  assert_equal(exit_count, enter_count, "runtime scopes stay balanced")

  local miss_untraced = linkedspec.runtime_parse(engine, "MISS")
  local miss_emitter = emitter()
  local miss_traced = linkedspec.runtime_parse(engine, "MISS", { trace = miss_emitter })
  assert_equal(
    json.encode(linkedspec.interpreter.to_json(miss_traced)),
    json.encode(linkedspec.interpreter.to_json(miss_untraced)),
    "no-match trace result identity"
  )
  local miss_event = find_event(miss_emitter, "lua_runtime:regex_match", "rule=Top mode=AND expected_index=0")
  assert_contains(miss_event.details, "taken=0", "regex no-match decision")

  local recursive = compiled_test_rule("Top", true, ast.rule_mode("Or"), {
    ast.body_element({ kind = ast.regex_body_kind({ pattern = "" }), source = "//", line = 1 }),
    ast.body_element({ kind = ast.blind_edge_body_kind({ target = "Top" }), source = "=> Top", line = 1 }),
  })
  local recursive_engine = linkedspec.runtime_engine(linkedspec.compile_spec(
    ast.spec_file({ rules = { recursive } }),
    { validate_source = false }
  ))
  local recursive_untraced = linkedspec.runtime_parse(recursive_engine, "")
  local recursive_emitter = emitter()
  local recursive_traced = linkedspec.runtime_parse(recursive_engine, "", { trace = recursive_emitter })
  assert_equal(
    json.encode(linkedspec.interpreter.to_json(recursive_traced)),
    json.encode(linkedspec.interpreter.to_json(recursive_untraced)),
    "recursion trace result identity"
  )
  find_event(recursive_emitter, "lua_runtime:recursion_guard", "rule=Top entry_regex=0 cursor=0")
  find_event(recursive_emitter, "lua_runtime:child_dispatch", "edge_family=blind mode=OR rule=Top")
end)

test("runtime failures carry neutral structured diagnostics with deepest rule attribution", function()
  local compiled = linkedspec.compile_spec(linkedspec.parse_spec("Top::\n /x/\n"))
  local identified = linkedspec.runtime_engine(compiled, {
    spec_name = "diagnostic.spec",
    spec_path = "specs/diagnostic.spec",
  })
  local missing_ok, missing_error = pcall(
    linkedspec.runtime_parse,
    identified,
    "x",
    { top_rule = "Missing" }
  )
  assert_equal(missing_ok, false, "missing selected rule fails")
  assert_equal(linkedspec.is_runtime_interpreter_error(missing_error), true, "missing rule typed error")
  assert_equal(linkedspec.interpreter.node_type(missing_error), "RuntimeInterpreterException", "error node type")
  assert_equal(missing_error.message, "rule 'Missing' is not compiled", "missing rule text stays unchanged")
  assert_equal(
    tostring(missing_error),
    "RuntimeInterpreterException: rule 'Missing' is not compiled",
    "missing rule display stays unchanged"
  )
  assert_equal(linkedspec.is_runtime_diagnostic(missing_error.diagnostic), true, "missing rule diagnostic type")
  assert_equal(
    json.encode(linkedspec.interpreter.to_json(missing_error.diagnostic)),
    json.encode(json.harray({
      type = "runtime_parser",
      stage = "rule_lookup",
      owner_stage = "lua_runtime",
      summary = "Lua runtime rule lookup failed",
      detail = "rule 'Missing' is not compiled",
      spec_name = "diagnostic.spec",
      spec_path = "specs/diagnostic.spec",
      top_rule = "Missing",
      rule_label = "Missing",
      handler_source_label = "lua_runtime:rule:Missing",
    })),
    "missing rule diagnostic JSON"
  )
  assert_equal(
    json.encode(linkedspec.interpreter.to_json(missing_error)),
    json.encode(json.harray({
      message = "rule 'Missing' is not compiled",
      diagnostic = linkedspec.interpreter.to_json(missing_error.diagnostic),
    })),
    "runtime error JSON carries diagnostic"
  )

  local child_engine = linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec([[
Top::
 -> Child

Child:
 /x/
 E { invented_helper() }
]])))
  local child_ok, child_error = pcall(linkedspec.runtime_parse, child_engine, "x")
  assert_equal(child_ok, false, "child helper failure")
  assert_contains(child_error.message, "invented_helper", "child error text")
  local child_diagnostic = linkedspec.interpreter.to_json(child_error.diagnostic)
  assert_equal(child_diagnostic.stage, "runtime_execution", "child stage")
  assert_equal(child_diagnostic.summary, "Lua runtime interpreter failed", "child summary")
  assert_equal(child_diagnostic.top_rule, "Top", "child top rule")
  assert_equal(child_diagnostic.rule_label, "Child", "deepest child rule survives unwind")
  assert_equal(
    child_diagnostic.handler_source_label,
    "lua_runtime:rule:Child",
    "deepest child handler survives unwind"
  )
  assert_equal(child_diagnostic.spec_name, nil, "absent spec name omitted")
  assert_equal(child_diagnostic.spec_path, nil, "absent spec path omitted")

  local lookup_engine = linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec([[
Top::
 /x/
 E { call(Missing) }
]])))
  local lookup_ok, lookup_error = pcall(linkedspec.runtime_parse, lookup_engine, "x")
  assert_equal(lookup_ok, false, "nested missing rule fails")
  assert_equal(lookup_error.diagnostic.stage, "rule_lookup", "richer nested stage is preserved")
  assert_equal(lookup_error.diagnostic.top_rule, "Top", "nested lookup top rule")
  assert_equal(lookup_error.diagnostic.rule_label, "Missing", "nested lookup target attribution")

  local empty_compiled = linkedspec.compile_spec(ast.spec_file({ rules = {} }), { validate_source = false })
  local empty_ok, empty_error = pcall(
    linkedspec.runtime_parse,
    linkedspec.runtime_engine(empty_compiled),
    ""
  )
  assert_equal(empty_ok, false, "empty compiled state fails")
  assert_equal(empty_error.diagnostic.stage, "top_rule_selection", "empty state stage")
  assert_equal(empty_error.diagnostic.handler_source_label, "lua_runtime", "empty state handler")

  local input_ok, input_error = pcall(linkedspec.runtime_parse, identified, string.char(255))
  assert_equal(input_ok, false, "invalid UTF-8 runtime input fails")
  assert_equal(input_error.diagnostic.stage, "runtime_input", "invalid input stage")
  assert_equal(input_error.diagnostic.top_rule, "Top", "invalid input top rule")
  assert_equal(input_error.diagnostic.rule_label, "Top", "invalid input effective rule")

  local success = linkedspec.runtime_parse(identified, "x")
  assert_equal(linkedspec.interpreter.node_type(success), "RuntimeParseResult", "successful result type unchanged")
  assert_equal(success.matched, true, "successful match unchanged")
  assert_equal(success.cursor_code_unit, 1, "successful cursor unchanged")
  assert_equal(success.value, json.null, "successful value unchanged")
  assert_equal(success.output[1], json.null, "successful output unchanged")
end)

test("runtime control and local stores match the cross-backend rule contract", function()
  local next_engine = linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec([[
Top::
 /skip/ { next() }
 /keep/
 E { return(match_text()) }
]])))
  local next_result = linkedspec.runtime_parse(next_engine, "skipkeep")
  assert_equal(next_result.value, "keep", "next advances to the next rule iteration")
  assert_equal(next_result.cursor_code_unit, 8, "next preserves cursor progress")

  local scoped_engine = linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec([[
Top::
 /a/ -> Child { set(shared, "parent") }
 E { return(shared) }

Child:
 /b/
 LE { set(shared, "child") }
 E { return(shared) }
]])))
  local scoped_result = linkedspec.runtime_parse(scoped_engine, "ab")
  assert_equal(scoped_result.value, "parent", "child local store does not leak into caller")

  local false_engine = linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec([[
Top::
 /a/ -> Child

Child:
 /b/
 E { return(false) }
]])))
  local false_result = linkedspec.runtime_parse(false_engine, "ab")
  assert_equal(false_result.value, false, "false child return is not replaced by null")
  assert_equal(false_result.output[1], false, "false direct output is preserved")

  local exit_engine = linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec([[
Top::
 /x/
 E { exit_now(7); return("unreachable") }
]])))
  local exit_ok, exit_error = pcall(linkedspec.runtime_parse, exit_engine, "x")
  assert_equal(exit_ok, false, "exit_now terminates immediately")
  assert_equal(linkedspec.is_runtime_interpreter_error(exit_error), true, "exit_now typed error")
  assert_equal(exit_error.message, "exit_now(7) in rule Top", "exit_now detail")
  assert_equal(exit_error.status, 7, "exit_now status")
end)

test("runtime diagnostic output is eager ordered Unicode-safe and caller-owned", function()
  local function assert_same_json(actual, expected, label)
    assert_equal(json.encode(actual), json.encode(expected), label)
  end
  local source = [[
Top::
 /x/
 E {
   seen = []
   items = ["α", false, undef, "🙂"]
   print({ push(seen, "print-left"); return("pré") }, { push(seen, "print-right"); return("🙂") })
   say({ push(seen, "say"); return(" ligne") })
   print_each(
     { push(seen, "items"); return(items) },
     { push(seen, "prefix"); return("élément:") },
     { push(seen, "suffix"); return("!") }
   )
   print_each(items, "raw:")
   return(copy(seen))
 }
]]
  local engine = linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(source)))
  local events = {}
  local result = linkedspec.runtime_parse(engine, "x", {
    diagnostic_sink = function(event) events[#events + 1] = event end,
  })

  assert_same_json(result.value, json.decode(
    '["print-left","print-right","say","items","prefix","suffix"]'
  ), "diagnostic arguments evaluate once from left to right")
  assert_same_json(result.output, json.array({ result.value }), "diagnostics stay out of parse output")
  assert_equal(#events, 10, "one ordered event per print/say or print_each item")
  local expected = {
    { "print", "pré🙂" },
    { "say", " ligne\n" },
    { "print_each", "élément:α!" },
    { "print_each", "élément:0!" },
    { "print_each", "élément:!" },
    { "print_each", "élément:🙂!" },
    { "print_each", "raw:α" },
    { "print_each", "raw:0" },
    { "print_each", "raw:" },
    { "print_each", "raw:🙂" },
  }
  for index, expected_event in ipairs(expected) do
    local event = events[index]
    assert_equal(linkedspec.interpreter.node_type(event), "RuntimeDiagnosticOutputEvent", "event type " .. index)
    assert_equal(event.helper_name, expected_event[1], "event helper " .. index)
    assert_equal(event.rule_label, "Top", "event rule " .. index)
    assert_equal(event.message, expected_event[2], "event message " .. index)
  end
  assert_equal(
    json.decode(json.encode(linkedspec.interpreter.to_json(events[1]))).message,
    "pré🙂",
    "event JSON"
  )

  local quiet = linkedspec.runtime_parse(engine, "x")
  assert_same_json(quiet.value, result.value, "missing sink stays quiet without skipping evaluation")
  assert_same_json(quiet.output, result.output, "missing sink preserves structural parse output")

  assert_error_contains(function()
    linkedspec.runtime_parse(engine, "x", { diagnostic_sink = {} })
  end, "diagnostic_sink must be a function", "invalid diagnostic sink")

  local invalid_arity = linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec([[
Top::
 /x/
 E { print_each(["x"]); return("unreachable") }
]])))
  assert_error_contains(function()
    linkedspec.runtime_parse(invalid_arity, "x", { diagnostic_sink = function() end })
  end, "helper 'print_each' expects 2 or 3 positional arguments", "print_each arity")

  local exit_engine = linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec([[
Top::
 /x/
 E { say("before"); exit_now(23); say("after") }
]])))
  local exit_events = {}
  local exit_ok, exit_error = pcall(linkedspec.runtime_parse, exit_engine, "x", {
    diagnostic_sink = function(event) exit_events[#exit_events + 1] = event end,
  })
  assert_equal(exit_ok, false, "exit_now still terminates immediately")
  assert_equal(linkedspec.is_runtime_interpreter_error(exit_error), true, "exit_now remains typed")
  assert_equal(exit_error.status, 23, "exit_now retains status")
  assert_equal(#exit_events, 1, "post-exit output is not evaluated")
  assert_equal(exit_events[1].message, "before\n", "pre-exit event is delivered")
end)

test("runtime core stores snapshots and checked access preserve typed values", function()
  local source = [[
Top::
 /x/
 I {
   scalar_value = false
   items = [1, { "name" : "old" }]
   meta = { "kind" : "base" }
   set(named_items, ["a"])
   set(named_meta, { "x" : 1 })
   items += 3
   meta["added"] = false
   items[1]["name"] = "new"
   items_snapshot = copy(items)
   meta_snapshot = copy(meta)
   items += 4
   meta["kind"] = "changed"
   items[8]["name"] = "forbidden"
 }
 E {
   return({
     "scalar_kind" : scalar_value,
     "items" : items,
     "meta" : meta,
     "items_snapshot" : items_snapshot,
     "meta_snapshot" : meta_snapshot,
     "named_items" : named_items,
     "named_meta" : named_meta,
     "nested" : items[1]["name"],
     "indexed" : meta["added"],
     "missing" : items[8]
   })
 }
]]
  local result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(source))),
    "x"
  )
  assert_equal(linkedspec.runtime_value_kind(result.value), "harray", "result harray kind")
  assert_equal(result.value.scalar_kind, false, "false scalar identity")
  assert_equal(json.kind(result.value.items), "array", "scalar-held array identity")
  assert_equal(#result.value.items, 4, "array append count")
  assert_equal(result.value.items[2].name, "new", "nested array-harray assignment")
  assert_equal(result.value.meta.kind, "changed", "hash-index assignment")
  assert_equal(result.value.meta.added, false, "false hash value")
  assert_equal(#result.value.items_snapshot, 3, "array snapshot isolation")
  assert_equal(result.value.meta_snapshot.kind, "base", "harray snapshot isolation")
  assert_equal(result.value.named_items[1], "a", "named array store")
  assert_equal(result.value.named_meta.x, 1, "named harray store")
  assert_equal(result.value.nested, "new", "nested access")
  assert_equal(result.value.indexed, false, "indexed false access")
  assert_equal(result.value.missing, json.null, "checked missing access")

  local eager_block_result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec([[
Top::
 /x/
 I { callback = { return("later") } }
 E { return(callback) }
]]))),
    "x"
  )
  assert_equal(linkedspec.runtime_value_kind(eager_block_result.value), "scalar", "ordinary block is eager")
  assert_equal(eager_block_result.value, "later", "ordinary block returns its local payload")
  assert_equal(linkedspec.runtime_value_kind(json.null), "scalar", "null scalar kind")
  assert_equal(linkedspec.runtime_value_kind(json.array()), "array", "empty array kind")
end)

test("runtime nested assignment preserves segment kinds order and atomic failure", function()
  local result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec([[
Top::
 /x/
 I {
   payload = { "items" : [{ "name" : "old" }] }
   dynamic_index = "0"
   payload["items"][dynamic_index]["name"] = "new"
   payload["items"][1] = { "name" : "tail" }
   wrong_result = payload["items"][0][0] = "bad"
   index_seen = -1
   rhs_seen = "before"
   missing_result = payload["missing"][index_seen = 0] = (rhs_seen = "after")
 }
 E {
   return(array(
     payload,
     wrong_result,
     missing_result,
     index_seen,
     rhs_seen,
     payload["items"][0][0],
     payload["items"][0]["name"]
   ))
 }
]]))),
    "x"
  )
  assert_equal(json.encode(result.value[1]), [[{"items":[{"name":"new"},{"name":"tail"}]}]], "valid path root")
  assert_equal(result.value[2], json.null, "numeric segment rejects harray write")
  assert_equal(result.value[3], json.null, "missing intermediate rejects write")
  assert_equal(result.value[4], 0, "all index expressions evaluate before path validation")
  assert_equal(result.value[5], "after", "RHS evaluates before path validation")
  assert_equal(result.value[6], json.null, "numeric segment rejects harray read")
  assert_equal(result.value[7], "new", "typed key path reads updated value")
end)

test("runtime executes exact nested assignment core corpus fixture", function()
  local corpus = linkedspec.load_corpus_fixtures("rust/linkedspec-runtime/tests/corpus")
  local fixture = corpus.fixtures[21]
  assert_equal(fixture.name, "terse_11_4_nested_mixed_value_path_assignment", "manifest offset 20")
  local parsed = linkedspec.parse_spec_with_staged_user_function_definitions(fixture.spec_source)
  assert_equal(linkedspec.validate_spec(parsed), nil, "fixture validation")
  local engine = linkedspec.runtime_engine(
    linkedspec.compile_spec(parsed, { validate_source = false }),
    {
      spec_name = fixture.name,
      spec_path = corpus.root .. "/" .. fixture.name .. "/input.spec",
    }
  )
  local result = linkedspec.runtime_parse(engine, fixture.input_text)
  assert_equal(result.matched, true, "fixture matched")
  assert_equal(result.cursor_code_unit, 1, "fixture byte endpoint remains unchanged")
  assert_equal(result.cursor_char_offset, 1, "fixture character endpoint remains unchanged")
  assert_equal(
    json.encode(result.output),
    json.encode(json.array({ fixture.expected_json })),
    "fixture exact wrapped output"
  )
end)

test("runtime entry and match helper families expose captures and Unicode positions", function()
  local source = [[
Top::
 /(?<name>\w+)=(\d+)/
 E {
   return({
     "entry_text" : entry_text(),
     "match_text" : match_text(),
     "entry_group_0" : entry_group(0),
     "match_group_1" : match_group(1),
     "entry_groups" : entry_groups(),
     "match_groups" : match_groups(),
     "entry_named" : entry_named(name),
     "match_named" : match_named(name),
     "entry_has" : entry_has(name),
     "match_has" : match_has(name),
     "entry_map" : entry_map(),
     "match_map" : match_map(),
     "entry_len" : entry_len(),
     "match_len" : match_len(),
     "entry_start" : entry_start_pos(),
     "entry_end" : entry_end_pos(),
     "match_start" : match_start_pos(),
     "match_end" : match_end_pos(),
     "entry_line" : entry_line(),
     "entry_col" : entry_col(),
     "entry_start_line" : entry_start_line(),
     "entry_start_col" : entry_start_col(),
     "entry_end_line" : entry_end_line(),
     "entry_end_col" : entry_end_col(),
     "match_line" : match_line(),
     "match_col" : match_col(),
     "match_start_line" : match_start_line(),
     "match_start_col" : match_start_col(),
     "match_end_line" : match_end_line(),
     "match_end_col" : match_end_col()
   })
 }
]]
  local result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(source))),
    "é\nkey=42"
  )
  assert_equal(result.value.entry_text, "key=42", "entry text")
  assert_equal(result.value.match_text, "key=42", "match text")
  assert_equal(result.value.entry_group_0, "key", "entry compact capture")
  assert_equal(result.value.match_group_1, "42", "match compact capture")
  assert_equal(table.concat(result.value.entry_groups, ","), "key,42", "entry capture list")
  assert_equal(table.concat(result.value.match_groups, ","), "key,42", "match capture list")
  assert_equal(result.value.entry_named, "key", "entry named capture")
  assert_equal(result.value.match_named, "key", "match named capture")
  assert_equal(result.value.entry_has, 1, "entry named presence")
  assert_equal(result.value.match_has, 1, "match named presence")
  assert_equal(result.value.entry_map.name, "key", "entry named map")
  assert_equal(result.value.match_map.name, "key", "match named map")
  assert_equal(result.value.entry_len, 6, "entry character length")
  assert_equal(result.value.match_len, 6, "match character length")
  assert_equal(result.value.entry_start, 2, "entry character start")
  assert_equal(result.value.entry_end, 8, "entry character end")
  assert_equal(result.value.match_start, 2, "match character start")
  assert_equal(result.value.match_end, 8, "match character end")
  assert_equal(result.value.entry_line, 2, "entry line alias")
  assert_equal(result.value.entry_col, 1, "entry column alias")
  assert_equal(result.value.entry_start_line, 2, "entry start line")
  assert_equal(result.value.entry_start_col, 1, "entry start column")
  assert_equal(result.value.entry_end_line, 2, "entry end line")
  assert_equal(result.value.entry_end_col, 7, "entry end column")
  assert_equal(result.value.match_line, 2, "match line alias")
  assert_equal(result.value.match_col, 1, "match column alias")
  assert_equal(result.value.match_start_line, 2, "match start line")
  assert_equal(result.value.match_start_col, 1, "match start column")
  assert_equal(result.value.match_end_line, 2, "match end line")
  assert_equal(result.value.match_end_col, 7, "match end column")
end)

test("runtime absent match helpers preserve null empty and origin distinctions", function()
  local result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec([[
Top::
 /x/
 I {
   return({
     "text" : match_text(),
     "group" : match_group(0),
     "groups" : match_groups(),
     "named" : match_named(name),
     "has" : match_has(name),
     "map" : match_map(),
     "len" : match_len(),
     "start" : match_start_pos(),
     "end" : match_end_pos(),
     "line" : match_line(),
     "col" : match_col()
   })
 }
]]))),
    "x"
  )
  assert_equal(result.value.text, json.null, "absent match text")
  assert_equal(result.value.group, json.null, "absent match group")
  assert_equal(json.kind(result.value.groups), "array", "absent groups type")
  assert_equal(#result.value.groups, 0, "absent groups empty")
  assert_equal(result.value.named, json.null, "absent named capture")
  assert_equal(result.value.has, 0, "absent named presence")
  assert_equal(json.kind(result.value.map), "harray", "absent map type")
  assert_equal(result.value.len, json.null, "absent match length")
  assert_equal(result.value.start, json.null, "absent start")
  assert_equal(result.value["end"], json.null, "absent end")
  assert_equal(result.value.line, 1, "absent line origin")
  assert_equal(result.value.col, 1, "absent column origin")
end)

test("runtime input cursor views and explicit controls are Unicode exact", function()
  local source = [[
Top::AND
 => Value

Value:AND
 /é/
 /ab🙂/
 -> Value[1] {
   after_match = cursor_pos()
   line = cursor_line()
   col = cursor_col()
   rest = cursor_rest()
   rest_len = cursor_rest_len()
   rest_upper = cursor_rest().uppercase()
   whole = input_text()
   whole_len = input_len()
   slice = input_slice(1, 4)
   end_pos = input_end_pos()
   end_line = input_end_line()
   end_col = input_end_col()
   invalid_slice = input_slice("bad", 2)
   negative_start = input_slice(-2, 3)
   negative_width = input_slice(1, -2)
   past_slice = input_slice(99, 2)
   save_cursor()
   rewind_match_start()
   match_start = cursor_pos()
   match_rest = cursor_rest()
   save_cursor()
   rewind_entry_start()
   entry_start = cursor_pos()
   restore_cursor()
   restored_match = cursor_pos()
   restore_cursor()
   restored_original = cursor_pos()
   restore_cursor()
   empty_restore = cursor_pos()
   return({
     "after_match" : after_match,
     "line" : line,
     "col" : col,
     "rest" : rest,
     "rest_len" : rest_len,
     "rest_upper" : rest_upper,
     "whole" : whole,
     "whole_len" : whole_len,
     "slice" : slice,
     "end_pos" : end_pos,
     "end_line" : end_line,
     "end_col" : end_col,
     "invalid_slice" : invalid_slice,
     "negative_start" : negative_start,
     "negative_width" : negative_width,
     "past_slice" : past_slice,
     "match_start" : match_start,
     "match_rest" : match_rest,
     "entry_start" : entry_start,
     "restored_match" : restored_match,
     "restored_original" : restored_original,
     "empty_restore" : empty_restore
   })
 }
]]
  local result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(source))),
    "é\nab🙂z"
  )
  local value = result.value[1]
  assert_equal(value.after_match, 5, "cursor character position")
  assert_equal(value.line, 2, "cursor line")
  assert_equal(value.col, 4, "cursor column")
  assert_equal(value.rest, "z", "cursor remainder")
  assert_equal(value.rest_len, 1, "cursor remainder character length")
  assert_equal(value.rest_upper, "Z", "cursor remainder receiver chain")
  assert_equal(value.whole, "é\nab🙂z", "whole input")
  assert_equal(value.whole_len, 6, "whole input character length")
  assert_equal(value.slice, "\nab🙂", "whole input character slice")
  assert_equal(value.end_pos, 6, "input end character position")
  assert_equal(value.end_line, 2, "input end line")
  assert_equal(value.end_col, 5, "input end column")
  assert_equal(value.invalid_slice, json.null, "invalid input slice boundary")
  assert_equal(value.negative_start, "é\na", "negative input slice start clamps to zero")
  assert_equal(value.negative_width, "", "negative input slice width clamps to zero")
  assert_equal(value.past_slice, "", "past-end input slice")
  assert_equal(value.match_start, 2, "local-match rewind")
  assert_equal(value.match_rest, "ab🙂z", "local-match rewind remainder")
  assert_equal(value.entry_start, 0, "entry-match rewind")
  assert_equal(value.restored_match, 2, "nested cursor restore")
  assert_equal(value.restored_original, 5, "outer cursor restore")
  assert_equal(value.empty_restore, 5, "empty cursor restore is a no-op")

  local consume_source = [[
Top::AND
 /ab/
 /ab/
 -> Top[0] { rewind_match_start() }
 -> Top[1] { return(cursor_pos()) }
]]
  local consume = linkedspec.runtime_parse(
    linkedspec.runtime_engine(
      linkedspec.compile_spec(linkedspec.parse_spec(consume_source)),
      { parse_mode = "consume" }
    ),
    "ab"
  )
  assert_equal(consume.value, 2, "rewound cursor controls consume continuation")

  local absent_rewind = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec([[
Top::
 /x/
 I { rewind_match_start(); rewind_entry_start(); return(cursor_pos()) }
]]))),
    "x"
  )
  assert_equal(absent_rewind.value, 0, "absent-anchor rewinds are no-ops")

  for _, malformed in ipairs({
    { action = "return(input_slice(0))", helper = "input_slice", actual = 1 },
    { action = "save_cursor(1)", helper = "save_cursor", actual = 1 },
  }) do
    local invalid_source = "Top::\n /x/ I { " .. malformed.action .. " }\n"
    local ok, failure = pcall(function()
      linkedspec.runtime_parse(
        linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(invalid_source))),
        "x"
      )
    end)
    assert_equal(ok, false, malformed.helper .. " malformed arity fails")
    assert_equal(linkedspec.is_runtime_interpreter_error(failure), true, malformed.helper .. " typed failure")
    assert_equal(failure.code, "helper_arity_mismatch", malformed.helper .. " diagnostic code")
    assert_equal(failure.helper_name, malformed.helper, malformed.helper .. " helper attribution")
    assert_equal(failure.actual_arity, malformed.actual, malformed.helper .. " actual arity")
  end
end)

test("runtime anonymous capture helpers share one Unicode-exact rolling boundary", function()
  local source = [[
Top::AND
 => Value

Value:AND
 /é\n/
 /body🙂/
 /Z/
 -> Value[0] { setter_result = start_capture_slice() }
 -> Value[2] {
   return({
     "setter_result" : setter_result,
     "slice" : capture_slice(),
     "slice_len" : capture_slice_len(),
     "slice_upper" : capture_slice().uppercase(),
     "slice_len_plus_one" : capture_slice_len().add(1),
     "pos" : capture_slice_pos(),
     "pos_plus_three" : capture_slice_pos().add(3),
     "line" : capture_slice_line(),
     "col" : capture_slice_col(),
     "until_cursor" : capture_slice_until_cursor(),
     "until_cursor_len" : capture_slice_until_cursor_len(),
     "rest" : capture_rest(),
     "rest_len" : capture_rest_len()
   })
 }
]]
  local result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(source))),
    "é\nbody🙂Ztail"
  )
  local value = result.value[1]
  assert_equal(value.setter_result, json.null, "capture setter is void")
  assert_equal(value.slice, "body🙂", "capture to local-match start")
  assert_equal(value.slice_len, 5, "capture local span character length")
  assert_equal(value.slice_upper, "BODY🙂", "capture text receiver continuation")
  assert_equal(value.slice_len_plus_one, 6, "capture length receiver continuation")
  assert_equal(value.pos, 2, "capture start character position")
  assert_equal(value.pos_plus_three, 5, "capture position receiver continuation")
  assert_equal(value.line, 2, "capture start line")
  assert_equal(value.col, 1, "capture start column")
  assert_equal(value.until_cursor, "body🙂Z", "capture through live cursor")
  assert_equal(value.until_cursor_len, 6, "capture through-cursor character length")
  assert_equal(value.rest, "body🙂Ztail", "capture through input end")
  assert_equal(value.rest_len, 10, "capture rest character length")

  local advancing_cases = {
    { helper = "capture_take", expected = "body🙂", pos = 8, rest = "tail" },
    { helper = "capture_take_len", expected = 5, pos = 8, rest = "tail" },
    { helper = "capture_take_until_cursor", expected = "body🙂Z", pos = 8, rest = "tail" },
    { helper = "capture_take_until_cursor_len", expected = 6, pos = 8, rest = "tail" },
    { helper = "capture_take_rest", expected = "body🙂Ztail", pos = 12, rest = "" },
    { helper = "capture_take_rest_len", expected = 10, pos = 12, rest = "" },
  }
  for _, case in ipairs(advancing_cases) do
    local advancing_source = [[
Top::AND
 => Value

Value:AND
 /é\n/
 /body🙂/
 /Z/
 -> Value[0] { start_capture_slice() }
 -> Value[2] {
   captured = ]] .. case.helper .. [[()
   return({
     "captured" : captured,
     "pos" : capture_slice_pos(),
     "rest" : capture_rest()
   })
 }
]]
    local advancing = linkedspec.runtime_parse(
      linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(advancing_source))),
      "é\nbody🙂Ztail"
    ).value[1]
    assert_equal(advancing.captured, case.expected, case.helper .. " result")
    assert_equal(advancing.pos, case.pos, case.helper .. " advances only its boundary")
    assert_equal(advancing.rest, case.rest, case.helper .. " remaining text")
  end

  local invalid = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec([[
Top::AND
 => Value

Value:AND
 /é\n/
 /body🙂/
 /Z/
 -> Value[0] {
   start_capture_slice()
   invalid_take = capture_take()
   start_after_invalid = capture_slice_pos()
 }
 -> Value[2] {
   return({
     "invalid_take" : invalid_take,
     "start_after_invalid" : start_after_invalid,
     "slice_after_invalid" : capture_slice()
   })
 }
]]))),
    "é\nbody🙂Ztail"
  ).value[1]
  assert_equal(invalid.invalid_take, json.null, "reversed capture span is neutral")
  assert_equal(invalid.start_after_invalid, 2, "invalid take preserves boundary")
  assert_equal(invalid.slice_after_invalid, "body🙂", "valid read survives invalid take")

  for _, malformed in ipairs({
    { call = "capture_slice(1)", helper = "capture_slice" },
    { call = "start_capture_slice(1)", helper = "start_capture_slice" },
  }) do
    local invalid_source = "Top::\n /x/ I { return(" .. malformed.call .. ") }\n"
    local ok, failure = pcall(function()
      linkedspec.runtime_parse(
        linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(invalid_source))),
        "x"
      )
    end)
    assert_equal(ok, false, malformed.helper .. " malformed arity fails")
    assert_equal(linkedspec.is_runtime_interpreter_error(failure), true, malformed.helper .. " typed failure")
    assert_equal(failure.code, "helper_arity_mismatch", malformed.helper .. " diagnostic code")
    assert_equal(failure.helper_name, malformed.helper, malformed.helper .. " helper attribution")
    assert_equal(failure.expected_arity, "exactly 0 positional arguments", malformed.helper .. " expected arity")
    assert_equal(failure.actual_arity, 1, malformed.helper .. " actual arity")
  end
end)

test("runtime boundary capture seeks earliest usable rule without consuming it", function()
  local source = [[
Top::AND
 /é🙂:[ \t]*/
 -> Top[0] {
   body = capture_until_boundary(EndBoundary, MissingBoundary, NextBoundary)
   return({
     "body" : body,
     "cursor" : cursor_pos(),
     "rest" : cursor_rest()
   })
 }

NextBoundary: /@b:/
EndBoundary: /END/
]]
  local result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(
      linkedspec.compile_spec(linkedspec.parse_spec(source)),
      { parse_mode = "consume" }
    ),
    "é🙂: α @b: tail END"
  ).value
  assert_equal(result.body, "α ", "earliest boundary capture")
  assert_equal(result.cursor, 6, "boundary cursor uses Unicode character position")
  assert_equal(result.rest, "@b: tail END", "boundary token remains unconsumed")

  local chained = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec([[
Top::AND
 /é🙂:[ \t]*/
 -> Top[0] { return(capture_until_boundary("NextBoundary").trim()) }

NextBoundary: /@b:/
]]))),
    "é🙂: α @b: tail"
  ).value
  assert_equal(chained, "α", "quoted boundary result receiver continuation")

  local eof = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec([[
Top::AND
 /é🙂:[ \t]*/
 -> Top[0] {
   body = capture_until_boundary(EndBoundary)
   return({ "body" : body, "cursor" : cursor_pos(), "rest" : cursor_rest() })
 }

EndBoundary: /END/
]]))),
    "é🙂: tail🙂"
  ).value
  assert_equal(eof.body, "tail🙂", "usable missing boundary captures to input end")
  assert_equal(eof.cursor, 9, "EOF fallback moves cursor to character end")
  assert_equal(eof.rest, "", "EOF fallback leaves empty remainder")

  local unusable = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec([[
Top::AND
 /é🙂:[ \t]*/
 -> Top[0] {
   before = cursor_pos()
   zero = capture_until_boundary()
   missing = capture_until_boundary(MissingBoundary, EmptyBoundary)
   return({
     "before" : before,
     "zero" : zero,
     "missing" : missing,
     "after" : cursor_pos(),
     "rest" : cursor_rest()
   })
 }

EmptyBoundary:AND
 I { return("unused") }
]]))),
    "é🙂: tail"
  ).value
  assert_equal(unusable.before, 4, "unusable boundary start position")
  assert_equal(unusable.zero, json.null, "zero boundaries are neutral pending arity normalization")
  assert_equal(unusable.missing, json.null, "unresolved and regex-free boundaries are neutral")
  assert_equal(unusable.after, 4, "unusable boundaries preserve cursor")
  assert_equal(unusable.rest, "tail", "unusable boundaries preserve remainder")
end)

test("runtime complete named marks match the neutral Unicode rule-local contract", function()
  local contract = json.decode(read_file("capability_conformance/complete_named_mark_contract.json"))
  assert_equal(contract.contract_id, "linkedspec-complete-named-mark-v1", "named-mark contract id")
  local parsed = linkedspec.parse_spec(contract.fixture.spec_source)
  local compiled = linkedspec.compile_spec(parsed)
  local result = linkedspec.runtime_parse(linkedspec.runtime_engine(compiled), contract.fixture.input)
  assert_equal(
    json.encode(result.value),
    json.encode(contract.fixture.expected),
    "complete named-mark fixture"
  )

  local serialized = json.encode(linkedspec.spec_ast.to_json(parsed))
  local reconstructed = linkedspec.compile_spec(
    linkedspec.spec_ast.from_json("SpecFile", json.decode(serialized))
  )
  local reconstructed_result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(reconstructed),
    contract.fixture.input
  )
  assert_equal(
    json.encode(reconstructed_result.value),
    json.encode(contract.fixture.expected),
    "serialized named-mark fixture"
  )
end)

test("runtime governed named spans and anonymous bridges are exact", function()
  local governed_source = read_file("capability_conformance/fixtures/capability_capture_named_surface.spec")
  local governed_parsed = linkedspec.parse_spec(governed_source)
  local governed_expected = json.decode([[
[
  {
    "between": "xxBC", "between_len": 4, "copied_pos": 1,
    "from": "xxB", "from_len": 3, "origin_exists": 1, "origin_pos": 1,
    "rest": "xxBC", "rest_len": 4,
    "take_between": "xxBC", "take_between_len": 4, "take_len": 3,
    "take_rest": "xxBC", "take_rest_len": 4,
    "take_until_cursor": "xxBC", "take_until_cursor_len": 4,
    "until_cursor": "xxBC", "until_cursor_len": 4,
    "whole_input": "AxxBC"
  }
]
]])
  local governed_result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(governed_parsed)),
    "AxxBC"
  )
  assert_equal(
    json.encode(governed_result.value),
    json.encode(governed_expected),
    "governed named-span fixture"
  )

  local governed_serialized = json.encode(linkedspec.spec_ast.to_json(governed_parsed))
  local governed_reconstructed = linkedspec.compile_spec(
    linkedspec.spec_ast.from_json("SpecFile", json.decode(governed_serialized))
  )
  local governed_reconstructed_result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(governed_reconstructed),
    "AxxBC"
  )
  assert_equal(
    json.encode(governed_reconstructed_result.value),
    json.encode(governed_expected),
    "serialized governed named-span fixture"
  )

  local bridge_source = [[
Top::AND
 => Value

Value:AND
 /é\n/
 /ab🙂/
 /Z/
 -> Value[0] {
   here_result = mark_here(origin)
   input_start_result = mark_input_start(input_start)
   start_capture_slice()
   bridge_result = mark_capture_slice(bridge)
   mark_here(cleared)
   clear_result = mark_copy(cleared, missing)
 }
 -> Value[2] {
   stable_named = capture_from(origin)
   named_take = capture_take(origin)
   after_take = mark_pos(origin)
   start_capture_slice_from(bridge)
   bridged = capture_slice()
   mark_capture_slice(roundtrip)
   start_capture_slice()
   start_capture_slice_from(missing)
   missing_bridge_pos = capture_slice_pos()
   mark_input_end(reverse_start)
   mark_input_start(reverse_end)
   invalid_between = capture_take_between(reverse_start, reverse_end)
   return({
     "here_result" : here_result,
     "input_start_result" : input_start_result,
     "bridge_result" : bridge_result,
     "clear_result" : clear_result,
     "cleared_exists" : mark_exists(cleared),
     "stable_named" : stable_named,
     "named_take" : named_take,
     "after_take" : after_take,
     "bridged" : bridged,
     "roundtrip_pos" : mark_pos(roundtrip),
     "missing_bridge_pos" : missing_bridge_pos,
     "invalid_between" : invalid_between,
     "reverse_after" : mark_pos(reverse_start)
   })
 }
]]
  local bridge_result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(bridge_source))),
    "é\nab🙂Ztail"
  ).value[1]
  local bridge_expected = json.harray({
    here_result = json.null,
    input_start_result = json.null,
    bridge_result = json.null,
    clear_result = json.null,
    cleared_exists = 0,
    stable_named = "ab🙂",
    named_take = "ab🙂",
    after_take = 6,
    bridged = "ab🙂",
    roundtrip_pos = 2,
    missing_bridge_pos = 6,
    invalid_between = json.null,
    reverse_after = 10,
  })
  assert_equal(
    json.encode(bridge_result),
    json.encode(bridge_expected),
    "Unicode named/anonymous bridge behavior"
  )

  for _, malformed in ipairs({
    { call = "mark_here()", helper = "mark_here", expected = "exactly 1 positional argument", actual = 0 },
    { call = "mark_copy(one)", helper = "mark_copy", expected = "exactly 2 positional arguments", actual = 1 },
    {
      call = "capture_between(one)",
      helper = "capture_between",
      expected = "exactly 2 positional arguments",
      actual = 1,
    },
    {
      call = "capture_from(one, two)",
      helper = "capture_from",
      expected = "exactly 1 positional argument",
      actual = 2,
    },
    {
      call = "capture_take(one, two)",
      helper = "capture_take",
      expected = "exactly 1 positional argument",
      actual = 2,
    },
  }) do
    local invalid_source = "Top::\n /x/ I { return(" .. malformed.call .. ") }\n"
    local ok, failure = pcall(function()
      linkedspec.runtime_parse(
        linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(invalid_source))),
        "x"
      )
    end)
    assert_equal(ok, false, malformed.helper .. " malformed arity fails")
    assert_equal(linkedspec.is_runtime_interpreter_error(failure), true, malformed.helper .. " typed failure")
    assert_equal(failure.code, "helper_arity_mismatch", malformed.helper .. " diagnostic code")
    assert_equal(failure.helper_name, malformed.helper, malformed.helper .. " helper attribution")
    assert_equal(failure.expected_arity, malformed.expected, malformed.helper .. " expected arity")
    assert_equal(failure.actual_arity, malformed.actual, malformed.helper .. " actual arity")
  end
end)

test("runtime split and named-mark rule-slot events execute after their matched action sites", function()
  local source = [[
Top::AND
 => Value

Value:AND
 /é\(/
 @capture_slice
 @mark(first_start)
 /α🙂/
 /,/
 @capture_from_here
 @mark(second_start)
 /β/
 @move_pos
 /γ/
 /\)/
 -> Value[0] {
   same_opener_slice = capture_slice()
   same_opener_mark = mark_exists(first_start)
 }
 -> Value[2] {
   first_slice = capture_slice()
   first_named = capture_from(first_start)
   same_comma_mark = mark_exists(second_start)
 }
 -> Value[3] {
   same_beta_slice = capture_slice()
 }
 -> Value[5] {
   return({
     "same_opener_slice" : same_opener_slice,
     "same_opener_mark" : same_opener_mark,
     "first_slice" : first_slice,
     "first_named" : first_named,
     "same_comma_mark" : same_comma_mark,
     "same_beta_slice" : same_beta_slice,
     "last_slice" : capture_slice(),
     "second_named" : capture_from(second_start),
     "first_pos" : mark_pos(first_start),
     "second_pos" : mark_pos(second_start)
   })
 }
]]
  local parsed = linkedspec.parse_spec(source)
  local compiled = linkedspec.compile_spec(parsed)
  local events = compiled:rule("Value").rule_slot_events
  assert_equal(#events, 5, "compiled rule-slot event count")
  assert_equal(linkedspec.compiled_spec.node_type(events[1]), "CompiledRuleSlotEvent", "event type")
  assert_equal(events[1].kind, "capture_boundary", "preferred capture marker kind")
  assert_equal(events[1].regex_index, 0, "preferred capture marker slot")
  assert_equal(events[2].kind, "named_mark", "first named marker kind")
  assert_equal(events[2].mark_name, "first_start", "first named marker name")
  assert_equal(events[3].kind, "capture_boundary", "first compatibility alias kind")
  assert_equal(events[3].regex_index, 2, "first compatibility alias slot")
  assert_equal(events[4].mark_name, "second_start", "second named marker name")
  assert_equal(events[5].kind, "capture_boundary", "shipped move-pos alias kind")
  assert_equal(events[5].regex_index, 3, "shipped move-pos alias slot")
  assert_equal(events[5].marker, "@move_pos", "shipped move-pos spelling")

  local shipped_source = read_file("rgx/subs/pgen/specs/ebnf.spec")
  local shipped_line = shipped_source:match("logging_annotation:[^\r\n]+")
  local shipped_owner = linkedspec.compile_spec(linkedspec.parse_spec(
    "Top::AND\n => logging_annotation\n\n" .. shipped_line .. "\n"
  )):rule("logging_annotation")
  assert_equal(#shipped_owner.rule_slot_events, 1, "shipped EBNF marker has one executable owner")
  assert_equal(shipped_owner.rule_slot_events[1].marker, "@move_pos", "shipped EBNF marker spelling")
  assert_equal(shipped_owner.rule_slot_events[1].regex_index, 1, "shipped EBNF marker slot")

  local expected = json.harray({
    same_opener_slice = "",
    same_opener_mark = 0,
    first_slice = "α🙂",
    first_named = "α🙂",
    same_comma_mark = 0,
    same_beta_slice = "",
    last_slice = "γ",
    second_named = "βγ",
    first_pos = 2,
    second_pos = 5,
  })
  local result = linkedspec.runtime_parse(linkedspec.runtime_engine(compiled), "é(α🙂,βγ)").value[1]
  assert_equal(json.encode(result), json.encode(expected), "native rule-slot marker timing")

  local reconstructed = linkedspec.compile_spec(
    linkedspec.spec_ast.from_json("SpecFile", json.decode(json.encode(linkedspec.spec_ast.to_json(parsed))))
  )
  local reconstructed_result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(reconstructed),
    "é(α🙂,βγ)"
  ).value[1]
  assert_equal(json.encode(reconstructed_result), json.encode(expected), "serialized rule-slot marker timing")

  for _, malformed_marker in ipairs({
    "@mark()",
    "@mark(9bad)",
    "@mark(bad-name)",
    "@mark(ok) trailing",
    "@capture_slicex",
  }) do
    local ok, validation_error = pcall(function()
      linkedspec.compile_spec(linkedspec.parse_spec("Top::\n /x/ " .. malformed_marker .. "\n"))
    end)
    assert_equal(ok, false, malformed_marker .. " authored marker fails")
    assert_equal(
      linkedspec.is_spec_validation_error(validation_error),
      true,
      malformed_marker .. " authored marker is typed"
    )
  end

  local malformed_ast = ast.spec_file({
    rules = {
      compiled_test_rule("Top", true, nil, {
        ast.body_element({ kind = ast.regex_body_kind({ pattern = "x" }), source = "/x/", line = 1 }),
        ast.body_element({
          kind = ast.split_marker_body_kind({ marker = "@mark(bad-name)" }),
          source = "@mark(bad-name)",
          line = 1,
        }),
      }),
    },
  })
  local compiled_error = assert_compiled_error(function()
    linkedspec.compile_spec(malformed_ast, { validate_source = false })
  end, "malformed split marker", "malformed typed marker")
  assert_equal(compiled_error.code, "malformed_rule_slot_marker", "malformed marker diagnostic code")
  assert_equal(compiled_error.rule_label, "Top", "malformed marker rule attribution")
  assert_equal(compiled_error.line, 1, "malformed marker line attribution")
end)

test("runtime deterministic pure scalar string helpers and receivers preserve portable values", function()
  local source = [[
Top::
 /x/
 I {
   raw = " node-name_end "
 }
 E {
   return({
     "cat" : cat("n=", 2, false),
     "cat_null" : cat("n=", 2, false, undef),
     "cat_negative_zero" : cat(-0.0),
     "cat_aggregate_empty" : cat("x", [1], { "a" : 1 }, "y"),
     "coalesce_false" : coalesce(undef, false, "bad"),
     "coalesce_nonempty_zero" : coalesce_nonempty("", 0, "bad"),
     "coalesce_lazy" : coalesce("kept", invented_helper()),
     "defined" : is_defined(false),
     "undefined" : is_undefined(undef),
     "empty_null" : is_empty(undef),
     "empty_array" : is_empty([]),
     "empty_hash" : is_empty({}),
     "nonempty_false" : is_nonempty(false),
     "trim_unicode" : trim("   value   "),
     "length_unicode" : length("é😀"),
     "length_array" : length([1, 2]),
     "length_hash" : length({ "a" : 1, "b" : 2 }),
     "length_false" : length(false),
     "starts" : starts_with("éclair", "é"),
     "ends" : ends_with("éclair", "air"),
     "contains" : contains_substr("a😀b", "😀"),
     "replace" : replace_substr("aaaa", "aa", "b"),
     "replace_empty" : replace_substr("abc", "", "x"),
     "rm_prefix" : rm_prefix("node_name", "node_"),
     "rm_suffix" : rm_suffix("name_end", "_end"),
     "substr_unicode" : substr("aé😀z", 1, 2),
     "substr_rest" : substr("aé😀z", 2),
     "substr_negative" : substr("abc", -2, 2),
     "substr_past" : substr("abc", 9, 2),
     "str_eq" : str_eq("a", "a"),
     "str_ne" : str_ne("a", "b"),
     "str_gt" : str_gt("2", "10"),
     "str_ge" : str_ge("2", "2"),
     "str_lt" : str_lt("10", "2"),
     "str_le" : str_le("2", "2"),
     "str_null" : str_eq(undef, ""),
     "chain" : raw.trim().replace_substr("-", "_").rm_prefix("node_").rm_suffix("_end").cat("!"),
     "receiver_coalesce" : "".coalesce_nonempty(" fallback ").trim(),
     "terminal_continuation" : "abc".length().trim(),
     "trim_null" : trim(undef),
     "replace_null" : replace_substr(undef, "a", "b")
   })
 }
]]
  local result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(source))),
    "x"
  )
  assert_equal(result.value.cat, "n=20", "stable scalar cat conversion")
  assert_equal(result.value.cat_negative_zero, "0", "stable negative-zero conversion")
  assert_equal(result.value.cat_null, json.null, "null propagates through cat")
  assert_equal(result.value.cat_aggregate_empty, json.null, "aggregate propagates null through cat")
  assert_equal(result.value.coalesce_false, false, "coalesce preserves false")
  assert_equal(result.value.coalesce_nonempty_zero, 0, "coalesce_nonempty preserves zero")
  assert_equal(result.value.coalesce_lazy, "kept", "coalesce short-circuits unevaluated fallback")
  assert_equal(result.value.defined, true, "defined false predicate")
  assert_equal(result.value.undefined, true, "undefined null predicate")
  assert_equal(result.value.empty_null, true, "empty null predicate")
  assert_equal(result.value.empty_array, true, "empty array predicate")
  assert_equal(result.value.empty_hash, true, "empty hash predicate")
  assert_equal(result.value.nonempty_false, true, "false is a nonempty scalar")
  assert_equal(result.value.trim_unicode, "value", "Unicode whitespace trim")
  assert_equal(result.value.length_unicode, 2, "Unicode scalar length")
  assert_equal(result.value.length_array, 2, "array length")
  assert_equal(result.value.length_hash, 2, "harray length")
  assert_equal(result.value.length_false, 1, "boolean scalar text length")
  assert_equal(result.value.starts, 1, "literal Unicode prefix")
  assert_equal(result.value.ends, 1, "literal suffix")
  assert_equal(result.value.contains, 1, "literal Unicode containment")
  assert_equal(result.value.replace, "bb", "literal replace all")
  assert_equal(result.value.replace_empty, "abc", "empty literal replacement source")
  assert_equal(result.value.rm_prefix, "name", "literal prefix removal")
  assert_equal(result.value.rm_suffix, "name", "literal suffix removal")
  assert_equal(result.value.substr_unicode, "é😀", "Unicode substring")
  assert_equal(result.value.substr_rest, "😀z", "substring remainder")
  assert_equal(result.value.substr_negative, "ab", "negative substring clamp")
  assert_equal(result.value.substr_past, "", "past-end substring")
  assert_equal(result.value.str_eq, true, "string equality")
  assert_equal(result.value.str_ne, true, "string inequality")
  assert_equal(result.value.str_gt, true, "lexical string greater")
  assert_equal(result.value.str_ge, true, "lexical string greater-equal")
  assert_equal(result.value.str_lt, true, "lexical string less")
  assert_equal(result.value.str_le, true, "lexical string less-equal")
  assert_equal(result.value.str_null, json.null, "string comparison null propagation")
  assert_equal(result.value.chain, "name!", "string receiver composition")
  assert_equal(result.value.receiver_coalesce, "fallback", "lazy receiver coalesce composition")
  assert_equal(result.value.terminal_continuation, json.null, "terminal string chain rejection")
  assert_equal(result.value.trim_null, json.null, "trim null propagation")
  assert_equal(result.value.replace_null, json.null, "replace null propagation")
end)

test("cat and scalar receiver text match the neutral six-variant contract", function()
  local handle = assert(io.open("capability_conformance/scalar_text_contract.json", "rb"))
  local contract = json.decode(assert(handle:read("*a")))
  assert(handle:close())
  assert_equal(contract.format, 1, "scalar-text contract format")
  assert_equal(contract.contract_id, "linkedspec-scalar-text-v1", "scalar-text contract id")
  assert_equal(contract.policy.codeblock, json.null, "codeblock is non-text")
  assert_equal(contract.retired_names[1], "concat", "concat remains retired")

  local result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(contract.spec_source))),
    "xx"
  )
  for key, expected in pairs(contract.expected) do
    assert_equal(result.value[key], expected, "neutral scalar-text field " .. key)
  end
end)

test("helper regex flags and matches are strict in function and receiver form", function()
  local source = [[
Top::
 /x/
 E {
   return({
     "plain" : matches("prefix-42", /\d+$/),
     "case" : matches("AbC", /^abc$/i),
     "case_noops" : matches("AbC", /^abc$/igo),
     "multiline" : matches("x
Y", /^y$/im),
     "dotall" : matches("a
b", /^a.b$/s),
     "extended" : matches("a b", /^ a \s+ b $/x),
     "null" : matches(undef, /x/),
     "non_regex" : matches("abc", "abc"),
     "unknown_flag" : matches("abc", /^abc$/q),
     "invalid_pattern" : matches("abc", /(/),
     "receiver" : "AbC".matches(/^abc$/io),
     "terminal_chain" : "abc".matches(/a/).lowercase()
   })
 }
]]
  local result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(source))),
    "x"
  )
  assert_equal(result.value.plain, true, "plain helper regex searches")
  assert_equal(result.value.case, true, "case-insensitive helper regex")
  assert_equal(result.value.case_noops, true, "g and o are predicate no-ops")
  assert_equal(result.value.multiline, true, "multiline helper flag")
  assert_equal(result.value.dotall, true, "dotall helper flag")
  assert_equal(result.value.extended, true, "extended helper flag")
  assert_equal(result.value.null, false, "null helper input fails closed")
  assert_equal(result.value.non_regex, false, "non-regex pattern fails closed")
  assert_equal(result.value.unknown_flag, false, "unknown helper flag fails closed")
  assert_equal(result.value.invalid_pattern, false, "invalid helper pattern fails closed")
  assert_equal(result.value.receiver, true, "receiver matches uses the same adapter")
  assert_equal(result.value.terminal_chain, json.null, "matches ends string receiver chains")
end)

test("pure split preserves typed literal regex Unicode and receiver boundaries", function()
  local source = [[
Top::
 /x/
 E {
   raw = "a-b-"
   return({
     "literal" : split(",a,b,", ","),
     "regex" : split("a1b22c", /\d+/go),
     "case" : split("aXbxc", /x/i),
     "characters" : split("🙂a", ""),
     "zero_width" : split("abc", /(?=b)/),
     "receiver" : raw.split("-"),
     "invalid_pattern" : split("abc", /(/),
     "unknown_flag" : split("abc", /b/q),
     "null" : split(undef, ","),
     "non_text" : split(["a"], ","),
     "source_after" : raw,
     "slice" : substr("🙂abc", 1, 2),
     "literal_replace" : replace_substr("a-b-a", "a", "x")
   })
 }
]]
  local result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(source))),
    "x"
  ).value
  assert_equal(json.kind(result.literal), "array", "literal split returns typed array")
  assert_equal(#result.literal, 4, "literal split preserves leading and trailing empties")
  assert_equal(result.literal[1], "", "literal leading empty")
  assert_equal(result.literal[4], "", "literal trailing empty")
  assert_equal(table.concat(result.regex, "|"), "a|b|c", "regex split uses PCRE2")
  assert_equal(table.concat(result.case, "|"), "a|b|c", "regex split uses helper flags")
  assert_equal(#result.characters, 2, "empty delimiter splits Unicode characters")
  assert_equal(result.characters[1], "🙂", "Unicode split preserves scalar bytes")
  assert_equal(table.concat(result.zero_width, "|"), "a|bc", "zero-width regex split makes progress")
  assert_equal(#result.receiver, 3, "receiver split preserves trailing empty")
  assert_equal(result.receiver[3], "", "receiver split trailing field")
  assert_equal(#result.invalid_pattern, 0, "invalid regex split fails closed")
  assert_equal(#result.unknown_flag, 0, "unknown regex flag split fails closed")
  assert_equal(#result.null, 0, "null split returns empty array")
  assert_equal(#result.non_text, 0, "non-text split returns empty array")
  assert_equal(result.source_after, "a-b-", "pure receiver split does not mutate source")
  assert_equal(result.slice, "ab", "Unicode substr remains a distinct pure value")
  assert_equal(result.literal_replace, "x-b-x", "literal replacement remains non-regex")
end)

test("statement regex substitution mutates bare scalars and preserves pure substr", function()
  local source = [[
Top::
 /x/
 E {
   value = "\"bar baz\""
   numbered = "a12b34"
   first_only = "a1b2"
   letters = "AbA"
   zero_width = "🙂a"
   untouched = "abcdef"
   substr(value, '"|\s', "", go)
   regex_subst(numbered, /(\d+)/, "[$1:$0]", g)
   substr(first_only, /(\d+)/, "[$1]", o)
   substr(letters, /a/, "x", ig)
   regex_subst(zero_width, /(?=.)/, "-", g)
   substr(untouched, 1, 3)
   return({
     "value" : value,
     "numbered" : numbered,
     "first_only" : first_only,
     "letters" : letters,
     "zero_width" : zero_width,
     "untouched" : untouched,
     "slice" : substr(untouched, 1, 3)
   })
 }
]]
  local result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(source))),
    "x"
  ).value
  assert_equal(result.value, "barbaz", "string pattern and global/no-op flags mutate target")
  assert_equal(result.numbered, "a[12:12]b[34:34]", "$n and $0 replacements expand")
  assert_equal(result.first_only, "a[1]b2", "missing global flag replaces first match only")
  assert_equal(result.letters, "xbx", "regex literal and case-insensitive global flags compose")
  assert_equal(result.zero_width, "-🙂-a", "global zero-width substitution makes Unicode-safe progress")
  assert_equal(result.untouched, "abcdef", "discarded numeric substr remains pure")
  assert_equal(result.slice, "bcd", "value-form numeric substr still slices")

  local invalid_source = [[
Broken::
 /x/
 E { value = "abc"; regex_subst(value, "(", "", g) }
]]
  local ok, failure = pcall(function()
    linkedspec.runtime_parse(
      linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(invalid_source))),
      "x"
    )
  end)
  assert_equal(ok, false, "invalid statement regex fails")
  assert_equal(linkedspec.is_runtime_interpreter_error(failure), true, "invalid regex uses runtime diagnostic")
  assert_equal(failure.rule_label, "Broken", "invalid regex diagnostic attributes its rule")

  local flag_source = [[
Flagged::
 /x/
 E { value = "abc"; substr(value, /b/, "x", q) }
]]
  ok, failure = pcall(function()
    linkedspec.runtime_parse(
      linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(flag_source))),
      "x"
    )
  end)
  assert_equal(ok, false, "unknown statement regex flag fails")
  assert_equal(failure.rule_label, "Flagged", "unknown flag diagnostic attributes its rule")
end)

test("statement split distinguishes bare mutable and pure forms", function()
  local source = [[
Top::
 /x/
 E {
   raw = " left , right,,third "
   parts = ["stale"]
   scalar_parts = split("a,b", ",")
   split(parts, raw, /\s*,\s*/)
   split(literal_parts, ",a,", ",")
   split(scalar_parts, "ignored", ",")
   return({
     "parts" : copy(parts),
     "literal_parts" : copy(literal_parts),
     "scalar_parts" : scalar_parts,
     "raw_after" : raw,
     "pure" : split("x-y", "-")
   })
 }
]]
  local result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(source))),
    "x"
  ).value
  assert_equal(json.kind(result.parts), "array", "explicit target remains a typed array")
  assert_equal(table.concat(result.parts, "|"), " left|right||third ", "regex split replaces explicit target")
  assert_equal(#result.literal_parts, 3, "literal target split preserves empty fields")
  assert_equal(result.literal_parts[1], "", "literal target leading empty")
  assert_equal(result.literal_parts[3], "", "literal target trailing empty")
  assert_equal(table.concat(result.scalar_parts, "|"), "ignored", "bare three-argument split replaces target")
  assert_equal(result.raw_after, " left , right,,third ", "statement split leaves source scalar untouched")
  assert_equal(table.concat(result.pure, "|"), "x|y", "pure split value remains available")
end)

local function execute_uniform_binding_source(source, input)
  return linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(source))),
    input or "xx"
  ).value
end

local function assert_json_equal(actual, expected, label)
  assert_equal(json.encode(actual), json.encode(expected), label)
end

local function uniform_binding_action_source(action)
  return "Top::\n /x/ -> Done { " .. action .. " }\nDone::\n /x/\n"
end

test("every admitted call name reaches a runtime or documented non-function owner", function()
  local action_names = require("linkedspec.action_call_names")
  local expected_non_function = {
    ["case"] = true,
    ["elif"] = true,
    ["elseif"] = true,
    ["i"] = true,
    ["map_leaves"] = true,
    ["pop_back"] = true,
    ["pop_front"] = true,
    ["push_back"] = true,
    ["push_front"] = true,
    ["reduce_leaves"] = true,
    ["walk_leaves"] = true,
    ["when"] = true,
    ["while"] = true,
  }
  local observed_non_function = {}

  for _, name in ipairs(action_names.current_names()) do
    local source = uniform_binding_action_source(name .. "()")
    local parsed_ok, parsed = pcall(linkedspec.parse_spec, source)
    if not parsed_ok then fail("admitted call failed to parse: " .. name .. ": " .. tostring(parsed)) end
    local compiled_ok, compiled = pcall(linkedspec.compile_spec, parsed)
    if not compiled_ok then fail("admitted call failed to compile: " .. name .. ": " .. tostring(compiled)) end
    local runtime_ok, runtime_failure = pcall(
      linkedspec.runtime_parse,
      linkedspec.runtime_engine(compiled),
      "xx"
    )
    if not runtime_ok and
      linkedspec.is_runtime_interpreter_error(runtime_failure) and
      runtime_failure.helper_name ~= nil and
      runtime_failure.message:find("unsupported", 1, true)
    then
      observed_non_function[name] = true
    end
  end

  local observed_count = 0
  for name in pairs(observed_non_function) do
    observed_count = observed_count + 1
    assert_equal(expected_non_function[name], true, "unexpected unowned call name " .. name)
  end
  local expected_count = 0
  for name in pairs(expected_non_function) do
    expected_count = expected_count + 1
    assert_equal(observed_non_function[name], true, "non-function owner remains explicit for " .. name)
  end
  assert_equal(expected_count, 13, "documented non-function owner count")
  assert_equal(observed_count, 13, "observed non-function owner count")
end)

test("direct call rule returns the child value and refreshes retv", function()
  local source = [[
Top::
 /x/ E { return([call(Child), retv, cursor_pos()]) }

Child::
 /y/ E { return(["child", match_text(), cursor_pos()]) }
]]
  assert_json_equal(execute_uniform_binding_source(source, "xy"), json.decode(
    '[["child","y",2],["child","y",2],2]'
  ), "direct child result and return channel")
end)

test("action-edge call reuses the current child exactly once", function()
  local function execute_traced(source, input)
    local emitter = linkedspec.trace_emitter(linkedspec.trace_config_enabled(linkedspec.TRACE_DEBUG), {
      stdout_writer = function() end,
    })
    local result = linkedspec.runtime_parse(
      linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(source))),
      input,
      { trace = emitter }
    )
    return result, linkedspec.trace_events(emitter)
  end

  local function count_rule_entries(events, label)
    local count = 0
    local details = "rule=" .. label .. " "
    for _, event in ipairs(events) do
      if event.kind == linkedspec.TRACE_ENTER and
          event.topic == "lua_runtime:rule" and
          event.details:find(details, 1, true) then
        count = count + 1
      end
    end
    return count
  end

  local function count_child_dispatches(events, label, passive)
    local count = 0
    local target = "target=" .. label .. "[0]"
    for _, event in ipairs(events) do
      if event.topic == "lua_runtime:child_dispatch" and
          event.details:find(target, 1, true) and
          (not passive or event.details:find("passive=1", 1, true)) then
        count = count + 1
      end
    end
    return count
  end

  local current, current_events = execute_traced([[
Top::
 I { called = "unset" }
 /a/ -> Child { called = call(Child) }
 E { return([called, retv, cursor_pos()]) }

Child:
 /b/
 E { return(["child", match_text(), cursor_pos()]) }
]], "ab")
  assert_json_equal(current.value, json.decode(
    '[["child","b",2],["child","b",2],2]'
  ), "current action-edge child value and return channel")
  assert_equal(current.cursor_code_unit, 2, "current action-edge child cursor")
  assert_equal(count_rule_entries(current_events, "Child"), 1, "current child call count")

  local passive, passive_events = execute_traced([[
Top::
 -> Passive { observed = call(Passive) }
 E { return([observed, retv, cursor_pos()]) }

Passive: /b/
]], "b")
  assert_json_equal(passive.value, json.array({ json.null, json.null, 1 }), "passive child result")
  assert_equal(passive.cursor_code_unit, 1, "passive child cursor")
  assert_equal(count_rule_entries(passive_events, "Passive"), 0, "passive child re-search count")
  assert_equal(count_child_dispatches(passive_events, "Passive", true), 1, "passive edge dispatch count")

  local recursive, recursive_events = execute_traced([[
Node::*
 /a/ -> Node { nested = call(Node) }
 E { return(cursor_pos()) }
]], "aa")
  assert_equal(recursive.value, 2, "self-recursive child value")
  assert_equal(recursive.cursor_code_unit, 2, "self-recursive child cursor")
  assert_equal(count_rule_entries(recursive_events, "Node"), 3, "self-recursive call count")

  local unrelated, unrelated_events = execute_traced([[
Top::
 /a/ -> Child { other = call(Other) }
 E { return([other, retv, cursor_pos()]) }

Other:
 /b/
 E { return("other") }

Child:
 /c/
 E { return("child") }
]], "abc")
  assert_json_equal(unrelated.value, json.decode('["other","child",3]'), "unrelated named call")
  assert_equal(unrelated.cursor_code_unit, 3, "unrelated named call cursor")
  assert_equal(count_rule_entries(unrelated_events, "Other"), 1, "unrelated rule call count")
  assert_equal(count_rule_entries(unrelated_events, "Child"), 1, "edge child fallback count")
end)

test("punctuation-light zero-argument contract is exact", function()
  local contract = json.decode(read_file(
    "capability_conformance/punctuation_light_zero_arg_contract.json"
  ))
  assert_equal(contract.contract_id, "linkedspec-punctuation-light-zero-arg-v1", "contract id")

  local omitted_fields = {
    source = true,
    source_span = true,
    source_method = true,
    body_source_span = true,
    trailing_block_source_span = true,
  }
  local function semantic_ast(value)
    if type(value) ~= "table" then return value end
    local result = json.kind(value) == "array" and json.array() or json.harray()
    for key, item in pairs(value) do
      if not omitted_fields[key] then
        result[key] = semantic_ast(item)
      end
    end
    return result
  end
  local function assert_semantic_ast_equal(actual, expected, label)
    assert_equal(
      json.encode(semantic_ast(linkedspec.action_ast.to_json(actual))),
      json.encode(semantic_ast(linkedspec.action_ast.to_json(expected))),
      label
    )
  end

  for _, case in ipairs(contract.standalone_cases) do
    local bare = linkedspec.parse_action_statement(case.bare).expr
    local parenthesized = linkedspec.parse_action_statement(case.parenthesized).expr
    assert_semantic_ast_equal(bare, parenthesized, case.id .. " statement AST")
    assert_equal(bare.kind, case.expected_ast.kind, case.id .. " statement kind")
  end
  local next_value = linkedspec.parse_action_expression("return(next)")
  assert_equal(next_value.args[1].value.kind, "variable", "return next remains a variable")
  assert_equal(next_value.args[1].value.name, "next", "return next variable name")
  assert_equal(linkedspec.parse_action_expression("next").kind, "variable", "expression next remains a variable")

  for _, case in ipairs(contract.receiver_cases) do
    local bare = linkedspec.parse_action_expression(case.bare)
    local parenthesized = linkedspec.parse_action_expression(case.parenthesized)
    assert_equal(bare.kind, "fluent_chain", case.id .. " receiver kind")
    assert_semantic_ast_equal(bare, parenthesized, case.id .. " receiver AST")
    assert_equal(#bare.calls[#bare.calls].args, 0, case.id .. " authored arguments")
  end

  for _, case in ipairs(contract.retained_noncall_cases) do
    local expression = linkedspec.parse_action_expression(case.source)
    assert_equal(expression.kind, "variable", case.id .. " retained kind")
    assert_equal(expression.name, case.source, case.id .. " retained name")
  end
  for _, case in ipairs(contract.invalid_syntax_cases) do
    local expression = linkedspec.parse_action_expression(case.source)
    assert_equal(expression.kind, "raw_perl", case.id .. " invalid kind")
    local fluent_invalid = case.id == "intermediate_generic_receiver" or
      case.id == "receiver_trailing_block_without_call"
    assert_equal(
      expression.reason,
      fluent_invalid and "invalid_fluent_chain" or "unsupported_expression",
      case.id .. " invalid reason"
    )
  end

  local count_result = execute_uniform_binding_source(
    uniform_binding_action_source('values = ["a", "b"]; return(values.count)')
  )
  assert_equal(count_result, 2, "terminal count alias")
  local bare_contains = execute_uniform_binding_source(
    uniform_binding_action_source('values = ["a", "b"]; return(values.contains)')
  )
  local parenthesized_contains = execute_uniform_binding_source(
    uniform_binding_action_source('values = ["a", "b"]; return(values.contains())')
  )
  assert_equal(bare_contains, parenthesized_contains, "contains spellings")
  assert_equal(bare_contains, 0, "existing missing contains needle result")

  local parsed = linkedspec.parse_spec(contract.future_fixture.spec_source)
  local serialized = json.encode(linkedspec.spec_ast.to_json(parsed))
  local reconstructed = linkedspec.spec_ast.from_json("SpecFile", json.decode(serialized))
  local result = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(reconstructed)),
    contract.future_fixture.input
  ).value
  assert_json_equal(result, contract.future_fixture.expected, "neutral native/serialized fixture")
end)

test("runtime eager blocks return last values and consume local return", function()
  local source = uniform_binding_action_source([[
items = [" raw "]
last_value = { set(x, "a"); x }
early_value = { set(y, "before"); return({ "stage" : y }); set(y, "after"); "bad" }
null_value = { return() }
trimmed = { trim_each(items); items[0] }
receiver_value = { [3, 1, 2] }.sorted().join_values(",")
return({
  "last" : last_value,
  "early" : early_value,
  "y_after" : y,
  "null" : null_value,
  "trimmed" : trimmed,
  "receiver" : receiver_value,
  "empty_hash" : {},
  "keyed_hash" : { "k" : "v" }
})
]])
  local result = execute_uniform_binding_source(source)
  assert_equal(result.last, "a", "final block expression is the value")
  assert_equal(json.kind(result.early), "harray", "local return preserves harray payload")
  assert_equal(result.early.stage, "before", "local return payload is exact")
  assert_equal(result.y_after, "before", "local return skips later block statements")
  assert_equal(result.null, json.null, "no-argument local return yields null")
  assert_equal(result.trimmed, "raw", "non-final dropped mutation executes before final value")
  assert_equal(result.receiver, "1,2,3", "yielded block value enters receiver dispatch")
  assert_equal(json.kind(result.empty_hash), "harray", "empty braces remain an harray")
  assert_equal(json.kind(result.keyed_hash), "harray", "keyed braces remain an harray")
  assert_equal(result.keyed_hash.k, "v", "keyed harray value is preserved")

  local trailing = linkedspec.parse_action_expression('with("x") { return(value) }')
  assert_equal(trailing.args[#trailing.args].value.kind, "block_value", "trailing block remains structural")
  assert_equal(#trailing.args[#trailing.args].value.block.statements, 1, "trailing block body remains inert")
end)

test("built-in final codeblock contracts are exact and copied", function()
  local expected = {
    { surface = "helper", name = "with", minimum = 0, maximum = 1 },
    { surface = "receiver", name = "with", minimum = 0, maximum = 0 },
    { surface = "receiver", name = "walk_leaves", minimum = 0, maximum = 0 },
    { surface = "receiver", name = "map_leaves", minimum = 0, maximum = 0 },
    { surface = "receiver", name = "reduce_leaves", minimum = 1, maximum = 1 },
  }
  for _, item in ipairs(expected) do
    local contract = linkedspec.action_contracts.builtin_final_codeblock_contract(item.surface, item.name)
    assert_equal(type(contract), "table", item.name .. " contract")
    assert_equal(contract.min_before_codeblock, item.minimum, item.name .. " minimum")
    assert_equal(contract.max_before_codeblock, item.maximum, item.name .. " maximum")
    assert_equal(contract.final_parameter.name, "callback", item.name .. " parameter name")
    assert_equal(contract.final_parameter.kind, "codeblock", item.name .. " parameter kind")
    assert_equal(
      linkedspec.action_contracts.accepts_final_codeblock_argument_count(contract, item.minimum),
      true,
      item.name .. " minimum accepted"
    )
    assert_equal(
      linkedspec.action_contracts.accepts_final_codeblock_argument_count(contract, item.maximum),
      true,
      item.name .. " maximum accepted"
    )
    assert_equal(
      linkedspec.action_contracts.accepts_final_codeblock_argument_count(contract, item.maximum + 1),
      false,
      item.name .. " excess rejected"
    )
  end
  assert_equal(
    linkedspec.action_contracts.builtin_final_codeblock_contract("helper", "trim"),
    nil,
    "ordinary helpers have no final codeblock contract"
  )
  local mutated = linkedspec.action_contracts.builtin_final_codeblock_contract("helper", "with")
  mutated.final_parameter.kind = "broken"
  assert_equal(
    linkedspec.action_contracts.builtin_final_codeblock_contract("helper", "with").final_parameter.kind,
    "codeblock",
    "callers cannot mutate registry metadata"
  )

  for _, source in ipairs({
    'return([].walk_leaves("extra", { return(value) }))',
    'return({}.map_leaves("extra", { return(value) }))',
    'return([].reduce_leaves({ return(value) }))',
  }) do
    local ok, failure = pcall(function()
      execute_uniform_binding_source(uniform_binding_action_source(source))
    end)
    assert_equal(ok, false, source .. " fails before callback execution")
    assert_equal(linkedspec.is_runtime_interpreter_error(failure), true, source .. " typed failure")
    assert_equal(failure.code, "helper_arity_mismatch", source .. " generic arity code")
  end
end)

test("scoped runtime bindings restore every store on success and error", function()
  local runtime_scoped_binding = require("linkedspec.runtime_scoped_binding")
  local function scoped_copy(value)
    if type(value) ~= "table" then return value end
    return json.decode(json.encode(value))
  end

  local input = json.array({ "inner" })
  local context = {
    variables = { value = false },
    arrays = { value = json.array({ "prior-array" }) },
    harrays = { value = json.harray({ state = "prior-harray" }) },
  }
  local result = runtime_scoped_binding.run(context, "value", input, scoped_copy, function()
    assert_equal(json.kind(context.variables.value), "array", "temporary value kind")
    assert_equal(context.variables.value == input, false, "temporary value is copied")
    assert_equal(context.arrays.value, nil, "prior array store is hidden")
    assert_equal(context.harrays.value, nil, "prior harray store is hidden")
    context.variables.value[#context.variables.value + 1] = "scoped"
    context.arrays.value = json.array({ "temporary-array" })
    context.harrays.value = json.harray({ state = "temporary-harray" })
    return context.variables.value
  end)
  assert_json_equal(result, json.decode('["inner","scoped"]'), "scoped result is copied before restore")
  assert_json_equal(input, json.decode('["inner"]'), "caller input remains isolated")
  assert_equal(context.variables.value, false, "false scalar binding restores exactly")
  assert_json_equal(context.arrays.value, json.decode('["prior-array"]'), "array store restores")
  assert_json_equal(
    context.harrays.value,
    json.decode('{"state":"prior-harray"}'),
    "harray store restores"
  )

  local absent = { variables = {}, arrays = {}, harrays = {} }
  local scoped_names = { "value", "key", "path", "depth", "acc" }
  local marker = {}
  local ok, failure = pcall(function()
    runtime_scoped_binding.run_frame(absent, {
      { name = "value", value = "temporary" },
      { name = "key", value = "a" },
      { name = "path", value = json.array({ "a" }) },
      { name = "depth", value = 1 },
      { name = "acc", value = json.array({ "seed" }) },
    }, scoped_copy, function()
      for _, name in ipairs(scoped_names) do
        absent.variables[name] = "changed"
        absent.arrays[name] = json.array({ "changed" })
        absent.harrays[name] = json.harray({ changed = true })
      end
      error(marker, 0)
    end)
  end)
  assert_equal(ok, false, "callback error propagates")
  assert_equal(failure, marker, "callback error identity is preserved")
  for _, name in ipairs(scoped_names) do
    assert_equal(absent.variables[name], nil, "absent " .. name .. " scalar remains absent after frame error")
    assert_equal(absent.arrays[name], nil, "absent " .. name .. " array remains absent after frame error")
    assert_equal(absent.harrays[name], nil, "absent " .. name .. " harray remains absent after frame error")
  end
end)

test("runtime with executes equivalent final codeblock spellings in copied scope", function()
  local source = uniform_binding_action_source([[
missing_result = with("first") { value = cat(value, "!"); return(value) }
missing_after = value
value = "outer"
evaluated_before_scope = with(cat(value, "-inner")) { return(value) }
helper_attached = with("attached") { value = cat(value, "!"); return(value) }
helper_explicit = with("explicit", { value = cat(value, "!"); return(value) })
receiver_attached = "receiver-a".with() { return(value) }
receiver_explicit = "receiver-b".with({ return(value) })
receiver_chain = " padded ".with({ return(value) }).trim()
zero_attached = with() { return(value) }
zero_explicit = with({ return(value) })
scalar_restored = value
source_items = ["source"]
copied_items = with(source_items) { value += "scoped"; return(value) }
source_items_after = copy(source_items)
value = ["outer-array"]
array_result = with(["inner-array"]) { value += "added"; return(value) }
array_restored = copy(value)
value = { "state" : "outer-harray" }
harray_result = with({ "state" : "inner-harray" }) { value["state"] = "changed"; return(value) }
harray_restored = copy(value)
value = "outer-final"
nested = with("outer-scope") {
  inner = with("inner-scope", { value = cat(value, "!"); return(value) })
  return([inner, value])
}
nested_restored = value
events = []
local_return = with("local") { return(value); push(events, "bad") }
return({
  "missing_result" : missing_result,
  "missing_after" : missing_after,
  "evaluated_before_scope" : evaluated_before_scope,
  "helper_attached" : helper_attached,
  "helper_explicit" : helper_explicit,
  "receiver_attached" : receiver_attached,
  "receiver_explicit" : receiver_explicit,
  "receiver_chain" : receiver_chain,
  "zero_attached" : zero_attached,
  "zero_explicit" : zero_explicit,
  "scalar_restored" : scalar_restored,
  "copied_items" : copied_items,
  "source_items_after" : source_items_after,
  "array_result" : array_result,
  "array_restored" : array_restored,
  "harray_result" : harray_result,
  "harray_restored" : harray_restored,
  "nested" : nested,
  "nested_restored" : nested_restored,
  "local_return" : local_return,
  "events" : events
})
]])
  local result = execute_uniform_binding_source(source)
  local expected = json.decode([[
{
  "missing_result": "first!", "missing_after": null,
  "evaluated_before_scope": "outer-inner",
  "helper_attached": "attached!", "helper_explicit": "explicit!",
  "receiver_attached": "receiver-a", "receiver_explicit": "receiver-b",
  "receiver_chain": "padded", "zero_attached": null, "zero_explicit": null,
  "scalar_restored": "outer",
  "copied_items": ["source", "scoped"], "source_items_after": ["source"],
  "array_result": ["inner-array", "added"], "array_restored": ["outer-array"],
  "harray_result": {"state": "changed"}, "harray_restored": {"state": "outer-harray"},
  "nested": ["inner-scope!", "outer-scope"], "nested_restored": "outer-final",
  "local_return": "local", "events": []
}
]])
  assert_json_equal(result, expected, "helper receiver and scope behavior")

  for _, invalid in ipairs({
    { source = 'return(with())', code = "final_argument_not_codeblock", kind = "missing" },
    { source = 'return(with("x"))', code = "final_argument_not_codeblock", kind = "scalar" },
    { source = 'return(with("x", {}))', code = "final_argument_not_codeblock", kind = "harray" },
    {
      source = 'return(with("x", "extra", { return(value) }))',
      code = "helper_arity_mismatch",
      actual = 2,
    },
    { source = 'return("x".with())', code = "final_argument_not_codeblock", kind = "missing" },
    {
      source = 'return("x".with("extra", { return(value) }))',
      code = "helper_arity_mismatch",
      actual = 1,
    },
  }) do
    local ok, failure = pcall(function()
      execute_uniform_binding_source(uniform_binding_action_source(invalid.source))
    end)
    assert_equal(ok, false, invalid.source .. " fails")
    assert_equal(linkedspec.is_runtime_interpreter_error(failure), true, invalid.source .. " typed failure")
    assert_equal(failure.code, invalid.code, invalid.source .. " diagnostic code")
    assert_equal(failure.helper_name, "with", invalid.source .. " helper attribution")
    if invalid.kind then assert_equal(failure.value_kind, invalid.kind, invalid.source .. " value kind") end
    if invalid.actual then assert_equal(failure.actual_arity, invalid.actual, invalid.source .. " authored arity") end
  end

  local error_ok, error_failure = pcall(function()
    execute_uniform_binding_source(uniform_binding_action_source(
      'value = "outer"; return(with("inner", { value = "changed"; exit_now(86) }))'
    ))
  end)
  assert_equal(error_ok, false, "with callback errors propagate")
  assert_equal(linkedspec.is_runtime_interpreter_error(error_failure), true, "with callback failure stays typed")
  assert_equal(error_failure.status, 86, "with callback failure stays exact")
end)

test("runtime harray traversal is sorted scoped copied and terminal where required", function()
  local source = uniform_binding_action_source([[
value = "outer-value"
key = "outer-key"
path = "outer-path"
depth = "outer-depth"
acc = "outer-acc"
source = {
  "b" : { "y" : "B" },
  "a" : "A",
  "arr" : ["u", "v"],
  "empty" : {}
}
mapped = source.map_leaves() {
  callback_label = cat(key, "@", depth)
  callback_path = copy(path)
  if(str_eq(key, "arr")) { value += "callback" }
  key = "inner-key"
  path = ["inner-path"]
  depth = 99
  return({ "label" : callback_label, "path" : callback_path, "value" : value })
}
seen = []
walk_count = source.walk_leaves() {
  seen += cat(key, "@", depth)
  value = "walk-local"
  key = "walk-key"
  path = ["walk-path"]
  depth = 88
  return(value)
}.count_keys()
reduced = source.reduce_leaves([]) {
  acc += cat(key, "@", depth)
  return(acc)
}
reduce_continuation_is_null = is_undefined(source.reduce_leaves("") { return(acc) }.trim())
empty = {}
seed = ["seed"]
empty_map = empty.map_leaves() { return(exit_now(71)) }
empty_reduce = empty.reduce_leaves(seed) { return(exit_now(72)) }
empty_reduce += "result-only"
empty_walk_count = empty.walk_leaves() { return(exit_now(73)) }.count_keys()
invalid_map = "scalar".map_leaves() { return(exit_now(74)) }
invalid_reduce = "scalar".reduce_leaves(exit_now(75)) { return(exit_now(76)) }
invalid_walk = "scalar".walk_leaves() { return(exit_now(77)) }
return({
  "mapped" : mapped,
  "seen" : seen,
  "walk_count" : walk_count,
  "reduced" : reduced,
  "reduce_continuation_is_null" : reduce_continuation_is_null,
  "source" : source,
  "outer_value" : value,
  "outer_key" : key,
  "outer_path" : path,
  "outer_depth" : depth,
  "outer_acc" : acc,
  "empty_map" : empty_map,
  "empty_reduce" : empty_reduce,
  "empty_walk_count" : empty_walk_count,
  "seed" : seed,
  "invalid_map" : invalid_map,
  "invalid_reduce" : invalid_reduce,
  "invalid_walk" : invalid_walk
})
]])
  local result = execute_uniform_binding_source(source)
  assert_json_equal(result, json.harray({
    mapped = json.harray({
      a = json.harray({ label = "a@1", path = json.array({ "a" }), value = "A" }),
      arr = json.harray({
        label = "arr@1",
        path = json.array({ "arr" }),
        value = json.array({ "u", "v", "callback" }),
      }),
      b = json.harray({
        y = json.harray({ label = "y@2", path = json.array({ "b", "y" }), value = "B" }),
      }),
      empty = json.harray(),
    }),
    seen = json.array({ "a@1", "arr@1", "y@2" }),
    walk_count = 4,
    reduced = json.array({ "a@1", "arr@1", "y@2" }),
    reduce_continuation_is_null = true,
    source = json.harray({
      a = "A",
      arr = json.array({ "u", "v" }),
      b = json.harray({ y = "B" }),
      empty = json.harray(),
    }),
    outer_value = "outer-value",
    outer_key = "outer-key",
    outer_path = "outer-path",
    outer_depth = "outer-depth",
    outer_acc = "outer-acc",
    empty_map = json.harray(),
    empty_reduce = json.array({ "seed", "result-only" }),
    empty_walk_count = 0,
    seed = json.array({ "seed" }),
    invalid_map = json.null,
    invalid_reduce = json.null,
    invalid_walk = json.null,
  }), "harray traversal behavior")

  local reference_result = execute_uniform_binding_source(uniform_binding_action_source([[
meta = { "b" : { "y" : "B" }, "a" : "A", "arr" : ["u", "v"] }
return([
  meta.map_leaves() {
    return(cat(key, "@", depth, "=", if(count(value), join_values("", value), else(value))))
  },
  meta.reduce_leaves("") { return(cat(acc, key, "@", depth, ";")) },
  meta.walk_leaves() { seen += cat(key, "@", depth); return(value) }.count_keys(),
  seen
])
]]))
  assert_json_equal(reference_result, json.decode([[
[
  {"a":"a@1=A","arr":"arr@1=uv","b":{"y":"y@2=B"}},
  "a@1;arr@1;y@2;",
  3,
  ["a@1","arr@1","y@2"]
]
]]), "exact Perl reference callback result")

  for _, invalid in ipairs({
    { source = "return({}.map_leaves())", code = "final_argument_not_codeblock", kind = "missing" },
    { source = 'return({}.walk_leaves("bad"))', code = "final_argument_not_codeblock", kind = "scalar" },
    {
      source = "return({}.reduce_leaves({ return(value) }))",
      code = "helper_arity_mismatch",
      actual = 0,
    },
  }) do
    local ok, failure = pcall(function()
      execute_uniform_binding_source(uniform_binding_action_source(invalid.source))
    end)
    assert_equal(ok, false, invalid.source .. " fails")
    assert_equal(linkedspec.is_runtime_interpreter_error(failure), true, invalid.source .. " typed failure")
    assert_equal(failure.code, invalid.code, invalid.source .. " diagnostic code")
    if invalid.kind then assert_equal(failure.value_kind, invalid.kind, invalid.source .. " value kind") end
    if invalid.actual then assert_equal(failure.actual_arity, invalid.actual, invalid.source .. " authored arity") end
  end
end)

test("runtime array traversal is indexed scoped copied and root-kind exact", function()
  local source = uniform_binding_action_source([=[
value = "outer-value"
index = "outer-index"
path = "outer-path"
depth = "outer-depth"
acc = "outer-acc"
source = ["A", ["B", "C"], { "h" : "H" }, []]
mapped = source.map_leaves() {
  callback_label = cat(join_values("/", path), "@", depth)
  callback_index = index
  callback_path = copy(path)
  if(num_eq(index, 2)) { value["h"] = "callback" }
  index = 99
  path = ["inner-path"]
  depth = 99
  return({ "label" : callback_label, "index" : callback_index, "path" : callback_path, "value" : value })
}
map_count = source.map_leaves() { return(value) }.count()
seen = []
walk_count = source.walk_leaves() {
  seen += join_values("/", path)
  value = "walk-local"
  index = 88
  path = ["walk-path"]
  depth = 88
  return(value)
}.count()
reduced = source.reduce_leaves([]) {
  acc += cat(join_values("/", path), "@", depth)
  return(acc)
}
reduce_continuation_is_null = is_undefined(source.reduce_leaves("") { return(acc) }.trim())
empty = []
seed = ["seed"]
empty_map = empty.map_leaves() { return(exit_now(81)) }
empty_reduce = empty.reduce_leaves(seed) { return(exit_now(82)) }
empty_reduce += "result-only"
empty_walk_count = empty.walk_leaves() { return(exit_now(83)) }.count()
return({
  "mapped" : mapped,
  "map_count" : map_count,
  "seen" : seen,
  "walk_count" : walk_count,
  "reduced" : reduced,
  "reduce_continuation_is_null" : reduce_continuation_is_null,
  "source" : source,
  "outer_value" : value,
  "outer_index" : index,
  "outer_path" : path,
  "outer_depth" : depth,
  "outer_acc" : acc,
  "empty_map" : empty_map,
  "empty_reduce" : empty_reduce,
  "empty_walk_count" : empty_walk_count,
  "seed" : seed
})
]=])
  local result = execute_uniform_binding_source(source)
  assert_json_equal(result, json.harray({
    mapped = json.array({
      json.harray({ label = "0@1", index = 0, path = json.array({ 0 }), value = "A" }),
      json.array({
        json.harray({ label = "1/0@2", index = 0, path = json.array({ 1, 0 }), value = "B" }),
        json.harray({ label = "1/1@2", index = 1, path = json.array({ 1, 1 }), value = "C" }),
      }),
      json.harray({
        label = "2@1",
        index = 2,
        path = json.array({ 2 }),
        value = json.harray({ h = "callback" }),
      }),
      json.array(),
    }),
    map_count = 4,
    seen = json.array({ "0", "1/0", "1/1", "2" }),
    walk_count = 4,
    reduced = json.array({ "0@1", "1/0@2", "1/1@2", "2@1" }),
    reduce_continuation_is_null = true,
    source = json.array({ "A", json.array({ "B", "C" }), json.harray({ h = "H" }), json.array() }),
    outer_value = "outer-value",
    outer_index = "outer-index",
    outer_path = "outer-path",
    outer_depth = "outer-depth",
    outer_acc = "outer-acc",
    empty_map = json.array(),
    empty_reduce = json.array({ "seed", "result-only" }),
    empty_walk_count = 0,
    seed = json.array({ "seed" }),
  }), "array traversal behavior")

  local reference_result = execute_uniform_binding_source(uniform_binding_action_source([[
items = ["a", ["b", "c"], { "h" : "H" }]
scalar = "x"
nonarray = scalar.map_leaves() { seen += "bad" }
return([
  items.map_leaves() {
    return(cat(join_values("/", path), "=", if(count(value.sorted_keys()), cat("{", value.sorted_keys().join_values(","), "}"), else(value))))
  },
  items.reduce_leaves("") {
    return(cat(acc, join_values("/", path), ":", if(count(value.sorted_keys()), cat("{", value.sorted_keys().join_values(","), "}"), else(value)), ";"))
  },
  items.walk_leaves() { seen += join_values("/", path); return(value) }.count(),
  seen,
  if(is_undefined(nonarray), "undef", else("bad"))
])
]]))
  assert_json_equal(reference_result, json.decode([[
[
  ["0=a",["1/0=b","1/1=c"],"2={h}"],
  "0:a;1/0:b;1/1:c;2:{h};",
  3,
  ["0","1/0","1/1","2"],
  "undef"
]
]]), "exact Perl array-tree reference result")
end)

test("runtime inline value controls select one lazy payload", function()
  local source = uniform_binding_action_source([[
selector_calls = []
kind = "tag"
tag = "dynamic"
assigned = if(false, exit_now(7), elseif(true, { return("elseif") }), else(exit_now(8)))
subject_once = switch(
  { push(selector_calls, "seen"); kind },
  case(other, exit_now(9)),
  case(tag, { return("literal") }),
  default(exit_now(10))
)
dynamic = switch("dynamic", case(cat(tag, ""), "dynamic-hit"), default(exit_now(11)))
return({
  "true" : if(true, false, exit_now(12)),
  "null" : if(false, exit_now(13)),
  "plain" : if(0, exit_now(14), "fallback"),
  "zero_string" : if("0", exit_now(15), "zero"),
  "empty_array" : if([], "array-reference", exit_now(16)),
  "empty_harray" : if({}, "harray-reference", exit_now(17)),
  "assigned" : assigned,
  "subject_once" : subject_once,
  "selector_calls" : count(selector_calls),
  "dynamic" : dynamic,
  "switch_null" : switch("missing", case(tag, exit_now(18))),
  "switch_null_match" : switch(undef, case("", "null-match"), default(exit_now(19))),
  "switch_bool_number" : switch(false, case(0, "bool-number"), default(exit_now(20))),
  "switch_aggregate" : switch([], case("", exit_now(21)), default("aggregate-default"))
})
]])
  local result = execute_uniform_binding_source(source)
  assert_equal(result["true"], false, "selected false payload is preserved")
  assert_equal(result.null, json.null, "missing if fallback yields null")
  assert_equal(result.plain, "fallback", "plain fallback is selected lazily")
  assert_equal(result.zero_string, "zero", "Perl-oracle string zero is false")
  assert_equal(result.empty_array, "array-reference", "empty array value remains reference-truthful")
  assert_equal(result.empty_harray, "harray-reference", "empty harray value remains reference-truthful")
  assert_equal(result.assigned, "elseif", "selected elseif block returns locally")
  assert_equal(result.subject_once, "literal", "bare case label stays literal")
  assert_equal(result.selector_calls, 1, "switch subject evaluates exactly once")
  assert_equal(result.dynamic, "dynamic-hit", "compound case expression reads a binding")
  assert_equal(result.switch_null, json.null, "unmatched switch without default yields null")
  assert_equal(result.switch_null_match, "null-match", "null shares the governed empty scalar switch spelling")
  assert_equal(result.switch_bool_number, "bool-number", "false shares the governed numeric zero spelling")
  assert_equal(result.switch_aggregate, "aggregate-default", "aggregate values do not collapse to empty scalar text")

  local fluent = linkedspec.runtime_parse(
    linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec([[
Top::
 /x/ -> Done.return(if(false, "bad", "fluent"))
Done::
 /x/
]]))),
    "xx"
  ).value
  assert_equal(fluent, "fluent", "inline control composes in fluent return")

  for _, malformed in ipairs({
    { source = "return(if())", helper = "if" },
    { source = 'return(if(false, "x", elseif(true, "y", "z")))', helper = "elseif" },
    { source = "return(switch())", helper = "switch" },
    { source = 'return(switch("x", case()))', helper = "case" },
  }) do
    local ok, failure = pcall(function()
      execute_uniform_binding_source(uniform_binding_action_source(malformed.source))
    end)
    assert_equal(ok, false, malformed.helper .. " malformed arity fails")
    assert_equal(linkedspec.is_runtime_interpreter_error(failure), true, malformed.helper .. " typed failure")
    assert_equal(failure.code, "helper_arity_mismatch", malformed.helper .. " generic arity code")
    assert_equal(failure.helper_name, malformed.helper, malformed.helper .. " diagnostic helper")
  end

  for _, structural_alias in ipairs({ "i", "elif", "when", "otherwise" }) do
    local ok, failure = pcall(function()
      execute_uniform_binding_source(uniform_binding_action_source(
        'return(' .. structural_alias .. '(true, "yes", "no"))'
      ))
    end)
    assert_equal(ok, false, structural_alias .. " does not become an inline value alias")
    assert_equal(failure.helper_name, structural_alias, structural_alias .. " stays source-attributed")
  end

  local unless_resolution = linkedspec.resolve_action_expression_contracts(
    linkedspec.parse_action_expression('unless(true, "yes", "no")')
  )
  assert_equal(unless_resolution.ok, false, "unless remains outside the governed helper surface")
  assert_equal(unless_resolution.diagnostics[1].code, "unknown_helper", "unless uses generic unknown diagnostic")
  assert_equal(unless_resolution.diagnostics[1].helper_name, "unless", "unless diagnostic stays source-attributed")
end)

test("runtime statement if controls execute one attached or marker branch", function()
  local source = uniform_binding_action_source([[
events = []
if(false) { exit_now(31) }
elseif(true) { push(events, "attached-elseif") }
elseif(exit_now(32)) { exit_now(33) }
else { exit_now(34) }
when(false) { exit_now(35) } otherwise { push(events, "attached-otherwise") }
when(true) {} otherwise { exit_now(36) }
push(events, "after-attached-empty")
i(false)
  exit_now(37)
elif(true)
  push(events, "marker-elif")
elseif(exit_now(38))
  exit_now(39)
else()
  exit_now(40)
endif()
if(false)
  exit_now(41)
else()
  push(events, "marker-else")
endif()
if(true)
elseif(exit_now(42))
  exit_now(43)
endif()
push(events, "after-marker-empty")
if(true)
  if(false)
    exit_now(44)
  else()
    push(events, "nested-marker")
  endif()
else()
  exit_now(45)
endif()
attached_value = { if(false) { return("bad") } elseif(true) { return("attached-local") } else { return("bad") } }
marker_value = { i(false); return("bad"); elif(true); return("marker-local"); else(); return("bad"); endif() }
return({ "events" : copy(events), "attached_value" : attached_value, "marker_value" : marker_value })
]])
  local result = execute_uniform_binding_source(source)
  assert_json_equal(result.events, json.decode([[
[
  "attached-elseif",
  "attached-otherwise",
  "after-attached-empty",
  "marker-elif",
  "marker-else",
  "after-marker-empty",
  "nested-marker"
]
]]), "attached and marker branches preserve ActionIR order")
  assert_equal(result.attached_value, "attached-local", "attached branch return stays block-local")
  assert_equal(result.marker_value, "marker-local", "marker branch return stays block-local")

  local action_return = execute_uniform_binding_source(uniform_binding_action_source([[
if(false)
  return("bad")
else()
  return("marker-action-return")
endif()
exit_now(46)
]]))
  assert_equal(action_return, "marker-action-return", "selected marker return exits the surrounding action block")

  for _, malformed in ipairs({
    { source = 'elseif(true); return("bad")', keyword = "elseif", reason = "orphaned branch or marker" },
    { source = 'otherwise(); return("bad")', keyword = "otherwise", reason = "orphaned branch or marker" },
    { source = 'endif(); return("bad")', keyword = "endif", reason = "orphaned branch or marker" },
    { source = 'if(true); return("bad")', keyword = "if", reason = "missing endif" },
    { source = 'if(false); else(); else(); endif()', keyword = "else", reason = "duplicate else" },
    { source = 'if(false); else(); elif(true); endif()', keyword = "elif", reason = "elseif follows else" },
    {
      source = 'if(false) { return("bad") } elseif(true); return("mixed"); endif()',
      keyword = "elseif",
      reason = "cannot mix attached and marker branches",
    },
    { source = 'i(true) { return("bad") }', keyword = "i", reason = "expected if/when" },
    {
      source = 'if(false) { return("bad") } elif(true) { return("bad") }',
      keyword = "elif",
      reason = "expected elseif",
    },
    { source = 'when(true); return("bad"); endif()', keyword = "when", reason = "expected if/i" },
    {
      source = 'if(false); otherwise(); return("bad"); endif()',
      keyword = "otherwise",
      reason = "expected else",
    },
    {
      source = 'if(true) {} else {} otherwise {}',
      keyword = "otherwise",
      reason = "duplicate else",
    },
    {
      source = 'if(false) {} else {} elseif(true) {}',
      keyword = "elseif",
      reason = "elseif follows else",
    },
  }) do
    local ok, failure = pcall(function()
      execute_uniform_binding_source(uniform_binding_action_source(malformed.source))
    end)
    assert_equal(ok, false, malformed.keyword .. " malformed control fails")
    assert_equal(linkedspec.is_runtime_interpreter_error(failure), true, malformed.keyword .. " typed control failure")
    assert_equal(failure.code, "malformed_statement_control", malformed.keyword .. " control diagnostic code")
    assert_equal(failure.control_keyword, malformed.keyword, malformed.keyword .. " diagnostic keyword")
    assert_equal(failure.reason, malformed.reason, malformed.keyword .. " diagnostic reason")
    assert_equal(failure.rule_label, "Top", malformed.keyword .. " diagnostic rule")
  end
end)

test("runtime statement switch controls select one attached or marker branch", function()
  local source = uniform_binding_action_source([[
events = []
subject_calls = []
kind = "b"
switch({ push(subject_calls, "attached"); kind }) {
  case(a) { exit_now(51) }
  case(b) { push(events, "attached-bare") }
  case(exit_now(52)) { exit_now(53) }
  default { exit_now(54) }
}
switch("dynamic") {
  case(cat("dyna", "mic")) { push(events, "attached-dynamic") }
  default { exit_now(55) }
}
switch(undef) { case("") { push(events, "attached-null") } default { exit_now(56) } }
switch(false) { case(0) { push(events, "attached-bool-number") } default { exit_now(57) } }
switch([]) { case("") { exit_now(58) } default { push(events, "attached-aggregate-default") } }
switch("missing") { case(no) { exit_now(59) } default {} }
push(events, "after-attached-empty")
switch({ push(subject_calls, "marker"); kind })
case(a)
  exit_now(60)
endcase()
case(b)
  push(events, "marker-bare")
endcase()
case(exit_now(61))
  exit_now(62)
endcase()
default()
  exit_now(63)
endswitch()
switch("outer")
case(outer)
  switch("inner")
  case(inner)
    push(events, "nested-marker-switch")
  endcase()
  default()
    exit_now(64)
  endswitch()
endcase()
default()
  exit_now(65)
endswitch()
switch("missing")
case(no)
  exit_now(66)
endcase()
default()
  push(events, "marker-default")
endswitch()
switch("outside")
  exit_now(68)
case(outside)
  push(events, "marker-outside-skipped")
endcase()
exit_now(69)
endswitch()
attached_value = { switch("yes") { case(no) { return("bad") } case(yes) { return("attached-local") } default { return("bad") } } }
marker_value = {
  switch("yes")
  case(no)
    return("bad")
  endcase()
  case(yes)
    return("marker-local")
  endcase()
  default()
    return("bad")
  endswitch()
}
return({
  "events" : copy(events),
  "subject_calls" : copy(subject_calls),
  "attached_value" : attached_value,
  "marker_value" : marker_value
})
]])
  local result = execute_uniform_binding_source(source)
  assert_json_equal(result.events, json.decode([[
[
  "attached-bare",
  "attached-dynamic",
  "attached-null",
  "attached-bool-number",
  "attached-aggregate-default",
  "after-attached-empty",
  "marker-bare",
  "nested-marker-switch",
  "marker-default",
  "marker-outside-skipped"
]
]]), "attached and marker switch branches preserve ActionIR order")
  assert_json_equal(result.subject_calls, json.decode('["attached","marker"]'), "switch subjects run once")
  assert_equal(result.attached_value, "attached-local", "attached switch return stays block-local")
  assert_equal(result.marker_value, "marker-local", "marker switch return stays block-local")

  for _, malformed in ipairs({
    { source = 'case(x); return("bad")', keyword = "case", reason = "orphaned branch or marker" },
    { source = 'default(); return("bad")', keyword = "default", reason = "orphaned branch or marker" },
    { source = 'endcase(); return("bad")', keyword = "endcase", reason = "orphaned branch or marker" },
    { source = 'endswitch(); return("bad")', keyword = "endswitch", reason = "orphaned branch or marker" },
    { source = 'switch(exit_now(67)); case(x); return("bad")', keyword = "switch", reason = "missing endswitch" },
    {
      source = 'switch(x); default(); return("bad"); default(); return("bad"); endswitch()',
      keyword = "default",
      reason = "duplicate default",
    },
    {
      source = 'switch(x); default(); return("bad"); case(x); return("bad"); endswitch()',
      keyword = "case",
      reason = "case follows default",
    },
    {
      source = 'switch(x); endcase(); default(); return("bad"); endswitch()',
      keyword = "endcase",
      reason = "endcase without open branch",
    },
    {
      source = 'switch(x); case(x); endcase(); endcase(); endswitch()',
      keyword = "endcase",
      reason = "endcase without open branch",
    },
    {
      source = 'switch(x); case(x) { return("bad") }; endswitch()',
      keyword = "case",
      reason = "cannot mix attached and marker branches",
    },
    {
      source = 'switch(x) { set(out, "bad"); default { return("bad") } }',
      keyword = "call",
      reason = "expected attached case/default branch",
    },
    {
      source = 'switch(x) { default { return("bad") } default { return("bad") } }',
      keyword = "default",
      reason = "duplicate default",
    },
    {
      source = 'switch(x) { default { return("bad") } case(x) { return("bad") } }',
      keyword = "case",
      reason = "case follows default",
    },
  }) do
    local ok, failure = pcall(function()
      execute_uniform_binding_source(uniform_binding_action_source(malformed.source))
    end)
    assert_equal(ok, false, malformed.keyword .. " malformed switch fails")
    assert_equal(linkedspec.is_runtime_interpreter_error(failure), true, malformed.keyword .. " typed switch failure")
    assert_equal(failure.code, "malformed_statement_control", malformed.keyword .. " switch diagnostic code")
    assert_equal(failure.control_keyword, malformed.keyword, malformed.keyword .. " switch diagnostic keyword")
    assert_equal(failure.reason, malformed.reason, malformed.keyword .. " switch diagnostic reason")
    assert_equal(failure.rule_label, "Top", malformed.keyword .. " switch diagnostic rule")
  end
end)

test("runtime attached while controls re-evaluate state and enforce bounded safety", function()
  local source = uniform_binding_action_source([[
events = []
condition_calls = []
count = 0
while({ push(condition_calls, count); num_lt(count, 3) }) {
  push(events, count)
  count = num_add(count, 1)
}
while(false) { exit_now(70) }
next_count = 0
while(num_lt(next_count, 3)) {
  next_count = num_add(next_count, 1)
  next()
  exit_now(71)
}
local_value = {
  local_count = 0
  while(num_lt(local_count, 3)) {
    local_count = num_add(local_count, 1)
    if(num_eq(local_count, 2)) { return(["local", local_count]) }
  }
  exit_now(72)
}
return({
  "events" : copy(events),
  "condition_calls" : copy(condition_calls),
  "count" : count,
  "next_count" : next_count,
  "local_value" : local_value
})
]])
  local result = execute_uniform_binding_source(source)
  assert_json_equal(result.events, json.decode("[0,1,2]"), "while body observes each prior condition state")
  assert_json_equal(
    result.condition_calls,
    json.decode("[0,1,2,3]"),
    "while condition re-evaluates once after the final body"
  )
  assert_equal(result.count, 3, "while body mutation reaches the next condition")
  assert_equal(result.next_count, 3, "next continues the attached while body")
  assert_json_equal(result.local_value, json.decode('["local",2]'), "while return stays expression-block local")

  local action_return = execute_uniform_binding_source(uniform_binding_action_source([[
while(true) {
  return("action-return")
  exit_now(73)
}
exit_now(74)
]]))
  assert_equal(action_return, "action-return", "while body return exits the surrounding action")

  local exact_limit = linkedspec.runtime_parse(
    linkedspec.runtime_engine(
      linkedspec.compile_spec(linkedspec.parse_spec(uniform_binding_action_source([[
count = 0
while(num_lt(count, 3)) { count = num_add(count, 1) }
return(count)
]]))),
      { max_iterations = 3 }
    ),
    "xx"
  ).value
  assert_equal(exact_limit, 3, "condition becoming false after the final allowed body succeeds")

  local ok, failure = pcall(function()
    linkedspec.runtime_parse(
      linkedspec.runtime_engine(
        linkedspec.compile_spec(linkedspec.parse_spec(uniform_binding_action_source([[
count = 0
while(num_lt(count, 4)) { count = num_add(count, 1) }
return(count)
]]))),
        { max_iterations = 3 }
      ),
      "xx"
    )
  end)
  assert_equal(ok, false, "truthful condition after the final allowed body fails")
  assert_equal(linkedspec.is_runtime_interpreter_error(failure), true, "while limit is a typed runtime failure")
  assert_equal(failure.code, "while_iteration_limit_exceeded", "while limit diagnostic code")
  assert_equal(failure.control_keyword, "while", "while limit diagnostic keyword")
  assert_equal(failure.action_kind, "control_while", "while limit diagnostic ActionIR kind")
  assert_equal(failure.max_iterations, 3, "while limit diagnostic threshold")
  assert_equal(failure.rule_label, "Top", "while limit diagnostic rule")
  assert_equal(
    failure.message,
    "LinkedSpec while iteration safety limit exceeded after 3 iterations",
    "while limit diagnostic message"
  )

  local bodyless_ok, bodyless_failure = pcall(function()
    execute_uniform_binding_source(uniform_binding_action_source('while(exit_now(75)); return("bad")'))
  end)
  assert_equal(bodyless_ok, false, "bodyless while fails before evaluating its condition")
  assert_equal(linkedspec.is_runtime_interpreter_error(bodyless_failure), true, "bodyless while failure is typed")
  assert_equal(bodyless_failure.code, "malformed_statement_control", "bodyless while diagnostic code")
  assert_equal(bodyless_failure.control_keyword, "while", "bodyless while diagnostic keyword")
  assert_equal(bodyless_failure.reason, "attached while requires a body", "bodyless while diagnostic reason")
  assert_equal(bodyless_failure.rule_label, "Top", "bodyless while diagnostic rule")
end)

test("Lua matches the neutral scalar numeric contract exactly", function()
  local contract = json.decode(read_file("capability_conformance/scalar_numeric_contract.json"))
  assert_equal(contract.format, 1, "scalar numeric contract format")
  assert_equal(contract.contract_id, scalar_numeric.CONTRACT_ID, "scalar numeric contract id")
  assert_equal(#contract.cases, 55, "scalar numeric contract cases")
  local actual = execute_uniform_binding_source(contract.spec_source)
  assert_json_equal(actual, contract.expected, "all scalar numeric cases")
end)

test("runtime logical helpers are eager boolean values over governed truthiness", function()
  local source = uniform_binding_action_source([[
seen = []
and_value = and(
  { push(seen, "and-first"); return(false) },
  { push(seen, "and-second"); return(true) }
)
or_value = or(
  { push(seen, "or-first"); return(true) },
  { push(seen, "or-second"); return(false) }
)
not_value = not(
  { push(seen, "not-first"); return(false) },
  { push(seen, "not-extra"); return(true) }
)
return({
  "and_value" : and_value,
  "or_value" : or_value,
  "not_value" : not_value,
  "and_empty" : and(),
  "or_empty" : or(),
  "not_empty" : not(),
  "lua_aggregate_truthiness" : and([], {}, true),
  "lua_zero_truthiness" : or("0", 0, ""),
  "receiver_value" : and(1, 2).with() { return(value) },
  "seen" : copy(seen)
})
]])
  assert_json_equal(execute_uniform_binding_source(source), json.harray({
    and_value = false,
    or_value = true,
    not_value = true,
    and_empty = false,
    or_empty = false,
    not_empty = true,
    lua_aggregate_truthiness = true,
    lua_zero_truthiness = false,
    receiver_value = true,
    seen = json.array({
      "and-first",
      "and-second",
      "or-first",
      "or-second",
      "not-first",
      "not-extra",
    }),
  }), "logical helper values and eager order")
end)

test("numeric aliases symbols and receiver chains share the scalar evaluator", function()
  local grouped_regex = linkedspec.parse_action_expression("/(foo),bar/")
  local class_regex = linkedspec.parse_action_expression("/([)])/")
  assert_equal(grouped_regex.kind, "regex", "grouped comma regex stays a regex")
  assert_equal(grouped_regex.pattern, "(foo),bar", "grouped comma regex payload")
  assert_equal(class_regex.kind, "regex", "class closing parenthesis stays a regex")
  assert_equal(class_regex.pattern, "([)])", "class closing parenthesis regex payload")
  local source = uniform_binding_action_source([[
score = -2.5
return({
  "word_abs" : abs(-4),
  "word_add" : add(1, 2, 3),
  "word_ceil" : ceil(-3.2),
  "word_clamp" : clamp(12, 0, 10),
  "word_div" : div(7, 2),
  "word_eq" : eq(2, 2),
  "word_floor" : floor(-3.2),
  "word_ge" : ge(2, 2),
  "word_gt" : gt(3, 2),
  "word_le" : le(2, 2),
  "word_lt" : lt(1, 2),
  "word_max" : max(2, 5, 3),
  "word_min" : min(2, 5, 3),
  "word_mod" : mod(7, 3),
  "word_mul" : mul(2, 3, 4),
  "word_ne" : ne(2, 3),
  "word_round" : round(-2.5),
  "word_sub" : sub(10, 3),
  "symbol_add" : +(2, 3),
  "symbol_sub" : -(5, 3),
  "symbol_mul" : *(3, 4),
  "symbol_div" : /(7, 2),
  "symbol_mod" : %(7, 3),
  "symbol_eq" : ==(2, 2),
  "symbol_ne" : !=(2, 3),
  "symbol_gt" : >(3, 2),
  "symbol_ge" : >=(2, 2),
  "symbol_lt" : <(1, 2),
  "symbol_le" : <=(2, 2),
  "integer_receiver" : 5.mod(2),
  "float_chain" : 3.5.floor().add(1),
  "bare_scalar_chain" : score.abs().mul(2),
  "comparison_receiver" : 5.gt(2),
  "terminal_eq" : 2.eq(2).add(1),
  "terminal_ne" : 2.ne(3).add(1),
  "terminal_gt" : 5.gt(2).add(1),
  "terminal_ge" : 2.ge(2).add(1),
  "terminal_lt" : 1.lt(2).add(1),
  "terminal_le" : 2.le(2).add(1)
})
]])
  local expected = json.decode([[
{
  "word_abs": 4, "word_add": 6, "word_ceil": -3, "word_clamp": 10,
  "word_div": 3.5, "word_eq": 1, "word_floor": -4, "word_ge": 1,
  "word_gt": 1, "word_le": 1, "word_lt": 1, "word_max": 5,
  "word_min": 2, "word_mod": 1, "word_mul": 24, "word_ne": 1,
  "word_round": -3, "word_sub": 7,
  "symbol_add": 5, "symbol_sub": 2, "symbol_mul": 12, "symbol_div": 3.5,
  "symbol_mod": 1, "symbol_eq": 1, "symbol_ne": 1, "symbol_gt": 1,
  "symbol_ge": 1, "symbol_lt": 1, "symbol_le": 1,
  "integer_receiver": 1, "float_chain": 4, "bare_scalar_chain": 5,
  "comparison_receiver": 1, "terminal_eq": null, "terminal_ne": null,
  "terminal_gt": null, "terminal_ge": null, "terminal_lt": null, "terminal_le": null
}
]])
  assert_json_equal(execute_uniform_binding_source(source), expected, "numeric call and receiver surfaces")
end)

test("numeric aggregate reducers preserve arrays and terminate receiver chains", function()
  local source = uniform_binding_action_source([[
scores = [1, "2", 5, 4]
empty = []
invalid = [1, true]
return({
  "explicit_sum" : num_sum([1, "2", 3]),
  "canonical_avg" : num_avg([2, 4, 6]),
  "canonical_range" : num_range([3, 9, 1, 7]),
  "canonical_max" : num_max([8, 3, 5]),
  "alias_sum" : sum([1, 2, 3]),
  "alias_min" : min([8, 3, 5]),
  "bare_avg" : avg(scores),
  "median_odd" : median([5, 1, 3]),
  "median_even" : num_median([4, 1, 3, 2]),
  "range" : range([3, 9, 1, 7]),
  "array_min" : num_min([8, 3, 5]),
  "array_max" : max([8, 3, 5]),
  "empty_sum" : sum(empty),
  "empty_avg" : avg(empty),
  "empty_median" : median(empty),
  "empty_range" : range(empty),
  "empty_min" : min(empty),
  "empty_max" : max(empty),
  "invalid_element" : sum(invalid),
  "invalid_kind" : sum(3),
  "wrong_arity" : sum([1], [2]),
  "source_after" : scores,
  "receiver_sum" : scores.sum(),
  "receiver_avg" : scores.avg(),
  "receiver_median" : scores.median(),
  "receiver_range" : scores.range(),
  "receiver_min" : scores.min(),
  "receiver_max" : scores.max(),
  "receiver_wrong_arity" : scores.sum(1),
  "receiver_terminal" : scores.sum().add(1)
})
]])
  local expected = json.decode([[
{
  "explicit_sum": 6, "canonical_avg": 4, "canonical_range": 8,
  "canonical_max": 8, "alias_sum": 6, "alias_min": 3,
  "bare_avg": 3, "median_odd": 3, "median_even": 2.5,
  "range": 8, "array_min": 3, "array_max": 8, "empty_sum": 0,
  "empty_avg": null, "empty_median": null, "empty_range": null,
  "empty_min": null, "empty_max": null, "invalid_element": null,
  "invalid_kind": null, "wrong_arity": null, "source_after": [1, "2", 5, 4],
  "receiver_sum": 12, "receiver_avg": 3, "receiver_median": 3,
  "receiver_range": 4, "receiver_min": 1, "receiver_max": 5,
  "receiver_wrong_arity": null, "receiver_terminal": null
}
]])
  assert_json_equal(execute_uniform_binding_source(source), expected, "numeric aggregate reducer surfaces")
end)

local function selector_diagnostic(surface, identifier)
  return "aggregate_selector_removed surface=" .. surface ..
    " identifier=" .. identifier .. " replacement=" .. identifier
end

local function assert_selector_compile_error(source, surface, identifier, label, spec_override)
  local ok, compile_error = pcall(function()
    return linkedspec.compile_spec(spec_override or linkedspec.parse_spec(source))
  end)
  assert_equal(ok, false, label .. " rejects")
  assert_equal(linkedspec.is_compiled_spec_error(compile_error), true, label .. " error type")
  assert_contains(compile_error.message, selector_diagnostic(surface, identifier), label .. " diagnostic")
  assert_equal(compile_error.code, "aggregate_selector_removed", label .. " code")
  assert_equal(compile_error.surface, surface, label .. " surface")
  assert_equal(compile_error.identifier, identifier, label .. " identifier")
  assert_equal(compile_error.replacement, identifier, label .. " replacement")
end

test("uniform-binding exact aggregate selectors fail compilation", function()
  local handle = assert(io.open("capability_conformance/uniform_binding_contract.json", "rb"))
  local contract = json.decode(assert(handle:read("*a")))
  assert(handle:close())
  for _, case in ipairs(contract.invalid_selector_cases) do
    assert_selector_compile_error(
      uniform_binding_action_source(case.source),
      case.surface,
      case.identifier,
      case.id
    )
  end
end)

test("uniform-binding dead fluent function and caller-mutated selectors reject", function()
  assert_selector_compile_error(
    uniform_binding_action_source("if(false) { return(array(items)) }; return([])"), -- selector-rejection fixture
    "array",
    "items",
    "dead selector"
  )
  assert_selector_compile_error(
    "Top::\n -> Done.return(hash(meta))\nDone::\n /x/\n", -- selector-rejection fixture
    "hash",
    "meta",
    "fluent selector"
  )

  local parsed = linkedspec.parse_spec(uniform_binding_action_source("return([])"))
  local definition = registry_function(
    "retired",
    {},
    0,
    nil,
    "return(array(items))" -- selector-rejection fixture
  )
  local function_spec = ast.spec_file({ functions = { definition }, rules = parsed.rules })
  assert_selector_compile_error("", "array", "items", "unused function selector", function_spec)

  local compiled = linkedspec.compile_spec(parsed)
  local payload = linkedspec.compiled_spec.action_payloads(compiled.rules_by_label.Top)[1]
  payload.action_ast = linkedspec.parse_action_block("array" .. "(items)") -- selector-rejection fixture: array(items)
  local ok, runtime_error = pcall(function() return linkedspec.runtime_engine(compiled) end)
  assert_equal(ok, false, "caller-mutated selector rejects")
  assert_equal(linkedspec.is_compiled_spec_error(runtime_error), true, "caller-mutated error type")
  assert_contains(runtime_error.message, selector_diagnostic("array", "items"), "caller-mutated diagnostic")
end)

test("uniform-binding retained aggregate constructors and literals execute", function()
  local result = execute_uniform_binding_source(uniform_binding_action_source([[
items = ["x"]
left = "l"
right = "r"
key = "key"
value = "r"
return([
  array(),
  array("items"),
  array(copy(items)),
  array(left, right),
  hash(),
  hash("key", value),
  [items],
  { key : value }
])
]]))
  assert_json_equal(result, json.array({
    json.array(),
    json.array({ "items" }),
    json.array({ json.array({ "x" }) }),
    json.array({ "l", "r" }),
    json.harray(),
    json.harray({ key = "r" }),
    json.array({ json.array({ "x" }) }),
    json.harray({ key = "r" }),
  }), "retained aggregate forms")
end)

test("uniform-binding future fixture executes", function()
  local handle = assert(io.open("capability_conformance/uniform_binding_contract.json", "rb"))
  local contract = json.decode(assert(handle:read("*a")))
  assert(handle:close())
  assert_equal(contract.contract_id, "linkedspec-uniform-binding-v1", "contract id")
  assert_json_equal(
    execute_uniform_binding_source(contract.fixture.spec_source, contract.fixture.input),
    contract.fixture.expected,
    "future fixture"
  )
end)

test("uniform-binding absent push and array-end mutation return independent updates", function()
  local result = execute_uniform_binding_source([[
Top::
 /x/ -> Done {
   first_push = push(items, "a")
   second_push = push(items, "b")
   items += "c"
   after_push_back = items.push_back("d")
   after_push_front = items.push_front("z")
   after_pop_back = items.pop_back()
   after_pop_front = items.pop_front()
   count = items.push_back("e").count()
   return({
     "items" : items,
     "first_push" : first_push,
     "second_push" : second_push,
     "after_push_back" : after_push_back,
     "after_push_front" : after_push_front,
     "after_pop_back" : after_pop_back,
     "after_pop_front" : after_pop_front,
     "count" : count
   })
 }
Done::
 /x/
]])
  assert_json_equal(result, json.harray({
    items = json.array({ "a", "b", "c", "e" }),
    first_push = json.array({ "a" }),
    second_push = json.array({ "a", "b" }),
    after_push_back = json.array({ "a", "b", "c", "d" }),
    after_push_front = json.array({ "z", "a", "b", "c", "d" }),
    after_pop_back = json.array({ "z", "a", "b", "c" }),
    after_pop_front = json.array({ "a", "b", "c" }),
    count = 4,
  }), "updated arrays")
end)

test("uniform-binding registered rule keeps ambiguous push precedence", function()
  local result = execute_uniform_binding_source([[
Top::
 I { items = ["unchanged"]; outputs = [] }
 /x/ -> Done { pushed = push(items, outputs); return([items, outputs, pushed]) }
items::
 /x/ I { return("child-result") }
Done::
 /x/
]])
  assert_json_equal(result, json.array({
    json.array({ "unchanged" }),
    json.array({ "child-result" }),
    json.array({ "child-result" }),
  }), "static rule precedence")
end)

test("runtime child push reuses action edge and selects zero based results", function()
  local forms = execute_uniform_binding_source([[
Parent::
 I { set(explicit, []) }
 -> Child {
   push(Child)
   push(Child, explicit)
   push(Child, 1)
   push(Child, explicit, 0)
 }
 LX {
   return({
     "implicit" : copy(Parent),
     "explicit" : copy(explicit),
     "absent_rule" : copy(Other)
   })
 }

Child:
 /x/
 I { return(["zero", "one"]) }

Other: /z/
]], "x")
  assert_json_equal(forms, json.harray({
    implicit = json.array({ json.array({ "zero", "one" }), "one" }),
    explicit = json.array({ json.array({ "zero", "one" }), "zero" }),
    absent_rule = json.array(),
  }), "child push forms")
end)

test("runtime fluent child push fills implicit and explicit accumulators", function()
  local implicit = execute_uniform_binding_source([[
top::
 -> item .push
 E { return(copy(top)) }

item:
 /x/
 I { return(entry_text()) }
]], "xx")
  assert_json_equal(implicit, json.array({ "x", "x" }), "fluent implicit child push")

  local explicit = execute_uniform_binding_source([[
Top::
 I { set(out, []) }
 -> Item.push(out)
 E { return(copy(out)) }

Item:
 /x/
 I { return(entry_text()) }
]], "xx")
  assert_json_equal(explicit, json.array({ "x", "x" }), "fluent explicit child push")
end)

test("runtime child push rejects wrong kind explicit accumulator", function()
  local ok, failure = pcall(function()
    execute_uniform_binding_source([[
Parent::
 I { explicit = "text" }
 -> Child { push(Child, explicit) }

Child: /x/ I { return("child") }
]], "x")
  end)
  assert_equal(ok, false, "wrong-kind child push fails")
  assert_equal(linkedspec.is_runtime_interpreter_error(failure), true, "typed child push error")
  assert_equal(failure.code, "binding_kind_mismatch", "child push error code")
  assert_equal(failure.identifier, "explicit", "child push error identifier")
  assert_equal(failure.expected_kind, "array", "child push expected kind")
  assert_equal(failure.actual_kind, "scalar", "child push actual kind")
end)

test("uniform-binding mutable and pure split remain distinct", function()
  local result = execute_uniform_binding_source([[
Top::
 /x/ -> Done {
   stored = split(parts, "a,b", ",")
   pure = split("c,d", ",")
   return({ "parts" : parts, "stored" : stored, "pure" : pure })
 }
Done::
 /x/
]])
  assert_json_equal(result, json.harray({
    parts = json.array({ "a", "b" }),
    stored = json.array({ "a", "b" }),
    pure = json.array({ "c", "d" }),
  }), "split forms")
end)

test("uniform-binding hash-index mutation returns the updated harray", function()
  local result = execute_uniform_binding_source([[
Top::
 /x/ -> Done {
   updated = (meta["stage"] = "ok")
   snapshot = copy(meta)
   return({ "meta" : meta, "updated" : updated, "snapshot" : snapshot })
 }
Done::
 /x/
]])
  local expected = json.harray({ stage = "ok" })
  assert_json_equal(result, json.harray({
    meta = expected,
    updated = expected,
    snapshot = expected,
  }), "harray update")
end)

test("runtime named harray mutation shares one binding seam and preserves pure forms", function()
  local result = execute_uniform_binding_source([[
Top::
 /x/ -> Done {
   set(existing, { "seed" : { "nested" : 1 } })
   set_key(existing, "statement", { "nested" : 2 })
   statement_snapshot = (existing["operator"] = { "nested" : 3 })
   set_key(created, "first", 1)
   direct_snapshot = (direct_created["first"] = { "nested" : 4 })
   set(indexed, ["a"])
   indexed_snapshot = (indexed[1] = "b")
   pure_call = set_key(existing, "pure_call", 5)
   pure_receiver = existing.set_key("pure_receiver", 6)
   existing["statement"]["nested"] = 9
   existing["later"] = 7
   direct_created["first"]["nested"] = 8
   indexed[0] = "changed"
   return({
     "existing" : existing,
     "created" : created,
     "direct_created" : direct_created,
     "statement_snapshot" : statement_snapshot,
     "direct_snapshot" : direct_snapshot,
     "indexed" : indexed,
     "indexed_snapshot" : indexed_snapshot,
     "pure_call" : pure_call,
     "pure_receiver" : pure_receiver
   })
 }
Done::
 /x/
]])
  assert_json_equal(result, json.harray({
    existing = json.harray({
      later = 7,
      operator = json.harray({ nested = 3 }),
      seed = json.harray({ nested = 1 }),
      statement = json.harray({ nested = 9 }),
    }),
    created = json.harray({ first = 1 }),
    direct_created = json.harray({ first = json.harray({ nested = 8 }) }),
    statement_snapshot = json.harray({
      operator = json.harray({ nested = 3 }),
      seed = json.harray({ nested = 1 }),
      statement = json.harray({ nested = 2 }),
    }),
    direct_snapshot = json.harray({ first = json.harray({ nested = 4 }) }),
    indexed = json.array({ "changed", "b" }),
    indexed_snapshot = json.array({ "a", "b" }),
    pure_call = json.harray({
      operator = json.harray({ nested = 3 }),
      pure_call = 5,
      seed = json.harray({ nested = 1 }),
      statement = json.harray({ nested = 2 }),
    }),
    pure_receiver = json.harray({
      operator = json.harray({ nested = 3 }),
      pure_receiver = 6,
      seed = json.harray({ nested = 1 }),
      statement = json.harray({ nested = 2 }),
    }),
  }), "named harray mutation")

  for _, case in ipairs({
    { source = [[
Top::
 /x/ -> Done { set(wrong, "text"); set_key(wrong, "key", 1) }
Done::
 /x/
]], actual_kind = "scalar" },
    { source = [[
Top::
 /x/ -> Done { set(wrong, 17); wrong["key"] = "value" }
Done::
 /x/
]], actual_kind = "scalar" },
    { source = [[
Top::
 /x/ -> Done { set(wrong, ["array"]); set_key(wrong, "key", "value") }
Done::
 /x/
]], actual_kind = "array" },
  }) do
    local ok, failure = pcall(function() execute_uniform_binding_source(case.source) end)
    assert_equal(ok, false, "wrong-kind harray mutation fails")
    assert_equal(linkedspec.is_runtime_interpreter_error(failure), true, "typed harray mutation error")
    assert_equal(failure.code, "binding_kind_mismatch", "harray mutation error code")
    assert_equal(failure.identifier, "wrong", "harray mutation error identifier")
    assert_equal(failure.expected_kind, "harray", "harray mutation expected kind")
    assert_equal(failure.actual_kind, case.actual_kind, "harray mutation actual kind")
  end
end)

test("uniform-binding unused values are dropped", function()
  local result = execute_uniform_binding_source([[
Top::
 /x/ -> Done {
   set(items, ["a"])
   copy(items)
   updated = push(items, "b")
   return({ "items" : items, "updated" : updated })
 }
Done::
 /x/
]])
  local expected = json.array({ "a", "b" })
  assert_json_equal(result, json.harray({ items = expected, updated = expected }), "dropped values")
end)

test("uniform-binding bare collection statements rebind the typed array", function()
  local result = execute_uniform_binding_source([[
Top::
 /x/ -> Done {
   trimmed = trim_each(set(words, [" a ", "", "b"]))
   trim_each(words)
   filter_nonempty(words)
   return({ "trimmed" : trimmed, "words" : words })
 }
Done::
 /x/
]])
  assert_json_equal(result, json.harray({
    trimmed = json.array({ "a", "", "b" }),
    words = json.array({ "a", "b" }),
  }), "collection rebinding")
end)

test("runtime copied array construction splices only explicit flat values", function()
  local result = execute_uniform_binding_source([=[
Top::
 /x/ -> Done {
   set(source, ["a", ["b"]])
   nested_call = array("tag", source)
   nested_literal = ["tag", copy(source)]
   call_splice = array("tag", flat_array(source), "tail")
   literal_splice = ["tag", flat(source), "tail"]
   receiver_splice = array("tag", source.flat(), "tail")
   concatenated = concat_arrays(["x"], ["y", "z"])
   flattened = flat_array(["p", "q"], "r", ["s"])
   snapshot = copy(source)
   source.push_back("c")
   ordered_call = array(set(step, 1), set(step, 2), step)
   ordered_literal = [set(step, 3), set(step, 4), step]
   return({
     "source" : source,
     "snapshot" : snapshot,
     "nested_call" : nested_call,
     "nested_literal" : nested_literal,
     "call_splice" : call_splice,
     "literal_splice" : literal_splice,
     "receiver_splice" : receiver_splice,
     "concatenated" : concatenated,
     "flattened" : flattened,
     "empty_array" : array(),
     "empty_flattened" : flat_array(),
     "empty_concatenated" : concat_arrays(),
     "missing_flat" : flat(),
     "missing_copy" : copy(),
     "ordered_call" : ordered_call,
     "ordered_literal" : ordered_literal
   })
 }
Done::
 /x/
]=])
  assert_json_equal(result, json.harray({
    source = json.array({ "a", json.array({ "b" }), "c" }),
    snapshot = json.array({ "a", json.array({ "b" }) }),
    nested_call = json.array({ "tag", json.array({ "a", json.array({ "b" }) }) }),
    nested_literal = json.array({ "tag", json.array({ "a", json.array({ "b" }) }) }),
    call_splice = json.array({ "tag", "a", json.array({ "b" }), "tail" }),
    literal_splice = json.array({ "tag", "a", json.array({ "b" }), "tail" }),
    receiver_splice = json.array({ "tag", "a", json.array({ "b" }), "tail" }),
    concatenated = json.array({ "x", "y", "z" }),
    flattened = json.array({ "p", "q", "r", "s" }),
    empty_array = json.array(),
    empty_flattened = json.array(),
    empty_concatenated = json.array(),
    missing_flat = json.array({ json.null }),
    missing_copy = json.null,
    ordered_call = json.array({ 1, 2, 2 }),
    ordered_literal = json.array({ 3, 4, 4 }),
  }), "copied array construction")
end)

test("runtime copied harray construction splices only explicit flat values", function()
  local result = execute_uniform_binding_source([[
Top::
 /x/ -> Done {
   set(step, 0)
   set(source, { "b" : 2, "a" : { "nested" : 1 } })
   set(pair_tokens, ["direct", { "nested" : 1 }, "tail", 2])
   set(empty_tokens, [])
   constructed = hash(
     "left",
     set(step, add(step, 1)),
     flat_hash(set(extra, { "x" : set(step, add(step, 1)) }))
   )
   nested = hash("payload", source)
   flat_copy = flat(source)
   flat_hash_copy = source.flat_hash()
   generic_splice = hash("kind", "root", flat(source))
   hash_splice = hash("kind", "root", source.flat_hash())
   positioned_splice = hash(flat_hash({ "a" : 1 }), "b", 2, flat({ "a" : 3 }), "c", 4)
   array_pair_splice = hash(flat(["p", 3, "missing"]))
   flat_array_splice = hash(flat_array(pair_tokens))
   receiver_flat_array_splice = hash(pair_tokens.flat_array())
   positioned_flat_array_splice = hash("head", 0, flat_array(["middle", 1]), "tail", 2)
   harray_flat_array_splice = harray(flat_array(["alias", 3]))
   empty_flat_array_splice = hash(flat_array())
   empty_receiver_flat_array_splice = hash(empty_tokens.flat_array())
   ordinary_array_value = hash("payload", pair_tokens)
   odd = hash("present", 1, "missing")
   call_list_splice = array("tag", flat_hash(source))
   literal_list_splice = ["tag", source.flat()]
   source["b"] = 9
   source["a"]["nested"] = 7
   pair_tokens[1]["nested"] = 9
   extra["x"] = 99
   return({
     "step" : step,
     "constructed" : constructed,
     "nested" : nested,
     "flat_copy" : flat_copy,
     "flat_hash_copy" : flat_hash_copy,
     "generic_splice" : generic_splice,
     "hash_splice" : hash_splice,
     "positioned_splice" : positioned_splice,
     "array_pair_splice" : array_pair_splice,
     "flat_array_splice" : flat_array_splice,
     "receiver_flat_array_splice" : receiver_flat_array_splice,
     "positioned_flat_array_splice" : positioned_flat_array_splice,
     "harray_flat_array_splice" : harray_flat_array_splice,
     "empty_flat_array_splice" : empty_flat_array_splice,
     "empty_receiver_flat_array_splice" : empty_receiver_flat_array_splice,
     "ordinary_array_value" : ordinary_array_value,
     "odd" : odd,
     "call_list_splice" : call_list_splice,
     "literal_list_splice" : literal_list_splice,
     "source" : source,
     "pair_tokens" : pair_tokens,
     "extra" : extra
   })
 }
Done::
 /x/
]])
  local original = json.harray({ a = json.harray({ nested = 1 }), b = 2 })
  assert_json_equal(result, json.harray({
    step = 2,
    constructed = json.harray({ left = 1, x = 2 }),
    nested = json.harray({ payload = original }),
    flat_copy = original,
    flat_hash_copy = original,
    generic_splice = json.harray({ a = json.harray({ nested = 1 }), b = 2, kind = "root" }),
    hash_splice = json.harray({ a = json.harray({ nested = 1 }), b = 2, kind = "root" }),
    positioned_splice = json.harray({ a = 3, b = 2, c = 4 }),
    array_pair_splice = json.harray({ p = 3, missing = json.null }),
    flat_array_splice = json.harray({ direct = json.harray({ nested = 1 }), tail = 2 }),
    receiver_flat_array_splice = json.harray({ direct = json.harray({ nested = 1 }), tail = 2 }),
    positioned_flat_array_splice = json.harray({ head = 0, middle = 1, tail = 2 }),
    harray_flat_array_splice = json.harray({ alias = 3 }),
    empty_flat_array_splice = json.harray(),
    empty_receiver_flat_array_splice = json.harray(),
    ordinary_array_value = json.harray({ payload = json.array({
      "direct", json.harray({ nested = 1 }), "tail", 2,
    }) }),
    odd = json.harray({ present = 1, missing = json.null }),
    call_list_splice = json.array({ "tag", "a", json.harray({ nested = 1 }), "b", 2 }),
    literal_list_splice = json.array({ "tag", "a", json.harray({ nested = 1 }), "b", 2 }),
    source = json.harray({ a = json.harray({ nested = 7 }), b = 9 }),
    pair_tokens = json.array({ "direct", json.harray({ nested = 9 }), "tail", 2 }),
    extra = json.harray({ x = 99 }),
  }), "copied harray construction")
end)

test("runtime receiver copy preserves evaluated values and continuation kinds", function()
  local result = execute_uniform_binding_source([[
Top::
 /x/ -> Done {
   evaluations = 0
   source = {
     "a" : 1,
     "nested" : { "value" : "original" },
     "items" : ["a", "b"]
   }
   items = ["a", "b"]
   raw = " text "
   copied = source.copy()
   copied["nested"]["value"] = "changed"
   copied["items"][0] = "changed"
   evaluated_once = set(evaluations, add(evaluations, 1)).copy().add(1)
   return({
     "source" : source,
     "copied" : copied,
     "harray_chain" : source.copy().flat_hash().count_keys(),
     "derived_harray_chain" : source.set_key("extra", 2).copy().count_keys(),
     "array_chain" : items.copy().drop_front(1).first(),
     "string_chain" : raw.copy().trim().uppercase(),
     "evaluated_once" : evaluated_once,
     "evaluations" : evaluations,
     "missing_copy" : missing.copy(),
     "missing_chain" : missing.copy().count_keys(),
     "function_copy_chain" : copy(source).flat_hash().count_keys(),
     "function_missing_copy" : copy()
   })
 }
Done:: /x/
]])
  assert_json_equal(result, json.harray({
    source = json.harray({
      a = 1,
      nested = json.harray({ value = "original" }),
      items = json.array({ "a", "b" }),
    }),
    copied = json.harray({
      a = 1,
      nested = json.harray({ value = "changed" }),
      items = json.array({ "changed", "b" }),
    }),
    harray_chain = 3,
    derived_harray_chain = 4,
    array_chain = "b",
    string_chain = "TEXT",
    evaluated_once = 2,
    evaluations = 1,
    missing_copy = json.null,
    missing_chain = 0,
    function_copy_chain = 3,
    function_missing_copy = json.null,
  }), "receiver copy")
end)

test("runtime deterministic harray views preserve key order and copied values", function()
  local result = execute_uniform_binding_source([[
Top::
 /x/ -> Done {
   set(meta, { "c" : 3, "a" : undef, "b" : { "nested" : 2 } })
   keys = sorted_keys(meta)
   values = meta.sorted_values()
   nested_from_chain = meta.sorted_values().drop_front().first()
   meta["b"]["nested"] = 9
   return({
     "count" : count_keys(meta),
     "receiver_count" : meta.count_keys(),
     "keys" : keys,
     "key_chain" : meta.sorted_keys().join_values(","),
     "values" : values,
     "nested_from_chain" : nested_from_chain,
     "has_null" : has_key(meta, "a"),
     "receiver_has" : meta.has_key("b"),
     "missing_key" : has_key(meta, "missing"),
     "missing_key_arg" : has_key(meta),
     "invalid_count" : count_keys("text"),
     "missing_count" : count_keys(),
     "invalid_keys" : sorted_keys(undef),
     "missing_values" : sorted_values(),
     "invalid_has" : has_key("text", "a"),
     "terminal_count" : meta.count_keys().add(1),
     "terminal_has" : meta.has_key("a").add(1),
     "meta" : meta
   })
 }
Done::
 /x/
]])
  assert_json_equal(result, json.harray({
    count = 3,
    receiver_count = 3,
    keys = json.array({ "a", "b", "c" }),
    key_chain = "a,b,c",
    values = json.array({ json.null, json.harray({ nested = 2 }), 3 }),
    nested_from_chain = json.harray({ nested = 2 }),
    has_null = 1,
    receiver_has = 1,
    missing_key = 0,
    missing_key_arg = 0,
    invalid_count = 0,
    missing_count = 0,
    invalid_keys = json.array(),
    missing_values = json.array(),
    invalid_has = 0,
    terminal_count = json.null,
    terminal_has = json.null,
    meta = json.harray({ a = json.null, b = json.harray({ nested = 9 }), c = 3 }),
  }), "deterministic harray views")
end)

test("runtime copied harray transforms preserve overrides isolation and receiver flow", function()
  local result = execute_uniform_binding_source([[
Top::
 /x/ -> Done {
   set(base, {
     "b" : 2,
     "a" : { "nested" : 1 },
     "same" : "base",
     "old" : 7,
     "new" : 9,
     "drop" : 0,
     "null" : undef
   })
   set(overlay, { "c" : 3, "same" : "overlay", "a" : { "nested" : 4 } })
   merged = merge_hash(base, overlay)
   receiver_merged = base.merge_hash(overlay).drop_keys("drop").set_key("z", 5)
   value_set = set_key(base, "added", { "value" : 8 })
   renamed = rename_key(base, "old", "renamed")
   collision = rename_key(base, "old", "new")
   same_rename = rename_key(base, "old", "old")
   dropped = drop_keys(base, "drop", "missing")
   picked = pick_keys(base, "a", "same", "null", "missing")
   base["a"]["nested"] = 99
   overlay["a"]["nested"] = 88
   return({
     "merged" : merged,
     "merged_chain" : merged.sorted_keys().join_values(","),
     "receiver_merged" : receiver_merged,
     "receiver_chain" : base.rename_key("old", "renamed").drop_keys("drop").set_key("z", 5).sorted_keys().join_values(","),
     "value_set" : value_set,
     "renamed" : renamed,
     "collision" : collision,
     "same_rename" : same_rename,
     "dropped" : dropped,
     "picked" : picked,
     "source_base" : base,
     "source_overlay" : overlay,
     "source_has_added" : base.has_key("added"),
     "source_has_renamed" : base.has_key("renamed"),
     "invalid_set" : set_key("text", "x", 1),
     "missing_set_value" : set_key(base, "x"),
     "invalid_rename" : rename_key("text", "old", "new"),
     "missing_rename_value" : rename_key(base, "old"),
     "invalid_drop" : drop_keys("text", "x"),
     "missing_drop" : drop_keys(),
     "invalid_pick" : pick_keys("text", "x"),
     "missing_pick" : pick_keys(),
     "empty_pick" : pick_keys(base),
     "empty_merge" : merge_hash()
   })
 }
Done::
 /x/
]])
  assert_json_equal(result, json.harray({
    merged = json.harray({
      a = json.harray({ nested = 4 }),
      b = 2,
      c = 3,
      drop = 0,
      new = 9,
      null = json.null,
      old = 7,
      same = "overlay",
    }),
    merged_chain = "a,b,c,drop,new,null,old,same",
    receiver_merged = json.harray({
      a = json.harray({ nested = 4 }),
      b = 2,
      c = 3,
      new = 9,
      null = json.null,
      old = 7,
      same = "overlay",
      z = 5,
    }),
    receiver_chain = "a,b,new,null,renamed,same,z",
    value_set = json.harray({
      a = json.harray({ nested = 1 }),
      added = json.harray({ value = 8 }),
      b = 2,
      drop = 0,
      new = 9,
      null = json.null,
      old = 7,
      same = "base",
    }),
    renamed = json.harray({
      a = json.harray({ nested = 1 }),
      b = 2,
      drop = 0,
      new = 9,
      null = json.null,
      renamed = 7,
      same = "base",
    }),
    collision = json.harray({
      a = json.harray({ nested = 1 }),
      b = 2,
      drop = 0,
      new = 7,
      null = json.null,
      same = "base",
    }),
    same_rename = json.harray({
      a = json.harray({ nested = 1 }),
      b = 2,
      drop = 0,
      new = 9,
      null = json.null,
      old = 7,
      same = "base",
    }),
    dropped = json.harray({
      a = json.harray({ nested = 1 }),
      b = 2,
      new = 9,
      null = json.null,
      old = 7,
      same = "base",
    }),
    picked = json.harray({ a = json.harray({ nested = 1 }), null = json.null, same = "base" }),
    source_base = json.harray({
      a = json.harray({ nested = 99 }),
      b = 2,
      drop = 0,
      new = 9,
      null = json.null,
      old = 7,
      same = "base",
    }),
    source_overlay = json.harray({ a = json.harray({ nested = 88 }), c = 3, same = "overlay" }),
    source_has_added = 0,
    source_has_renamed = 0,
    invalid_set = "text",
    missing_set_value = json.null,
    invalid_rename = "text",
    missing_rename_value = json.null,
    invalid_drop = "text",
    missing_drop = json.null,
    invalid_pick = json.null,
    missing_pick = json.null,
    empty_pick = json.harray(),
    empty_merge = json.harray(),
  }), "copied harray transforms")
end)

test("runtime copied array selection ordering membership and uniqueness", function()
  local result = execute_uniform_binding_source([[
Top::
 /x/ -> Done {
   set(items, ["b", "a", "c", "a"])
   source = copy(items)
   return({
     "count" : count(items),
     "first" : first(items),
     "last" : last(items),
     "take_default" : take(items),
     "take_two" : take(items, 2),
     "take_last_two" : take_last(items, 2),
     "drop_front_default" : drop_front(items),
     "drop_back_two" : drop_back(items, 2),
     "slice_width" : slice(items, 1, 2),
     "slice_tail" : slice(items, 2),
     "slice_past_end" : slice(items, 99, 2),
     "sorted" : sorted(items),
     "reversed_literal" : [1, 2, 3].reversed(),
     "contains" : contains(items, "a"),
     "missing_contains" : items.contains("z"),
     "index" : index_of(items, "c"),
     "missing_index" : items.index_of("z"),
     "uniq" : uniq(items),
     "chain" : items.sorted().drop_front(2).first(),
     "invalid_count_default" : items.take("bad"),
     "invalid_count" : count(undef),
     "invalid_first" : first("text"),
     "invalid_sorted" : sorted("text"),
     "source" : source,
     "items" : items
   })
 }
Done::
 /x/
]])
  assert_json_equal(result, json.harray({
    count = 4,
    first = "b",
    last = "a",
    take_default = json.array({ "b" }),
    take_two = json.array({ "b", "a" }),
    take_last_two = json.array({ "c", "a" }),
    drop_front_default = json.array({ "a", "c", "a" }),
    drop_back_two = json.array({ "b", "a" }),
    slice_width = json.array({ "a", "c" }),
    slice_tail = json.array({ "c", "a" }),
    slice_past_end = json.array(),
    sorted = json.array({ "a", "a", "b", "c" }),
    reversed_literal = json.array({ 3, 2, 1 }),
    contains = 1,
    missing_contains = 0,
    index = 2,
    missing_index = json.null,
    uniq = json.array({ "b", "a", "c" }),
    chain = "b",
    invalid_count_default = json.array({ "b" }),
    invalid_count = 0,
    invalid_first = json.null,
    invalid_sorted = json.array(),
    source = json.array({ "b", "a", "c", "a" }),
    items = json.array({ "b", "a", "c", "a" }),
  }), "copied array selection")
end)

test("runtime copied array transforms joins split pipelines and rebinding", function()
  local result = execute_uniform_binding_source([[
Top::
 /x/ -> Done {
   set(source, [" A:A ", "", "c:d", "z:q", "AA"])
   snapshot = copy(source)
   pure_trim = trim_each(source)
   pure_split = split_each(source, ":")
   set(mutating, copy(source))
   trim_each(mutating)
   filter_nonempty(mutating)
   lowercase_each(mutating)
   split_each(mutating, ":")
   filter_match(mutating, /^[acd]/)
   uniq(mutating)
   uppercase_each(mutating)
   return({
     "source" : source,
     "snapshot" : snapshot,
     "pure_trim" : pure_trim,
     "pure_split" : pure_split,
     "mutating" : mutating,
     "direct_join" : join_values("|", ["a", 2, undef]),
     "receiver_join" : ["a", "b"].join_values("|"),
     "scalar_join" : join_values("-", "ab"),
     "missing_join" : join_values("|"),
     "null_join" : join_values("|", undef),
     "regex_split" : ["a, B", "c ,d"].split_each(/\s*,\s*/i),
     "regex_filter" : ["Alpha", "beta", "ALTO"].filter_match(/^a/i),
     "invalid_filter" : filter_match(["a"], "not-a-regex"),
     "invalid_transform" : trim_each("text"),
     "chain" : [" A ", "", "B"].trim_each().filter_nonempty().lowercase_each().join_values("|"),
     "terminal_join" : ["a"].join_values(",").uppercase()
   })
 }
Done::
 /x/
]])
  assert_json_equal(result, json.harray({
    source = json.array({ " A:A ", "", "c:d", "z:q", "AA" }),
    snapshot = json.array({ " A:A ", "", "c:d", "z:q", "AA" }),
    pure_trim = json.array({ "A:A", "", "c:d", "z:q", "AA" }),
    pure_split = json.array({ " A", "A ", "", "c", "d", "z", "q", "AA" }),
    mutating = json.array({ "A", "C", "D", "AA" }),
    direct_join = "a|2|",
    receiver_join = "a|b",
    scalar_join = "",
    missing_join = json.null,
    null_join = json.null,
    regex_split = json.array({ "a", "B", "c", "d" }),
    regex_filter = json.array({ "Alpha", "ALTO" }),
    invalid_filter = json.array(),
    invalid_transform = json.array(),
    chain = "a|b",
    terminal_join = json.null,
  }), "copied array transforms")
end)

test("runtime split tagged records preserves copied fields and pipelines", function()
  local result = execute_uniform_binding_source([[
Top::
 /x/ -> Done {
   set(source_calls, 0)
   set(field_calls, 0)
   set(field, ["x"])
   set(meta, { "k" : "v" })
   tagged = split_tagged_records(
     cat("a,,b", substr(set(source_calls, add(source_calls, 1)), 0, 0)),
     ",",
     "?item:",
     set(field_calls, add(field_calls, 1)),
     field,
     meta
   )
   field.push_back("y")
   meta["k"] = "changed"
   return({
     "tagged" : tagged,
     "regex" : split_tagged_records("a, b", /\s*,\s*/o, "?node:", "field"),
     "receiver_count" : "a,b".split_tagged_records(",", "?item:").count(),
     "missing_tag" : split_tagged_records("a,b", ","),
     "invalid_source" : split_tagged_records(["a"], ",", "?item:"),
     "source_calls" : source_calls,
     "field_calls" : field_calls,
     "field" : field,
     "meta" : meta
   })
 }
Done::
 /x/
]])
  assert_json_equal(result, json.harray({
    tagged = json.array({
      json.array({ "?item:", "a", 1, json.array({ "x" }), json.harray({ k = "v" }) }),
      json.array({ "?item:", "", 1, json.array({ "x" }), json.harray({ k = "v" }) }),
      json.array({ "?item:", "b", 1, json.array({ "x" }), json.harray({ k = "v" }) }),
    }),
    regex = json.array({
      json.array({ "?node:", "a", "field" }),
      json.array({ "?node:", "b", "field" }),
    }),
    receiver_count = 2,
    missing_tag = json.array(),
    invalid_source = json.array(),
    source_calls = 1,
    field_calls = 1,
    field = json.array({ "x", "y" }),
    meta = json.harray({ k = "changed" }),
  }), "split tagged records")
end)

test("uniform-binding dropped array transform rejects wrong kind", function()
  local ok, failure = pcall(function()
    execute_uniform_binding_source([[
Top::
 /x/ -> Done { items = "text"; split_each(items, ":"); return(items) }
Done::
 /x/
]])
  end)
  assert_equal(ok, false, "wrong-kind transform fails")
  assert_equal(linkedspec.is_runtime_interpreter_error(failure), true, "typed transform error")
  assert_equal(failure.code, "binding_kind_mismatch", "transform error code")
  assert_equal(failure.identifier, "items", "transform error identifier")
  assert_equal(failure.expected_kind, "array", "transform expected kind")
  assert_equal(failure.actual_kind, "scalar", "transform actual kind")
end)

test("uniform-binding wrong-kind mutation reports neutral fields", function()
  local ok, failure = pcall(function()
    execute_uniform_binding_source([[
Top::
 /x/ -> Done { items = "text"; push(items, "x"); return(items) }
Done::
 /x/
]])
  end)
  assert_equal(ok, false, "wrong-kind push fails")
  assert_equal(linkedspec.is_runtime_interpreter_error(failure), true, "typed runtime error")
  assert_equal(failure.code, "binding_kind_mismatch", "error code")
  assert_equal(failure.identifier, "items", "error identifier")
  assert_equal(failure.expected_kind, "array", "expected kind")
  assert_equal(failure.actual_kind, "scalar", "actual kind")
end)

test("uniform-binding set returns the assigned value for receiver chaining", function()
  local result = execute_uniform_binding_source([[
Top::
 /x/ -> Done {
   first = set(items, ["b", "a"]).sorted().first()
   return([first, items])
 }
Done::
 /x/
]])
  assert_json_equal(result, json.array({ "a", json.array({ "b", "a" }) }), "set chain")
end)

test("generated Unicode 17 casing matches all neutral fixtures and runtime paths", function()
  local handle = assert(io.open("capability_conformance/unicode_case_contract.json", "rb"))
  local contract = json.decode(assert(handle:read("*a")))
  assert(handle:close())
  local unicode_case = require("linkedspec.unicode_case_mapping")
  assert_equal(unicode_case.contract_id, contract.contract_id, "Unicode contract id")
  assert_equal(unicode_case.unicode_version, contract.unicode_version, "Unicode version")
  assert_equal(unicode_case.data_sha256, contract.data_sha256, "Unicode data digest")
  for _, fixture in ipairs(contract.fixtures) do
    assert_equal(unicode_case.lowercase(fixture.input), fixture.lower, fixture.id .. " direct lowercase")
    assert_equal(unicode_case.uppercase(fixture.input), fixture.upper, fixture.id .. " direct uppercase")
    local literal = json.encode(fixture.input)
    local source = "Top::\n /x/ -> Done { return([lowercase(" .. literal .. "), " .. literal ..
      ".lowercase(), uppercase(" .. literal .. "), " .. literal .. ".uppercase(), [" .. literal ..
      "].lowercase_each(), [" .. literal .. "].uppercase_each()]) }\n\nDone::\n /x/\n"
    local result = linkedspec.runtime_parse(
      linkedspec.runtime_engine(linkedspec.compile_spec(linkedspec.parse_spec(source))),
      "xx"
    ).value
    assert_equal(result[1], fixture.lower, fixture.id .. " helper lowercase")
    assert_equal(result[2], fixture.lower, fixture.id .. " receiver lowercase")
    assert_equal(result[3], fixture.upper, fixture.id .. " helper uppercase")
    assert_equal(result[4], fixture.upper, fixture.id .. " receiver uppercase")
    assert_equal(result[5][1], fixture.lower, fixture.id .. " array lowercase")
    assert_equal(result[6][1], fixture.upper, fixture.id .. " array uppercase")
  end
end)

io.stdout:write("1..", total, "\n")
if failed > 0 then
  os.exit(1)
end
