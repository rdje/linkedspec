-- Generated LinkedSpec parser module.
-- Contract id: linkedspec-generated-source-v2.
-- Source format: linkedspec_lua source_emitter v2.
-- Source identity: LINKEDSPEC_GENERATED_SOURCE_IDENTITY.

local linkedspec = require("linkedspec")
local M = {}

M.LINKEDSPEC_GENERATED_SOURCE_CONTRACT = "linkedspec-generated-source-v2"
M.LINKEDSPEC_GENERATED_SOURCE_FORMAT = 2
M.LINKEDSPEC_REGEX_SLOT_IDENTITY_CONTRACT = "linkedspec-duplicate-regex-slot-identity-v1"
local _SOURCE_IDENTITY_HEX = "7261772d6572726f722d61756469742f6e65737465645f62696e64696e672e73706563"
local _EFFECTIVE_SPEC_JSON_HEX = "7b2266756e6374696f6e73223a5b5d2c2272756c6573223a5b7b22626f6479223a5b7b226b696e64223a7b22636f6465223a6e756c6c2c22666c75656e745f636861696e223a5b5d2c226b696e64223a22616374696f6e5f65646765222c2274617267657473223a5b7b22617574686f7265645f73656c6563746f72223a6e756c6c2c22696e646578223a302c226c6162656c223a224368696c64222c2273656c6563746f725f6b696e64223a22756e696e6465786564227d5d7d2c226c696e65223a322c22736f75726365223a222d3e204368696c64227d5d2c22686561646572223a7b2269735f746f70223a747275652c226c6162656c223a22546f70222c226c696e65223a312c226d6f6465223a2244656661756c74222c2272657374223a22227d7d2c7b22626f6479223a5b7b226b696e64223a7b226b696e64223a227265676578222c227061747465726e223a2278222c22736c6f745f6964223a6e756c6c7d2c226c696e65223a352c22736f75726365223a222f782f227d2c7b226b696e64223a7b22636f6465223a226974656d733d5c226261645c223b6974656d732b3d313b72657475726e286974656d7329222c226b696e64223a22636f64655f626c6f636b222c226c6966656379636c65223a2245227d2c226c696e65223a362c22736f75726365223a2245207b6974656d733d5c226261645c223b6974656d732b3d313b72657475726e286974656d73297d227d5d2c22686561646572223a7b2269735f746f70223a66616c73652c226c6162656c223a224368696c64222c226c696e65223a342c226d6f6465223a2244656661756c74222c2272657374223a22227d7d5d2c22736f757263655f6964223a22696e6c696e65227d"

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
  linkedspec.generated_plan_row(decode_hex("546f70"), "default"),
  linkedspec.generated_plan_row(decode_hex("4368696c64"), "default"),
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
