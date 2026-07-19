const _ROOT_ROUTE_MARKED_SOURCE = raw"""
Earlier:
 /x/
 E { return("earlier") }

Marked::
 /x/
 E { return("marked") }

Later:
 /x/
 E { return("later") }
"""

const _ROOT_ROUTE_MARKERLESS_SOURCE = raw"""
First:
 /x/
 E { return("first") }

Second:
 /x/
 E { return("second") }
"""

function _root_route_failure(call)
    try
        call()
    catch error
        return error
    end
    return nothing
end

function _root_route_host_process(scratch, runner, generated, private_depot)
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

function _root_route_trace_events(call)
    output = IOBuffer()
    trace = LinkedSpecTraceEmitter(trace_config_enabled("low"); stdout_io = output)
    result = call(trace)
    return result, trace_events(trace), String(take!(output))
end

@testset "Julia root-rule loaded and normalized routes" begin
    routes = (
        (
            name = "marked",
            source = _ROOT_ROUTE_MARKED_SOURCE,
            default_value = "marked",
            explicit_label = "Earlier",
            explicit_value = "earlier",
        ),
        (
            name = "markerless",
            source = _ROOT_ROUTE_MARKERLESS_SOURCE,
            default_value = "first",
            explicit_label = "Second",
            explicit_value = "second",
        ),
    )

    mktempdir() do scratch
        for route in routes
            direct = compile_spec(parse_spec(route.source))
            descriptor_before = to_descriptor_json(direct)

            path = joinpath(scratch, "$(route.name).spec")
            write(path, route.source)
            loaded = load_and_compile_spec(path_spec_request(path), SpecLoadOptions(scratch))
            @test runtime_parse(create_engine(loaded), "x").value == route.default_value
            @test runtime_parse(
                create_engine(loaded),
                "x";
                top_rule = route.explicit_label,
            ).value == route.explicit_value
            @test to_descriptor_json(loaded.compiled) == descriptor_before

            normalized_json = JSON3.read(JSON3.write(to_json(parse_spec(route.source))))
            normalized = from_json(SpecFile, normalized_json)
            reconstructed = compile_spec(normalized)
            @test runtime_parse(
                LinkedSpecRuntimeEngine(reconstructed),
                "x",
            ).value == route.default_value
            @test runtime_parse(
                LinkedSpecRuntimeEngine(reconstructed),
                "x";
                top_rule = route.explicit_label,
            ).value == route.explicit_value
            @test to_descriptor_json(reconstructed) == descriptor_before
        end

        zero_path = joinpath(scratch, "zero.spec")
        write(zero_path, "# no rules\n")
        zero = _root_route_failure() do
            load_and_compile_spec(path_spec_request(zero_path), SpecLoadOptions(scratch))
        end
        @test zero isa SpecPipelineException
        if zero isa SpecPipelineException
            projection = to_json(zero)
            @test projection["stage"] == "validate_spec"
            @test projection["code"] == "no_rules_defined"
            @test projection["detail"] == "spec does not define any rules"
        end
    end
end

@testset "Julia root-rule generated routes and selection trace" begin
    routes = (
        (
            source = _ROOT_ROUTE_MARKED_SOURCE,
            identity = "root-routes/marked.spec",
            default_value = "marked",
            effective = "Marked",
            basis = "first_authored_marker",
        ),
        (
            source = _ROOT_ROUTE_MARKERLESS_SOURCE,
            identity = "root-routes/markerless.spec",
            default_value = "first",
            effective = "First",
            basis = "first_authored_rule",
        ),
    )

    for route in routes
        compiled = compile_spec(parse_spec(route.source))
        plan = build_generated_rule_plan(compiled)
        descriptor_before = to_descriptor_json(compiled)
        @test execute_generated_parser_v1(
            compiled,
            plan,
            "x",
            route.identity,
        ) == route.default_value
        result, events, output = _root_route_trace_events() do trace
            execute_generated_parser_v1(
                compiled,
                plan,
                "x",
                route.identity;
                trace = trace,
            )
        end
        @test result == route.default_value
        selection = only(filter(
            event -> event.topic == "julia_runtime:entry_rule_selection",
            events,
        ))
        @test selection.kind == LinkedSpecTraceDecision
        @test selection.level == LinkedSpecTraceLow
        @test occursin("taken=1", selection.details)
        @test occursin("requested=<default>", selection.details)
        @test occursin("effective=$(route.effective)", selection.details)
        @test occursin("basis=$(route.basis)", selection.details)
        @test occursin("julia_runtime:entry_rule_selection", output)
        @test to_descriptor_json(compiled) == descriptor_before
        @test all(Set(keys(to_json(row))) == Set(["label", "family"]) for row in plan)
    end

    compiled = compile_spec(parse_spec(_ROOT_ROUTE_MARKED_SOURCE))
    plan = build_generated_rule_plan(compiled)
    explicit, events, _ = _root_route_trace_events() do trace
        execute_generated_parser_v1(
            compiled,
            plan,
            "x",
            "root-routes/explicit.spec";
            top_rule = "Earlier",
            trace = trace,
        )
    end
    @test explicit == "earlier"
    selection = only(filter(
        event -> event.topic == "julia_runtime:entry_rule_selection",
        events,
    ))
    @test occursin("requested=Earlier", selection.details)
    @test occursin("effective=Earlier", selection.details)
    @test occursin("basis=explicit_selector", selection.details)
end

@testset "Julia generated root failures preserve portable identity" begin
    identity = "root-routes/failure.spec"
    compiled = compile_spec(parse_spec(_ROOT_ROUTE_MARKED_SOURCE))
    plan = build_generated_rule_plan(compiled)

    trace_output = IOBuffer()
    trace = LinkedSpecTraceEmitter(trace_config_enabled("low"); stdout_io = trace_output)
    unknown = _root_route_failure() do
        execute_generated_parser_v1(
            compiled,
            plan,
            "x",
            identity;
            top_rule = "Missing",
            trace = trace,
        )
    end
    @test unknown isa GeneratedSourceException
    if unknown isa GeneratedSourceException
        @test to_json(unknown) == Dict{String,Any}(
            "type" => "generated_source_error",
            "stage" => "select_entry_rule",
            "code" => "entry_rule_not_found",
            "summary" => "Generated Julia parser entry-rule selection failed",
            "source_identity" => identity,
            "entry_rule" => "Missing",
            "rule_label" => "Missing",
            "detail" => "entry rule 'Missing' is not defined",
        )
    end
    failure_selection = only(filter(
        event -> event.topic == "julia_runtime:entry_rule_selection",
        trace_events(trace),
    ))
    @test occursin("taken=0", failure_selection.details)
    @test occursin("requested=Missing", failure_selection.details)
    @test occursin("effective=<none>", failure_selection.details)
    @test occursin("stage=select_entry_rule", failure_selection.details)
    @test occursin("code=entry_rule_not_found", failure_selection.details)
    @test occursin("julia_runtime:entry_rule_selection", String(take!(trace_output)))

    empty = compile_spec(SpecFile(rules = Rule[]); validate_source = false)
    zero = _root_route_failure() do
        execute_generated_parser_v1(
            empty,
            GeneratedPlanRow[],
            "",
            identity;
            top_rule = "Missing",
        )
    end
    @test zero isa GeneratedSourceException
    if zero isa GeneratedSourceException
        @test to_json(zero) == Dict{String,Any}(
            "type" => "generated_source_error",
            "stage" => "validate_spec",
            "code" => "no_rules_defined",
            "summary" => "Generated Julia parser entry-rule selection failed",
            "source_identity" => identity,
            "detail" => "compiled spec does not contain any rules",
        )
    end

    stale_plan = plan[1:(end - 1)]
    stale = _root_route_failure() do
        execute_generated_parser_v1(
            compiled,
            stale_plan,
            "x",
            identity;
            top_rule = "Missing",
        )
    end
    @test stale isa GeneratedSourceException
    if stale isa GeneratedSourceException
        @test stale.stage == ValidateGeneratedPlanStage
        @test stale.code == GeneratedPlanRowCountMismatchCode
    end
end

@testset "Independently emitted Julia root routes" begin
    compiled = compile_spec(parse_spec(_ROOT_ROUTE_MARKERLESS_SOURCE))
    identity = "root-routes/emitted-markerless.spec"
    generated = emit_julia_source_v1(compiled, identity)

    mktempdir() do scratch
        private_depot = joinpath(scratch, "depot")
        mkpath(private_depot)
        write(
            joinpath(scratch, "Project.toml"),
            "name = \"RootRouteHost\"\n" *
            "uuid = \"36e603b1-6247-499a-bfdc-161dc941c96b\"\n" *
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
@assert Parser.LINKEDSPEC_GENERATED_SOURCE_CONTRACT == "linkedspec-generated-source-v1"
@assert Parser.LINKEDSPEC_GENERATED_SOURCE_FORMAT == 1
@assert Parser.execute("x") == "first"
@assert Parser.execute("x"; top_rule = "Second") == "second"
@assert all(Set(keys(LinkedSpecJulia.to_json(row))) == Set(["label", "family"]) for row in Parser.plan())
trace_io = IOBuffer()
@assert Parser.execute_with_trace(
    "x",
    LinkedSpecJulia.trace_config_enabled("low");
    top_rule = "Second",
    stdout_io = trace_io,
) == "second"
trace = String(take!(trace_io))
@assert occursin("julia_runtime:entry_rule_selection", trace)
@assert occursin("requested=Second", trace)
@assert occursin("effective=Second", trace)
@assert occursin("basis=explicit_selector", trace)
print("root-route-host-ok")
""",
        )
        passed, output = _root_route_host_process(
            scratch,
            runner_path,
            generated_path,
            private_depot,
        )
        @test passed
        @test output == "root-route-host-ok"
    end
end
