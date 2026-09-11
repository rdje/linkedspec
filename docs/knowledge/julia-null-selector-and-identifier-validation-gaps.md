---
id: julia-null-selector-and-identifier-validation-gaps
title: Julia reconstructed named selectors accept null and identifiers accept terminal LF
answers:
  - can a reconstructed Julia named selector select an anonymous regex slot
  - does Julia reject null named selector provenance
  - do Julia function identifiers reject a terminal newline
  - can a newline bypass Julia reserved function or parameter names
  - which tasks own Julia null selector and full identifier validation
  - does invalid native Julia trace configuration reset a selected file
date: 2026-09-11
status: confirmed native limitations; .2.23 and .2.24 repairs pending
tags: [julia, startup, validation, regex-slots, identifiers, trace]
evidence: "JULIA-STARTUP-READING.1.33 reads Validator641-1047, Trace1-424 and callable_codeblock_literal_contract_test1-669. Existing1201 plus selection1 and diagnostic162 assertions pass; source remains unchanged."
reverify:
  - "Run the two repository-managed bash blocks below for diagnostic and existing focused proof."
---

## Exact source reading

Seven untruncated windows cover1,500 fragments /53,501 baseline-identical bytes;
ordered SHA-25619f76b05c49c993c31531d46010cf38756152123d3bd01e06b93bde50471b8af.
Raw digests: Validator suffix6fa262a7b4e85749d9c96d00fd26fae6048da54b38f618a4ccd92e5ccbb31ab5
(13831 bytes), Trace66ca0fa1eb22c36c4f8e766735d06f137783d7328e032db7bf5ff8e7b952c18a
(13393), callable test prefixe30260ef8135cbe2c1baeefce1b8c673be7a3049f32327a9f13dd99e9e439d15
(26277). Validator and Trace are complete; the test suffix after669 is unread.
Coverage reaches33/52 groups,47,925 lines /1,665,590 bytes and43 complete files.

Validator completion covers bare/action/blind ownership, grouped shared blocks,
target and named/numeric slot checks, shallow regex structure, strict unused rules,
ASCII function identifiers and reserved namespace sets. Native tracing owns numeric
and named levels, immutable config builders, environment precedence, file preparation,
detached event/line collections, filtered scopes, indentation and stdout/route/mirror
rendering. It is separate from the canonical primary recorder.

The callable test prefix exercises typed call-result access, keyword versus
assignment arguments, static-name precedence, evaluation order, copied inputs,
three-store restoration after failure, invocation-local return, ordered recursion,
normalized final-codeblock metadata and native/reconstructed/generated/emitted
carriers. Dynamic invocation coverage is fully read; contextual declaration tests
continue after669, followed by the construction group. Running the whole file grants
no advance reading credit and does not close selector/callback findings .2.1/.2.8.

## Reconstructed named selector defect — .2.23.1/.2

The ten controls match the already documented Dart question but execute Julia's
public SpecFile JSON reconstruction, validation, compilation, descriptor and runtime.
A `selector_kind: named` target with `authored_selector: null` incorrectly selects
an anonymous declaration. Moving `/a/` from slot0 to slot1 moves the erroneous
compiled index with it; both runs return `a`, whereas valid `Child[head]` selects
`head=/b/` and returns `b`. This is nullable name equality, not default-index fallback.

Validator797 passes the untyped authored value to `_regex_slot_index`; equality
at848 admits `nothing == nothing`. Compiler `_resolve_authored_target` at
`julia/src/compiler/CompiledSpec.jl:1689` repeats that equality and retains the
resolved anonymous slot. Descriptor `resolved_slot_edges` reports named/null
provenance and null target_slot_id. That violates exact named identity in
[[inter-match-gap-executable-contract-plan]].

Two malformed acceptances, three valid named/numeric/unindexed selectors and three
rejecting-name comparisons pass96 assertions. With all declarations named, a null
selector rejects; numeric and empty names also reject with exact
`regex_slot_unknown_name / resolve_selector`. Two additional accepted inputs,
numeric/null and unindexed/text provenance, are a compatibility census rather than
a new policy decision or a wrong-slot claim. .2.23.1 owns the identity/consistency
audit and .2.23.2 owns supported-carrier/public closure, coordinated with Dart .2.23.

The first exploratory descriptor access mistakenly indexed the whole descriptor
by Top and raised a harness KeyError after compilation. Inspecting its actual keys
(spec/meta/functions/dependency_regex_map) located that mistake. The final replay
uses the public CompiledRule descriptor method and completes both runtime probes.
No semantic-index, CLI/MCP or fresh emitted reproduction of this defect is claimed.

## Complete identifier defect — .2.24.1/.2

Validator1002-1004 uses `^[A-Za-z_][A-Za-z0-9_]*$`, whose host dollar anchor accepts
a final LF. JSON-reconstructed function `normal\n` and reserved `return\n`, plus
parameter `value\n` and reserved `ctx\n`, all pass quiet and traced validation.
The same checker rejects plain reserved return/ctx and invalid digit-first names.
Exact namespace comparison sees the untrimmed newline-bearing value and therefore
misses the reserved spelling.

Ten controls pass54 assertions: four malformed acceptances, two ordinary valid
comparisons and four rejections. Only names/parameters are mutated in the retained
SpecFile JSON; the claim is validator admission, not successful downstream staging,
compilation or invocation of those inconsistent carriers. .2.24.1 owns complete
ASCII matching and all fixed/rest/final-parameter consumers without trimming;
.2.24.2 owns supported-route/public recurrence. Coordinate .2.22 metadata work.

## Positive native trace boundary

Twelve assertions retain named/numeric levels and quiet filtering. Oversized decimal
text or an invalid sink rejects with LinkedSpecTraceException before emitter file
preparation; a selected reset-file sentinel remains byte-identical. A valid quiet
stdout/reset configuration then intentionally truncates it and emits no lines.
This is the native config/emitter path, not a Julia CLI test, a guarantee for every
host input type or closure of Dart's separately owned trace defect.

## Exact diagnostic replay

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_GROUP33_DIAGNOSTIC'
using LinkedSpecJulia, JSON3, Test

function group33_capture(f)
    try
        return (value=f(), error=nothing)
    catch error
        return (value=nothing, error=error)
    end
end

@testset "group33 reconstructed selectors: two defects and eight comparisons" begin
    first = "Top::\n -> Child[head] { return(match_text()) }\nChild::\n /a/\n head=/b/\n"
    second = "Top::\n -> Child[head] { return(match_text()) }\nChild::\n head=/b/\n /a/\n"
    named = "Top::\n -> Child[head] { return(match_text()) }\nChild::\n tail=/a/\n head=/b/\n"
    cases = [
        ("named_head", first, "named", "head", 0, 1, "head", nothing, "b"),
        ("numeric_one", first, "numeric", 1, 1, 1, "head", nothing, "b"),
        ("unindexed", first, "unindexed", nothing, 0, 0, nothing, "a", nothing),
        ("null_first", first, "named", nothing, 0, 0, nothing, "a", nothing),
        ("null_second", second, "named", nothing, 0, 1, nothing, "a", nothing),
        ("null_all_named", named, "named", nothing, 0, nothing, nothing, nothing, nothing),
        ("named_number", first, "named", 0, 0, nothing, nothing, nothing, nothing),
        ("named_empty", first, "named", "", 0, nothing, nothing, nothing, nothing),
        ("numeric_null", first, "numeric", nothing, 1, 1, "head", nothing, "b"),
        ("unindexed_text", first, "unindexed", "head", 0, 0, nothing, "a", nothing),
    ]
    for (name, source, kind, authored, index, resolved, slot, a, b) in cases
        raw = JSON3.read(JSON3.write(to_json(parse_spec(source))), Dict{String,Any})
        target = only(raw["rules"][1]["body"][1]["kind"]["targets"])
        target["selector_kind"] = kind
        target["authored_selector"] = authored
        target["index"] = index
        parsed = from_json(SpecFile, raw)
        retained = only(top_rule(parsed).body).kind.targets[1]
        @test retained.selector_kind == kind
        @test retained.authored_selector == authored
        @test retained.index == index
        if resolved === nothing
            for operation in [() -> validate_spec(parsed), () -> compile_spec(parsed)]
                result = group33_capture(operation)
                @test result.error isa SpecValidationException
                @test result.error.diagnostic.code == "regex_slot_unknown_name"
                @test result.error.diagnostic.stage == "resolve_selector"
                @test result.error.diagnostic.fields["authored_selector"] == authored
            end
        else
            @test validate_spec(parsed) === nothing
            compiled = compile_spec(parsed)
            rule = compiled.rules_by_label["Top"]
            edge = only(rule.action_edges)
            @test edge.child_regex_index == resolved
            @test edge.target_slot_id == slot
            descriptor = only(to_descriptor_json(rule)["meta"]["resolved_slot_edges"])
            @test descriptor == Dict{String,Any}("selector_kind"=>kind,
                "authored_selector"=>authored, "target_rule"=>"Child",
                "regex_index"=>resolved, "target_slot_id"=>slot)
            @test runtime_execute(LinkedSpecRuntimeEngine(compiled), "a").value == a
            @test runtime_execute(LinkedSpecRuntimeEngine(compiled), "b").value == b
        end
    end
end

@testset "group33 registry identifiers: four defects and six comparisons" begin
    source = "fn normal(value) { return(value) }\nTop:: /x/\n"
    base = to_json(parse_spec_with_staged_user_function_definitions(source))
    cases = [
        ("name_clean", "normal", nothing, true),
        ("name_lf", "normal\n", nothing, true),
        ("reserved_name_lf", "return\n", nothing, true),
        ("reserved_name", "return", nothing, false),
        ("invalid_name", "1bad", nothing, false),
        ("param_clean", nothing, "value", true),
        ("param_lf", nothing, "value\n", true),
        ("reserved_param_lf", nothing, "ctx\n", true),
        ("reserved_param", nothing, "ctx", false),
        ("invalid_param", nothing, "1bad", false),
    ]
    for (id, name, param, accepted) in cases
        raw = JSON3.read(JSON3.write(base), Dict{String,Any})
        definition = only(raw["functions"])
        name !== nothing && (definition["name"] = name)
        param !== nothing && (definition["params"] = [param])
        parsed = from_json(SpecFile, raw)
        @test only(parsed.functions).name == (name === nothing ? "normal" : name)
        @test only(parsed.functions).params == [param === nothing ? "value" : param]
        trace = LinkedSpecTraceEmitter(trace_config_enabled(LinkedSpecTraceDebug); stdout_io=IOBuffer())
        quiet = group33_capture(() -> validate_spec(parsed))
        traced = group33_capture(() -> validate_spec(parsed; trace=trace))
        @test typeof(quiet.error) == typeof(traced.error)
        if accepted
            @test quiet.error === nothing
            @test any(event.topic == "julia_frontend:validate_spec:function_registry" &&
                      occursin("taken=1", event.details) for event in trace_events(trace))
        else
            @test quiet.error isa SpecValidationException
            @test sprint(showerror, quiet.error) == sprint(showerror, traced.error)
            @test any(event.topic == "julia_frontend:validate_spec:function_registry" &&
                      occursin("taken=0", event.details) for event in trace_events(trace))
        end
    end
end

@testset "group33 native trace configuration precedes file preparation" begin
    @test parse_trace_level("med") == LinkedSpecTraceMedium
    @test parse_trace_level("quiet") == LinkedSpecTraceNone
    @test parse_trace_level("501").value == 501
    @test !trace_allows(parse_trace_level("-1"), LinkedSpecTraceLow)
    huge = "99999999999999999999999999999999999999"
    @test group33_capture(() -> parse_trace_level(huge)).error isa LinkedSpecTraceException
    mktempdir() do scratch
        path = joinpath(scratch, "native-trace.txt")
        write(path, "sentinel\n")
        environment = Dict("LINKEDSPEC_TRACE_LEVEL"=>huge, "LINKEDSPEC_TRACE_FILE"=>path,
                           "LINKEDSPEC_TRACE_RESET_FILE"=>"1")
        rejected = group33_capture(() -> LinkedSpecTraceEmitter(trace_config_from_environment(environment)))
        @test rejected.error isa LinkedSpecTraceException
        @test read(path, String) == "sentinel\n"
        rejected_sink = group33_capture(() -> LinkedSpecTraceEmitter(LinkedSpecTraceConfig(
            level="debug", trace_file=path, sink_mode="invalid", reset_file=true)))
        @test rejected_sink.error isa LinkedSpecTraceException
        @test read(path, String) == "sentinel\n"
        quiet = LinkedSpecTraceEmitter(LinkedSpecTraceConfig(level="none", trace_file=path,
            sink_mode="stdout", reset_file=true); stdout_io=IOBuffer())
        @test read(path, String) == ""
        emit_trace_line!(quiet, "low", "hidden")
        @test isempty(trace_lines(quiet))
        @test read(path, String) == ""
    end
end
JULIA_GROUP33_DIAGNOSTIC
```

## Existing focused proof

Trace43/frontend trace28/parser185/validator23 pass279; callable125/118/239 pass482;
duplicate slots121 and gap105/33/46/105/30 pass440. Total1201 existing assertions,
plus exact test-selection1, pass. Existing emitted gap runs are positive finite
coverage and do not reproduce the new malformed selectors. Neutral callable
7 literals/11 calls/9 invalid literals/7 invalid calls/4 declarations/8 contextual
forms/23 mutations, gap9/0/63 plus public8/15/10/34, and duplicate7/0/59 pass.
No full component/canonical gate or dependency build ran.

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_GROUP33_EXISTING'
using LinkedSpecJulia, JSON3, Test
const REPO_ROOT=pwd()
const CORPUS_ROOT=joinpath(REPO_ROOT,"rust/linkedspec-runtime/tests/corpus")
const selected=Set(["Spec parser","Spec validation","Trace controls events and sinks","Frontend compiler and staged trace coverage"])
const seen=Set{String}()
for expression in Meta.parseall(read("julia/test/runtests.jl",String)).args
 expression isa Expr || continue
 if expression.head==:function
  Core.eval(Main,expression)
 elseif expression.head==:macrocall && expression.args[1]==Symbol("@testset") && expression.args[3] in selected
  Core.eval(Main,expression);push!(seen,expression.args[3])
 end
end
@test seen==selected
include("julia/test/callable_codeblock_literal_contract_test.jl")
include("julia/test/duplicate_regex_slot_identity_contract_test.jl")
include("julia/test/inter_match_gap_capture_contract_test.jl")
JULIA_GROUP33_EXISTING
bash tools/run_python_project_data.sh tools/check_callable_codeblock_contract.py
bash tools/run_python_project_data.sh tools/check_inter_match_gap_capture_contract.py
bash tools/run_python_project_data.sh tools/check_duplicate_regex_slot_identity_contract.py
```

Related: [[julia-frontend-validation]], [[julia-trace-controls-sinks]],
[[dart-null-named-selector-validation-gap]], [[julia-function-projection-metadata-gaps]],
[[julia-callable-codeblock-literal-state]].
