using LinkedSpecJulia
using JSON3
using Test

const REPO_ROOT = normpath(joinpath(@__DIR__, "..", ".."))
const CORPUS_ROOT = joinpath(REPO_ROOT, "rust", "linkedspec-runtime", "tests", "corpus")

function _throws_corpus_message(call, needle)
    try
        call()
    catch error
        return error isa CorpusManifestException && occursin(needle, sprint(showerror, error))
    end
    return false
end

function _write_manifest(root, cases; case_count = length(cases), format = 1)
    manifest = Dict(
        "format" => format,
        "case_count" => case_count,
        "cases" => cases,
    )
    write(joinpath(root, "manifest.json"), JSON3.write(manifest))
end

function _write_fixture(
    root,
    name;
    spec_source = "Top:: /x/",
    input_text = "x",
    expected_json = Any[],
    expected_text = nothing,
    write_expected = true,
)
    fixture = joinpath(root, name)
    mkpath(fixture)
    write(joinpath(fixture, "input.spec"), spec_source)
    write(joinpath(fixture, "input.txt"), input_text)
    if write_expected
        text = expected_text === nothing ? JSON3.write(expected_json) : expected_text
        write(joinpath(fixture, "expected.json"), text)
    end
end

@testset "LinkedSpecJulia scaffold" begin
    @test backend_name() == "julia"
    @test cli_entrypoint() == "julia/bin/linkedspec_julia.jl"
    @test corpus_runner_entrypoint() == "julia/bin/corpus_runner.jl"

    status = backend_status()
    @test status.backend == "julia"
    @test status.package == "LinkedSpecJulia"
    @test status.parity == "frontend-ast-data"

    cli_output = IOBuffer()
    cli_error = IOBuffer()
    @test run_cli(["--help"]; io = cli_output, err = cli_error) == 0
    @test occursin("LinkedSpec Julia backend", String(take!(cli_output)))
    @test isempty(String(take!(cli_error)))

    status_output = IOBuffer()
    @test run_cli(["status"]; io = status_output, err = IOBuffer()) == 0
    @test occursin("parity: frontend-ast-data", String(take!(status_output)))

    corpus_output = IOBuffer()
    corpus_error = IOBuffer()
    @test run_corpus_runner(["--corpus", CORPUS_ROOT];
        io = corpus_output,
        err = corpus_error,
    ) == 0
    @test occursin("manifest validated", String(take!(corpus_output)))
    @test isempty(String(take!(corpus_error)))

    execute_error = IOBuffer()
    @test run_corpus_runner(["--corpus", "fixtures", "--execute"]; io = IOBuffer(), err = execute_error) == 2
    @test occursin("not implemented", String(take!(execute_error)))
end

@testset "Corpus manifest IO" begin
    validation = load_corpus_fixtures(CORPUS_ROOT)

    @test validation.root == CORPUS_ROOT
    @test validation.manifest.format == 1
    @test validation.manifest.case_count == 99
    @test length(validation.manifest.cases) == validation.manifest.case_count
    @test length(validation.fixtures) == validation.manifest.case_count
    @test validation.fixtures[1].name == "proof_edge_array_literal"
    @test !isempty(validation.fixtures[1].spec_source)
    @test validation.fixtures[1].expected_json == ["?proof:", "ok"]

    cli_output = IOBuffer()
    cli_error = IOBuffer()
    @test run_corpus_runner(["--corpus", CORPUS_ROOT]; io = cli_output, err = cli_error) == 0
    cli_text = String(take!(cli_output))
    @test occursin("fixtures: 99", cli_text)
    @test occursin("manifest validated", cli_text)
    @test isempty(String(take!(cli_error)))

    mktempdir() do root
        _write_manifest(root, ["alpha"]; format = 2)
        _write_fixture(root, "alpha")
        @test _throws_corpus_message(() -> load_corpus_fixtures(root), "unsupported corpus manifest format 2")
    end

    mktempdir() do root
        _write_manifest(root, ["../bad"])
        @test _throws_corpus_message(() -> load_corpus_fixtures(root), "invalid corpus manifest case name: ../bad")
    end

    mktempdir() do root
        _write_manifest(root, ["alpha", "alpha"])
        @test _throws_corpus_message(() -> load_corpus_fixtures(root), "duplicate case names")
    end

    mktempdir() do root
        _write_manifest(root, ["alpha", "beta"])
        _write_fixture(root, "alpha")
        @test _throws_corpus_message(() -> load_corpus_fixtures(root), "missing fixture dirs: [beta]")
    end

    mktempdir() do root
        _write_manifest(root, ["alpha"])
        _write_fixture(root, "alpha")
        _write_fixture(root, "stale")
        @test _throws_corpus_message(() -> load_corpus_fixtures(root), "extra fixture dirs: [stale]")
    end

    mktempdir() do root
        _write_manifest(root, ["alpha"]; case_count = 2)
        _write_fixture(root, "alpha")
        @test _throws_corpus_message(() -> load_corpus_fixtures(root), "case_count=2 does not match cases.len()=1")
    end

    mktempdir() do root
        _write_manifest(root, ["alpha"])
        _write_fixture(root, "alpha"; write_expected = false)
        @test _throws_corpus_message(() -> load_corpus_fixtures(root), "expected.json")
    end

    mktempdir() do root
        _write_manifest(root, ["alpha"])
        _write_fixture(root, "alpha"; expected_text = "{")
        @test _throws_corpus_message(() -> load_corpus_fixtures(root), "malformed expected.json for corpus case alpha")
    end
end

@testset "Spec AST JSON contract" begin
    spec = SpecFile(
        functions = [
            FunctionDefinition(
                name = "normalize",
                params = ["value"],
                arity = 1,
                body_source = "return(trim(value))",
                body_payload = Dict("kind" => "action_block"),
                body_parse_job = StagedParseJob(
                    job_id = "parse_job:function_body:functions.0.body_source",
                    parent_ast_path = ["functions", "0", "body_source"],
                    node_kind = "function_definition",
                    payload_kind = "action_block",
                    text = "return(trim(value))",
                    source_span = StagedSourceSpan(10, 28, 1, 1),
                    parser_spec_id = "actionir-body.spec",
                    top_rule = "action_block",
                    result_policy = "replace_field",
                    result_field = "body_ast",
                    failure_policy = "diagnostic",
                ),
                body_ast = Dict("kind" => "code_block", "statements" => Any[]),
                source = "fn normalize(value) { return(trim(value)) }",
                source_span = SourceSpan(1, 1),
                body_span = SourceSpan(1, 1),
            ),
        ],
        rules = [
            Rule(
                header = RuleHeader(
                    "Top",
                    true,
                    and_bounded_rule_mode(min = 1, max = 2),
                    "/x/ -> Child[0] { return(normalize(retv)) }",
                    2,
                ),
                body = [
                    BodyElement(RegexBodyElementKind("x"), "/x/", 2),
                    BodyElement(
                        ActionEdgeBodyElementKind(
                            targets = [EdgeTarget(label = "Child")],
                            code = "return(normalize(retv))",
                            fluent_chain = [FluentCall("push", "")],
                        ),
                        "-> Child[0] { return(normalize(retv)) }.push",
                        2,
                    ),
                    BodyElement(
                        CodeBlockBodyElementKind("I", "set(count, 0)"),
                        "I { set(count, 0) }",
                        3,
                    ),
                ],
            ),
        ],
    )

    encoded = JSON3.write(to_json(spec))
    decoded = from_json(SpecFile, JSON3.read(encoded))

    @test decoded.functions[1].name == "normalize"
    @test decoded.functions[1].body_parse_job !== nothing
    @test decoded.functions[1].body_parse_job.job_id == "parse_job:function_body:functions.0.body_source"
    @test top_rule(decoded).header.mode == and_bounded_rule_mode(min = 1, max = 2)
    @test is_and(top_rule(decoded).header.mode)
    @test rep_min(top_rule(decoded).header.mode) == 1
    @test rep_max(top_rule(decoded).header.mode) == 2
    @test decoded.rules[1].body[2].kind isa ActionEdgeBodyElementKind
    @test to_json(decoded) == to_json(spec)

    @test rep_min(default_rule_mode()) == 0
    @test rep_min(RuleMode("Star")) == 0
    @test rep_max(RuleMode("Optional")) == 1
    @test rep_min(RuleMode("Plus")) == 1
    @test is_and(RuleMode("And"))
    @test !is_and(RuleMode("Or"))
    @test rep_max(or_bounded_rule_mode(min = 2)) === nothing
end
