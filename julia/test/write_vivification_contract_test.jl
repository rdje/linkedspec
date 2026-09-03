const JULIA_WRITE_VIVIFICATION_CONTRACT = JSON3.read(
    read(
        joinpath(
            REPO_ROOT,
            "capability_conformance",
            "write_vivification_contract.json",
        ),
        String,
    ),
    Dict{String,Any},
)

function _write_vivification_engine(action::AbstractString)
    source = """
Top::
 -> Done { $action }

Done::
 /[a-z]+/
"""
    return LinkedSpecRuntimeEngine(
        compile_spec(parse_spec_with_staged_user_function_definitions(source)),
    )
end

function _write_vivification_source_engine(source::AbstractString)
    return LinkedSpecRuntimeEngine(
        compile_spec(parse_spec_with_staged_user_function_definitions(source)),
    )
end

function _write_vivification_objects(value)
    return [
        Dict{String,Any}(String(key) => item_value for (key, item_value) in pairs(item))
        for item in value
    ]
end

function _write_vivification_literal(value)
    if value === nothing
        return "undef"
    elseif value isa Bool || value isa Number
        return string(value)
    elseif value isa AbstractString
        return String(JSON3.write(String(value)))
    elseif value isa AbstractVector
        return "[" * join((_write_vivification_literal(item) for item in value), ", ") * "]"
    elseif value isa AbstractDict
        entries = [
            String(JSON3.write(String(key))) * " : " * _write_vivification_literal(item)
            for (key, item) in pairs(value)
        ]
        return "{ " * join(entries, ", ") * " }"
    end
    throw(ArgumentError("unsupported write-vivification fixture literal $(repr(value))"))
end

function _write_vivification_instrumented(marker::AbstractString, expression::AbstractString)
    return "{ say($(String(JSON3.write(String(marker))))); $expression }"
end

function _write_vivification_ordinary_action(fixture; include_result::Bool)
    statements = String[]
    initial = fixture["initial_binding"]
    if initial["present"] == true
        push!(statements, "document = $(_write_vivification_literal(initial["value"]))")
    end

    segment_expressions = String[]
    for (index, segment) in enumerate(_write_vivification_objects(fixture["segments"]))
        source = String(segment["source"])
        if occursin(r"^[A-Za-z_][A-Za-z0-9_]*$", source) &&
                !(source in ("true", "false", "null", "undef"))
            value = segment["kind"] == "codeblock" ?
                    "{|value| return(value) }" :
                    _write_vivification_literal(segment["value"])
            push!(statements, "$source = $value")
        end
        push!(
            segment_expressions,
            _write_vivification_instrumented("segment:$(index - 1)", source),
        )
    end

    rhs = fixture["rhs"]
    rhs_source = String(rhs["source"])
    if occursin(r"^[A-Za-z_][A-Za-z0-9_]*$", rhs_source)
        push!(statements, "$rhs_source = $(_write_vivification_literal(rhs["value"]))")
    end
    lvalue = "document" * join(("[$expression]" for expression in segment_expressions))
    assignment = "$lvalue = $(_write_vivification_instrumented("rhs", rhs_source))"
    if include_result
        push!(statements, "result = ($assignment)")
        push!(statements, "return(array(document, result))")
    else
        push!(statements, assignment)
    end
    return join(statements, "; ")
end

_write_vivification_effects(events) = String[strip(event.message) for event in events]

function _write_vivification_nested_write(action::AbstractString)
    block = parse_action_block(action)
    for statement in block.statements
        expression = statement.expr
        if expression isa ActionAssignNestedAccessExpr
            return expression
        elseif expression isa ActionAssignScalarExpr &&
                expression.value isa ActionAssignNestedAccessExpr
            return expression.value
        end
    end
    throw(ArgumentError("action did not contain a top-level nested write"))
end

function _write_vivification_structural_message(expected)
    segment = expected["segment_index"]
    code = expected["code"]
    if code == "nested_write_segment_invalid"
        return "nested write segment $segment for binding 'document' must evaluate " *
               "to a string or nonnegative integer; got $(expected["actual_kind"]) " *
               "($(expected["reason"]))"
    elseif code == "nested_write_kind_conflict"
        return "nested write segment $segment for binding 'document' requires " *
               "$(expected["expected_kind"]); found $(expected["actual_kind"])"
    end
    return "nested write segment $segment for binding 'document' cannot create " *
           "array index $(expected["index"]) at length $(expected["length"])"
end

function _write_vivification_corrupted_compiled()
    compiled = compile_spec(parse_spec(raw"""
Top::
 -> Done { document["x"] = "y"; return(document) }

Done::
 /[a-z]+/
"""))
    top = compiled.rules_by_label["Top"]
    edge = only(top.action_edges)
    payload = edge.action_payload
    statement = first(payload.action_ast.statements)
    write = statement.expr
    corrupted_block = ActionBlock(
        source = payload.action_ast.source,
        source_span = payload.action_ast.source_span,
        statements = ActionStatement[
            ActionStatement(
                source = statement.source,
                source_span = statement.source_span,
                expr = ActionAssignNestedAccessExpr(
                    source = write.source,
                    source_span = write.source_span,
                    base = write.base,
                    segments = ActionWritePathSegment[],
                    value = write.value,
                ),
                drops_value = statement.drops_value,
            ),
            payload.action_ast.statements[2:end]...,
        ],
    )
    corrupted_payload = CompiledActionPayload(
        role = payload.role,
        line = payload.line,
        source = payload.source,
        code = payload.code,
        lifecycle = payload.lifecycle,
        action_ast = corrupted_block,
        contracts = payload.contracts,
    )
    corrupted_edge = CompiledActionEdge(
        line = edge.line,
        source = edge.source,
        targets = edge.targets,
        regex_index = edge.regex_index,
        child_regex_index = edge.child_regex_index,
        has_parent_regex = edge.has_parent_regex,
        selector_kind = edge.selector_kind,
        authored_selector = edge.authored_selector,
        target_slot_id = edge.target_slot_id,
        source_id = edge.source_id,
        code = edge.code,
        fluent_chain = edge.fluent_chain,
        action_payload = corrupted_payload,
    )
    corrupted_top = LinkedSpecJulia.compiled_rule_with(
        top;
        action_edges = [corrupted_edge],
    )
    return CompiledSpec(
        definition_order = compiled.definition_order,
        compiled_rule_order = compiled.compiled_rule_order,
        rules_by_label = Dict(
            label => label == "Top" ? corrupted_top : rule
            for (label, rule) in pairs(compiled.rules_by_label)
        ),
        redefined_rule_labels = compiled.redefined_rule_labels,
        function_registry = compiled.function_registry,
        dependency_regex_state = compiled.dependency_regex_state,
    )
end

@testset "Julia write-vivification contract" begin
    @test JULIA_WRITE_VIVIFICATION_CONTRACT["contract_id"] ==
          "linkedspec-write-vivification-v1"

    @testset "projects the frozen AST and syntax inventory" begin
        valid = JULIA_WRITE_VIVIFICATION_CONTRACT["valid_syntax_cases"]
        invalid = JULIA_WRITE_VIVIFICATION_CONTRACT["invalid_syntax_cases"]
        excluded = JULIA_WRITE_VIVIFICATION_CONTRACT["excluded_syntax_cases"]
        @test length(valid) == 5
        @test length(invalid) == 7
        @test length(excluded) == 4

        expression_kind(kind) = get(
            Dict(
                "identifier" => "variable",
                "integer_literal" => "number",
                "string_literal" => "string",
            ),
            String(kind),
            String(kind),
        )
        for fixture in _write_vivification_objects(valid)
            expected = fixture["expected_ast"]
            expression = parse_action_expression(String(fixture["source"]))
            @test expression isa ActionAssignNestedAccessExpr
            actual = to_json(expression)
            @test actual["kind"] == "assign_nested_access"
            @test actual["source"] == fixture["source"]
            @test actual["source_span"] == expected["source_span"]
            @test actual["base"] == expected["base"]
            @test length(actual["segments"]) == length(expected["segments"])
            for index in eachindex(expected["segments"])
                actual_segment = actual["segments"][index]
                expected_segment = expected["segments"][index]
                actual_expression = actual_segment["expression"]
                expected_expression = expected_segment["expression"]
                @test actual_segment["kind"] == "path_segment"
                @test actual_segment["source"] == expected_segment["source"]
                @test actual_segment["source_span"] == expected_segment["source_span"]
                @test actual_expression["kind"] ==
                      expression_kind(expected_expression["kind"])
                @test actual_expression["source"] == expected_expression["source"]
                @test actual_expression["source_span"] ==
                      expected_expression["source_span"]
            end
            @test actual["value"]["kind"] ==
                  expression_kind(expected["value"]["kind"])
            @test actual["value"]["source"] == expected["value"]["source"]
            @test actual["value"]["source_span"] == expected["value"]["source_span"]
        end

        for fixture in _write_vivification_objects(invalid)
            expected = fixture["diagnostic"]
            failure = try
                parse_action_expression(String(fixture["source"]))
                nothing
            catch error
                error
            end
            @test failure isa ActionParseException
            actual = to_json(failure)
            @test actual["code"] == expected["code"]
            @test actual["stage"] == expected["stage"]
            @test actual["source_span"]["start"] == expected["source_span"]["start"]
            @test actual["source_span"]["end"] == expected["source_span"]["end"]
            @test actual["source_span"]["unit"] == expected["source_span"]["unit"]
            @test actual["source_span"]["provenance"] ==
                  expected["source_span"]["provenance"]
            @test actual["message"] == expected["message"]
        end

        for fixture in _write_vivification_objects(excluded)
            expression = parse_action_expression(String(fixture["source"]))
            classification = fixture["classification"]
            if classification == "not_nested_write"
                @test expression isa ActionAssignScalarExpr
            elseif classification == "read_only"
                @test expression isa ActionNestedAccessExpr
            elseif classification == "unsupported_helper"
                @test expression isa ActionCallExpr
                @test expression.name == "vivify"
            else
                @test !(expression isa ActionAssignNestedAccessExpr)
            end
        end

        astral = parse_action_expression(
            "document[\"🙂\"][position] = \"值\"",
        )
        @test to_json(astral.source_span) == Dict("start" => 0, "end" => 29)
        @test to_json(astral.segments[1].source_span) ==
              Dict("start" => 9, "end" => 12)
        @test to_json(astral.segments[2].source_span) ==
              Dict("start" => 14, "end" => 22)
        @test to_json(astral.value.source_span) == Dict("start" => 26, "end" => 29)
    end

    @testset "executes all frozen successes in exact evaluation order" begin
        fixtures = _write_vivification_objects(
            JULIA_WRITE_VIVIFICATION_CONTRACT["success_cases"],
        )
        @test length(fixtures) == 11
        for fixture in fixtures
            action = if fixture["id"] == "rhs_same_binding_side_effect_composes"
                "document = { \"audit\" : [] }; " *
                "result = (document[$(_write_vivification_instrumented("segment:0", "\"value\""))] = " *
                "{ say(\"rhs\"); document = { \"audit\" : [\"rhs\"] }; \"done\" }); " *
                "return(array(document, result))"
            elseif fixture["id"] == "segment_same_binding_side_effect_composes"
                "result = (document[{ say(\"segment:0\"); " *
                "document = { \"seed\" : 1 }; \"value\" }] = " *
                "$(_write_vivification_instrumented("rhs", "\"done\""))); " *
                "return(array(document, result))"
            else
                _write_vivification_ordinary_action(fixture; include_result = true)
            end
            events = RuntimeDiagnosticOutputEvent[]
            result = runtime_parse(
                _write_vivification_engine(action),
                "xhello";
                diagnostic_output_sink = event -> push!(events, event),
            )
            @test result.value == Any[
                fixture["expected_binding"],
                fixture["expected_result"],
            ]
            @test _write_vivification_effects(events) == fixture["expected_effects"]
        end
    end

    @testset "returns exact typed structural failures after RHS evaluation" begin
        fixtures = _write_vivification_objects(
            JULIA_WRITE_VIVIFICATION_CONTRACT["failure_cases"],
        )
        @test length(fixtures) == 16
        for fixture in fixtures
            action = if fixture["id"] == "rhs_side_effect_survives_outer_gap"
                "document = []; " *
                "document[$(_write_vivification_instrumented("segment:0", "2"))] = " *
                "{ say(\"rhs\"); document = [\"rhs\"]; \"outer\" }"
            else
                _write_vivification_ordinary_action(fixture; include_result = false)
            end
            events = RuntimeDiagnosticOutputEvent[]
            failure = try
                runtime_parse(
                    _write_vivification_engine(action),
                    "xhello";
                    diagnostic_output_sink = event -> push!(events, event),
                )
                nothing
            catch error
                error
            end
            @test failure isa RuntimeInterpreterException
            expected = fixture["expected_error"]
            actual = to_json(failure.diagnostic)
            @test actual["code"] == expected["code"]
            @test actual["operation"] == "nested_write_vivification"
            @test actual["binding"] == fixture["binding"]
            for field in (
                "segment_index",
                "path",
                "actual_kind",
                "reason",
                "expected_kind",
                "index",
                "length",
            )
                haskey(expected, field) && @test actual[field] == expected[field]
            end
            @test failure.message == _write_vivification_structural_message(expected)
            @test _write_vivification_effects(events) == fixture["expected_effects"]

            write = _write_vivification_nested_write(action)
            target = String(expected["source_target"])
            segment_index = parse(Int, target[(length("segment:") + 1):end]) + 1
            expected_span = Dict{String,Any}(
                "start" => write.segments[segment_index].source_span.start,
                "end" => write.segments[segment_index].source_span.stop,
                "unit" => "unicode_scalar",
                "provenance" => "authored",
            )
            @test actual["source_span"] == expected_span
        end
    end

    @testset "propagates expression failures unchanged and stops evaluation" begin
        fixtures = _write_vivification_objects(
            JULIA_WRITE_VIVIFICATION_CONTRACT["evaluation_failure_cases"],
        )
        @test length(fixtures) == 3
        for fixture in fixtures
            statements = String[]
            initial = fixture["initial_binding"]
            if initial["present"] == true
                push!(statements, "document = $(_write_vivification_literal(initial["value"]))")
            end
            segment_expressions = String[]
            failing_marker = nothing
            expected_failure = nothing
            for (index, segment) in enumerate(
                _write_vivification_objects(fixture["segments"]),
            )
                marker = "segment:$(index - 1)"
                if haskey(segment, "evaluation_error")
                    failing_marker = marker
                    expected_failure = segment["evaluation_error"]
                end
                value = get(segment, "value", "unreached")
                push!(
                    segment_expressions,
                    _write_vivification_instrumented(
                        marker,
                        _write_vivification_literal(value),
                    ),
                )
            end
            rhs = fixture["rhs"]
            if haskey(rhs, "evaluation_error")
                failing_marker = "rhs"
                expected_failure = rhs["evaluation_error"]
            end
            rhs_value = get(rhs, "value", "unreached")
            lvalue = "document" *
                     join(("[$expression]" for expression in segment_expressions))
            push!(
                statements,
                "$lvalue = $(_write_vivification_instrumented("rhs", _write_vivification_literal(rhs_value)))",
            )

            injected = RuntimeInterpreterException(
                String(expected_failure["message"]);
                diagnostic = RuntimeDiagnostic(
                    type = "runtime",
                    stage = "user_function_call",
                    summary = "injected user function failure",
                    detail = String(expected_failure["message"]),
                    code = String(expected_failure["code"]),
                ),
            )
            events = RuntimeDiagnosticOutputEvent[]
            failure = try
                runtime_parse(
                    _write_vivification_engine(join(statements, "; ")),
                    "xhello";
                    diagnostic_output_sink = event -> begin
                        push!(events, event)
                        strip(event.message) == failing_marker && throw(injected)
                    end,
                )
                nothing
            catch error
                error
            end
            @test failure === injected
            @test failure.message == expected_failure["message"]
            @test failure.diagnostic.code == expected_failure["code"]
            @test _write_vivification_effects(events) == fixture["expected_effects"]
        end
    end

    @testset "keeps reads non-creating" begin
        fixtures = _write_vivification_objects(
            JULIA_WRITE_VIVIFICATION_CONTRACT["read_exclusion_cases"],
        )
        @test length(fixtures) == 3
        for fixture in fixtures
            statements = String[]
            initial = fixture["initial_binding"]
            if initial["present"] == true
                push!(statements, "document = $(_write_vivification_literal(initial["value"]))")
            end
            access = "document" * join(
                "[$(_write_vivification_literal(segment["value"]))]"
                for segment in fixture["segments"]
            )
            push!(statements, "observed = $access")
            push!(statements, "return(array(document, observed))")
            result = runtime_parse(
                _write_vivification_engine(join(statements, "; ")),
                "xhello",
            )
            expected = fixture["expected_binding"]
            @test result.value == Any[get(expected, "value", nothing), fixture["expected_result"]]
        end
    end

    @testset "detaches initial, RHS, binding, and result" begin
        fixture = JULIA_WRITE_VIVIFICATION_CONTRACT["detachment_case"]
        expected = fixture["expected"]
        result = runtime_parse(
            _write_vivification_engine(raw"""
initial = { "existing" : ["keep"] };
document = initial;
rhs = ["a"];
result = (document["payload"] = rhs);
rhs[0] = "rhs-mutated";
result["payload"][0] = "result-mutated";
document["existing"][0] = "binding-mutated";
initial["existing"][0] = "initial-mutated";
return(array(initial, rhs, document, result))
"""),
            "xhello",
        )
        @test result.value == Any[
            expected["initial"],
            expected["rhs"],
            expected["binding"],
            expected["result"],
        ]
    end

    @testset "fresh function state distinguishes absence from bound null" begin
        fresh = _write_vivification_source_engine(raw"""
fn build_document() {
 document["items"][0] = "value";
 return(document)
}

Top::
 -> Done { return(array(build_document(), build_document())) }

Done::
 /[a-z]+/
""")
        @test runtime_parse(fresh, "xhello").value == Any[
            Dict{String,Any}("items" => Any["value"]),
            Dict{String,Any}("items" => Any["value"]),
        ]

        bound_null = _write_vivification_source_engine(raw"""
fn write_document(document) {
 document["key"] = "value";
 return(document)
}

Top::
 -> Done { return(write_document(undef)) }

Done::
 /[a-z]+/
""")
        failure = try
            runtime_parse(bound_null, "xhello")
            nothing
        catch error
            error
        end
        @test failure isa RuntimeInterpreterException
        diagnostic = to_json(failure.diagnostic)
        @test diagnostic["code"] == "nested_write_kind_conflict"
        @test diagnostic["binding"] == "document"
        @test diagnostic["segment_index"] == 0
        @test diagnostic["expected_kind"] == "harray"
        @test diagnostic["actual_kind"] == "null"
    end

    @testset "malformed typed carriers fail closed" begin
        corrupted = _write_vivification_corrupted_compiled()
        validator_failure = try
            validate_nested_write_serialized_state(corrupted)
            nothing
        catch error
            error
        end
        @test validator_failure isa CompiledSpecException
        @test occursin("nested_write_serialized_state_invalid", validator_failure.message)

        runtime_failure = try
            LinkedSpecRuntimeEngine(corrupted)
            nothing
        catch error
            error
        end
        @test runtime_failure isa RuntimeInterpreterException
        @test runtime_failure.diagnostic.code == "nested_write_serialized_state_invalid"

        emit_failure = try
            emit_julia_source_v2(corrupted, "write-vivification/corrupt.spec")
            nothing
        catch error
            error
        end
        @test emit_failure isa GeneratedSourceException
        @test occursin("nested_write_serialized_state_invalid", emit_failure.detail)

        plan_failure = try
            validate_generated_rule_plan_v2(
                corrupted,
                build_generated_rule_plan(corrupted),
                "write-vivification/corrupt.spec",
            )
            nothing
        catch error
            error
        end
        @test plan_failure isa GeneratedSourceException
        @test occursin("nested_write_serialized_state_invalid", plan_failure.detail)
    end

    @testset "typed state survives every supported Julia route" begin
        identity = "write-vivification/julia.spec"
        source = raw"""
Top::
 -> Done { key_name = "sections"; document[key_name][0]["title"] = "Intro"; return(document) }

Done::
 /[a-z]+/
"""
        expected = Dict{String,Any}(
            "sections" => Any[Dict{String,Any}("title" => "Intro")],
        )
        authored = parse_spec(source; source_id = identity)
        reconstructed = from_json(
            SpecFile,
            JSON3.read(JSON3.write(to_json(authored)), Dict{String,Any}),
        )
        compiled = compile_spec(reconstructed)
        compiled_json = String(JSON3.write(to_descriptor_json(compiled)))
        @test occursin("\"kind\":\"assign_nested_access\"", compiled_json)
        @test occursin("\"kind\":\"path_segment\"", compiled_json)
        @test occursin("\"source\":\"key_name\"", compiled_json)
        @test runtime_parse(LinkedSpecRuntimeEngine(compiled), "xhello").value == expected

        plan = build_generated_rule_plan(compiled)
        @test execute_generated_parser_v2(compiled, plan, "xhello", identity) == expected

        output = IOBuffer()
        errors = IOBuffer()
        @test LinkedSpecJulia.run_cli(
            ["--inline-spec", source, "--input", "xhello"];
            io = output,
            err = errors,
        ) == 0
        @test isempty(String(take!(errors)))
        @test JSON3.read(String(take!(output)), Dict{String,Any}) == expected

        emitted = emit_julia_source_v2(compiled, identity)
        @test occursin(GENERATED_SOURCE_CONTRACT, emitted)
        scratch = mktempdir()
        try
            generated_path = joinpath(scratch, "write_vivification_generated.jl")
            write(generated_path, emitted)
            host = Module(gensym(:JuliaWriteVivificationGenerated))
            Base.include(host, generated_path)
            parser = Base.invokelatest(() -> getfield(host, :LinkedSpecGeneratedParser))
            execute = Base.invokelatest(() -> Core.getglobal(parser, :execute))
            @test Base.invokelatest(execute, "xhello") == expected
        finally
            rm(scratch; recursive = true, force = true)
        end
        @test !ispath(scratch)
    end
end
