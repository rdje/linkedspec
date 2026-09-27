local linkedspec = require("linkedspec")
local json = linkedspec.json
local A, D = json.array, json.harray
local fixture = "tests/language-readiness/lossless-child/"
local segments_fixture = "tests/language-readiness/lossless-segments/"
local C = dofile(fixture .. "lua_checks.lua")
local M = {}

local function replace_once(source, needle, replacement)
  local first, last = assert(source:find(needle, 1, true))
  assert(not source:find(needle, last + 1, true), "exactly one mutation target")
  return source:sub(1, first - 1) .. replacement .. source:sub(last + 1)
end

local function segment_variants(source)
  local prefix = "  if(num_ne(cursor_pos(), 0));\n" ..
    "   push(parts, hash(\"kind\", \"entry_prefix\", \"span\", [0, cursor_pos()], \"text\", input_slice(0, cursor_pos())))\n" ..
    "  endif();\n"
  local tail = " LX {\n  push(parts, hash(\"kind\", gap_kind(), \"span\", gap_span(), \"text\", gap_text()))\n"
  return {
    { id = "selection", source = replace_once(source, "[0-9]", "[1-9]") },
    { id = "tail", source = replace_once(source, tail, " LX {\n") },
    { id = "item_span", source = replace_once(source,
      "[entry_start_pos(), entry_end_pos()]", "[entry_end_pos(), entry_end_pos()]") },
    { id = "entry_prefix", source = replace_once(source, prefix, "") },
  }
end

local function child_variants(parent, child)
  return {
    { id = "leading_zero", is_parent = false,
      source = replace_once(child, "(0|[1-9][0-9]*)", "([0-9]+)") },
    { id = "wrong_span", is_parent = false,
      source = replace_once(child, '"start", entry_start_pos()', '"start", num_add(entry_start_pos(), 1)') },
    { id = "whole_item", is_parent = true,
      source = replace_once(parent, "parse_job(entry_group(0)", "parse_job(entry_text()") },
  }
end

local function compile(source)
  local parsed = linkedspec.parse_spec_with_staged_user_function_definitions(source)
  linkedspec.validate_spec(parsed)
  return parsed, linkedspec.compile_spec(parsed)
end

local function carriers(source, labels, check)
  local parsed = compile(source)
  local restored = linkedspec.spec_ast.from_json("SpecFile",
    json.decode(json.encode(linkedspec.spec_ast.to_json(parsed))))
  linkedspec.validate_spec(restored)
  local routes = {}
  for _, spec in ipairs({ parsed, restored }) do
    local compiled = linkedspec.compile_spec(spec)
    local plan = linkedspec.build_generated_rule_plan(compiled)
    linkedspec.validate_generated_rule_plan_v2(compiled, plan, "lossless/readiness")
    local observed = A()
    for index, row in ipairs(plan) do observed[index] = row.label end
    check(C.exact_json(observed, labels), "lossless plan labels")
    routes[#routes + 1] = function(seed)
      local engine = linkedspec.runtime_engine(compiled, { staged_ast_enrichment_seed = seed })
      return function(input) return linkedspec.runtime_parse(engine, input).value end
    end
    -- Public v2 constructs an engine on every invocation.
    routes[#routes + 1] = function(seed)
      return function(input)
        return linkedspec.execute_generated_parser_v2(compiled, plan, input,
          "lossless/readiness", { staged_ast_enrichment_seed = seed })
      end
    end
  end
  return routes
end

function M.verify(h)
  local segments = h.read_file(segments_fixture .. "grammar.spec")
  local parent, child = h.read_file(fixture .. "parent.spec"), h.read_file(fixture .. "child.spec")
  local cases = json.decode(h.read_file(segments_fixture .. "cases.json"))
  local strict = json.decode(h.read_file(fixture .. "cases.json"))
  local segment_changes, child_changes = segment_variants(segments), child_variants(parent, child)
  local segment_labels, child_labels = A({ "Item", "Segments" }), A({ "Number", "Digits" })
  local segment_routes = carriers(segments, segment_labels, h.check)
  local parents, children = carriers(parent, segment_labels, h.check), carriers(child, child_labels, h.check)
  local records
  for route = 1, 4 do
    h.check(C.segmentation(cases, segment_routes[route](nil)), "lossless original " .. route)
    local observed = C.children(cases, strict, parents[route], children[route](nil), C.digest(child))
    h.check(#observed == 26, "enriched original inventory " .. route)
    if records then h.check(C.exact_json(observed, records), "complete lossless child record equality")
    else records = observed end
  end
  for _, row in ipairs(segment_changes) do
    for _, builder in ipairs(carriers(row.source, segment_labels, h.check)) do
      h.check(C.segment_mutation(row.id, cases, builder(nil)), "segment mutant " .. row.id)
    end
  end
  for _, row in ipairs(child_changes) do
    local routes = carriers(row.source, row.is_parent and segment_labels or child_labels, h.check)
    for route = 1, 4 do
      local parent_builder = row.is_parent and routes[route] or parents[route]
      local child_parse = (row.is_parent and children[route] or routes[route])(nil)
      h.check(C.child_mutation(row.id, parent_builder, child_parse,
        C.digest(row.is_parent and child or row.source)), "child mutant " .. row.id)
    end
  end

  local owned_root
  h.with_temp_directory(function(root)
    owned_root = root
    local modules = { { id = "segments", source = segments },
      { id = "parent", source = parent }, { id = "child", source = child } }
    local config = D({ ids = A(), child_digest = C.digest(child), segment_mutations = A(), child_mutations = A() })
    for _, row in ipairs(segment_changes) do
      modules[#modules + 1] = { id = "segment_" .. row.id, source = row.source }
      config.segment_mutations[#config.segment_mutations + 1] = row.id
    end
    for _, row in ipairs(child_changes) do
      modules[#modules + 1] = { id = row.id, source = row.source }
      config.child_mutations[#config.child_mutations + 1] = D({ id = row.id, is_parent = row.is_parent,
        digest = C.digest(row.is_parent and child or row.source) })
    end
    for _, row in ipairs(modules) do
      config.ids[#config.ids + 1] = row.id
      local _, compiled = compile(row.source)
      h.write_file(root .. "/" .. row.id .. ".lua", linkedspec.emit_lua_source_v2(compiled, "lossless/" .. row.id))
    end
    h.write_file(root .. "/config.json", json.encode(config))
    h.write_file(root .. "/cases.json", h.read_file(segments_fixture .. "cases.json"))
    h.write_file(root .. "/strict.json", h.read_file(fixture .. "cases.json"))
    h.write_file(root .. "/checks.lua", h.read_file(fixture .. "lua_checks.lua"))
    h.write_file(root .. "/nested_checks.lua", h.read_file("tests/language-readiness/nested-tree/lua_checks.lua"))
    h.write_file(root .. "/runner.lua", [[
local linkedspec = require("linkedspec")
local json = linkedspec.json
local root = assert(arg[1])
local C = assert(loadfile(root .. "/checks.lua"))(root .. "/nested_checks.lua")
local function read_json(name)
  local file = assert(io.open(root .. "/" .. name .. ".json", "rb"))
  local value = json.decode(assert(file:read("*a")))
  assert(file:close())
  return value
end
local config, cases, strict = read_json("config"), read_json("cases"), read_json("strict")
local builders, count = {}, 0
for _, id in ipairs(config.ids) do
  local parser = assert(loadfile(root .. "/" .. id .. ".lua"))()
  C.exact_json(linkedspec.generated_source_metadata_to_json(parser.metadata()), json.harray({
    contract_id = "linkedspec-generated-source-v2", format_version = 2, source_identity = "lossless/" .. id,
  }), id .. " metadata")
  parser.validate_plan(parser.plan())
  builders[id] = function(seed)
    return function(input) return parser.execute(input, { staged_ast_enrichment_seed = seed }) end
  end
  count = count + 1
end
assert(C.segmentation(cases, builders.segments(nil)))
local records = C.children(cases, strict, builders.parent, builders.child(nil), config.child_digest)
assert(#records == 26, "complete original enriched sequence")
for _, id in ipairs(config.segment_mutations) do
  assert(C.segment_mutation(id, cases, builders["segment_" .. id](nil)))
end
for _, row in ipairs(config.child_mutations) do
  assert(C.child_mutation(row.id, builders[row.is_parent and row.id or "parent"],
    builders[row.is_parent and "child" or row.id](nil), row.digest))
end
io.write(json.encode(json.harray({ modules = count, segmentation_cases = 13, child_accept = 4,
  child_reject = 15, mutations = 7, alias_control = true })), "\n")
]])
    local runtime = assert(os.getenv("LINKEDSPEC_LUA_TEST_RUNTIME"), "selected ABI required")
    local quote = h.shell_quote
    local stdout_path, stderr_path = root .. "/stdout.json", root .. "/stderr.txt"
    local succeeded = h.command_succeeded(table.concat({
      "env LUA_PATH=" .. quote(assert(os.getenv("LUA_PATH"))),
      "LUA_CPATH=" .. quote(assert(os.getenv("LUA_CPATH"))), quote(runtime),
      quote(root .. "/runner.lua"), quote(root), ">" .. quote(stdout_path), "2>" .. quote(stderr_path),
    }, " "))
    local stdout, stderr = h.read_file(stdout_path), h.read_file(stderr_path)
    assert(succeeded, "lossless child host failed:\n" .. stdout .. stderr)
    h.check_equal(stderr, "", "lossless fresh host stderr")
    h.check_same_json(json.decode(stdout), D({ modules = 10, segmentation_cases = 13,
      child_accept = 4, child_reject = 15, mutations = 7, alias_control = true }), "lossless child completion")
  end)
  h.check(h.command_succeeded("test ! -e " .. h.shell_quote(owned_root)), "lossless child cleanup")
end

return M
