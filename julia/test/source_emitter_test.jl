function _generated_source_test_spec()
    value = string("λ:", Char(0x24))
    source = "Top::\n /é/\n E { return(" * String(JSON3.write(value)) * ") }\n"
    return compile_spec(parse_spec(source)), value
end

function _generated_source_host_process(scratch, runner, generated, private_depot)
    separator = Sys.iswindows() ? ';' : ':'
    parent_depot = get(ENV, "JULIA_DEPOT_PATH", "")
    depot_path = isempty(parent_depot) ?
        private_depot : string(private_depot, separator, parent_depot)
    load_path = join(
        [scratch, joinpath(REPO_ROOT, "julia"), "@stdlib"],
        separator,
    )
    command = `$(Base.julia_cmd()) --project=$scratch --startup-file=no --history-file=no --compiled-modules=no $runner $generated`
    environment = copy(ENV)
    environment["JULIA_DEPOT_PATH"] = depot_path
    environment["JULIA_LOAD_PATH"] = load_path
    environment["JULIA_PKG_OFFLINE"] = "true"
    output = IOBuffer()
    process = run(
        pipeline(ignorestatus(setenv(command, environment)); stdout = output, stderr = output),
    )
    return success(process), String(take!(output))
end

const _GENERATED_FAMILY_MATRIX_SOURCE = raw"""
DefaultRoot::
 I { set(words, []) }
 /hello[ \t]+(\w+)/
 LE { push(words, match_group(0)) }
 E { return(copy(words)) }

OrAcode:OR
 /go/ -> OrDone { return("or-acode") }
OrDone: /go/

AndSingle:AND
 /one/ -> AndSingleDone { return("and-single") }
AndSingleDone: /one/

AndSeq:AND
 /a/ -> AndSeqFirst
 /[ \t]+b/ -> AndSeqSecond { return("and-seq") }
AndSeqFirst: /a/
AndSeqSecond: /[ \t]+b/

AndBcode:AND
 => AndBlindA
 => AndBlindB
 E { return("and-bcode") }
AndBlindA: /a/
AndBlindB: /[ \t]+b/

OrBcode:OR
 => OrBlindA
 => OrBlindB
 E { return(cat("or-bcode:", retv)) }
OrBlindA: /a/ E { return("A") }
OrBlindB: /b/ E { return("B") }

RepAcode:OR{2,3}
 I { set(rep_acode, []) }
 /a/ -> RepA { push(rep_acode, match_text()) }
 /b/ -> RepB { push(rep_acode, match_text()) }
 E { return(copy(rep_acode)) }
RepA: /a/
RepB: /b/

RepBcode:OR{2,3}
 I { set(rep_bcode, []) }
 => RepBlindA
 => RepBlindB
 LE { push(rep_bcode, retv) }
 E { return(copy(rep_bcode)) }
RepBlindA:& /a/ LE { return("A") }
RepBlindB:& /b/ LE { return("B") }

RepAndAcode:AND{2}
 I { set(rep_and_acode, []); set(rep_and_acode_pair, []) }
 /a/ -> RepAndA { push(rep_and_acode_pair, match_text()) }
 /b/ -> RepAndB { push(rep_and_acode_pair, match_text()) }
 IT { push(rep_and_acode, copy(rep_and_acode_pair)); set(rep_and_acode_pair, []) }
 E { return(copy(rep_and_acode)) }
RepAndA: /a/
RepAndB: /b/

RepAndBcode:AND{2}
 I { set(rep_and_bcode, []); set(rep_and_bcode_group, []) }
 => RepAndBlindA { push(rep_and_bcode_group, retv) }
 => RepAndBlindB { push(rep_and_bcode_group, retv) }
 IT { push(rep_and_bcode, copy(rep_and_bcode_group)); set(rep_and_bcode_group, []) }
 E { return(copy(rep_and_bcode)) }
RepAndBlindA:& /a/ LE { return("A") }
RepAndBlindB:& /b/ LE { return("B") }
"""

const _GENERATED_FAMILY_CASES = [
    (label = "DefaultRoot", family = "default", input = "hello one hello two"),
    (label = "OrAcode", family = "or_acode", input = "go"),
    (label = "AndSingle", family = "and_single_acode", input = "one"),
    (label = "AndSeq", family = "and_acode_seq", input = "a b"),
    (label = "AndBcode", family = "and_bcode", input = "a b"),
    (label = "OrBcode", family = "or_bcode", input = "a"),
    (label = "RepAcode", family = "rep_acode", input = "abab"),
    (label = "RepBcode", family = "rep_bcode", input = "abab"),
    (label = "RepAndAcode", family = "rep_and_acode", input = "abab"),
    (label = "RepAndBcode", family = "rep_and_bcode", input = "abab"),
]

function _generated_plan_failure(call)
    try
        call()
    catch error
        return error
    end
    return nothing
end

const JULIA_GENERATED_SOURCE_ACCEPTED_SUBSET_COUNT = 8

function _parse_generated_corpus_spec(source)
    try
        return parse_spec(source)
    catch error
        if error isa SpecParseException
            return parse_spec_with_staged_user_function_definitions(source)
        end
        rethrow()
    end
end

@testset "Generated Julia source matches contract accepted subset" begin
    contract_path = joinpath(
        REPO_ROOT,
        "capability_conformance",
        "generated_source_contract.json",
    )
    contract = JSON3.read(read(contract_path, String), Dict{String,Any})
    accepted_subset = String[
        String(name) for name in contract["corpus_proof"]["accepted_subset"]
    ]
    @test length(accepted_subset) == JULIA_GENERATED_SOURCE_ACCEPTED_SUBSET_COUNT

    corpus_root = joinpath(REPO_ROOT, "rust", "linkedspec-runtime", "tests", "corpus")
    validation = load_corpus_fixtures(corpus_root)
    fixtures = Dict(fixture.name => fixture for fixture in validation.fixtures)
    @test all(name -> haskey(fixtures, name), accepted_subset)

    scratch = mktempdir()
    private_depot = joinpath(scratch, "depot")
    mkpath(private_depot)
    try
        write(
            joinpath(scratch, "Project.toml"),
            "name = \"GeneratedSubsetHost\"\n" *
            "uuid = \"646d7ef1-f5fe-4f66-9fcc-2aee85c02fed\"\n" *
            "version = \"0.1.0\"\n",
        )
        cases = Dict{String,Any}[]
        for (index, case_name) in enumerate(accepted_subset)
            fixture = fixtures[case_name]
            spec = _parse_generated_corpus_spec(fixture.spec_source)
            compiled = compile_spec(spec)
            interpreter_value = runtime_execute(
                LinkedSpecRuntimeEngine(compiled),
                fixture.input_text,
            ).value
            @test interpreter_value == fixture.expected_json

            identity = "generated-source/julia-subset/$case_name.spec"
            generated_path = joinpath(scratch, "case_$index.jl")
            write(generated_path, emit_julia_source_v1(compiled, identity))
            push!(cases, Dict(
                "name" => case_name,
                "path" => generated_path,
                "input" => fixture.input_text,
                "expected" => fixture.expected_json,
                "identity" => identity,
                "plan" => [to_json(row) for row in build_generated_rule_plan(compiled)],
            ))
        end
        write(joinpath(scratch, "subset.json"), JSON3.write(Dict("cases" => cases)))
        runner_path = joinpath(scratch, "runner.jl")
        write(
            runner_path,
            """
import JSON3
import LinkedSpecJulia

normalize(value) = value
normalize(value::AbstractVector) = [normalize(item) for item in value]
normalize(value::AbstractDict) = Dict(String(key) => normalize(item) for (key, item) in value)
latest_binding(owner::Module, name::Symbol) =
    Base.invokelatest(() -> Core.getglobal(owner, name))

function main()
subset = JSON3.read(read(joinpath(dirname(ARGS[1]), "subset.json"), String))
values = Dict{String,Any}()
metadata = Dict{String,Any}()
plans = Dict{String,Any}()
first_parser = nothing
first_input = nothing
for (index, case) in enumerate(subset["cases"])
    host = Module(Symbol("GeneratedSubsetCase", index))
    Base.include(host, String(case["path"]))
    parser = Base.invokelatest(() -> getfield(host, :LinkedSpecGeneratedParser))
    plan_function = latest_binding(parser, :plan)
    validate_function = latest_binding(parser, :validate_plan)
    execute_function = latest_binding(parser, :execute)
    metadata_function = latest_binding(parser, :metadata)
    case_plan = Base.invokelatest(plan_function)
    Base.invokelatest(validate_function, case_plan)
    name = String(case["name"])
    values[name] = normalize(Base.invokelatest(execute_function, String(case["input"])))
    metadata[name] = normalize(LinkedSpecJulia.to_json(Base.invokelatest(metadata_function)))
    plans[name] = normalize([LinkedSpecJulia.to_json(row) for row in case_plan])
    @assert values[name] == normalize(case["expected"])
    @assert metadata[name] == Dict(
        "contract_id" => "linkedspec-generated-source-v1",
        "format_version" => 1,
        "source_identity" => String(case["identity"]),
    )
    @assert plans[name] == normalize(case["plan"])
    if index == 1
        first_parser = parser
        first_input = String(case["input"])
    end
end
trace_io = IOBuffer()
Base.invokelatest(
    latest_binding(first_parser, :execute_with_trace),
    first_input,
    LinkedSpecJulia.trace_config_enabled("low");
    stdout_io = trace_io,
)
trace = String(take!(trace_io))
@assert occursin("generated_rule_enter", trace)
@assert occursin("generated_family_decision", trace)
@assert occursin("generated_rule_exit", trace)
@assert occursin("generated-source/julia-subset", trace)
print("generated-subset-host-ok")
end

main()
""",
        )
        passed, output = _generated_source_host_process(
            scratch,
            runner_path,
            first(cases)["path"],
            private_depot,
        )
        @test passed
        @test output == "generated-subset-host-ok"
    finally
        rm(scratch; recursive = true, force = true)
    end
    @test !ispath(scratch)
end

@testset "Generated Julia family plan and direct execution" begin
    compiled = compile_spec(parse_spec(_GENERATED_FAMILY_MATRIX_SOURCE))
    identity = "generated-source/julia-family-matrix.spec"
    plan = build_generated_rule_plan(compiled)
    plan_by_label = Dict(row.label => row.family for row in plan)

    @test [plan_by_label[case.label] for case in _GENERATED_FAMILY_CASES] ==
          [case.family for case in _GENERATED_FAMILY_CASES]
    @test Set(case.family for case in _GENERATED_FAMILY_CASES) ==
          Set(generated_rule_family_name(family) for family in instances(GeneratedRuleFamily))
    @test validate_generated_rule_plan_v1(compiled, plan, identity) == plan_by_label

    generated_v1_results = Dict{String,Any}()
    for case in _GENERATED_FAMILY_CASES
        legacy = runtime_execute(
            LinkedSpecJulia._generated_v1_compatibility_engine(compiled),
            case.input;
            top_rule = case.label,
        ).value
        generated_v1_results[case.label] = legacy
        @test execute_generated_parser_v1(
            compiled,
            plan,
            case.input,
            identity;
            top_rule = case.label,
        ) == legacy
    end
    @test generated_v1_results["RepBcode"] == Any["A", "A", "B"]

    mutations = [
        (plan[1:(end - 1)], GeneratedPlanRowCountMismatchCode),
        ([GeneratedPlanRow("Wrong", plan[1].family); plan[2:end]], GeneratedPlanLabelMismatchCode),
        ([GeneratedPlanRow(plan[1].label, "or_acode"); plan[2:end]], GeneratedPlanFamilyMismatchCode),
        ([GeneratedPlanRow(plan[1].label, "invented"); plan[2:end]], GeneratedPlanUnknownFamilyCode),
    ]
    for (mutated, expected_code) in mutations
        failure = _generated_plan_failure(
            () -> validate_generated_rule_plan_v1(compiled, mutated, identity),
        )
        @test failure isa GeneratedSourceException
        @test failure.stage == ValidateGeneratedPlanStage
        @test failure.code == expected_code
    end

    generated = emit_julia_source_v1(compiled, identity)
    mktempdir() do scratch
        private_depot = joinpath(scratch, "depot")
        mkpath(private_depot)
        write(
            joinpath(scratch, "Project.toml"),
            "name = \"GeneratedFamilyHost\"\n" *
            "uuid = \"bbd21f80-f220-41f6-ab13-8beabf6a251f\"\n" *
            "version = \"0.1.0\"\n",
        )
        generated_path = joinpath(scratch, "generated_parser.jl")
        runner_path = joinpath(scratch, "runner.jl")
        manifest_path = joinpath(scratch, "matrix.json")
        write(generated_path, generated)
        write(
            manifest_path,
            JSON3.write(Dict(
                "cases" => [
                    Dict(
                        "label" => case.label,
                        "family" => case.family,
                        "input" => case.input,
                        "expected" => generated_v1_results[case.label],
                    )
                    for case in _GENERATED_FAMILY_CASES
                ],
            )),
        )
        write(
            runner_path,
            """
import JSON3
import LinkedSpecJulia
include(ARGS[1])
const Parser = LinkedSpecGeneratedParser
matrix = JSON3.read(read(joinpath(dirname(ARGS[1]), "matrix.json"), String))
plan = Dict(row.label => row.family for row in Parser.plan())
Parser.validate_plan(Parser.plan())
for case in matrix["cases"]
    label = String(case["label"])
    @assert plan[label] == String(case["family"])
    @assert Parser.execute(String(case["input"]); top_rule = label) == case["expected"]
end
trace_io = IOBuffer()
first_case = first(matrix["cases"])
Parser.execute_with_trace(
    String(first_case["input"]),
    LinkedSpecJulia.trace_config_enabled("low");
    top_rule = String(first_case["label"]),
    stdout_io = trace_io,
)
trace = String(take!(trace_io))
@assert occursin("generated_rule_enter", trace)
@assert occursin("generated_family_decision", trace)
@assert occursin("generated_rule_exit", trace)
@assert occursin("generated-source/julia-family-matrix.spec", trace)
print("generated-family-host-ok")
""",
        )
        passed, output = _generated_source_host_process(
            scratch,
            runner_path,
            generated_path,
            private_depot,
        )
        @test passed
        @test output == "generated-family-host-ok"
    end
end

@testset "Generated Julia source scaffold" begin
    compiled, expected_value = _generated_source_test_spec()
    identity = string("generated/λ", Char(0x24), ".spec")
    generated = emit_julia_source_v1(compiled, identity)
    inline_generated = emit_julia_source(compiled)

    @test generated == emit_julia_source_v1(compiled, identity)
    @test generated != emit_julia_source_v1(compiled, "generated/other.spec")
    @test generated == replace(
        inline_generated,
        bytes2hex(codeunits("<inline>")) => bytes2hex(codeunits(identity)),
    )
    @test occursin("module LinkedSpecGeneratedParser", generated)
    @test occursin("diagnostic_output_sink = nothing", generated)
    @test occursin(bytes2hex(codeunits(identity)), generated)
    @test occursin(bytes2hex(codeunits(expected_value)), generated)
    @test !occursin(identity, generated)

    metadata = GeneratedSourceMetadata(identity)
    @test to_json(metadata) == Dict(
        "contract_id" => "linkedspec-generated-source-v1",
        "format_version" => 1,
        "source_identity" => identity,
    )

    empty_identity_error = try
        emit_julia_source_v1(compiled, "")
        nothing
    catch error
        error
    end
    @test empty_identity_error isa GeneratedSourceException
    @test to_json(empty_identity_error) == Dict(
        "type" => "generated_source_error",
        "stage" => "emit_source",
        "code" => "generated_source_emit_failed",
        "summary" => "Generated Julia source identity must not be empty",
        "source_identity" => "",
        "detail" => "source_identity is required",
    )

    compile_error = generated_source_compile_failed(identity, ArgumentError("broken payload"))
    @test generated_source_stage_name(compile_error.stage) ==
          "compile_or_load_generated_source"
    @test generated_source_code_name(compile_error.code) ==
          "generated_source_compile_failed"
    @test sprint(showerror, compile_error) ==
          "Generated Julia source failed to compile or load: ArgumentError: broken payload"

    mktempdir() do scratch
        private_depot = joinpath(scratch, "depot")
        mkpath(private_depot)
        write(
            joinpath(scratch, "Project.toml"),
            "name = \"GeneratedSourceHost\"\n" *
            "uuid = \"4096c05b-8f48-4ee1-89a1-52480dbf986d\"\n" *
            "version = \"0.1.0\"\n",
        )
        generated_path = joinpath(scratch, "generated_parser.jl")
        runner_path = joinpath(scratch, "runner.jl")
        write(generated_path, generated)
        write(
            runner_path,
            """
import LinkedSpecJulia
include(ARGS[1])

const Parser = LinkedSpecGeneratedParser
expected_identity = string("generated/λ", Char(0x24), ".spec")
expected_value = string("λ:", Char(0x24))
@assert Parser.LINKEDSPEC_GENERATED_SOURCE_CONTRACT == "linkedspec-generated-source-v1"
@assert Parser.LINKEDSPEC_GENERATED_SOURCE_FORMAT == 1
@assert LinkedSpecJulia.to_json(Parser.metadata()) == Dict(
    "contract_id" => "linkedspec-generated-source-v1",
    "format_version" => 1,
    "source_identity" => expected_identity,
)
@assert Parser.execute("é") == expected_value

execution_error = try
    Parser.execute("é"; top_rule = "Missing")
    nothing
catch error
    error
end
@assert execution_error isa LinkedSpecJulia.GeneratedSourceException
@assert LinkedSpecJulia.generated_source_stage_name(execution_error.stage) == "select_entry_rule"
@assert LinkedSpecJulia.generated_source_code_name(execution_error.code) == "entry_rule_not_found"
@assert execution_error.entry_rule == "Missing"
@assert execution_error.rule_label == "Missing"
print("generated-host-ok")
""",
        )

        passed, output = _generated_source_host_process(
            scratch,
            runner_path,
            generated_path,
            private_depot,
        )
        @test passed
        @test output == "generated-host-ok"

        corrupt_path = joinpath(scratch, "corrupt_parser.jl")
        corrupt_source = replace(
            generated,
            r"const _COMPILED_SPEC_JSON_HEX = \"[0-9a-f]+\"" =>
                "const _COMPILED_SPEC_JSON_HEX = \"00\"",
        )
        @test corrupt_source != generated
        write(corrupt_path, corrupt_source)
        write(
            runner_path,
            """
import LinkedSpecJulia
failure = try
    include(ARGS[1])
    nothing
catch error
    while error isa LoadError
        error = error.error
    end
    error
end
@assert failure isa LinkedSpecJulia.GeneratedSourceException
projection = LinkedSpecJulia.to_json(failure)
@assert projection["type"] == "generated_source_error"
@assert projection["stage"] == "compile_or_load_generated_source"
@assert projection["code"] == "generated_source_compile_failed"
@assert projection["source_identity"] == string("generated/λ", Char(0x24), ".spec")
print("generated-failure-ok")
""",
        )
        failed_as_expected, failure_output = _generated_source_host_process(
            scratch,
            runner_path,
            corrupt_path,
            private_depot,
        )
        @test failed_as_expected
        @test failure_output == "generated-failure-ok"
    end
end
