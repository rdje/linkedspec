local linkedspec = require("linkedspec")
local json = linkedspec.json
local staged = require("linkedspec.staged_ast_enrichment")
local sha256 = require("linkedspec.sha256")
local utility_path = ... or "tests/language-readiness/nested-tree/lua_checks.lua"
local exact = dofile(utility_path).exact_json
local A, D = json.array, json.harray
local M = { exact_json = exact }

function M.digest(source) return "sha256:" .. sha256.hex(source) end
local function copy(value) return json.decode(json.encode(value)) end
local function clear(values) for key in pairs(values) do values[key] = nil end end
local function case_by_id(cases, id)
  for _, row in ipairs(cases.accept) do if row.id == id then return row end end
  error("missing authored case " .. id)
end

function M.seed(child, child_digest, calls, change)
  local caps = A({ "staged-parse-job-v2", "typed-source-location-v1" })
  local modes = A({ "fail", "sibling_field" })
  local ceilings = D({ source_detail = "span", max_steps = 100,
    max_result_nodes = 512, max_diagnostic_bytes = 4096 })
  local top = change == "forbidden_top" and "Other" or "Number"
  local snapshot = D({
    immutable = true, prepared_before_authored_execution = true,
    filesystem_access_during_dispatch = false,
    aliases = change == "missing_identity" and A() or A({ D({
      declaring_spec_id = "readiness/parent.spec", authored_id = "integer",
      resolved_spec_id = "registry:integer-v1",
    }) }),
    declaring_relative = A(), search_roots = A(), providers = A(),
    entries = A({ D({ resolved_spec_id = "registry:integer-v1", compiled_authority = "opaque:integer",
      content_digest = child_digest, import_graph_fingerprint = M.digest(""),
      default_top_rule = top, allowed_top_rules = A({ top }), spec_language_version = 2,
      helper_contract_version = "actionir-v3", staged_contract_version = 2,
      capabilities = caps, policy_modes = modes, ceilings = ceilings,
    }) }),
  })
  local options = D({ declaring_spec_id = "readiness/parent.spec", caller_capabilities = caps,
    caller_policy_modes = modes, caller_ceilings = ceilings, required_source_detail = "span",
    required_versions = D({ spec_language_version = 2,
      helper_contract_version = "actionir-v3", staged_contract_version = 2 }),
  })
  return staged.execution_seed(snapshot, options, function()
    local callback = function(request, context)
      calls[#calls + 1] = D({ text = request.text, top = request.top_rule })
      -- Recognition and semantic construction belong to the actual precompiled child grammar.
      local ok, result = pcall(child, request.text)
      if not ok then
        if not linkedspec.is_runtime_exit_now(result) then error(result, 0) end
        return staged.child_failure(D({ code = "child_exit", status = result.status }))
      end
      result.source_span = staged.rebase_span(context, result.span)
      return staged.child_success(result)
    end
    return {
      compiled_authorities = { ["opaque:integer"] = callback },
      recursive_authority = D({ cancellation_token = "lossless-child-readiness", deadline = 100,
        remaining_steps = change == "no_budget" and 0 or 100, required_steps = 1,
        max_depth = 4, max_calls = change == "one_call" and 1 or 16 }),
      cancelled = function() return false end, clock = function() return 0 end,
    }
  end)
end

function M.segments(actual, expected, input)
  exact(actual, expected)
  -- Independent UTF-8 scalar slicing of the authored valid input; no runtime coordinate helper.
  local scalars = {}
  for scalar in input:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
    scalars[#scalars + 1] = scalar
  end
  assert(table.concat(scalars) == input, "complete UTF-8 scalar inventory")
  local cursor, reconstructed = 0, {}
  for _, part in ipairs(actual) do
    local span = part.span
    local first, last
    if json.kind(span) == "array" then first, last = span[1], span[2]
    else first, last = span.start, span["end"] end
    assert(first == cursor and 0 <= first and first <= last and last <= #scalars,
      "ordered scalar adjacency")
    local selected = {}
    for index = first + 1, last do selected[#selected + 1] = scalars[index] end
    exact(part.text, table.concat(selected), "independent scalar slice")
    reconstructed[#reconstructed + 1] = part.text
    cursor = last
  end
  assert(cursor == #scalars, "complete scalar coverage")
  exact(table.concat(reconstructed), input, "exact reconstruction")
  return true
end

function M.segmentation(cases, parse)
  assert(#cases.accept == 13, "original segmentation inventory")
  for _ = 1, 2 do
    for _, row in ipairs(cases.accept) do M.segments(parse(row.input), row.expected, row.input) end
  end
  local row = case_by_id(cases, "unicode_edges")
  local returned = parse(row.input)
  returned[1].text, returned[1].span.start = "changed gap", 999
  M.segments(parse(row.input), row.expected, row.input)
  return true
end

function M.composed(result, row, calls)
  local original = copy(result.ast)
  local requests, sidecars = A(), {}
  for index, item in ipairs(row.expected) do
    if item.kind == "item" then
      local text = item.text:sub(2, -2) -- Selected tokens contain only ASCII brackets/digits.
      local span = D({ kind = "direct_span", source_id = "input", provenance = "entry_group",
        start = item.span[1] + 1, ["end"] = item.span[2] - 1 })
      exact(original[index].child, text)
      exact(original[index].parsed, D({ kind = "integer", text = text,
        span = D({ start = 0, ["end"] = #text }), source_span = span }))
      original[index].child, original[index].parsed = nil, nil
      requests[#requests + 1] = D({ text = text, top = "Number" })
      sidecars[#sidecars + 1] = { path = A({ index - 1, "child" }), span = span }
    end
  end
  M.segments(original, row.expected, row.input)
  exact(calls, requests, "actual child calls")
  assert(#result.sidecars == #sidecars, "sidecar count")
  for index, actual in ipairs(result.sidecars) do
    exact(actual.parent_ast_path, sidecars[index].path)
    exact(actual.provenance, sidecars[index].span)
    exact(actual.resolved_spec_id, "registry:integer-v1")
    exact(actual.top_rule, "Number")
    exact(actual.state, "succeeded")
  end
  exact(result.resources.total_calls, #requests)
  exact(result.cache.misses, #requests == 0 and 0 or 1)
  exact(result.cache.hits, math.max(#requests - 1, 0))
  exact(result.diagnostics, A())
  return true
end

function M.rejects(parse, input, code)
  local ok, failure = pcall(parse, input)
  assert(not ok and staged.is_error(failure), "typed staged rejection without a result: " .. input)
  exact(staged.diagnostic_code(failure), code)
  return true
end

function M.actual_result_isolation(first, second)
  local expected = json.encode(second)
  first.ast[2].parsed.text = "changed actual child"
  first.ast[2].parsed.source_span.start = 999
  if json.encode(second) ~= expected then error("actual child results alias", 0) end
  return true
end

function M.children(cases, strict, parent_builder, child, child_digest)
  local calls = A()
  local parse = parent_builder(M.seed(child, child_digest, calls))
  local records = A()
  for _ = 1, 2 do
    for _, row in ipairs(cases.accept) do
      clear(calls)
      local result = parse(row.input)
      M.composed(result, row, calls)
      records[#records + 1] = result
    end
  end
  clear(calls)
  M.rejects(parse, "[12][00][7]", "staged_child_failed")
  exact(calls, A({ D({ text = "12", top = "Number" }), D({ text = "00", top = "Number" }) }))
  local recovery = copy(case_by_id(cases, "single_zero"))
  recovery.input, recovery.expected[2].text = "[8]", "[8]"
  clear(calls); M.composed(parse("[8]"), recovery, calls)
  for _, row in ipairs({
    { "missing_identity", "staged_registry_missing", 0 },
    { "forbidden_top", "staged_top_rule_forbidden", 0 },
    { "no_budget", "staged_budget_exhausted", 0 },
    { "one_call", "staged_call_limit_exceeded", 1 },
  }) do
    local changed = parent_builder(M.seed(child, child_digest, calls, row[1]))
    clear(calls); M.rejects(changed, "[1][2]", row[2])
    assert(#calls == row[3], "callback count: " .. row[1])
  end
  local first, second = parse("α[12]🙂"), parse("α[12]🙂")
  M.actual_result_isolation(first, second)
  local aliased = copy(second)
  local ok, failure = pcall(M.actual_result_isolation, aliased, aliased)
  assert(not ok and failure == "actual child results alias", "deliberate alias must fail the isolation oracle")
  clear(calls); M.composed(parse("α[12]🙂"), case_by_id(cases, "unicode_edges"), calls)
  clear(calls)
  local inert = parent_builder(nil)("α[12]🙂")
  exact(inert[2].child.kind, "STAGED_PARSE_JOB_MARKER")
  exact(inert[2].child.staged_parse_job_v2.text, "12")
  assert(#calls == 0, "no seed executes no child")
  assert(#strict.accept == 4 and #strict.reject == 15, "strict child inventory")
  for _, row in ipairs(strict.accept) do exact(child(row.input), row.expected) end
  for _, input in ipairs(strict.reject) do
    local accepted, rejected = pcall(child, input)
    assert(not accepted and linkedspec.is_runtime_exit_now(rejected), "typed child rejection: " .. input)
    exact(rejected.status, 1)
  end
  return records
end

function M.child_mutation(id, parent_builder, child, child_digest)
  local calls = A()
  local parse = parent_builder(M.seed(child, child_digest, calls))
  if id == "leading_zero" then
    exact(parse("[00]").ast[2].parsed, D({ kind = "integer", text = "00",
      span = D({ start = 0, ["end"] = 2 }), source_span = D({ kind = "direct_span",
        source_id = "input", start = 1, ["end"] = 3, provenance = "entry_group" }) }))
  elseif id == "wrong_span" then
    local result = parse("α[12]🙂").ast[2].parsed
    exact(result.span, D({ start = 1, ["end"] = 2 }))
    exact(result.source_span, D({ kind = "direct_span", source_id = "input",
      start = 3, ["end"] = 4, provenance = "entry_group" }))
  elseif id == "whole_item" then
    M.rejects(parse, "α[12]🙂", "staged_child_failed")
    exact(calls, A({ D({ text = "[12]", top = "Number" }) }))
  else error("unknown child mutation " .. id) end
  return true
end

function M.segment_mutation(id, cases, parse)
  local row = case_by_id(cases, id == "selection" and "single_zero" or
    id == "entry_prefix" and "leading_lf" or "unicode_edges")
  local expected = copy(row.expected)
  if id == "selection" then
    expected = A({ D({ kind = "tail", span = D({ source_id = "input", start = 0,
      ["end"] = 3, provenance = "gap" }), text = "[0]" }) })
  elseif id == "tail" then table.remove(expected)
  elseif id == "item_span" then expected[2].span = A({ 5, 5 })
  elseif id == "entry_prefix" then table.remove(expected, 1)
  else error("unknown segment mutation " .. id) end
  exact(parse(row.input), expected, "controlled " .. id .. " mutation")
  assert(json.encode(expected) ~= json.encode(row.expected), "mutant differs from original oracle")
  return true
end

return M
