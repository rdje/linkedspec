local ast = require("linkedspec.spec_ast")
local json = require("linkedspec.json")

local M = {}

local PARSE_ERROR_MT = {
  __tostring = function(value)
    return "SpecParseException(line " .. value.line .. "): " .. value.message
  end,
}

local function parse_fail(line, message)
  error(M.new_parse_error(line, message), 0)
end

function M.is_parse_error(value)
  return getmetatable(value) == PARSE_ERROR_MT
end

function M.new_parse_error(line, message)
  return setmetatable({ line = line, message = message }, PARSE_ERROR_MT)
end

local function trim(value)
  return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function ltrim(value)
  return (value:gsub("^%s+", ""))
end

local function split_lines(source)
  local lines = {}
  local start = 1
  while true do
    local ending = source:find("\n", start, true)
    if not ending then
      lines[#lines + 1] = source:sub(start)
      return lines
    end
    lines[#lines + 1] = source:sub(start, ending - 1)
    start = ending + 1
  end
end

local function is_word_byte(byte)
  return byte ~= nil and (
    (byte >= 0x30 and byte <= 0x39) or
    (byte >= 0x41 and byte <= 0x5A) or
    (byte >= 0x61 and byte <= 0x7A) or
    byte == 0x5F
  )
end

local function skip_spaces(text, position)
  while position <= #text do
    local byte = text:byte(position)
    if byte ~= 0x20 and byte ~= 0x09 and byte ~= 0x0A and byte ~= 0x0D then
      break
    end
    position = position + 1
  end
  return position
end

local function read_word(text, position)
  local start = position
  while is_word_byte(text:byte(position)) do
    position = position + 1
  end
  if position == start then
    return nil, start
  end
  return text:sub(start, position - 1), position
end

local function parse_bounded_mode(raw)
  local base
  local inside
  if raw:sub(1, 4) == "AND{" and raw:sub(-1) == "}" then
    base = "AND"
    inside = raw:sub(5, -2)
  elseif raw:sub(1, 3) == "OR{" and raw:sub(-1) == "}" then
    base = "OR"
    inside = raw:sub(4, -2)
  else
    return nil
  end

  local min_text
  local max_text
  local comma = inside:find(",", 1, true)
  if comma then
    if inside:find(",", comma + 1, true) then
      return nil
    end
    min_text = inside:sub(1, comma - 1)
    max_text = inside:sub(comma + 1)
  else
    min_text = inside
    max_text = false
  end
  if not min_text:match("^%d*$") or (max_text ~= false and not max_text:match("^%d*$")) then
    return nil
  end
  local minimum = min_text == "" and 0 or tonumber(min_text)
  local maximum
  if max_text == false then
    maximum = minimum
  elseif max_text == "" then
    maximum = nil
  else
    maximum = tonumber(max_text)
    if maximum < minimum then
      return nil
    end
  end
  return base, minimum, maximum
end

local function parse_mode(raw)
  if raw == "" then
    return ast.default_rule_mode()
  end
  local base, minimum, maximum = parse_bounded_mode(raw)
  if base == "AND" then
    return ast.and_bounded_rule_mode({ min = minimum, max = maximum })
  elseif base == "OR" then
    return ast.or_bounded_rule_mode({ min = minimum, max = maximum })
  end
  local names = {
    AND = "And",
    ["AND+"] = "AndPlus",
    OR = "Or",
    ["OR+"] = "OrPlus",
    ["&"] = "Single",
    ["|"] = "Pipe",
    ["+"] = "Plus",
    ["*"] = "Star",
    ["?"] = "Optional",
  }
  local name = names[raw]
  return name and ast.rule_mode(name) or nil
end

local function skip_blanks_and_comments(lines, index)
  while index <= #lines do
    local text = trim(lines[index])
    if text == "" or text:sub(1, 1) == "#" then
      index = index + 1
    else
      break
    end
  end
  return index
end

local function parse_header(lines, index)
  if index > #lines then
    return nil
  end
  local text = trim(lines[index])
  local label, colon, mode_raw, rest_raw = text:match("^([%w_]+)[ \t]*(::?)[ \t]*([^%s/]*)[ \t]*(.*)$")
  if not label then
    return nil
  end
  local mode = parse_mode(mode_raw)
  local rest
  if mode == nil then
    mode = ast.default_rule_mode()
    rest = rest_raw == "" and mode_raw or mode_raw .. " " .. rest_raw
  else
    rest = rest_raw
  end
  return {
    header = ast.rule_header({
      label = label,
      is_top = colon == "::",
      mode = mode,
      rest = rest,
      line = index,
    }),
    next_index = index + 1,
  }
end

local function looks_like_header(text)
  return trim(text):match("^[%w_]+[ \t]*::?") ~= nil
end

local function scan_quoted(text, position, quote)
  position = position + 1
  while position <= #text do
    local byte = text:byte(position)
    if byte == 0x5C then
      position = position + 2
    elseif byte == quote then
      return position + 1
    else
      position = position + 1
    end
  end
  return nil
end

local function scan_regex(text, position)
  position = position + 1
  while position <= #text do
    local byte = text:byte(position)
    if byte == 0x5C then
      position = position + 2
    elseif byte == 0x2F then
      position = position + 1
      while position <= #text do
        local flag = text:byte(position)
        if not ((flag >= 0x41 and flag <= 0x5A) or (flag >= 0x61 and flag <= 0x7A)) then
          break
        end
        position = position + 1
      end
      return position
    else
      position = position + 1
    end
  end
  return nil
end

local function extract_parentheses(text, open_position)
  if text:sub(open_position, open_position) ~= "(" then
    return nil
  end
  local depth = 1
  local position = open_position + 1
  while position <= #text do
    local byte = text:byte(position)
    if byte == 0x22 or byte == 0x27 then
      local next_position = scan_quoted(text, position, byte)
      if not next_position then
        return nil
      end
      position = next_position
    elseif byte == 0x2F then
      position = scan_regex(text, position) or position + 1
    elseif byte == 0x28 then
      depth = depth + 1
      position = position + 1
    elseif byte == 0x29 then
      depth = depth - 1
      if depth == 0 then
        return {
          content = text:sub(open_position + 1, position - 1),
          close_position = position,
        }
      end
      position = position + 1
    else
      position = position + 1
    end
  end
  return nil
end

local function parse_fluent_chain(text)
  local calls = {}
  local position = skip_spaces(text, 1)
  while text:sub(position, position) == "." do
    position = skip_spaces(text, position + 1)
    local method
    method, position = read_word(text, position)
    if not method then
      break
    end
    position = skip_spaces(text, position)
    local args = ""
    if text:sub(position, position) == "(" then
      local parentheses = extract_parentheses(text, position)
      if not parentheses then
        calls[#calls + 1] = ast.fluent_call({ method = method, args = "" })
        return { calls = calls, remainder = "" }
      end
      args = parentheses.content
      position = skip_spaces(text, parentheses.close_position + 1)
    end
    calls[#calls + 1] = ast.fluent_call({ method = method, args = args })
  end
  return { calls = calls, remainder = ltrim(text:sub(position)) }
end

local function fluent_parentheses_complete(text)
  local position = skip_spaces(text, 1)
  if text:sub(position, position) ~= "." then
    return true
  end
  while position <= #text do
    if text:sub(position, position) ~= "." then
      return true
    end
    position = skip_spaces(text, position + 1)
    local method
    method, position = read_word(text, position)
    if not method then
      return true
    end
    position = skip_spaces(text, position)
    if text:sub(position, position) ~= "(" then
      return true
    end
    local parentheses = extract_parentheses(text, position)
    if not parentheses then
      return false
    end
    position = skip_spaces(text, parentheses.close_position + 1)
  end
  return true
end

local function scan_braces(text, initial_depth)
  local depth = initial_depth
  local position = 1
  while position <= #text do
    local byte = text:byte(position)
    if byte == 0x22 or byte == 0x27 then
      position = scan_quoted(text, position, byte) or (#text + 1)
    elseif byte == 0x7B then
      depth = depth + 1
      position = position + 1
    elseif byte == 0x7D then
      depth = depth - 1
      position = position + 1
      if depth == 0 then
        return { text = text:sub(1, position - 1), depth = 0 }
      end
    else
      position = position + 1
    end
  end
  return { text = text, depth = depth }
end

local function consume_block(lines, cursor, rest)
  local start_brace = rest:find("{", 1, true)
  if not start_brace then
    return nil
  end
  local after_open = rest:sub(start_brace + 1)
  local depth = 1
  local content = ""
  local scanned = scan_braces(after_open, depth)
  depth = scanned.depth
  if depth == 0 then
    local block_text = scanned.text:sub(1, -2)
    return {
      code = trim(block_text),
      remainder = trim(after_open:sub(#scanned.text + 1)),
    }
  end
  if trim(scanned.text) ~= "" then
    content = trim(scanned.text)
  end

  cursor.index = cursor.index + 1
  while cursor.index <= #lines and depth > 0 do
    local line = lines[cursor.index]
    scanned = scan_braces(line, depth)
    depth = scanned.depth
    if depth == 0 then
      local before_close = scanned.text:sub(1, -2)
      if trim(before_close) ~= "" then
        if content ~= "" then
          content = content .. "\n"
        end
        content = content .. trim(before_close)
      end
      cursor.index = cursor.index + 1
      return {
        code = trim(content),
        remainder = trim(line:sub(#scanned.text + 1)),
      }
    end
    if content ~= "" then
      content = content .. "\n"
    end
    content = content .. trim(line)
    cursor.index = cursor.index + 1
  end
  return { code = trim(content), remainder = "" }
end

local function strip_keyword(text, keyword, require_dot)
  local position = skip_spaces(text, 1)
  if require_dot then
    if text:sub(position, position) ~= "." then
      return nil
    end
    position = skip_spaces(text, position + 1)
  elseif text:sub(position, position) == "." then
    position = skip_spaces(text, position + 1)
  end
  if text:sub(position, position + #keyword - 1) ~= keyword then
    return nil
  end
  local after = position + #keyword
  if is_word_byte(text:byte(after)) then
    return nil
  end
  return text:sub(after)
end

local function block_remainder_origin(start_index, end_index, remainder)
  if trim(remainder) ~= "" and end_index > start_index then
    return end_index - 1
  end
  return end_index
end

local function parse_attached_when(lines, cursor, rest)
  local after_when = strip_keyword(rest, "when", true)
  if not after_when then
    return nil
  end
  local position = skip_spaces(after_when, 1)
  if after_when:sub(position, position) ~= "(" then
    return nil
  end
  local condition = extract_parentheses(after_when, position)
  if not condition then
    return nil
  end
  local remaining = ltrim(after_when:sub(condition.close_position + 1))
  if remaining:sub(1, 1) ~= "{" then
    return nil
  end

  local when_start = cursor.index
  local when_body = consume_block(lines, cursor, remaining)
  if not when_body then
    return nil
  end
  local code = "when(" .. trim(condition.content) .. ") { " .. trim(when_body.code) .. " }"
  remaining = when_body.remainder
  local origin = block_remainder_origin(when_start, cursor.index, remaining)

  while true do
    local after_otherwise = strip_keyword(remaining, "otherwise", false)
    if not after_otherwise then
      break
    end
    after_otherwise = ltrim(after_otherwise)
    if after_otherwise:sub(1, 1) ~= "{" then
      break
    end
    local floor_index = cursor.index
    local block_cursor = { index = origin }
    local otherwise_body = consume_block(lines, block_cursor, after_otherwise)
    if not otherwise_body then
      break
    end
    code = code .. " otherwise { " .. trim(otherwise_body.code) .. " }"
    remaining = otherwise_body.remainder
    cursor.index = math.max(floor_index, block_cursor.index)
    if trim(remaining) == "" then
      origin = cursor.index
    else
      origin = block_remainder_origin(origin, block_cursor.index, remaining)
    end
  end
  return { code = code, remainder = ltrim(remaining) }
end

local function parse_regex_element(text, line_number)
  if text:sub(1, 1) ~= "/" then
    return nil
  end
  local close_position = scan_regex(text, 1)
  if not close_position then
    return nil
  end
  local slash_position = close_position - 1
  while slash_position > 1 and text:sub(slash_position, slash_position):match("[A-Za-z]") do
    slash_position = slash_position - 1
  end
  if text:sub(slash_position, slash_position) ~= "/" then
    return nil
  end
  local full_match = text:sub(1, slash_position)
  return {
    element = ast.body_element({
      kind = ast.regex_body_kind({ pattern = text:sub(2, slash_position - 1) }),
      source = full_match,
      line = line_number,
    }),
    remainder = text:sub(slash_position + 1),
    advanced = false,
  }
end

local function parse_action_prefix(text)
  if text:sub(1, 2) ~= "->" then
    return nil
  end
  local position = skip_spaces(text, 3)
  local labels = {}
  local label
  label, position = read_word(text, position)
  if not label then
    return nil
  end
  labels[#labels + 1] = label
  while true do
    local before_pipe = position
    position = skip_spaces(text, position)
    if text:sub(position, position) ~= "|" then
      position = before_pipe
      break
    end
    position = skip_spaces(text, position + 1)
    label, position = read_word(text, position)
    if not label then
      return nil
    end
    labels[#labels + 1] = label
  end
  position = skip_spaces(text, position)
  local target_index = 0
  if text:sub(position, position) == "[" then
    local closing = text:find("]", position + 1, true)
    if not closing then
      return nil
    end
    local digits = text:sub(position + 1, closing - 1)
    if not digits:match("^%d+$") then
      return nil
    end
    target_index = tonumber(digits)
    position = closing + 1
  end
  local targets = {}
  for index, target_label in ipairs(labels) do
    targets[index] = ast.edge_target({ label = target_label, index = target_index })
  end
  return {
    targets = targets,
    full_match = trim(text:sub(1, position - 1)),
    rest = ltrim(text:sub(position)),
  }
end

local function parse_lifecycle_prefix(text)
  local markers = { "LS", "LE", "LX", "EX", "IT", "I", "E" }
  for _, marker in ipairs(markers) do
    if text:sub(1, #marker) == marker and not is_word_byte(text:byte(#marker + 1)) then
      return marker, text:sub(1, #marker), ltrim(text:sub(#marker + 1))
    end
  end
  return nil
end

local function lifecycle_fluent_code(lines, cursor, rest)
  local start_index = cursor.index
  local text = ltrim(rest)
  if text:sub(1, 1) ~= "." then
    return nil
  end
  while not fluent_parentheses_complete(text) do
    if cursor.index + 1 > #lines then
      return nil
    end
    cursor.index = cursor.index + 1
    text = text .. "\n" .. trim(lines[cursor.index])
  end
  local parsed = parse_fluent_chain(text)
  if #parsed.calls == 0 then
    return nil
  end
  local statements = {}
  for index, call in ipairs(parsed.calls) do
    if trim(call.method) == "" then
      return nil
    end
    statements[index] = trim(call.method) .. "(" .. trim(call.args) .. ")"
  end
  local advanced = cursor.index > start_index
  if advanced then
    cursor.index = cursor.index + 1
  end
  return {
    code = table.concat(statements, "; "),
    remainder = parsed.remainder,
    advanced = advanced,
  }
end

local function parse_single_element(text, lines, cursor, line_number)
  local regex = parse_regex_element(text, line_number)
  if regex then
    return regex
  end

  local action = parse_action_prefix(text)
  if action then
    local saved_index = cursor.index
    local attached = parse_attached_when(lines, cursor, action.rest)
    if attached then
      return {
        element = ast.body_element({
          kind = ast.action_edge_body_kind({ targets = action.targets, code = attached.code }),
          source = action.full_match,
          line = line_number,
        }),
        remainder = attached.remainder,
        advanced = cursor.index > saved_index,
      }
    end
    if action.rest:sub(1, 1) == "{" then
      local block = consume_block(lines, cursor, action.rest)
      if not block then
        return nil
      end
      return {
        element = ast.body_element({
          kind = ast.action_edge_body_kind({ targets = action.targets, code = block.code }),
          source = action.full_match,
          line = line_number,
        }),
        remainder = block.remainder,
        advanced = cursor.index > saved_index,
      }
    end
    local fluent = parse_fluent_chain(action.rest)
    return {
      element = ast.body_element({
        kind = ast.action_edge_body_kind({ targets = action.targets, fluent_chain = fluent.calls }),
        source = action.full_match,
        line = line_number,
      }),
      remainder = fluent.remainder,
      advanced = false,
    }
  end

  if text:sub(1, 2) == "=>" then
    local position = skip_spaces(text, 3)
    local target
    target, position = read_word(text, position)
    if target then
      local full_match = trim(text:sub(1, position - 1))
      local rest = ltrim(text:sub(position))
      local saved_index = cursor.index
      local code
      local fluent_chain = {}
      local remainder
      if rest:sub(1, 1) == "{" then
        local block = consume_block(lines, cursor, rest)
        if not block then
          return nil
        end
        code = block.code
        remainder = block.remainder
      else
        local fluent = parse_fluent_chain(rest)
        fluent_chain = fluent.calls
        remainder = fluent.remainder
      end
      return {
        element = ast.body_element({
          kind = ast.blind_edge_body_kind({ target = target, code = code, fluent_chain = fluent_chain }),
          source = full_match,
          line = line_number,
        }),
        remainder = remainder,
        advanced = cursor.index > saved_index,
      }
    end
  end

  local marker, full_match, lifecycle_rest = parse_lifecycle_prefix(text)
  if marker then
    local saved_index = cursor.index
    local attached = parse_attached_when(lines, cursor, lifecycle_rest)
    if attached then
      return {
        element = ast.body_element({
          kind = ast.code_block_body_kind({ lifecycle = marker, code = attached.code }),
          source = full_match,
          line = line_number,
        }),
        remainder = attached.remainder,
        advanced = cursor.index > saved_index,
      }
    end
    if lifecycle_rest:sub(1, 1) == "{" then
      local block = consume_block(lines, cursor, lifecycle_rest)
      if not block then
        return nil
      end
      return {
        element = ast.body_element({
          kind = ast.code_block_body_kind({ lifecycle = marker, code = block.code }),
          source = full_match,
          line = line_number,
        }),
        remainder = block.remainder,
        advanced = cursor.index > saved_index,
      }
    end
    local fluent = lifecycle_fluent_code(lines, cursor, lifecycle_rest)
    if fluent then
      return {
        element = ast.body_element({
          kind = ast.code_block_body_kind({ lifecycle = marker, code = fluent.code }),
          source = full_match,
          line = line_number,
        }),
        remainder = fluent.remainder,
        advanced = fluent.advanced,
      }
    end
    return {
      element = ast.body_element({
        kind = ast.lifecycle_marker_body_kind({ marker = marker }),
        source = full_match,
        line = line_number,
      }),
      remainder = lifecycle_rest,
      advanced = false,
    }
  end

  local split_marker = text:match("^@[ \t]*(capture_slice)") or
    text:match("^@[ \t]*(capture_from_here)") or
    text:match("^@[ \t]*(move_pos)")
  local split_full
  if split_marker then
    split_full = text:match("^@[ \t]*" .. split_marker)
  else
    split_full = text:match("^@[ \t]*mark[ \t]*%([ \t]*[%w_]+[ \t]*%)")
  end
  if split_full then
    return {
      element = ast.body_element({
        kind = ast.split_marker_body_kind({ marker = split_full }),
        source = split_full,
        line = line_number,
      }),
      remainder = text:sub(#split_full + 1),
      advanced = false,
    }
  end

  local conditional = text:match("^%-%?[ \t]+([%w_]+)")
  if conditional then
    local conditional_full = text:match("^%-%?[ \t]+[%w_]+")
    return {
      element = ast.body_element({
        kind = ast.conditional_body_kind({ word = conditional }),
        source = conditional_full,
        line = line_number,
      }),
      remainder = text:sub(#conditional_full + 1),
      advanced = false,
    }
  end

  if text:match("^%.[ \t]*[%w_]+") then
    local fluent = parse_fluent_chain(text)
    return {
      element = ast.body_element({
        kind = ast.fluent_chain_body_kind({ calls = fluent.calls }),
        source = text:match("^%.[ \t]*[%w_]+"),
        line = line_number,
      }),
      remainder = "",
      advanced = false,
    }
  end

  if text:sub(1, 1) == "{" then
    local saved_index = cursor.index
    local block = consume_block(lines, cursor, text)
    if not block then
      return nil
    end
    return {
      element = ast.body_element({
        kind = ast.plain_block_body_kind({ code = block.code }),
        source = text,
        line = line_number,
      }),
      remainder = block.remainder,
      advanced = cursor.index > saved_index,
    }
  end
  return nil
end

local function parse_body_elements(lines, cursor)
  local elements = {}
  local line_number = cursor.index
  local remaining = trim(lines[cursor.index])
  local advanced = false
  while true do
    local text = trim(remaining)
    if text == "" or text:sub(1, 1) == "#" then
      break
    end
    local parsed = parse_single_element(text, lines, cursor, line_number)
    if not parsed then
      break
    end
    elements[#elements + 1] = parsed.element
    remaining = parsed.remainder
    if parsed.advanced then
      advanced = true
    end
    if trim(remaining) == "" then
      break
    end
  end
  if #elements > 0 and not advanced then
    cursor.index = cursor.index + 1
  end
  return elements
end

local function collect_action_fluent_lines(lines, cursor, elements)
  if #elements == 0 then
    return
  end
  local kind = elements[#elements].kind
  if ast.node_type(kind) ~= "ActionEdgeBodyElementKind" then
    return
  end
  while cursor.index <= #lines do
    local text = trim(lines[cursor.index])
    if text == "" or text:sub(1, 1) == "#" or text:sub(1, 1) ~= "." then
      break
    end
    local fluent = parse_fluent_chain(text)
    local remainder = trim(fluent.remainder)
    if #fluent.calls == 0 or (remainder ~= "" and remainder:sub(1, 1) ~= "#") then
      break
    end
    for _, call in ipairs(fluent.calls) do
      kind.fluent_chain[#kind.fluent_chain + 1] = call
    end
    cursor.index = cursor.index + 1
  end
end

local function collect_body(lines, start_index)
  local body = {}
  local cursor = { index = start_index }
  while cursor.index <= #lines do
    local text = trim(lines[cursor.index])
    local line_number = cursor.index
    if text == "" or text:sub(1, 1) == "#" then
      cursor.index = cursor.index + 1
    elseif looks_like_header(text) then
      break
    else
      local elements = parse_body_elements(lines, cursor)
      collect_action_fluent_lines(lines, cursor, elements)
      if #elements == 0 then
        body[#body + 1] = ast.body_element({
          kind = ast.raw_body_kind({ text = text }),
          source = text,
          line = line_number,
        })
        cursor.index = cursor.index + 1
      else
        for _, element in ipairs(elements) do
          body[#body + 1] = element
        end
      end
    end
  end
  return { body = body, next_index = cursor.index }
end

local function parse_inline_body(rest, line_number, lines, cursor)
  local elements = {}
  local remaining = trim(rest)
  while remaining ~= "" do
    local text = trim(remaining)
    if text == "" or text:sub(1, 1) == "#" then
      break
    end
    local before = text
    local parsed = parse_single_element(text, lines, cursor, line_number)
    if not parsed then
      break
    end
    elements[#elements + 1] = parsed.element
    remaining = parsed.remainder
    if trim(remaining) == before then
      break
    end
  end
  return #elements == 0 and nil or elements
end

function M.parse_spec(source)
  if type(source) ~= "string" then
    parse_fail(1, "source must be a string")
  end
  local valid_utf8, invalid_position = json.validate_utf8(source)
  if not valid_utf8 then
    parse_fail(1, "source is not valid UTF-8 at byte " .. invalid_position)
  end
  local lines = split_lines(source)
  local rules = {}
  local index = skip_blanks_and_comments(lines, 1)
  while index <= #lines do
    local parsed_header = parse_header(lines, index)
    if parsed_header then
      local header = parsed_header.header
      local body_start = parsed_header.next_index
      local inline_elements = {}
      if trim(header.rest) ~= "" then
        local inline_cursor = { index = header.line }
        inline_elements = parse_inline_body(header.rest, header.line, lines, inline_cursor) or {}
        if inline_cursor.index > body_start then
          body_start = inline_cursor.index
        end
      end
      local collected = collect_body(lines, body_start)
      local body = {}
      for _, element in ipairs(inline_elements) do
        body[#body + 1] = element
      end
      for _, element in ipairs(collected.body) do
        body[#body + 1] = element
      end
      rules[#rules + 1] = ast.rule({ header = header, body = body })
      index = collected.next_index
    else
      if #rules == 0 then
        parse_fail(
          index,
          "expected rule definition to start with a rule label (Word: or Word::), got: " .. trim(lines[index])
        )
      end
      index = index + 1
    end
  end
  if #rules == 0 then
    parse_fail(1, "no rule definitions found in spec")
  end
  return ast.spec_file({ rules = rules })
end

return M
