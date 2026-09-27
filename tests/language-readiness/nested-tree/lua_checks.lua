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

function M.sequence(cases, parse)
  assert(#cases.accept == 6 and #cases.reject == 7, "authored inventory")
  local recovery = find_case(cases.accept, "nested_state")
  local executions = 0
  for _ = 1, 2 do
    for _, row in ipairs(cases.accept) do
      M.exact_json(parse(row.input), row.expected, row.id)
      executions = executions + 1
    end
    for _, row in ipairs(cases.reject) do
      local ok, failure = pcall(parse, row.input)
      assert(not ok and linkedspec.is_runtime_exit_now(failure), row.id .. ": typed rejection")
      assert(failure.status == 1, row.id .. ": exact status")
      M.exact_json(parse(recovery.input), recovery.expected, "recovery after " .. row.id)
      executions = executions + 2
    end
  end
  assert(executions == 40, "complete execution sequence")
  return executions
end

function M.mutation(id, cases, parse)
  local row
  if id == "prefix" then
    row = find_case(cases.reject, "hidden_prefix")
  elseif id == "gap" then
    row = find_case(cases.reject, "interstitial_junk")
  elseif id == "span" then
    row = find_case(cases.accept, "nested_state")
  else
    error("unknown mutation " .. id)
  end
  local value = parse(row.input)
  assert(json.kind(value) == "array", id .. ": mutant must execute and return a document")
  if id == "span" then
    M.exact_json(value[1].span, json.array({ 9, 9 }), "wrong start span")
    M.exact_json(row.expected[1].span, json.array({ 0, 9 }), "unchanged authored span")
  else
    assert(#value == (id == "prefix" and 1 or 2), id .. ": mutant wrongly accepts forms")
  end
  return true
end

function M.variant(id, cases, parse)
  if id == "original" then return M.sequence(cases, parse) == 40 end
  return M.mutation(id, cases, parse)
end

return M
