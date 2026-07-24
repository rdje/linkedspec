# FUTURE-PARITY-BACKLOG.10.6.6.1 — typed invocation-local native capture.

const JULIA_RUNTIME_OBSERVATION_INPUT = "ab\n"
const JULIA_RUNTIME_OBSERVATION_INPUT_IDENTITY =
    "input:sha256:a63d8014dba891345b30174df2b2a57efbb65b4f9f09b98f245d1b3192277ece"

struct JuliaRuntimeObservationCallerFailure <: Exception
    id::String
end

function _julia_runtime_observation_compile(source::AbstractString)
    spec = parse_spec(source)
    validate_spec(spec)
    return compile_spec(spec)
end

function _julia_runtime_observation_expected_events()
    return RuntimeSemanticObservationEvent[
        RuntimeSemanticObservationEvent(
            event_kind = RuntimeSemanticRegexSlotSelected,
            rule_label = "Top",
            target_rule = "Top",
            regex_index = 0,
            position = 1,
        ),
        RuntimeSemanticObservationEvent(
            event_kind = RuntimeSemanticRegexSlotSelected,
            rule_label = "Top",
            target_rule = "Top",
            regex_index = 1,
            position = 2,
        ),
        RuntimeSemanticObservationEvent(
            event_kind = RuntimeSemanticRuleResult,
            rule_label = "Top",
            position = 2,
            input_identity = JULIA_RUNTIME_OBSERVATION_INPUT_IDENTITY,
            status = "succeeded",
        ),
    ]
end

function _julia_runtime_observation_capture(call)
    events = RuntimeSemanticObservationEvent[]
    result = call(event -> push!(events, event))
    return result, events
end

@testset "Julia typed runtime semantic observation capture" begin
    source = read(
        joinpath(
            REPO_ROOT,
            "capability_conformance",
            "semantic_introspection",
            "runtime.spec",
        ),
        String,
    )
    @test read(
        joinpath(
            REPO_ROOT,
            "capability_conformance",
            "semantic_introspection",
            "runtime.input",
        ),
        String,
    ) == JULIA_RUNTIME_OBSERVATION_INPUT
    compiled = _julia_runtime_observation_compile(source)
    engine = LinkedSpecRuntimeEngine(compiled)
    expected = _julia_runtime_observation_expected_events()

    @testset "public immutable event vocabulary and exact fields" begin
        result, events = _julia_runtime_observation_capture() do sink
            runtime_parse(
                engine,
                JULIA_RUNTIME_OBSERVATION_INPUT;
                semantic_observation_sink = sink,
            )
        end
        @test result.value == Any["A", "B"]
        @test result.cursor_char_offset == 2
        @test events == expected
        @test Base.hash(events) == Base.hash(expected)
        @test [to_json(event) for event in events] == Any[
            Dict{String,Any}(
                "contract_id" => RUNTIME_SEMANTIC_OBSERVATION_CONTRACT,
                "event_kind" => "regex_slot_selected",
                "rule_label" => "Top",
                "target_rule" => "Top",
                "regex_index" => 0,
                "position" => 1,
                "input_identity" => nothing,
                "status" => nothing,
            ),
            Dict{String,Any}(
                "contract_id" => RUNTIME_SEMANTIC_OBSERVATION_CONTRACT,
                "event_kind" => "regex_slot_selected",
                "rule_label" => "Top",
                "target_rule" => "Top",
                "regex_index" => 1,
                "position" => 2,
                "input_identity" => nothing,
                "status" => nothing,
            ),
            Dict{String,Any}(
                "contract_id" => RUNTIME_SEMANTIC_OBSERVATION_CONTRACT,
                "event_kind" => "rule_result",
                "rule_label" => "Top",
                "target_rule" => nothing,
                "regex_index" => nothing,
                "position" => 2,
                "input_identity" => JULIA_RUNTIME_OBSERVATION_INPUT_IDENTITY,
                "status" => "succeeded",
            ),
        ]
        @test runtime_semantic_observation_event_kind_name(
            RuntimeSemanticRegexSlotSelected,
        ) == "regex_slot_selected"
        @test runtime_semantic_observation_event_kind_name(
            RuntimeSemanticRuleResult,
        ) == "rule_result"
        @test fieldnames(RuntimeSemanticObservationEvent) == (
            :contract_id,
            :event_kind,
            :rule_label,
            :target_rule,
            :regex_index,
            :position,
            :input_identity,
            :status,
        )
        @test !(:value in fieldnames(RuntimeSemanticObservationEvent))
        @test !ismutabletype(RuntimeSemanticObservationEvent)
    end

    @testset "direct loaded and normalized reconstructed engines agree" begin
        mktempdir() do scratch
            path = joinpath(scratch, "runtime.spec")
            write(path, source)
            loaded = load_and_compile_spec(
                path_spec_request("runtime.spec"),
                SpecLoadOptions(scratch),
            )
            reconstructed_spec = from_json(
                SpecFile,
                JSON3.read(JSON3.write(to_json(parse_spec(source)))),
            )
            validate_spec(reconstructed_spec)
            reconstructed = compile_spec(reconstructed_spec)

            routes = Dict(
                "direct" => engine,
                "loaded" => create_engine(loaded),
                "reconstructed" => LinkedSpecRuntimeEngine(reconstructed),
            )
            for (name, route_engine) in routes
                baseline = runtime_parse(route_engine, JULIA_RUNTIME_OBSERVATION_INPUT)
                observed, events = _julia_runtime_observation_capture() do sink
                    runtime_parse(
                        route_engine,
                        JULIA_RUNTIME_OBSERVATION_INPUT;
                        semantic_observation_sink = sink,
                    )
                end
                @test to_json(observed) == to_json(baseline)
                @test events == expected
                @test name in ("direct", "loaded", "reconstructed")
            end
        end
    end

    @testset "all native and validated generated-plan entries reuse capture" begin
        identity = "semantic-introspection/runtime.spec"
        plan = build_generated_rule_plan(compiled)
        routes = Dict{String,Function}(
            "parse" => sink -> runtime_parse(
                engine,
                JULIA_RUNTIME_OBSERVATION_INPUT;
                semantic_observation_sink = sink,
            ).value,
            "execute" => sink -> runtime_execute(
                engine,
                JULIA_RUNTIME_OBSERVATION_INPUT;
                semantic_observation_sink = sink,
            ).value,
            "parse_with_trace" => sink -> runtime_parse_with_trace(
                engine,
                JULIA_RUNTIME_OBSERVATION_INPUT,
                trace_config_disabled();
                semantic_observation_sink = sink,
            ).value,
            "execute_with_trace" => sink -> runtime_execute_with_trace(
                engine,
                JULIA_RUNTIME_OBSERVATION_INPUT,
                trace_config_disabled();
                semantic_observation_sink = sink,
            ).value,
            "generated_plan" => sink -> execute_generated_parser_v2(
                compiled,
                plan,
                JULIA_RUNTIME_OBSERVATION_INPUT,
                identity;
                semantic_observation_sink = sink,
            ),
            "generated_plan_trace" => sink -> execute_generated_parser_with_trace_v2(
                compiled,
                plan,
                JULIA_RUNTIME_OBSERVATION_INPUT,
                trace_config_disabled(),
                identity;
                semantic_observation_sink = sink,
            ),
        )
        for (name, route) in routes
            value, events = _julia_runtime_observation_capture(route)
            @test value == Any["A", "B"]
            @test events == expected
            @test haskey(routes, name)
        end
    end

    @testset "trace diagnostics and results remain independent" begin
        diagnostic_compiled = _julia_runtime_observation_compile(
            "Top::\n /x/\n E { say(\"diagnostic-only\"); return(\"ok\") }\n",
        )
        diagnostic_engine = LinkedSpecRuntimeEngine(diagnostic_compiled)
        baseline_output = IOBuffer()
        observed_output = IOBuffer()
        baseline_trace = LinkedSpecTraceEmitter(
            trace_config_enabled(LinkedSpecTraceDebug);
            stdout_io = baseline_output,
        )
        observed_trace = LinkedSpecTraceEmitter(
            trace_config_enabled(LinkedSpecTraceDebug);
            stdout_io = observed_output,
        )
        baseline_diagnostics = RuntimeDiagnosticOutputEvent[]
        observed_diagnostics = RuntimeDiagnosticOutputEvent[]
        observed_events = RuntimeSemanticObservationEvent[]
        baseline = runtime_parse(
            diagnostic_engine,
            "x";
            trace = baseline_trace,
            diagnostic_output_sink = event -> push!(baseline_diagnostics, event),
        )
        observed = runtime_parse(
            diagnostic_engine,
            "x";
            trace = observed_trace,
            diagnostic_output_sink = event -> push!(observed_diagnostics, event),
            semantic_observation_sink = event -> push!(observed_events, event),
        )
        @test to_json(observed) == to_json(baseline)
        @test String(take!(observed_output)) == String(take!(baseline_output))
        @test [to_json(event) for event in trace_events(observed_trace)] ==
            [to_json(event) for event in trace_events(baseline_trace)]
        @test [to_json(event) for event in observed_diagnostics] ==
            [to_json(event) for event in baseline_diagnostics]
        @test [event.event_kind for event in observed_events] == [
            RuntimeSemanticRegexSlotSelected,
            RuntimeSemanticRuleResult,
        ]
        @test only(observed_diagnostics).message == "diagnostic-only\n"
    end

    @testset "Unicode scalar positions and UTF-8 input identity are exact" begin
        unicode_input = "é🙂"
        unicode_engine = LinkedSpecRuntimeEngine(
            _julia_runtime_observation_compile(
                "Töp::\n /🙂/\n E { return(\"ok\") }\n",
            ),
        )
        result, events = _julia_runtime_observation_capture() do sink
            runtime_parse(
                unicode_engine,
                unicode_input;
                semantic_observation_sink = sink,
            )
        end
        expected_identity =
            "input:sha256:$(bytes2hex(LinkedSpecJulia.SHA.sha256(codeunits(unicode_input))))"
        @test result.cursor_codeunit == ncodeunits(unicode_input)
        @test result.cursor_char_offset == 2
        @test [event.position for event in events] == [2, 2]
        @test all(event -> event.rule_label == "Töp", events)
        @test events[1].target_rule == "Töp"
        @test events[2].input_identity == expected_identity
    end

    @testset "absent sink performs zero event allocation or input hashing" begin
        context = LinkedSpecJulia._RuntimeExecutionContext(
            JULIA_RUNTIME_OBSERVATION_INPUT,
            "Top",
            nothing,
        )
        @test context.semantic_observation_sink === nothing
        @test context.semantic_observation_failure === nothing
        LinkedSpecJulia._emit_runtime_semantic_regex_slot_selected!(
            context,
            "Top",
            "Top",
            0,
            1,
        )
        LinkedSpecJulia._emit_runtime_semantic_rule_result!(context, "Top", 2)
        slot_allocations = @allocated LinkedSpecJulia._emit_runtime_semantic_regex_slot_selected!(
            context,
            "Top",
            "Top",
            0,
            1,
        )
        result_allocations = @allocated LinkedSpecJulia._emit_runtime_semantic_rule_result!(
            context,
            "Top",
            2,
        )
        @test slot_allocations == 0
        @test result_allocations == 0
    end

    @testset "caller failure identity survives native and generated catches" begin
        plan = build_generated_rule_plan(compiled)
        routes = Function[
            sink -> runtime_parse(
                engine,
                JULIA_RUNTIME_OBSERVATION_INPUT;
                semantic_observation_sink = sink,
            ),
            sink -> runtime_parse_with_trace(
                engine,
                JULIA_RUNTIME_OBSERVATION_INPUT,
                trace_config_disabled();
                semantic_observation_sink = sink,
            ),
            sink -> execute_generated_parser_v2(
                compiled,
                plan,
                JULIA_RUNTIME_OBSERVATION_INPUT,
                "semantic-introspection/runtime.spec";
                semantic_observation_sink = sink,
            ),
            sink -> execute_generated_parser_with_trace_v2(
                compiled,
                plan,
                JULIA_RUNTIME_OBSERVATION_INPUT,
                trace_config_disabled(),
                "semantic-introspection/runtime.spec";
                semantic_observation_sink = sink,
            ),
        ]
        for (index, route) in enumerate(routes)
            failure = JuliaRuntimeObservationCallerFailure("failure-$index")
            captured = try
                route(_ -> throw(failure))
                nothing
            catch error
                error
            end
            @test captured === failure
        end

        diagnostic_wrapper = LinkedSpecJulia._GeneratedDiagnosticOutputSinkFailure(
            JuliaRuntimeObservationCallerFailure("diagnostic-wrapper-collision"),
        )
        captured_wrapper = try
            execute_generated_parser_v2(
                compiled,
                plan,
                JULIA_RUNTIME_OBSERVATION_INPUT,
                "semantic-introspection/runtime.spec";
                semantic_observation_sink = _ -> throw(diagnostic_wrapper),
            )
            nothing
        catch error
            error
        end
        @test captured_wrapper === diagnostic_wrapper
    end

    @testset "thrown execution omits the successful final event" begin
        exit_engine = LinkedSpecRuntimeEngine(
            _julia_runtime_observation_compile(
                "Top::\n /x/\n E { exit_now(7) }\n",
            ),
        )
        events = RuntimeSemanticObservationEvent[]
        captured = try
            runtime_parse(
                exit_engine,
                "x";
                semantic_observation_sink = event -> push!(events, event),
            )
            nothing
        catch error
            error
        end
        @test captured isa RuntimeExitNow
        @test captured.status == 7
        @test length(events) == 1
        @test only(events).event_kind == RuntimeSemanticRegexSlotSelected
        @test all(event -> event.event_kind != RuntimeSemanticRuleResult, events)

        selection_events = RuntimeSemanticObservationEvent[]
        selection_failure = try
            runtime_parse(
                engine,
                JULIA_RUNTIME_OBSERVATION_INPUT;
                top_rule = "Missing",
                semantic_observation_sink = event -> push!(selection_events, event),
            )
            nothing
        catch error
            error
        end
        @test selection_failure isa RuntimeInterpreterException
        @test isempty(selection_events)
    end
end
