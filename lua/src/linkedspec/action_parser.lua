local action_ast = require("linkedspec.action_ast")
local json = require("linkedspec.json")

local M = {}

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
      if before ~= "=" and before ~= "!" and before ~= "<" and before ~= ">" and after ~= "=" and after ~= ">" then
        return position
      end
    end
    consume_scan(state, text, position)
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
      local expression = parse_expression(part.text, part.start)
      local equals = find_assignment_equals(part.text)
      if equals and expression.kind ~= "assign_scalar" then
        local name = part.text:sub(1, equals - 1):match("^%s*([A-Za-z_][A-Za-z0-9_]*)%s*$")
        if name then
          local value_text, value_start = trim_offsets(
            part.text:sub(equals + 1),
            part.start + equals
          )
          args[#args + 1] = action_ast.keyword_argument(name, parse_expression(value_text, value_start))
        else
          args[#args + 1] = action_ast.positional_argument(expression)
        end
      else
        args[#args + 1] = action_ast.positional_argument(expression)
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

  local function parse_access(text, start_byte)
    local prefix, name = text:match("^(%$?)([A-Za-z_][A-Za-z0-9_]*)")
    if not name then
      return nil
    end
    local position = #prefix + #name + 1
    position = skip_space(text, position)
    if position > #text then
      return action_ast.expr("variable", text, span(start_byte, start_byte + #text), { name = name })
    end
    local segments = {}
    while position <= #text do
      if text:sub(position, position) ~= "[" then
        return nil
      end
      local close_position = find_matching(text, position, "[", "]")
      if not close_position then
        return nil
      end
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
    local equals = find_assignment_equals(text)
    if not equals then
      return nil
    end
    local left, left_start = trim_offsets(text:sub(1, equals - 1), start_byte)
    local right, right_start = trim_offsets(text:sub(equals + 1), start_byte + equals)
    local value = parse_expression(right, right_start)
    local name = left:match("^([A-Za-z_][A-Za-z0-9_]*)$")
    if name then
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
    elseif target and target.kind == "nested_access" then
      if #target.segments == 1 then
        local segment = target.segments[1]
        local key = segment.kind == "key" and action_ast.expr(
          "string", segment.source, segment.source_span, { value = segment.value, quote = '"' }
        ) or segment.expr
        return action_ast.expr("assign_hash_index", text, span(start_byte, start_byte + #text), {
          name = target.base,
          key = key,
          value = value,
        })
      end
      return action_ast.expr("assign_nested_access", text, span(start_byte, start_byte + #text), {
        base = target.base,
        segments = target.segments,
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

  local function parse_fluent_call(segment)
    local attached = split_attached_block(segment.text)
    local head = attached and segment.text:sub(1, attached.open_position - 1) or segment.text
    head = head:match("^%s*(.-)%s*$")
    local callee = parse_callee(head, segment.start)
    if not callee then
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
    if head == "else" or head == "otherwise" or head == "default" then
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
        local call = parse_fluent_call(fluent_segments[index])
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
    local call = parse_call(text, start_byte)
    if call then return call end
    local access = parse_access(text, start_byte)
    if access then return access end
    return raw_expr(text, start_byte, "unsupported_expression")
  end

  parse_block = function(source, absolute_start)
    local statements = {}
    local separators = { [";"] = true, ["\n"] = true, ["\r"] = true, branch = true }
    for _, piece in ipairs(split_top_level(source, absolute_start, separators)) do
      local expression = parse_expression(piece.text, piece.start)
      statements[#statements + 1] = action_ast.statement(
        piece.text,
        span(piece.start, piece["end"]),
        expression,
        true
      )
    end
    return action_ast.block(source, span(absolute_start, absolute_start + #source), statements)
  end

  return {
    parse_expression = function(source) return parse_expression(source, 1) end,
    parse_statement = function(source)
      local text, start_byte, end_byte = trim_offsets(source, 1)
      return action_ast.statement(text, span(start_byte, end_byte), parse_expression(text, start_byte), true)
    end,
    parse_block = function(source) return parse_block(source, 1) end,
  }
end

function M.parse_action_expression(source)
  if type(source) ~= "string" then error("ActionParseException: source must be a string", 0) end
  return parser(source).parse_expression(source)
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
