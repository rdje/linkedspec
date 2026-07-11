@enum GeneratedSourceStage begin
    EmitSourceStage
    CompileOrLoadGeneratedSourceStage
    ValidateGeneratedPlanStage
    ExecuteGeneratedStage
end

@enum GeneratedSourceCode begin
    GeneratedSourceEmitFailedCode
    GeneratedSourceCompileFailedCode
    GeneratedPlanRowCountMismatchCode
    GeneratedPlanLabelMismatchCode
    GeneratedPlanFamilyMismatchCode
    GeneratedPlanUnknownFamilyCode
    GeneratedExecutionFailedCode
end

const GENERATED_SOURCE_CONTRACT = "linkedspec-generated-source-v1"
const GENERATED_SOURCE_FORMAT = 1

function generated_source_stage_name(stage::GeneratedSourceStage)
    if stage == EmitSourceStage
        return "emit_source"
    elseif stage == CompileOrLoadGeneratedSourceStage
        return "compile_or_load_generated_source"
    elseif stage == ValidateGeneratedPlanStage
        return "validate_generated_plan"
    end
    return "execute_generated"
end

function generated_source_code_name(code::GeneratedSourceCode)
    if code == GeneratedSourceEmitFailedCode
        return "generated_source_emit_failed"
    elseif code == GeneratedSourceCompileFailedCode
        return "generated_source_compile_failed"
    elseif code == GeneratedPlanRowCountMismatchCode
        return "generated_plan_row_count_mismatch"
    elseif code == GeneratedPlanLabelMismatchCode
        return "generated_plan_label_mismatch"
    elseif code == GeneratedPlanFamilyMismatchCode
        return "generated_plan_family_mismatch"
    elseif code == GeneratedPlanUnknownFamilyCode
        return "generated_plan_unknown_family"
    end
    return "generated_execution_failed"
end

struct GeneratedSourceException <: Exception
    stage::GeneratedSourceStage
    code::GeneratedSourceCode
    summary::String
    source_identity::String
    rule_label::Union{Nothing,String}
    handler_family::Union{Nothing,String}
    detail::Union{Nothing,String}
end

function GeneratedSourceException(
    stage::GeneratedSourceStage,
    code::GeneratedSourceCode,
    summary::AbstractString,
    source_identity::AbstractString;
    rule_label = nothing,
    handler_family = nothing,
    detail = nothing,
)
    optional_string(value) = value === nothing ? nothing : String(value)
    return GeneratedSourceException(
        stage,
        code,
        String(summary),
        String(source_identity),
        optional_string(rule_label),
        optional_string(handler_family),
        optional_string(detail),
    )
end

function Base.showerror(io::IO, error::GeneratedSourceException)
    print(io, error.summary)
    if error.detail !== nothing
        print(io, ": ", error.detail)
    end
end

function generated_source_compile_failed(source_identity::AbstractString, detail)
    return GeneratedSourceException(
        CompileOrLoadGeneratedSourceStage,
        GeneratedSourceCompileFailedCode,
        "Generated Julia source failed to compile or load",
        source_identity;
        detail = _generated_source_detail(detail),
    )
end

function generated_source_execution_failed(
    source_identity::AbstractString,
    detail;
    rule_label = nothing,
    handler_family = nothing,
)
    return GeneratedSourceException(
        ExecuteGeneratedStage,
        GeneratedExecutionFailedCode,
        "Generated Julia parser execution failed",
        source_identity;
        rule_label = rule_label,
        handler_family = handler_family,
        detail = _generated_source_detail(detail),
    )
end

_generated_source_detail(detail::Exception) = sprint(showerror, detail)
_generated_source_detail(detail) = string(detail)

function to_json(error::GeneratedSourceException)
    result = Dict{String,Any}(
        "type" => "generated_source_error",
        "stage" => generated_source_stage_name(error.stage),
        "code" => generated_source_code_name(error.code),
        "summary" => error.summary,
        "source_identity" => error.source_identity,
    )
    _put_if_present!(result, "rule_label", error.rule_label)
    _put_if_present!(result, "handler_family", error.handler_family)
    _put_if_present!(result, "detail", error.detail)
    return result
end

struct GeneratedSourceMetadata
    contract_id::String
    format_version::Int
    source_identity::String
end

GeneratedSourceMetadata(source_identity::AbstractString) = GeneratedSourceMetadata(
    GENERATED_SOURCE_CONTRACT,
    GENERATED_SOURCE_FORMAT,
    String(source_identity),
)

function to_json(metadata::GeneratedSourceMetadata)
    return Dict{String,Any}(
        "contract_id" => metadata.contract_id,
        "format_version" => metadata.format_version,
        "source_identity" => metadata.source_identity,
    )
end

"""Emit a deterministic contract-v1 Julia module using the compatibility identity."""
emit_julia_source(compiled::CompiledSpec) = emit_julia_source_v1(compiled, "<inline>")

"""
Emit deterministic Julia source from effective compiled state.

The logical payload is Unicode scalar text. The generated-file boundary encodes
its canonical JSON as strict UTF-8 and renders those bytes as ASCII hexadecimal;
UTF-8 is the selected boundary encoding, not a synonym for Unicode.
"""
function emit_julia_source_v1(compiled::CompiledSpec, source_identity::AbstractString)
    identity = String(source_identity)
    if isempty(identity)
        throw(GeneratedSourceException(
            EmitSourceStage,
            GeneratedSourceEmitFailedCode,
            "Generated Julia source identity must not be empty",
            identity;
            detail = "source_identity is required",
        ))
    elseif !isvalid(identity)
        throw(GeneratedSourceException(
            EmitSourceStage,
            GeneratedSourceEmitFailedCode,
            "Generated Julia source identity must be valid Unicode text",
            identity;
            detail = "source_identity must encode as strict UTF-8",
        ))
    end

    try
        normalized_spec = _generated_effective_spec(compiled)
        spec_json = _generated_canonical_json(to_json(normalized_spec))
        identity_hex = bytes2hex(codeunits(identity))
        spec_json_hex = bytes2hex(codeunits(spec_json))

        output = IOBuffer()
        print(output, """# Generated LinkedSpec parser module.
# Contract id: linkedspec-generated-source-v1.
# Source format: LinkedSpecJulia source_emitter v1.
# Source identity: LINKEDSPEC_GENERATED_SOURCE_IDENTITY.

module LinkedSpecGeneratedParser

import JSON3
import LinkedSpecJulia

const LINKEDSPEC_GENERATED_SOURCE_CONTRACT = "linkedspec-generated-source-v1"
const LINKEDSPEC_GENERATED_SOURCE_FORMAT = 1
""")
        println(
            output,
            "const LINKEDSPEC_GENERATED_SOURCE_IDENTITY = String(hex2bytes(\"",
            identity_hex,
            "\"))",
        )
        println(output, "const _COMPILED_SPEC_JSON_HEX = \"", spec_json_hex, "\"")
        print(output, """

metadata() = LinkedSpecJulia.GeneratedSourceMetadata(
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

const _COMPILED_SPEC = _load_compiled_spec()
const _ENGINE = LinkedSpecJulia.LinkedSpecRuntimeEngine(_COMPILED_SPEC)

function execute(input::AbstractString; top_rule = nothing)
    try
        return LinkedSpecJulia.runtime_execute(
            _ENGINE,
            input;
            top_rule = top_rule,
        ).value
    catch error
        if error isa LinkedSpecJulia.GeneratedSourceException
            rethrow()
        end
        rule_label = error isa LinkedSpecJulia.RuntimeInterpreterException &&
            error.diagnostic !== nothing ? error.diagnostic.rule_label : nothing
        throw(LinkedSpecJulia.generated_source_execution_failed(
            LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
            error;
            rule_label = rule_label,
        ))
    end
end

function execute_with_trace(
    input::AbstractString,
    trace_config::LinkedSpecJulia.LinkedSpecTraceConfig;
    top_rule = nothing,
    stdout_io::IO = stdout,
)
    try
        return LinkedSpecJulia.runtime_execute_with_trace(
            _ENGINE,
            input,
            trace_config;
            top_rule = top_rule,
            stdout_io = stdout_io,
        ).value
    catch error
        if error isa LinkedSpecJulia.GeneratedSourceException
            rethrow()
        end
        rule_label = error isa LinkedSpecJulia.RuntimeInterpreterException &&
            error.diagnostic !== nothing ? error.diagnostic.rule_label : nothing
        throw(LinkedSpecJulia.generated_source_execution_failed(
            LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
            error;
            rule_label = rule_label,
        ))
    end
end

end # module LinkedSpecGeneratedParser
""")
        return String(take!(output))
    catch error
        if error isa GeneratedSourceException
            rethrow()
        end
        throw(GeneratedSourceException(
            EmitSourceStage,
            GeneratedSourceEmitFailedCode,
            "Failed to serialize compiled spec for generated Julia source",
            identity;
            detail = sprint(showerror, error),
        ))
    end
end

function _generated_effective_spec(compiled::CompiledSpec)
    functions = FunctionDefinition[]
    for entry in compiled.function_registry.entries
        definition = entry.definition
        push!(functions, FunctionDefinition(
            name = definition.name,
            params = definition.params,
            arity = definition.arity,
            body_source = definition.body_source,
            source = definition.source,
            source_span = definition.source_span,
            body_span = definition.body_span,
        ))
    end

    rules = Rule[]
    for label in compiled.compiled_rule_order
        rule = compiled.rules_by_label[label]
        push!(rules, Rule(header = rule.header, body = rule.body_elements))
    end
    return SpecFile(functions = functions, rules = rules)
end

function _generated_canonical_json(value)
    output = IOBuffer()
    _write_generated_canonical_json(output, value)
    return String(take!(output))
end

function _write_generated_canonical_json(io::IO, value)
    if value === nothing
        print(io, "null")
    elseif value isa Bool
        print(io, value ? "true" : "false")
    elseif value isa AbstractString || value isa Number
        print(io, String(JSON3.write(value)))
    elseif value isa AbstractDict
        entries = Pair{String,Any}[]
        seen_keys = Set{String}()
        for (key, entry_value) in pairs(value)
            if !(key isa AbstractString)
                throw(ArgumentError(
                    "generated-source JSON object keys must be strings, got $(typeof(key))",
                ))
            end
            text_key = String(key)
            if text_key in seen_keys
                throw(ArgumentError(
                    "generated-source JSON object contains duplicate key '$text_key'",
                ))
            end
            push!(seen_keys, text_key)
            push!(entries, text_key => entry_value)
        end
        sort!(entries; by = first)

        print(io, '{')
        for (index, entry) in enumerate(entries)
            if index > 1
                print(io, ',')
            end
            print(io, String(JSON3.write(first(entry))), ':')
            _write_generated_canonical_json(io, last(entry))
        end
        print(io, '}')
    elseif value isa AbstractVector || value isa Tuple
        print(io, '[')
        for (index, item) in enumerate(value)
            if index > 1
                print(io, ',')
            end
            _write_generated_canonical_json(io, item)
        end
        print(io, ']')
    else
        throw(ArgumentError(
            "generated-source JSON does not support values of type $(typeof(value))",
        ))
    end
    return nothing
end
