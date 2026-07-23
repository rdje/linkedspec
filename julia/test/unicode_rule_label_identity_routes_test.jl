# FUTURE-PARITY-BACKLOG.10.6.1.2 — exact downstream Julia label identity.

function _julia_unicode_identity_labels()
    labels = String[]
    for fixture in JULIA_UNICODE_RULE_LABEL_CONTRACT["positive_fixtures"]
        push!(labels, String(fixture["label"]))
    end
    for fixture in JULIA_UNICODE_RULE_LABEL_CONTRACT["distinct_fixtures"]
        for side in ("left", "right")
            label = String(fixture[side])
            if !(label in labels)
                push!(labels, label)
            end
        end
    end
    return labels
end

function _julia_unicode_identity_source(labels::AbstractVector{<:AbstractString})
    output = IOBuffer()
    for (index, label) in enumerate(labels)
        println(output, label, index == 1 ? "::" : ":")
        println(output, " /x/")
        println(output, " E { return(", JSON3.write(label), ") }")
        println(output)
    end
    return String(take!(output))
end

function _julia_unicode_identity_error(call)
    try
        call()
    catch error
        return error
    end
    return nothing
end

function _julia_unicode_identity_host_process(
    scratch,
    runner,
    generated,
    labels_path,
    private_depot,
)
    separator = Sys.iswindows() ? ';' : ':'
    parent_depot = get(ENV, "JULIA_DEPOT_PATH", "")
    depot_path = isempty(parent_depot) ?
        private_depot : string(private_depot, separator, parent_depot)
    load_path = join(
        [scratch, joinpath(REPO_ROOT, "julia"), "@stdlib"],
        separator,
    )
    command = `$(Base.julia_cmd()) --project=$scratch --startup-file=no --history-file=no --compiled-modules=no $runner $generated $labels_path`
    environment = copy(ENV)
    environment["JULIA_DEPOT_PATH"] = depot_path
    environment["JULIA_LOAD_PATH"] = load_path
    environment["JULIA_PKG_OFFLINE"] = "true"
    output = IOBuffer()
    errors = IOBuffer()
    process = run(pipeline(
        ignorestatus(setenv(command, environment));
        stdout = output,
        stderr = errors,
    ))
    return success(process), String(take!(output)), String(take!(errors))
end

const JULIA_UNICODE_IDENTITY_LABELS = _julia_unicode_identity_labels()
const JULIA_UNICODE_IDENTITY_SOURCE =
    _julia_unicode_identity_source(JULIA_UNICODE_IDENTITY_LABELS)

@testset "every positive and distinct label survives compiled artifacts" begin
    labels = JULIA_UNICODE_IDENTITY_LABELS
    @test length(JULIA_UNICODE_RULE_LABEL_CONTRACT["positive_fixtures"]) == 9
    @test length(JULIA_UNICODE_RULE_LABEL_CONTRACT["distinct_fixtures"]) == 2
    @test length(labels) == 10

    parsed = parse_spec(JULIA_UNICODE_IDENTITY_SOURCE)
    validate_spec(parsed)
    compiled = compile_spec(parsed)
    compiled_json = to_json(compiled)
    descriptor = to_descriptor_json(compiled)
    plan = build_generated_rule_plan(compiled)

    @test [rule.header.label for rule in parsed.rules] == labels
    @test compiled.definition_order == labels
    @test compiled.compiled_rule_order == labels
    @test Set(keys(compiled.rules_by_label)) == Set(labels)
    @test Set(keys(compiled_json["rules_by_label"])) == Set(labels)
    @test Set(keys(descriptor["spec"])) == Set(labels)
    @test descriptor["meta"]["definition_order"] == labels
    @test descriptor["meta"]["compiled_rule_order"] == labels
    @test [row.label for row in plan] == labels

    reconstructed_spec = from_json(
        SpecFile,
        JSON3.read(JSON3.write(to_json(parsed))),
    )
    reconstructed = compile_spec(reconstructed_spec)
    @test to_json(reconstructed) == compiled_json
    @test to_descriptor_json(reconstructed) == descriptor

    native_engine = LinkedSpecRuntimeEngine(reconstructed)
    @test runtime_parse(native_engine, "x").value == first(labels)
    for label in labels
        rule = compiled_rule(compiled, label)
        @test rule !== nothing
        @test rule.label == label
        @test runtime_parse(native_engine, "x"; top_rule = label).value == label
        @test execute_generated_parser_v2(
            compiled,
            plan,
            "x",
            "unicode-label/direct-plan.spec";
            top_rule = label,
        ) == label
    end

    for fixture in JULIA_UNICODE_RULE_LABEL_CONTRACT["distinct_fixtures"]
        left = String(fixture["left"])
        right = String(fixture["right"])
        @test left != right
        @test compiled_rule(compiled, left) !== nothing
        @test compiled_rule(compiled, right) !== nothing
        @test compiled_rule(compiled, left) != compiled_rule(compiled, right)
    end
end

@testset "emitted source reconstructs and executes every exact label" begin
    labels = JULIA_UNICODE_IDENTITY_LABELS
    identity = "unicode-label/emitted-規則-𐐀.spec"
    compiled = compile_spec(parse_spec(JULIA_UNICODE_IDENTITY_SOURCE))
    emitted = emit_julia_source_v2(compiled, identity)
    encoded = match(r"const _COMPILED_SPEC_JSON_HEX = \"([0-9a-f]+)\"", emitted)
    @test encoded !== nothing
    payload = String(hex2bytes(encoded.captures[1]))
    reconstructed = compile_spec(from_json(SpecFile, JSON3.read(payload)))
    @test reconstructed.compiled_rule_order == labels
    @test [row.label for row in build_generated_rule_plan(reconstructed)] == labels

    mktempdir() do scratch
        private_depot = joinpath(scratch, "depot")
        mkpath(private_depot)
        write(
            joinpath(scratch, "Project.toml"),
            "name = \"JuliaUnicodeLabelEmittedHost\"\n" *
            "uuid = \"cdb67a3c-e949-4fa8-b661-a37ff4a7a224\"\n" *
            "version = \"0.1.0\"\n",
        )
        generated_path = joinpath(scratch, "generated_parser.jl")
        runner_path = joinpath(scratch, "runner.jl")
        labels_path = joinpath(scratch, "labels.json")
        write(generated_path, emitted)
        write(labels_path, JSON3.write(labels))
        write(
            runner_path,
            """
import JSON3
import LinkedSpecJulia

include(ARGS[1])
const Parser = LinkedSpecGeneratedParser
labels = JSON3.read(read(ARGS[2], String), Vector{String})
plan = Parser.plan()
Parser.validate_plan(plan)
values = [Parser.execute("x"; top_rule = label) for label in labels]
print(JSON3.write(Dict(
    "identity" => Parser.metadata().source_identity,
    "labels" => labels,
    "plan" => [row.label for row in plan],
    "values" => values,
)))
""",
        )
        passed, output, errors = _julia_unicode_identity_host_process(
            scratch,
            runner_path,
            generated_path,
            labels_path,
            private_depot,
        )
        @test passed
        @test isempty(errors)
        @test JSON3.read(output, Dict{String,Any}) == Dict{String,Any}(
            "identity" => identity,
            "labels" => labels,
            "plan" => labels,
            "values" => labels,
        )
    end
end

@testset "strict loading and primary commands preserve every exact label" begin
    labels = JULIA_UNICODE_IDENTITY_LABELS
    mktempdir() do scratch
        path = joinpath(scratch, "unicode-規則.spec")
        write(path, JULIA_UNICODE_IDENTITY_SOURCE)
        loaded = load_and_compile_spec(path_spec_request(path), SpecLoadOptions(scratch))
        @test loaded.loaded.source_text == JULIA_UNICODE_IDENTITY_SOURCE
        @test loaded.compiled.compiled_rule_order == labels
        @test !occursin(path, JSON3.write(to_json(loaded.compiled)))
        @test !occursin(path, JSON3.write(to_descriptor_json(loaded.compiled)))

        engine = create_engine(loaded)
        for label in labels
            @test runtime_parse(engine, "x"; top_rule = label).value == label
            output = IOBuffer()
            errors = IOBuffer()
            @test run_cli(
                [
                    "--inline-spec",
                    JULIA_UNICODE_IDENTITY_SOURCE,
                    "--input",
                    "x",
                    "--top-rule",
                    label,
                ];
                io = output,
                err = errors,
            ) == 0
            @test JSON3.read(chomp(String(take!(output))), String) == label
            @test isempty(String(take!(errors)))
        end

        supplementary = only(
            String(fixture["label"])
            for fixture in JULIA_UNICODE_RULE_LABEL_CONTRACT["positive_fixtures"]
            if fixture["id"] == "supplementary"
        )
        output = IOBuffer()
        errors = IOBuffer()
        @test run_cli(
            [
                "--spec-file",
                path,
                "--input",
                "x",
                "--top-rule",
                supplementary,
            ];
            io = output,
            err = errors,
        ) == 0
        @test JSON3.read(chomp(String(take!(output))), String) == supplementary
        @test isempty(String(take!(errors)))
    end
end

@testset "selectors diagnostics and traces retain exact Unicode identity" begin
    selected = String(only(
        fixture["right"]
        for fixture in JULIA_UNICODE_RULE_LABEL_CONTRACT["distinct_fixtures"]
        if fixture["id"] == "normalization_sensitive"
    ))
    missing = "規則Missing𐐀"
    identity = "unicode-label/diagnostic-規則.spec"
    compiled = compile_spec(parse_spec(JULIA_UNICODE_IDENTITY_SOURCE))
    engine = LinkedSpecRuntimeEngine(compiled)
    plan = build_generated_rule_plan(compiled)

    trace_output = IOBuffer()
    trace = LinkedSpecTraceEmitter(
        trace_config_enabled(LinkedSpecTraceDebug);
        stdout_io = trace_output,
    )
    @test runtime_parse(engine, "x"; top_rule = selected, trace = trace).value == selected
    @test any(
        event.topic == "julia_runtime:entry_rule_selection" &&
        occursin("requested=$selected", event.details) &&
        occursin("effective=$selected", event.details) &&
        occursin("basis=explicit_selector", event.details)
        for event in trace_events(trace)
    )
    native_trace_text = String(take!(trace_output))
    @test occursin("top_rule=$selected", native_trace_text)
    @test occursin(selected, native_trace_text)

    native_failure = _julia_unicode_identity_error() do
        runtime_parse(engine, "x"; top_rule = missing, trace = trace)
    end
    @test native_failure isa RuntimeInterpreterException
    if native_failure isa RuntimeInterpreterException
        @test to_json(native_failure.diagnostic) == Dict{String,Any}(
            "type" => "runtime_parser",
            "stage" => "select_entry_rule",
            "owner_stage" => "julia_runtime",
            "summary" => "Julia runtime entry-rule selection failed",
            "detail" => "entry rule '$missing' is not defined",
            "code" => "entry_rule_not_found",
            "top_rule" => missing,
            "entry_rule" => missing,
            "rule_label" => missing,
            "handler_source_label" => "julia_runtime:rule:$missing",
        )
    end
    @test any(
        event.topic == "julia_runtime:entry_rule_selection" &&
        occursin("requested=$missing", event.details)
        for event in trace_events(trace)
    )

    generated_failure = _julia_unicode_identity_error() do
        execute_generated_parser_v2(
            compiled,
            plan,
            "x",
            identity;
            top_rule = missing,
        )
    end
    @test generated_failure isa GeneratedSourceException
    if generated_failure isa GeneratedSourceException
        @test to_json(generated_failure) == Dict{String,Any}(
            "type" => "generated_source_error",
            "stage" => "select_entry_rule",
            "code" => "entry_rule_not_found",
            "summary" => "Generated Julia parser entry-rule selection failed",
            "source_identity" => identity,
            "entry_rule" => missing,
            "rule_label" => missing,
            "detail" => "entry rule '$missing' is not defined",
        )
    end

    mktempdir() do scratch
        trace_path = joinpath(scratch, "generated.trace")
        @test execute_generated_parser_with_trace_v2(
            compiled,
            plan,
            "x",
            LinkedSpecTraceConfig(
                level = LinkedSpecTraceDebug,
                trace_file = trace_path,
                sink_mode = LinkedSpecTraceRoute,
                reset_file = true,
            ),
            identity;
            top_rule = selected,
        ) == selected
        generated_trace = read(trace_path, String)
        @test occursin("requested=$selected", generated_trace)
        @test occursin("effective=$selected", generated_trace)
        @test occursin("top_rule=$selected", generated_trace)
        @test occursin(identity, generated_trace)
    end
end
