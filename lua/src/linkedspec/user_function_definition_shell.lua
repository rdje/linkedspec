local ast = require("linkedspec.spec_ast")
local json = require("linkedspec.json")
local spec_parser = require("linkedspec.spec_parser")

local M = {}

local PROJECTION_ERROR_MT = {
  __tostring = function(value)
    return "UserFunctionDefinitionException: " .. value.message
  end,
}

local function projection_fail(message)
  error(setmetatable({ message = message }, PROJECTION_ERROR_MT), 0)
end

function M.is_projection_error(value)
  return getmetatable(value) == PROJECTION_ERROR_MT
end

local function object_value(value, context)
  if json.kind(value) ~= "harray" then
    projection_fail(context .. " must be a JSON object")
  end
  return value
end

local function array_value(value, context)
  if json.kind(value) ~= "array" then
    projection_fail(context .. " must be a JSON array")
  end
  return value
end

local function string_field(object, field, context)
  local value = object[field]
  if type(value) ~= "string" then
    projection_fail(context .. " is missing string field '" .. field .. "'")
  end
  return value
end

local function integer_field(object, field, index)
  local value = object[field]
  if type(value) ~= "number" or value % 1 ~= 0 or value < 0 then
    projection_fail(
      "function_definition node " .. index .. " field '" .. field .. "' must be a non-negative integer"
    )
  end
  return value
end

local function required_value(object, field, index)
  local value = object[field]
  if value == nil then
    projection_fail("function_definition node " .. index .. " is missing field '" .. field .. "'")
  end
  return value
end

local function string_list_field(object, field, index)
  local values = array_value(
    object[field],
    "function_definition node " .. index .. " field '" .. field .. "'"
  )
  local result = {}
  for item_index, value in ipairs(values) do
    if type(value) ~= "string" then
      projection_fail(
        "function_definition node " .. index .. " field '" .. field .. "' item " ..
        (item_index - 1) .. " is not a string"
      )
    end
    result[item_index] = value
  end
  return result
end

local function assert_string_field(object, field, expected, index)
  local actual = string_field(object, field, "function_definition")
  if actual ~= expected then
    projection_fail(
      "function_definition node " .. index .. " expected " .. field .. "='" .. expected ..
      "', got '" .. actual .. "'"
    )
  end
end

local function is_identifier(value)
  return value:match("^[A-Za-z_][A-Za-z0-9_]*$") ~= nil
end

local function clone_json(value)
  return json.decode(json.encode(value))
end

local function codepoint_offsets(source)
  local offsets = { [0] = 1 }
  local character_count = 0
  local byte_position = 1
  while byte_position <= #source do
    local first = source:byte(byte_position)
    local width
    if first <= 0x7F then
      width = 1
    elseif first <= 0xDF then
      width = 2
    elseif first <= 0xEF then
      width = 3
    else
      width = 4
    end
    byte_position = byte_position + width
    character_count = character_count + 1
    offsets[character_count] = byte_position
  end
  return offsets, character_count
end

local function source_slice(source, offsets, character_count, start_position, end_position)
  if start_position > end_position or end_position > character_count then
    return nil
  end
  return source:sub(offsets[start_position], offsets[end_position] - 1)
end

local function span_field(object, field, index)
  local span = object_value(
    required_value(object, field, index),
    "function_definition node " .. index .. " " .. field
  )
  local result = {
    start = integer_field(span, "start", index),
    ["end"] = integer_field(span, "end", index),
    line_start = integer_field(span, "line_start", index),
    line_end = integer_field(span, "line_end", index),
  }
  if result.line_start == 0 or result.line_end == 0 or result.line_start > result.line_end then
    projection_fail(
      "function_definition node " .. index .. " " .. field .. " has invalid line span " ..
      result.line_start .. ".." .. result.line_end
    )
  end
  if result.start > result["end"] then
    projection_fail(
      "function_definition node " .. index .. " " .. field .. " has invalid character span " ..
      result.start .. ".." .. result["end"]
    )
  end
  return result
end

local function spans_equal(left, right)
  return left.start == right.start and left["end"] == right["end"] and
    left.line_start == right.line_start and left.line_end == right.line_end
end

local function validate_span_text(source, offsets, character_count, span, expected, field, index)
  local actual = source_slice(source, offsets, character_count, span.start, span["end"])
  if actual == nil then
    projection_fail(
      "function_definition node " .. index .. " " .. field .. " span " ..
      span.start .. ".." .. span["end"] .. " is outside source"
    )
  elseif actual ~= expected then
    projection_fail(
      "function_definition node " .. index .. " " .. field .. " does not match its source span"
    )
  end
end

local function string_lists_equal(left, right)
  if #left ~= #right then
    return false
  end
  for index = 1, #left do
    if left[index] ~= right[index] then
      return false
    end
  end
  return true
end

local function parameter_kinds_field(object, params, context, index)
  local kinds = object_value(
    required_value(object, "parameter_kinds", index),
    "function_definition node " .. index .. " " .. context .. " parameter_kinds"
  )
  if #params == 0 then
    projection_fail(
      "function_definition node " .. index .. " " .. context ..
      " codeblock parameter must be final"
    )
  end
  local expected_name = params[#params]
  local count = 0
  for name, kind in pairs(kinds) do
    count = count + 1
    if name ~= expected_name or kind ~= "codeblock" then
      projection_fail(
        "function_definition node " .. index .. " " .. context ..
        " must declare only the final parameter as codeblock"
      )
    end
  end
  if count ~= 1 then
    projection_fail(
      "function_definition node " .. index .. " " .. context ..
      " must declare exactly one parameter kind"
    )
  end
  local result = json.harray()
  result[expected_name] = "codeblock"
  return result
end

local function canonicalize_codeblock_definition(object, index)
  if object.codeblock_param == nil then return end
  if integer_field(object, "version", index) ~= 1 then
    projection_fail("function_definition node " .. index .. " codeblock declaration requires version 1")
  end
  local fixed_params = string_list_field(object, "fixed_params", index)
  local codeblock_param = string_field(object, "codeblock_param", "function_definition")
  if not is_identifier(codeblock_param) then
    projection_fail(
      "function_definition node " .. index .. " has invalid codeblock parameter '" ..
      codeblock_param .. "'"
    )
  end
  local params = {}
  for item_index, param in ipairs(fixed_params) do params[item_index] = param end
  params[#params + 1] = codeblock_param
  parameter_kinds_field(object, params, "function definition", index)

  for _, field in ipairs({ "body_payload", "body_parse_job" }) do
    local record = object_value(
      required_value(object, field, index),
      "function_definition node " .. index .. " " .. field
    )
    local record_fixed = string_list_field(record, "fixed_params", index)
    if not string_lists_equal(record_fixed, fixed_params) then
      projection_fail("function_definition node " .. index .. " " .. field .. " fixed_params do not match")
    elseif string_field(record, "codeblock_param", field) ~= codeblock_param then
      projection_fail("function_definition node " .. index .. " " .. field .. " codeblock_param does not match")
    end
    parameter_kinds_field(record, params, field, index)
    record.params = json.array(params)
    record.arity = #params
    record.fixed_params = nil
    record.codeblock_param = nil
  end

  object.params = json.array(params)
  object.arity = #params
  object.fixed_params = nil
  object.codeblock_param = nil
end

local CALLABLE_SIGNATURE_FIELDS = {
  kind = true,
  version = true,
  positional_params = true,
  rest_param = true,
  min_arity = true,
  max_arity = true,
}

local function callable_signature_field(object, field, index)
  local signature = object_value(
    required_value(object, field, index),
    "function_definition node " .. index .. " field '" .. field .. "'"
  )
  local field_count = 0
  for key in pairs(signature) do
    field_count = field_count + 1
    if not CALLABLE_SIGNATURE_FIELDS[key] then
      projection_fail(
        "function_definition node " .. index .. " field '" .. field ..
        "' has invalid callable signature fields"
      )
    end
  end
  if field_count ~= 6 then
    projection_fail(
      "function_definition node " .. index .. " field '" .. field ..
      "' has invalid callable signature fields"
    )
  end
  assert_string_field(signature, "kind", "callable_signature", index)
  local version = integer_field(signature, "version", index)
  if version ~= 1 then
    projection_fail(
      "function_definition node " .. index .. " field '" .. field ..
      "' has unsupported signature version " .. version
    )
  end
  local positional_params = string_list_field(signature, "positional_params", index)
  for _, param in ipairs(positional_params) do
    if not is_identifier(param) then
      projection_fail(
        "function_definition node " .. index .. " has invalid positional parameter '" .. param .. "'"
      )
    end
  end
  local rest_param = string_field(signature, "rest_param", "callable_signature")
  if not is_identifier(rest_param) then
    projection_fail(
      "function_definition node " .. index .. " has invalid rest parameter '" .. rest_param .. "'"
    )
  end
  local min_arity = integer_field(signature, "min_arity", index)
  if min_arity ~= #positional_params then
    projection_fail(
      "function_definition node " .. index .. " min_arity " .. min_arity ..
      " does not match " .. #positional_params .. " positional params"
    )
  end
  if signature.max_arity ~= json.null then
    projection_fail(
      "function_definition node " .. index .. " field '" .. field .. "' max_arity must be null"
    )
  end
  return ast.callable_signature({
    kind = "callable_signature",
    version = version,
    positional_params = positional_params,
    rest_param = rest_param,
    min_arity = min_arity,
    max_arity = nil,
  })
end

local function validate_parent_path(object, context, index)
  local path = string_list_field(object, "parent_ast_path", index)
  if #path ~= 3 or path[1] ~= "functions" or path[3] ~= "body_source" then
    projection_fail(
      "function_definition node " .. index .. " " .. context ..
      " parent_ast_path must target functions[*].body_source"
    )
  end
end

local function normalize_parent_path(object, index)
  object.parent_ast_path = json.array({ "functions", tostring(index), "body_source" })
end

local function validate_staged_signature(object, context, params, arity, signature, parameter_kinds, index)
  if signature ~= nil then
    if object.params ~= nil or object.arity ~= nil then
      projection_fail(
        "function_definition node " .. index .. " " .. context ..
        " version 2 must store arity only in signature"
      )
    elseif object.parameter_kinds ~= nil then
      projection_fail(
        "function_definition node " .. index .. " " .. context ..
        " version 2 must not contain parameter_kinds"
      )
    end
    local actual = callable_signature_field(object, "signature", index)
    if not ast.callable_signatures_equal(actual, signature) then
      projection_fail(
        "function_definition node " .. index .. " " .. context ..
        " signature does not match signature"
      )
    end
    return
  end
  if object.signature ~= nil then
    projection_fail(
      "function_definition node " .. index .. " " .. context ..
      " version 1 must not contain signature"
    )
  elseif not string_lists_equal(string_list_field(object, "params", index), params) then
    projection_fail("function_definition node " .. index .. " " .. context .. " params do not match params")
  elseif integer_field(object, "arity", index) ~= arity then
    projection_fail("function_definition node " .. index .. " " .. context .. " arity does not match arity")
  end
  if parameter_kinds ~= nil then
    local actual = parameter_kinds_field(object, params, context, index)
    if not ast.parameter_kinds_equal(actual, parameter_kinds) then
      projection_fail(
        "function_definition node " .. index .. " " .. context ..
        " parameter_kinds do not match parameter_kinds"
      )
    end
  elseif object.parameter_kinds ~= nil then
    projection_fail(
      "function_definition node " .. index .. " untyped " .. context ..
      " must not contain parameter_kinds"
    )
  end
end

local function validate_body_common(
  object,
  context,
  name,
  params,
  arity,
  signature,
  parameter_kinds,
  body_source,
  body_span,
  index
)
  assert_string_field(object, "node_kind", "function_definition", index)
  assert_string_field(object, "payload_kind", "function_body", index)
  validate_parent_path(object, context, index)
  if string_field(object, "function_name", context) ~= name then
    projection_fail("function_definition node " .. index .. " " .. context .. " function_name does not match name")
  end
  validate_staged_signature(object, context, params, arity, signature, parameter_kinds, index)
  if string_field(object, "text", context) ~= body_source then
    projection_fail("function_definition node " .. index .. " " .. context .. " text does not match body_source")
  elseif not spans_equal(span_field(object, "source_span", index), body_span) then
    projection_fail("function_definition node " .. index .. " " .. context .. " source_span does not match body_span")
  end
end

local function validate_body_payload(
  payload,
  name,
  params,
  arity,
  signature,
  parameter_kinds,
  body_source,
  body_span,
  index
)
  local object = object_value(payload, "function_definition node " .. index .. " body_payload")
  assert_string_field(object, "kind", "staged_payload", index)
  validate_body_common(
    object,
    "body_payload",
    name,
    params,
    arity,
    signature,
    parameter_kinds,
    body_source,
    body_span,
    index
  )
end

local function validate_body_parse_job(
  job,
  name,
  params,
  arity,
  signature,
  parameter_kinds,
  body_source,
  body_span,
  index
)
  local object = object_value(job, "function_definition node " .. index .. " body_parse_job")
  assert_string_field(object, "kind", "parse_job", index)
  validate_body_common(
    object,
    "body_parse_job",
    name,
    params,
    arity,
    signature,
    parameter_kinds,
    body_source,
    body_span,
    index
  )
  if string_field(object, "job_id", "body_parse_job") == "" then
    projection_fail("function_definition node " .. index .. " body_parse_job job_id must be non-empty")
  end
  local required_strings = {
    parser_spec_id = "actionir-body.spec",
    top_rule = "action_block",
    result_policy = "replace_field",
    result_field = "body_ast",
    failure_policy = "fail",
    diagnostic_owner = "function_body",
  }
  for field, expected in pairs(required_strings) do
    local actual = string_field(object, field, "body_parse_job")
    if actual ~= expected then
      projection_fail(
        "function_definition node " .. index .. " body_parse_job " .. field .. " must be " .. expected
      )
    end
  end
end

local function project_function(object, source, offsets, character_count, index)
  assert_string_field(object, "kind", "user_function_definition", index)
  canonicalize_codeblock_definition(object, index)
  local version = integer_field(object, "version", index)
  local name = string_field(object, "name", "function_definition")
  if not is_identifier(name) then
    projection_fail("function_definition node " .. index .. " has invalid name '" .. name .. "'")
  end
  local params
  local arity
  local signature
  local parameter_kinds
  if version == 1 then
    if object.signature ~= nil then
      projection_fail("function_definition node " .. index .. " version 1 must not contain signature")
    end
    params = string_list_field(object, "params", index)
    arity = integer_field(object, "arity", index)
    if object.parameter_kinds ~= nil then
      parameter_kinds = parameter_kinds_field(object, params, "function definition", index)
    end
  elseif version == 2 then
    if object.params ~= nil or object.arity ~= nil then
      projection_fail(
        "function_definition node " .. index .. " version 2 must store arity only in signature"
      )
    elseif object.parameter_kinds ~= nil then
      projection_fail(
        "function_definition node " .. index .. " version 2 must not contain parameter_kinds"
      )
    end
    signature = callable_signature_field(object, "signature", index)
    params = signature.positional_params
    arity = signature.min_arity
  else
    projection_fail(
      "function_definition node " .. index .. " has unsupported version " .. version
    )
  end
  for _, param in ipairs(params) do
    if not is_identifier(param) then
      projection_fail("function_definition node " .. index .. " has invalid parameter '" .. param .. "'")
    end
  end
  if arity ~= #params then
    projection_fail(
      "function_definition node " .. index .. " arity " .. arity .. " does not match " .. #params .. " params"
    )
  end

  local source_text = string_field(object, "source_text", "function_definition")
  local source_span = span_field(object, "source_span", index)
  validate_span_text(source, offsets, character_count, source_span, source_text, "source_text", index)
  local body_source = string_field(object, "body_source", "function_definition")
  local body_span = span_field(object, "body_span", index)
  validate_span_text(source, offsets, character_count, body_span, body_source, "body_source", index)
  if source_span.start > body_span.start or body_span.start > body_span["end"] or
      body_span["end"] > source_span["end"] then
    projection_fail("function_definition node " .. index .. " body span is outside source span")
  end

  local body_payload = clone_json(required_value(object, "body_payload", index))
  validate_body_payload(
    body_payload,
    name,
    params,
    arity,
    signature,
    parameter_kinds,
    body_source,
    body_span,
    index
  )
  normalize_parent_path(body_payload, index)
  local body_parse_job = clone_json(required_value(object, "body_parse_job", index))
  validate_body_parse_job(
    body_parse_job,
    name,
    params,
    arity,
    signature,
    parameter_kinds,
    body_source,
    body_span,
    index
  )
  normalize_parent_path(body_parse_job, index)
  body_parse_job.job_id = "parse_job:function_body:functions." .. index ..
    ".body_source:actionir-body.spec:action_block:" .. body_span.start .. "-" .. body_span["end"]

  return {
    definition = ast.function_definition({
      name = name,
      params = params,
      arity = arity,
      signature = signature,
      parameter_kinds = parameter_kinds,
      body_source = body_source,
      body_payload = body_payload,
      body_parse_job = ast.from_json("StagedParseJob", body_parse_job),
      source = source_text,
      source_span = ast.source_span({ line_start = source_span.line_start, line_end = source_span.line_end }),
      body_span = ast.source_span({ line_start = body_span.line_start, line_end = body_span.line_end }),
    }),
    span = source_span,
  }
end

local function strip_spans(source, offsets, character_count, spans)
  if #spans == 0 then
    return source
  end
  table.sort(spans, function(left, right)
    return left.start < right.start
  end)
  local previous_end = 0
  for _, span in ipairs(spans) do
    if span.start > span["end"] or span["end"] > character_count then
      projection_fail(
        "function definition span " .. span.start .. ".." .. span["end"] ..
        " is outside source length " .. character_count
      )
    elseif span.start < previous_end then
      projection_fail("function definition spans overlap at " .. span.start .. ".." .. span["end"])
    end
    previous_end = span["end"]
  end

  local chunks = {}
  local span_index = 1
  for character_index = 0, character_count - 1 do
    while span_index <= #spans and character_index >= spans[span_index]["end"] do
      span_index = span_index + 1
    end
    local inside = span_index <= #spans and character_index >= spans[span_index].start and
      character_index < spans[span_index]["end"]
    local character = source:sub(offsets[character_index], offsets[character_index + 1] - 1)
    if inside and character ~= "\n" and character ~= "\r" then
      chunks[#chunks + 1] = " "
    else
      chunks[#chunks + 1] = character
    end
  end
  return table.concat(chunks)
end

local function definition_error(object, index)
  local line = 0
  if json.kind(object.source_span) == "harray" and type(object.source_span.line_start) == "number" then
    line = object.source_span.line_start
  end
  local message = type(object.message) == "string" and object.message or "invalid user function definition"
  local header = type(object.source_text) == "string" and object.source_text or ""
  header = header:match("^(.-){") or header
  if header:match(":%s*codeblock%s*%(") then
    message = "codeblock_declaration_has_no_argument_list"
  elseif header:match(":%s*codeblock%s*,") then
    message = "codeblock_parameter_must_be_final"
  elseif header:match("%(%s*:%s*codeblock") then
    message = "invalid_codeblock_parameter_name"
  else
    local declared_type = header:match(":%s*([A-Za-z_][A-Za-z0-9_]*)")
    if declared_type ~= nil and declared_type ~= "codeblock" then
      message = "unknown_parameter_type"
    end
  end
  if line > 0 then
    return spec_parser.new_parse_error(
      line,
      "user function definition parse error at line " .. line .. ": " .. message
    )
  end
  return spec_parser.new_parse_error(
    1,
    "user function definition parse error at node " .. index .. ": " .. message
  )
end

function M.definition_nodes_from_output(output)
  if output == nil or output == json.null then
    return json.array()
  end
  local kind = json.kind(output)
  if kind == "harray" then
    return json.array({ clone_json(output) })
  elseif kind == "array" then
    if #output == 0 then
      return json.array()
    end
    local all_objects = true
    local all_arrays = true
    for _, item in ipairs(output) do
      all_objects = all_objects and json.kind(item) == "harray"
      all_arrays = all_arrays and json.kind(item) == "array"
    end
    if all_objects then
      return clone_json(output)
    elseif #output == 1 then
      return M.definition_nodes_from_output(output[1])
    elseif all_arrays then
      local flattened = json.array()
      for _, item in ipairs(output) do
        local nodes = M.definition_nodes_from_output(item)
        for _, node_value in ipairs(nodes) do
          flattened[#flattened + 1] = node_value
        end
      end
      return flattened
    end
  end
  projection_fail("user_function_definition.spec returned unsupported output shape")
end

function M.project(source, definition_nodes)
  if type(source) ~= "string" then
    projection_fail("function projection source must be a string")
  end
  local valid_utf8, invalid_position = json.validate_utf8(source)
  if not valid_utf8 then
    projection_fail("function projection source is not valid UTF-8 at byte " .. invalid_position)
  end
  local nodes = array_value(definition_nodes, "definition_nodes")
  local offsets, character_count = codepoint_offsets(source)
  local functions = {}
  local spans = {}
  for lua_index, node_value in ipairs(nodes) do
    local index = lua_index - 1
    local object = object_value(node_value, "definition node " .. index)
    local node_type = string_field(object, "type", "definition node")
    if node_type == "function_definition" then
      local projected = project_function(object, source, offsets, character_count, index)
      functions[#functions + 1] = projected.definition
      spans[#spans + 1] = projected.span
    elseif node_type == "function_definition_error" then
      error(definition_error(object, index), 0)
    else
      projection_fail(
        "user_function_definition.spec returned unsupported node type '" .. node_type .. "' at index " .. index
      )
    end
  end
  return {
    functions = functions,
    stripped_source = strip_spans(source, offsets, character_count, spans),
  }
end

function M.parse_spec_with_asts(source, definition_nodes)
  local projection = M.project(source, definition_nodes)
  local ok, rule_spec = pcall(spec_parser.parse_spec, projection.stripped_source)
  if not ok then
    if spec_parser.is_parse_error(rule_spec) then
      error(spec_parser.new_parse_error(
        rule_spec.line,
        "rule parse after function extraction failed: " .. rule_spec.message
      ), 0)
    end
    error(rule_spec, 0)
  end
  return ast.spec_file({ functions = projection.functions, rules = rule_spec.rules })
end

return M
