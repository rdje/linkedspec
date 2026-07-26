-- FUTURE-PARITY-BACKLOG.10.7.2.1 — strict semantic source foundation.

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

local function read_file(path)
  local handle = assert(io.open(path, "rb"))
  local value = assert(handle:read("*a"))
  assert(handle:close())
  return value
end

local forbidden_dependencies = {
  "linkedspec.spec_parser",
  "linkedspec.spec_validator",
  "linkedspec.compiled_spec",
  "linkedspec.spec_loader",
  "linkedspec.source_emitter",
  "linkedspec.interpreter",
  "linkedspec.trace",
}
for _, name in ipairs(forbidden_dependencies) do
  check_equal(package.loaded[name], nil, name .. " absent before source module load")
end

local semantic_index = require("linkedspec.semantic_index")
local json = require("linkedspec.json")

for _, name in ipairs(forbidden_dependencies) do
  check_equal(package.loaded[name], nil, name .. " absent after source module load")
end

local module_source = read_file("lua/src/linkedspec/semantic_index.lua")
local required = {}
for name in module_source:gmatch('require%(%"([^%"]+)%"%)') do required[#required + 1] = name end
table.sort(required)
check_equal(#required, 2, "source module dependency count")
check_equal(required[1], "linkedspec.json", "source module JSON dependency")
check_equal(required[2], "linkedspec.unicode_rule_label", "source module Unicode dependency")
for _, token in ipairs({
  "io.",
  "os.",
  "dofile",
  "loadfile",
  "package.loadlib",
  "bit32",
  "require(\"bit\")",
}) do
  check_equal(module_source:find(token, 1, true), nil, "source module forbids " .. token)
end

local function check_same_json(actual, expected, label)
  check_equal(json.encode(actual), json.encode(expected), label)
end

local function capture_error(operation, expected_stage, expected_code, label)
  local ok, value = pcall(operation)
  check_equal(ok, false, label .. " rejected")
  if ok then return nil end
  check_equal(value.stage, expected_stage, label .. " stage")
  check_equal(value.code, expected_code, label .. " code")
  check(type(value.message) == "string" and value.message ~= "", label .. " message")
  check_equal(getmetatable(value), "protected", label .. " protected metatable")
  return value
end

local function options(logical_name, source_detail_ceiling, entry_rule)
  return {
    logical_name = logical_name,
    source_detail_ceiling = source_detail_ceiling,
    entry_rule = entry_rule,
  }
end

local empty = semantic_index.create("", options("empty.spec", "text"))
local abc = semantic_index.create("abc", options("abc.spec", "text"))
check_equal(
  empty:source_identity().content_digest,
  "sha256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855",
  "empty SHA-256 vector"
)
check_equal(
  abc:source_identity().content_digest,
  "sha256:ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",
  "abc SHA-256 vector"
)
for _, vector in ipairs({
  { 55, "9f4390f8d30c2dd92ec9f095b65e2b9ae9b0a925a5258e241c9f1e910f734318" },
  { 56, "b35439a4ac6f0948b6d6f9e3c6af0f5f590ce20f1bde7090ef7970686ec6738a" },
  { 64, "ffe054fe7ae0cb6dc65c3af9b61d5209f439851db43d0ba5997337df154668eb" },
  { 1000, "41edece42d63e8d9bf515a9ba6932e1c20cbc9f5a5d134645adb5db1b9737ea3" },
}) do
  local source = string.rep("a", vector[1])
  local index = semantic_index.create(source, options("padding.spec", "text"))
  check_equal(index:source_identity().content_digest, "sha256:" .. vector[2],
    "SHA-256 padding vector " .. vector[1])
end

local graph = read_file("capability_conformance/semantic_introspection/graph.spec")
local graph_options = options("graph.spec", "text", "Top")
local graph_index = semantic_index.create(graph, graph_options)
graph_options.logical_name = "/tmp/mutated.spec"
graph_options.source_detail_ceiling = "none"
graph_options.entry_rule = "Missing"
local graph_identity = graph_index:source_identity()
check_equal(graph_identity.source_id, "source:0", "graph source id")
check_equal(graph_identity.logical_name, "graph.spec", "graph copied logical name")
check_equal(graph_identity.byte_length, 128, "graph byte length")
check_equal(graph_identity.scalar_length, 128, "graph scalar length")
check_equal(
  graph_identity.content_digest,
  "sha256:28505ba8524900f55e11452988acc6b7d35dccbccc1c0cb6194c8cda80a0cbcf",
  "graph SHA-256 vector"
)
check_equal(graph_index:source_excerpt_for_bytes(0, 8), "Top::AND", "graph prefix excerpt")

local graph_json = graph_identity:to_json()
check_same_json(graph_json, json.harray({
  source_id = "source:0",
  logical_name = "graph.spec",
  byte_length = 128,
  scalar_length = 128,
  content_digest = "sha256:28505ba8524900f55e11452988acc6b7d35dccbccc1c0cb6194c8cda80a0cbcf",
}), "graph identity JSON")
graph_json.logical_name = "/private/mutated.spec"
check_equal(graph_index:source_identity().logical_name, "graph.spec", "identity JSON detached")

local starts = {}
local cursor = 0
for occurrence = 1, 4 do
  local span = graph_index:locate_exact("/a/", cursor)
  check(span ~= nil, "graph occurrence " .. occurrence .. " exists")
  starts[occurrence] = span.start_byte
  cursor = span.end_byte
end
check_equal(starts[1], 10, "graph occurrence 1")
check_equal(starts[2], 47, "graph occurrence 2")
check_equal(starts[3], 119, "graph occurrence 3")
check_equal(starts[4], 124, "graph occurrence 4")
check_equal(graph_index:locate_exact("/a/", cursor), nil, "graph occurrence exhaustion")

local privacy = read_file("capability_conformance/semantic_introspection/privacy.spec")
local privacy_index = semantic_index.create(privacy, options("privacy.spec", "text", "Töp"))
local privacy_identity = privacy_index:source_identity()
check_equal(privacy_identity.byte_length, 13, "privacy byte length")
check_equal(privacy_identity.scalar_length, 11, "privacy scalar length")
check_equal(
  privacy_identity.content_digest,
  "sha256:8fe5f40cc6e9f5ce438a605f4965e04a78c34f392e13761e66d042730469f8de",
  "privacy SHA-256"
)
local header_span = privacy_index:source_span_for_bytes(0, 6)
check_same_json(header_span:to_json(), json.harray({
  start_byte = 0,
  end_byte = 6,
  start_line = 1,
  start_column = 1,
  end_line = 1,
  end_column = 6,
}), "privacy header span")
check_same_json(
  privacy_index:source_span_for_scalars(0, 5):to_json(),
  header_span:to_json(),
  "privacy byte/scalar convergence"
)
check_equal(privacy_index:source_excerpt_for_bytes(0, 6), "Töp::", "privacy header excerpt")
check_equal(privacy_index:source_excerpt_for_bytes(8, 12), "/é/", "privacy regex excerpt")

local unicode_source = "A😀\r\né́Z"
local unicode_index = semantic_index.create(unicode_source, options("unicode-source.spec", "text", "Töp"))
local unicode_identity = unicode_index:source_identity()
check_equal(unicode_identity.byte_length, 12, "Unicode byte length")
check_equal(unicode_identity.scalar_length, 7, "Unicode scalar length")
check_equal(
  unicode_identity.content_digest,
  "sha256:57e1b2340598ecf42cdcbb3f811e43de57603f4b5ed3d2baa8850007436a7aba",
  "Unicode SHA-256"
)
check_same_json(unicode_index:source_span_for_bytes(1, 5):to_json(), json.harray({
  start_byte = 1,
  end_byte = 5,
  start_line = 1,
  start_column = 2,
  end_line = 1,
  end_column = 3,
}), "emoji byte span")
check_same_json(
  unicode_index:source_span_for_scalars(1, 2):to_json(),
  unicode_index:source_span_for_bytes(1, 5):to_json(),
  "emoji scalar span"
)
check_same_json(unicode_index:source_span_for_bytes(5, 7):to_json(), json.harray({
  start_byte = 5,
  end_byte = 7,
  start_line = 1,
  start_column = 3,
  end_line = 2,
  end_column = 1,
}), "CR/LF coordinate policy")
check_same_json(unicode_index:source_span_for_bytes(7, 11):to_json(), json.harray({
  start_byte = 7,
  end_byte = 11,
  start_line = 2,
  start_column = 1,
  end_line = 2,
  end_column = 3,
}), "combining sequence coordinate policy")
check_equal(unicode_index:source_excerpt_for_bytes(7, 11), "é́", "combining sequence excerpt")
check_same_json(unicode_index:source_span_for_bytes(12, 12):to_json(), json.harray({
  start_byte = 12,
  end_byte = 12,
  start_line = 2,
  start_column = 4,
  end_line = 2,
  end_column = 4,
}), "end boundary span")
check_equal(unicode_index:source_excerpt_for_bytes(12, 12), "", "empty end excerpt")

local supplementary = semantic_index.create("𐐀Rule\r\nX", options("supplementary.spec", "span"))
check_same_json(supplementary:source_span_for_scalars(0, 1):to_json(), json.harray({
  start_byte = 0,
  end_byte = 4,
  start_line = 1,
  start_column = 1,
  end_line = 1,
  end_column = 2,
}), "supplementary scalar span")
check_same_json(supplementary:source_span_for_bytes(10, 11):to_json(), json.harray({
  start_byte = 10,
  end_byte = 11,
  start_line = 2,
  start_column = 1,
  end_line = 2,
  end_column = 2,
}), "supplementary newline span")

local duplicates = semantic_index.create("α α α", options("duplicates.spec", "span"))
check_equal(duplicates:locate_exact("α").start_byte, 0, "duplicate first occurrence")
check_equal(duplicates:locate_exact("α", 2).start_byte, 3, "duplicate second occurrence")
check_equal(duplicates:locate_exact("α", 5).start_byte, 6, "duplicate third occurrence")
check_equal(duplicates:locate_exact("missing"), nil, "duplicate missing occurrence")

local none_index = semantic_index.create("not a LinkedSpec grammar", options("none.spec", "none"))
local none_error = capture_error(function() return none_index:source_identity() end,
  "apply_source_ceiling", "semantic_source_detail_forbidden", "none identity ceiling")
check_same_json(none_error.fields, json.harray({ ceiling = "none", required = "identity" }),
  "none identity fields")

local identity_index = semantic_index.create("still not a grammar", options("identity.spec", "identity"))
check_equal(identity_index:source_identity().content_digest, nil, "identity ceiling omits digest")
check_equal(identity_index:source_identity():to_json().content_digest, json.null,
  "identity JSON uses null digest")
capture_error(function() return identity_index:source_span_for_bytes(0, 0) end,
  "apply_source_ceiling", "semantic_source_detail_forbidden", "identity span ceiling")

local span_index = semantic_index.create("span only", options("span.spec", "span"))
check_equal(span_index:source_identity().content_digest, nil, "span ceiling omits digest")
check_equal(span_index:source_span_for_scalars(0, 4).end_column, 5, "span ceiling maps")
capture_error(function() return span_index:source_excerpt_for_bytes(0, 4) end,
  "apply_source_ceiling", "semantic_source_detail_forbidden", "span text ceiling")

local range_cases = {
  { "negative byte", function() return unicode_index:source_span_for_bytes(-1, 0) end },
  { "byte overflow", function() return unicode_index:source_span_for_bytes(0, 13) end },
  { "reversed byte", function() return unicode_index:source_span_for_bytes(5, 4) end },
  { "negative scalar", function() return unicode_index:source_span_for_scalars(-1, 0) end },
  { "scalar overflow", function() return unicode_index:source_span_for_scalars(0, 8) end },
  { "reversed scalar", function() return unicode_index:source_span_for_scalars(2, 1) end },
  { "Boolean-like coordinate", function() return unicode_index:source_span_for_bytes(true, 1) end },
  { "fractional coordinate", function() return unicode_index:source_span_for_bytes(0.5, 1) end },
  { "NaN coordinate", function() return unicode_index:source_span_for_bytes(0 / 0, 1) end },
  { "infinite coordinate", function() return unicode_index:source_span_for_bytes(math.huge, math.huge) end },
}
for _, case in ipairs(range_cases) do
  capture_error(case[2], "map_source", "semantic_source_range_invalid", case[1])
end

local start_boundary = capture_error(function()
  return unicode_index:source_span_for_bytes(2, 5)
end, "map_source", "semantic_source_boundary_invalid", "mid-scalar start")
check_same_json(start_boundary.fields, json.harray({ start_byte = 2 }), "mid-scalar start fields")
local end_boundary = capture_error(function()
  return unicode_index:source_span_for_bytes(1, 4)
end, "map_source", "semantic_source_boundary_invalid", "mid-scalar end")
check_same_json(end_boundary.fields, json.harray({ end_byte = 4 }), "mid-scalar end fields")
capture_error(function() return unicode_index:locate_exact("A", 2) end,
  "map_source", "semantic_source_boundary_invalid", "lookup mid-scalar boundary")

capture_error(function() return unicode_index:locate_exact(42) end,
  "map_source", "semantic_source_needle_invalid", "lookup needle type")
capture_error(function() return unicode_index:locate_exact("") end,
  "map_source", "semantic_source_needle_invalid", "empty lookup needle")
capture_error(function() return unicode_index:locate_exact(string.char(0xFF)) end,
  "map_source", "semantic_source_needle_invalid", "malformed lookup needle")

local malformed_sources = {
  { "continuation", string.char(0x80), 0 },
  { "truncated two-byte", string.char(0xC2), 0 },
  { "invalid continuation", string.char(0xC3, 0x28), 0 },
  { "truncated three-byte", string.char(0xE2, 0x82), 0 },
  { "surrogate", string.char(0xED, 0xA0, 0x80), 0 },
  { "above maximum", string.char(0xF4, 0x90, 0x80, 0x80), 0 },
  { "late malformed", "valid" .. string.char(0xFF), 5 },
}
for _, case in ipairs(malformed_sources) do
  local value = capture_error(function()
    return semantic_index.create(case[2], options("invalid.spec", "text"))
  end, "decode_source", "semantic_index_invalid_utf8", case[1] .. " source")
  check_equal(value.fields.offset, case[3], case[1] .. " offset")
end

for _, case in ipairs({
  { "nil source", nil },
  { "table source", {} },
  { "number source", 42 },
  { "Boolean source", false },
}) do
  capture_error(function()
    return semantic_index.create(case[2], options("invalid.spec", "text"))
  end, "validate_source", "semantic_index_invalid_source", case[1])
end

local invalid_options = {
  { "nil options", nil, "options" },
  { "number options", 42, "options" },
  { "metatable options", setmetatable({}, {}), "options" },
  { "missing logical name", { source_detail_ceiling = "text" }, "logical_name" },
  { "logical name type", options(42, "text"), "logical_name" },
  { "empty logical name", options("", "text"), "logical_name" },
  { "line logical name", options("line\nname", "text"), "logical_name" },
  { "C1 logical name", options("name\194\133", "text"), "logical_name" },
  { "malformed logical name", options(string.char(0xFF), "text"), "logical_name" },
  { "missing ceiling", { logical_name = "source.spec" }, "source_detail_ceiling" },
  { "ceiling type", options("source.spec", 4), "source_detail_ceiling" },
  { "ceiling spelling", options("source.spec", "TEXT"), "source_detail_ceiling" },
  { "entry type", options("source.spec", "text", 42), "entry_rule" },
  { "entry empty", options("source.spec", "text", ""), "entry_rule" },
  { "entry punctuation", options("source.spec", "text", "Bad-Rule"), "entry_rule" },
  { "entry malformed", options("source.spec", "text", string.char(0xFF)), "entry_rule" },
  { "unknown option", { logical_name = "source.spec", source_detail_ceiling = "text", path = "/tmp/x" }, "path" },
  { "non-string option", { [1] = "bad", logical_name = "source.spec", source_detail_ceiling = "text" }, "options" },
}
for _, case in ipairs(invalid_options) do
  local value = capture_error(function()
    return semantic_index.create("not language syntax", case[2])
  end, "validate_options", "semantic_index_invalid_option", case[1])
  check_equal(value.fields.option, case[3], case[1] .. " option field")
end

local immutable_values = {
  { "index", graph_index },
  { "identity", graph_identity },
  { "span", header_span },
  { "error", start_boundary },
}
for _, case in ipairs(immutable_values) do
  check_equal(getmetatable(case[2]), "protected", case[1] .. " protected metatable")
  check_equal(next(case[2]), nil, case[1] .. " raw state empty")
  local pair_count = 0
  for _ in pairs(case[2]) do pair_count = pair_count + 1 end
  check_equal(pair_count, 0, case[1] .. " iteration empty")
  local write_ok = pcall(function() case[2].leak = "/tmp/private.spec" end)
  check_equal(write_ok, false, case[1] .. " write rejected")
  local metatable_ok = pcall(function() setmetatable(case[2], {}) end)
  check_equal(metatable_ok, false, case[1] .. " metatable replacement rejected")
end

local detached_fields = start_boundary.fields
detached_fields.start_byte = 999
check_equal(start_boundary.fields.start_byte, 2, "error fields detached")
local detached_error_json = start_boundary:to_json()
detached_error_json.fields.start_byte = 777
check_equal(start_boundary.fields.start_byte, 2, "error JSON detached")
check_equal(tostring(start_boundary),
  "semantic_source_boundary_invalid at map_source: Source byte range starts inside a UTF-8 scalar",
  "error string stable")

local index_string = tostring(graph_index)
check_equal(index_string,
  "SemanticIndex(source_id=\"source:0\", source_detail_ceiling=\"text\")",
  "index string stable")
for _, forbidden in ipairs({ "graph.spec", "Top::AND", "/tmp", "table:", "userdata:" }) do
  check_equal(index_string:find(forbidden, 1, true), nil, "index string redacts " .. forbidden)
end
check_equal(tostring(graph_identity), "SemanticSourceIdentity", "identity string stable")
check_equal(tostring(header_span), "SemanticSourceSpan", "span string stable")

local original_open = io.open
local original_getenv = os.getenv
local original_time = os.time
local original_clock = os.clock
io.open = function() error("source constructor attempted file access", 0) end
os.getenv = function() error("source constructor attempted environment access", 0) end
os.time = function() error("source constructor attempted clock access", 0) end
os.clock = function() error("source constructor attempted clock access", 0) end
local isolated_ok, isolated_index = pcall(function()
  return semantic_index.create(
    "Top::\n { fail(\"target must not run\") }\n",
    options("isolated.spec", "text", "Top")
  )
end)
io.open = original_open
os.getenv = original_getenv
os.time = original_time
os.clock = original_clock
check_equal(isolated_ok, true, "constructor has no path/environment/clock/target execution")
if isolated_ok then
  check_equal(isolated_index:source_identity().logical_name, "isolated.spec", "isolated identity")
end

local linkedspec = require("linkedspec")
check_equal(linkedspec.semantic_index, semantic_index.create, "root semantic constructor export")
local public_index = linkedspec.semantic_index("not language syntax", options("public.spec", "identity", "Töp"))
check_equal(public_index:source_identity().logical_name, "public.spec", "root constructor behavior")

if #failures > 0 then error(table.concat(failures, "\n"), 0) end
io.stdout:write("Lua semantic-index source foundation: ", assertions, " assertions passed\n")
