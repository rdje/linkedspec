function _sexpr_v1_render(node)
    node["kind"] == "list" || return node["lexeme"]
    return "(" * join(_sexpr_v1_render.(node["items"]), " ") * ")"
end

@testset "SExprDocumentV1 authored document contract" begin
    contract = JSON3.read(
        read(joinpath(REPO_ROOT, "tests", "sexpr-document-v1", "contract.json"), String),
        Dict{String,Any},
    )
    cases = contract["cases"]
    @test length(cases) == 37
    reuse = only(filter(row -> row["id"] == "reuse_after_rejection", cases))
    source = read(joinpath(REPO_ROOT, "specs", "SExprDocumentV1.spec"), String)
    parsed = parse_spec_with_staged_user_function_definitions(source)
    engine = LinkedSpecRuntimeEngine(compile_spec(parsed))
    for row in cases
        @testset "$(row["id"])" begin
            if row["outcome"] == "accept"
                @test runtime_parse(engine, row["input"]).value == row["expected"]
                rendered = join(_sexpr_v1_render.(row["expected"]["forms"]), "\n")
                @test runtime_parse(engine, rendered).value == row["expected"]
            else
                failure = try
                    runtime_parse(engine, row["input"])
                    nothing
                catch error
                    error
                end
                @test failure isa RuntimeExitNow
                if failure isa RuntimeExitNow
                    @test failure.status == 1
                end
                @test runtime_parse(engine, reuse["input"]).value == reuse["expected"]
            end
        end
    end
end
