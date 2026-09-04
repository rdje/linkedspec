local action_ast = require("linkedspec.action_ast")
local json = require("linkedspec.json")

local M = {}

local ACTION_PARSE_ERROR_MT = {
  __tostring = function(value)
    return "ActionParseException: " .. value.message
  end,
}

local NESTED_WRITE_RESERVED_ROOTS = {
  CAPTURE = true,
  IINDEX = true,
  IMATCH = true,
  IMATCH_HASH = true,
  IMATCH_LIST = true,
  IPOS = true,
  LINDEX = true,
  LMATCH = true,
  LMATCH_HASH = true,
  LMATCH_LIST = true,
  LSPOS = true,
  STRING = true,
  descr = true,
  ["false"] = true,
  info = true,
  minfo = true,
  null = true,
  retv = true,
  ["true"] = true,
  undef = true,
}

function M.is_nested_write_reserved_root(value)
  return type(value) == "string" and NESTED_WRITE_RESERVED_ROOTS[value] == true
end

local function action_parse_fail(code, source_span, message)
  error(setmetatable({
    code = code,
    stage = "action_parse",
    source_span = source_span,
    message = message,
  }, ACTION_PARSE_ERROR_MT), 0)
end

function M.is_action_parse_error(value)
  return getmetatable(value) == ACTION_PARSE_ERROR_MT
end

function M.action_parse_error_to_json(value)
  if not M.is_action_parse_error(value) then
    error("ActionParseException: action_parse_error_to_json expects ActionParseException", 0)
  end
  return json.harray({
    code = value.code,
    stage = value.stage,
    source_span = json.harray({
      start = value.source_span.start,
      ["end"] = value.source_span["end"],
      unit = "unicode_scalar",
      provenance = "authored",
    }),
    message = value.message,
  })
end

local function trim_offsets(text, absolute_start)
  local first = 1
  while first <= #text and text:sub(first, first):match("%s") do
    first = first + 1
  end
  local last = #text
  while last >= first and text:sub(last, last):match("%s") do
    last = last - 1
  end
  return text:sub(first, last), absolute_start + first - 1, absolute_start + last
end

local function is_word_byte(byte)
  return byte and ((byte >= 48 and byte <= 57) or (byte >= 65 and byte <= 90) or
    (byte >= 97 and byte <= 122) or byte == 95)
end

local function skip_space(text, position)
  while position <= #text and text:sub(position, position):match("%s") do
    position = position + 1
  end
  return position
end

local function regex_closer_follows_group(text, position)
  local escaped = false
  for cursor = position + 1, #text do
    local character = text:sub(cursor, cursor)
    if character == "\n" then return false end
    if escaped then
      escaped = false
    elseif character == "\\" then
      escaped = true
    elseif character == "/" then
      local suffix = cursor + 1
      while text:sub(suffix, suffix):match("[A-Za-z]") do suffix = suffix + 1 end
      suffix = skip_space(text, suffix)
      if suffix > #text then return true end
      return text:sub(suffix, suffix):match("[,%)%]%}%.;]") ~= nil
    end
  end
  return false
end

local function looks_slash_symbol_callee(text, position)
  local open_position = skip_space(text, position + 1)
  if text:sub(open_position, open_position) ~= "(" then return false end
  local depth = 0
  local bracket_depth = 0
  local quote
  local escaped = false
  for cursor = open_position, #text do
    local character = text:sub(cursor, cursor)
    if quote then
      if escaped then
        escaped = false
      elseif character == "\\" then
        escaped = true
      elseif character == quote then
        quote = nil
      end
    elseif character == '"' or character == "'" then
      quote = character
    elseif character == "/" then
      local nested_open = skip_space(text, cursor + 1)
      if text:sub(nested_open, nested_open) ~= "(" then return false end
    elseif character == "[" then
      bracket_depth = bracket_depth + 1
    elseif character == "]" then
      bracket_depth = math.max(0, bracket_depth - 1)
    elseif character == "(" and bracket_depth == 0 then
      depth = depth + 1
    elseif character == ")" and bracket_depth == 0 then
      depth = depth - 1
      if depth == 0 then
        local next_position = skip_space(text, cursor + 1)
        if text:sub(cursor + 1, next_position - 1):find("\n", 1, true) then return true end
        if next_position > #text then return true end
        if regex_closer_follows_group(text, cursor) then return false end
        return text:sub(next_position, next_position):match("[,%)%]%}%.;]") ~= nil
      end
    end
  end
  return false
end

local function looks_regex_start(text, position)
  if looks_slash_symbol_callee(text, position) then return false end
  local previous = position - 1
  while previous >= 1 and text:sub(previous, previous):match("%s") do
    previous = previous - 1
  end
  if previous < 1 then
    return true
  end
  return text:sub(previous, previous):match("[%(,%=:!%[%{%?]") ~= nil
end

local function scan_state()
  return { quote = nil, escaped = false, regex = false, paren = 0, bracket = 0, brace = 0 }
end

local function top_level(state)
  return state.quote == nil and not state.regex and state.paren == 0 and state.bracket == 0 and state.brace == 0
end

local BRANCH_KEYWORDS = {
  ["elseif"] = true,
  elif = true,
  ["else"] = true,
  otherwise = true,
  ["case"] = true,
  default = true,
}

local SYMBOL_CALLEES = {
  ["+"] = true,
  ["-"] = true,
  ["*"] = true,
  ["/"] = true,
  ["%"] = true,
  ["="] = true,
  ["=="] = true,
  ["!="] = true,
  [">"] = true,
  [">="] = true,
  ["<"] = true,
  ["<="] = true,
}

local CODEBLOCK_RESERVED_PARAMETERS = {
  fn = true,
  ["return"] = true,
  I = true,
  LS = true,
  LE = true,
  E = true,
  EX = true,
  IT = true,
  LX = true,
  STRING = true,
  descr = true,
  minfo = true,
  LSPOS = true,
  LEPOS = true,
  LMATCH = true,
  LSMATCH = true,
  IMATCH = true,
  IMATCH_LIST = true,
  LMATCH_LIST = true,
  IMATCH_HASH = true,
  LMATCH_HASH = true,
  SELF = true,
  this = true,
  ctx = true,
  runtime_ctx = true,
}

local function starts_with_keyword(text, keywords)
  local keyword = text:match("^([A-Za-z_][A-Za-z0-9_]*)")
  return keyword ~= nil and keywords[keyword] == true
end

local function consume_scan(state, text, position)
  local character = text:sub(position, position)
  if state.quote then
    if state.escaped then
      state.escaped = false
    elseif character == "\\" then
      state.escaped = true
    elseif character == state.quote then
      state.quote = nil
    end
    return
  elseif state.regex then
    if state.escaped then
      state.escaped = false
    elseif character == "\\" then
      state.escaped = true
    elseif character == "/" then
      state.regex = false
    end
    return
  end
  if character == '"' or character == "'" then
    state.quote = character
  elseif character == "/" and looks_regex_start(text, position) then
    state.regex = true
  elseif character == "(" then
    state.paren = state.paren + 1
  elseif character == ")" then
    state.paren = state.paren - 1
  elseif character == "[" then
    state.bracket = state.bracket + 1
  elseif character == "]" then
    state.bracket = state.bracket - 1
  elseif character == "{" then
    state.brace = state.brace + 1
  elseif character == "}" then
    state.brace = state.brace - 1
  end
end

local function split_top_level(text, absolute_start, separators)
  local pieces = {}
  local state = scan_state()
  local segment_start = 1
  local position = 1
  while position <= #text do
    local was_top = top_level(state)
    local character = text:sub(position, position)
    if was_top and separators[character] then
      local piece, start_position, end_position = trim_offsets(
        text:sub(segment_start, position - 1),
        absolute_start + segment_start - 1
      )
      if piece ~= "" then
        pieces[#pieces + 1] = { text = piece, start = start_position, ["end"] = end_position }
      end
      segment_start = position + 1
    else
      consume_scan(state, text, position)
      if character == "}" and top_level(state) and separators.branch then
        local next_position = skip_space(text, position + 1)
        local tail = text:sub(next_position)
        if starts_with_keyword(tail, BRANCH_KEYWORDS) then
          local piece, start_position, end_position = trim_offsets(
            text:sub(segment_start, position),
            absolute_start + segment_start - 1
          )
          if piece ~= "" then
            pieces[#pieces + 1] = { text = piece, start = start_position, ["end"] = end_position }
          end
          segment_start = next_position
          position = next_position - 1
        end
      end
    end
    position = position + 1
  end
  local piece, start_position, end_position = trim_offsets(
    text:sub(segment_start),
    absolute_start + segment_start - 1
  )
  if piece ~= "" then
    pieces[#pieces + 1] = { text = piece, start = start_position, ["end"] = end_position }
  end
  return pieces
end

local function find_matching(text, open_position, open_character, close_character)
  local state = scan_state()
  local depth = 0
  for position = open_position, #text do
    local character = text:sub(position, position)
    if state.quote or state.regex then
      consume_scan(state, text, position)
    elseif character == '"' or character == "'" or
        (character == "/" and looks_regex_start(text, position)) then
      consume_scan(state, text, position)
    elseif character == open_character then
      depth = depth + 1
    elseif character == close_character then
      depth = depth - 1
      if depth == 0 then
        return position
      end
    end
  end
  return nil
end

local function outer_balanced(text, open_character, close_character)
  return text:sub(1, 1) == open_character and text:sub(-1) == close_character and
    find_matching(text, 1, open_character, close_character) == #text
end

local function find_top_level_token(text, token)
  local state = scan_state()
  local position = 1
  while position <= #text - #token + 1 do
    if top_level(state) and text:sub(position, position + #token - 1) == token then
      return position
    end
    consume_scan(state, text, position)
    position = position + 1
  end
  return nil
end

local function find_assignment_equals(text)
  local state = scan_state()
  for position = 1, #text do
    local character = text:sub(position, position)
    if top_level(state) and character == "=" then
      local before = text:sub(position - 1, position - 1)
      local after = text:sub(position + 1, position + 1)
      if before ~= "=" and before ~= "!" and before ~= "<" and before ~= ">" and before ~= ":" and
          after ~= "=" and after ~= ">" then
        return position
      end
    end
    consume_scan(state, text, position)
  end
  return nil
end

local function find_unclosed_nested_write_assignment_equals(text)
  local open_position = text:find("[", 1, true)
  if open_position == nil then return nil end
  local root = text:sub(1, open_position - 1):match("^%s*([A-Za-z_][A-Za-z0-9_]*)%s*$")
  if root == nil or find_matching(text, open_position, "[", "]") ~= nil then return nil end

  local quote
  local escaped = false
  for position = open_position + 1, #text do
    local character = text:sub(position, position)
    if quote then
      if escaped then
        escaped = false
      elseif character == "\\" then
        escaped = true
      elseif character == quote then
        quote = nil
      end
    elseif character == '"' or character == "'" then
      quote = character
    elseif character == "=" then
      local before = text:sub(position - 1, position - 1)
      local after = text:sub(position + 1, position + 1)
      if before ~= "=" and before ~= "!" and before ~= "<" and before ~= ">" and before ~= ":" and
          after ~= "=" and after ~= ">" then
        return position
      end
    end
  end
  return nil
end

local function find_top_level_brace(text)
  local state = scan_state()
  for position = 1, #text do
    if top_level(state) and text:sub(position, position) == "{" then
      return position
    end
    consume_scan(state, text, position)
  end
  return nil
end

local function split_attached_block(text)
  local open_position = find_top_level_brace(text)
  if not open_position then
    return nil
  end
  local close_position = find_matching(text, open_position, "{", "}")
  if close_position ~= #text then
    return nil
  end
  return {
    head = text:sub(1, open_position - 1),
    body = text:sub(open_position + 1, close_position - 1),
    open_position = open_position,
    close_position = close_position,
  }
end

local function unescape_string(payload)
  return (payload:gsub("\\([\\'\"])", "%1"))
end

local function parser(root_source)
  local valid_utf8, invalid_position = json.validate_utf8(root_source)
  if not valid_utf8 then
    error("ActionParseException: source is not valid UTF-8 at byte " .. invalid_position, 0)
  end
  local boundary_to_character = {}
  local byte_position = 1
  local character_index = 0
  boundary_to_character[1] = 0
  while byte_position <= #root_source do
    local first = root_source:byte(byte_position)
    local width = first <= 0x7F and 1 or (first <= 0xDF and 2 or (first <= 0xEF and 3 or 4))
    byte_position = byte_position + width
    character_index = character_index + 1
    boundary_to_character[byte_position] = character_index
  end

  local function span(start_byte, end_byte)
    return action_ast.source_span(boundary_to_character[start_byte], boundary_to_character[end_byte])
  end

  local parse_expression
  local parse_block

  local function raw_expr(text, start_byte, reason)
    return action_ast.expr("raw_perl", text, span(start_byte, start_byte + #text), { reason = reason })
  end

  local function parse_codeblock_signature(source)
    if source == "" then return action_ast.callable_signature({}, nil), nil end
    local parts = {}
    local segment_start = 1
    for position = 1, #source + 1 do
      if position > #source or source:sub(position, position) == "," then
        parts[#parts + 1] = source:sub(segment_start, position - 1):match("^%s*(.-)%s*$")
        segment_start = position + 1
      end
    end
    local positional = {}
    local rest_param
    local seen = {}
    for index, part in ipairs(parts) do
      if part == "" then return nil, "invalid_parameter" end
      local name
      if part:sub(1, 3) == "..." then
        if index ~= #parts then return nil, "rest_parameter_must_be_final" end
        name = part:match("^%.%.%.([A-Za-z_][A-Za-z0-9_]*)$")
        if name == nil then return nil, "invalid_rest_parameter" end
        rest_param = name
      else
        name = part:match("^([A-Za-z_][A-Za-z0-9_]*)$")
        if name == nil then return nil, "invalid_parameter" end
        positional[#positional + 1] = name
      end
      if CODEBLOCK_RESERVED_PARAMETERS[name] then return nil, "reserved_parameter" end
      if seen[name] then return nil, "duplicate_parameter" end
      seen[name] = true
    end
    return action_ast.callable_signature(positional, rest_param), nil
  end

  local function parse_codeblock_literal(text, start_byte)
    local signature_end = text:find("|", 3, true)
    if signature_end == nil then
      return action_ast.codeblock_literal_error(
        text,
        span(start_byte, start_byte + #text),
        "missing_codeblock_signature_closer"
      )
    end
    local signature, error_code = parse_codeblock_signature(text:sub(3, signature_end - 1))
    if signature == nil then
      return action_ast.codeblock_literal_error(
        text,
        span(start_byte, start_byte + #text),
        error_code
      )
    end
    local body_source = text:sub(signature_end + 1, -2)
    local body_start = start_byte + signature_end
    local body_end = start_byte + #text - 1
    return action_ast.codeblock_literal(
      text,
      span(start_byte, start_byte + #text),
      signature,
      body_source,
      parse_block(body_source, body_start),
      span(body_start, body_end)
    )
  end

  local function parse_literal(text, start_byte)
    local end_byte = start_byte + #text
    if text:match("^-?%d+%.?%d*$") then
      return action_ast.expr("number", text, span(start_byte, end_byte), { value = tonumber(text) })
    elseif text == "undef" then
      return action_ast.expr("undef", text, span(start_byte, end_byte))
    elseif text == "true" or text == "false" then
      return action_ast.expr("boolean", text, span(start_byte, end_byte), { value = text == "true" })
    elseif #text >= 2 and (text:sub(1, 1) == '"' or text:sub(1, 1) == "'") and text:sub(-1) == text:sub(1, 1) then
      return action_ast.expr("string", text, span(start_byte, end_byte), {
        value = unescape_string(text:sub(2, -2)),
        quote = text:sub(1, 1),
      })
    end
    local pattern
    local flags
    if text:sub(1, 1) == "/" then
      local close_position = 2
      local escaped = false
      while close_position <= #text do
        local character = text:sub(close_position, close_position)
        if escaped then
          escaped = false
        elseif character == "\\" then
          escaped = true
        elseif character == "/" then
          local candidate_flags = text:sub(close_position + 1)
          if candidate_flags:match("^[A-Za-z]*$") then
            pattern = text:sub(2, close_position - 1)
            flags = candidate_flags
          end
          break
        end
        close_position = close_position + 1
      end
    end
    if pattern then
      return action_ast.expr("regex", text, span(start_byte, end_byte), { pattern = pattern, flags = flags })
    end
    return nil
  end

  local function parse_arguments(payload, payload_start)
    local args = {}
    for _, part in ipairs(split_top_level(payload, payload_start, { [","] = true })) do
      local colon = find_top_level_token(part.text, ":")
      local keyword_added = false
      if colon then
        local name = part.text:sub(1, colon - 1):match("^%s*([A-Za-z_][A-Za-z0-9_]*)%s*$")
        if name then
          local value_text, value_start = trim_offsets(
            part.text:sub(colon + 1),
            part.start + colon
          )
          args[#args + 1] = action_ast.keyword_argument(name, parse_expression(value_text, value_start))
          keyword_added = true
        end
      end
      if not keyword_added then
        args[#args + 1] = action_ast.positional_argument(parse_expression(part.text, part.start))
      end
    end
    return args
  end

  local function parse_callee(text, start_byte)
    local open_position = text:find("(", 1, true)
    if not open_position then
      return nil
    end
    local close_position = find_matching(text, open_position, "(", ")")
    if close_position ~= #text then
      return nil
    end
    local name = text:sub(1, open_position - 1):match("^%s*(.-)%s*$")
    if not name:match("^[A-Za-z_][A-Za-z0-9_]*$") and not SYMBOL_CALLEES[name] then
      return nil
    end
    return {
      name = name,
      payload = text:sub(open_position + 1, close_position - 1),
      payload_start = start_byte + open_position,
    }
  end

  local function parse_access_segments(text, position, start_byte)
    local segments = {}
    while position <= #text do
      if text:sub(position, position) ~= "[" then return nil end
      local close_position = find_matching(text, position, "[", "]")
      if not close_position then return nil end
      local payload, payload_start = trim_offsets(
        text:sub(position + 1, close_position - 1),
        start_byte + position
      )
      local expression = parse_expression(payload, payload_start)
      local segment_source = text:sub(position, close_position)
      if expression.kind == "string" then
        segments[#segments + 1] = action_ast.access_segment(
          "key",
          segment_source,
          span(start_byte + position - 1, start_byte + close_position),
          { value = expression.value }
        )
      else
        segments[#segments + 1] = action_ast.access_segment(
          "index",
          segment_source,
          span(start_byte + position - 1, start_byte + close_position),
          { expr = expression }
        )
      end
      position = skip_space(text, close_position + 1)
    end
    return segments
  end

  local function parse_access(text, start_byte)
    local prefix, name = text:match("^(%$?)([A-Za-z_][A-Za-z0-9_]*)")
    if not name then return nil end
    local position = skip_space(text, #prefix + #name + 1)
    if position > #text then
      return action_ast.expr("variable", text, span(start_byte, start_byte + #text), { name = name })
    end
    local segments = parse_access_segments(text, position, start_byte)
    if segments == nil then return nil end
    if #segments == 1 and segments[1].kind == "index" then
      return action_ast.expr("indexed_var", text, span(start_byte, start_byte + #text), {
        name = name,
        index = segments[1].expr,
      })
    end
    return action_ast.expr("nested_access", text, span(start_byte, start_byte + #text), {
      base = name,
      segments = segments,
    })
  end

  local function nested_write_syntax_error(code, start_byte, end_byte, message)
    action_parse_fail(code, span(start_byte, end_byte), message)
  end

  local function parse_nested_write_target(left, left_start)
    local open_position = left:find("[", 1, true)
    if open_position == nil then return nil end
    local root_text, root_start, root_end = trim_offsets(left:sub(1, open_position - 1), left_start)
    if not root_text:match("^[A-Za-z_][A-Za-z0-9_]*$") then
      local message = root_text == "{}" and
        "nested write root must be a bare identifier" or
        "nested write root must remain a bare identifier"
      nested_write_syntax_error(
        "nested_write_root_not_addressable",
        root_start,
        root_end,
        message
      )
    end
    if M.is_nested_write_reserved_root(root_text) then
      nested_write_syntax_error(
        "nested_write_root_reserved",
        root_start,
        root_end,
        "nested write root '" .. root_text .. "' is reserved"
      )
    end

    local segments = {}
    local position = open_position
    while position <= #left do
      position = skip_space(left, position)
      if position > #left then break end
      if left:sub(position, position) ~= "[" then
        nested_write_syntax_error(
          "nested_write_root_not_addressable",
          left_start,
          left_start + #left,
          "nested write root must remain a bare identifier"
        )
      end
      local close_position = find_matching(left, position, "[", "]")
      if close_position == nil then
        nested_write_syntax_error(
          "nested_write_segment_unclosed",
          left_start + position - 1,
          left_start + #left,
          "nested write segment is missing its closing bracket"
        )
      end
      local payload, payload_start, payload_end = trim_offsets(
        left:sub(position + 1, close_position - 1),
        left_start + position
      )
      if payload == "" then
        nested_write_syntax_error(
          "nested_write_segment_empty",
          left_start + position - 1,
          left_start + close_position,
          "nested write segment may not be empty"
        )
      end
      local expression = parse_expression(payload, payload_start)
      if expression.kind == "raw_perl" then
        nested_write_syntax_error(
          "nested_write_segment_expression_invalid",
          payload_start,
          payload_end,
          "segment must be one balanced ActionIR value expression"
        )
      end
      segments[#segments + 1] = action_ast.write_path_segment(
        payload,
        span(payload_start, payload_end),
        expression
      )
      position = close_position + 1
    end
    return { base = root_text, segments = segments }
  end

  local function staged_parse_job_error(code)
    error("LINKEDSPEC_STAGED_AST_ENRICHMENT_ERROR:" .. code, 0)
  end

  local function staged_literal_string(expression)
    if expression.kind == "string" then return expression.value end
    return nil
  end

  local function staged_parser_identity_is_valid(value)
    return value:match("^[a-z][a-z0-9]*[a-z0-9._:-]*$") ~= nil and
      value:match("[._:-][._:-]") == nil and value:match("[._:-]$") == nil
  end

  local function staged_parse_job_options(expression)
    if expression.kind ~= "call" or expression.name ~= "hash" or
        #expression.args == 0 or #expression.args % 2 ~= 0 then
      staged_parse_job_error("staged_parse_job_options_required")
    end

    local allowed = {
      node_kind = true,
      payload_kind = true,
      spec = true,
      top = true,
      result_policy = true,
      into = true,
      on_error = true,
      required_capabilities = true,
    }
    local values = {}
    for index = 1, #expression.args, 2 do
      local key_argument = expression.args[index]
      local value_argument = expression.args[index + 1]
      local key = key_argument.argument_kind == "positional" and
        staged_literal_string(key_argument.value) or nil
      if key == nil or value_argument.argument_kind ~= "positional" or values[key] ~= nil then
        staged_parse_job_error("staged_parse_job_options_required")
      end
      if not allowed[key] then staged_parse_job_error("staged_parse_job_option_unknown") end
      values[key] = value_argument.value
    end

    local function required_string(name)
      local expression_value = values[name]
      local value = expression_value and staged_literal_string(expression_value) or nil
      if value == nil then staged_parse_job_error("staged_parse_job_options_required") end
      return value
    end

    local function optional_string(name)
      local expression_value = values[name]
      if expression_value == nil then return nil end
      local value = staged_literal_string(expression_value)
      if value == nil then staged_parse_job_error("staged_parse_job_options_required") end
      return value
    end

    local node_kind = required_string("node_kind")
    local payload_kind = required_string("payload_kind")
    local parser_spec_id = required_string("spec")
    local top_rule = optional_string("top")
    local result_policy = required_string("result_policy")
    local into = optional_string("into")
    local failure_policy = required_string("on_error")
    if not node_kind:match("^[a-z][a-z0-9_]*$") or
        not payload_kind:match("^[a-z][a-z0-9_]*$") then
      staged_parse_job_error("staged_parse_job_options_required")
    end
    if not staged_parser_identity_is_valid(parser_spec_id) then
      staged_parse_job_error("staged_parser_identity_invalid")
    end
    if top_rule ~= nil and not top_rule:match("^[A-Za-z_][A-Za-z0-9_]*$") then
      staged_parse_job_error("staged_top_rule_invalid")
    end
    if result_policy ~= "replace_marker" and result_policy ~= "replace_field" and
        result_policy ~= "sibling_field" and result_policy ~= "append_child" then
      staged_parse_job_error("staged_result_policy_invalid")
    end
    if failure_policy ~= "fail" and failure_policy ~= "keep_text" and
        failure_policy ~= "diagnostic_node" then
      staged_parse_job_error("staged_failure_policy_invalid")
    end
    local target_is_valid = into ~= nil and into:match("^[A-Za-z_][A-Za-z0-9_]*$") ~= nil
    if (result_policy == "replace_marker" and into ~= nil) or
        (result_policy ~= "replace_marker" and not target_is_valid) then
      staged_parse_job_error("staged_result_target_invalid")
    end

    local required_capabilities = json.array()
    local capability_expression = values.required_capabilities
    if capability_expression ~= nil then
      if capability_expression.kind ~= "call" or capability_expression.name ~= "array" then
        staged_parse_job_error("staged_parse_job_options_required")
      end
      local seen = {}
      local capabilities = {}
      for _, argument in ipairs(capability_expression.args) do
        local capability = argument.argument_kind == "positional" and
          staged_literal_string(argument.value) or nil
        if capability == nil or not staged_parser_identity_is_valid(capability) or seen[capability] then
          staged_parse_job_error("staged_parse_job_options_required")
        end
        seen[capability] = true
        capabilities[#capabilities + 1] = capability
      end
      table.sort(capabilities)
      for index, capability in ipairs(capabilities) do
        required_capabilities[index] = capability
      end
    end

    return action_ast.staged_parse_job_options({
      node_kind = node_kind,
      payload_kind = payload_kind,
      spec = parser_spec_id,
      top = top_rule,
      result_policy = result_policy,
      into = into,
      on_error = failure_policy,
      required_capabilities = required_capabilities,
    })
  end

  local function staged_direct_text_plan(expression)
    if expression.kind ~= "call" then return nil end
    if expression.name == "entry_text" or expression.name == "match_text" then
      if #expression.args ~= 0 then staged_parse_job_error("staged_source_provenance_invalid") end
      return action_ast.staged_parse_job_direct_text_plan(expression.name)
    end
    if expression.name == "entry_group" or expression.name == "match_group" then
      if #expression.args ~= 1 or expression.args[1].argument_kind ~= "positional" then
        staged_parse_job_error("staged_source_provenance_invalid")
      end
      local index_expression = expression.args[1].value
      local index = index_expression.kind == "number" and index_expression.value or nil
      if type(index) ~= "number" or index ~= math.floor(index) or index < 0 then
        staged_parse_job_error("staged_source_provenance_invalid")
      end
      return action_ast.staged_parse_job_direct_text_plan(expression.name, index)
    end
    return nil
  end

  local function staged_parse_job_text_plan(expression)
    local direct = staged_direct_text_plan(expression)
    if direct ~= nil then return direct end
    if expression.kind ~= "call" or expression.name ~= "cat" or #expression.args == 0 then
      staged_parse_job_error("staged_source_provenance_invalid")
    end
    local segments = {}
    for _, argument in ipairs(expression.args) do
      if argument.argument_kind ~= "positional" then
        staged_parse_job_error("staged_source_provenance_invalid")
      end
      local nested = staged_parse_job_text_plan(argument.value)
      if nested.kind == "direct_span" then
        segments[#segments + 1] = nested
      else
        for _, segment in ipairs(nested.segments) do segments[#segments + 1] = segment end
      end
    end
    if #segments == 0 then staged_parse_job_error("staged_source_provenance_invalid") end
    return action_ast.staged_parse_job_derived_text_plan(segments)
  end

  local function staged_parse_job_assignment(text, start_byte, target, value)
    if value.kind ~= "call" or value.name ~= "parse_job" then return nil end
    if #value.args ~= 2 or value.args[1].argument_kind ~= "positional" or
        value.args[2].argument_kind ~= "positional" then
      staged_parse_job_error("staged_parse_job_options_required")
    end
    return action_ast.expr(
      "staged_parse_job_marker",
      text,
      span(start_byte, start_byte + #text),
      {
        target = target,
        version = 2,
        sidecar_kind = "staged_parse_job_v2",
        effect = "staged_parse_job_declaration",
        text_plan = staged_parse_job_text_plan(value.args[1].value),
        options = staged_parse_job_options(value.args[2].value),
      }
    )
  end

  local function parse_assignment(text, start_byte)
    local append_position = find_top_level_token(text, "+=")
    if append_position then
      local name = text:sub(1, append_position - 1):match("^%s*([A-Za-z_][A-Za-z0-9_]*)%s*$")
      if name then
        local value_text, value_start = trim_offsets(text:sub(append_position + 2), start_byte + append_position + 1)
        return action_ast.expr("assign_array_append", text, span(start_byte, start_byte + #text), {
          name = name,
          value = parse_expression(value_text, value_start),
        })
      end
    end
    local equals = find_assignment_equals(text) or find_unclosed_nested_write_assignment_equals(text)
    if not equals then
      return nil
    end
    local left, left_start = trim_offsets(text:sub(1, equals - 1), start_byte)
    local right, right_start = trim_offsets(text:sub(equals + 1), start_byte + equals)
    local nested_target = parse_nested_write_target(left, left_start)
    if nested_target then
      return action_ast.expr("assign_nested_access", text, span(start_byte, start_byte + #text), {
        base = nested_target.base,
        segments = nested_target.segments,
        value = parse_expression(right, right_start),
      })
    end
    local value = parse_expression(right, right_start)
    local name = left:match("^([A-Za-z_][A-Za-z0-9_]*)$")
    if name then
      local staged = staged_parse_job_assignment(text, start_byte, name, value)
      if staged ~= nil then return staged end
      if value.kind == "call" and value.name == "dispatch_span" then
        local function progressive_error(code)
          error("LINKEDSPEC_PROGRESSIVE_SPAN_DISPATCH_ERROR:" .. code, 0)
        end
        if #value.args ~= 3 then progressive_error("progressive_span_binding_required") end
        for _, argument in ipairs(value.args) do
          if argument.argument_kind ~= "positional" then
            progressive_error("progressive_span_binding_required")
          end
        end
        local parser_operand = value.args[1].value
        if parser_operand.kind ~= "string" then
          progressive_error("progressive_parser_identity_literal_required")
        end
        if not parser_operand.value:match("^[a-z][a-z0-9]*[a-z0-9._:-]*$") or
            parser_operand.value:match("[._:-][._:-]") or
            parser_operand.value:match("[._:-]$") then
          progressive_error("progressive_parser_identity_invalid")
        end
        local top_operand = value.args[2].value
        if top_operand.kind ~= "string" then
          progressive_error("progressive_top_rule_literal_required")
        end
        if not top_operand.value:match("^[A-Za-z_][A-Za-z0-9_]*$") then
          progressive_error("progressive_top_rule_invalid")
        end
        local span_operand = value.args[3].value
        if span_operand.kind ~= "variable" then
          progressive_error("progressive_span_binding_required")
        end
        return action_ast.expr(
          "progressive_dispatch_span",
          text,
          span(start_byte, start_byte + #text),
          {
            target = name,
            parser_id = parser_operand.value,
            top_rule = top_operand.value,
            span = span_operand.name,
          }
        )
      end
      return action_ast.expr("assign_scalar", text, span(start_byte, start_byte + #text), {
        name = name,
        value = value,
      })
    end
    local target = parse_access(left, left_start)
    if target and target.kind == "indexed_var" then
      return action_ast.expr("assign_hash_index", text, span(start_byte, start_byte + #text), {
        name = target.name,
        key = target.index,
        value = value,
      })
    end
    return nil
  end

  local function split_fluent(text, start_byte)
    local pieces = {}
    local state = scan_state()
    local segment_start = 1
    for position = 1, #text do
      local character = text:sub(position, position)
      local previous_byte = text:byte(position - 1)
      local next_position = skip_space(text, position + 1)
      local next_byte = text:byte(next_position)
      local decimal_point = previous_byte and next_byte and
        previous_byte >= 48 and previous_byte <= 57 and next_byte >= 48 and next_byte <= 57
      if top_level(state) and character == "." and not decimal_point and is_word_byte(next_byte) then
        local piece, piece_start, piece_end = trim_offsets(
          text:sub(segment_start, position - 1),
          start_byte + segment_start - 1
        )
        if piece ~= "" then
          pieces[#pieces + 1] = { text = piece, start = piece_start, ["end"] = piece_end }
        end
        segment_start = position + 1
      else
        consume_scan(state, text, position)
      end
    end
    local piece, piece_start, piece_end = trim_offsets(text:sub(segment_start), start_byte + segment_start - 1)
    if piece ~= "" then
      pieces[#pieces + 1] = { text = piece, start = piece_start, ["end"] = piece_end }
    end
    return pieces
  end

  local function parse_fluent_call(segment, allow_bare_identifier)
    local attached = split_attached_block(segment.text)
    local head = attached and segment.text:sub(1, attached.open_position - 1) or segment.text
    head = head:match("^%s*(.-)%s*$")
    local callee = parse_callee(head, segment.start)
    if not callee then
      if attached or not allow_bare_identifier then
        return nil
      end
      local method = head:match("^([A-Za-z_][A-Za-z0-9_]*)$")
      if not method then
        return nil
      end
      callee = { name = method, payload = "", payload_start = segment.start + #head }
    end
    local args = parse_arguments(callee.payload, callee.payload_start)
    local fields = {}
    if attached then
      local block_source = segment.text:sub(attached.open_position, attached.close_position)
      args[#args + 1] = action_ast.positional_argument(action_ast.expr(
        "block_value",
        block_source,
        span(segment.start + attached.open_position - 1, segment.start + attached.close_position),
        { block = parse_block(attached.body, segment.start + attached.open_position) }
      ))
      fields.trailing_block_arg = true
      fields.receiver_trailing_block_arg = true
      fields.trailing_block_source_span = span(
        segment.start + attached.open_position - 1,
        segment.start + attached.close_position
      )
    end
    return action_ast.fluent_call(
      callee.name,
      args,
      segment.text,
      span(segment.start, segment["end"]),
      fields
    )
  end

  local CONTROL_CANONICAL = {
    ["if"]="if", i="if", when="if", ["elseif"]="elseif", elif="elseif",
    ["else"]="else", otherwise="else", ["while"]="while", switch="switch",
    ["case"]="case", default="default", endif="endif", endcase="endcase", endswitch="endswitch",
  }

  local function parse_control(text, start_byte)
    local attached = split_attached_block(text)
    local head = attached and text:sub(1, attached.open_position - 1) or text
    head = head:match("^%s*(.-)%s*$")
    if head == "else" or head == "otherwise" or head == "endif" or
        head == "default" or head == "endcase" or head == "endswitch" then
      head = head .. "()"
    end
    local callee = parse_callee(head, start_byte)
    if not callee or not CONTROL_CANONICAL[callee.name] then
      return nil
    end
    local args = parse_arguments(callee.payload, callee.payload_start)
    local body
    local body_span
    if attached then
      body = parse_block(attached.body, start_byte + attached.open_position)
      body_span = span(start_byte + attached.open_position - 1, start_byte + attached.close_position)
    end
    local fields = {
      keyword = callee.name,
      canonical_keyword = CONTROL_CANONICAL[callee.name],
      args = args,
      body = body,
      body_source_span = body_span,
    }
    if callee.name == "if" or callee.name == "i" or callee.name == "when" or
        callee.name == "elseif" or callee.name == "elif" then
      if #args ~= 1 then return nil end
      fields.branch_role = (callee.name == "elseif" or callee.name == "elif") and "elseif" or "if"
      fields.condition = args[1].value
      return action_ast.expr("control_if", text, span(start_byte, start_byte + #text), fields)
    elseif callee.name == "else" or callee.name == "otherwise" then
      if #args ~= 0 then return nil end
      fields.branch_role = "else"
      return action_ast.expr("control_else", text, span(start_byte, start_byte + #text), fields)
    elseif callee.name == "while" then
      if #args ~= 1 then return nil end
      fields.condition = args[1].value
      return action_ast.expr("control_while", text, span(start_byte, start_byte + #text), fields)
    elseif callee.name == "switch" then
      if #args ~= 1 then return nil end
      fields.source_expr = args[1].value
      fields.cases = {}
      if body then
        for _, statement in ipairs(body.statements) do
          if statement.expr.kind == "control_case" then
            fields.cases[#fields.cases + 1] = statement.expr
          elseif statement.expr.kind == "control_default" then
            fields.default = statement.expr
          end
        end
      end
      return action_ast.expr("control_switch", text, span(start_byte, start_byte + #text), fields)
    elseif callee.name == "case" then
      if #args ~= 1 then return nil end
      fields.match = args[1].value
      return action_ast.expr("control_case", text, span(start_byte, start_byte + #text), fields)
    elseif callee.name == "default" then
      if #args ~= 0 then return nil end
      return action_ast.expr("control_default", text, span(start_byte, start_byte + #text), fields)
    else
      if #args ~= 0 or attached then return nil end
      return action_ast.expr("control_" .. callee.name, text, span(start_byte, start_byte + #text), fields)
    end
  end

  local function parse_call(text, start_byte)
    local attached = split_attached_block(text)
    local head = attached and text:sub(1, attached.open_position - 1) or text
    local head_text, head_start = trim_offsets(head, start_byte)
    local callee = parse_callee(head_text, head_start)
    if not callee then return nil end
    local args = parse_arguments(callee.payload, callee.payload_start)
    local function invalid_recognition_form()
      error(
        "LINKEDSPEC_RECOGNITION_TRANSACTION_ERROR:" ..
          "recognition_static_form_required:" .. callee.name,
        0
      )
    end
    local function invalid_recursive_observation(code)
      error("LINKEDSPEC_SOURCE_LOCATION_ERROR:" .. code, 0)
    end
    local function recognition_bare_name(argument)
      if argument ~= nil and argument.argument_kind == "positional" and
          argument.value ~= nil and argument.value.kind == "variable" then
        return argument.value.name
      end
      return nil
    end
    local transaction_expr
    if callee.name == "recognition_checkpoint" then
      if #args ~= 0 then invalid_recognition_form() end
      transaction_expr = action_ast.expr(
        "recognition_checkpoint",
        text,
        span(start_byte, start_byte + #text)
      )
    elseif callee.name == "recognize_once" then
      if #args ~= 2 then invalid_recognition_form() end
      local token = recognition_bare_name(args[1])
      local operand = args[2]
      local call = operand and operand.argument_kind == "positional" and operand.value or nil
      local rule = call and call.kind == "call" and call.name == "call" and
        #call.args == 1 and recognition_bare_name(call.args[1]) or nil
      if token == nil or rule == nil then invalid_recognition_form() end
      transaction_expr = action_ast.expr(
        "recognize_once",
        text,
        span(start_byte, start_byte + #text),
        { token = token, rule = rule }
      )
    elseif callee.name == "observe_recognition" then
      if #args ~= 2 then
        invalid_recursive_observation("source_location_recursive_observation_operand")
      end
      local target = recognition_bare_name(args[1])
      if target == nil then
        invalid_recursive_observation("source_location_recursive_observation_target")
      end
      local operand = args[2]
      local call = operand and operand.argument_kind == "positional" and operand.value or nil
      local rule = call and call.kind == "call" and call.name == "call" and
        #call.args == 1 and recognition_bare_name(call.args[1]) or nil
      if rule == nil then
        invalid_recursive_observation("source_location_recursive_observation_operand")
      end
      transaction_expr = action_ast.expr(
        "observe_recognition",
        text,
        span(start_byte, start_byte + #text),
        { target = target, rule = rule }
      )
    elseif callee.name == "recognition_commit" or callee.name == "recognition_rollback" then
      if #args ~= 1 then invalid_recognition_form() end
      local token = recognition_bare_name(args[1])
      if token == nil then invalid_recognition_form() end
      transaction_expr = action_ast.expr(
        callee.name,
        text,
        span(start_byte, start_byte + #text),
        { token = token }
      )
    end
    if transaction_expr ~= nil then return transaction_expr end
    local fields = { name = callee.name, args = args }
    if attached then
      local block_source = text:sub(attached.open_position, attached.close_position)
      local block_value = action_ast.expr(
        "block_value",
        block_source,
        span(start_byte + attached.open_position - 1, start_byte + attached.close_position),
        { block = parse_block(attached.body, start_byte + attached.open_position) }
      )
      args[#args + 1] = action_ast.positional_argument(block_value)
      fields.trailing_block_arg = true
      fields.trailing_block_source_span = block_value.source_span
    end
    return action_ast.expr("call", text, span(start_byte, start_byte + #text), fields)
  end

  local function parse_value_access(text, start_byte)
    local open_position = text:find("(", 1, true)
    if open_position == nil then return nil end
    local close_position = find_matching(text, open_position, "(", ")")
    if close_position == nil or close_position == #text then return nil end
    local position = skip_space(text, close_position + 1)
    if text:sub(position, position) ~= "[" then return nil end

    local receiver = parse_call(text:sub(1, close_position), start_byte)
    if receiver == nil then return nil end
    local segments = parse_access_segments(text, position, start_byte)
    if segments == nil then return nil end
    return action_ast.expr("value_access", text, span(start_byte, start_byte + #text), {
      receiver = receiver,
      segments = segments,
    })
  end

  parse_expression = function(source, absolute_start)
    local text, start_byte = trim_offsets(source, absolute_start)
    if text == "" then return raw_expr(text, start_byte, "empty_expression") end
    local assignment = parse_assignment(text, start_byte)
    if assignment then return assignment end
    local fluent_segments = split_fluent(text, start_byte)
    if #fluent_segments > 1 then
      local receiver_text = fluent_segments[1].text
      local receiver_start = fluent_segments[1].start
      if outer_balanced(receiver_text, "(", ")") then
        receiver_text, receiver_start = trim_offsets(receiver_text:sub(2, -2), receiver_start + 1)
      end
      local calls = {}
      for index = 2, #fluent_segments do
        local call = parse_fluent_call(fluent_segments[index], index == #fluent_segments)
        if not call then return raw_expr(text, start_byte, "invalid_fluent_chain") end
        calls[#calls + 1] = call
      end
      return action_ast.expr("fluent_chain", text, span(start_byte, start_byte + #text), {
        receiver = parse_expression(receiver_text, receiver_start),
        calls = calls,
      })
    end
    if outer_balanced(text, "(", ")") then
      local inner, inner_start = trim_offsets(text:sub(2, -2), start_byte + 1)
      return parse_expression(inner, inner_start)
    end
    local literal = parse_literal(text, start_byte)
    if literal then return literal end
    if outer_balanced(text, "[", "]") then
      local items = {}
      for _, item in ipairs(split_top_level(text:sub(2, -2), start_byte + 1, { [","] = true })) do
        items[#items + 1] = parse_expression(item.text, item.start)
      end
      return action_ast.expr("array_literal", text, span(start_byte, start_byte + #text), { items = items })
    end
    if outer_balanced(text, "{", "}") then
      local payload = text:sub(2, -2)
      if text:sub(1, 2) == "{|" then return parse_codeblock_literal(text, start_byte) end
      if payload:match("^%s+|") then
        return action_ast.codeblock_literal_error(
          text,
          span(start_byte, start_byte + #text),
          "invalid_codeblock_opener"
        )
      end
      local entries = {}
      local has_separator = false
      for _, part in ipairs(split_top_level(payload, start_byte + 1, { [","] = true })) do
        local separator = find_top_level_token(part.text, ":") or find_top_level_token(part.text, "=>")
        if separator then
          has_separator = true
          local length = part.text:sub(separator, separator + 1) == "=>" and 2 or 1
          if length == 2 then return raw_expr(text, start_byte, "hash_literal_use_colon") end
          local key_text, key_start = trim_offsets(part.text:sub(1, separator - 1), part.start)
          local value_text, value_start = trim_offsets(
            part.text:sub(separator + length),
            part.start + separator + length - 1
          )
          entries[#entries + 1] = action_ast.hash_entry(
            parse_expression(key_text, key_start),
            parse_expression(value_text, value_start)
          )
        end
      end
      if payload:match("^%s*$") or has_separator then
        return action_ast.expr("hash_literal", text, span(start_byte, start_byte + #text), { entries = entries })
      end
      return action_ast.expr("block_value", text, span(start_byte, start_byte + #text), {
        block = parse_block(payload, start_byte + 1),
      })
    end
    local control = parse_control(text, start_byte)
    if control then return control end
    local value_access = parse_value_access(text, start_byte)
    if value_access then return value_access end
    local call = parse_call(text, start_byte)
    if call then return call end
    local access = parse_access(text, start_byte)
    if access then return access end
    return raw_expr(text, start_byte, "unsupported_expression")
  end

  local function reject_residual_staged_call(value)
    if type(value) ~= "table" then return end
    if (value.kind == "call" and value.name == "parse_job") or value.method == "parse_job" then
      staged_parse_job_error("staged_parse_job_options_required")
    end
    for _, child in pairs(value) do reject_residual_staged_call(child) end
  end

  local function parse_statement(text, start_byte, end_byte)
    local expression
    if text == "next" then
      expression = action_ast.expr("call", text, span(start_byte, end_byte), {
        name = "next",
        args = {},
      })
    else
      expression = parse_expression(text, start_byte)
    end
    reject_residual_staged_call(expression)
    return action_ast.statement(text, span(start_byte, end_byte), expression, true)
  end

  parse_block = function(source, absolute_start)
    local statements = {}
    local separators = { [";"] = true, ["\n"] = true, ["\r"] = true, branch = true }
    for _, piece in ipairs(split_top_level(source, absolute_start, separators)) do
      statements[#statements + 1] = parse_statement(piece.text, piece.start, piece["end"])
    end
    return action_ast.block(source, span(absolute_start, absolute_start + #source), statements)
  end

  return {
    parse_expression = function(source)
      local expression = parse_expression(source, 1)
      reject_residual_staged_call(expression)
      return expression
    end,
    parse_statement = function(source)
      local text, start_byte, end_byte = trim_offsets(source, 1)
      return parse_statement(text, start_byte, end_byte)
    end,
    parse_block = function(source) return parse_block(source, 1) end,
  }
end

function M.parse_action_expression(source)
  if type(source) ~= "string" then error("ActionParseException: source must be a string", 0) end
  return parser(source).parse_expression(source)
end

function M.parse_action_expression_at(source, start_position)
  if type(source) ~= "string" then error("ActionParseException: source must be a string", 0) end
  if type(start_position) ~= "number" or start_position % 1 ~= 0 or start_position < 0 then
    error("ActionParseException: start position must be a nonnegative integer", 0)
  end
  local padded = string.rep(" ", start_position) .. source
  local block = parser(padded).parse_block(padded)
  if #block.statements ~= 1 then
    error("ActionParseException: offset expression must remain one statement", 0)
  end
  return block.statements[1].expr
end

function M.parse_action_statement(source)
  if type(source) ~= "string" then error("ActionParseException: source must be a string", 0) end
  return parser(source).parse_statement(source)
end

function M.parse_action_block(source)
  if type(source) ~= "string" then error("ActionParseException: source must be a string", 0) end
  return parser(source).parse_block(source)
end

return M
