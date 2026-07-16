const DIAGNOSTIC_OUTPUT_CONTRACT = JSON3.read(
    read(joinpath(REPO_ROOT, "capability_conformance", "diagnostic_output_contract.json"), String),
    Dict{String,Any},
)

struct DiagnosticOutputCallerSinkFailure <: Exception
    id::String
end

function _diagnostic_output_engine(source::AbstractString)
    spec = parse_spec_with_staged_user_function_definitions(source)
    return LinkedSpecRuntimeEngine(compile_spec(spec))
end

function _diagnostic_output_program_source(id::AbstractString)
    row = only(filter(
        program -> program["id"] == id,
        DIAGNOSTIC_OUTPUT_CONTRACT["programs"],
    ))
    return row["spec_source"]
end

function _diagnostic_output_scenario(id::AbstractString)
    return only(filter(
        scenario -> scenario["id"] == id,
        DIAGNOSTIC_OUTPUT_CONTRACT["scenarios"],
    ))
end

function _diagnostic_output_event_json(events)
    return Any[to_json(event) for event in events]
end

function _diagnostic_output_render_expression(value)
    kind = value["kind"]
    if kind == "string"
        return JSON3.write(value["value"])
    elseif kind == "boolean"
        return value["value"] ? "true" : "false"
    elseif kind == "number"
        return JSON3.write(value["value"])
    elseif kind == "null"
        return "undef"
    elseif kind == "array"
        return "[1]"
    elseif kind == "harray"
        return "{ \"k\" : 1 }"
    elseif kind == "codeblock"
        return "{ return(undef) }"
    end
    error("unsupported diagnostic scalar render kind $kind")
end

@testset "Neutral diagnostic output event contract" begin
    contract = DIAGNOSTIC_OUTPUT_CONTRACT

    @testset "ordered Unicode, quietness, and native aliases" begin
        @test contract["contract_id"] == "linkedspec-diagnostic-output-v1"
        @test contract["event_schema"]["native_type"] == "RuntimeDiagnosticOutputEvent"

        source = _diagnostic_output_program_source("ordered_unicode")
        scenario = _diagnostic_output_scenario("ordered_unicode_with_sink")
        expected = scenario["expected"]
        outcome = expected["outcome"]
        engine = _diagnostic_output_engine(source)
        events = RuntimeDiagnosticOutputEvent[]

        result = runtime_parse(
            engine,
            "x";
            diagnostic_output_sink = event -> push!(events, event),
        )
        @test result.output == outcome["output"]
        @test result.value == outcome["value"]
        @test _diagnostic_output_event_json(events) == expected["events"]

        quiet = _diagnostic_output_scenario("ordered_unicode_quiet")["expected"]["outcome"]
        @test runtime_parse(engine, "x").output == quiet["output"]
        @test runtime_execute(engine, "x").value == quiet["value"]

        aliases = (
            sink -> runtime_execute(engine, "x"; diagnostic_output_sink = sink),
            sink -> runtime_parse_with_trace(
                engine,
                "x",
                trace_config_disabled();
                diagnostic_output_sink = sink,
                stdout_io = IOBuffer(),
            ),
            sink -> runtime_execute_with_trace(
                engine,
                "x",
                trace_config_disabled();
                diagnostic_output_sink = sink,
                stdout_io = IOBuffer(),
            ),
        )
        for invoke in aliases
            alias_events = RuntimeDiagnosticOutputEvent[]
            @test invoke(event -> push!(alias_events, event)).value == outcome["value"]
            @test _diagnostic_output_event_json(alias_events) == expected["events"]
        end
    end

    @testset "all scalar render rows" begin
        for row in contract["scalar_render_cases"]
            expression = _diagnostic_output_render_expression(row["value"])
            events = RuntimeDiagnosticOutputEvent[]
            result = runtime_parse(
                _diagnostic_output_engine(
                    "Top::\n /x/\n E { print($expression); return(\"ok\") }\n",
                ),
                "x";
                diagnostic_output_sink = event -> push!(events, event),
            )

            @test result.value == "ok"
            @test length(events) == 1
            @test only(events).message == row["expected"]
        end
    end

    @testset "invalid arity precedes argument evaluation" begin
        for row in contract["invalid_arity_cases"]
            helper_name = row["helper_name"]
            actual_arity = row["actual_arity"]
            arguments = join(
                [index == 1 ? "exit_now(77)" : JSON3.write("arg-$(index - 1)")
                 for index in 1:actual_arity],
                ", ",
            )
            engine = _diagnostic_output_engine(
                "Top::\n /x/\n E { $helper_name($arguments); return(\"late\") }\n",
            )

            captured = try
                runtime_parse(engine, "x")
                nothing
            catch error
                error
            end
            @test captured isa RuntimeInterpreterException
            @test captured.diagnostic.stage == row["expected_code"]
            @test occursin(row["expected_arity"], captured.message)
        end
    end

    @testset "wrong-kind targets and immediate exit" begin
        wrong = _diagnostic_output_scenario("wrong_kind_no_events")["expected"]
        wrong_events = RuntimeDiagnosticOutputEvent[]
        wrong_result = runtime_parse(
            _diagnostic_output_engine(_diagnostic_output_program_source("wrong_kind")),
            "x";
            diagnostic_output_sink = event -> push!(wrong_events, event),
        )
        @test wrong_result.output == wrong["outcome"]["output"]
        @test _diagnostic_output_event_json(wrong_events) == wrong["events"]

        exit_scenario = _diagnostic_output_scenario("event_before_immediate_exit")
        exit_expected = exit_scenario["expected"]
        exit_events = RuntimeDiagnosticOutputEvent[]
        captured = try
            runtime_parse(
                _diagnostic_output_engine(_diagnostic_output_program_source("immediate_exit")),
                "x";
                diagnostic_output_sink = event -> push!(exit_events, event),
            )
            nothing
        catch error
            error
        end
        @test captured isa RuntimeExitNow
        @test captured.status == exit_expected["outcome"]["status"]
        @test _diagnostic_output_event_json(exit_events) == exit_expected["events"]
    end

    @testset "caller sink failures retain exact identity" begin
        for scenario_id in ("print_each_sink_failure", "synchronous_sink_failure")
            scenario = _diagnostic_output_scenario(scenario_id)
            sink = scenario["sink"]
            expected = scenario["expected"]
            failure = scenario_id == "print_each_sink_failure" ?
                RuntimeInterpreterException(sink["error_id"]) :
                DiagnosticOutputCallerSinkFailure(sink["error_id"])
            events = RuntimeDiagnosticOutputEvent[]
            invocation = Ref(0)
            captured = try
                runtime_parse(
                    _diagnostic_output_engine(
                        _diagnostic_output_program_source(scenario["program_id"]),
                    ),
                    "x";
                    diagnostic_output_sink = event -> begin
                        invocation[] += 1
                        push!(events, event)
                        invocation[] == sink["invocation"] && throw(failure)
                    end,
                )
                nothing
            catch error
                error
            end
            @test captured === failure
            @test _diagnostic_output_event_json(events) == expected["events"]
        end
    end

    @testset "diagnostic events remain separate from native trace" begin
        marker = "diagnostic-only-pré🙂"
        trace_io = IOBuffer()
        trace = LinkedSpecTraceEmitter(
            trace_config_enabled(LinkedSpecTraceDebug);
            stdout_io = trace_io,
        )
        events = RuntimeDiagnosticOutputEvent[]
        engine = _diagnostic_output_engine(
            "Top::\n /x/\n E { say($(JSON3.write(marker))); return(\"ok\") }\n",
        )

        result = runtime_parse(
            engine,
            "x";
            trace = trace,
            diagnostic_output_sink = event -> push!(events, event),
        )
        trace_text = String(take!(trace_io))
        @test result.value == "ok"
        @test only(events).message == "$marker\n"
        @test occursin("julia_runtime:parse", trace_text)
        @test !occursin(marker, trace_text)
    end

    @testset "generated direct and traced roles preserve diagnostic outcomes" begin
        identity = "diagnostic-output/generated-julia.spec"
        source = _diagnostic_output_program_source("ordered_unicode")
        parsed = parse_spec_with_staged_user_function_definitions(source)
        compiled = compile_spec(parsed)
        plan = build_generated_rule_plan(compiled)
        expected = _diagnostic_output_scenario("ordered_unicode_with_sink")["expected"]
        events = RuntimeDiagnosticOutputEvent[]

        value = execute_generated_parser_v1(
            compiled,
            plan,
            "x",
            identity;
            diagnostic_output_sink = event -> push!(events, event),
        )
        @test value == expected["outcome"]["value"]
        @test _diagnostic_output_event_json(events) == expected["events"]

        traced_events = RuntimeDiagnosticOutputEvent[]
        traced = execute_generated_parser_with_trace_v1(
            compiled,
            plan,
            "x",
            trace_config_disabled(),
            identity;
            stdout_io = IOBuffer(),
            diagnostic_output_sink = event -> push!(traced_events, event),
        )
        @test traced == value
        @test _diagnostic_output_event_json(traced_events) == expected["events"]

        failure_source = _diagnostic_output_program_source("sink_failure")
        failure_compiled = compile_spec(
            parse_spec_with_staged_user_function_definitions(failure_source),
        )
        failure = DiagnosticOutputCallerSinkFailure("generated-caller-sink-failure")
        invocation = Ref(0)
        captured = try
            execute_generated_parser_v1(
                failure_compiled,
                build_generated_rule_plan(failure_compiled),
                "x",
                identity;
                diagnostic_output_sink = event -> begin
                    invocation[] += 1
                    invocation[] == 2 && throw(failure)
                end,
            )
            nothing
        catch error
            error
        end
        @test captured === failure

        exit_source = _diagnostic_output_program_source("immediate_exit")
        exit_compiled = compile_spec(
            parse_spec_with_staged_user_function_definitions(exit_source),
        )
        exit_events = RuntimeDiagnosticOutputEvent[]
        captured_exit = try
            execute_generated_parser_v1(
                exit_compiled,
                build_generated_rule_plan(exit_compiled),
                "x",
                identity;
                diagnostic_output_sink = event -> push!(exit_events, event),
            )
            nothing
        catch error
            error
        end
        @test captured_exit isa RuntimeExitNow
        @test captured_exit.status == 23
        @test _diagnostic_output_event_json(exit_events) ==
              _diagnostic_output_scenario("event_before_immediate_exit")["expected"]["events"]
    end
end
