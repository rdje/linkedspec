const ROOT_SELECTION_CONTRACT = JSON3.read(
    read(
        joinpath(
            normpath(joinpath(@__DIR__, "..", "..")),
            "capability_conformance",
            "root_rule_selection_contract.json",
        ),
        String,
    ),
    Dict{String,Any},
)

function _root_selection_compiled_for_rows(rows)
    if isempty(rows)
        return compile_spec(SpecFile(rules = Rule[]); validate_source = false)
    end
    source = join(
        [
            begin
                label = String(row["label"])
                separator = row["authored_is_top"] ? "::" : ":"
                "$label$separator\n /x/\n E { return(\"$label\") }\n"
            end for row in rows
        ],
        "\n",
    )
    return compile_spec(parse_spec(source))
end

function _root_selection_error(call)
    try
        call()
    catch error
        return error
    end
    return nothing
end

@testset "Neutral root-rule selection core" begin
    @test ROOT_SELECTION_CONTRACT["contract_id"] == ENTRY_RULE_CONTRACT_ID

    for case_value in ROOT_SELECTION_CONTRACT["selection_cases"]
        case_id = String(case_value["id"])
        @testset "$case_id" begin
            compiled = _root_selection_compiled_for_rows(case_value["rules"])
            authored_before = [
                (label, compiled_rule(compiled, label).header.is_top)
                for label in compiled.compiled_rule_order
            ]
            selection = resolve_entry_rule(compiled, case_value["explicit_selector"])
            @test selection.rule.label == case_value["expected_label"]
            @test entry_rule_selection_basis_name(selection.basis) ==
                case_value["expected_basis"]
            @test [
                (label, compiled_rule(compiled, label).header.is_top)
                for label in compiled.compiled_rule_order
            ] == authored_before
        end
    end

    for case_value in ROOT_SELECTION_CONTRACT["failure_cases"]
        case_id = String(case_value["id"])
        @testset "$case_id" begin
            compiled = _root_selection_compiled_for_rows(case_value["rules"])
            error = _root_selection_error() do
                resolve_entry_rule(compiled, case_value["explicit_selector"])
            end
            @test error isa EntryRuleSelectionException
            if error isa EntryRuleSelectionException
                @test error.code == case_value["expected_code"]
                @test error.stage == case_value["expected_stage"]
                expected_fields = error.code == "entry_rule_not_found" ?
                    Dict{String,Any}("entry_rule" => case_value["explicit_selector"]) :
                    Dict{String,Any}()
                @test to_json(error)["fields"] == expected_fields
            end
        end
    end

    @testset "parser and structural validation" begin
        @test isempty(parse_spec("").rules)
        @test isempty(parse_spec("  \n# no rules\n\t").rules)
        @test_throws SpecParseException parse_spec("not a rule")
        @test validate_spec(parse_spec("Only:\n /x/")) === nothing

        for source in ("", "# no rules\n")
            error = _root_selection_error() do
                validate_spec(parse_spec(source))
            end
            @test error isa SpecValidationException
            if error isa SpecValidationException
                @test error.diagnostic isa SpecPortableDiagnostic
                @test to_json(error.diagnostic) == Dict{String,Any}(
                    "code" => "no_rules_defined",
                    "stage" => "validate_spec",
                    "message" => "spec does not define any rules",
                    "fields" => Dict{String,Any}(),
                )
            end
        end
    end

    @testset "native precedence and failures before user code" begin
        marked = LinkedSpecRuntimeEngine(compile_spec(parse_spec(raw"""
Earlier:
 /x/
 E { return("earlier") }

Marked::
 /x/
 E { return("marked") }

Later::
 /x/
 E { return("later") }
""")))
        @test runtime_parse(marked, "x").value == "marked"
        @test runtime_parse(marked, "x"; top_rule = "Earlier").value == "earlier"
        @test runtime_parse(marked, "x"; top_rule = "Later").value == "later"

        markerless = LinkedSpecRuntimeEngine(compile_spec(parse_spec(raw"""
First:
 /x/
 E { return("first") }

Second:
 /x/
 E { return("second") }
""")))
        @test runtime_parse(markerless, "x").value == "first"
        @test runtime_parse(markerless, "x"; top_rule = "Second").value == "second"

        exits_if_entered = LinkedSpecRuntimeEngine(compile_spec(parse_spec(raw"""
Top::
 /x/
 I { exit_now(99) }
""")))
        unknown = _root_selection_error() do
            runtime_parse(exits_if_entered, "x"; top_rule = "Missing")
        end
        @test unknown isa RuntimeInterpreterException
        if unknown isa RuntimeInterpreterException
            @test unknown.message == "entry rule 'Missing' is not defined"
            @test unknown.diagnostic.code == "entry_rule_not_found"
            @test unknown.diagnostic.stage == "select_entry_rule"
            @test unknown.diagnostic.top_rule == "Missing"
            @test unknown.diagnostic.entry_rule == "Missing"
            @test unknown.diagnostic.rule_label == "Missing"
        end

        empty_engine = LinkedSpecRuntimeEngine(
            compile_spec(SpecFile(rules = Rule[]); validate_source = false),
        )
        zero = _root_selection_error() do
            runtime_parse(empty_engine, ""; top_rule = "Missing")
        end
        @test zero isa RuntimeInterpreterException
        if zero isa RuntimeInterpreterException
            @test zero.diagnostic.code == "no_rules_defined"
            @test zero.diagnostic.stage == "validate_spec"
            @test zero.diagnostic.top_rule === nothing
            @test zero.diagnostic.entry_rule === nothing
        end
    end

    @testset "descriptor identity and strict authored edges" begin
        compiled = _root_selection_compiled_for_rows([
            Dict{String,Any}("label" => "Earlier", "authored_is_top" => false),
            Dict{String,Any}("label" => "Marked", "authored_is_top" => true),
            Dict{String,Any}("label" => "Later", "authored_is_top" => true),
        ])
        before = to_descriptor_json(compiled)
        @test resolve_entry_rule(compiled, "Earlier").rule.label == "Earlier"
        @test runtime_parse(
            LinkedSpecRuntimeEngine(compiled),
            "x";
            top_rule = "Earlier",
        ).value == "Earlier"
        after = to_descriptor_json(compiled)
        @test after == before
        @test after["meta"]["entry_rule_contract"] == ENTRY_RULE_CONTRACT_ID
        @test after["meta"]["definition_order"] == ["Earlier", "Marked", "Later"]
        @test !haskey(after["meta"], "entry_rule")
        @test !haskey(after["meta"], "selected_entry_rule")
        @test after["spec"]["Earlier"]["meta"]["is_top"] === false
        @test after["spec"]["Marked"]["meta"]["is_top"] === true
        @test after["spec"]["Later"]["meta"]["is_top"] === true

        strict_sources = Dict(
            "explicit_selection_is_not_reference" => "A:\n /a/\n\nB:\n /b/\n",
            "marker_selection_is_not_reference" =>
                "Top::\n /x/ -> Child\n\nChild:\n /x/ -> Child\n",
            "closed_reference_cycle_has_no_unused_rules" =>
                "A:\n /a/ -> B\n\nB:\n /b/ -> A\n",
        )
        for case_value in ROOT_SELECTION_CONTRACT["strict_cases"]
            case_id = String(case_value["id"])
            spec = parse_spec(strict_sources[case_id])
            expected_unused = String[String(label) for label in case_value["expected_unused"]]
            if case_id == "explicit_selection_is_not_reference"
                resolve_entry_rule(compile_spec(spec), case_value["explicit_selector"])
            end
            if isempty(expected_unused)
                @test validate_spec(spec; strict_syntax = true) === nothing
            else
                error = _root_selection_error() do
                    validate_spec(spec; strict_syntax = true)
                end
                @test error isa SpecValidationException
                if error isa SpecValidationException
                    @test error.message ==
                        "unused rule(s) in strict mode: $(join(expected_unused, ", "))"
                end
            end
        end
    end
end
