local linkedspec = require("linkedspec")
local json = linkedspec.json
local M = {}

function M.exact_json(actual, expected, label)
  -- Canonical JSON preserves array/object tags and scalar kinds, including empty arrays.
  local observed, wanted = json.encode(actual), json.encode(expected)
  assert(observed == wanted, (label or "value") .. ": expected " .. wanted .. ", got " .. observed)
  return true
end

local function find_case(cases, id)
  for _, row in ipairs(cases) do
    if row.id == id then return row end
  end
  error("missing authored case " .. id)
end

function M.sequence(cases, parse, options)
  options = options or {}
  local accepted_count, rejected_count = options.accepted_count or 6, options.rejected_count or 7
  local recovery_id = options.recovery_id or "nested_state"
  assert(#cases.accept == accepted_count and #cases.reject == rejected_count, "authored inventory")
  local recovery = find_case(cases.accept, recovery_id)
  local executions = 0
  for _ = 1, 2 do
    for _, row in ipairs(cases.accept) do
      M.exact_json(parse(row.input), row.expected, row.id)
      executions = executions + 1
    end
    for _, row in ipairs(cases.reject) do
      local ok, failure = pcall(parse, row.input)
      assert(not ok and linkedspec.is_runtime_exit_now(failure), row.id .. ": typed rejection")
      assert(failure.status == (row.status or 1), row.id .. ": exact status")
      M.exact_json(parse(recovery.input), recovery.expected, "recovery after " .. row.id)
      executions = executions + 2
    end
  end
  assert(executions == 2 * (accepted_count + 2 * rejected_count), "complete execution sequence")
  return executions
end

function M.mutation(id, cases, parse, options)
  options = options or {}
  local span_case, span_end = options.span_case or "nested_state", options.span_end or 9
  if id == "comparison" then
    return M.exact_json(parse(find_case(cases.reject, "mismatch").input),
      find_case(cases.accept, "empty_element").expected, "comparison mutant")
  elseif id == "state" then
    local ok, failure = pcall(parse, find_case(cases.accept, "siblings_restore_parent").input)
    assert(not ok and linkedspec.is_runtime_exit_now(failure), "state mutant typed rejection")
    assert(failure.status == 2, "state mutant exact mismatch status")
    return true
  end
  local row
  if id == "prefix" then
    row = find_case(cases.reject, "hidden_prefix")
  elseif id == "gap" then
    row = find_case(cases.reject, "interstitial_junk")
  elseif id == "span" then
    row = find_case(cases.accept, span_case)
  else
    error("unknown mutation " .. id)
  end
  local value = parse(row.input)
  assert(json.kind(value) == "array", id .. ": mutant must execute and return a document")
  if id == "span" then
    M.exact_json(value[1].span, json.array({ span_end, span_end }), "wrong start span")
    M.exact_json(row.expected[1].span, json.array({ 0, span_end }), "unchanged authored span")
  else
    assert(#value == (id == "prefix" and 1 or 2), id .. ": mutant wrongly accepts forms")
  end
  return true
end

function M.variant(id, cases, parse, options)
  options = options or {}
  if id == "original" then
    return M.sequence(cases, parse, options) ==
      2 * ((options.accepted_count or 6) + 2 * (options.rejected_count or 7))
  end
  return M.mutation(id, cases, parse, options)
end

return M
