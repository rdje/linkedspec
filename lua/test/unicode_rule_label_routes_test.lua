-- FUTURE-PARITY-BACKLOG.10.7.1.1 — Lua parser and validator rule-label routes.

local ast = require("linkedspec.spec_ast")
local json = require("linkedspec.json")
local spec_parser = require("linkedspec.spec_parser")
local spec_validator = require("linkedspec.spec_validator")

local linkedspec = {
  is_spec_parse_error = spec_parser.is_parse_error,
  is_spec_validation_error = spec_validator.is_validation_error,
  parse_spec = spec_parser.parse_spec,
  spec_validation_error_to_json = spec_validator.validation_error_to_json,
  validate_spec = spec_validator.validate_spec,
}

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

local function read_file(path)
  local handle = assert(io.open(path, "rb"))
  local value = assert(handle:read("*a"))
  assert(handle:close())
  return value
end

local contract = json.decode(read_file("capability_conformance/unicode_rule_label_contract.json"))

local function fixture_label(id)
  for _, fixture in ipairs(contract.positive_fixtures) do
    if fixture.id == id then return fixture.label end
  end
  error("missing positive fixture " .. id, 0)
end

local function node_type(value)
  return ast.node_type(value)
end

local function check_raw_edge(source, label)
  local parsed = linkedspec.parse_spec("Owner::\n " .. source .. "\n")
  check_equal(#parsed.rules, 1, label .. " rule count")
  check_equal(#parsed.rules[1].body, 1, label .. " body count")
  check_equal(node_type(parsed.rules[1].body[1].kind), "RawBodyElementKind", label .. " stays raw")
  check_equal(parsed.rules[1].body[1].kind.text, source, label .. " raw identity")
end

local function check_parse_error(source, label)
  local ok, value = pcall(function() return linkedspec.parse_spec(source) end)
  check_equal(ok, false, label .. " rejected")
  check(linkedspec.is_spec_parse_error(value), label .. " parse error type")
end

-- scanner parses every declaration and edge form with exact identity
local declaration_lines = {}
for index, fixture in ipairs(contract.positive_fixtures) do
  declaration_lines[index] = fixture.label .. (index == 1 and ":: /x/" or ": /x/")
end
local declarations = linkedspec.parse_spec(table.concat(declaration_lines, "\n"))
check_equal(#declarations.rules, #contract.positive_fixtures, "positive declaration count")
for index, fixture in ipairs(contract.positive_fixtures) do
  check_equal(declarations.rules[index].header.label, fixture.label, fixture.id .. " declaration identity")
end
check_equal(linkedspec.validate_spec(declarations), nil, "positive declarations validate")

local precomposed = fixture_label("latin_precomposed")
local decomposed = fixture_label("latin_decomposed")
local greek = fixture_label("greek")
local cjk = fixture_label("cjk")
local middle_dot = fixture_label("middle_dot_continue")
local supplementary = fixture_label("supplementary")

local action_spec = linkedspec.parse_spec(table.concat({
  "Owner::OR",
  " /o/ -> " .. precomposed .. " | " .. decomposed .. " { return(\"ok\") }",
  precomposed .. ": /x/",
  decomposed .. ": /y/",
}, "\n"))
local action_kind = action_spec.rules[1].body[2].kind
check_equal(node_type(action_kind), "ActionEdgeBodyElementKind", "action edge kind")
check_equal(action_kind.targets[1].label, precomposed, "action first target identity")
check_equal(action_kind.targets[2].label, decomposed, "action second target identity")
check_equal(linkedspec.validate_spec(action_spec), nil, "Unicode action route validates")

local blind_spec = linkedspec.parse_spec(table.concat({
  "Owner::AND",
  " => " .. cjk,
  cjk .. ": /x/",
}, "\n"))
local blind_kind = blind_spec.rules[1].body[1].kind
check_equal(node_type(blind_kind), "BlindEdgeBodyElementKind", "blind edge kind")
check_equal(blind_kind.target, cjk, "blind target identity")
check_equal(linkedspec.validate_spec(blind_spec), nil, "Unicode blind route validates")

local bare_spec = linkedspec.parse_spec(table.concat({
  "Owner::OR",
  " " .. middle_dot .. " | " .. supplementary .. " { return(\"ok\") }",
  middle_dot .. ": /x/",
  supplementary .. ": /y/",
}, "\n"))
local bare_kind = bare_spec.rules[1].body[1].kind
check_equal(node_type(bare_kind), "BareEdgeBodyElementKind", "bare edge kind")
check_equal(bare_kind.targets[1].label, middle_dot, "bare first target identity")
check_equal(bare_kind.targets[2].label, supplementary, "bare second target identity")
check_equal(linkedspec.validate_spec(bare_spec), nil, "Unicode bare route validates")

local action_boundaries = {
  "",
  " # comment",
  " { return(\"ok\") }",
  ".push",
  " -> " .. greek,
  " => " .. cjk,
  " /x/",
  " E",
  " @capture_slice",
  " -? flag",
}
for index, suffix in ipairs(action_boundaries) do
  local parsed = linkedspec.parse_spec("Owner::\n -> " .. precomposed .. suffix .. "\n")
  check_equal(
    node_type(parsed.rules[1].body[1].kind),
    "ActionEdgeBodyElementKind",
    "action boundary " .. index
  )
end
local indexed_action = linkedspec.parse_spec("Owner::\n -> " .. precomposed .. " [2]\n")
check_equal(indexed_action.rules[1].body[1].kind.targets[1].index, 2, "spaced action index")
local indexed_blind = linkedspec.parse_spec("Owner::\n => " .. cjk .. " [3]\n")
check_equal(indexed_blind.rules[1].body[1].kind.index, 3, "spaced blind index")
local indexed_bare = linkedspec.parse_spec("Owner::\n " .. middle_dot .. " | " .. supplementary .. " [4]\n")
check_equal(indexed_bare.rules[1].body[1].kind.targets[1].index, 4, "spaced bare index first")
check_equal(indexed_bare.rules[1].body[1].kind.targets[2].index, 4, "spaced bare index second")

-- invalid suffixes never become partial action blind or bare edges
local invalid_suffixes = {
  { "hyphen", "Top-Rule" },
  { "space", "Top Rule" },
  { "emoji", "Top😀" },
  { "colon", "Top:" },
  { "slash", "Top/Rule" },
  { "dollar", "$Top" },
}
for _, fixture in ipairs(invalid_suffixes) do
  check_raw_edge("-> " .. fixture[2], fixture[1] .. " action")
  check_raw_edge("=> " .. fixture[2], fixture[1] .. " blind")
  if fixture[1] ~= "colon" then
    check_raw_edge(fixture[2], fixture[1] .. " bare")
  end
end
check_raw_edge("->", "empty action")
check_raw_edge("=>", "empty blind")

local colon_bare = linkedspec.parse_spec("Owner::\n Top:\n /x/\n")
check_equal(#colon_bare.rules, 2, "colon remains declaration punctuation")
check_equal(#colon_bare.rules[1].body, 0, "colon is not a partial bare edge")
check_equal(colon_bare.rules[2].header.label, "Top", "colon declaration identity")

for _, fixture in ipairs(contract.negative_fixtures) do
  if fixture.id ~= "newline" then
    check_parse_error(fixture.label .. "::\n /x/\n", fixture.id .. " declaration")
  end
end
check_parse_error("Top:::\n /x/\n", "third colon")

local function rule_header(label, line)
  return ast.rule_header({
    label = label,
    is_top = true,
    mode = ast.default_rule_mode(),
    rest = "",
    line = line,
  })
end

local function body_element(kind, line)
  return ast.body_element({ kind = kind, source = "external", line = line })
end

local function validation_spec(role, label)
  local body = {}
  if role == "action" then
    body[1] = body_element(ast.action_edge_body_kind({
      targets = { ast.edge_target({ label = label, index = 0 }) },
    }), 12)
  elseif role == "blind" then
    body[1] = body_element(ast.blind_edge_body_kind({ target = label }), 13)
  elseif role == "bare" then
    body[1] = body_element(ast.bare_edge_body_kind({
      targets = { ast.bare_edge_target({ label = label }) },
    }), 14)
  end
  return ast.spec_file({
    rules = {
      ast.rule({
        header = rule_header(role == "declaration" and label or "Top", 11),
        body = body,
      }),
    },
  })
end

local function check_invalid_diagnostic(spec, label, role, line, owner, test_label)
  local ok, value = pcall(function() return linkedspec.validate_spec(spec) end)
  check_equal(ok, false, test_label .. " rejected")
  check(linkedspec.is_spec_validation_error(value), test_label .. " validation error type")
  if not linkedspec.is_spec_validation_error(value) then return end
  local expected_message = role .. " '" .. label ..
    "' is not a nonempty Unicode 17.0.0 XID_Continue rule label"
  check_equal(value.code, "invalid_rule_label", test_label .. " code")
  check_equal(value.stage, "validate_rule_labels", test_label .. " stage")
  check_equal(value.message, expected_message, test_label .. " message")
  local fields = json.harray({ label = label, line = line, role = role })
  if owner ~= nil then fields.rule_label = owner end
  check_equal(
    json.encode(linkedspec.spec_validation_error_to_json(value)),
    json.encode(json.harray({
      code = "invalid_rule_label",
      stage = "validate_rule_labels",
      message = expected_message,
      fields = fields,
    })),
    test_label .. " portable JSON"
  )
end

-- validator rejects every programmatic declaration and target role
local invalid_label = "Top-Rule"
local validation_cases = {
  { "declaration", "declaration", 11, nil },
  { "action", "edge_target", 12, "Top" },
  { "blind", "edge_target", 13, "Top" },
  { "bare", "edge_target", 14, "Top" },
}
for _, item in ipairs(validation_cases) do
  local specimen = validation_spec(item[1], invalid_label)
  check_invalid_diagnostic(specimen, invalid_label, item[2], item[3], item[4], item[1] .. " programmatic")
end

-- validator rejects invalid labels reconstructed from AST JSON
for _, item in ipairs(validation_cases) do
  local specimen = validation_spec(item[1], invalid_label)
  local reconstructed = ast.from_json("SpecFile", json.decode(json.encode(ast.to_json(specimen))))
  check_invalid_diagnostic(
    reconstructed,
    invalid_label,
    item[2],
    item[3],
    item[4],
    item[1] .. " reconstructed"
  )
end

if #failures > 0 then
  error(table.concat(failures, "\n"), 0)
end
io.stdout:write("Lua Unicode rule-label routes: ", assertions, " assertions passed\n")
