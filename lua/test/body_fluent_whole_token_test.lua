-- FUTURE-PARITY-BACKLOG.10.7.1.3.1 — preserve body-fluent remainders.

local ast = require("linkedspec.spec_ast")
local json = require("linkedspec.json")
local spec_parser = require("linkedspec.spec_parser")
local spec_validator = require("linkedspec.spec_validator")

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

local function node_type(value)
  return ast.node_type(value)
end

-- malformed same-line suffixes remain visible as raw validation failures
local malformed = {
  { id = "precomposed", source = ".Töp()", prefix = ".T", method = "T", suffix = "öp()" },
  { id = "middle dot", source = ".A·B()", prefix = ".A", method = "A", suffix = "·B()" },
  { id = "hyphen", source = ".Top-Rule()", prefix = ".Top", method = "Top", suffix = "-Rule()" },
  { id = "space", source = ".Top Rule()", prefix = ".Top", method = "Top", suffix = "Rule()" },
  { id = "emoji", source = ".Top😀()", prefix = ".Top", method = "Top", suffix = "😀()" },
  { id = "colon", source = ".Top:Rule()", prefix = ".Top", method = "Top", suffix = ":Rule()" },
  { id = "slash", source = ".Top/Rule()", prefix = ".Top", method = "Top", suffix = "/Rule()" },
}

for _, fixture in ipairs(malformed) do
  local parsed = spec_parser.parse_spec("Root::\n " .. fixture.source .. "\n")
  check_equal(#parsed.rules, 1, fixture.id .. " rule count")
  check_equal(#parsed.rules[1].body, 2, fixture.id .. " body count")

  local fluent = parsed.rules[1].body[1]
  check_equal(node_type(fluent.kind), "FluentChainBodyElementKind", fixture.id .. " fluent kind")
  check_equal(fluent.source, fixture.prefix, fixture.id .. " fluent source")
  check_equal(fluent.line, 2, fixture.id .. " fluent line")
  check_equal(#fluent.kind.calls, 1, fixture.id .. " call count")
  check_equal(fluent.kind.calls[1].method, fixture.method, fixture.id .. " method")
  check_equal(fluent.kind.calls[1].args, "", fixture.id .. " arguments")

  local raw = parsed.rules[1].body[2]
  check_equal(node_type(raw.kind), "RawBodyElementKind", fixture.id .. " raw kind")
  check_equal(raw.kind.text, fixture.suffix, fixture.id .. " raw text")
  check_equal(raw.source, fixture.suffix, fixture.id .. " raw source")
  check_equal(raw.line, 2, fixture.id .. " raw line")

  local ok, value = pcall(function() return spec_validator.validate_spec(parsed) end)
  check_equal(ok, false, fixture.id .. " validation rejected")
  check(spec_validator.is_validation_error(value), fixture.id .. " validation error type")
  if spec_validator.is_validation_error(value) then
    local expected = "rule 'Root': unrecognized body syntax at line 2: " .. fixture.suffix
    check_equal(value.message, expected, fixture.id .. " validation message")
    check_equal(value.code, nil, fixture.id .. " validation code")
    check_equal(value.stage, nil, fixture.id .. " validation stage")
    local encoded = json.encode(spec_validator.validation_error_to_json(value))
    check(encoded:find(fixture.suffix, 1, true) ~= nil, fixture.id .. " diagnostic suffix identity")
  end
end

-- no-prefix and newline controls retain their established raw ownership
local no_prefix = {
  { id = "empty method", source = ".()" },
  { id = "dollar method", source = ".$Top()" },
}
for _, fixture in ipairs(no_prefix) do
  local parsed = spec_parser.parse_spec("Root::\n " .. fixture.source .. "\n")
  check_equal(#parsed.rules[1].body, 1, fixture.id .. " body count")
  check_equal(node_type(parsed.rules[1].body[1].kind), "RawBodyElementKind", fixture.id .. " raw kind")
  check_equal(parsed.rules[1].body[1].kind.text, fixture.source, fixture.id .. " raw text")
  local ok, value = pcall(function() return spec_validator.validate_spec(parsed) end)
  check_equal(ok, false, fixture.id .. " validation rejected")
  check(spec_validator.is_validation_error(value), fixture.id .. " validation error type")
end

local newline = spec_parser.parse_spec("Root::\n .Top\n Rule()\n")
check_equal(#newline.rules[1].body, 2, "newline body count")
check_equal(node_type(newline.rules[1].body[1].kind), "FluentChainBodyElementKind", "newline fluent kind")
check_equal(newline.rules[1].body[1].kind.calls[1].method, "Top", "newline fluent method")
check_equal(node_type(newline.rules[1].body[2].kind), "RawBodyElementKind", "newline raw kind")
check_equal(newline.rules[1].body[2].kind.text, "Rule()", "newline raw text")
check_equal(newline.rules[1].body[2].line, 3, "newline raw line")
local newline_ok, newline_error = pcall(function() return spec_validator.validate_spec(newline) end)
check_equal(newline_ok, false, "newline validation rejected")
check(spec_validator.is_validation_error(newline_error), "newline validation error type")

-- valid ASCII methods and recognized body continuations retain their existing grammar
local valid = spec_parser.parse_spec(table.concat({
  "Root::",
  " . _method9()",
  " .Top().next(1)",
  " .commented # retained comment",
  " .lifecycle E",
  " .regex /x/",
  " .edge -> Child",
  "Child: /x/",
}, "\n"))

check_equal(#valid.rules, 2, "valid rule count")
check_equal(#valid.rules[1].body, 9, "valid root body count")
local expected_types = {
  "FluentChainBodyElementKind",
  "FluentChainBodyElementKind",
  "FluentChainBodyElementKind",
  "FluentChainBodyElementKind",
  "LifecycleMarkerBodyElementKind",
  "FluentChainBodyElementKind",
  "RegexBodyElementKind",
  "FluentChainBodyElementKind",
  "ActionEdgeBodyElementKind",
}
for index, expected in ipairs(expected_types) do
  check_equal(node_type(valid.rules[1].body[index].kind), expected, "valid body kind " .. index)
end
check_equal(valid.rules[1].body[1].kind.calls[1].method, "_method9", "underscore method retained")
check_equal(#valid.rules[1].body[2].kind.calls, 2, "chained call count retained")
check_equal(valid.rules[1].body[2].kind.calls[1].method, "Top", "first chained method retained")
check_equal(valid.rules[1].body[2].kind.calls[2].method, "next", "second chained method retained")
check_equal(valid.rules[1].body[2].kind.calls[2].args, "1", "second chained arguments retained")
check_equal(valid.rules[1].body[3].kind.calls[1].method, "commented", "comment method retained")
check_equal(valid.rules[1].body[5].kind.marker, "E", "lifecycle continuation retained")
check_equal(valid.rules[1].body[7].kind.pattern, "x", "regex continuation retained")
check_equal(valid.rules[1].body[9].kind.targets[1].label, "Child", "edge continuation retained")
check_equal(node_type(valid.rules[2].body[1].kind), "RegexBodyElementKind", "child regex retained")
check_equal(spec_validator.validate_spec(valid), nil, "valid fluent and continuation routes validate")

if #failures > 0 then
  error(table.concat(failures, "\n"), 0)
end
io.stdout:write("Lua body-fluent whole-token: ", assertions, " assertions passed\n")
