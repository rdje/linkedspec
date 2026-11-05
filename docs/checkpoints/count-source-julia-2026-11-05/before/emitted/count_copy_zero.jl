# Generated LinkedSpec parser module.
# Contract id: linkedspec-generated-source-v2.
# Source format: LinkedSpecJulia source_emitter v2.
# Source identity: LINKEDSPEC_GENERATED_SOURCE_IDENTITY.

module LinkedSpecGeneratedParser

import JSON3
import LinkedSpecJulia

const LINKEDSPEC_GENERATED_SOURCE_CONTRACT = "linkedspec-generated-source-v2"
const LINKEDSPEC_GENERATED_SOURCE_FORMAT = 2
const LINKEDSPEC_REGEX_SLOT_IDENTITY_CONTRACT = "linkedspec-duplicate-regex-slot-identity-v1"
const LINKEDSPEC_GENERATED_SOURCE_IDENTITY = String(hex2bytes("636f756e742d736f757263652d66616c6c6261636b2e73706563"))
const _COMPILED_SPEC_JSON_HEX = "7b2266756e6374696f6e73223a5b5d2c2272756c6573223a5b7b22626f6479223a5b7b226b696e64223a7b22636f6465223a226f726465723d5c225c223b6f75743d5b636f707928636f756e74285b5d29292e636f616c65736365287b6f726465723d636174286f726465722c5c22465c22293b377d292e6164642831292c636f756e74285b5d292e636f707928292e636f616c65736365287b6f726465723d636174286f726465722c5c22525c22293b377d292e6164642831295d3b72657475726e285b6f75742c6f726465725d29222c226b696e64223a22636f64655f626c6f636b222c226c6966656379636c65223a2249227d2c226c696e65223a312c22736f75726365223a2249207b6f726465723d5c225c223b6f75743d5b636f707928636f756e74285b5d29292e636f616c65736365287b6f726465723d636174286f726465722c5c22465c22293b377d292e6164642831292c636f756e74285b5d292e636f707928292e636f616c65736365287b6f726465723d636174286f726465722c5c22525c22293b377d292e6164642831295d3b72657475726e285b6f75742c6f726465725d297d227d5d2c22686561646572223a7b2269735f746f70223a747275652c226c6162656c223a2256616c7565222c226c696e65223a312c226d6f6465223a2244656661756c74222c2272657374223a2249207b6f726465723d5c225c223b6f75743d5b636f707928636f756e74285b5d29292e636f616c65736365287b6f726465723d636174286f726465722c5c22465c22293b377d292e6164642831292c636f756e74285b5d292e636f707928292e636f616c65736365287b6f726465723d636174286f726465722c5c22525c22293b377d292e6164642831295d3b72657475726e285b6f75742c6f726465725d297d227d7d5d2c22736f757263655f6964223a22696e6c696e65227d"
const _GENERATED_PLAN = LinkedSpecJulia.GeneratedPlanRow[
    LinkedSpecJulia.GeneratedPlanRow(String(hex2bytes("56616c7565")), "default"),
]

metadata() = LinkedSpecJulia.GeneratedSourceMetadata(
    LINKEDSPEC_GENERATED_SOURCE_CONTRACT,
    LINKEDSPEC_GENERATED_SOURCE_FORMAT,
    LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
)

function _load_compiled_spec()
    try
        payload = String(hex2bytes(_COMPILED_SPEC_JSON_HEX))
        spec = LinkedSpecJulia.from_json(LinkedSpecJulia.SpecFile, JSON3.read(payload))
        return LinkedSpecJulia.compile_spec(spec)
    catch error
        if error isa LinkedSpecJulia.GeneratedSourceException
            rethrow()
        end
        throw(LinkedSpecJulia.generated_source_compile_failed(
            LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
            error,
        ))
    end
end

LinkedSpecJulia.validate_generated_source_contract_v2(
    LINKEDSPEC_GENERATED_SOURCE_CONTRACT,
    LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
)
const _COMPILED_SPEC = _load_compiled_spec()
plan() = copy(_GENERATED_PLAN)

function validate_plan(actual::AbstractVector{LinkedSpecJulia.GeneratedPlanRow})
    validate_plan_for_contract(actual, LINKEDSPEC_GENERATED_SOURCE_CONTRACT)
end

function validate_plan_for_contract(
    actual::AbstractVector{LinkedSpecJulia.GeneratedPlanRow},
    actual_contract::AbstractString,
)
    LinkedSpecJulia.validate_generated_source_contract_v2(
        actual_contract,
        LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
    )
    LinkedSpecJulia.validate_generated_rule_plan_v2(
        _COMPILED_SPEC,
        actual,
        LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
        actual_contract = actual_contract,
    )
    return nothing
end

function execute(
    input::AbstractString;
    top_rule = nothing,
    diagnostic_output_sink = nothing,
    semantic_observation_sink = nothing,
    bounded_child_parse_authority = nothing,
    staged_ast_enrichment_seed = nothing,
)
    return LinkedSpecJulia.execute_generated_parser_v2(
        _COMPILED_SPEC,
        _GENERATED_PLAN,
        input,
        LINKEDSPEC_GENERATED_SOURCE_IDENTITY;
        top_rule = top_rule,
        diagnostic_output_sink = diagnostic_output_sink,
        semantic_observation_sink = semantic_observation_sink,
        actual_contract = LINKEDSPEC_GENERATED_SOURCE_CONTRACT,
        bounded_child_parse_authority = bounded_child_parse_authority,
        staged_ast_enrichment_seed = staged_ast_enrichment_seed,
    )
end

function execute_with_trace(
    input::AbstractString,
    trace_config::LinkedSpecJulia.LinkedSpecTraceConfig;
    top_rule = nothing,
    stdout_io::IO = stdout,
    diagnostic_output_sink = nothing,
    semantic_observation_sink = nothing,
    bounded_child_parse_authority = nothing,
    staged_ast_enrichment_seed = nothing,
)
    return LinkedSpecJulia.execute_generated_parser_with_trace_v2(
        _COMPILED_SPEC,
        _GENERATED_PLAN,
        input,
        trace_config,
        LINKEDSPEC_GENERATED_SOURCE_IDENTITY;
        top_rule = top_rule,
        stdout_io = stdout_io,
        diagnostic_output_sink = diagnostic_output_sink,
        semantic_observation_sink = semantic_observation_sink,
        actual_contract = LINKEDSPEC_GENERATED_SOURCE_CONTRACT,
        bounded_child_parse_authority = bounded_child_parse_authority,
        staged_ast_enrichment_seed = staged_ast_enrichment_seed,
    )
end

end # module LinkedSpecGeneratedParser
