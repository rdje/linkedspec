local corpus = require("linkedspec.corpus")
local json = require("linkedspec.json")
local semantic_index = require("linkedspec.semantic_index")
local semantic_observation = require("linkedspec.semantic_observation")
local semantic_query = require("linkedspec.semantic_query")
local spec_loader = require("linkedspec.spec_loader")
local spec_ast = require("linkedspec.spec_ast")
local spec_parser = require("linkedspec.spec_parser")
local spec_validator = require("linkedspec.spec_validator")
local function_shell = require("linkedspec.user_function_definition_shell")
local action_ast = require("linkedspec.action_ast")
local action_parser = require("linkedspec.action_parser")
local action_contracts = require("linkedspec.action_contracts")
local user_function_registry = require("linkedspec.user_function_registry")
local staged_parser_registry = require("linkedspec.staged_parser_registry")
local user_function_definition_parser = require("linkedspec.user_function_definition_parser")
local compiled_spec = require("linkedspec.compiled_spec")
local source_emitter = require("linkedspec.source_emitter")
local matching = require("linkedspec.matching")
local interpreter = require("linkedspec.interpreter")
local primary_cli = require("linkedspec.primary_cli")
local trace = require("linkedspec.trace")

local M = {}
local mcp_server

local function load_mcp_server()
  if mcp_server == nil then mcp_server = require("linkedspec.mcp_server") end
  return mcp_server
end

M.PACKAGE_NAME = "linkedspec"
M.PACKAGE_VERSION = "0.1.0"
M.BACKEND_NAME = "lua"
M.PARITY_STATUS = "runtime-corpus-primary-cli"
M.CLI_ENTRYPOINT = "lua/bin/linkedspec-lua"
M.CORPUS_RUNNER_ENTRYPOINT = "lua/bin/corpus_runner.lua"

local function copy_table(value)
  local result = {}
  for key, item in pairs(value) do
    result[key] = item
  end
  return result
end

function M.backend_name()
  return M.BACKEND_NAME
end

function M.cli_entrypoint()
  return M.CLI_ENTRYPOINT
end

function M.corpus_runner_entrypoint()
  return M.CORPUS_RUNNER_ENTRYPOINT
end

function M.runtime_implementation()
  if type(jit) == "table" and type(jit.version) == "string" then
    return "luajit"
  end
  return "puc-lua"
end

function M.backend_status()
  return copy_table({
    backend = M.BACKEND_NAME,
    package = M.PACKAGE_NAME,
    version = M.PACKAGE_VERSION,
    parity = M.PARITY_STATUS,
    runtime = M.runtime_implementation(),
    cli = M.CLI_ENTRYPOINT,
    corpus_runner = M.CORPUS_RUNNER_ENTRYPOINT,
  })
end

M.json = json
M.semantic_index = semantic_index.create
M.RUNTIME_SEMANTIC_OBSERVATION_CONTRACT = semantic_observation.CONTRACT_ID
M.is_runtime_semantic_observation_event = semantic_observation.is_event
M.runtime_semantic_observation_event_to_json = semantic_observation.to_json
M.semantic_query_request = semantic_query.request
M.is_semantic_query_request = semantic_query.is_request
M.is_semantic_query_response = semantic_query.is_response
M.semantic_query_to_json = semantic_query.to_json
M.mcp_server = function(...) return load_mcp_server().server(...) end
M.mcp_budget_limits = function(...) return load_mcp_server().budget_limits(...) end
M.mcp_deployment_policy = function(...) return load_mcp_server().deployment_policy(...) end
M.mcp_registration_options = function(...) return load_mcp_server().registration_options(...) end
M.is_mcp_server_error = function(...) return load_mcp_server().is_error(...) end
M.mcp_server_error_to_json = function(...) return load_mcp_server().error_to_json(...) end
M.primary_cli = primary_cli
M.primary_cli_help = primary_cli.help
M.run_primary_cli = primary_cli.run
M.load_corpus_fixtures = corpus.load_corpus_fixtures
M.execute_corpus_fixtures = corpus.execute_corpus_fixtures
M.corpus_node_type = corpus.node_type
M.is_corpus_fixture_execution_result = corpus.is_corpus_fixture_execution_result
M.is_corpus_execution_result = corpus.is_corpus_execution_result
M.corpus_fixture_passed = corpus.corpus_fixture_passed
M.corpus_execution_passed = corpus.corpus_execution_passed
M.corpus_passed_count = corpus.corpus_passed_count
M.corpus_failures = corpus.corpus_failures
M.corpus_fixture_result = corpus.corpus_fixture_result
M.spec_loader = spec_loader
M.named_spec_request = spec_loader.named_spec_request
M.path_spec_request = spec_loader.path_spec_request
M.spec_load_options = spec_loader.spec_load_options
M.validate_spec_request = spec_loader.validate_spec_request
M.resolve_spec = spec_loader.resolve_spec
M.load_spec = spec_loader.load_spec
M.load_and_compile_spec = spec_loader.load_and_compile_spec
M.create_loaded_spec_engine = spec_loader.create_engine
M.is_spec_pipeline_error = spec_loader.is_spec_pipeline_error
M.spec_pipeline_error_to_json = spec_loader.spec_pipeline_error_to_json
M.spec_ast = spec_ast
M.parse_spec = spec_parser.parse_spec
M.is_spec_parse_error = spec_parser.is_parse_error
M.validate_spec = spec_validator.validate_spec
M.is_spec_validation_error = spec_validator.is_validation_error
M.spec_validation_error_to_json = spec_validator.validation_error_to_json
M.project_user_function_definition_asts = function_shell.project
M.parse_spec_with_user_function_definition_asts = function_shell.parse_spec_with_asts
M.definition_nodes_from_user_function_definition_output = function_shell.definition_nodes_from_output
M.is_user_function_projection_error = function_shell.is_projection_error
M.action_ast = action_ast
M.parse_action_block = action_parser.parse_action_block
M.parse_action_statement = action_parser.parse_action_statement
M.parse_action_expression = action_parser.parse_action_expression
M.action_contracts = action_contracts
M.resolve_action_block_contracts = action_contracts.resolve_action_block_contracts
M.resolve_action_statement_contracts = action_contracts.resolve_action_statement_contracts
M.resolve_action_expression_contracts = action_contracts.resolve_action_expression_contracts
M.canonical_action_helper_name = action_contracts.canonical_action_helper_name
M.is_known_action_ir_call_name = action_contracts.is_known_action_ir_call_name
M.user_function_registry = user_function_registry
M.user_function_registry_from_spec = user_function_registry.from_spec
M.user_function_registry_from_functions = user_function_registry.from_functions
M.empty_user_function_registry = user_function_registry.empty
M.stitch_function_body_ast = user_function_registry.stitch_function_body_ast
M.prepare_user_function_invocation = user_function_registry.prepare_invocation
M.staged_parser_registry = staged_parser_registry
M.ACTION_IR_BODY_SPEC_ID = staged_parser_registry.ACTION_IR_BODY_SPEC_ID
M.ACTION_IR_BODY_TOP_RULE = staged_parser_registry.ACTION_IR_BODY_TOP_RULE
M.ACTION_IR_BODY_RESOLVED_SPEC_ID = staged_parser_registry.ACTION_IR_BODY_RESOLVED_SPEC_ID
M.ACTION_IR_BODY_ADAPTER_DIGEST = staged_parser_registry.ACTION_IR_BODY_ADAPTER_DIGEST
M.execute_staged_parse_job = staged_parser_registry.execute_staged_parse_job
M.execute_staged_parse_jobs = staged_parser_registry.execute_staged_parse_jobs
M.dispatch_function_body_parse_jobs = staged_parser_registry.dispatch_function_body_parse_jobs
M.stitch_function_body_parse_jobs = staged_parser_registry.stitch_function_body_parse_jobs
M.parse_spec_with_staged_user_function_definition_asts =
  staged_parser_registry.parse_spec_with_staged_user_function_definition_asts
M.is_staged_parser_registry_error = staged_parser_registry.is_staged_parser_registry_error
M.staged_parser_registry_to_json = staged_parser_registry.to_json
M.user_function_definition_parser = user_function_definition_parser
M.USER_FUNCTION_DEFINITION_SPEC_ID = user_function_definition_parser.USER_FUNCTION_DEFINITION_SPEC_ID
M.USER_FUNCTION_DEFINITION_TOP_RULE = user_function_definition_parser.USER_FUNCTION_DEFINITION_TOP_RULE
M.user_function_definition_ast_parser_from_spec_source =
  user_function_definition_parser.parser_from_spec_source
M.user_function_definition_parser_metadata =
  user_function_definition_parser.default_parser_metadata
M.parse_user_function_definition_asts =
  user_function_definition_parser.parse_user_function_definition_asts
M.parse_spec_with_staged_user_function_definitions =
  user_function_definition_parser.parse_spec_with_staged_user_function_definitions
M.is_user_function_definition_parser_error = user_function_definition_parser.is_error
M.compiled_spec = compiled_spec
M.ENTRY_RULE_CONTRACT_ID = compiled_spec.ENTRY_RULE_CONTRACT_ID
M.RULE_LOCAL_CURSOR_CONTRACT_ID = compiled_spec.RULE_LOCAL_CURSOR_CONTRACT_ID
M.REGEX_SLOT_IDENTITY_CONTRACT_ID = compiled_spec.REGEX_SLOT_IDENTITY_CONTRACT_ID
M.compile_spec = compiled_spec.compile_spec
M.validate_compiled_regex_slot_identities = compiled_spec.validate_compiled_regex_slot_identities
M.compiled_regex_slot_identities_for = compiled_spec.compiled_regex_slot_identities_for
M.is_compiled_spec_error = compiled_spec.is_compiled_spec_error
M.resolve_entry_rule = compiled_spec.resolve_entry_rule
M.entry_rule_selection_basis_name = compiled_spec.entry_rule_selection_basis_name
M.is_entry_rule_selection_error = compiled_spec.is_entry_rule_selection_error
M.entry_rule_selection_error_to_json = compiled_spec.entry_rule_selection_error_to_json
M.compiled_spec_to_json = compiled_spec.to_json
M.to_descriptor_json = compiled_spec.to_descriptor_json
M.source_emitter = source_emitter
M.GENERATED_SOURCE_CONTRACT = source_emitter.GENERATED_SOURCE_CONTRACT
M.GENERATED_SOURCE_FORMAT = source_emitter.GENERATED_SOURCE_FORMAT
M.EMIT_SOURCE_STAGE = source_emitter.EMIT_SOURCE_STAGE
M.COMPILE_OR_LOAD_GENERATED_SOURCE_STAGE = source_emitter.COMPILE_OR_LOAD_GENERATED_SOURCE_STAGE
M.VALIDATE_GENERATED_PLAN_STAGE = source_emitter.VALIDATE_GENERATED_PLAN_STAGE
M.VALIDATE_COMPILED_RULE_STAGE = source_emitter.VALIDATE_COMPILED_RULE_STAGE
M.VALIDATE_GENERATED_SPEC_STAGE = source_emitter.VALIDATE_GENERATED_SPEC_STAGE
M.SELECT_GENERATED_ENTRY_RULE_STAGE = source_emitter.SELECT_GENERATED_ENTRY_RULE_STAGE
M.EXECUTE_GENERATED_STAGE = source_emitter.EXECUTE_GENERATED_STAGE
M.EXECUTE_RULE_STAGE = source_emitter.EXECUTE_RULE_STAGE
M.GENERATED_SOURCE_EMIT_FAILED_CODE = source_emitter.GENERATED_SOURCE_EMIT_FAILED_CODE
M.GENERATED_SOURCE_COMPILE_FAILED_CODE = source_emitter.GENERATED_SOURCE_COMPILE_FAILED_CODE
M.GENERATED_PLAN_ROW_COUNT_MISMATCH_CODE = source_emitter.GENERATED_PLAN_ROW_COUNT_MISMATCH_CODE
M.GENERATED_PLAN_LABEL_MISMATCH_CODE = source_emitter.GENERATED_PLAN_LABEL_MISMATCH_CODE
M.GENERATED_PLAN_FAMILY_MISMATCH_CODE = source_emitter.GENERATED_PLAN_FAMILY_MISMATCH_CODE
M.GENERATED_PLAN_UNKNOWN_FAMILY_CODE = source_emitter.GENERATED_PLAN_UNKNOWN_FAMILY_CODE
M.GENERATED_SOURCE_CONTRACT_VERSION_MISMATCH_CODE =
  source_emitter.GENERATED_SOURCE_CONTRACT_VERSION_MISMATCH_CODE
M.REGEX_SLOT_IDENTITY_INVALID_CODE = source_emitter.REGEX_SLOT_IDENTITY_INVALID_CODE
M.ORDERED_REGEX_SLOT_IDENTITY_LOST_CODE = source_emitter.ORDERED_REGEX_SLOT_IDENTITY_LOST_CODE
M.GENERATED_NO_RULES_DEFINED_CODE = source_emitter.GENERATED_NO_RULES_DEFINED_CODE
M.GENERATED_ENTRY_RULE_NOT_FOUND_CODE = source_emitter.GENERATED_ENTRY_RULE_NOT_FOUND_CODE
M.GENERATED_EXECUTION_FAILED_CODE = source_emitter.GENERATED_EXECUTION_FAILED_CODE
M.generated_source_stage_name = source_emitter.generated_source_stage_name
M.generated_source_code_name = source_emitter.generated_source_code_name
M.generated_source_error = source_emitter.generated_source_error
M.generated_source_error_to_json = source_emitter.generated_source_error_to_json
M.is_generated_source_error = source_emitter.is_generated_source_error
M.generated_source_compile_failed = source_emitter.generated_source_compile_failed
M.generated_source_regex_slot_identity_failed = source_emitter.generated_source_regex_slot_identity_failed
M.generated_source_ordered_regex_slot_identity_lost =
  source_emitter.generated_source_ordered_regex_slot_identity_lost
M.generated_source_execution_failed = source_emitter.generated_source_execution_failed
M.generated_source_entry_rule_selection_failed =
  source_emitter.generated_source_entry_rule_selection_failed
M.generated_source_metadata = source_emitter.generated_source_metadata
M.generated_source_metadata_to_json = source_emitter.generated_source_metadata_to_json
M.is_generated_source_metadata = source_emitter.is_generated_source_metadata
M.generated_plan_row = source_emitter.generated_plan_row
M.is_generated_plan_row = source_emitter.is_generated_plan_row
M.generated_plan_row_to_json = source_emitter.generated_plan_row_to_json
M.generated_rule_family_names = source_emitter.generated_rule_family_names
M.generated_family_cursor_policy = source_emitter.generated_family_cursor_policy
M.classify_generated_rule_family = source_emitter.classify_generated_rule_family
M.build_generated_rule_plan = source_emitter.build_generated_rule_plan
M.validate_generated_source_contract_v2 = source_emitter.validate_generated_source_contract_v2
M.validate_generated_rule_plan_v2 = source_emitter.validate_generated_rule_plan_v2
M.execute_generated_parser_v2 = source_emitter.execute_generated_parser_v2
M.execute_generated_parser_with_trace_v2 = source_emitter.execute_generated_parser_with_trace_v2
M.emit_lua_source = source_emitter.emit_lua_source
M.emit_lua_source_v2 = source_emitter.emit_lua_source_v2
M.matching = matching
M.compile_runtime_regex_alternation = matching.compile_runtime_regex_alternation
M.runtime_match = matching.runtime_match
M.match_runtime_regex_slot = matching.match_runtime_regex_slot
M.seek_match = matching.seek_match
M.consume_match = matching.consume_match
M.runtime_match_registers = matching.runtime_match_registers
M.runtime_regex_engine = matching.runtime_regex_engine
M.runtime_regex_engine_version = matching.runtime_regex_engine_version
M.is_runtime_regex_error = matching.is_runtime_regex_error
M.interpreter = interpreter
M.runtime_engine = interpreter.runtime_engine
M.typed_source_projection_rows = interpreter.typed_source_projection_rows
M.typed_source_compatibility_aliases = interpreter.typed_source_compatibility_aliases
M.runtime_parse = interpreter.runtime_parse
M.runtime_execute = interpreter.runtime_execute
M.runtime_parse_with_trace = interpreter.runtime_parse_with_trace
M.runtime_execute_with_trace = interpreter.runtime_execute_with_trace
M.is_runtime_interpreter_error = interpreter.is_runtime_interpreter_error
M.is_runtime_exit_now = interpreter.is_runtime_exit_now
M.is_runtime_diagnostic = interpreter.is_runtime_diagnostic
M.assert_ordered_regex_slot_identity = interpreter.assert_ordered_regex_slot_identity
M.runtime_value_kind = interpreter.runtime_value_kind
M.trace = trace
M.DUMP_NONE = trace.DUMP_NONE
M.DUMP_LOW = trace.DUMP_LOW
M.DUMP_MEDIUM = trace.DUMP_MEDIUM
M.DUMP_HIGH = trace.DUMP_HIGH
M.DUMP_FULL = trace.DUMP_FULL
M.DUMP_DEBUG = trace.DUMP_DEBUG
M.TRACE_NONE = trace.TRACE_NONE
M.TRACE_LOW = trace.TRACE_LOW
M.TRACE_MEDIUM = trace.TRACE_MEDIUM
M.TRACE_HIGH = trace.TRACE_HIGH
M.TRACE_FULL = trace.TRACE_FULL
M.TRACE_DEBUG = trace.TRACE_DEBUG
M.TRACE_STDOUT = trace.TRACE_STDOUT
M.TRACE_ROUTE = trace.TRACE_ROUTE
M.TRACE_MIRROR = trace.TRACE_MIRROR
M.TRACE_ENTER = trace.TRACE_ENTER
M.TRACE_EXIT = trace.TRACE_EXIT
M.TRACE_DECISION = trace.TRACE_DECISION
M.TRACE_MARK = trace.TRACE_MARK
M.TRACE_DUMP = trace.TRACE_DUMP
M.TRACE_LOG = trace.TRACE_LOG
M.parse_trace_level = trace.parse_trace_level
M.trace_allows = trace.trace_allows
M.trace_level_name = trace.trace_level_name
M.parse_trace_sink_mode = trace.parse_trace_sink_mode
M.trace_config = trace.trace_config
M.trace_config_disabled = trace.trace_config_disabled
M.trace_config_enabled = trace.trace_config_enabled
M.with_trace_level = trace.with_trace_level
M.with_trace_file = trace.with_trace_file
M.with_trace_sink_mode = trace.with_trace_sink_mode
M.with_trace_reset_file = trace.with_trace_reset_file
M.with_trace_emoji = trace.with_trace_emoji
M.trace_should_emit = trace.trace_should_emit
M.trace_config_from_environment = trace.trace_config_from_environment
M.trace_event_kind_name = trace.trace_event_kind_name
M.trace_emitter = trace.trace_emitter
M.trace_config_of = trace.trace_config_of
M.trace_events = trace.trace_events
M.trace_lines = trace.trace_lines
M.emit_trace_line = trace.emit_trace_line
M.emit_trace_event = trace.emit_trace_event
M.enter_trace_scope = trace.enter_trace_scope
M.exit_trace_scope = trace.exit_trace_scope
M.trace_decision = trace.trace_decision
M.log_trace_output = trace.log_trace_output
M.log_trace_dump = trace.log_trace_dump
M.trace_event_to_json = trace.to_json
M.is_trace_error = trace.is_trace_error
M.is_trace_level = trace.is_trace_level
M.is_trace_sink_mode = trace.is_trace_sink_mode
M.is_trace_config = trace.is_trace_config
M.is_trace_event = trace.is_trace_event
M.is_trace_scope = trace.is_trace_scope
M.is_trace_emitter = trace.is_trace_emitter

return M
