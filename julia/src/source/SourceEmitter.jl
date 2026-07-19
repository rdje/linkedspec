@enum GeneratedSourceStage begin
    EmitSourceStage
    CompileOrLoadGeneratedSourceStage
    ValidateGeneratedPlanStage
    ValidateGeneratedSpecStage
    SelectGeneratedEntryRuleStage
    ExecuteGeneratedStage
end

@enum GeneratedSourceCode begin
    GeneratedSourceEmitFailedCode
    GeneratedSourceCompileFailedCode
    GeneratedPlanRowCountMismatchCode
    GeneratedPlanLabelMismatchCode
    GeneratedPlanFamilyMismatchCode
    GeneratedPlanUnknownFamilyCode
    GeneratedNoRulesDefinedCode
    GeneratedEntryRuleNotFoundCode
    GeneratedExecutionFailedCode
end

struct _GeneratedDiagnosticOutputSinkFailure <: Exception
    error::Any
end

function _generated_diagnostic_output_sink(sink)
    sink === nothing && return nothing
    return event -> try
        sink(event)
    catch error
        throw(_GeneratedDiagnosticOutputSinkFailure(error))
    end
end

const GENERATED_SOURCE_CONTRACT = "linkedspec-generated-source-v1"
const GENERATED_SOURCE_FORMAT = 1

@enum GeneratedRuleFamily begin
    DefaultGeneratedFamily
    OrAcodeGeneratedFamily
    AndSingleAcodeGeneratedFamily
    AndAcodeSeqGeneratedFamily
    AndBcodeGeneratedFamily
    OrBcodeGeneratedFamily
    RepAcodeGeneratedFamily
    RepBcodeGeneratedFamily
    RepAndAcodeGeneratedFamily
    RepAndBcodeGeneratedFamily
end

struct GeneratedPlanRow
    label::String
    family::String
end

GeneratedPlanRow(label::AbstractString, family::AbstractString) =
    GeneratedPlanRow(String(label), String(family))

to_json(row::GeneratedPlanRow) = Dict("label" => row.label, "family" => row.family)

function generated_rule_family_name(family::GeneratedRuleFamily)
    names = (
        "default",
        "or_acode",
        "and_single_acode",
        "and_acode_seq",
        "and_bcode",
        "or_bcode",
        "rep_acode",
        "rep_bcode",
        "rep_and_acode",
        "rep_and_bcode",
    )
    return names[Int(family) + 1]
end

function generated_rule_family_from_name(name::AbstractString)
    text = String(name)
    for family in instances(GeneratedRuleFamily)
        if generated_rule_family_name(family) == text
            return family
        end
    end
    return nothing
end

_generated_family_uses_blind_dispatch(family::AbstractString) = String(family) in (
    "and_bcode",
    "or_bcode",
    "rep_bcode",
    "rep_and_bcode",
)

function classify_generated_rule_family(rule::CompiledRule)
    mode = rule.mode_metadata.name
    repetition = mode in (
        "Plus",
        "Star",
        "Optional",
        "OrPlus",
        "AndPlus",
        "OrBounded",
        "AndBounded",
    )
    if repetition
        if !isempty(rule.blind_edges)
            return rule.mode_metadata.is_and ?
                RepAndBcodeGeneratedFamily : RepBcodeGeneratedFamily
        end
        return rule.mode_metadata.is_and ?
            RepAndAcodeGeneratedFamily : RepAcodeGeneratedFamily
    elseif !isempty(rule.blind_edges)
        return mode == "Or" ? OrBcodeGeneratedFamily : AndBcodeGeneratedFamily
    elseif mode == "Default"
        return DefaultGeneratedFamily
    elseif mode == "Or"
        return OrAcodeGeneratedFamily
    elseif mode == "Single"
        return AndSingleAcodeGeneratedFamily
    elseif mode in ("And", "Pipe")
        return length(rule.regex_patterns) <= 1 && length(rule.action_edges) <= 1 ?
            AndSingleAcodeGeneratedFamily : AndAcodeSeqGeneratedFamily
    end
    throw(ArgumentError("unsupported generated rule mode $mode"))
end

function build_generated_rule_plan(compiled::CompiledSpec)
    return GeneratedPlanRow[
        GeneratedPlanRow(
            label,
            generated_rule_family_name(classify_generated_rule_family(compiled.rules_by_label[label])),
        )
        for label in compiled.compiled_rule_order
    ]
end

function validate_generated_rule_plan_v1(
    compiled::CompiledSpec,
    plan::AbstractVector{GeneratedPlanRow},
    source_identity::AbstractString,
)
    identity = String(source_identity)
    try
        validate_no_removed_aggregate_selectors(compiled)
    catch error
        throw(generated_source_compile_failed(identity, error))
    end
    if length(plan) != length(compiled.compiled_rule_order)
        throw(GeneratedSourceException(
            ValidateGeneratedPlanStage,
            GeneratedPlanRowCountMismatchCode,
            "Generated rule plan row count does not match compiled rules",
            identity;
            detail = "expected=$(length(compiled.compiled_rule_order)) actual=$(length(plan))",
        ))
    end

    validated = Dict{String,String}()
    for (index, row) in enumerate(plan)
        expected_label = compiled.compiled_rule_order[index]
        if row.label != expected_label
            throw(GeneratedSourceException(
                ValidateGeneratedPlanStage,
                GeneratedPlanLabelMismatchCode,
                "Generated rule plan label does not match compiled rule",
                identity;
                rule_label = expected_label,
                detail = "row=$(index - 1) expected=$expected_label actual=$(row.label)",
            ))
        end
        actual_family = generated_rule_family_from_name(row.family)
        if actual_family === nothing
            throw(GeneratedSourceException(
                ValidateGeneratedPlanStage,
                GeneratedPlanUnknownFamilyCode,
                "Generated rule plan contains an unknown family",
                identity;
                rule_label = expected_label,
                handler_family = row.family,
                detail = "row=$(index - 1) family=$(row.family)",
            ))
        end
        expected_family = classify_generated_rule_family(compiled.rules_by_label[expected_label])
        if actual_family != expected_family
            expected_name = generated_rule_family_name(expected_family)
            throw(GeneratedSourceException(
                ValidateGeneratedPlanStage,
                GeneratedPlanFamilyMismatchCode,
                "Generated rule plan family does not match compiled rule",
                identity;
                rule_label = expected_label,
                handler_family = row.family,
                detail = "row=$(index - 1) expected=$expected_name actual=$(row.family)",
            ))
        end
        validated[expected_label] = row.family
    end
    return validated
end

function execute_generated_parser_v1(
    compiled::CompiledSpec,
    plan::AbstractVector{GeneratedPlanRow},
    input::AbstractString,
    source_identity::AbstractString;
    top_rule = nothing,
    trace::Union{Nothing,LinkedSpecTraceEmitter} = nothing,
    diagnostic_output_sink::Union{Nothing,RuntimeDiagnosticOutputSink} = nothing,
)
    families = validate_generated_rule_plan_v1(compiled, plan, source_identity)
    try
        return runtime_parse(
            LinkedSpecRuntimeEngine(compiled),
            input;
            top_rule = top_rule,
            trace = trace,
            diagnostic_output_sink = _generated_diagnostic_output_sink(
                diagnostic_output_sink,
            ),
            _generated_families = families,
            _generated_source_identity = source_identity,
        ).value
    catch error
        error isa GeneratedSourceException && rethrow()
        error isa _GeneratedDiagnosticOutputSinkFailure && throw(error.error)
        error isa RuntimeExitNow && rethrow()
        if error isa RuntimeInterpreterException && error.diagnostic !== nothing &&
                error.diagnostic.code in ("no_rules_defined", "entry_rule_not_found")
            throw(generated_source_entry_rule_selection_failed(source_identity, error))
        end
        rule_label = error isa RuntimeInterpreterException && error.diagnostic !== nothing ?
            error.diagnostic.rule_label : nothing
        family = rule_label === nothing ? nothing : get(families, rule_label, nothing)
        throw(generated_source_execution_failed(
            source_identity,
            error;
            rule_label = rule_label,
            handler_family = family,
        ))
    end
end

function execute_generated_parser_with_trace_v1(
    compiled::CompiledSpec,
    plan::AbstractVector{GeneratedPlanRow},
    input::AbstractString,
    config::LinkedSpecTraceConfig,
    source_identity::AbstractString;
    top_rule = nothing,
    stdout_io::IO = stdout,
    diagnostic_output_sink::Union{Nothing,RuntimeDiagnosticOutputSink} = nothing,
)
    return execute_generated_parser_v1(
        compiled,
        plan,
        input,
        source_identity;
        top_rule = top_rule,
        trace = LinkedSpecTraceEmitter(config; stdout_io = stdout_io),
        diagnostic_output_sink = diagnostic_output_sink,
    )
end

function generated_source_stage_name(stage::GeneratedSourceStage)
    if stage == EmitSourceStage
        return "emit_source"
    elseif stage == CompileOrLoadGeneratedSourceStage
        return "compile_or_load_generated_source"
    elseif stage == ValidateGeneratedPlanStage
        return "validate_generated_plan"
    elseif stage == ValidateGeneratedSpecStage
        return "validate_spec"
    elseif stage == SelectGeneratedEntryRuleStage
        return "select_entry_rule"
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
    elseif code == GeneratedNoRulesDefinedCode
        return "no_rules_defined"
    elseif code == GeneratedEntryRuleNotFoundCode
        return "entry_rule_not_found"
    end
    return "generated_execution_failed"
end

struct GeneratedSourceException <: Exception
    stage::GeneratedSourceStage
    code::GeneratedSourceCode
    summary::String
    source_identity::String
    entry_rule::Union{Nothing,String}
    rule_label::Union{Nothing,String}
    handler_family::Union{Nothing,String}
    detail::Union{Nothing,String}
end

function GeneratedSourceException(
    stage::GeneratedSourceStage,
    code::GeneratedSourceCode,
    summary::AbstractString,
    source_identity::AbstractString;
    entry_rule = nothing,
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
        optional_string(entry_rule),
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

function generated_source_entry_rule_selection_failed(
    source_identity::AbstractString,
    error::RuntimeInterpreterException,
)
    diagnostic = error.diagnostic
    if diagnostic === nothing ||
            !(diagnostic.code in ("no_rules_defined", "entry_rule_not_found"))
        throw(ArgumentError("runtime error is not an entry-rule selection failure"))
    end
    zero_rules = diagnostic.code == "no_rules_defined"
    return GeneratedSourceException(
        zero_rules ? ValidateGeneratedSpecStage : SelectGeneratedEntryRuleStage,
        zero_rules ? GeneratedNoRulesDefinedCode : GeneratedEntryRuleNotFoundCode,
        "Generated Julia parser entry-rule selection failed",
        source_identity;
        entry_rule = diagnostic.entry_rule,
        rule_label = diagnostic.rule_label,
        detail = diagnostic.detail,
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
    _put_if_present!(result, "entry_rule", error.entry_rule)
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
        validate_no_removed_aggregate_selectors(compiled)
        normalized_spec = _generated_effective_spec(compiled)
        spec_json = _generated_canonical_json(to_json(normalized_spec))
        identity_hex = bytes2hex(codeunits(identity))
        spec_json_hex = bytes2hex(codeunits(spec_json))
        plan = build_generated_rule_plan(compiled)

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
        println(output, "const _GENERATED_PLAN = LinkedSpecJulia.GeneratedPlanRow[")
        for row in plan
            println(
                output,
                "    LinkedSpecJulia.GeneratedPlanRow(String(hex2bytes(\"",
                bytes2hex(codeunits(row.label)),
                "\")), \"",
                row.family,
                "\"),",
            )
        end
        println(output, "]")
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
plan() = copy(_GENERATED_PLAN)

function validate_plan(actual::AbstractVector{LinkedSpecJulia.GeneratedPlanRow})
    LinkedSpecJulia.validate_generated_rule_plan_v1(
        _COMPILED_SPEC,
        actual,
        LINKEDSPEC_GENERATED_SOURCE_IDENTITY,
    )
    return nothing
end

function execute(
    input::AbstractString;
    top_rule = nothing,
    diagnostic_output_sink = nothing,
)
    return LinkedSpecJulia.execute_generated_parser_v1(
        _COMPILED_SPEC,
        _GENERATED_PLAN,
        input,
        LINKEDSPEC_GENERATED_SOURCE_IDENTITY;
        top_rule = top_rule,
        diagnostic_output_sink = diagnostic_output_sink,
    )
end

function execute_with_trace(
    input::AbstractString,
    trace_config::LinkedSpecJulia.LinkedSpecTraceConfig;
    top_rule = nothing,
    stdout_io::IO = stdout,
    diagnostic_output_sink = nothing,
)
    return LinkedSpecJulia.execute_generated_parser_with_trace_v1(
        _COMPILED_SPEC,
        _GENERATED_PLAN,
        input,
        trace_config,
        LINKEDSPEC_GENERATED_SOURCE_IDENTITY;
        top_rule = top_rule,
        stdout_io = stdout_io,
        diagnostic_output_sink = diagnostic_output_sink,
    )
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
            signature = definition.signature,
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
