module JuliaStandaloneLifecycleBlockContract

using JSON3
using LinkedSpecJulia
using Test

const REPO_ROOT = isdefined(Main, :REPO_ROOT) ?
    Main.REPO_ROOT : normpath(joinpath(@__DIR__, "..", ".."))
const CONTRACT = JSON3.read(
    read(
        joinpath(
            REPO_ROOT,
            "capability_conformance",
            "standalone_lifecycle_block_contract.json",
        ),
        String,
    ),
    Dict{String,Any},
)

_parse(source) = parse_spec_with_staged_user_function_definitions(String(source))
_compile(source) = compile_spec(_parse(source))

function _lifecycle(source)
    rule = only(_parse(source).rules)
    return only(element for element in rule.body if element.kind isa CodeBlockBodyElementKind)
end

function _all_kinds(source)
    return [to_json(element.kind)["kind"] for rule in _parse(source).rules for element in rule.body]
end

function _execute(compiled, input)
    return runtime_parse(LinkedSpecRuntimeEngine(compiled), String(input)).value
end

function _capture_failure(source)
    try
        _compile(source)
    catch error
        return error
    end
    error("expected source to reject")
end

@testset "standalone lifecycle block contract" begin
    @testset "placement normalization" begin
        for row in CONTRACT["placement_twins"]
            explicit = _lifecycle(row["explicit"])
            shorthand = _lifecycle(row["shorthand"])
            @test to_json(explicit.kind) == to_json(shorthand.kind)
            @test explicit.kind.lifecycle == "I"
            @test explicit.kind.code == strip(String(row["interior"]))
            @test shorthand.kind.code == strip(String(row["interior"]))
            @test explicit.line == row["opening_line"]
            @test shorthand.line == row["opening_line"]
            @test !("plain_block" in _all_kinds(row["shorthand"]))
        end
    end

    @testset "provenance and ActionIR equivalence" begin
        row = CONTRACT["provenance_twin"]
        explicit = _lifecycle(row["explicit"])
        shorthand = _lifecycle(row["shorthand"])
        @test explicit.source == row["explicit_block_source"]
        @test shorthand.source == row["shorthand_block_source"]
        @test explicit.line == row["opening_line"]
        @test shorthand.line == row["opening_line"]
        @test to_json(explicit.kind) == to_json(shorthand.kind)

        explicit_payload = only(compiled_rule(_compile(row["explicit"]), "Top").lifecycle_action_payloads)
        shorthand_payload = only(compiled_rule(_compile(row["shorthand"]), "Top").lifecycle_action_payloads)
        explicit_semantic = to_json(explicit_payload)
        shorthand_semantic = to_json(shorthand_payload)
        delete!(explicit_semantic, "source")
        delete!(shorthand_semantic, "source")
        @test explicit_semantic == shorthand_semantic
    end

    @testset "authored duplicates and carriers" begin
        for row in CONTRACT["duplicate_cases"]
            source = String(row["source"])
            parsed = _parse(source)
            compiled = compile_spec(parsed)
            input = String(CONTRACT["duplicate_input"])
            expected = CONTRACT["duplicate_expected"]
            @test _execute(compiled, input) == expected

            reconstructed = from_json(
                SpecFile,
                JSON3.read(JSON3.write(to_json(parsed))),
            )
            @test _execute(compile_spec(reconstructed), input) == expected
            identity = "standalone-lifecycle/julia-$(row["id"]).spec"
            @test execute_generated_parser_v2(
                compiled,
                build_generated_rule_plan(compiled),
                input,
                identity,
            ) == expected
            @test !isempty(emit_julia_source_v2(compiled, identity))
        end
    end

    @testset "brace ownership" begin
        for row in CONTRACT["ownership_cases"]
            @test row["expected_kind"] in _all_kinds(row["source"])
        end
    end

    @testset "malformed twins" begin
        for row in CONTRACT["malformed_twins"]
            explicit = _capture_failure(row["explicit"])
            shorthand = _capture_failure(row["shorthand"])
            @test typeof(explicit) == typeof(shorthand)
            @test !isempty(sprint(showerror, explicit))
            @test !isempty(sprint(showerror, shorthand))
        end
    end

    @testset "legacy plain compatibility remains inert" begin
        normalized = _parse("Top::\n { return(\"must-not-run\") }\n")
        top = only(normalized.rules)
        legacy = SpecFile(
            source_id = "legacy-plain.spec",
            rules = [
                Rule(
                    header = top.header,
                    body = [
                        BodyElement(
                            PlainBlockBodyElementKind(" return(\"must-not-run\") "),
                            "{ return(\"must-not-run\") }",
                            2,
                        ),
                    ],
                ),
            ],
        )
        reconstructed = from_json(
            SpecFile,
            JSON3.read(JSON3.write(to_json(legacy))),
        )
        compiled = compile_spec(reconstructed; validate_source = false)
        @test length(compiled_rule(compiled, "Top").plain_action_payloads) == 1
        @test _execute(compiled, "") === nothing
        @test execute_generated_parser_v2(
            compiled,
            build_generated_rule_plan(compiled),
            "",
            "standalone-lifecycle/julia-legacy-plain.spec",
        ) === nothing
    end
end

end
