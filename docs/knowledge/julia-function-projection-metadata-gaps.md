---
id: julia-function-projection-metadata-gaps
title: Julia function projection accepts malformed metadata and lifecycle validation counts regex braces
answers:
  - can Julia function projection accept boolean version or arity fields
  - does Julia validate projected function payload versions
  - does Julia validate function line spans against source text
  - can caller supplied function nodes retain false line numbers through execution
  - why does a compact Julia lifecycle regex brace fail validation
  - which tasks own Julia function projection metadata and lifecycle balance repairs
date: 2026-09-11
status: confirmed native limitations; repairs pending behind startup prerequisites
tags: [julia, startup, function-projection, validation, source-spans, regex]
evidence: "JULIA-STARTUP-READING.1.32 reads UnicodeRuleLabel823-872, UserFunctionDefinitionShell1-810 and Validator1-640. Existing2536 plus selection1 and diagnostic118 assertions pass. Metadata repair .2.22.1-.3 and distinct downstream balance .2.21.3 are pending."
reverify:
  - "Run both repository-managed bash blocks below; no complete package or canonical gate is required for this reading replay."
---

## Exact reading and comprehension

The three ranges contain1,500 physical fragments /54,143 baseline-identical bytes,
ordered SHA-2568141dca93ba8508087a5aeb72fa2fca3bafbc3147f5fe7448cc7be322259e3b1.
Raw range digests are Unicode suffix4bf7bb19bd10dd485ce2f3baed0d4ddfcdb09a69ad79a9df695c641548c9ce92
(1500 bytes), shellb70c9512ec9997db7f1af3cf37fc7ce166d3d0eb493e3d880676665ac09d38dd
(30553), and validator3340938ba1cf8709c4e0c22c1c35514bd0a314d06a833dfadad01f04b33e1831
(22090). Seven untruncated windows finish the classifier and function projection;
validator edge-structure work after640 remains unread. Cumulative32/52 groups,
46,425 lines /1,612,089 bytes and41 complete files are reading evidence only.

The classifier rejects out-of-range integers before host conversion, binary-searches
the pinned range table, validates every scalar without normalization, and splits
prefixes on Julia character boundaries. Projection consumes executable-grammar nodes,
normalizes nested output shapes and trace scopes, distinguishes fixed-v1,
variadic-v2 and final-codeblock-v1 metadata, copies sidecars, validates matching
scalar text, rejects overlapping spans and strips one non-newline scalar to one
space. It preserves CR/LF and scalar coordinates rather than UTF-8 byte lengths.
Paths and job IDs are normalized to the actual function index before rule parsing.

The validator's traced and untraced paths have the same check order. This prefix
covers portable diagnostics, complete rule-label roles, duplicate labels and slots,
function namespaces/signatures/reserved parameters, retained raw syntax, lifecycle
balance and gap-directive eligibility. Registry validation still rejects duplicate
or reserved parameters that the shell projection alone does not reject.

## Confirmed metadata gaps — .2.22.1/.2/.3

Use the spec-defined parser's real node for the one-line `fn one(value)` source,
round-trip it through JSON and change only the indicated metadata:

- Definition `version: true` and, separately, `arity: true` are accepted. The helper
  at UserFunctionDefinitionShell752-759 admits Julia Bool through Integer and
  converts it to1; version dispatch at182 sees a normal fixed-v1 definition.
- Payload `version: 99`, or a missing payload version, is retained and accepted.
  `_validate_body_payload` at349 checks kind/name/signature/text/span but no version.
- Setting definition/body/payload/job line spans to99 succeeds for a line1 function.
  `_validate_span_text`573-584 verifies scalar text, while `_ufd_span_field`600-616
  checks positive ordered lines without deriving them from the source. Payload
  provenance still says line1, exposing additional unchecked disagreement.

All five malformed cases reach body staging, compilation and runtime output `ok`.
The clean node does too. Seven rejecting comparisons retain exact errors and input
immutability: boolean arity in every sidecar (downstream SpecAstException), changed
body text, body outside definition, unmatched job line coordinates, wrong parser,
negative version and v2 metadata carrying fixed-v1 fields. The boolean sidecar
rejection does not make the accepted outer boolean fields valid.

Metadata .2.22.1 owns exact numeric types/versions and conversion boundaries;
.2.22.2 owns source-derived coordinates and provenance audit; .2.22.3 owns supported
carriers, counterpart audit and public/canonical closure. These probes do not claim
semantic-index, CLI/MCP, emitted or independent counterpart outcomes. Ordinary
source parsing emits the clean metadata; the measured defect is the public
caller-supplied neutral-node projection boundary.

## Distinct downstream regex balance — .2.21.3

`Top:: I.return(matches("{", /{/))` retains its entire action code before
validation. The `}` and `[{]` regex twins do likewise. All three reject at the
`balanced_lifecycle_blocks` trace check, with identical quiet/traced errors.
Validator424 calls the quote-only `_brace_depth_delta`437-460, which counts the
regex brace as structure. This mechanism is independent of outer collection
truncation in [[julia-spec-lexical-boundary-defects]].

Plain regex, balanced brace class, quoted brace and closed braced lifecycle
comparisons execute correctly; the genuinely unclosed brace comparison rejects.
Julia .2.21.3 repairs this validator, while .2.21.1 retains outer collection and
.2.21.2 requires both before recurrence closure. Shared startup .54.3 retains
cross-backend coordination. Do not infer general regex acceptance from a balanced
brace class passing a delimiter-only counter.

## Exact diagnostic replay

Thirteen metadata controls pass73 assertions: five limitations and eight comparisons.
Eight lifecycle controls pass39: three limitations and five comparisons. Six
classifier boundary assertions bring the independent diagnostic total to118.
No source repair or whole-component signoff is claimed.

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_GROUP32_DIAGNOSTIC'
using LinkedSpecJulia, JSON3, Test

function group32_capture(f)
    try
        return (value=f(), error=nothing)
    catch error
        return (value=nothing, error=error)
    end
end

const group32_source = "fn one(value) { return(value) }\nTop::\n /x/ -> Top { return(one(\"ok\")) }\n"
const group32_base = only(parse_user_function_definition_asts(group32_source))
function group32_node(name)
    node = JSON3.read(JSON3.write(group32_base), Dict{String,Any})
    if name == "bool_version"
        node["version"] = true
    elseif name == "bool_outer_arity"
        node["arity"] = true
    elseif name == "payload_version"
        node["body_payload"]["version"] = 99
    elseif name == "missing_payload_version"
        delete!(node["body_payload"], "version")
    elseif name == "false_lines"
        for span in [node["source_span"], node["body_span"],
                     node["body_payload"]["source_span"], node["body_parse_job"]["source_span"]]
            span["line_start"] = 99
            span["line_end"] = 99
        end
    elseif name == "all_bool_arity"
        node["arity"] = true
        node["body_payload"]["arity"] = true
        node["body_parse_job"]["arity"] = true
    elseif name == "text_mismatch"
        node["body_source"] = "return(\"drift\")"
    elseif name == "outside_body"
        node["source_span"]["end"] = 0
        node["source_text"] = ""
    elseif name == "job_line_mismatch"
        node["body_parse_job"]["source_span"]["line_start"] = 99
        node["body_parse_job"]["source_span"]["line_end"] = 99
    elseif name == "bad_parser"
        node["body_parse_job"]["parser_spec_id"] = "other.spec"
    elseif name == "negative_version"
        node["version"] = -1
    elseif name == "version_two_without_signature"
        node["version"] = 2
    end
    return node
end

@testset "group32 projected metadata: five limitations and eight comparisons" begin
    accepted = ["clean", "bool_version", "bool_outer_arity", "payload_version",
                "missing_payload_version", "false_lines"]
    for name in accepted
        node = group32_node(name)
        saved = deepcopy(node)
        parsed = parse_spec_with_staged_user_function_definition_asts(group32_source, [node])
        definition = only(parsed.functions)
        @test node == saved
        @test definition.body_ast !== nothing
        @test definition.arity == 1
        @test definition.body_source == " return(value) "
        @test definition.source_span.line_start == (name == "false_lines" ? 99 : 1)
        @test definition.body_span.line_end == (name == "false_lines" ? 99 : 1)
        @test definition.body_payload["parent_ast_path"] == ["functions", "0", "body_source"]
        compiled = compile_spec(parsed)
        @test runtime_execute(LinkedSpecRuntimeEngine(compiled), "x").value == "ok"
        if name == "payload_version"
            @test definition.body_payload["version"] == 99
        elseif name == "missing_payload_version"
            @test !haskey(definition.body_payload, "version")
        elseif name == "false_lines"
            @test definition.body_payload["provenance"][1]["source_span"]["line_start"] == 1
            @test definition.body_parse_job.source_span.line_start == 99
        end
    end
    rejected = [
        ("all_bool_arity", SpecAstException, "arity must be an integer"),
        ("text_mismatch", UserFunctionDefinitionException, "body_source does not match its source span"),
        ("outside_body", UserFunctionDefinitionException, "body span is outside source span"),
        ("job_line_mismatch", UserFunctionDefinitionException, "body_parse_job source_span does not match body_span"),
        ("bad_parser", UserFunctionDefinitionException, "parser_spec_id must be actionir-body.spec"),
        ("negative_version", UserFunctionDefinitionException, "must be a non-negative integer"),
        ("version_two_without_signature", UserFunctionDefinitionException, "version 2 must store arity only in signature"),
    ]
    for (name, kind, message) in rejected
        node = group32_node(name)
        saved = deepcopy(node)
        result = group32_capture(() -> parse_spec_with_staged_user_function_definition_asts(group32_source, [node]))
        @test result.error isa kind
        @test occursin(message, sprint(showerror, result.error))
        @test node == saved
    end
end

@testset "group32 lifecycle balance: three limitations and five comparisons" begin
    cases = [
        ("compact_open", "return(matches(\"{\", /{/))", true),
        ("compact_close", "return(matches(\"}\", /}/))", true),
        ("compact_class", "return(matches(\"{\", /[{]/))", true),
        ("plain_regex", "return(matches(\"x\", /x/))", false),
        ("balanced_class", "return(matches(\"{\", /[{}]/))", false),
        ("quoted_brace", "return(\"{\")", false),
    ]
    for (name, code, rejected) in cases
        parsed = parse_spec("Top:: I." * code)
        @test length(top_rule(parsed).body) == 1
        @test only(top_rule(parsed).body).kind.code == code
        trace = LinkedSpecTraceEmitter(trace_config_enabled(LinkedSpecTraceDebug); stdout_io=IOBuffer())
        quiet = group32_capture(() -> validate_spec(parsed))
        traced = group32_capture(() -> validate_spec(parsed; trace=trace))
        @test typeof(quiet.error) == typeof(traced.error)
        if rejected
            @test quiet.error isa SpecValidationException
            @test sprint(showerror, quiet.error) == sprint(showerror, traced.error)
            @test occursin("unbalanced braces", sprint(showerror, quiet.error))
            @test any(event.topic == "julia_frontend:validate_spec:balanced_lifecycle_blocks" &&
                      occursin("taken=0", event.details) for event in trace_events(trace))
        else
            @test quiet.error === nothing
            @test runtime_execute(LinkedSpecRuntimeEngine(compile_spec(parsed)), "").value ==
                  (name == "quoted_brace" ? "{" : true)
        end
    end
    complete = parse_spec("Top:: I { return(\"ok\") }")
    @test runtime_execute(LinkedSpecRuntimeEngine(compile_spec(complete)), "").value == "ok"
    incomplete = parse_spec("Top:: I { return(\"ok\")")
    result = group32_capture(() -> compile_spec(incomplete))
    @test result.error isa SpecValidationException
    @test occursin("unbalanced braces", sprint(showerror, result.error))
end

@testset "group32 Unicode classifier integer and exact prefix boundaries" begin
    @test !LinkedSpecJulia.is_rule_label_codepoint(big(-1))
    @test !LinkedSpecJulia.is_rule_label_codepoint(big(2)^100)
    @test LinkedSpecJulia.is_rule_label_codepoint(big(0x30))
    @test !LinkedSpecJulia.is_rule_label_codepoint(0xd800)
    prefix = LinkedSpecJulia.take_rule_label_prefix("T·öp!suffix")
    @test prefix.label == "T·öp"
    @test prefix.remainder == "!suffix"
end
JULIA_GROUP32_DIAGNOSTIC
```

## Existing focused proof

Existing original testsets pass325 assertions (registry39, frontend trace28,
parser185, validator23, projection27, spec-driven parser7, AST16); exact testset
selection adds1 separately. Classifier1674, variadic55 and callable-codeblock482
(125 invocation/118 final normalization/239 construction) bring existing proof
to2536. Neutral signatures pass3 definitions/9 calls/7 invalid definitions.
Loading helper definitions and running full consumers grants no later source credit.

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_GROUP32_EXISTING'
using LinkedSpecJulia, JSON3, Test
const REPO_ROOT=pwd()
const CORPUS_ROOT=joinpath(REPO_ROOT,"rust/linkedspec-runtime/tests/corpus")
const selected=Set(["Spec parser","Spec validation","Spec AST JSON contract","User function definition shell projection","Spec-driven user function definition parser","Staged function-body parser registry","Frontend compiler and staged trace coverage"])
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
include("julia/test/unicode_rule_label_classifier_test.jl")
include("julia/test/variadic_user_function_contract_test.jl")
include("julia/test/callable_codeblock_literal_contract_test.jl")
JULIA_GROUP32_EXISTING
bash tools/run_python_project_data.sh tools/check_callable_signature_contract.py
```

Related: [[julia-user-function-definition-projection]], [[julia-frontend-validation]],
[[julia-unicode-rule-label-preflight]], [[julia-staged-function-body-registry]].
