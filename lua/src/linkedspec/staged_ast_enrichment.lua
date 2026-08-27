-- Private caller-frozen authority for one complete staged-AST marker depth.
--
-- Trusted host code supplies a completed logical resolution snapshot and the
-- exact already-compiled callbacks named by that snapshot.  Dispatch performs
-- no discovery, loading, compilation, provider query, filesystem access, or
-- registry mutation.  Child values are detached before an unpublished AST
-- copy is stitched and returned.

local json = require("linkedspec.json")
local sha256 = require("linkedspec.sha256")

local M = {}

local ERROR_PREFIX = "LINKEDSPEC_STAGED_AST_ENRICHMENT_ERROR:"
local MARKER_KIND = "STAGED_PARSE_JOB_MARKER"
local SIDECAR_KIND = "staged_parse_job_v2"
local MAX_EXACT_INTEGER = 9007199254740991
local SOURCE_DETAILS = { none = 0, identity = 1, span = 2, text = 3 }
local SOURCE_DETAIL_NAMES = { [0] = "none", [1] = "identity", [2] = "span", [3] = "text" }
local LIVE_RESULT_KEYS = {
  ["$ref"] = true,
  parser = true,
  parser_handle = true,
  registry = true,
  source_authority = true,
  frame = true,
  transaction = true,
  cancellation = true,
  callback = true,
  host = true,
  path = true,
  live_handle = true,
}

local private_state = setmetatable({}, { __mode = "k" })
local token_metatables = {}
local CONTEXT_MT = { __metatable = "private StagedRuntimeContext" }

local function token_metatable(node_type)
  local current = token_metatables[node_type]
  if current ~= nil then return current end
  current = {
    __metatable = "private " .. node_type,
    __newindex = function() error(node_type .. " is opaque", 2) end,
    __tostring = function(value)
      local state = private_state[value]
      if state ~= nil and state.node_type == "StagedAstEnrichmentException" then
        return ERROR_PREFIX .. state.record.code
      end
      return node_type .. "(<opaque>)"
    end,
  }
  token_metatables[node_type] = current
  return current
end

local function new_token(node_type, state)
  state.node_type = node_type
  local token = setmetatable({}, token_metatable(node_type))
  private_state[token] = state
  return token
end

local function state_of(value, expected)
  local state = type(value) == "table" and private_state[value] or nil
  if state == nil or state.node_type ~= expected then
    error("staged AST enrichment expects " .. expected, 0)
  end
  return state
end

local function is_integer(value)
  return type(value) == "number" and value == math.floor(value) and
    value >= -MAX_EXACT_INTEGER and value <= MAX_EXACT_INTEGER
end

local function dense_array(value)
  if type(value) ~= "table" then return false end
  local count = 0
  local maximum = 0
  for key in pairs(value) do
    if not is_integer(key) or key < 1 then return false end
    count = count + 1
    if key > maximum then maximum = key end
  end
  return count == maximum
end

local function plain_table_kind(value)
  local kind = json.kind(value)
  if kind == "array" or kind == "harray" then return kind end
  if kind ~= "table" or getmetatable(value) ~= nil then return nil end
  local saw_string = false
  local saw_number = false
  for key in pairs(value) do
    if type(key) == "string" then
      saw_string = true
    elseif is_integer(key) and key >= 1 then
      saw_number = true
    else
      return nil
    end
  end
  if saw_string and saw_number then return nil end
  if saw_number then return dense_array(value) and "array" or nil end
  return "harray"
end

local function copy_plain(value, active)
  if value == nil then return nil end
  local value_type = type(value)
  if value == json.null or value_type == "boolean" or value_type == "string" then return value end
  if value_type == "number" then
    if value ~= value or value == math.huge or value == -math.huge then
      error("staged AST enrichment cannot copy a non-finite number", 0)
    end
    return value
  end
  if value_type ~= "table" or private_state[value] ~= nil then
    error("staged AST enrichment cannot copy live data", 0)
  end
  active = active or {}
  if active[value] then error("staged AST enrichment cannot copy cyclic data", 0) end
  local kind = plain_table_kind(value)
  if kind == nil then error("staged AST enrichment cannot copy non-plain data", 0) end
  active[value] = true
  local result
  if kind == "array" then
    result = json.array()
    for index = 1, #value do result[index] = copy_plain(value[index], active) end
  else
    result = json.harray()
    for key, item in pairs(value) do
      if type(key) ~= "string" then error("staged AST enrichment object key is not a string", 0) end
      result[key] = copy_plain(item, active)
    end
  end
  active[value] = nil
  return result
end

local function new_error(record)
  return new_token("StagedAstEnrichmentException", { record = copy_plain(record) })
end

local function raise(code, phase, fields)
  local record = json.harray({ code = code, phase = phase })
  for key, value in pairs(fields or {}) do record[key] = copy_plain(value) end
  error(new_error(record), 0)
end

local function raise_record(record)
  error(new_error(record), 0)
end

local function snapshot_error(component)
  raise("staged_registry_snapshot_invalid", "prepare", { snapshot_component = component })
end

function M.node_type(value)
  local state = type(value) == "table" and private_state[value] or nil
  return state and state.node_type or nil
end

function M.is_error(value)
  return M.node_type(value) == "StagedAstEnrichmentException"
end

function M.diagnostic_code(value)
  return state_of(value, "StagedAstEnrichmentException").record.code
end

function M.to_json(value)
  return copy_plain(state_of(value, "StagedAstEnrichmentException").record)
end

local function exact_keys(value, expected)
  if type(value) ~= "table" then return false end
  local count = 0
  for key in pairs(value) do
    count = count + 1
    if type(key) ~= "string" or not expected[key] then return false end
  end
  local expected_count = 0
  for _ in pairs(expected) do expected_count = expected_count + 1 end
  return count == expected_count
end

local function required_string(value, field, component)
  local result = type(value) == "table" and value[field] or nil
  if type(result) ~= "string" or result == "" then snapshot_error(component or field) end
  return result
end

local function positive_integer(value, field, component)
  local result = type(value) == "table" and value[field] or nil
  if not is_integer(result) or result <= 0 then snapshot_error(component or field) end
  return result
end

local function valid_parser_identity(value)
  if type(value) ~= "string" or not value:match("^[a-z]") then return false end
  local previous_separator = false
  for index = 2, #value do
    local character = value:sub(index, index)
    if previous_separator then
      if character:match("^[a-z]$") == nil then return false end
      previous_separator = false
    elseif character:match("^[a-z0-9]$") ~= nil then
      previous_separator = false
    elseif character == "." or character == "_" or character == ":" or
        character == "/" or character == "-" then
      previous_separator = true
    else
      return false
    end
  end
  return #value > 0 and not previous_separator
end

local function valid_top_rule(value)
  return type(value) == "string" and value:match("^[A-Za-z_][A-Za-z0-9_]*$") ~= nil
end

local function valid_digest(value)
  return type(value) == "string" and #value == 71 and value:match("^sha256:[0-9a-f]+$") ~= nil
end

local function copy_string_set(values, component, allow_empty)
  if type(values) ~= "table" or not dense_array(values) then snapshot_error(component) end
  local result = {}
  local seen = {}
  for index = 1, #values do
    local value = values[index]
    if type(value) ~= "string" or value == "" or seen[value] then snapshot_error(component) end
    seen[value] = true
    result[index] = value
  end
  if #result == 0 and not allow_empty then snapshot_error(component) end
  table.sort(result)
  return result
end

local function contains(values, expected)
  for _, value in ipairs(values) do if value == expected then return true end end
  return false
end

local function intersection(left, right)
  local allowed = {}
  for _, value in ipairs(right) do allowed[value] = true end
  local result = {}
  for _, value in ipairs(left) do
    if allowed[value] then result[#result + 1] = value end
  end
  table.sort(result)
  return result
end

local function source_detail_rank(value)
  local rank = type(value) == "string" and SOURCE_DETAILS[value] or nil
  if rank == nil then snapshot_error("source_detail") end
  return rank
end

local function parse_ceilings(value, component)
  if not exact_keys(value, {
        source_detail = true,
        max_steps = true,
        max_result_nodes = true,
        max_diagnostic_bytes = true,
      }) then snapshot_error(component) end
  local result = {
    source_detail = required_string(value, "source_detail", component),
    max_steps = positive_integer(value, "max_steps", component),
    max_result_nodes = positive_integer(value, "max_result_nodes", component),
    max_diagnostic_bytes = positive_integer(value, "max_diagnostic_bytes", component),
  }
  source_detail_rank(result.source_detail)
  return result
end

local function parse_versions(value, component)
  if not exact_keys(value, {
        spec_language_version = true,
        helper_contract_version = true,
        staged_contract_version = true,
      }) then snapshot_error(component) end
  return {
    spec_language_version = positive_integer(value, "spec_language_version", component),
    helper_contract_version = required_string(value, "helper_contract_version", component),
    staged_contract_version = positive_integer(value, "staged_contract_version", component),
  }
end

local function parse_direct_candidates(values, entries, component)
  if type(values) ~= "table" or not dense_array(values) then snapshot_error(component) end
  local result = {}
  for index, row in ipairs(values) do
    if not exact_keys(row, {
          declaring_spec_id = true,
          authored_id = true,
          resolved_spec_id = true,
        }) then snapshot_error(component) end
    local declaring = required_string(row, "declaring_spec_id", component)
    local authored = required_string(row, "authored_id", component)
    local resolved = required_string(row, "resolved_spec_id", component)
    if not valid_parser_identity(declaring) or not valid_parser_identity(authored) or entries[resolved] == nil then
      snapshot_error(component)
    end
    result[index] = {
      declaring_spec_id = declaring,
      authored_id = authored,
      resolved_spec_id = resolved,
    }
  end
  return result
end

local function parse_ordered_candidates(values, entries, identity_field, component)
  if type(values) ~= "table" or not dense_array(values) then snapshot_error(component) end
  local result = {}
  local orders = {}
  for index, row in ipairs(values) do
    if not exact_keys(row, { [identity_field] = true, order = true, candidates = true }) then
      snapshot_error(component)
    end
    local identity = required_string(row, identity_field, component)
    local order = positive_integer(row, "order", component)
    if orders[order] then snapshot_error(component) end
    orders[order] = true
    if type(row.candidates) ~= "table" or not dense_array(row.candidates) then snapshot_error(component) end
    local candidates = {}
    for candidate_index, candidate in ipairs(row.candidates) do
      if not exact_keys(candidate, { authored_id = true, resolved_spec_id = true }) then
        snapshot_error(component)
      end
      local authored = required_string(candidate, "authored_id", component)
      local resolved = required_string(candidate, "resolved_spec_id", component)
      if not valid_parser_identity(authored) or entries[resolved] == nil then snapshot_error(component) end
      candidates[candidate_index] = { authored_id = authored, resolved_spec_id = resolved }
    end
    result[index] = { identity = identity, order = order, candidates = candidates }
  end
  table.sort(result, function(left, right) return left.order < right.order end)
  return result
end

local function registry_state(value)
  return state_of(value, "FrozenStagedRegistry")
end

function M.freeze_registry(snapshot, compiled_authorities)
  if not exact_keys(snapshot, {
        immutable = true,
        prepared_before_authored_execution = true,
        filesystem_access_during_dispatch = true,
        aliases = true,
        declaring_relative = true,
        search_roots = true,
        providers = true,
        entries = true,
      }) then snapshot_error("shape") end
  if snapshot.immutable ~= true or snapshot.prepared_before_authored_execution ~= true or
      snapshot.filesystem_access_during_dispatch ~= false then
    snapshot_error("authority_boundary")
  end
  if type(compiled_authorities) ~= "table" then snapshot_error("compiled_authority") end

  local callbacks = {}
  for key, callback in pairs(compiled_authorities) do
    if type(key) ~= "string" or type(callback) ~= "function" then snapshot_error("compiled_authority") end
    callbacks[key] = callback
  end
  if type(snapshot.entries) ~= "table" or not dense_array(snapshot.entries) or #snapshot.entries == 0 then
    snapshot_error("entries")
  end
  local entries = {}
  local entry_order = {}
  local logical = copy_plain(snapshot)
  for index, row in ipairs(snapshot.entries) do
    if not exact_keys(row, {
          resolved_spec_id = true,
          compiled_authority = true,
          content_digest = true,
          import_graph_fingerprint = true,
          default_top_rule = true,
          allowed_top_rules = true,
          spec_language_version = true,
          helper_contract_version = true,
          staged_contract_version = true,
          capabilities = true,
          policy_modes = true,
          ceilings = true,
        }) then snapshot_error("entries") end
    local resolved = required_string(row, "resolved_spec_id", "resolved_spec_id")
    local authority_name = required_string(row, "compiled_authority", "compiled_authority")
    local callback = callbacks[authority_name]
    if not valid_parser_identity(resolved) or entries[resolved] ~= nil or type(callback) ~= "function" then
      snapshot_error("compiled_authority")
    end
    callbacks[authority_name] = nil
    local content_digest = required_string(row, "content_digest", "content_digest")
    local graph = required_string(row, "import_graph_fingerprint", "import_graph_fingerprint")
    local default_top = required_string(row, "default_top_rule", "default_top_rule")
    if not valid_digest(content_digest) or not valid_digest(graph) or not valid_top_rule(default_top) then
      snapshot_error("entries")
    end
    local allowed_tops = copy_string_set(row.allowed_top_rules, "allowed_top_rules", false)
    if not contains(allowed_tops, default_top) then snapshot_error("default_top_rule") end
    local entry = {
      resolved_spec_id = resolved,
      callback = callback,
      content_digest = content_digest,
      import_graph_fingerprint = graph,
      default_top_rule = default_top,
      allowed_top_rules = allowed_tops,
      versions = {
        spec_language_version = positive_integer(row, "spec_language_version", "versions"),
        helper_contract_version = required_string(row, "helper_contract_version", "versions"),
        staged_contract_version = positive_integer(row, "staged_contract_version", "versions"),
      },
      capabilities = copy_string_set(row.capabilities, "capabilities", false),
      policy_modes = copy_string_set(row.policy_modes, "policy_modes", false),
      ceilings = parse_ceilings(row.ceilings, "ceilings"),
    }
    entries[resolved] = entry
    entry_order[index] = entry
    logical.entries[index].compiled_authority = "opaque:compiled:callback"
  end
  if next(callbacks) ~= nil then snapshot_error("compiled_authority") end

  local state = {
    entries = entries,
    entry_order = entry_order,
    aliases = parse_direct_candidates(snapshot.aliases, entries, "aliases"),
    declaring_relative = parse_direct_candidates(snapshot.declaring_relative, entries, "declaring_relative"),
    search_roots = parse_ordered_candidates(snapshot.search_roots, entries, "root_id", "search_roots"),
    providers = parse_ordered_candidates(snapshot.providers, entries, "provider_id", "providers"),
    snapshot_id = "registry-snapshot:sha256:" .. sha256.hex(json.encode(logical)),
    cache = { entries = {}, count = 0, hits = 0, misses = 0 },
  }
  return new_token("FrozenStagedRegistry", state)
end

function M.snapshot_id(registry)
  return registry_state(registry).snapshot_id
end

local function array_copy(values)
  local result = json.array()
  for index, value in ipairs(values) do result[index] = copy_plain(value) end
  return result
end

function M.cache_stats(registry)
  local state = registry_state(registry)
  return json.harray({
    snapshot_id = state.snapshot_id,
    entries = state.cache.count,
    hits = state.cache.hits,
    misses = state.cache.misses,
  })
end

local function direct_matches(candidates, declaring_spec_id, parser_spec_id)
  local result = {}
  for _, candidate in ipairs(candidates) do
    if candidate.declaring_spec_id == declaring_spec_id and candidate.authored_id == parser_spec_id then
      result[#result + 1] = candidate.resolved_spec_id
    end
  end
  return result
end

function M.resolve_pre_registered(registry, options)
  local state = registry_state(registry)
  options = type(options) == "table" and options or {}
  local declaring_spec_id = options.declaring_spec_id
  local parser_spec_id = options.parser_spec_id
  local job_id = type(options.job_id) == "string" and options.job_id or "<unassigned>"
  if not valid_parser_identity(parser_spec_id) then
    raise("staged_parser_identity_invalid", "resolve", {
      origin = "post_ast",
      parser_spec_id = type(parser_spec_id) == "string" and parser_spec_id or "<invalid>",
    })
  end
  if type(declaring_spec_id) ~= "string" or declaring_spec_id == "" then snapshot_error("declaring_spec_id") end
  local aliases = direct_matches(state.aliases, declaring_spec_id, parser_spec_id)
  local relatives = direct_matches(state.declaring_relative, declaring_spec_id, parser_spec_id)
  if #aliases > 0 and #relatives > 0 then
    raise("staged_registry_collision", "resolve", {
      job_id = job_id,
      parser_spec_id = parser_spec_id,
      aliases = array_copy(aliases),
      relative_candidates = array_copy(relatives),
    })
  end
  if #aliases > 1 or #relatives > 1 then
    local matches = #aliases > 1 and aliases or relatives
    raise("staged_registry_ambiguous", "resolve", {
      job_id = job_id,
      parser_spec_id = parser_spec_id,
      priority = #aliases > 1 and "alias" or "declaring_relative",
      candidates = array_copy(matches),
    })
  end
  if #aliases == 1 then return aliases[1] end
  if #relatives == 1 then return relatives[1] end
  for _, groups in ipairs({ state.search_roots, state.providers }) do
    for _, group in ipairs(groups) do
      local matches = {}
      for _, candidate in ipairs(group.candidates) do
        if candidate.authored_id == parser_spec_id then matches[#matches + 1] = candidate.resolved_spec_id end
      end
      if #matches > 1 then
        raise("staged_registry_ambiguous", "resolve", {
          job_id = job_id,
          parser_spec_id = parser_spec_id,
          priority = group.identity,
          candidates = array_copy(matches),
        })
      end
      if #matches == 1 then return matches[1] end
    end
  end
  raise("staged_registry_missing", "resolve", {
    job_id = job_id,
    parser_spec_id = parser_spec_id,
    declaring_spec_id = declaring_spec_id,
  })
end

local function effective_authority(registry, options)
  local state = registry_state(registry)
  local entry_id = required_string(options, "entry_id", "entry_id")
  local top_rule = required_string(options, "top_rule", "top_rule")
  local job_id = type(options.job_id) == "string" and options.job_id or "<unassigned>"
  local entry = state.entries[entry_id]
  if entry == nil then
    raise("staged_registry_missing", "resolve", {
      job_id = job_id,
      parser_spec_id = entry_id,
      declaring_spec_id = "<prepared-snapshot>",
    })
  end
  local required_versions = parse_versions(options.required_versions, "required_versions")
  for _, row in ipairs({
    { "spec_language_version", required_versions.spec_language_version, entry.versions.spec_language_version },
    { "helper_contract_version", required_versions.helper_contract_version, entry.versions.helper_contract_version },
    { "staged_contract_version", required_versions.staged_contract_version, entry.versions.staged_contract_version },
  }) do
    if row[2] ~= row[3] then
      raise("staged_version_mismatch", "compile", {
        job_id = job_id,
        resolved_spec_id = entry_id,
        version_kind = row[1],
        required = row[2],
        actual = row[3],
      })
    end
  end
  if not contains(entry.allowed_top_rules, top_rule) then
    raise("staged_top_rule_forbidden", "compile", {
      job_id = job_id,
      resolved_spec_id = entry_id,
      top_rule = top_rule,
    })
  end
  local caller_capabilities = copy_string_set(options.caller_capabilities, "caller_capabilities", false)
  local required_capabilities = copy_string_set(options.required_capabilities, "required_capabilities", true)
  local capabilities = intersection(entry.capabilities, caller_capabilities)
  for _, capability in ipairs(required_capabilities) do
    if not contains(capabilities, capability) then
      raise("staged_capability_denied", "compile", {
        job_id = job_id,
        resolved_spec_id = entry_id,
        capability = capability,
      })
    end
  end
  local caller_policies = copy_string_set(options.caller_policy_modes, "caller_policy_modes", false)
  local required_policies = copy_string_set(options.required_policy_modes, "required_policy_modes", true)
  local policies = intersection(entry.policy_modes, caller_policies)
  for _, policy in ipairs(required_policies) do
    if not contains(policies, policy) then
      raise("staged_policy_denied", "compile", {
        job_id = job_id,
        resolved_spec_id = entry_id,
        policy = policy,
      })
    end
  end
  local caller_ceilings = parse_ceilings(options.caller_ceilings, "caller_ceilings")
  local effective_rank = math.min(
    source_detail_rank(caller_ceilings.source_detail),
    source_detail_rank(entry.ceilings.source_detail)
  )
  local required_detail = required_string(options, "required_source_detail", "required_source_detail")
  if effective_rank < source_detail_rank(required_detail) then
    raise("staged_source_detail_denied", "compile", {
      job_id = job_id,
      resolved_spec_id = entry_id,
      required = required_detail,
      effective = SOURCE_DETAIL_NAMES[effective_rank],
    })
  end
  return json.harray({
    capabilities = array_copy(capabilities),
    policy_modes = array_copy(policies),
    source_detail = SOURCE_DETAIL_NAMES[effective_rank],
    max_steps = math.min(caller_ceilings.max_steps, entry.ceilings.max_steps),
    max_result_nodes = math.min(caller_ceilings.max_result_nodes, entry.ceilings.max_result_nodes),
    max_diagnostic_bytes = math.min(
      caller_ceilings.max_diagnostic_bytes,
      entry.ceilings.max_diagnostic_bytes
    ),
  })
end

function M.effective_authority(registry, options)
  return effective_authority(registry, options)
end

function M.evaluate_authority_case(registry, row, job_id)
  return effective_authority(registry, {
    entry_id = row.entry_id,
    top_rule = row.top_rule,
    job_id = job_id or "contract:authority",
    caller_capabilities = row.caller_capabilities,
    required_capabilities = row.required_capabilities,
    caller_policy_modes = row.caller_policy_modes,
    required_policy_modes = row.required_policy_modes,
    caller_ceilings = row.caller_ceilings,
    required_source_detail = row.required_source_detail,
    required_versions = row.required_versions,
  })
end

function M.register(registry, options)
  registry_state(registry)
  options = type(options) == "table" and options or {}
  raise("staged_registry_mutation_forbidden", "resolve", {
    job_id = type(options.job_id) == "string" and options.job_id or "<registry>",
    parser_spec_id = type(options.parser_spec_id) == "string" and options.parser_spec_id or "<invalid>",
    operation = "register",
  })
end

function M.load(registry, options)
  registry_state(registry)
  options = type(options) == "table" and options or {}
  raise("staged_implicit_load_forbidden", "load", {
    job_id = type(options.job_id) == "string" and options.job_id or "<registry>",
    parser_spec_id = type(options.parser_spec_id) == "string" and options.parser_spec_id or "<invalid>",
    operation = "load",
  })
end

function M.job_identity(fields)
  if not exact_keys(fields, {
        declaring_spec_id = true,
        parent_ast_path = true,
        node_kind = true,
        payload_kind = true,
        parser_spec_id = true,
        top_rule = true,
        provenance = true,
      }) then snapshot_error("job_identity") end
  local identity = json.harray({
    contract_version = 2,
    declaring_spec_id = copy_plain(fields.declaring_spec_id),
    parent_ast_path = copy_plain(fields.parent_ast_path),
    node_kind = copy_plain(fields.node_kind),
    payload_kind = copy_plain(fields.payload_kind),
    parser_spec_id = copy_plain(fields.parser_spec_id),
    top_rule = copy_plain(fields.top_rule),
    provenance = copy_plain(fields.provenance),
  })
  return "parse_job:v2:sha256:" .. sha256.hex(json.encode(identity))
end

local function cache_error(fields, component)
  local resolved = type(fields) == "table" and fields.normalized_spec_id or nil
  raise("staged_cache_identity_invalid", "compile", {
    job_id = "<cache-identity>",
    resolved_spec_id = type(resolved) == "string" and resolved or "<invalid>",
    cache_component = component,
  })
end

function M.cache_identity(fields)
  if not exact_keys(fields, {
        normalized_spec_id = true,
        content_digest = true,
        import_graph_fingerprint = true,
        top_rule = true,
        spec_language_version = true,
        helper_contract_version = true,
        staged_contract_version = true,
        backend_capabilities = true,
      }) then cache_error(fields, "<shape>") end
  if not valid_parser_identity(fields.normalized_spec_id) then cache_error(fields, "normalized_spec_id") end
  if not valid_digest(fields.content_digest) then cache_error(fields, "content_digest") end
  if not valid_digest(fields.import_graph_fingerprint) then cache_error(fields, "import_graph_fingerprint") end
  if not valid_top_rule(fields.top_rule) then cache_error(fields, "top_rule") end
  if not is_integer(fields.spec_language_version) or fields.spec_language_version <= 0 then
    cache_error(fields, "spec_language_version")
  end
  if type(fields.helper_contract_version) ~= "string" or fields.helper_contract_version == "" then
    cache_error(fields, "helper_contract_version")
  end
  if not is_integer(fields.staged_contract_version) or fields.staged_contract_version <= 0 then
    cache_error(fields, "staged_contract_version")
  end
  local ok, capabilities = pcall(
    copy_string_set,
    fields.backend_capabilities,
    "backend_capabilities",
    true
  )
  if not ok then cache_error(fields, "backend_capabilities") end
  local normalized = json.harray({
    normalized_spec_id = fields.normalized_spec_id,
    content_digest = fields.content_digest,
    import_graph_fingerprint = fields.import_graph_fingerprint,
    top_rule = fields.top_rule,
    spec_language_version = fields.spec_language_version,
    helper_contract_version = fields.helper_contract_version,
    staged_contract_version = fields.staged_contract_version,
    backend_capabilities = array_copy(capabilities),
  })
  return "sha256:" .. sha256.hex(json.encode(normalized))
end

local function typed_components(values, component)
  if type(values) ~= "table" or not dense_array(values) then snapshot_error(component) end
  local result = {}
  for index, value in ipairs(values) do
    if type(value) == "string" then
      result[index] = value
    elseif is_integer(value) and value >= 0 then
      result[index] = value
    else
      snapshot_error(component)
    end
  end
  return result
end

local function compare_components(left, right)
  local shared = math.min(#left, #right)
  for index = 1, shared do
    local a = left[index]
    local b = right[index]
    local order = 0
    if type(a) == type(b) then
      if a < b then order = -1 elseif a > b then order = 1 end
    else
      order = type(a) == "string" and -1 or 1
    end
    if order ~= 0 then return order end
  end
  if #left < #right then return -1 end
  if #left > #right then return 1 end
  return 0
end

local function order_jobs(jobs)
  if type(jobs) ~= "table" or not dense_array(jobs) then snapshot_error("current_depth_jobs") end
  local rows = {}
  for index, row in ipairs(jobs) do
    if type(row) ~= "table" then snapshot_error("current_depth_job") end
    local depth = row.stage_depth
    if not is_integer(depth) or depth <= 0 or type(row.job_id) ~= "string" or row.job_id == "" then
      snapshot_error("current_depth_job")
    end
    rows[index] = {
      source = row,
      depth = depth,
      path = typed_components(row.parent_ast_path, "parent_ast_path"),
      provenance = typed_components(row.provenance_order, "provenance_order"),
      id = row.job_id,
    }
  end
  table.sort(rows, function(left, right)
    if left.depth ~= right.depth then return left.depth < right.depth end
    local order = compare_components(left.path, right.path)
    if order ~= 0 then return order < 0 end
    order = compare_components(left.provenance, right.provenance)
    if order ~= 0 then return order < 0 end
    return left.id < right.id
  end)
  return rows
end

function M.current_depth_order(jobs)
  local result = json.array()
  for index, row in ipairs(order_jobs(jobs)) do result[index] = row.id end
  return result
end

local function parse_options(value)
  if not exact_keys(value, {
        declaring_spec_id = true,
        caller_capabilities = true,
        caller_policy_modes = true,
        caller_ceilings = true,
        required_source_detail = true,
        required_versions = true,
      }) then snapshot_error("enrichment_options") end
  local declaring = required_string(value, "declaring_spec_id", "declaring_spec_id")
  if not valid_parser_identity(declaring) then snapshot_error("declaring_spec_id") end
  local detail = required_string(value, "required_source_detail", "required_source_detail")
  source_detail_rank(detail)
  return {
    declaring_spec_id = declaring,
    caller_capabilities = copy_string_set(value.caller_capabilities, "caller_capabilities", false),
    caller_policy_modes = copy_string_set(value.caller_policy_modes, "caller_policy_modes", false),
    caller_ceilings = parse_ceilings(value.caller_ceilings, "caller_ceilings"),
    required_source_detail = detail,
    required_versions = parse_versions(value.required_versions, "required_versions"),
  }
end

local function is_marker(value)
  return type(value) == "table" and value.kind == MARKER_KIND and value.version == 2 and
    value.sidecar_kind == SIDECAR_KIND and type(value[SIDECAR_KIND]) == "table"
end

local function discover_markers(value, path, result)
  if is_marker(value) then
    result[#result + 1] = { path = path, marker = copy_plain(value) }
    return
  end
  if type(value) ~= "table" then return end
  local kind = plain_table_kind(value)
  if kind == "array" then
    for index = 1, #value do
      local child_path = {}
      for path_index, component in ipairs(path) do child_path[path_index] = component end
      child_path[#child_path + 1] = index - 1
      discover_markers(value[index], child_path, result)
    end
  elseif kind == "harray" then
    for key, child in pairs(value) do
      local child_path = {}
      for path_index, component in ipairs(path) do child_path[path_index] = component end
      child_path[#child_path + 1] = key
      discover_markers(child, child_path, result)
    end
  end
end

local function marker_error(sidecar, code)
  raise(code, "prepare", {
    origin = type(sidecar.origin) == "string" and sidecar.origin or "<marker>",
    parser_spec_id = type(sidecar.parser_spec_id) == "string" and sidecar.parser_spec_id or "<invalid>",
  })
end

local function marker_sidecar(marker)
  if not is_marker(marker) then snapshot_error("marker") end
  local sidecar = copy_plain(marker[SIDECAR_KIND])
  if sidecar.kind ~= SIDECAR_KIND or sidecar.version ~= 2 or sidecar.state ~= "declared" then
    snapshot_error("sidecar")
  end
  return sidecar
end

local function sidecar_string(sidecar, field)
  local value = sidecar[field]
  if type(value) ~= "string" or value == "" then marker_error(sidecar, "staged_registry_snapshot_invalid") end
  return value
end

local function provenance_order(value)
  if type(value) ~= "table" then snapshot_error("provenance") end
  local segments
  if value.kind == "direct_span" then
    segments = { value }
  elseif value.kind == "derived_text" and value.policy == "concatenate_in_order" and
      type(value.segments) == "table" and dense_array(value.segments) and #value.segments > 0 then
    segments = value.segments
  else
    snapshot_error("provenance")
  end
  local result = {}
  for _, segment in ipairs(segments) do
    if type(segment) ~= "table" or segment.kind ~= "direct_span" or
        type(segment.source_id) ~= "string" or segment.source_id == "" or
        not is_integer(segment.start) or segment.start < 0 or
        not is_integer(segment["end"]) or segment["end"] < segment.start or
        type(segment.provenance) ~= "string" or segment.provenance == "" then
      snapshot_error("provenance")
    end
    result[#result + 1] = segment.source_id
    result[#result + 1] = segment.start
    result[#result + 1] = segment["end"]
    result[#result + 1] = segment.provenance
  end
  return result
end

local function path_json(path)
  local result = json.array()
  for index, component in ipairs(path) do result[index] = component end
  return result
end

local function prepare_plan(registry, discovered, options)
  local state = registry_state(registry)
  local sidecar = marker_sidecar(discovered.marker)
  local parser_spec_id = sidecar_string(sidecar, "parser_spec_id")
  local provisional_top = type(sidecar.top_rule) == "string" and sidecar.top_rule or "UnresolvedDefault"
  local function identity_fields(top_rule)
    return json.harray({
      declaring_spec_id = options.declaring_spec_id,
      parent_ast_path = path_json(discovered.path),
      node_kind = sidecar_string(sidecar, "node_kind"),
      payload_kind = sidecar_string(sidecar, "payload_kind"),
      parser_spec_id = parser_spec_id,
      top_rule = top_rule,
      provenance = copy_plain(sidecar.provenance),
    })
  end
  local provisional_id = M.job_identity(identity_fields(provisional_top))
  local resolved = M.resolve_pre_registered(registry, {
    declaring_spec_id = options.declaring_spec_id,
    parser_spec_id = parser_spec_id,
    job_id = provisional_id,
  })
  local entry = state.entries[resolved]
  if entry == nil then snapshot_error("resolved_spec_id") end
  local top_rule = type(sidecar.top_rule) == "string" and sidecar.top_rule or entry.default_top_rule
  local job_id = M.job_identity(identity_fields(top_rule))
  local result_policy = sidecar_string(sidecar, "result_policy")
  local failure_policy = sidecar_string(sidecar, "failure_policy")
  local required_policies = { result_policy }
  if failure_policy ~= result_policy then required_policies[#required_policies + 1] = failure_policy end
  table.sort(required_policies)
  local effective = effective_authority(registry, {
    entry_id = resolved,
    top_rule = top_rule,
    job_id = job_id,
    caller_capabilities = options.caller_capabilities,
    required_capabilities = sidecar.required_capabilities,
    caller_policy_modes = options.caller_policy_modes,
    required_policy_modes = required_policies,
    caller_ceilings = options.caller_ceilings,
    required_source_detail = options.required_source_detail,
    required_versions = options.required_versions,
  })
  local cache_key = M.cache_identity(json.harray({
    normalized_spec_id = resolved,
    content_digest = entry.content_digest,
    import_graph_fingerprint = entry.import_graph_fingerprint,
    top_rule = top_rule,
    spec_language_version = entry.versions.spec_language_version,
    helper_contract_version = entry.versions.helper_contract_version,
    staged_contract_version = entry.versions.staged_contract_version,
    backend_capabilities = effective.capabilities,
  }))
  sidecar.state = "prepared"
  sidecar.declaring_spec_id = options.declaring_spec_id
  sidecar.parent_ast_path = path_json(discovered.path)
  sidecar.resolved_spec_id = resolved
  sidecar.top_rule = top_rule
  sidecar.job_id = job_id
  sidecar.cache_key = cache_key
  sidecar.stage_depth = 1
  sidecar.stage_chain = json.array()
  sidecar.payload_digest = "sha256:" .. sha256.hex(sidecar_string(sidecar, "text"))
  sidecar.effective = copy_plain(effective)
  return {
    path = discovered.path,
    marker = discovered.marker,
    sidecar = sidecar,
    resolved_spec_id = resolved,
    top_rule = top_rule,
    cache_key = cache_key,
    effective = effective,
    provenance_order = provenance_order(sidecar.provenance),
  }
end

local function plan_less(left, right)
  local order = compare_components(left.path, right.path)
  if order ~= 0 then return order < 0 end
  order = compare_components(left.provenance_order, right.provenance_order)
  if order ~= 0 then return order < 0 end
  return left.sidecar.job_id < right.sidecar.job_id
end

local function value_at(root, path)
  local current = root
  for _, component in ipairs(path) do
    local kind = type(current) == "table" and plain_table_kind(current) or nil
    if type(component) == "string" and kind == "harray" and current[component] ~= nil then
      current = current[component]
    elseif is_integer(component) and component >= 0 and kind == "array" and current[component + 1] ~= nil then
      current = current[component + 1]
    else
      return false, nil
    end
  end
  return true, current
end

local function parent_at(root, path)
  if #path == 0 then return false, nil end
  local parent_path = {}
  for index = 1, #path - 1 do parent_path[index] = path[index] end
  return value_at(root, parent_path)
end

local function set_at(root, path, replacement)
  if #path == 0 then return replacement end
  local found, parent = parent_at(root, path)
  if not found then return root end
  local component = path[#path]
  if type(component) == "number" then parent[component + 1] = replacement else parent[component] = replacement end
  return root
end

local function marker_diagnostic(found, value)
  if not found then return "<missing>" end
  if type(value) == "table" then
    return json.harray({ kind = value.kind or json.null, version = value.version or json.null })
  end
  return type(value)
end

local function stitch_error(plan, code, fields)
  local record = {
    stage_chain = plan.sidecar.stage_chain,
    job_id = plan.sidecar.job_id,
    parent_ast_path = plan.sidecar.parent_ast_path,
  }
  for key, value in pairs(fields or {}) do record[key] = value end
  raise(code, "stitch", record)
end

local function marker_equal(left, right)
  local ok_left, encoded_left = pcall(json.encode, left)
  local ok_right, encoded_right = pcall(json.encode, right)
  return ok_left and ok_right and encoded_left == encoded_right
end

local function validate_stitch_target(ast, plan)
  local found, actual = value_at(ast, plan.path)
  if not found or not is_marker(actual) or not marker_equal(actual, plan.marker) then
    stitch_error(plan, "staged_marker_mismatch", {
      actual_marker = marker_diagnostic(found, actual),
    })
  end
  local policy = plan.sidecar.result_policy
  if policy == "replace_marker" then return end
  local into = plan.sidecar.into
  local parent_found, parent = parent_at(ast, plan.path)
  if type(into) ~= "string" or into == "" or not parent_found or plain_table_kind(parent) ~= "harray" then
    stitch_error(plan, "staged_stitch_target_missing", {
      into = type(into) == "string" and into or "<missing>",
    })
  end
  if policy == "replace_field" and parent[into] == nil then
    stitch_error(plan, "staged_stitch_target_missing", { into = into })
  elseif policy == "sibling_field" and parent[into] ~= nil then
    stitch_error(plan, "staged_stitch_target_collision", { into = into })
  elseif policy == "append_child" and plain_table_kind(parent[into]) ~= "array" then
    stitch_error(plan, "staged_append_target_invalid", { into = into })
  elseif policy ~= "replace_field" and policy ~= "sibling_field" and policy ~= "append_child" then
    marker_error(plan.sidecar, "staged_result_policy_invalid")
  end
end

local function path_is_prefix(prefix, path)
  if #prefix > #path then return false end
  for index = 1, #prefix do if prefix[index] ~= path[index] then return false end end
  return true
end

local function target_path(plan)
  local path = {}
  for index = 1, #plan.path - 1 do path[index] = plan.path[index] end
  path[#path + 1] = plan.sidecar.into
  return path
end

local function validate_prepared_depth(ast, plans)
  local ids = {}
  for _, plan in ipairs(plans) do
    local job_id = plan.sidecar.job_id
    if ids[job_id] then
      raise("staged_duplicate_job_id", "prepare", {
        job_id = job_id,
        parent_ast_path = plan.sidecar.parent_ast_path,
      })
    end
    ids[job_id] = true
    validate_stitch_target(ast, plan)
  end
  local claims = {}
  for _, plan in ipairs(plans) do
    if plan.sidecar.result_policy ~= "replace_marker" then
      local path = target_path(plan)
      local append = plan.sidecar.result_policy == "append_child"
      if not append then
        for _, queued in ipairs(plans) do
          if queued ~= plan and path_is_prefix(path, queued.path) then
            stitch_error(plan, "staged_stitch_target_collision", { into = plan.sidecar.into })
          end
        end
      end
      for _, prior in ipairs(claims) do
        local same = compare_components(path, prior.path) == 0
        local incompatible = (same and not (append and prior.append)) or
          (not append and path_is_prefix(path, prior.path)) or
          (not prior.append and path_is_prefix(prior.path, path))
        if incompatible then
          stitch_error(plan, "staged_stitch_target_collision", { into = plan.sidecar.into })
        end
      end
      claims[#claims + 1] = { path = path, append = append }
    end
  end
end

local function stitch_value(ast, plan, value)
  validate_stitch_target(ast, plan)
  local policy = plan.sidecar.result_policy
  if policy == "replace_marker" then return set_at(ast, plan.path, value) end
  ast = set_at(ast, plan.path, plan.sidecar.text)
  local _, parent = parent_at(ast, plan.path)
  local into = plan.sidecar.into
  if policy == "replace_field" or policy == "sibling_field" then
    parent[into] = value
  else
    parent[into][#parent[into] + 1] = value
  end
  return ast
end

local function materialize_text(ast, plan)
  validate_stitch_target(ast, plan)
  return set_at(ast, plan.path, plan.sidecar.text)
end

local function detach_plain(value, maximum)
  local nodes = 0
  local active = {}
  local function failure(reason)
    return nil, { nodes = nodes, reason = reason }
  end
  local function walk(current, path)
    nodes = nodes + 1
    if nodes > maximum then return failure("node_limit") end
    if current == nil then return json.null end
    local current_type = type(current)
    if current == json.null or current_type == "boolean" or current_type == "string" then return current end
    if current_type == "number" then
      if current ~= current or current == math.huge or current == -math.huge then return failure(path) end
      return current
    end
    if current_type ~= "table" or private_state[current] ~= nil or getmetatable(current) == CONTEXT_MT then
      return failure(path)
    end
    if active[current] then return failure(path) end
    local kind = plain_table_kind(current)
    if kind == nil then return failure(path) end
    active[current] = true
    local result
    if kind == "array" then
      result = json.array()
      for index = 1, #current do
        local child, child_failure = walk(current[index], path .. "/" .. tostring(index - 1))
        if child_failure then active[current] = nil return nil, child_failure end
        result[index] = child
      end
    else
      result = json.harray()
      for key, child_value in pairs(current) do
        if type(key) ~= "string" or LIVE_RESULT_KEYS[key] then
          active[current] = nil
          return failure(path .. "/" .. tostring(key))
        end
        local child, child_failure = walk(child_value, path .. "/" .. key)
        if child_failure then active[current] = nil return nil, child_failure end
        result[key] = child
      end
    end
    active[current] = nil
    return result
  end
  local detached, failure_record = walk(value, "<result>")
  if failure_record then return nil, failure_record end
  return detached, { nodes = nodes }
end

function M.detach_plain(value, maximum)
  if not is_integer(maximum) or maximum < 0 then snapshot_error("node_limit") end
  local detached, record = detach_plain(value, maximum)
  if detached == nil then
    return json.harray({ accepted = false, nodes = record.nodes, reason = record.reason })
  end
  return json.harray({ accepted = true, value = detached, nodes = record.nodes })
end

function M.child_success(value)
  return new_token("StagedChildExecution", { succeeded = true, value = value })
end

function M.child_failure(diagnostic)
  return new_token("StagedChildExecution", { succeeded = false, value = diagnostic })
end

local function runtime_context()
  local context = setmetatable({
    cursor = 0,
    marks = json.harray(),
    captures = json.harray(),
    variables = json.harray(),
  }, CONTEXT_MT)
  private_state[context] = { node_type = "StagedRuntimeContext" }
  return context
end

function M.runtime_context_to_json(value)
  state_of(value, "StagedRuntimeContext")
  return json.harray({
    cursor = value.cursor,
    marks = copy_plain(value.marks),
    captures = copy_plain(value.captures),
    variables = copy_plain(value.variables),
  })
end

local function cached_plan(registry, plan)
  local state = registry_state(registry)
  local cached = state.cache.entries[plan.cache_key]
  if cached ~= nil then
    state.cache.hits = state.cache.hits + 1
    return cached
  end
  local entry = state.entries[plan.resolved_spec_id]
  if entry == nil then snapshot_error("plan_cache") end
  cached = {
    callback = entry.callback,
    resolved_spec_id = plan.resolved_spec_id,
    top_rule = plan.top_rule,
    effective_capabilities = array_copy(plan.effective.capabilities),
  }
  state.cache.entries[plan.cache_key] = cached
  state.cache.count = state.cache.count + 1
  state.cache.misses = state.cache.misses + 1
  return cached
end

local function detachment_diagnostic(plan, failure)
  if failure.reason == "node_limit" then
    return json.harray({
      code = "staged_result_node_limit_exceeded",
      phase = "execute",
      stage_chain = copy_plain(plan.sidecar.stage_chain),
      job_id = plan.sidecar.job_id,
      nodes = failure.nodes,
      maximum = plan.effective.max_result_nodes,
    })
  end
  return json.harray({
    code = "staged_result_not_detached",
    phase = "execute",
    stage_chain = copy_plain(plan.sidecar.stage_chain),
    job_id = plan.sidecar.job_id,
    field = failure.reason,
  })
end

local function portable_child_diagnostic(value)
  local detached = detach_plain(value, 256)
  if detached ~= nil and plain_table_kind(detached) == "harray" then return detached end
  return json.harray({ code = "staged_child_exception" })
end

local function child_failure_diagnostic(plan, child)
  return json.harray({
    code = "staged_child_failed",
    phase = "execute",
    stage_chain = copy_plain(plan.sidecar.stage_chain),
    job_id = plan.sidecar.job_id,
    parent_ast_path = copy_plain(plan.sidecar.parent_ast_path),
    node_kind = plan.sidecar.node_kind,
    payload_kind = plan.sidecar.payload_kind,
    parser_spec_id = plan.sidecar.parser_spec_id,
    resolved_spec_id = plan.sidecar.resolved_spec_id,
    top_rule = plan.sidecar.top_rule,
    cache_key = plan.sidecar.cache_key,
    source_provenance = copy_plain(plan.sidecar.provenance),
    result_policy = plan.sidecar.result_policy,
    failure_policy = plan.sidecar.failure_policy,
    child_diagnostic = portable_child_diagnostic(child),
  })
end

local function settle_failure(working, plan, diagnostic, diagnostics)
  local owned = copy_plain(diagnostic)
  diagnostics[#diagnostics + 1] = owned
  plan.sidecar.diagnostic = copy_plain(owned)
  local policy = plan.sidecar.failure_policy
  if policy == "fail" then
    raise_record(owned)
  elseif policy == "keep_text" then
    plan.sidecar.state = "failed_keep_text"
    return materialize_text(working, plan)
  elseif policy == "diagnostic_node" then
    plan.sidecar.state = "failed_diagnostic_node"
    return stitch_value(working, plan, json.harray({
      kind = "staged_parse_diagnostic",
      diagnostic = copy_plain(owned),
    }))
  end
  marker_error(plan.sidecar, "staged_failure_policy_invalid")
end

local function child_request(plan)
  return json.harray({
    stage_depth = plan.sidecar.stage_depth,
    stage_chain = copy_plain(plan.sidecar.stage_chain),
    job_id = plan.sidecar.job_id,
    parent_ast_path = copy_plain(plan.sidecar.parent_ast_path),
    node_kind = plan.sidecar.node_kind,
    payload_kind = plan.sidecar.payload_kind,
    parser_spec_id = plan.sidecar.parser_spec_id,
    resolved_spec_id = plan.sidecar.resolved_spec_id,
    top_rule = plan.sidecar.top_rule,
    text = plan.sidecar.text,
    source_provenance = copy_plain(plan.sidecar.provenance),
    result_policy = plan.sidecar.result_policy,
    failure_policy = plan.sidecar.failure_policy,
    effective = copy_plain(plan.sidecar.effective),
  })
end

function M.enrich_current_depth(registry, ast, options)
  registry_state(registry)
  local parsed_options = parse_options(options)
  local copied, copy_record = detach_plain(ast, MAX_EXACT_INTEGER)
  if copied == nil then snapshot_error("parent_ast:" .. tostring(copy_record.reason)) end
  local working = copied
  local discovered = {}
  discover_markers(working, {}, discovered)
  local plans = {}
  for index, marker in ipairs(discovered) do plans[index] = prepare_plan(registry, marker, parsed_options) end
  table.sort(plans, plan_less)
  validate_prepared_depth(working, plans)

  local diagnostics = json.array()
  for _, plan in ipairs(plans) do
    validate_stitch_target(working, plan)
    local cached = cached_plan(registry, plan)
    if cached.resolved_spec_id ~= plan.resolved_spec_id or cached.top_rule ~= plan.top_rule or
        json.encode(cached.effective_capabilities) ~= json.encode(plan.effective.capabilities) then
      snapshot_error("plan_cache")
    end
    local context = runtime_context()
    local ok, execution = pcall(cached.callback, child_request(plan), context)
    local execution_state = ok and type(execution) == "table" and private_state[execution] or nil
    if execution_state == nil or execution_state.node_type ~= "StagedChildExecution" then
      execution_state = { succeeded = false, value = json.harray({ code = "staged_child_exception" }) }
    end
    if execution_state.succeeded then
      local detached, record = detach_plain(execution_state.value, plan.effective.max_result_nodes)
      if detached ~= nil then
        working = stitch_value(working, plan, detached)
        plan.sidecar.state = "succeeded"
      else
        working = settle_failure(working, plan, detachment_diagnostic(plan, record), diagnostics)
      end
    else
      working = settle_failure(
        working,
        plan,
        child_failure_diagnostic(plan, execution_state.value),
        diagnostics
      )
    end
  end

  local sidecars = json.array()
  for index, plan in ipairs(plans) do sidecars[index] = copy_plain(plan.sidecar) end
  return json.harray({
    ast = copy_plain(working),
    sidecars = sidecars,
    diagnostics = copy_plain(diagnostics),
    cache = M.cache_stats(registry),
  })
end

return M
