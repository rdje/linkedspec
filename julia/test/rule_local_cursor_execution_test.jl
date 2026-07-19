const RULE_LOCAL_CURSOR_EXECUTION_CONTRACT = JSON3.read(
    read(
        joinpath(REPO_ROOT, "capability_conformance", "rule_local_cursor_contract.json"),
        String,
    ),
    Dict{String,Any},
)

const RULE_LOCAL_CURSOR_PARENT_CHILD_CASES = (
    (
        id = "and_to_or_blind",
        input = "prefix x",
        expected = Any["hit"],
        source = raw"""
Top::AND
 => Child
Child:
 /x/
 -> Child { return("hit") }
""",
    ),
    (
        id = "or_to_and_blind",
        input = "prefix x",
        expected = nothing,
        source = raw"""
Top::|
 => Child
Child:AND
 /x/
 -> Child { return("hit") }
""",
    ),
    (
        id = "and_to_or_action",
        input = "x junk x",
        expected = "hit",
        source = raw"""
Top::AND
 -> Child { return(call(Child)) }
Child:
 /x/
 -> Child { return("hit") }
""",
    ),
    (
        id = "or_to_and_action",
        input = "prefix x junk x",
        expected = nothing,
        source = raw"""
Top::|
 -> Child { return(call(Child)) }
Child:AND
 /x/
 -> Child { return("hit") }
""",
    ),
    (
        id = "and_to_or_call",
        input = "p junk x",
        expected = "hit",
        source = raw"""
Top::AND
 /p/
 -> Top { return(call(Child)) }
Child:
 /x/
 -> Child { return("hit") }
""",
    ),
    (
        id = "or_to_and_call",
        input = "prefix p junk x",
        expected = nothing,
        source = raw"""
Top::|
 /p/
 -> Top { return(call(Child)) }
Child:AND
 /x/
 -> Child { return("hit") }
""",
    ),
    (
        id = "and_to_or_recursion",
        input = "p junk xp junk z",
        expected = "done",
        source = raw"""
Top::AND
 /p/
 -> Top { return(call(Child)) }
Child:OR
 /x/ -> Child[0] { return(call(Top)) }
 /z/ -> Child[1] { return("done") }
""",
    ),
    (
        id = "or_to_and_recursion",
        input = "junk p junk x z",
        expected = nothing,
        source = raw"""
Top::|
 /p/ -> Top[0] { return(call(Child)) }
 /z/ -> Top[1] { return("done") }
Child:AND
 /x/ -> Child { return(call(Top)) }
""",
    ),
)

const RULE_LOCAL_CURSOR_STRUCTURAL_CASES = (
    (
        id = "ordered_landmarks",
        input = "junk h junk b",
        expected = Any["header", "body"],
        source = raw"""
Top::AND
 => Header
 => Body
Header:
 /h/
 -> Header { return("header") }
Body:
 /b/
 -> Body { return("body") }
""",
    ),
    (
        id = "anchored_choice",
        input = "prefix x",
        expected = nothing,
        source = raw"""
Top::|
 => X
 => Y
X:AND
 /x/
 -> X { return("x") }
Y:AND
 /y/
 -> Y { return("y") }
""",
    ),
)

function _normalized_cursor_execution_spec(source::AbstractString)
    parsed = parse_spec(source)
    return from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
end

@testset "Neutral rule-local cursor execution contract" begin
    parent_rows = RULE_LOCAL_CURSOR_EXECUTION_CONTRACT["parent_child_cases"]
    structural_rows = RULE_LOCAL_CURSOR_EXECUTION_CONTRACT["structural_replacements"]
    @test Set(case.id for case in RULE_LOCAL_CURSOR_PARENT_CHILD_CASES) ==
          Set(String(row["id"]) for row in parent_rows)
    @test Set(case.id for case in RULE_LOCAL_CURSOR_STRUCTURAL_CASES) ==
          Set(String(row["id"]) for row in structural_rows)

    @testset "live and normalized parent-child composition" begin
        for case in (RULE_LOCAL_CURSOR_PARENT_CHILD_CASES..., RULE_LOCAL_CURSOR_STRUCTURAL_CASES...)
            routes = (
                (name = "live", spec = parse_spec(case.source)),
                (name = "normalized", spec = _normalized_cursor_execution_spec(case.source)),
            )
            for route in routes
                actual = runtime_parse(
                    LinkedSpecRuntimeEngine(compile_spec(route.spec)),
                    case.input,
                ).value
                @test actual == case.expected
            end
        end
    end

    @testset "all 36 family spellings spend entered policy" begin
        family_rows = RULE_LOCAL_CURSOR_EXECUTION_CONTRACT["family_cases"]
        @test length(family_rows) == 36
        for row in family_rows
            header = String(row["header"])
            prefix = startswith(header, "Top::") ? "" : "Root::\n I { return(\"unused\") }\n\n"
            source = prefix * header * "\n /x/ -> Top { return(\"hit\") }\n"
            expected = row["cursor_policy"] == "seek" ? "hit" : nothing
            routes = (
                (name = "live", spec = parse_spec(source)),
                (name = "normalized", spec = _normalized_cursor_execution_spec(source)),
            )
            for route in routes
                try
                    actual = runtime_parse(
                        LinkedSpecRuntimeEngine(compile_spec(route.spec)),
                        "prefix x";
                        top_rule = "Top",
                    ).value
                    @test actual == expected
                catch error
                    error isa RuntimeInterpreterException || rethrow()
                    @test row["cursor_policy"] == "consume" &&
                          occursin("expected at least", error.message)
                end
            end
        end
    end

    @testset "loaded and traced execution derive each entered rule" begin
        case = only(filter(item -> item.id == "and_to_or_call", RULE_LOCAL_CURSOR_PARENT_CHILD_CASES))
        mktempdir() do scratch
            path = joinpath(scratch, "loaded.spec")
            write(path, case.source)
            loaded = load_and_compile_spec(path_spec_request(path), SpecLoadOptions(scratch))
            @test runtime_parse(create_engine(loaded), case.input).value == case.expected
        end

        trace = LinkedSpecTraceEmitter(
            trace_config_enabled(LinkedSpecTraceDebug);
            stdout_io = IOBuffer(),
        )
        result = runtime_parse(
            LinkedSpecRuntimeEngine(compile_spec(parse_spec(case.source))),
            case.input;
            trace = trace,
        )
        @test result.value == case.expected
        rule_entries = [
            event.details
            for event in trace_events(trace)
            if event.kind == LinkedSpecTraceEnter && event.topic == "julia_runtime:rule"
        ]
        @test any(
            details -> occursin("rule=Top ", details) &&
                occursin("family=and", details) &&
                occursin("cursor_policy=consume", details),
            rule_entries,
        )
        @test any(
            details -> occursin("rule=Child ", details) &&
                occursin("family=or_default", details) &&
                occursin("cursor_policy=seek", details),
            rule_entries,
        )
    end

    @testset "generated-v2 derives intrinsic family policy" begin
        and_compiled = compile_spec(parse_spec(raw"""
Top::AND
 /x/ -> Top { return("hit") }
"""))
        @test runtime_parse(LinkedSpecRuntimeEngine(and_compiled), "prefix x").value === nothing
        @test execute_generated_parser_v2(
            and_compiled,
            build_generated_rule_plan(and_compiled),
            "prefix x",
            "cursor-v2-and.spec",
        ) === nothing

        pipe_compiled = compile_spec(parse_spec(raw"""
Top::|
 => X
 => Y
 E { return(retv) }
X: /x/ E { return("x") }
Y: /y/ E { return("y") }
"""))
        @test runtime_parse(LinkedSpecRuntimeEngine(pipe_compiled), "xy").value == "x"
        @test generated_rule_family_name(classify_generated_rule_family(
            compiled_rule(pipe_compiled, "Top"),
        )) == "or_bcode"
        @test execute_generated_parser_v2(
            pipe_compiled,
            build_generated_rule_plan(pipe_compiled),
            "xy",
            "cursor-v2-pipe.spec",
        ) == "x"
    end
end
