-- FUTURE-PARITY-BACKLOG.10.7.1.1 — generated Lua rule-label primitives.

local json = require("linkedspec.json")
local unicode_rule_label = require("linkedspec.unicode_rule_label")

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

-- generated metadata and all range boundaries match the contract
check_equal(unicode_rule_label.CONTRACT_ID, contract.contract_id, "contract id")
check_equal(unicode_rule_label.UNICODE_VERSION, contract.unicode_version, "Unicode version")
check_equal(unicode_rule_label.DATA_SHA256, contract.data_sha256, "data digest")
check_equal(unicode_rule_label.RANGE_COUNT, #contract.xid_continue_ranges, "range count")
for _, range in ipairs(contract.xid_continue_ranges) do
  local start = assert(tonumber(range[1], 16))
  local finish = assert(tonumber(range[2], 16))
  check(unicode_rule_label.is_rule_label_codepoint(start), "range start U+" .. range[1])
  check(unicode_rule_label.is_rule_label_codepoint(finish), "range end U+" .. range[2])
end
check(not unicode_rule_label.is_rule_label_codepoint(-1), "negative scalar rejected")
check(not unicode_rule_label.is_rule_label_codepoint(1.5), "fractional scalar rejected")
check(not unicode_rule_label.is_rule_label_codepoint(0xD800), "surrogate rejected")
check(not unicode_rule_label.is_rule_label_codepoint(0x110000), "out-of-range scalar rejected")

-- complete-label validation matches every neutral fixture
for _, fixture in ipairs(contract.positive_fixtures) do
  check(unicode_rule_label.is_rule_label(fixture.label), fixture.id .. " positive")
end
for _, fixture in ipairs(contract.negative_fixtures) do
  check(not unicode_rule_label.is_rule_label(fixture.label), fixture.id .. " negative")
end
for _, fixture in ipairs(contract.distinct_fixtures) do
  check(unicode_rule_label.is_rule_label(fixture.left), fixture.id .. " left valid")
  check(unicode_rule_label.is_rule_label(fixture.right), fixture.id .. " right valid")
  check(fixture.left ~= fixture.right, fixture.id .. " remains distinct")
end

-- longest-prefix scanning preserves scalar and byte boundaries
for _, fixture in ipairs(contract.positive_fixtures) do
  local input = "!" .. fixture.label .. "[2]"
  local label, next_position = unicode_rule_label.take_rule_label_prefix(input, 2)
  check_equal(label, fixture.label, fixture.id .. " prefix label")
  check_equal(next_position, 2 + #fixture.label, fixture.id .. " prefix byte end")
  check_equal(input:sub(next_position), "[2]", fixture.id .. " prefix remainder")
end

local partial_label, partial_end = unicode_rule_label.take_rule_label_prefix("!Top😀Rule", 2)
check_equal(partial_label, "Top", "emoji boundary label")
check_equal(partial_end, 5, "emoji boundary byte position")
local no_label = unicode_rule_label.take_rule_label_prefix("😀Top", 1)
check_equal(no_label, nil, "invalid leading scalar")
check_equal(unicode_rule_label.take_rule_label_prefix("", 1), nil, "empty prefix")

local malformed = {
  { "continuation start", string.char(0x80) },
  { "truncated two-byte", string.char(0xC2) },
  { "truncated three-byte", string.char(0xE2, 0x82) },
  { "truncated four-byte", string.char(0xF0, 0x90, 0x80) },
  { "overlong two-byte", string.char(0xC0, 0xAF) },
  { "overlong three-byte", string.char(0xE0, 0x80, 0xAF) },
  { "surrogate encoding", string.char(0xED, 0xA0, 0x80) },
  { "above Unicode maximum", string.char(0xF4, 0x90, 0x80, 0x80) },
}
for _, fixture in ipairs(malformed) do
  check(not unicode_rule_label.is_rule_label(fixture[2]), fixture[1] .. " complete label")
  check_equal(
    unicode_rule_label.take_rule_label_prefix(fixture[2], 1),
    nil,
    fixture[1] .. " prefix"
  )
  local prefix, next_position = unicode_rule_label.take_rule_label_prefix("Top" .. fixture[2], 1)
  check_equal(prefix, "Top", fixture[1] .. " preserves valid prefix")
  check_equal(next_position, 4, fixture[1] .. " preserves invalid byte boundary")
end

if #failures > 0 then
  error(table.concat(failures, "\n"), 0)
end
io.stdout:write("Lua Unicode rule-label classifier: ", assertions, " assertions passed\n")
