-- Generated LinkedSpec parser module.
-- Contract id: linkedspec-generated-source-v2.
-- Source format: linkedspec_lua source_emitter v2.
-- Source identity: LINKEDSPEC_GENERATED_SOURCE_IDENTITY.

local linkedspec = require("linkedspec")
local M = {}

M.LINKEDSPEC_GENERATED_SOURCE_CONTRACT = "linkedspec-generated-source-v2"
M.LINKEDSPEC_GENERATED_SOURCE_FORMAT = 2
M.LINKEDSPEC_REGEX_SLOT_IDENTITY_CONTRACT = "linkedspec-duplicate-regex-slot-identity-v1"
local _SOURCE_IDENTITY_HEX = "636f756e742d636f70792d736f757263652d6173736573736d656e742e73706563"
local _EFFECTIVE_SPEC_JSON_HEX = "7b2266756e6374696f6e73223a5b5d2c2272756c6573223a5b7b22626f6479223a5b7b226b696e64223a7b22636f6465223a2272657475726e285b636f70792866616c7365292c636f70792830292c636f7079285c22305c22292c636f707928756e646566292c7b66616c73657d2e636f707928292c7b307d2e636f707928292c7b5c22305c227d2e636f707928292c7b756e6465667d2e636f707928295d29222c226b696e64223a22636f64655f626c6f636b222c226c6966656379636c65223a2249227d2c226c696e65223a312c22736f75726365223a2249207b72657475726e285b636f70792866616c7365292c636f70792830292c636f7079285c22305c22292c636f707928756e646566292c7b66616c73657d2e636f707928292c7b307d2e636f707928292c7b5c22305c227d2e636f707928292c7b756e6465667d2e636f707928295d297d227d5d2c22686561646572223a7b2269735f746f70223a747275652c226c6162656c223a2256616c7565222c226c696e65223a312c226d6f6465223a2244656661756c74222c2272657374223a2249207b72657475726e285b636f70792866616c7365292c636f70792830292c636f7079285c22305c22292c636f707928756e646566292c7b66616c73657d2e636f707928292c7b307d2e636f707928292c7b5c22305c227d2e636f707928292c7b756e6465667d2e636f707928295d297d227d7d5d2c22736f757263655f6964223a22696e6c696e65227d"

local function decode_hex(value)
  if type(value) ~= "string" or #value % 2 ~= 0 or value:find("[^0-9a-f]") then
    error("generated-source hex payload is malformed", 0)
  end
  local chunks = {}
  for index = 1, #value, 2 do
    chunks[#chunks + 1] = string.char(assert(tonumber(value:sub(index, index + 1), 16)))
  end
  return table.concat(chunks)
end

M.LINKEDSPEC_GENERATED_SOURCE_IDENTITY = decode_hex(_SOURCE_IDENTITY_HEX)
local _GENERATED_PLAN = {
  linkedspec.generated_plan_row(decode_hex("56616c7565"), "default"),
}

linkedspec.validate_generated_source_contract_v2(
  M.LINKEDSPEC_GENERATED_SOURCE_CONTRACT,
  M.LINKEDSPEC_GENERATED_SOURCE_IDENTITY
)

function M.metadata()
  return linkedspec.generated_source_metadata(M.LINKEDSPEC_GENERATED_SOURCE_IDENTITY)
end

local function load_compiled_spec()
  local ok, result = pcall(function()
    local payload = decode_hex(_EFFECTIVE_SPEC_JSON_HEX)
    local decoded = linkedspec.json.decode(payload)
    return linkedspec.compile_spec(linkedspec.spec_ast.from_json("SpecFile", decoded))
  end)
  if ok then return result end
  if linkedspec.is_generated_source_error(result) then error(result, 0) end
  error(linkedspec.generated_source_compile_failed(
    M.LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
    result
  ), 0)
end

local _COMPILED_SPEC = load_compiled_spec()

function M.plan()
  local result = {}
  for index, row in ipairs(_GENERATED_PLAN) do
    result[index] = linkedspec.generated_plan_row(row.label, row.family)
  end
  return result
end

function M.validate_plan(actual)
  linkedspec.validate_generated_rule_plan_v2(
    _COMPILED_SPEC,
    actual,
    M.LINKEDSPEC_GENERATED_SOURCE_IDENTITY
  )
end

function M.execute(input, options)
  return linkedspec.execute_generated_parser_v2(
    _COMPILED_SPEC,
    _GENERATED_PLAN,
    input,
    M.LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
    options
  )
end

function M.execute_with_trace(input, trace_config, options)
  return linkedspec.execute_generated_parser_with_trace_v2(
    _COMPILED_SPEC,
    _GENERATED_PLAN,
    input,
    trace_config,
    M.LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
    options
  )
end

return M
