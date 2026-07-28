-- FUTURE-PARITY-BACKLOG.10.7.5.1-.2 — complete private static query evaluator.

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

local function count_plain(text, needle)
  local count = 0
  local position = 1
  while true do
    local found = text:find(needle, position, true)
    if found == nil then return count end
    count = count + 1
    position = found + #needle
  end
end

-- Compact dual-ABI SHA-256 oracle. Operators are loaded from text only on
-- native-bitwise Lua; LuaJIT parses this file without seeing 5.3 syntax.
local UINT32 = 4294967296
local UINT32_MASK = UINT32 - 1
local bit_api
if type(bit32) == "table" then
  bit_api = {
    band = bit32.band, bxor = bit32.bxor, bnot = bit32.bnot,
    rshift = bit32.rshift, ror = bit32.rrotate,
  }
elseif type(bit) == "table" then
  bit_api = {
    band = bit.band, bxor = bit.bxor, bnot = bit.bnot,
    rshift = bit.rshift, ror = bit.ror,
  }
else
  bit_api = assert(load([[
    return {
      band = function(a, b) return (a & b) & 0xffffffff end,
      bxor = function(a, b) return (a ~ b) & 0xffffffff end,
      bnot = function(a) return (~a) & 0xffffffff end,
      rshift = function(a, n) return (a >> n) & 0xffffffff end,
      ror = function(a, n)
        return ((a >> n) | ((a << (32 - n)) & 0xffffffff)) & 0xffffffff
      end,
    }
  ]]))()
end

local function u32(value) return value % UINT32 end
local function band(left, right) return u32(bit_api.band(left, right)) end
local function bxor(left, right) return u32(bit_api.bxor(left, right)) end
local function bxor3(a, b, c) return bxor(bxor(a, b), c) end
local function bnot(value) return u32(bit_api.bnot(value)) end
local function rshift(value, amount) return u32(bit_api.rshift(value, amount)) end
local function ror(value, amount) return u32(bit_api.ror(value, amount)) end
local function add32(a, b, c, d, e)
  return (a + b + (c or 0) + (d or 0) + (e or 0)) % UINT32
end

local SHA256_INITIAL = {
  0x6A09E667, 0xBB67AE85, 0x3C6EF372, 0xA54FF53A,
  0x510E527F, 0x9B05688C, 0x1F83D9AB, 0x5BE0CD19,
}

local SHA256_ROUND = {
  0x428A2F98, 0x71374491, 0xB5C0FBCF, 0xE9B5DBA5,
  0x3956C25B, 0x59F111F1, 0x923F82A4, 0xAB1C5ED5,
  0xD807AA98, 0x12835B01, 0x243185BE, 0x550C7DC3,
  0x72BE5D74, 0x80DEB1FE, 0x9BDC06A7, 0xC19BF174,
  0xE49B69C1, 0xEFBE4786, 0x0FC19DC6, 0x240CA1CC,
  0x2DE92C6F, 0x4A7484AA, 0x5CB0A9DC, 0x76F988DA,
  0x983E5152, 0xA831C66D, 0xB00327C8, 0xBF597FC7,
  0xC6E00BF3, 0xD5A79147, 0x06CA6351, 0x14292967,
  0x27B70A85, 0x2E1B2138, 0x4D2C6DFC, 0x53380D13,
  0x650A7354, 0x766A0ABB, 0x81C2C92E, 0x92722C85,
  0xA2BFE8A1, 0xA81A664B, 0xC24B8B70, 0xC76C51A3,
  0xD192E819, 0xD6990624, 0xF40E3585, 0x106AA070,
  0x19A4C116, 0x1E376C08, 0x2748774C, 0x34B0BCB5,
  0x391C0CB3, 0x4ED8AA4A, 0x5B9CCA4F, 0x682E6FF3,
  0x748F82EE, 0x78A5636F, 0x84C87814, 0x8CC70208,
  0x90BEFFFA, 0xA4506CEB, 0xBEF9A3F7, 0xC67178F2,
}

local function word_byte(value, shift)
  return math.floor(value / (2 ^ shift)) % 256
end

local function sha256_hex(source)
  local bit_length = #source * 8
  local high = math.floor(bit_length / UINT32)
  local low = bit_length % UINT32
  local zero_count = (56 - ((#source + 1) % 64)) % 64
  local message = source .. string.char(0x80) .. string.rep("\0", zero_count) .. string.char(
    word_byte(high, 24), word_byte(high, 16), word_byte(high, 8), word_byte(high, 0),
    word_byte(low, 24), word_byte(low, 16), word_byte(low, 8), word_byte(low, 0)
  )
  local hash = {}
  for index = 1, 8 do hash[index] = SHA256_INITIAL[index] end
  for block_start = 1, #message, 64 do
    local words = {}
    for index = 0, 15 do
      local position = block_start + index * 4
      words[index + 1] = message:byte(position) * 0x1000000 +
        message:byte(position + 1) * 0x10000 +
        message:byte(position + 2) * 0x100 + message:byte(position + 3)
    end
    for index = 17, 64 do
      local left = words[index - 15]
      local right = words[index - 2]
      local small_0 = bxor3(ror(left, 7), ror(left, 18), rshift(left, 3))
      local small_1 = bxor3(ror(right, 17), ror(right, 19), rshift(right, 10))
      words[index] = add32(words[index - 16], small_0, words[index - 7], small_1)
    end
    local a, b, c, d = hash[1], hash[2], hash[3], hash[4]
    local e, f, g, h = hash[5], hash[6], hash[7], hash[8]
    for index = 1, 64 do
      local large_1 = bxor3(ror(e, 6), ror(e, 11), ror(e, 25))
      local choose = bxor(band(e, f), band(bnot(e), g))
      local temporary_1 = add32(h, large_1, choose, SHA256_ROUND[index], words[index])
      local large_0 = bxor3(ror(a, 2), ror(a, 13), ror(a, 22))
      local majority = bxor3(band(a, b), band(a, c), band(b, c))
      local temporary_2 = add32(large_0, majority)
      h, g, f, e, d, c, b, a = g, f, e, add32(d, temporary_1), c, b, a,
        add32(temporary_1, temporary_2)
    end
    hash[1] = add32(hash[1], a)
    hash[2] = add32(hash[2], b)
    hash[3] = add32(hash[3], c)
    hash[4] = add32(hash[4], d)
    hash[5] = add32(hash[5], e)
    hash[6] = add32(hash[6], f)
    hash[7] = add32(hash[7], g)
    hash[8] = add32(hash[8], h)
  end
  local parts = {}
  for index = 1, 8 do parts[index] = string.format("%08x", hash[index]) end
  return table.concat(parts)
end

local linkedspec = require("linkedspec")
local json = linkedspec.json
local semantic_index_module = require("linkedspec.semantic_index")
local semantic_query = require("linkedspec.semantic_query")

local function plain_sequence(values)
  local result = {}
  for index, value in ipairs(values) do result[index] = value end
  return result
end

local function typed_request(value)
  local after_id = value.page.after_id
  if after_id == json.null then after_id = nil end
  return semantic_query.request(value.operation, {
    contract = value.contract,
    subjects = plain_sequence(value.subjects),
    record_kinds = plain_sequence(value.record_kinds),
    relation_kinds = plain_sequence(value.relation_kinds),
    direction = value.direction,
    page = { after_id = after_id, limit = value.page.limit },
    budget = {
      max_records = value.budget.max_records,
      max_relations = value.budget.max_relations,
      max_depth = value.budget.max_depth,
    },
    source = {
      detail = value.source.detail,
      include_content_digest = value.source.include_content_digest,
    },
  })
end

local contract = json.decode(
  read_file("capability_conformance/semantic_introspection_contract.json")
)
local query_cases = {}
for _, query_case in ipairs(contract.query_cases) do query_cases[query_case.id] = query_case end

local owned_ids = {
  "capabilities",
  "graph_list_rules",
  "graph_duplicate_regex_text",
  "graph_reverse_dispatch",
  "graph_explain_entry",
  "calls_symbols_and_shapes",
  "staged_chain",
  "generated_provenance",
  "failed_diagnostic",
  "privacy_none",
  "privacy_text_and_digest",
  "pagination_after_id",
  "page_boundary",
  "budget_prefix",
  "relation_budget_prefix",
  "relation_depth_zero",
  "source_ceiling_forbidden",
  "unsupported_contract",
  "invalid_operation_combination",
}

local completion_ids = {
  "graph_reverse_dispatch",
  "staged_chain",
  "generated_provenance",
  "pagination_after_id",
  "page_boundary",
  "budget_prefix",
  "relation_budget_prefix",
  "relation_depth_zero",
  "unsupported_contract",
  "invalid_operation_combination",
}

local snapshot_options = {
  graph = { fixture = "graph.spec", logical_name = "graph.spec", ceiling = "text" },
  calls = {
    fixture = "calls_and_staging.spec",
    logical_name = "calls_and_staging.spec",
    ceiling = "text",
  },
  failed = { fixture = "failed.spec", logical_name = "failed.spec", ceiling = "span" },
  privacy = { fixture = "privacy.spec", logical_name = "privacy.spec", ceiling = "text" },
  privacy_limited = {
    fixture = "privacy.spec",
    logical_name = "privacy.spec",
    ceiling = "identity",
  },
}

local function index_for(snapshot)
  local options = assert(snapshot_options[snapshot])
  local source = read_file(
    "capability_conformance/semantic_introspection/" .. options.fixture
  )
  return linkedspec.semantic_index(source, {
    logical_name = options.logical_name,
    source_detail_ceiling = options.ceiling,
  })
end

local function ids(values)
  local result = json.array()
  for index, value in ipairs(values) do result[index] = value.id end
  return result
end

local function diagnostic_codes(values)
  local result = json.array()
  for index, value in ipairs(values) do result[index] = value.code end
  return result
end

local responses = {}
local requests = {}
check_equal(sha256_hex("abc"),
  "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad",
  "test SHA-256 oracle")
check_equal(#owned_ids, 19, "owned static query count")
check_equal(#completion_ids, 10, "traversal completion query count")

for _, id in ipairs(owned_ids) do
  local query_case = assert(query_cases[id])
  local request = typed_request(query_case.request)
  local response = semantic_index_module._semantic_query_kernel(
    index_for(query_case.snapshot), request
  )
  local expected = query_case.expected
  local projected = semantic_query.to_json(response)
  requests[id] = request
  responses[id] = response

  check_equal(response.ok, expected.ok, id .. " status")
  check_equal(json.encode(ids(response.records)), json.encode(expected.record_ids), id .. " records")
  check_equal(
    json.encode(ids(response.relations)), json.encode(expected.relation_ids), id .. " relations"
  )
  check_equal(
    json.encode(diagnostic_codes(response.diagnostics)), json.encode(expected.diagnostic_codes),
    id .. " diagnostics"
  )
  check_equal(response.page.complete, expected.complete, id .. " page completion")
  check_equal(sha256_hex(json.encode(projected)), expected.response_sha256, id .. " response hash")
end

local interleaved_index = index_for("graph")
local repeated_request = typed_request(query_cases.graph_list_rules.request)
local interleaved_request = typed_request(query_cases.graph_duplicate_regex_text.request)
local repeated_first = semantic_index_module._semantic_query_kernel(
  interleaved_index, repeated_request
)
local interleaved = semantic_index_module._semantic_query_kernel(
  interleaved_index, interleaved_request
)
local repeated_second = semantic_index_module._semantic_query_kernel(
  interleaved_index, repeated_request
)
check(repeated_first ~= repeated_second, "repeated query returns a fresh response")
check_equal(
  sha256_hex(json.encode(semantic_query.to_json(repeated_first))),
  query_cases.graph_list_rules.expected.response_sha256,
  "repeated query first hash"
)
check_equal(
  sha256_hex(json.encode(semantic_query.to_json(interleaved))),
  query_cases.graph_duplicate_regex_text.expected.response_sha256,
  "interleaved query hash"
)
check_equal(
  sha256_hex(json.encode(semantic_query.to_json(repeated_second))),
  query_cases.graph_list_rules.expected.response_sha256,
  "repeated query second hash"
)

local none = responses.privacy_none.records[1]
check_equal(none.source, nil, "none source is absent")
check_equal(none.facts.pattern, json.null, "none pattern is redacted")
check_equal(json.encode(none.redactions), '["/facts/pattern"]', "none redaction path")

local text_record = responses.privacy_text_and_digest.records[1]
check_equal(text_record.facts.pattern, "é", "text pattern retained")
check_equal(#text_record.redactions, 0, "text redactions empty")
check_equal(text_record.source.excerpt, "/é/", "text excerpt")
check(text_record.source.content_digest:match("^sha256:[0-9a-f]+$") ~= nil, "text digest shape")
check_equal(#text_record.source.content_digest, 71, "text digest length")

local forbidden = responses.source_ceiling_forbidden
check_equal(forbidden.ok, false, "source ceiling status")
check_equal(forbidden.cost.records_examined, 0, "source ceiling record cost")
check_equal(forbidden.cost.relations_examined, 0, "source ceiling relation cost")
check_equal(forbidden.diagnostics[1].fields.requested, "span", "source ceiling request")
check_equal(forbidden.diagnostics[1].fields.ceiling, "identity", "source ceiling value")

local explain = responses.graph_explain_entry
check_equal(explain.records[1].kind, "decision", "explain decision first")
check_equal(explain.records[2].kind, "explanation_step", "explain first step")
check_equal(explain.records[3].kind, "explanation_step", "explain second step")
check_equal(explain.relations[1].kind, "explained_by", "explain relation kind")
check_equal(explain.cost.depth_reached, 1, "explain depth")

local capabilities = responses.capabilities
local first_json = semantic_query.to_json(capabilities)
first_json.records[1].facts.record_kinds[1] = "host-private"
first_json.records[1].facts.budget_defaults.max_records = -1
local second_json = semantic_query.to_json(capabilities)
check_equal(second_json.records[1].facts.record_kinds[1], "capabilities", "fresh nested JSON")
check_equal(second_json.records[1].facts.budget_defaults.max_records, 1000, "fresh object JSON")
check(first_json ~= second_json, "fresh response roots")
check(first_json.records ~= second_json.records, "fresh response arrays")

local first_records = capabilities.records
first_records[1] = nil
check_equal(#capabilities.records, 1, "record collection access detached")
local capability_facts = capabilities.records[1].facts
capability_facts.features[1] = "host-private"
check_equal(#capabilities.records[1].facts.features, 0, "record facts access detached")

local request_subjects = { "rule:Top" }
local isolated_request = semantic_query.request("get", { subjects = request_subjects })
request_subjects[1] = "rule:Injected"
check_equal(isolated_request.subjects[1], "rule:Top", "request input detached")
local exposed_subjects = isolated_request.subjects
exposed_subjects[1] = "rule:Injected"
check_equal(isolated_request.subjects[1], "rule:Top", "request collection access detached")

for _, value in ipairs({
  requests.capabilities,
  capabilities,
  capabilities.snapshot,
  capabilities.records[1],
  capabilities.page,
  capabilities.cost,
  forbidden.diagnostics[1],
  explain.relations[1],
  text_record.source,
}) do
  check_equal(getmetatable(value), "protected", tostring(value) .. " metatable")
  check_equal(next(value), nil, tostring(value) .. " raw state")
  local ok = pcall(function() value.injected = true end)
  check_equal(ok, false, tostring(value) .. " assignment rejected")
end

check(semantic_query.is_request(requests.capabilities), "request guard")
check(not semantic_query.is_request(capabilities), "request guard rejects response")
check(semantic_query.is_response(capabilities), "response guard")
check(not semantic_query.is_response(requests.capabilities), "response guard rejects request")

local graph = index_for("graph")
local reverse = responses.graph_reverse_dispatch
check_equal(reverse.cost.records_examined, 0, "reverse record cost")
check_equal(reverse.cost.relations_examined, 2, "reverse relation cost")
check_equal(reverse.cost.depth_reached, 1, "reverse depth cost")
check_equal(reverse.page.after_id, nil, "reverse after cursor")
check_equal(reverse.page.next_after_id, nil, "reverse next cursor")

local both = semantic_index_module._semantic_query_kernel(graph, semantic_query.request("relations", {
  subjects = { "rule:Child" },
  relation_kinds = { "dispatches_to" },
  direction = "both",
}))
check_equal(json.encode(ids(both.relations)), json.encode(ids(reverse.relations)),
  "both traversal matches reverse depth one")
check_equal(both.cost.relations_examined, 2, "both relation cost")
check_equal(both.cost.depth_reached, 1, "both depth cost")

check_equal(responses.staged_chain.cost.relations_examined, 2, "staged relation cost")
check_equal(responses.staged_chain.cost.depth_reached, 1, "staged depth cost")
check_equal(responses.generated_provenance.cost.relations_examined, 1,
  "generated relation cost")
check_equal(responses.generated_provenance.cost.depth_reached, 1, "generated depth cost")

local after_id = responses.pagination_after_id
check_equal(after_id.page.after_id, "rule:Child", "page after cursor")
check_equal(after_id.page.next_after_id, nil, "page final cursor")
check_equal(after_id.cost.records_examined, 2, "page record cost")

local boundary = responses.page_boundary
check_equal(boundary.page.after_id, nil, "boundary after cursor")
check_equal(boundary.page.next_after_id, "rule:Top", "boundary next cursor")
check_equal(boundary.cost.records_examined, 1, "boundary record cost")
check_equal(#boundary.diagnostics, 0, "page-only boundary has no warning")

local record_budget = responses.budget_prefix
check_equal(record_budget.page.next_after_id, "source:0", "record budget cursor")
check_equal(record_budget.cost.records_examined, 2, "record budget cost")
check_equal(record_budget.diagnostics[1].severity, "warning", "record budget severity")
check_equal(record_budget.diagnostics[1].fields.limit, "max_records", "record budget limit")

local relation_budget = responses.relation_budget_prefix
check_equal(
  relation_budget.page.next_after_id,
  "relation:contains:rule:Top:edge:rule:Top:1:1",
  "relation budget cursor"
)
check_equal(relation_budget.cost.relations_examined, 2, "relation budget cost")
check_equal(relation_budget.cost.depth_reached, 1, "relation budget depth")
check_equal(relation_budget.diagnostics[1].fields.limit, "max_relations",
  "relation budget limit")

local depth_zero = responses.relation_depth_zero
check_equal(depth_zero.page.next_after_id, nil, "depth-zero next cursor")
check_equal(depth_zero.cost.relations_examined, 0, "depth-zero relation cost")
check_equal(depth_zero.cost.depth_reached, 0, "depth-zero depth cost")
check_equal(depth_zero.diagnostics[1].fields.limit, "max_depth", "depth-zero limit")

local precedence = semantic_index_module._semantic_query_kernel(graph, semantic_query.request("relations", {
  subjects = { "rule:Top" },
  relation_kinds = { "contains" },
  budget = { max_relations = 1, max_depth = 1 },
}))
check_equal(precedence.diagnostics[1].fields.limit, "max_relations",
  "relation budget precedes depth budget")

local unsupported = responses.unsupported_contract
check_equal(unsupported.ok, false, "unsupported status")
check_equal(unsupported.diagnostics[1].fields.requested, "linkedspec-semantic-query-v0",
  "unsupported requested contract")
check_equal(unsupported.diagnostics[1].fields.supported[1],
  "linkedspec-semantic-query-v1", "unsupported supported contract")
local invalid = responses.invalid_operation_combination
check_equal(invalid.ok, false, "invalid combination status")
check_equal(invalid.diagnostics[1].fields.reason, "operation_combination",
  "invalid combination reason")

local bad_cursor = semantic_index_module._semantic_query_kernel(graph, semantic_query.request("list", {
  record_kinds = { "rule" },
  page = { after_id = "rule:Missing" },
}))
check_equal(bad_cursor.ok, false, "bad cursor status")
check_equal(bad_cursor.page.after_id, "rule:Missing", "bad cursor retained")
check_equal(bad_cursor.diagnostics[1].fields.reason, "after_id_not_in_primary_stream",
  "bad cursor reason")

local unknown = semantic_index_module._semantic_query_kernel(graph, semantic_query.request("relations", {
  subjects = { "rule:Missing" },
}))
check_equal(unknown.ok, false, "unknown subject status")
check_equal(unknown.diagnostics[1].fields.reason, "unknown_subject", "unknown subject reason")

local deep = semantic_index_module._semantic_query_kernel(graph, semantic_query.request("relations", {
  subjects = { "rule:Top" },
  relation_kinds = { "contains", "dispatches_to", "selects_regex" },
  budget = { max_depth = 2 },
}))
check_equal(#deep.relations, 7, "two-layer traversal prefix")
check_equal(deep.cost.depth_reached, 2, "two-layer traversal depth")
check_equal(deep.diagnostics[1].fields.limit, "max_depth", "two-layer depth warning")

local get_page = semantic_index_module._semantic_query_kernel(graph, semantic_query.request("get", {
  subjects = { "regex:rule:Child:0", "regex:rule:Child:1" },
  page = { after_id = "regex:rule:Child:0" },
}))
check_equal(json.encode(ids(get_page.records)), '["regex:rule:Child:1"]', "get page stream")
check_equal(get_page.page.complete, true, "get page complete")

local capability_page = semantic_index_module._semantic_query_kernel(
  graph,
  semantic_query.request("capabilities", { page = { after_id = "capabilities:0" } })
)
check_equal(#capability_page.records, 0, "capabilities after cursor")
check_equal(capability_page.page.complete, true, "capabilities page complete")

local typed_error_requests = {
  {
    semantic_query.request("get", { subjects = { "rule:Missing" } }),
    "unknown_subject",
  },
  {
    semantic_query.request("explain", { subjects = { "source:0" } }),
    "not_explainable",
  },
  {
    semantic_query.request("capabilities", { record_kinds = { "rule" } }),
    "capability_filter",
  },
  {
    semantic_query.request("list", {
      source = { detail = "identity", include_content_digest = true },
    }),
    "digest_requires_text",
  },
}
for index, pair in ipairs(typed_error_requests) do
  local response = semantic_index_module._semantic_query_kernel(graph, pair[1])
  check_equal(response.ok, false, "typed error status " .. index)
  check_equal(response.diagnostics[1].fields.reason, pair[2], "typed error reason " .. index)
  check_equal(response.cost.records_examined, 0, "typed error record cost " .. index)
  check_equal(response.cost.relations_examined, 0, "typed error relation cost " .. index)
end

local explain_budget = semantic_index_module._semantic_query_kernel(graph, semantic_query.request("explain", {
  subjects = { "decision:entry:spec:0" },
  budget = { max_records = 1 },
  source = { detail = "span" },
}))
check_equal(json.encode(ids(explain_budget.records)), '["decision:entry:spec:0"]',
  "explain budget reserves decision")
check_equal(#explain_budget.relations, 0, "explain budget omits step relations")
check_equal(explain_budget.cost.records_examined, 1, "explain budget record cost")
check_equal(explain_budget.cost.depth_reached, 0, "explain budget depth cost")
check_equal(explain_budget.diagnostics[1].fields.limit, "max_records",
  "explain budget limit")

local mutable_reverse = semantic_query.to_json(reverse)
mutable_reverse.relations[1].facts.host_private = true
mutable_reverse.relations[1].evidence_ids[1] = "host-private"
local fresh_reverse = semantic_index_module._semantic_query_kernel(
  index_for("graph"), typed_request(query_cases.graph_reverse_dispatch.request)
)
check_equal(
  sha256_hex(json.encode(semantic_query.to_json(fresh_reverse))),
  query_cases.graph_reverse_dispatch.expected.response_sha256,
  "relation response remains detached"
)
check_equal(fresh_reverse.relations[1].facts.host_private, nil, "relation facts stay private")
check(fresh_reverse.relations[1].evidence_ids[1] ~= "host-private",
  "relation evidence stays private")

for index, constructor in ipairs({
  function() semantic_query.request("list", { contract = false }) end,
  function() semantic_query.request("list", { direction = false }) end,
  function() semantic_query.request("list", { page = { limit = false } }) end,
  function() semantic_query.request("list", { budget = { max_records = false } }) end,
  function() semantic_query.request("list", { budget = { max_depth = 1.5 } }) end,
  function() semantic_query.request("list", { source = { include_content_digest = 1 } }) end,
  function() semantic_query.request("list", { subjects = json.array() }) end,
}) do
  check_equal(pcall(constructor), false, "typed constructor rejection " .. index)
end

for _, name in ipairs({
  "semantic_query_request",
  "is_semantic_query_request",
  "is_semantic_query_response",
  "semantic_query_to_json",
  "semantic_query",
  "query_neutral",
  "capabilities",
}) do
  check_equal(linkedspec[name], nil, "root omits " .. name)
end
check_equal(graph.capabilities, nil, "index omits capabilities")
check_equal(graph.query, nil, "index omits query")
check_equal(graph.query_neutral, nil, "index omits neutral query")

local index_source = read_file("lua/src/linkedspec/semantic_index.lua")
local kernel_source = assert(index_source:match(
  "function M%._semantic_query_kernel.-\nend"
))
check_equal(count_plain(kernel_source, "materialize_static_projection"), 1,
  "kernel materializes exactly once")
check_equal(count_plain(kernel_source, ".evaluate("), 1, "kernel evaluates exactly once")

local query_source = read_file("lua/src/linkedspec/semantic_query.lua")
check_equal(count_plain(query_source, 'require("linkedspec.json")'), 1, "sole query dependency")
for _, forbidden_text in ipairs({
  'require("linkedspec.semantic_index")',
  'require("linkedspec.spec_parser")',
  'require("linkedspec.spec_validator")',
  'require("linkedspec.action_parser")',
  'require("linkedspec.source_emitter")',
  'require("linkedspec.interpreter")',
  "io.open(",
  "io.popen(",
  "os.getenv(",
  "os.time(",
  "math.random(",
  "debug.",
}) do
  check_equal(query_source:find(forbidden_text, 1, true), nil,
    "query omits forbidden authority " .. forbidden_text)
end

if #failures > 0 then
  io.stderr:write("not ok - semantic index query kernel\n")
  for _, failure in ipairs(failures) do io.stderr:write("  " .. failure .. "\n") end
  os.exit(1)
end

print("ok - semantic index query kernel (" .. assertions .. " assertions)")
