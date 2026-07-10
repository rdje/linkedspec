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

function _throws_validation_message(call, needle)
    try
        call()
    catch error
        return error isa SpecValidationException && occursin(needle, sprint(showerror, error))
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

function _regex_patterns_of(rule::Rule)
    return [
        element.kind.pattern for element in rule.body
        if element.kind isa RegexBodyElementKind
    ]
end

function _starts_with_top_level_function(source::AbstractString)
    for line in split(source, '\n'; keepempty = true)
        trimmed = strip(line)
        if isempty(trimmed) || startswith(trimmed, "#")
            continue
        end
        return startswith(trimmed, "fn ")
    end
    return false
end

function _spec_with_functions(functions)
    rule = Rule(
        header = RuleHeader("Top", true, default_rule_mode(), "", 1),
        body = [BodyElement(RegexBodyElementKind("x"), "/x/", 2)],
    )
    return SpecFile(functions = functions, rules = [rule])
end

function _function_definition(name, params; arity = length(params))
    return FunctionDefinition(
        name = name,
        params = params,
        arity = arity,
        body_source = "return(value)",
        source = "fn $name($(join(params, ", "))) { return(value) }",
        source_span = SourceSpan(1, 1),
        body_span = SourceSpan(1, 1),
    )
end

@testset "LinkedSpecJulia scaffold" begin
    @test backend_name() == "julia"
    @test cli_entrypoint() == "julia/bin/linkedspec_julia.jl"
    @test corpus_runner_entrypoint() == "julia/bin/corpus_runner.jl"

    status = backend_status()
    @test status.backend == "julia"
    @test status.package == "LinkedSpecJulia"
    @test status.parity == "source-validator"

    cli_output = IOBuffer()
    cli_error = IOBuffer()
    @test run_cli(["--help"]; io = cli_output, err = cli_error) == 0
    @test occursin("LinkedSpec Julia backend", String(take!(cli_output)))
    @test isempty(String(take!(cli_error)))

    status_output = IOBuffer()
    @test run_cli(["status"]; io = status_output, err = IOBuffer()) == 0
    @test occursin("parity: source-validator", String(take!(status_output)))

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

@testset "Spec parser" begin
    modes = Dict(
        "R1:AND" => RuleMode("And"),
        "R2:OR+" => RuleMode("OrPlus"),
        "R3::*" => RuleMode("Star"),
        "R4:?" => RuleMode("Optional"),
        "R5:AND{2,4}" => and_bounded_rule_mode(min = 2, max = 4),
        "R6:OR{3}" => or_bounded_rule_mode(min = 3, max = 3),
        "R7:&" => RuleMode("Single"),
        "R8:|" => RuleMode("Pipe"),
    )

    for (header, mode) in modes
        spec = parse_spec("$header\n /x/")
        @test spec.rules[1].header.mode == mode
        @test spec.rules[1].body[1].kind isa RegexBodyElementKind
    end

    inline = parse_spec("Top:: /x/ I { return(entry_text()) } E.return(\"done\")")
    @test inline.rules[1].header.rest == "/x/ I { return(entry_text()) } E.return(\"done\")"
    @test inline.rules[1].body[1].kind isa RegexBodyElementKind
    @test inline.rules[1].body[2].kind isa CodeBlockBodyElementKind
    @test inline.rules[1].body[3].kind isa CodeBlockBodyElementKind

    single = parse_spec("Top::\n -> semi\n\nsemi : /;/")
    @test _regex_patterns_of(find_rule(single, "semi")) == [";"]

    pair = parse_spec("Top::\n -> bracket\n\nbracket : /\\(/ /\\)/")
    @test _regex_patterns_of(find_rule(pair, "bracket")) == ["\\(", "\\)"]

    edges = parse_spec(raw"""
Top::->Child.push
 -> Child[1] .return(array("?child:", copy(array(Child))))
 -> A | B { return(entry_text()) }
 =>Helper.trim()

Child: /x/ /y/
Helper: /h/
""")
    top = top_rule(edges)
    @test length(top.body) == 4
    compact = top.body[1].kind
    @test compact isa ActionEdgeBodyElementKind
    @test compact.targets[1].label == "Child"
    @test compact.targets[1].index == 0
    @test compact.fluent_chain[1].method == "push"

    indexed = top.body[2].kind
    @test indexed isa ActionEdgeBodyElementKind
    @test indexed.targets[1].index == 1
    @test indexed.fluent_chain[1].method == "return"
    @test indexed.fluent_chain[1].args == "array(\"?child:\", copy(array(Child)))"

    grouped = top.body[3].kind
    @test grouped isa ActionEdgeBodyElementKind
    @test [target.label for target in grouped.targets] == ["A", "B"]
    @test grouped.code == "return(entry_text())"

    blind = top.body[4].kind
    @test blind isa BlindEdgeBodyElementKind
    @test blind.target == "Helper"
    @test blind.fluent_chain[1].method == "trim"

    continuation = parse_spec(raw"""
Top::
 -> item
  .if(on)
    .push(item, out)
  .else()
    .return_undef()
  .endif()

item: /x/
""")
    edge = top_rule(continuation).body[1].kind
    @test [(call.method, call.args) for call in edge.fluent_chain] == [
        ("if", "on"),
        ("push", "item, out"),
        ("else", ""),
        ("return_undef", ""),
        ("endif", ""),
    ]

    attached = parse_spec(raw"""
Top::
 -> Done.when(false) {
    return("bad")
 }.otherwise {
    return("fallback")
 }
 I.when(false) { set(out, "bad") } otherwise { set(out, "fallback") }

Done:
 /x/
""")
    action = top_rule(attached).body[1].kind
    @test action isa ActionEdgeBodyElementKind
    @test isempty(action.fluent_chain)
    @test occursin("when(false)", action.code)
    @test occursin("return(\"fallback\")", action.code)
    lifecycle = top_rule(attached).body[2].kind
    @test lifecycle isa CodeBlockBodyElementKind
    @test lifecycle.lifecycle == "I"
    @test occursin("otherwise", lifecycle.code)

    compact_lifecycle = parse_spec(raw"""
Top::
 I.set(out, undef).set(out, "ok").return(out)
 /x/
""")
    block = top_rule(compact_lifecycle).body[1].kind
    @test block isa CodeBlockBodyElementKind
    @test block.code == "set(out, undef); set(out, \"ok\"); return(out)"

    multiline_args = parse_spec(raw"""
Top::
 I.return({
  "type" => "function_definition_error",
  "source_text" => entry_text()
 })
 /x/
""")
    multiline_block = top_rule(multiline_args).body[1].kind
    @test multiline_block isa CodeBlockBodyElementKind
    @test startswith(multiline_block.code, "return({")
    @test occursin("\"source_text\" => entry_text()", multiline_block.code)
    @test top_rule(multiline_args).body[2].kind isa RegexBodyElementKind

    quoted_braces = parse_spec(raw"""
Top::
 /a/ I { print("literal { brace"); print('literal } brace') }
 /b/ E { return("ok") }
""")
    quoted_block = top_rule(quoted_braces).body[2].kind
    @test quoted_block isa CodeBlockBodyElementKind
    @test occursin("print(\"literal { brace\")", quoted_block.code)
    @test occursin("print('literal } brace')", quoted_block.code)
    @test top_rule(quoted_braces).body[3].kind isa RegexBodyElementKind

    raw_fallback = parse_spec("Top::\n raw compatibility line")
    @test top_rule(raw_fallback).body[1].kind isa RawBodyElementKind
    @test_throws SpecParseException parse_spec("fn normalize(value) { return(trim(value)) }\n\nTop::\n /x/")

    spec_files = sort(filter(path -> endswith(path, ".spec"), readdir(joinpath(REPO_ROOT, "specs"); join = true)))
    @test !isempty(spec_files)
    for file in spec_files
        parsed = parse_spec(read(file, String))
        @test !isempty(parsed.rules)
    end

    corpus_specs = String[]
    for (root, _, files) in walkdir(CORPUS_ROOT)
        for file in files
            if file == "input.spec"
                push!(corpus_specs, joinpath(root, file))
            end
        end
    end
    sort!(corpus_specs)

    parsed_count = 0
    skipped_function_shells = 0
    for file in corpus_specs
        source = read(file, String)
        if _starts_with_top_level_function(source)
            skipped_function_shells += 1
            continue
        end
        parsed = parse_spec(source)
        @test !isempty(parsed.rules)
        parsed_count += 1
    end
    @test parsed_count > 80
    @test skipped_function_shells > 0
end

@testset "Spec validation" begin
    valid = parse_spec("Top::\n /a/ -> Child\n\nChild:\n /b/")
    @test validate_spec(valid) === nothing

    no_top = parse_spec("Rule:\n /a/")
    @test _throws_validation_message(() -> validate_spec(no_top), "no top rule")

    duplicate = parse_spec("Top::\n /a/\n\nTop:\n /b/")
    @test _throws_validation_message(() -> validate_spec(duplicate), "duplicate rule label")

    mixed = parse_spec(raw"""
Top::
 /a/ -> A
 /b/ => B

A: /a/
B: /b/
""")
    @test _throws_validation_message(() -> validate_spec(mixed), "mixes action")

    missing = parse_spec("Top::\n /a/ -> Ghost")
    @test _throws_validation_message(() -> validate_spec(missing), "undefined rule")

    bad_index = parse_spec("Top::\n /a/ -> Child[1]\n\nChild:\n /b/")
    @test _throws_validation_message(() -> validate_spec(bad_index), "regex slot 1")

    grouped = parse_spec("Top::\n -> A | B\n\nA: /a/\nB: /b/")
    @test _throws_validation_message(() -> validate_spec(grouped), "grouped action-edge targets")

    raw = parse_spec("Top::\n unsupported helper line")
    @test _throws_validation_message(() -> validate_spec(raw), "unrecognized body syntax")

    invalid_regex = parse_spec("Top::\n /[invalid/")
    @test _throws_validation_message(() -> validate_spec(invalid_regex), "invalid regex pattern")

    strict_unused = parse_spec("Top::\n /a/ -> Child\n\nChild:\n /b/")
    @test validate_spec(strict_unused) === nothing
    @test _throws_validation_message(() -> validate_spec(strict_unused; strict_syntax = true), "unused")
    @test _throws_validation_message(() -> validate_spec(strict_unused; strict_syntax = true), "Top")

    recursive_top = parse_spec("Top::\n /a/ -> Top")
    @test validate_spec(recursive_top; strict_syntax = true) === nothing

    ok_function = _spec_with_functions([_function_definition("normalize", ["value"])])
    @test validate_spec(ok_function) === nothing

    duplicate_function = _spec_with_functions([
        _function_definition("normalize", ["value"]),
        _function_definition("normalize", ["other"]),
    ])
    @test _throws_validation_message(() -> validate_spec(duplicate_function), "duplicate user function")

    rule_collision = _spec_with_functions([_function_definition("Top", ["value"])])
    @test _throws_validation_message(() -> validate_spec(rule_collision), "collides with rule label")

    builtin_collision = _spec_with_functions([_function_definition("trim", ["value"])])
    @test _throws_validation_message(() -> validate_spec(builtin_collision), "built-in helper")

    invalid_function_name = _spec_with_functions([_function_definition("1bad", ["value"])])
    @test _throws_validation_message(() -> validate_spec(invalid_function_name), "invalid user function name")

    duplicate_param = _spec_with_functions([_function_definition("normalize", ["value", "value"])])
    @test _throws_validation_message(() -> validate_spec(duplicate_param), "duplicate parameter")

    reserved_param = _spec_with_functions([_function_definition("normalize", ["ctx"])])
    @test _throws_validation_message(() -> validate_spec(reserved_param), "parameter 'ctx' is reserved")

    arity_mismatch = _spec_with_functions([_function_definition("normalize", ["value"]; arity = 2)])
    @test _throws_validation_message(() -> validate_spec(arity_mismatch), "arity")

    spec_files = sort(filter(path -> endswith(path, ".spec"), readdir(joinpath(REPO_ROOT, "specs"); join = true)))
    @test !isempty(spec_files)
    for file in spec_files
        validate_spec(parse_spec(read(file, String)))
    end

    corpus_specs = String[]
    for (root, _, files) in walkdir(CORPUS_ROOT)
        for file in files
            if file == "input.spec"
                push!(corpus_specs, joinpath(root, file))
            end
        end
    end
    sort!(corpus_specs)

    parsed_count = 0
    for file in corpus_specs
        source = read(file, String)
        if _starts_with_top_level_function(source)
            continue
        end
        validate_spec(parse_spec(source))
        parsed_count += 1
    end
    @test parsed_count > 80
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
