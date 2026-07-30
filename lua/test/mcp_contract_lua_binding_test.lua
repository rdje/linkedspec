-- FUTURE-PARITY-BACKLOG.10.9.6.1 — generated Lua MCP binding/runtime proof.

local binding = require("linkedspec.mcp_contract")
local json = require("linkedspec.json")
local runtime = require("linkedspec.mcp_contract_runtime")
local sha256 = require("linkedspec.sha256")

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

local function read_file(path)
  local handle = assert(io.open(path, "rb"))
  local value = assert(handle:read("*a"))
  assert(handle:close())
  return value
end

local contract = json.decode(read_file(
  "capability_conformance/mcp_semantic_transport_contract.json"
))
local corpus = json.decode(read_file(
  "capability_conformance/mcp_semantic_transport/corpus.json"
))
local validator = json.decode(read_file(
  "capability_conformance/mcp_semantic_transport/validator_cases.json"
))
local frame_lines = {}
for line in read_file(
    "capability_conformance/mcp_semantic_transport/canonical_frames.jsonl"
  ):gmatch("[^\n]+") do
  frame_lines[#frame_lines + 1] = line
end
local frame_by_id = {}
for index = 1, #corpus.canonical_order do
  frame_by_id[corpus.canonical_order[index]] = json.decode(frame_lines[index])
end

check_equal(binding.binding_format, 1, "generated binding format")
check_equal(#binding.bundle_json, 82543, "generated canonical bundle byte count")
check_equal(sha256.hex(binding.bundle_json), binding.bundle_sha256,
  "generated canonical bundle digest")
check(binding.bundle_sha256:match("^[0-9a-f]+$") ~= nil and #binding.bundle_sha256 == 64,
  "generated bundle SHA-256 syntax")
check_equal(runtime.protocol_version(), "2026-07-28", "frozen protocol version")

local source_digests = runtime.source_sha256()
for name, path in next, contract.artifacts do
  check_equal(sha256.hex(read_file(path)), source_digests[name],
    name .. " source digest is embedded exactly")
end

check_equal(#frame_lines, 35, "neutral canonical frame count")
for index = 1, #corpus.canonical_order do
  local id = corpus.canonical_order[index]
  check_same_json(runtime.frame(id), frame_by_id[id], id .. " exact canonical identity")
end
check_equal(runtime.frame("absent"), nil, "unknown frame is absent")
check_equal(runtime.payload("absent"), nil, "unknown payload is absent")

for index = 1, #validator.frame_schema.accepted do
  local id = validator.frame_schema.accepted[index]
  check(runtime.validate_frame(frame_by_id[id]), id .. " accepted by frozen schema")
end
for index = 1, #validator.frame_schema.rejected do
  local id = validator.frame_schema.rejected[index].id
  check(not runtime.validate_frame(frame_by_id[id]), id .. " rejected by frozen schema")
end

local request = runtime.frame("discover_request")
request.extra = true
check(not runtime.validate_named("discoverRequest", request),
  "additional envelope field rejected")
request = runtime.frame("discover_request")
request.id = true
check(not runtime.validate_named("discoverRequest", request), "boolean request id rejected")
request.id = string.rep("é", 65)
check(not runtime.validate_named("discoverRequest", request), "request-id UTF-8 byte ceiling")
check(runtime.validate_named("handle", string.rep("A", 43)), "handle pattern accepted")
check(not runtime.validate_named("handle", string.rep("A", 42)), "short handle rejected")
check(not runtime.validate_named("unknownDefinition", json.null), "unknown definition rejected")

local first = runtime.frame("discover_response_lua")
local before = runtime.canonical_json(first)
first.result.supportedVersions[1] = "host-mutated"
check_equal(runtime.canonical_json(runtime.frame("discover_response_lua")), before,
  "frame mutation cannot alter retained generated data")
local contract_copy = runtime.contract()
contract_copy.protocol_version = "host-mutated"
check_equal(runtime.protocol_version(), "2026-07-28",
  "contract mutation cannot alter retained protocol state")
local payload = runtime.payload("capabilities_default")
local response = runtime.tool_success_response(101, payload)
payload.records[1].name = "host-mutated"
check(response.result.structuredContent.records[1].name ~= "host-mutated",
  "tool result clones the native payload")
check_equal(response.result.content[1].text,
  runtime.canonical_json(response.result.structuredContent),
  "tool text is canonical structured content")
check_equal(response.result._meta["io.modelcontextprotocol/serverInfo"].name,
  "linkedspec-semantic-lua", "tool result carries Lua identity")
check_equal(runtime.tools_list_response("tools-1").result._meta[
  "io.modelcontextprotocol/serverInfo"].name, "linkedspec-semantic-lua",
  "tools list carries Lua identity")

local nested = json.harray({
  z = 1,
  a = json.harray({
    ["β"] = "é",
    a = json.array({ json.harray({ z = false, a = true }) }),
  }),
})
check_equal(runtime.canonical_json(nested),
  '{"a":{"a":[{"a":true,"z":false}],"β":"é"},"z":1}',
  "canonical JSON sorts recursively without normalizing text")
check(not pcall(runtime.canonical_json, json.harray({ bad = 0 / 0 })),
  "canonical JSON rejects non-finite values")

local runtime_source = read_file("lua/src/linkedspec/mcp_contract_runtime.lua")
for _, token in ipairs({
  "capability_conformance", "mcp_semantic_transport/", "io.open", "io.popen", "os.execute",
  "dofile", "loadfile", "package.loadlib", "parse_spec", "compile_spec",
}) do
  check_equal(runtime_source:find(token, 1, true), nil,
    "frozen runtime forbids " .. token)
end
local generated_source = read_file("lua/src/linkedspec/mcp_contract.lua")
check(generated_source:find("bundle_json = [[{", 1, true) ~= nil,
  "generated binding uses an immediate raw long-bracket payload")
local generator_source = read_file("tools/generate_lua_mcp_contract.py")
check_equal(generator_source:find("import base64", 1, true), nil,
  "Lua generator does not encode the bundle as Base64")

if #failures > 0 then
  io.stderr:write("Lua MCP binding/runtime failures:\n")
  for index = 1, #failures do io.stderr:write(" - " .. failures[index] .. "\n") end
  os.exit(1)
end

io.write("[lua-mcp-binding] PASS: " .. assertions ..
  " generated, digest, schema, clone, identity, and authority assertions\n")
