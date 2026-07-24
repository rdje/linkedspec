# FUTURE-PARITY-BACKLOG.10.6.6.3 — generated and emitted observation routes.

const JULIA_RUNTIME_ROUTE_RESPONSE_DIGEST =
    "36897041c6f71b95b577ce7b38f42d3649c6adffc6c37c069944a90f6eb65887"
const JULIA_RUNTIME_ROUTE_IDENTITY = "semantic-introspection/runtime.spec"

struct JuliaRuntimeRouteCallerFailure <: Exception
    id::String
end

function _julia_runtime_route_source()
    return read(
        joinpath(
            REPO_ROOT,
            "capability_conformance",
            "semantic_introspection",
            "runtime.spec",
        ),
        String,
    )
end

function _julia_runtime_route_base(source)
    return semantic_index(
        source;
        logical_name = "runtime.spec",
        source_detail_ceiling = SemanticSourceTextDetail,
    )
end

function _julia_runtime_route_request()
    return SemanticQuery(
        operation = SemanticQueryListOperation,
        record_kinds = ("execution", "event"),
        source = SemanticQuerySource(detail = SemanticSourceIdentityDetail),
    )
end

function _julia_runtime_route_neutral_request()
    return Dict{String,Any}(
        "contract" => "linkedspec-semantic-query-v1",
        "operation" => "list",
        "subjects" => Any[],
        "record_kinds" => Any["execution", "event"],
        "relation_kinds" => Any[],
        "direction" => "outgoing",
        "page" => Dict{String,Any}("after_id" => nothing, "limit" => 100),
        "budget" => Dict{String,Any}(
            "max_records" => 1000,
            "max_relations" => 2000,
            "max_depth" => 4,
        ),
        "source" => Dict{String,Any}(
            "detail" => "identity",
            "include_content_digest" => false,
        ),
    )
end

function _julia_runtime_route_check_digest(base, events)
    observed = with_execution_observation(base, events)
    typed = semantic_query(observed, _julia_runtime_route_request())
    neutral = semantic_query_neutral(
        observed,
        _julia_runtime_route_neutral_request(),
    )
    @test typed == neutral
    @test _semantic_query_kernel_digest(typed) == JULIA_RUNTIME_ROUTE_RESPONSE_DIGEST
    return nothing
end

function _julia_runtime_route_capture(call)
    events = RuntimeSemanticObservationEvent[]
    value = call(event -> push!(events, event))
    return value, events
end

function _julia_runtime_route_event_from_json(raw)
    kind = raw["event_kind"] == "regex_slot_selected" ?
        RuntimeSemanticRegexSlotSelected : RuntimeSemanticRuleResult
    return RuntimeSemanticObservationEvent(
        contract_id = raw["contract_id"],
        event_kind = kind,
        rule_label = raw["rule_label"],
        target_rule = raw["target_rule"],
        regex_index = raw["regex_index"],
        position = raw["position"],
        input_identity = raw["input_identity"],
        status = raw["status"],
    )
end

function _julia_runtime_route_host_process(
    scratch,
    runner,
    generated,
    exit_generated,
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
    command = `$(Base.julia_cmd()) --project=$scratch --startup-file=no --history-file=no --compiled-modules=no $runner $generated $exit_generated`
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

@testset "Julia generated and emitted semantic observation routes" begin
    source = _julia_runtime_route_source()
    compiled = _julia_runtime_observation_compile(source)
    plan = build_generated_rule_plan(compiled)
    base = _julia_runtime_route_base(source)
    expected = _julia_runtime_observation_expected_events()

    @testset "public generated helpers preserve outputs trace diagnostics and identity" begin
        baseline_diagnostics = RuntimeDiagnosticOutputEvent[]
        baseline = execute_generated_parser_v2(
            compiled,
            plan,
            JULIA_RUNTIME_OBSERVATION_INPUT,
            JULIA_RUNTIME_ROUTE_IDENTITY;
            diagnostic_output_sink = event -> push!(baseline_diagnostics, event),
        )
        observed_diagnostics = RuntimeDiagnosticOutputEvent[]
        observed, events = _julia_runtime_route_capture() do sink
            execute_generated_parser_v2(
                compiled,
                plan,
                JULIA_RUNTIME_OBSERVATION_INPUT,
                JULIA_RUNTIME_ROUTE_IDENTITY;
                diagnostic_output_sink = event -> push!(observed_diagnostics, event),
                semantic_observation_sink = sink,
            )
        end
        @test observed == baseline == Any["A", "B"]
        @test events == expected
        @test [to_json(event) for event in observed_diagnostics] ==
              [to_json(event) for event in baseline_diagnostics]
        _julia_runtime_route_check_digest(base, events)

        baseline_trace = IOBuffer()
        traced_baseline = execute_generated_parser_with_trace_v2(
            compiled,
            plan,
            JULIA_RUNTIME_OBSERVATION_INPUT,
            trace_config_enabled(LinkedSpecTraceDebug),
            JULIA_RUNTIME_ROUTE_IDENTITY;
            stdout_io = baseline_trace,
        )
        observed_trace = IOBuffer()
        traced_observed, traced_events = _julia_runtime_route_capture() do sink
            execute_generated_parser_with_trace_v2(
                compiled,
                plan,
                JULIA_RUNTIME_OBSERVATION_INPUT,
                trace_config_enabled(LinkedSpecTraceDebug),
                JULIA_RUNTIME_ROUTE_IDENTITY;
                stdout_io = observed_trace,
                semantic_observation_sink = sink,
            )
        end
        @test traced_observed == traced_baseline == Any["A", "B"]
        @test String(take!(observed_trace)) == String(take!(baseline_trace))
        @test traced_events == expected
        _julia_runtime_route_check_digest(base, traced_events)

        routes = Function[
            sink -> execute_generated_parser_v2(
                compiled,
                plan,
                JULIA_RUNTIME_OBSERVATION_INPUT,
                JULIA_RUNTIME_ROUTE_IDENTITY;
                semantic_observation_sink = sink,
            ),
            sink -> execute_generated_parser_with_trace_v2(
                compiled,
                plan,
                JULIA_RUNTIME_OBSERVATION_INPUT,
                trace_config_disabled(),
                JULIA_RUNTIME_ROUTE_IDENTITY;
                semantic_observation_sink = sink,
            ),
        ]
        for (index, route) in enumerate(routes)
            failure = JuliaRuntimeRouteCallerFailure("generated-$index")
            captured = try
                route(_ -> throw(failure))
                nothing
            catch error
                error
            end
            @test captured === failure
        end

        exit_compiled = _julia_runtime_observation_compile(
            "Top::\n /x/\n E { exit_now(7) }\n",
        )
        exit_events = RuntimeSemanticObservationEvent[]
        captured_exit = try
            execute_generated_parser_v2(
                exit_compiled,
                build_generated_rule_plan(exit_compiled),
                "x",
                "semantic-introspection/exit.spec";
                semantic_observation_sink = event -> push!(exit_events, event),
            )
            nothing
        catch error
            error
        end
        @test captured_exit isa RuntimeExitNow
        @test captured_exit.status == 7
        @test length(exit_events) == 1
        @test only(exit_events).event_kind == RuntimeSemanticRegexSlotSelected
    end

    @testset "fresh emitted direct and traced wrappers forward the existing sink" begin
        generated = emit_julia_source_v2(compiled, JULIA_RUNTIME_ROUTE_IDENTITY)
        @test generated == emit_julia_source_v2(compiled, JULIA_RUNTIME_ROUTE_IDENTITY)
        @test length(findall("semantic_observation_sink = nothing", generated)) == 2
        @test length(findall(
            "semantic_observation_sink = semantic_observation_sink",
            generated,
        )) == 2
        @test occursin("const LINKEDSPEC_GENERATED_SOURCE_FORMAT = 2", generated)
        @test occursin(
            "const LINKEDSPEC_GENERATED_SOURCE_CONTRACT = \"linkedspec-generated-source-v2\"",
            generated,
        )

        mktempdir() do scratch
            generated_path = joinpath(scratch, "runtime_generated.jl")
            write(generated_path, generated)
            host = Module(:JuliaRuntimeObservationGeneratedHost)
            Base.include(host, generated_path)
            parser = Base.invokelatest(
                getproperty,
                host,
                :LinkedSpecGeneratedParser,
            )
            execute = Base.invokelatest(getproperty, parser, :execute)
            execute_with_trace = Base.invokelatest(
                getproperty,
                parser,
                :execute_with_trace,
            )

            baseline_diagnostics = RuntimeDiagnosticOutputEvent[]
            baseline = Base.invokelatest(
                execute,
                JULIA_RUNTIME_OBSERVATION_INPUT;
                diagnostic_output_sink = event -> push!(baseline_diagnostics, event),
            )
            observed_diagnostics = RuntimeDiagnosticOutputEvent[]
            observed, events = _julia_runtime_route_capture() do sink
                Base.invokelatest(
                    execute,
                    JULIA_RUNTIME_OBSERVATION_INPUT;
                    diagnostic_output_sink = event -> push!(observed_diagnostics, event),
                    semantic_observation_sink = sink,
                )
            end
            @test observed == baseline == Any["A", "B"]
            @test events == expected
            @test [to_json(event) for event in observed_diagnostics] ==
                  [to_json(event) for event in baseline_diagnostics]
            _julia_runtime_route_check_digest(base, events)

            baseline_trace = IOBuffer()
            traced_baseline = Base.invokelatest(
                execute_with_trace,
                JULIA_RUNTIME_OBSERVATION_INPUT,
                trace_config_enabled(LinkedSpecTraceDebug);
                stdout_io = baseline_trace,
            )
            observed_trace = IOBuffer()
            traced_observed, traced_events = _julia_runtime_route_capture() do sink
                Base.invokelatest(
                    execute_with_trace,
                    JULIA_RUNTIME_OBSERVATION_INPUT,
                    trace_config_enabled(LinkedSpecTraceDebug);
                    stdout_io = observed_trace,
                    semantic_observation_sink = sink,
                )
            end
            @test traced_observed == traced_baseline == Any["A", "B"]
            @test String(take!(observed_trace)) == String(take!(baseline_trace))
            @test traced_events == expected
            _julia_runtime_route_check_digest(base, traced_events)

            routes = Function[
                sink -> Base.invokelatest(
                    execute,
                    JULIA_RUNTIME_OBSERVATION_INPUT;
                    semantic_observation_sink = sink,
                ),
                sink -> Base.invokelatest(
                    execute_with_trace,
                    JULIA_RUNTIME_OBSERVATION_INPUT,
                    trace_config_disabled();
                    semantic_observation_sink = sink,
                ),
            ]
            for (index, route) in enumerate(routes)
                failure = JuliaRuntimeRouteCallerFailure("emitted-$index")
                captured = try
                    route(_ -> throw(failure))
                    nothing
                catch error
                    error
                end
                @test captured === failure
            end
        end
    end

    @testset "isolated emitted host preserves direct traced exit and callback behavior" begin
        mktempdir() do scratch
            private_depot = joinpath(scratch, "depot")
            mkpath(private_depot)
            write(
                joinpath(scratch, "Project.toml"),
                "name = \"JuliaSemanticObservationHost\"\n" *
                "uuid = \"bfa02ea0-b421-4f41-86d4-787799f1a3d1\"\n" *
                "version = \"0.1.0\"\n",
            )
            generated_path = joinpath(scratch, "runtime_generated.jl")
            exit_path = joinpath(scratch, "exit_generated.jl")
            runner_path = joinpath(scratch, "runner.jl")
            write(
                generated_path,
                emit_julia_source_v2(compiled, JULIA_RUNTIME_ROUTE_IDENTITY),
            )
            exit_compiled = _julia_runtime_observation_compile(
                "Top::\n /x/\n E { exit_now(7) }\n",
            )
            write(
                exit_path,
                emit_julia_source_v2(
                    exit_compiled,
                    "semantic-introspection/emitted-exit.spec",
                ),
            )
            write(
                runner_path,
                raw"""
import JSON3
import LinkedSpecJulia

include(ARGS[1])
const Parser = LinkedSpecGeneratedParser
const INPUT = "ab\n"

struct CallerObservationFailure <: Exception end

function preserves_failure(call)
    failure = CallerObservationFailure()
    captured = try
        call(_ -> throw(failure))
        nothing
    catch error
        error
    end
    return captured === failure
end

baseline_diagnostics = LinkedSpecJulia.RuntimeDiagnosticOutputEvent[]
baseline = Parser.execute(
    INPUT;
    diagnostic_output_sink = event -> push!(baseline_diagnostics, event),
)
events = LinkedSpecJulia.RuntimeSemanticObservationEvent[]
observed_diagnostics = LinkedSpecJulia.RuntimeDiagnosticOutputEvent[]
observed = Parser.execute(
    INPUT;
    diagnostic_output_sink = event -> push!(observed_diagnostics, event),
    semantic_observation_sink = event -> push!(events, event),
)

baseline_trace = IOBuffer()
traced_baseline = Parser.execute_with_trace(
    INPUT,
    LinkedSpecJulia.trace_config_enabled(LinkedSpecJulia.LinkedSpecTraceDebug);
    stdout_io = baseline_trace,
)
observed_trace = IOBuffer()
traced_events = LinkedSpecJulia.RuntimeSemanticObservationEvent[]
traced_observed = Parser.execute_with_trace(
    INPUT,
    LinkedSpecJulia.trace_config_enabled(LinkedSpecJulia.LinkedSpecTraceDebug);
    stdout_io = observed_trace,
    semantic_observation_sink = event -> push!(traced_events, event),
)

direct_failure = preserves_failure() do sink
    Parser.execute(INPUT; semantic_observation_sink = sink)
end
traced_failure = preserves_failure() do sink
    Parser.execute_with_trace(
        INPUT,
        LinkedSpecJulia.trace_config_disabled();
        semantic_observation_sink = sink,
    )
end

exit_host = Module(:JuliaSemanticObservationExitHost)
Base.include(exit_host, ARGS[2])
exit_parser = getfield(exit_host, :LinkedSpecGeneratedParser)
exit_events = LinkedSpecJulia.RuntimeSemanticObservationEvent[]
exit_failure = try
    exit_parser.execute(
        "x";
        semantic_observation_sink = event -> push!(exit_events, event),
    )
    nothing
catch error
    error
end

print(JSON3.write(Dict{String,Any}(
    "contract" => Parser.LINKEDSPEC_GENERATED_SOURCE_CONTRACT,
    "format" => Parser.LINKEDSPEC_GENERATED_SOURCE_FORMAT,
    "baseline" => baseline,
    "observed" => observed,
    "traced_baseline" => traced_baseline,
    "traced_observed" => traced_observed,
    "events" => [LinkedSpecJulia.to_json(event) for event in events],
    "traced_events" => [LinkedSpecJulia.to_json(event) for event in traced_events],
    "diagnostics_equal" => [LinkedSpecJulia.to_json(event) for event in observed_diagnostics] ==
        [LinkedSpecJulia.to_json(event) for event in baseline_diagnostics],
    "trace_equal" => String(take!(observed_trace)) == String(take!(baseline_trace)),
    "direct_failure" => direct_failure,
    "traced_failure" => traced_failure,
    "exit_status" => exit_failure isa LinkedSpecJulia.RuntimeExitNow ? exit_failure.status : nothing,
    "exit_events" => [LinkedSpecJulia.to_json(event) for event in exit_events],
)))
""",
            )

            passed, output = _julia_runtime_route_host_process(
                scratch,
                runner_path,
                generated_path,
                exit_path,
                private_depot,
            )
            @test passed
            payload = passed ? JSON3.read(output, Dict{String,Any}) : Dict{String,Any}()
            @test payload["contract"] == GENERATED_SOURCE_CONTRACT
            @test payload["format"] == GENERATED_SOURCE_FORMAT
            @test payload["observed"] == payload["baseline"] == Any["A", "B"]
            @test payload["traced_observed"] == payload["traced_baseline"] == Any["A", "B"]
            @test payload["diagnostics_equal"] === true
            @test payload["trace_equal"] === true
            @test payload["direct_failure"] === true
            @test payload["traced_failure"] === true
            @test payload["exit_status"] == 7

            direct_events = RuntimeSemanticObservationEvent[
                _julia_runtime_route_event_from_json(raw) for raw in payload["events"]
            ]
            traced_events = RuntimeSemanticObservationEvent[
                _julia_runtime_route_event_from_json(raw) for raw in payload["traced_events"]
            ]
            @test direct_events == expected
            @test traced_events == expected
            _julia_runtime_route_check_digest(base, direct_events)
            _julia_runtime_route_check_digest(base, traced_events)

            exit_events = RuntimeSemanticObservationEvent[
                _julia_runtime_route_event_from_json(raw) for raw in payload["exit_events"]
            ]
            @test length(exit_events) == 1
            @test only(exit_events).event_kind == RuntimeSemanticRegexSlotSelected
        end
    end
end
