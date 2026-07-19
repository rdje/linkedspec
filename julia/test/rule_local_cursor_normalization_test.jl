const RULE_LOCAL_CURSOR_CONTRACT = JSON3.read(
    read(
        joinpath(REPO_ROOT, "capability_conformance", "rule_local_cursor_contract.json"),
        String,
    ),
    Dict{String,Any},
)

function _cursor_contract_rows(name::AbstractString)
    return RULE_LOCAL_CURSOR_CONTRACT[String(name)]
end

function _cursor_edge_source(parent_family, sources, declared_rules)
    io = IOBuffer()
    println(io, parent_family == "and" ? "Top::AND" : "Top::")
    for source in sources
        println(io, " ", source)
    end
    for label in declared_rules
        println(io)
        println(io, label, ":")
        println(io, " /x/ /y/")
    end
    return String(take!(io))
end

function _cursor_diagnostic(source::AbstractString)
    try
        validate_spec(parse_spec(source))
    catch error
        if error isa SpecValidationException && error.diagnostic !== nothing
            return error.diagnostic
        end
        rethrow()
    end
    error("expected portable spec validation diagnostic")
end

function _cursor_fluent_text(call::FluentCall)
    return isempty(call.args) ? call.method : "$(call.method)($(call.args))"
end

@testset "Neutral rule-local cursor normalization contract" begin
    family_rows = _cursor_contract_rows("family_cases")
    edge_rows = _cursor_contract_rows("edge_resolution_cases")
    edge_set_rows = _cursor_contract_rows("rule_edge_set_cases")
    diagnostic_rows = Dict(row["code"] => row for row in _cursor_contract_rows("diagnostics"))

    @test length(family_rows) == 36
    @test length(edge_rows) == 18
    @test length(edge_set_rows) == 6

    @testset "all authored rule families" begin
        for row in family_rows
            parsed = parse_spec("$(row["header"])\n /x/\n")
            mode = only(parsed.rules).header.mode
            expected_family = row["family"]
            expected_policy = row["cursor_policy"]

            @test rule_family(mode) == expected_family
            @test cursor_policy(mode) == expected_policy

            compiled = compiled_rule(compile_spec(parsed; validate_source = false), "Top")
            @test compiled !== nothing
            @test rule_family(compiled.mode_metadata) == expected_family
            @test cursor_policy(compiled.mode_metadata) == expected_policy
        end

        @test !is_and(RuleMode("Pipe"))
        @test is_and(RuleMode("Single"))
    end

    @testset "every edge form and diagnostic" begin
        for row in edge_rows
            id = row["id"]
            declared = String[String(value) for value in row["declared_rules"]]
            source = _cursor_edge_source(
                row["parent_family"],
                [String(row["source"])],
                declared,
            )

            expected_error = get(row, "expected_error", nothing)
            if expected_error !== nothing
                diagnostic = _cursor_diagnostic(source)
                contract_diagnostic = diagnostic_rows[expected_error]
                @test diagnostic.code == expected_error
                @test diagnostic.stage == contract_diagnostic["stage"]
                @test Set(keys(diagnostic.fields)) == Set(String(value) for value in contract_diagnostic["fields"])
                @test diagnostic.fields["rule_label"] == "Top"
                if haskey(diagnostic.fields, "target")
                    @test diagnostic.fields["target"] == (
                        expected_error == "bare_edge_target_undefined" ? "Missing" : "Child"
                    )
                end
                if haskey(diagnostic.fields, "regex_index")
                    @test diagnostic.fields["regex_index"] == 0
                end
                if haskey(diagnostic.fields, "targets")
                    @test diagnostic.fields["targets"] == declared
                end

                roundtrip = from_json(
                    SpecPortableDiagnostic,
                    JSON3.read(JSON3.write(to_json(diagnostic))),
                )
                @test to_json(roundtrip) == to_json(diagnostic)
                continue
            end

            parsed = parse_spec(source)
            validate_spec(parsed)
            expected = row["expected"]
            first_kind = first(first(parsed.rules).body).kind

            if expected["kind"] == "lifecycle"
                @test first_kind isa LifecycleMarkerBodyElementKind
                @test first_kind.marker == expected["name"]
                continue
            end

            if expected["source_form"] == "bare"
                @test first_kind isa BareEdgeBodyElementKind
                @test length(first_kind.targets) == length(expected["targets"])
                @test (first_kind.code !== nothing) == expected["has_block"]
                expected_fluent = first(expected["targets"])["fluent"]
                actual_fluent = isempty(first_kind.fluent_chain) ? nothing : _cursor_fluent_text(first(first_kind.fluent_chain))
                @test actual_fluent == expected_fluent
                @test all(element -> !(element.kind isa RawBodyElementKind), first(parsed.rules).body)

                roundtrip = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
                @test to_json(roundtrip) == to_json(parsed)
            end

            compiled = compiled_rule(compile_spec(parsed), "Top")
            @test compiled !== nothing
            expected_targets = expected["targets"]
            if expected["ownership"] == "action"
                @test length(compiled.action_edges) == length(expected_targets)
                @test isempty(compiled.blind_edges)
                for (index, target) in enumerate(expected_targets)
                    actual = only(compiled.action_edges[index].targets)
                    @test actual.label == target["label"]
                    @test actual.index == something(target["index"], 0)
                end
            else
                @test length(compiled.blind_edges) == length(expected_targets)
                @test isempty(compiled.action_edges)
                for (index, target) in enumerate(expected_targets)
                    @test compiled.blind_edges[index].target.label == target["label"]
                end
            end
        end
    end

    @testset "normalized ownership sets" begin
        for row in edge_set_rows
            declared = String[String(value) for value in row["declared_rules"]]
            sources = String[String(value) for value in row["sources"]]
            source = _cursor_edge_source(row["parent_family"], sources, declared)
            expected_error = get(row, "expected_error", nothing)

            if expected_error !== nothing
                diagnostic = _cursor_diagnostic(source)
                @test diagnostic.code == expected_error
                @test diagnostic.stage == "validate_rule"
                @test Set(keys(diagnostic.fields)) == Set(["ownerships", "rule_label"])
                @test diagnostic.fields["ownerships"] == ["action", "blind"]
                continue
            end

            compiled = compiled_rule(compile_spec(parse_spec(source)), "Top")
            @test compiled !== nothing
            if row["expected_ownership"] == "action"
                @test !isempty(compiled.action_edges)
                @test isempty(compiled.blind_edges)
            else
                @test !isempty(compiled.blind_edges)
                @test isempty(compiled.action_edges)
            end
        end
    end

    @testset "bare candidates are physical-line scoped" begin
        for source in [
            "Top::\n Child\n\nChild:\n /x/\n",
            "Top:: Child\n\nChild:\n /x/\n",
            "Top::AND\n Child {\n  return(child_result)\n }\n\nChild:\n /x/\n",
        ]
            parsed = parse_spec(source)
            @test first(first(parsed.rules).body).kind isa BareEdgeBodyElementKind
            @test all(element -> !(element.kind isa RawBodyElementKind), first(parsed.rules).body)
        end

        suffix = parse_spec("Top:: /x/ Child\n\nChild:\n /x/\n")
        @test all(element -> !(element.kind isa BareEdgeBodyElementKind), first(suffix.rules).body)
    end
end
