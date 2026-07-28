-- Package-private immutable semantic-query-v1 protocol and complete static
-- evaluator. Public construction and raw-neutral validation are deliberately
-- deferred to the next task-tree leaf.

local json = require("linkedspec.json")

local M = {}

local MODEL_ID = "linkedspec-semantic-model-v1"
local QUERY_ID = "linkedspec-semantic-query-v1"
local PAGE_DEFAULT = 100
local PAGE_MAX = 1000
local RECORD_BUDGET_DEFAULT = 1000
local RELATION_BUDGET_DEFAULT = 2000
local DEPTH_BUDGET_DEFAULT = 4
local RECORD_BUDGET_MAX = 10000
local RELATION_BUDGET_MAX = 20000
local DEPTH_BUDGET_MAX = 8

local RECORD_KINDS = {
  "capabilities", "spec", "source", "rule", "regex_slot", "edge", "lifecycle",
  "function", "helper", "binding", "call", "staged_artifact", "generated_artifact",
  "diagnostic", "decision", "execution", "event", "explanation_step",
}

local RELATION_KINDS = {
  "declares", "contains", "depends_on", "dispatches_to", "selects_regex", "calls",
  "resolves_to", "reads", "writes", "consumes", "produces", "lowered_from",
  "staged_by", "generated_as", "diagnoses", "observed_as", "explained_by",
}

local OPERATIONS = {
  capabilities = true,
  list = true,
  get = true,
  relations = true,
  explain = true,
}

local DIRECTIONS = { outgoing = true, incoming = true, both = true }
local SOURCE_DETAIL_RANK = { none = 0, identity = 1, span = 2, text = 3 }
local VALUE_STATE = setmetatable({}, { __mode = "k" })
local REQUEST_STATE = setmetatable({}, { __mode = "k" })
local FROZEN_NULL = {}
local FROZEN_OBJECT = {}
local FROZEN_ARRAY = {}
local VALUE_METHODS = {}

local function empty_pairs()
  return function() return nil end, nil, nil
end

local function immutable_newindex()
  error("Semantic query values are immutable", 0)
end

local function finite_number(value)
  return value == value and value ~= math.huge and value ~= -math.huge
end

local function freeze_json(value, active)
  if value == nil or value == json.null then return FROZEN_NULL end
  local value_type = type(value)
  if value_type == "string" or value_type == "boolean" then return value end
  if value_type == "number" then
    if not finite_number(value) then error("Semantic query value contains a non-finite number", 0) end
    return value
  end
  if value_type ~= "table" then
    error("Semantic query value contains an unsupported host type", 0)
  end
  if VALUE_STATE[value] ~= nil then return value end

  local kind = json.kind(value)
  if kind ~= "array" and kind ~= "harray" then
    error("Semantic query value contains an ambiguous or host table", 0)
  end
  active = active or {}
  if active[value] then error("Semantic query value contains a cycle", 0) end
  active[value] = true

  local frozen = { tag = kind == "array" and FROZEN_ARRAY or FROZEN_OBJECT, values = {} }
  if kind == "array" then
    local count = 0
    for key in next, value do
      if type(key) ~= "number" or key < 1 or key ~= math.floor(key) then
        error("Semantic query array contains a non-index key", 0)
      end
      count = count + 1
    end
    if count ~= #value then error("Semantic query array contains a hole", 0) end
    for index = 1, #value do
      frozen.values[index] = freeze_json(value[index], active)
    end
  else
    for key, item in next, value do
      if type(key) ~= "string" then
        error("Semantic query object contains a non-text key", 0)
      end
      frozen.values[key] = freeze_json(item, active)
    end
  end
  active[value] = nil
  return frozen
end

local protocol_to_json

local function thaw_collection(value)
  if value == FROZEN_NULL then return json.null end
  if type(value) ~= "table" then return value end
  if VALUE_STATE[value] ~= nil then return value end
  if value.tag == FROZEN_ARRAY then
    local result = json.array()
    for index = 1, #value.values do result[index] = thaw_collection(value.values[index]) end
    return result
  end
  if value.tag == FROZEN_OBJECT then
    local result = json.harray()
    for key, item in next, value.values do result[key] = thaw_collection(item) end
    return result
  end
  error("Semantic query retained value is invalid", 0)
end

local function thaw_access(value)
  if value == FROZEN_NULL then return nil end
  if type(value) == "table" and VALUE_STATE[value] == nil and
      (value.tag == FROZEN_ARRAY or value.tag == FROZEN_OBJECT) then
    return thaw_collection(value)
  end
  return value
end

local function thaw_json(value)
  if value == FROZEN_NULL then return json.null end
  if type(value) ~= "table" then return value end
  if VALUE_STATE[value] ~= nil then return protocol_to_json(value) end
  if value.tag == FROZEN_ARRAY then
    local result = json.array()
    for index = 1, #value.values do result[index] = thaw_json(value.values[index]) end
    return result
  end
  if value.tag == FROZEN_OBJECT then
    local result = json.harray()
    for key, item in next, value.values do result[key] = thaw_json(item) end
    return result
  end
  error("Semantic query retained value is invalid", 0)
end

local function value_index(value, key)
  local method = VALUE_METHODS[key]
  if method ~= nil then return method end
  local state = VALUE_STATE[value]
  if state == nil then return nil end
  local field = state.fields.values[key]
  if field == nil then return nil end
  return thaw_access(field)
end

local VALUE_MT = {
  __index = value_index,
  __newindex = immutable_newindex,
  __pairs = empty_pairs,
  __metatable = "protected",
  __tostring = function(value)
    local state = VALUE_STATE[value]
    return state == nil and "SemanticQueryValue" or state.kind
  end,
}

local function protocol_value(kind, fields)
  if json.kind(fields) ~= "harray" then
    error("Semantic query protocol fields must be an object", 0)
  end
  local result = setmetatable({}, VALUE_MT)
  VALUE_STATE[result] = { kind = kind, fields = freeze_json(fields) }
  return result
end

protocol_to_json = function(value)
  local state = VALUE_STATE[value]
  if state == nil then error("Invalid semantic query protocol value", 0) end
  return thaw_json(state.fields)
end

function VALUE_METHODS.to_json(value)
  return protocol_to_json(value)
end

local function require_plain_options(value, label, allowed)
  if value == nil then return {} end
  if type(value) ~= "table" or getmetatable(value) ~= nil then
    error("Semantic query " .. label .. " must be a plain table", 0)
  end
  for key in next, value do
    if type(key) ~= "string" or not allowed[key] then
      error("Semantic query " .. label .. " contains an unknown field", 0)
    end
  end
  return value
end

local function portable_integer(value, label, minimum, maximum)
  if type(value) ~= "number" or not finite_number(value) or value ~= math.floor(value) then
    error("Semantic query " .. label .. " must be a finite integer", 0)
  end
  if value < minimum or value > maximum then
    error("Semantic query " .. label .. " is outside the supported range", 0)
  end
  return value
end

local function copy_string_array(value, label)
  if value == nil then return json.array() end
  if type(value) ~= "table" or getmetatable(value) ~= nil then
    error("Semantic query " .. label .. " must be a plain sequence", 0)
  end
  local count = 0
  for key in next, value do
    if type(key) ~= "number" or key < 1 or key ~= math.floor(key) then
      error("Semantic query " .. label .. " must be a plain sequence", 0)
    end
    count = count + 1
  end
  if count ~= #value then error("Semantic query " .. label .. " contains a hole", 0) end
  local result = json.array()
  local seen = {}
  for index = 1, #value do
    local item = value[index]
    if type(item) ~= "string" then
      error("Semantic query " .. label .. " must contain only text", 0)
    end
    if seen[item] then error("Semantic query " .. label .. " contains a duplicate", 0) end
    seen[item] = true
    result[index] = item
  end
  return result
end

local function validate_ranked(values, label, ordered)
  local last = 0
  local rank = {}
  for index, item in ipairs(ordered) do rank[item] = index end
  for _, item in ipairs(values) do
    local current = rank[item]
    if current == nil then error("Semantic query " .. label .. " contains an unknown kind", 0) end
    if current <= last then error("Semantic query " .. label .. " is not rank ordered", 0) end
    last = current
  end
end

local function request_page(options)
  options = require_plain_options(options, "page", { after_id = true, limit = true })
  local after_id = options.after_id
  if after_id ~= nil and type(after_id) ~= "string" then
    error("Semantic query after_id must be text when present", 0)
  end
  local limit = options.limit
  if limit == nil then limit = PAGE_DEFAULT end
  limit = portable_integer(limit, "limit", 1, PAGE_MAX)
  return protocol_value("SemanticQueryPage", json.harray({
    after_id = after_id == nil and json.null or after_id,
    limit = limit,
  })), after_id, limit
end

local function request_budget(options)
  options = require_plain_options(options, "budget", {
    max_records = true, max_relations = true, max_depth = true,
  })
  local max_records = options.max_records
  if max_records == nil then max_records = RECORD_BUDGET_DEFAULT end
  max_records = portable_integer(max_records, "max_records", 1, RECORD_BUDGET_MAX)
  local max_relations = options.max_relations
  if max_relations == nil then max_relations = RELATION_BUDGET_DEFAULT end
  max_relations = portable_integer(max_relations, "max_relations", 1, RELATION_BUDGET_MAX)
  local max_depth = options.max_depth
  if max_depth == nil then max_depth = DEPTH_BUDGET_DEFAULT end
  max_depth = portable_integer(max_depth, "max_depth", 0, DEPTH_BUDGET_MAX)
  return protocol_value("SemanticQueryBudget", json.harray({
    max_records = max_records,
    max_relations = max_relations,
    max_depth = max_depth,
  })), max_records, max_relations, max_depth
end

local function request_source(options)
  options = require_plain_options(options, "source", {
    detail = true, include_content_digest = true,
  })
  local detail = options.detail
  if detail == nil then detail = "none" end
  if SOURCE_DETAIL_RANK[detail] == nil then
    error("Semantic query source detail must be none, identity, span, or text", 0)
  end
  local include_digest = options.include_content_digest
  if include_digest == nil then include_digest = false end
  if type(include_digest) ~= "boolean" then
    error("Semantic query include_content_digest must be Boolean", 0)
  end
  return protocol_value("SemanticQuerySource", json.harray({
    detail = detail,
    include_content_digest = include_digest,
  })), detail, include_digest
end

function M.request(operation, options)
  if type(operation) ~= "string" or not OPERATIONS[operation] then
    error("Semantic query operation is invalid", 0)
  end
  options = require_plain_options(options, "options", {
    contract = true,
    subjects = true,
    record_kinds = true,
    relation_kinds = true,
    direction = true,
    page = true,
    budget = true,
    source = true,
  })
  local contract = options.contract
  if contract == nil then contract = QUERY_ID end
  if type(contract) ~= "string" then error("Semantic query contract must be text", 0) end
  local subjects = copy_string_array(options.subjects, "subjects")
  local record_kinds = copy_string_array(options.record_kinds, "record_kinds")
  local relation_kinds = copy_string_array(options.relation_kinds, "relation_kinds")
  validate_ranked(record_kinds, "record_kinds", RECORD_KINDS)
  validate_ranked(relation_kinds, "relation_kinds", RELATION_KINDS)
  local direction = options.direction
  if direction == nil then direction = "outgoing" end
  if type(direction) ~= "string" or not DIRECTIONS[direction] then
    error("Semantic query direction is invalid", 0)
  end
  local page, after_id, limit = request_page(options.page)
  local budget, max_records, max_relations, max_depth = request_budget(options.budget)
  local source, detail, include_digest = request_source(options.source)

  local result = protocol_value("SemanticQueryRequest", json.harray({
    contract = contract,
    operation = operation,
    subjects = subjects,
    record_kinds = record_kinds,
    relation_kinds = relation_kinds,
    direction = direction,
    page = page,
    budget = budget,
    source = source,
  }))
  REQUEST_STATE[result] = {
    contract = contract,
    operation = operation,
    subjects = subjects,
    record_kinds = record_kinds,
    relation_kinds = relation_kinds,
    direction = direction,
    after_id = after_id,
    limit = limit,
    max_records = max_records,
    max_relations = max_relations,
    max_depth = max_depth,
    source_detail = detail,
    include_content_digest = include_digest,
  }
  return result
end

function M.is_request(value)
  return REQUEST_STATE[value] ~= nil
end

function M.is_response(value)
  local state = VALUE_STATE[value]
  return state ~= nil and state.kind == "SemanticQueryResponse"
end

function M.to_json(value)
  return protocol_to_json(value)
end

local function protocol_array(values)
  local result = json.array()
  for index = 1, #values do result[index] = values[index] end
  return result
end

local function page_value(after_id, next_after_id, complete)
  return protocol_value("SemanticQueryPageState", json.harray({
    after_id = after_id == nil and json.null or after_id,
    next_after_id = next_after_id == nil and json.null or next_after_id,
    complete = complete,
  }))
end

local function cost_value(records_examined, relations_examined, depth_reached)
  return protocol_value("SemanticQueryCost", json.harray({
    records_examined = records_examined,
    relations_examined = relations_examined,
    depth_reached = depth_reached,
  }))
end

local function snapshot_value(snapshot)
  return protocol_value("SemanticQuerySnapshot", json.harray({
    id = snapshot.id,
    state = snapshot.state,
    has_execution = snapshot.has_execution,
    source_detail_ceiling = snapshot.source_detail_ceiling,
    content_digest_available = snapshot.content_digest_available,
  }))
end

local function diagnostic_value(code, fields)
  local severity = "error"
  local message
  if code == "semantic_query_budget_exceeded" then
    severity = "warning"
    message = "Semantic query budget was reached; returning the deterministic prefix."
  elseif code == "semantic_query_contract_unsupported" then
    message = "Unsupported semantic query contract."
  elseif code == "semantic_query_source_detail_forbidden" then
    message = "Requested source detail exceeds the index ceiling."
  elseif code == "semantic_query_invalid" then
    message = "Invalid semantic query request."
  else
    error("Unknown semantic query diagnostic", 0)
  end
  return protocol_value("SemanticQueryDiagnostic", json.harray({
    code = code,
    severity = severity,
    message = message,
    fields = fields,
  }))
end

local function response_value(snapshot, request, ok, records, relations, diagnostics, options)
  options = options or {}
  return protocol_value("SemanticQueryResponse", json.harray({
    contract = QUERY_ID,
    model = MODEL_ID,
    ok = ok,
    snapshot = snapshot_value(snapshot),
    records = protocol_array(records),
    relations = protocol_array(relations),
    page = page_value(
      request.after_id,
      options.next_after_id,
      options.complete == nil and true or options.complete
    ),
    cost = cost_value(
      options.records_examined or #records,
      options.relations_examined or #relations,
      options.depth_reached or 0
    ),
    diagnostics = protocol_array(diagnostics),
  }))
end

local function rejected_response(snapshot, request, diagnostic)
  return response_value(snapshot, request, false, {}, {}, { diagnostic })
end

local function record_value(record, source, facts, redactions)
  return protocol_value("SemanticQueryRecord", json.harray({
    id = record.id,
    kind = record.kind,
    name = record.name,
    owner_id = record.owner_id,
    order = record.order,
    source = source,
    facts = facts,
    redactions = redactions,
  }))
end

local function relation_value(relation, source)
  return protocol_value("SemanticQueryRelation", json.harray({
    id = relation.id,
    kind = relation.kind,
    from_id = relation.from_id,
    to_id = relation.to_id,
    order = relation.order,
    source = source,
    facts = relation.facts,
    evidence_ids = relation.evidence_ids,
  }))
end

local function detached_json(value)
  return thaw_json(freeze_json(value))
end

local function project_source(source_key, projection, request)
  if source_key == nil or source_key == json.null or request.source_detail == "none" then
    return json.null
  end
  local full = projection.source_refs[source_key]
  if full == nil then error("Semantic query record references an unknown source", 0) end
  local span = json.null
  if SOURCE_DETAIL_RANK[request.source_detail] >= SOURCE_DETAIL_RANK.span then
    span = detached_json(full.span)
  end
  local excerpt = request.source_detail == "text" and full.excerpt or json.null
  local content_digest = request.source_detail == "text" and
    request.include_content_digest and full.content_digest or json.null
  return protocol_value("SemanticQuerySourceReference", json.harray({
    source_id = full.source_id,
    logical_name = full.logical_name,
    span = span,
    excerpt = excerpt,
    content_digest = content_digest,
    provenance_ids = full.provenance_ids,
  }))
end

local function project_record(record, projection, request)
  local facts = detached_json(record.facts)
  local sensitive_key
  if record.kind == "regex_slot" then
    sensitive_key = "pattern"
  elseif record.kind == "diagnostic" then
    sensitive_key = "message"
  elseif record.kind == "explanation_step" then
    sensitive_key = "summary"
  end
  local redactions = detached_json(record.redactions)
  if request.source_detail ~= "text" and sensitive_key ~= nil then
    facts[sensitive_key] = json.null
    redactions = json.array({ "/facts/" .. sensitive_key })
  end
  return record_value(
    record,
    project_source(record.source, projection, request),
    facts,
    redactions
  )
end

local function project_relation(relation, projection, request)
  return relation_value(relation, project_source(relation.source, projection, request))
end

local function capabilities_record(snapshot)
  return record_value(
    {
      id = "capabilities:0",
      kind = "capabilities",
      name = "semantic introspection v1",
      owner_id = json.null,
      order = 0,
    },
    json.null,
    json.harray({
      model_ids = json.array({ MODEL_ID }),
      query_ids = json.array({ QUERY_ID }),
      record_kinds = json.array(RECORD_KINDS),
      relation_kinds = json.array(RELATION_KINDS),
      source_detail_ceiling = snapshot.source_detail_ceiling,
      page_default = PAGE_DEFAULT,
      page_max = PAGE_MAX,
      budget_defaults = json.harray({
        max_records = RECORD_BUDGET_DEFAULT,
        max_relations = RELATION_BUDGET_DEFAULT,
        max_depth = DEPTH_BUDGET_DEFAULT,
      }),
      budget_maxima = json.harray({
        max_records = RECORD_BUDGET_MAX,
        max_relations = RELATION_BUDGET_MAX,
        max_depth = DEPTH_BUDGET_MAX,
      }),
      execution_observation = snapshot.has_execution,
      features = json.array(),
    }),
    json.array()
  )
end

local function validate_owned_request(snapshot, request)
  if request.contract ~= QUERY_ID then
    return rejected_response(snapshot, request, diagnostic_value(
      "semantic_query_contract_unsupported",
      json.harray({
        requested = request.contract,
        supported = json.array({ QUERY_ID }),
      })
    ))
  end
  if request.include_content_digest and request.source_detail ~= "text" then
    return rejected_response(snapshot, request, diagnostic_value(
      "semantic_query_invalid",
      json.harray({ reason = "digest_requires_text" })
    ))
  end
  if SOURCE_DETAIL_RANK[request.source_detail] > SOURCE_DETAIL_RANK[snapshot.source_detail_ceiling] or
      (request.include_content_digest and not snapshot.content_digest_available) then
    return rejected_response(
      snapshot, request,
      diagnostic_value("semantic_query_source_detail_forbidden", json.harray({
        requested = request.source_detail,
        ceiling = snapshot.source_detail_ceiling,
      }))
    )
  end

  local valid = false
  if request.operation == "capabilities" or request.operation == "list" then
    valid = #request.subjects == 0 and #request.relation_kinds == 0
  elseif request.operation == "get" then
    valid = #request.subjects > 0 and #request.record_kinds == 0 and
      #request.relation_kinds == 0
  elseif request.operation == "relations" then
    valid = #request.subjects > 0 and #request.record_kinds == 0
  elseif request.operation == "explain" then
    valid = #request.subjects == 1 and #request.record_kinds == 0 and
      #request.relation_kinds == 0
  end
  if not valid or (request.operation == "capabilities" and #request.record_kinds > 0) then
    return rejected_response(snapshot, request, diagnostic_value(
      "semantic_query_invalid",
      json.harray({
        reason = request.operation == "capabilities" and #request.record_kinds > 0 and
          "capability_filter" or "operation_combination",
      })
    ))
  end
  return nil
end

local function page_stream(items, request, budget_limit)
  local start = 1
  if request.after_id ~= nil then
    local cursor
    for index, item in ipairs(items) do
      if item.id == request.after_id then
        cursor = index
        break
      end
    end
    if cursor == nil then return nil end
    start = cursor + 1
  end

  local remaining = #items - start + 1
  if remaining < 0 then remaining = 0 end
  local limited_by_budget = remaining > budget_limit
  local selected_count = math.min(remaining, request.limit, budget_limit)
  local selected = {}
  for offset = 0, selected_count - 1 do selected[#selected + 1] = items[start + offset] end
  local complete = selected_count == remaining and not limited_by_budget
  local next_after_id
  if #selected > 0 and not complete then next_after_id = selected[#selected].id end
  return {
    selected = selected,
    next_after_id = next_after_id,
    complete = complete,
    limited_by_budget = limited_by_budget,
  }
end

local function relation_layer(relations, frontier, wanted_kinds, direction, selected_ids)
  local result = {}
  for _, relation in ipairs(relations) do
    local kind_matches = next(wanted_kinds) == nil or wanted_kinds[relation.kind]
    local outgoing = (direction == "outgoing" or direction == "both") and
      frontier[relation.from_id]
    local incoming = (direction == "incoming" or direction == "both") and
      frontier[relation.to_id]
    if kind_matches and (outgoing or incoming) and not selected_ids[relation.id] then
      result[#result + 1] = relation
    end
  end
  return result
end

local function traverse_relations(relations, request)
  local wanted_kinds = {}
  for _, kind in ipairs(request.relation_kinds) do wanted_kinds[kind] = true end
  local frontier = {}
  local visited = {}
  for _, id in ipairs(request.subjects) do frontier[id], visited[id] = true, true end
  local depth_by_id = {}

  for depth = 1, request.max_depth do
    local layer = relation_layer(relations, frontier, wanted_kinds, request.direction, depth_by_id)
    if #layer == 0 then break end
    local next_frontier = {}
    for _, relation in ipairs(layer) do
      depth_by_id[relation.id] = depth
      if (request.direction == "outgoing" or request.direction == "both") and
          frontier[relation.from_id] then
        next_frontier[relation.to_id] = true
      end
      if (request.direction == "incoming" or request.direction == "both") and
          frontier[relation.to_id] then
        next_frontier[relation.from_id] = true
      end
    end
    for id in next, visited do next_frontier[id] = nil end
    for id in next, next_frontier do visited[id] = true end
    frontier = next_frontier
    if next(frontier) == nil then break end
  end

  local depth_limited = next(frontier) ~= nil and
    #relation_layer(relations, frontier, wanted_kinds, request.direction, depth_by_id) > 0
  local selected = {}
  for _, relation in ipairs(relations) do
    if depth_by_id[relation.id] ~= nil then selected[#selected + 1] = relation end
  end
  return { relations = selected, depth_by_id = depth_by_id, depth_limited = depth_limited }
end

local function invalid_response(snapshot, request, reason)
  return rejected_response(snapshot, request, diagnostic_value(
    "semantic_query_invalid",
    json.harray({ reason = reason })
  ))
end

local function project_page_records(candidates, projection, request, budget_limit)
  local paged = page_stream(candidates, request, budget_limit)
  if paged == nil then return nil end
  local records = {}
  for _, record in ipairs(paged.selected) do
    records[#records + 1] = project_record(record, projection, request)
  end
  paged.projected = records
  return paged
end

function M.evaluate(projection, request_value)
  local request = REQUEST_STATE[request_value]
  if request == nil then error("Semantic query kernel requires a typed request", 0) end
  if json.kind(projection) ~= "harray" or json.kind(projection.snapshot) ~= "harray" or
      json.kind(projection.source_refs) ~= "harray" or
      json.kind(projection.records) ~= "array" or json.kind(projection.relations) ~= "array" then
    error("Semantic query kernel requires one detached static projection", 0)
  end
  local snapshot = {
    id = projection.snapshot.id,
    state = projection.snapshot.state,
    has_execution = projection.snapshot.has_execution,
    source_detail_ceiling = projection.snapshot.source_detail_ceiling,
    content_digest_available = projection.snapshot.content_digest_available,
  }
  local request_error = validate_owned_request(snapshot, request)
  if request_error ~= nil then return request_error end

  local record_by_id = {}
  for _, record in ipairs(projection.records) do record_by_id[record.id] = record end
  if (request.operation == "get" or request.operation == "relations") then
    for _, subject in ipairs(request.subjects) do
      if record_by_id[subject] == nil then return invalid_response(snapshot, request, "unknown_subject") end
    end
  end

  local selected_records = {}
  local selected_relations = {}
  local page = { next_after_id = nil, complete = true }
  local record_cost = 0
  local relation_cost = 0
  local depth_reached = 0
  local budget_reason

  if request.operation == "capabilities" then
    local paged = page_stream({ capabilities_record(snapshot) }, request, request.max_records)
    if paged == nil then return invalid_response(snapshot, request, "after_id_not_in_primary_stream") end
    selected_records = paged.selected
    page = paged
    record_cost = #selected_records
    if paged.limited_by_budget then budget_reason = "max_records" end
  elseif request.operation == "list" then
    local wanted = {}
    for _, kind in ipairs(request.record_kinds) do wanted[kind] = true end
    local candidates = {}
    for _, record in ipairs(projection.records) do
      if #request.record_kinds == 0 or wanted[record.kind] then
        candidates[#candidates + 1] = record
      end
    end
    local paged = project_page_records(candidates, projection, request, request.max_records)
    if paged == nil then return invalid_response(snapshot, request, "after_id_not_in_primary_stream") end
    selected_records = paged.projected
    page = paged
    record_cost = #selected_records
    if paged.limited_by_budget then budget_reason = "max_records" end
  elseif request.operation == "get" then
    local wanted = {}
    for _, id in ipairs(request.subjects) do wanted[id] = true end
    local candidates = {}
    for _, record in ipairs(projection.records) do
      if wanted[record.id] then candidates[#candidates + 1] = record end
    end
    local paged = project_page_records(candidates, projection, request, request.max_records)
    if paged == nil then return invalid_response(snapshot, request, "after_id_not_in_primary_stream") end
    selected_records = paged.projected
    page = paged
    record_cost = #selected_records
    if paged.limited_by_budget then budget_reason = "max_records" end
  elseif request.operation == "relations" then
    local traversal = traverse_relations(projection.relations, request)
    local paged = page_stream(traversal.relations, request, request.max_relations)
    if paged == nil then return invalid_response(snapshot, request, "after_id_not_in_primary_stream") end
    for _, relation in ipairs(paged.selected) do
      selected_relations[#selected_relations + 1] = project_relation(relation, projection, request)
      depth_reached = math.max(depth_reached, traversal.depth_by_id[relation.id])
    end
    page = paged
    relation_cost = #selected_relations
    if paged.limited_by_budget then
      budget_reason = "max_relations"
    elseif traversal.depth_limited then
      budget_reason = "max_depth"
    end
  else
    local subject = request.subjects[1]
    local decision = record_by_id[subject]
    if decision ~= nil and decision.kind ~= "decision" then decision = nil end
    if decision == nil then
      local owned = {}
      for _, record in ipairs(projection.records) do
        if record.kind == "decision" and record.owner_id == subject then owned[#owned + 1] = record end
      end
      if #owned == 1 then decision = owned[1] end
    end
    if decision == nil then return invalid_response(snapshot, request, "not_explainable") end
    local steps = {}
    for _, record in ipairs(projection.records) do
      if record.kind == "explanation_step" and record.owner_id == decision.id then
        steps[#steps + 1] = record
      end
    end
    local paged = project_page_records(steps, projection, request, request.max_records - 1)
    if paged == nil then return invalid_response(snapshot, request, "after_id_not_in_primary_stream") end
    selected_records[1] = project_record(decision, projection, request)
    local selected_steps = {}
    for _, step in ipairs(paged.selected) do selected_steps[step.id] = true end
    for _, step in ipairs(paged.projected) do selected_records[#selected_records + 1] = step end
    for _, relation in ipairs(projection.relations) do
      if relation.kind == "explained_by" and relation.from_id == decision.id and
          selected_steps[relation.to_id] then
        selected_relations[#selected_relations + 1] = project_relation(relation, projection, request)
      end
    end
    page = paged
    record_cost = #selected_records
    relation_cost = #selected_relations
    depth_reached = #paged.selected > 0 and 1 or 0
    if paged.limited_by_budget then budget_reason = "max_records" end
  end

  local diagnostics = {}
  if budget_reason ~= nil then
    page.complete = false
    diagnostics[1] = diagnostic_value(
      "semantic_query_budget_exceeded",
      json.harray({ limit = budget_reason })
    )
  end
  return response_value(
    snapshot,
    request,
    true,
    selected_records,
    selected_relations,
    diagnostics,
    {
      next_after_id = page.next_after_id,
      complete = page.complete,
      records_examined = record_cost,
      relations_examined = relation_cost,
      depth_reached = depth_reached,
    }
  )
end

return M
