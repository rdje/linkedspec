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

function _throws_parse_message(call, needle)
    try
        call()
    catch error
        return error isa SpecParseException && occursin(needle, sprint(showerror, error))
    end
    return false
end

function _throws_user_function_message(call, needle)
    try
        call()
    catch error
        return error isa UserFunctionDefinitionException && occursin(needle, sprint(showerror, error))
    end
    return false
end

function _throws_compiled_spec_message(call, needle)
    try
        call()
    catch error
        return error isa CompiledSpecException && occursin(needle, sprint(showerror, error))
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

function _function_with_body_sidecar(
    name,
    params;
    body_source = "return(value)",
    body_ast = nothing,
    index = 0,
)
    path = ["functions", string(index), "body_source"]
    span = StagedSourceSpan(0, 1, 1, 1)
    span_json = to_json(span)
    payload = Dict{String,Any}(
        "kind" => "staged_payload",
        "node_kind" => "function_definition",
        "payload_kind" => "function_body",
        "parent_ast_path" => path,
        "function_name" => name,
        "params" => params,
        "arity" => length(params),
        "text" => body_source,
        "source_span" => span_json,
    )
    job = StagedParseJob(
        version = 1,
        job_id = "parse_job:function_body:functions.$index.body_source",
        parent_ast_path = path,
        node_kind = "function_definition",
        payload_kind = "function_body",
        function_name = name,
        params = params,
        arity = length(params),
        text = body_source,
        source_span = span,
        parser_spec_id = "actionir-body.spec",
        top_rule = "action_block",
        result_policy = "replace_field",
        result_field = "body_ast",
        failure_policy = "fail",
        diagnostic_owner = "function_body",
    )
    return FunctionDefinition(
        name = name,
        params = params,
        arity = length(params),
        body_source = body_source,
        body_payload = payload,
        body_parse_job = job,
        body_ast = body_ast,
        source = "fn $name($(join(params, ", "))) { $body_source }",
        source_span = SourceSpan(1, 1),
        body_span = SourceSpan(1, 1),
    )
end

function _canonical_names(resolution::ActionContractResolution)
    return [contract.canonical_name for contract in resolution.contracts]
end

function _action_contract(resolution::ActionContractResolution, source_name::AbstractString)
    matches = [contract for contract in resolution.contracts if contract.source_name == source_name]
    @test length(matches) == 1
    return only(matches)
end

function _diagnostic_codes(resolution::ActionContractResolution)
    return [diagnostic.code for diagnostic in resolution.diagnostics]
end

function _definition_node(source, name, params, body_source)
    source_start = _find_offset(source, "fn $name")
    body_start = _find_offset(source, body_source; start = source_start)
    body_end = body_start + length(collect(body_source))
    source_end = _find_offset(source, "}"; start = body_end) + 1
    source_text = _slice_chars(source, source_start, source_end)
    source_span = _span(source, source_start, source_end)
    body_span = _span(source, body_start, body_end)

    return Dict{String,Any}(
        "type" => "function_definition",
        "kind" => "user_function_definition",
        "version" => 1,
        "name" => name,
        "params" => params,
        "arity" => length(params),
        "source_text" => source_text,
        "source_span" => source_span,
        "body_source" => body_source,
        "body_span" => body_span,
        "body_payload" => Dict{String,Any}(
            "kind" => "staged_payload",
            "version" => 1,
            "node_kind" => "function_definition",
            "payload_kind" => "function_body",
            "parent_ast_path" => ["functions", "__pending_source_order__", "body_source"],
            "function_name" => name,
            "params" => params,
            "arity" => length(params),
            "text" => body_source,
            "source_span" => body_span,
            "provenance" => Any[
                Dict("kind" => "source_slice", "source_span" => body_span),
            ],
        ),
        "body_parse_job" => Dict{String,Any}(
            "kind" => "parse_job",
            "version" => 1,
            "job_id" => "parse_job:function_body:$name:actionir-body.spec:action_block",
            "parent_ast_path" => ["functions", "__pending_source_order__", "body_source"],
            "node_kind" => "function_definition",
            "payload_kind" => "function_body",
            "function_name" => name,
            "params" => params,
            "arity" => length(params),
            "text" => body_source,
            "source_span" => body_span,
            "parser_spec_id" => "actionir-body.spec",
            "top_rule" => "action_block",
            "result_policy" => "replace_field",
            "result_field" => "body_ast",
            "failure_policy" => "fail",
            "diagnostic_owner" => "function_body",
        ),
    )
end

function _find_offset(source, needle; start = 0)
    chars = collect(source)
    needle_chars = collect(needle)
    if isempty(needle_chars)
        return start
    end
    last_start = length(chars) - length(needle_chars) + 1
    for index in (start + 1):last_start
        if chars[index:(index + length(needle_chars) - 1)] == needle_chars
            return index - 1
        end
    end
    error("missing $needle")
end

function _slice_chars(source, start, stop)
    if start == stop
        return ""
    end
    return String(collect(source)[(start + 1):stop])
end

function _span(source, start, stop)
    return Dict{String,Any}(
        "start" => start,
        "end" => stop,
        "line_start" => _line_at(source, start),
        "line_end" => _line_at(source, stop),
    )
end

function _line_at(source, offset)
    line = 1
    for (index, char) in enumerate(collect(source))
        if index > offset
            break
        end
        if char == '\n'
            line += 1
        end
    end
    return line
end

@testset "LinkedSpecJulia scaffold" begin
    @test backend_name() == "julia"
    @test cli_entrypoint() == "julia/bin/linkedspec_julia.jl"
    @test corpus_runner_entrypoint() == "julia/bin/corpus_runner.jl"

    status = backend_status()
    @test status.backend == "julia"
    @test status.package == "LinkedSpecJulia"
    @test status.parity == "runtime-hash-helpers"

    cli_output = IOBuffer()
    cli_error = IOBuffer()
    @test run_cli(["--help"]; io = cli_output, err = cli_error) == 0
    @test occursin("LinkedSpec Julia backend", String(take!(cli_output)))
    @test isempty(String(take!(cli_error)))

    status_output = IOBuffer()
    @test run_cli(["status"]; io = status_output, err = IOBuffer()) == 0
    @test occursin("parity: runtime-hash-helpers", String(take!(status_output)))

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

@testset "Action AST parser" begin
    block = parse_action_block(
        "set(array(results), []); push(array(results), retv)\n" *
        "return(copy(array(results)))",
    )
    @test block.kind == "action_block"
    @test length(block.statements) == 3
    @test all(statement -> statement.drops_value, block.statements)
    @test block.statements[1].expr isa ActionCallExpr
    @test block.statements[1].expr.name == "set"
    @test block.statements[1].expr.args[1].value isa ActionCallExpr
    @test block.statements[1].expr.args[2].value isa ActionArrayLiteralExpr
    @test block.statements[2].expr.name == "push"
    @test block.statements[2].expr.args[2].value isa ActionVariableExpr

    @test parse_action_expression("42") isa ActionNumberLiteralExpr
    @test parse_action_expression("true") isa ActionBooleanLiteralExpr
    @test parse_action_expression("undef") isa ActionUndefExpr
    @test parse_action_expression("/a\\\\sb/i") isa ActionRegexLiteralExpr

    nested = parse_action_expression("foo[\"a\"][i][0]")
    @test nested isa ActionNestedAccessExpr
    @test nested.base == "foo"
    @test [segment.kind for segment in nested.segments] == ["key", "index", "index"]

    array = parse_action_expression("[value, true, []]")
    @test array isa ActionArrayLiteralExpr
    @test [item.kind for item in array.items] == ["variable", "boolean", "array_literal"]

    hash = parse_action_expression("{ key : value, \"fixed\" : [value] }")
    @test hash isa ActionHashLiteralExpr
    @test hash.entries[1].key isa ActionVariableExpr
    @test hash.entries[2].key isa ActionStringLiteralExpr
    @test hash.entries[2].value isa ActionArrayLiteralExpr
    @test parse_action_expression("{ key => value }") isa ActionRawExpr
    @test parse_action_expression("{ key => value }").reason == "hash_literal_use_colon"

    assignment = parse_action_expression("items = [value]")
    @test assignment isa ActionAssignScalarExpr
    @test assignment.name == "items"
    @test assignment.value isa ActionArrayLiteralExpr

    append = parse_action_expression("items += value")
    @test append isa ActionAssignArrayAppendExpr
    @test append.name == "items"
    @test append.value isa ActionVariableExpr

    hash_assignment = parse_action_expression("meta[key] = { stage : value }")
    @test hash_assignment isa ActionAssignHashIndexExpr
    @test hash_assignment.key isa ActionVariableExpr
    @test hash_assignment.value isa ActionHashLiteralExpr

    nested_assignment = parse_action_expression("payload[\"children\"][0][\"name\"] = value")
    @test nested_assignment isa ActionAssignNestedAccessExpr
    @test length(nested_assignment.segments) == 3

    assignment_chain = parse_action_expression("(items += value).count()")
    @test assignment_chain isa ActionFluentChainExpr
    @test assignment_chain.receiver isa ActionAssignArrayAppendExpr
    @test only(assignment_chain.calls).method == "count"

    call_with_assignment = parse_action_expression("array(items = [value], copy(array(items)))")
    @test call_with_assignment isa ActionCallExpr
    @test call_with_assignment.args[1] isa ActionPositionalArgument
    @test call_with_assignment.args[1].value isa ActionAssignScalarExpr

    chain = parse_action_expression("\" raw \".trim().split(\"-\").count()")
    @test chain isa ActionFluentChainExpr
    @test chain.receiver isa ActionStringLiteralExpr
    @test [call.method for call in chain.calls] == ["trim", "split", "count"]

    with_call = parse_action_expression("with(\"x\") { return(value) }")
    @test with_call isa ActionCallExpr
    @test with_call.trailing_block_arg
    @test with_call.args[end].value isa ActionBlockValueExpr

    receiver_with = parse_action_expression("\"x\".with() { return(value) }")
    @test receiver_with isa ActionFluentChainExpr
    @test only(receiver_with.calls).method == "with"
    @test only(receiver_with.calls).receiver_trailing_block_arg
    @test only(receiver_with.calls).args[1].value isa ActionBlockValueExpr

    print_call = parse_action_expression("print(\"begin_end_blocks: BEGIN   (\", entry_text(), \"\\n\")")
    @test print_call isa ActionCallExpr
    @test print_call.name == "print"
    @test length(print_call.args) == 3
    @test print_call.args[1].value isa ActionStringLiteralExpr

    block_value = parse_action_expression("{ set(x, \"a\"); x }")
    @test block_value isa ActionBlockValueExpr
    @test length(block_value.block.statements) == 2
    @test block_value.block.statements[end].expr isa ActionVariableExpr

    if_node = parse_action_expression("if(flag) { set(out, \"yes\") }")
    @test if_node isa ActionControlIfExpr
    @test if_node.keyword == "if"
    @test if_node.condition isa ActionVariableExpr
    @test only(if_node.body.statements).expr isa ActionCallExpr

    branch_block = parse_action_block(
        "if(false) { set(out, \"bad\") } " *
        "elseif(true) { set(out, \"yes\") } " *
        "else { set(out, \"no\") }",
    )
    @test [statement.expr.kind for statement in branch_block.statements] == [
        "control_if",
        "control_if",
        "control_else",
    ]
    @test branch_block.statements[2].expr.branch_role == "elseif"

    while_node = parse_action_expression("while(flag) { next() }")
    @test while_node isa ActionControlWhileExpr
    @test while_node.condition isa ActionVariableExpr
    @test only(while_node.body.statements).expr isa ActionCallExpr

    switch_node = parse_action_expression(
        "switch(kind) { case(\"a\") { return(\"hit\") } default { return(\"miss\") } }",
    )
    @test switch_node isa ActionControlSwitchExpr
    @test switch_node.source_expr isa ActionVariableExpr
    @test length(switch_node.cases) == 1
    @test switch_node.default_case !== nothing

    raw = parse_action_expression("@invalid")
    @test raw isa ActionRawExpr
    @test raw.reason == "unsupported_expression"
    @test to_json(raw)["kind"] == "raw_perl"
end

@testset "Action contract resolver" begin
    block = parse_action_block(
        "set(out, +(1, 2));\n" *
        "if(gt(out, 0)) { return(cat(\"ok\", out)) }\n" *
        "\" x \".trim().with() { return(value) }",
    )
    resolution = resolve_action_block_contracts(block)

    @test resolution.ok
    @test all(name -> name in _canonical_names(resolution), ["set", "num_add", "if", "num_gt"])
    @test all(name -> name in _canonical_names(resolution), ["return", "cat", "trim", "with"])

    add_contract = _action_contract(resolution, "+")
    @test add_contract.canonical_name == "num_add"
    @test add_contract.family == "numeric"
    @test canonicalized(add_contract)

    gt_contract = _action_contract(resolution, "gt")
    @test gt_contract.canonical_name == "num_gt"
    @test gt_contract.positional_arg_count == 2

    assignments = resolve_action_block_contracts(parse_action_block(
        "name = \"ok\"; items += name; meta[name] = [name]; " *
        "payload[\"children\"][0][\"name\"] = name",
    ))
    @test assignments.ok
    @test _action_contract(assignments, "=").canonical_name == "set"
    @test _action_contract(assignments, "+=").canonical_name == "push"
    @test _action_contract(assignments, "[]=").canonical_name == "set_key"
    @test _action_contract(assignments, "nested_access=").canonical_name == "nested_access_assignment"

    unknown = resolve_action_block_contracts(parse_action_block("unknown_helper(value); @invalid"))
    @test !unknown.ok
    @test _diagnostic_codes(unknown) == ["unknown_helper", "raw_perl"]
    @test unknown.diagnostics[1].helper_name == "unknown_helper"
    @test occursin("canonical ActionIR helper contract", unknown.diagnostics[1].message)

    @test is_known_action_ir_call_name("cat")
    @test is_known_action_ir_call_name("gt")
    @test is_known_action_ir_call_name("push_back")
    @test is_known_action_ir_call_name("sorted_keys")
    @test is_known_action_ir_call_name("save_cursor")
    @test is_known_action_ir_call_name("restore_cursor")
    @test is_known_action_ir_call_name("rewind_match_start")
    @test is_known_action_ir_call_name("rewind_entry_start")
    @test is_known_action_ir_call_name("entry_end_line")
    @test is_known_action_ir_call_name("match_end_line")
    @test is_known_action_ir_call_name("capture_until_boundary")
    @test !is_known_action_ir_call_name("BACKTRACK")
    @test !is_known_action_ir_call_name("IBACKTRACK")
    @test !is_known_action_ir_call_name("mystery_helper")
    @test canonical_action_helper_name(">=") == "num_ge"

    collision = _spec_with_functions([_function_definition("cat", ["value"])])
    @test _throws_validation_message(() -> validate_spec(collision), "built-in helper/control name")
end

@testset "User function registry" begin
    zero_ast = Dict{String,Any}("kind" => "action_block", "statements" => Any[])
    zero = _function_with_body_sidecar(
        "zero",
        String[];
        body_source = "return(\"zero\")",
        body_ast = zero_ast,
        index = 0,
    )
    normalize = _function_with_body_sidecar(
        "normalize",
        ["value"];
        body_source = "return(value.trim())",
        index = 1,
    )
    registry = user_function_registry_from_functions([zero, normalize])

    @test user_function_names(registry) == ["zero", "normalize"]
    @test [job.job_id for job in body_parse_jobs(registry)] == [
        "parse_job:function_body:functions.0.body_source",
        "parse_job:function_body:functions.1.body_source",
    ]

    zero_resolution = resolve_user_function_call(registry, "zero", 0)
    @test zero_resolution.matched
    @test zero_resolution.entry.index == 0
    @test zero_resolution.entry.definition.params == String[]
    @test zero_resolution.entry.definition.body_ast == zero_ast
    @test zero_resolution.entry.definition.body_parse_job.parent_ast_path == [
        "functions",
        "0",
        "body_source",
    ]

    mismatch = resolve_user_function_call(registry, "normalize", 2)
    @test mismatch.name_known
    @test mismatch.arity_mismatch
    @test mismatch.expected_arities == [1]

    missing = resolve_user_function_call(registry, "missing", 0)
    @test !missing.name_known

    encoded = to_json(registry)
    @test encoded["functions"] isa Vector
    @test encoded["body_parse_jobs"] isa Vector

    spec = SpecFile(functions = [zero, normalize], rules = [
        Rule(
            header = RuleHeader("Top", true, default_rule_mode(), "", 1),
            body = [BodyElement(RegexBodyElementKind("x"), "/x/", 2)],
        ),
    ])
    stitched_ast = Dict{String,Any}("kind" => "action_block", "statements" => [Dict("kind" => "action_stmt")])
    stitched = stitch_function_body_ast(
        spec,
        "parse_job:function_body:functions.1.body_source",
        stitched_ast,
    )
    @test stitched.functions[1].body_ast == zero_ast
    @test stitched.functions[2].body_ast == stitched_ast
    @test spec.functions[2].body_ast === nothing

    @test_throws UserFunctionRegistryException user_function_registry_from_functions([
        _function_with_body_sidecar("dup", ["value"], index = 0),
        _function_with_body_sidecar("dup", ["other"], index = 1),
    ])

    block = parse_action_block(
        "return(normalize(\" x \")); normalize(\"x\", \"y\"); mystery(\"z\")",
    )
    resolution = resolve_action_block_contracts(block; function_registry = registry)
    user_contract = _action_contract(resolution, "normalize")
    @test user_contract.family == "user_function"
    @test user_contract.canonical_name == "normalize"
    @test user_contract.positional_arg_count == 1
    @test _diagnostic_codes(resolution) == ["user_function_arity_mismatch", "unknown_helper"]
    @test occursin("expects arity 1, got 2", resolution.diagnostics[1].message)
end

@testset "Compiled spec state" begin
    parsed = parse_spec(raw"""
Top::
 /x/ -> Child { return(normalize(entry_text())) }
 I { set(out, "start") }
 E.return(out)

Child:
 /[a-z]+/
""")
    normalize = _function_with_body_sidecar(
        "normalize",
        ["value"];
        body_source = "return(value)",
        body_ast = to_json(parse_action_block("return(value)")),
        index = 0,
    )
    spec = SpecFile(functions = [normalize], rules = parsed.rules)
    compiled = compile_spec(spec)

    @test compiled.definition_order == ["Top", "Child"]
    @test compiled.compiled_rule_order == ["Top", "Child"]
    @test isempty(compiled.redefined_rule_labels)
    @test user_function_names(compiled.function_registry) == ["normalize"]
    @test compiled_functions(compiled)[1].definition.name == "normalize"

    top = compiled_rule(compiled, "Top")
    @test top !== nothing
    @test top.regex_patterns == ["x"]
    @test top.mode_metadata.name == "Default"
    @test top.mode_metadata.is_top
    @test !top.mode_metadata.is_and
    @test top.dependency_refs[1].label == "Child"
    @test top.dependency_refs[1].index == 0
    @test [payload.lifecycle for payload in top.lifecycle_action_payloads] == ["I", "E"]
    @test length(action_payloads(top)) == 3

    edge_payload = top.action_edges[1].action_payload
    @test edge_payload !== nothing
    @test length(edge_payload.action_ast.statements) == 1
    @test any(
        contract -> contract.family == "user_function" && contract.canonical_name == "normalize",
        edge_payload.contracts.contracts,
    )

    dependency_entry = compiled.dependency_regex_state.dependency_regex_map["Top"]
    @test dependency_entry.patterns == ["[a-z]+"]
    @test combined_pattern(dependency_entry) == "(?:[a-z]+)"

    encoded = to_json(compiled)
    @test encoded["kind"] == "compiled_spec_state"
    @test encoded["function_order"] == ["normalize"]
    @test haskey(encoded["rules_by_label"], "Top")

    descriptor = to_descriptor_json(compiled)
    @test sort(collect(keys(descriptor))) == ["dependency_regex_map", "functions", "meta", "spec"]
    descriptor_top = descriptor["spec"]["Top"]
    @test descriptor_top["handler"]["kind"] == "julia_interpreter_rule"
    @test descriptor_top["handler"]["status"] == "compiled_state_only"
    @test descriptor_top["dependency_refs"] == [Dict{String,Any}("label" => "Child", "idx" => 0)]
    @test descriptor["meta"]["descriptor_model"] == "compiled_descriptor_state"
    @test descriptor["meta"]["compiled_rule_order"] == ["Top", "Child"]
    @test descriptor["meta"]["function_order"] == ["normalize"]
    @test descriptor["meta"]["function_count"] == 1
    @test descriptor["functions"]["normalize"]["body_ast"]["kind"] == "action_block"
    @test descriptor["dependency_regex_map"]["Top"]["patterns"] == ["[a-z]+"]

    edge_compiled = compile_spec(parse_spec(raw"""
Top::
 /z/ -> Anchored { return(match_text()) }
 -> Child .push

Anchored: /z/
Child: /c/
Pair: /\[/ /\]/
 -> Other .push
 -> Pair[1] .return(array("pair"))

Other: /x/
"""))
    top_edges = compiled_rule(edge_compiled, "Top").action_edges
    @test [
        (edge.targets[1].label, edge.regex_index, edge.child_regex_index, edge.has_parent_regex)
        for edge in top_edges
    ] == [("Anchored", 0, 0, true), ("Child", 1, 0, false)]
    pair_edges = compiled_rule(edge_compiled, "Pair").action_edges
    @test compiled_rule(edge_compiled, "Pair").regex_patterns == ["\\[", "\\]", "x"]
    @test [
        (edge.targets[1].label, edge.regex_index, edge.child_regex_index, edge.has_parent_regex)
        for edge in pair_edges
    ] == [("Other", 2, 0, false), ("Pair", 1, 1, false)]

    first = Rule(
        header = RuleHeader("Top", true, default_rule_mode(), "", 1),
        body = [BodyElement(RegexBodyElementKind("first"), "/first/", 2)],
    )
    second = Rule(
        header = RuleHeader("Top", true, default_rule_mode(), "", 4),
        body = [BodyElement(RegexBodyElementKind("second"), "/second/", 5)],
    )
    duplicate = compile_spec(SpecFile(rules = [first, second]); validate_source = false)
    @test duplicate.definition_order == ["Top", "Top"]
    @test duplicate.compiled_rule_order == ["Top"]
    @test duplicate.redefined_rule_labels == ["Top"]
    @test compiled_rule(duplicate, "Top").regex_patterns == ["second"]

    missing = parse_spec("Top::\n -> Ghost")
    @test _throws_validation_message(() -> compile_spec(missing), "undefined rule")
    @test _throws_compiled_spec_message(
        () -> compile_spec(missing; validate_source = false),
        "undefined rule 'Ghost'",
    )
end

@testset "Runtime regex matching state" begin
    @test parse_mode_from_name("seek") == SeekParseMode
    @test parse_mode_from_name("consume") == ConsumeParseMode
    @test parse_mode_name(SeekParseMode) == "seek"
    @test to_json(ConsumeParseMode) == "consume"
    @test_throws RuntimeRegexException parse_mode_from_name("scan")
    @test_throws RuntimeRegexException RuntimeRegexAlternation(["("])

    alternation = RuntimeRegexAlternation(["cat", "dog"])
    @test length(alternation) == 2
    @test !isempty(alternation)
    @test to_json(alternation)["patterns"] == ["cat", "dog"]

    seek = runtime_match(alternation, "xx dog cat", 0; parse_mode = SeekParseMode)
    @test seek !== nothing
    @test seek.alternative_index == 1
    @test seek.pattern == "dog"
    @test match_text(seek) == "dog"
    @test seek.codeunit_start == 3

    @test runtime_match(alternation, "xx dog cat", 0; parse_mode = "consume") === nothing
    consume = consume_match(alternation, "dog cat", 0)
    @test consume !== nothing
    @test consume.alternative_index == 1
    @test match_text(consume) == "dog"

    tie = RuntimeRegexAlternation(["c.t", "cat"])
    @test seek_match(tie, "cat", 0).alternative_index == 0
    @test isempty(RuntimeRegexAlternation(String[]))

    compiled = compile_spec(parse_spec("Top::\n /cat/ /dog/"))
    compiled_alternation = RuntimeRegexAlternation(compiled_rule(compiled, "Top"))
    compiled_match = seek_match(compiled_alternation, "xx dog cat", 0)
    @test compiled_match.alternative_index == 1
    @test compiled_match.pattern == "dog"

    capture_input = "e🙂 abc-42"
    capture_match = seek_match(
        RuntimeRegexAlternation([raw"(?P<word>[a-z]+)-(a)?(\d+)()"]),
        capture_input,
        0,
    )
    @test match_text(capture_match) == "abc-42"
    @test capture_match.groups == ["abc-42", "abc", "", "42", ""]
    @test capture_match.captures == ["abc", "42", ""]
    @test named_capture(capture_match, "word") == "abc"
    @test capture_match.codeunit_start == 6
    @test capture_match.codeunit_end == 12
    @test codeunit_length(capture_match) == 6
    @test char_start(capture_match) == 3
    @test char_end(capture_match) == 9
    @test char_length(capture_match) == 6
    @test to_json(match_start_line_column(capture_match)) == Dict{String,Any}(
        "line" => 1,
        "column" => 4,
    )
    @test to_json(capture_match)["captures"] == ["abc", "42", ""]
    @test !is_zero_width(capture_match)

    @test named_capture(
        consume_match(RuntimeRegexAlternation([raw"(?<word>[a-z]+)"]), "name", 0),
        "word",
    ) == "name"
    @test match_text(
        consume_match(RuntimeRegexAlternation([raw"[[:alpha:]]+"]), "Name", 0),
    ) == "Name"
    @test match_text(
        consume_match(RuntimeRegexAlternation([raw"(?i)name"]), "NAME", 0),
    ) == "NAME"
    @test match_text(
        consume_match(RuntimeRegexAlternation([raw"(?i:name)"]), "NAME", 0),
    ) == "NAME"
    @test match_text(
        consume_match(RuntimeRegexAlternation([raw"\w++\s+[^}]++"]), "name value", 0),
    ) == "name value"
    @test match_text(
        consume_match(
            RuntimeRegexAlternation([raw"(\[(?:[^\[\]]++|(?R))+\])"]),
            "[x [y] z]",
            0,
        ),
    ) == "[x [y] z]"

    register_input = "parent child"
    parent_match = consume_match(RuntimeRegexAlternation(["parent", "child"]), register_input, 0)
    parent_registers = with_local_match(RuntimeMatchRegisters(register_input), parent_match)
    child_entry = enter_child(parent_registers)
    @test match_text(child_entry.entry_match) == "parent"
    @test child_entry.local_match === nothing
    @test child_entry.capture_start_codeunit == parent_match.codeunit_end

    child_match = consume_match(
        RuntimeRegexAlternation(["parent", "child"]),
        register_input,
        ncodeunits("parent "),
    )
    child_registers = with_local_match(child_entry, child_match)
    @test match_text(child_registers.entry_match) == "parent"
    @test match_text(child_registers.local_match) == "child"
    @test match_text(parent_registers.local_match) == "parent"

    cursor_input = "a\n🙂b"
    cursor_codeunit = char_offset_to_codeunit_offset(cursor_input, 3)
    @test cursor_codeunit == 6
    @test codeunit_offset_to_char_offset(cursor_input, cursor_codeunit) == 3
    cursor_registers = RuntimeMatchRegisters(cursor_input; cursor_codeunit = cursor_codeunit)
    @test cursor_char_offset(cursor_registers) == 3
    @test to_json(cursor_line_column(cursor_registers)) == Dict{String,Any}(
        "line" => 2,
        "column" => 2,
    )

    empty_match = consume_match(RuntimeRegexAlternation([""]), cursor_input, 1)
    @test is_zero_width(empty_match)
    @test is_zero_progress_from(empty_match, 1)
    @test !made_progress_from(empty_match, 1)

    advanced_match = seek_match(RuntimeRegexAlternation(["🙂"]), cursor_input, 0)
    advanced_registers = with_local_match(RuntimeMatchRegisters(cursor_input), advanced_match)
    @test !zero_progress_since(advanced_registers, 0)
    @test reindex_runtime_regex_match(advanced_match, 7).alternative_index == 7
    @test with_cursor_codeunit(advanced_registers, 0).cursor_codeunit == 0
    @test with_capture_start_codeunit(advanced_registers, 0).capture_start_codeunit == 0
    @test_throws ArgumentError RuntimeMatchRegisters(cursor_input; cursor_codeunit = 3)
    @test_throws ArgumentError with_local_match(
        RuntimeMatchRegisters("other"),
        advanced_match,
    )
end

@testset "Runtime rule interpreter" begin
    runtime_engine(source; parse_mode = SeekParseMode, max_iterations = 10_000) =
        LinkedSpecRuntimeEngine(
            compile_spec(parse_spec(source));
            parse_mode = parse_mode,
            max_iterations = max_iterations,
        )

    repetition = runtime_engine(raw"""
Top::
 I { set(array(words), []) }
 /hello[ \t]+(\w+)/
 LE { push(array(words), match_group(0)) }
 E { return(copy(array(words))) }
""")
    repetition_result = runtime_parse(repetition, "hello one hello two")
    @test repetition_result.matched
    @test repetition_result.value == Any["one", "two"]
    @test repetition_result.output == Any[Any["one", "two"]]
    @test repetition_result.cursor_codeunit == ncodeunits("hello one hello two")
    @test repetition_result.cursor_char_offset == length("hello one hello two")
    @test [event.lifecycle for event in repetition_result.lifecycle_events] == ["I", "LE", "LE", "E"]
    @test to_json(repetition_result)["output"] == Any[Any["one", "two"]]

    action_edge = runtime_engine(raw"""
top::
 -> item .push
 E { return(copy(array(top))) }

item:
 /x/
 I { return(entry_text()) }
""")
    action_result = runtime_execute(action_edge, "xx")
    @test action_result.value == Any["x", "x"]
    @test action_result.cursor_codeunit == 2

    explicit_call = runtime_engine(raw"""
Top::
 -> Item { return(call(Item)) }

Item:
 /x/
 I { return(entry_text()) }
""")
    @test runtime_parse(explicit_call, "x").value == "x"

    action_retv = runtime_engine(raw"""
Top::
 I { set(array(out), []) }
 -> A { push(array(out), retv) }
 -> B { push(array(out), retv) }
 E { return(copy(array(out))) }

A: /a/ I { return("A") }
B: /b/ I { return("B") }
""")
    @test runtime_parse(action_retv, "ab").value == Any["A", "B"]

    passive_child = runtime_engine(raw"""
Top::
 -> Item
 E { return(match_text()) }

Item: /x/
""")
    passive_result = runtime_parse(passive_child, "x")
    @test passive_result.value == "x"
    @test passive_result.cursor_codeunit == 1

    blind_and = runtime_engine(raw"""
Top::AND
 I { set(array(log), []) }
 => ChildA { push(array(log), retv) }
 => ChildB { push(array(log), retv) }
 E { return(copy(array(log))) }

ChildA:
 /a/
 E { return("A") }

ChildB:
 /[ \t]+b/
 E { return("B") }
""")
    blind_and_result = runtime_parse(blind_and, "a b")
    @test blind_and_result.value == Any["A", "B"]
    @test blind_and_result.cursor_codeunit == 3

    blind_or = runtime_engine(raw"""
Top::OR
 => ChildA
 => ChildB
 LX { return("or-miss") }
 E { return("unexpected") }

ChildA::
 I { return_undef() }
 /never/

ChildB::
 I { return_undef() }
 /never/
""")
    blind_or_result = runtime_parse(blind_or, "c")
    @test blind_or_result.value == "or-miss"
    @test [event.lifecycle for event in blind_or_result.lifecycle_events] == ["I", "I", "LX"]

    bounded_or = runtime_engine(raw"""
Top::OR{2,3}
 I { set(array(out), []) }
 /a/ -> A { push(array(out), match_text()) }
 /b/ -> B { push(array(out), match_text()) }
 E { return(copy(array(out))) }

A: /a/
B: /b/
""")
    bounded_result = runtime_parse(bounded_or, "abab")
    @test bounded_result.value == Any["a", "b", "a"]
    @test bounded_result.cursor_codeunit == 3

    zero_width = runtime_engine(raw"""
Top::OR+
 I { set(array(iters), []) }
 /x*/
 LE { push(array(iters), "i") }
 E { return(copy(array(iters))) }
""")
    zero_width_result = runtime_parse(zero_width, "abc")
    @test zero_width_result.value == Any["i"]
    @test zero_width_result.cursor_codeunit == 0

    lifecycle = runtime_engine(raw"""
Top::OR{1}
 I { push(array(events), "I") }
 LS { push(array(events), "LS") }
 /a/
 LE { push(array(events), "LE") }
 IT { push(array(events), "IT") }
 EX { push(array(events), "EX") }
 LX { push(array(events), "LX") }
 E { return(copy(array(events))) }
""")
    lifecycle_result = runtime_parse(lifecycle, "a")
    @test lifecycle_result.value == Any["I", "LS", "LE", "IT", "EX", "LX"]
    @test [event.lifecycle for event in lifecycle_result.lifecycle_events] ==
        ["I", "LS", "LE", "IT", "EX", "LX", "E"]
    @test to_json(first(lifecycle_result.lifecycle_events)) == Dict{String,Any}(
        "rule_label" => "Top",
        "lifecycle" => "I",
        "line" => 2,
    )

    consume_and = runtime_engine(
        raw"""
Top::AND
 /ab/
 /cd/
 E { return(match_text()) }
""";
        parse_mode = "consume",
    )
    consume_result = runtime_parse(consume_and, "abcd")
    @test consume_result.value == "cd"
    @test consume_result.cursor_codeunit == 4

    shaped = runtime_engine(raw"""
Top::
 /x/
 E { return(array("ok", array(1, true, undef))) }
""")
    @test runtime_parse(shaped, "x").value == Any["ok", Any[1, true, nothing]]

    recursion_guard = runtime_engine(raw"""
Loop::OR
 /x*/
 => Loop
""")
    recursion_result = runtime_parse(recursion_guard, "x")
    @test !recursion_result.matched
    @test recursion_result.value === nothing
    @test recursion_result.cursor_codeunit == 0

    below_minimum = runtime_engine(raw"""
Top::OR{2}
 /a/
""")
    @test_throws RuntimeInterpreterException runtime_parse(below_minimum, "a")

    unsupported = runtime_engine(raw"""
Top::
 /x/
 E { unknown_runtime_helper(match_text()) }
""")
    @test_throws RuntimeInterpreterException runtime_parse(unsupported, "x")
    @test_throws RuntimeInterpreterException runtime_parse(repetition, "x"; top_rule = "Missing")
    @test_throws ArgumentError LinkedSpecRuntimeEngine(repetition.compiled_spec; max_iterations = 0)
end

@testset "Runtime core value stores and capture helpers" begin
    runtime_engine(source; parse_mode = SeekParseMode) =
        LinkedSpecRuntimeEngine(compile_spec(parse_spec(source)); parse_mode = parse_mode)

    typed_stores = runtime_engine(raw"""
Top::
 /x/
 E {
   set(value, "ok")
   set(array(items), ["a"])
   items += value
   set(hash(meta), { "k" : "v" })
   meta["n"] = 2
   payload = { "children" : [ { "name" : "zero" }, { "name" : value } ] }
   return(hash(
     "scalar", value,
     "items", copy(array(items)),
     "bare_items", items,
     "meta", copy(hash(meta)),
     "bare_meta", meta,
     "name", payload["children"][1]["name"],
     "shapes", array(undef, false, 3, 2.5)
   ))
 }
""")
    @test runtime_parse(typed_stores, "x").value == Dict{String,Any}(
        "scalar" => "ok",
        "items" => Any["a", "ok"],
        "bare_items" => Any["a", "ok"],
        "meta" => Dict{String,Any}("k" => "v", "n" => 2),
        "bare_meta" => Dict{String,Any}("k" => "v", "n" => 2),
        "name" => "ok",
        "shapes" => Any[nothing, false, 3, 2.5],
    )

    variable_shapes = runtime_engine(raw"""
Top::
 /x/
 E {
   value = "ok"
   items = [value, "tail"]
   meta = { "key" : value }
   key = "key"
   return(array(
     items[0],
     copy(items),
     copy(array(items)),
     meta[key],
     hash(meta),
     copy(hash(meta))
   ))
 }
""")
    @test runtime_parse(variable_shapes, "x").value == Any[
        "ok",
        Any["ok", "tail"],
        Any["ok", "tail"],
        "ok",
        Dict{String,Any}("key" => "ok"),
        Dict{String,Any}("key" => "ok"),
    ]

    nested_writes = runtime_engine(raw"""
Top::
 /x/
 E {
   payload = { "items" : [{ "name" : "old" }] }
   root_array = [{ "name" : "old" }]
   return(array(
     payload["items"][0]["name"] = "new",
     payload["items"][1] = "tail",
     payload,
     payload["items"][3] = "gap",
     payload["missing"][0] = "bad",
     payload["items"][0][0] = "bad",
     root_array[0]["name"] = "changed",
     root_array[1] = { "name" : "tail" },
     root_array["bad"] = { "name" : "bad" },
     root_array
   ))
 }
""")
    updated_payload_once = Dict{String,Any}(
        "items" => Any[Dict{String,Any}("name" => "new")],
    )
    updated_payload = Dict{String,Any}(
        "items" => Any[Dict{String,Any}("name" => "new"), "tail"],
    )
    updated_root_once = Any[Dict{String,Any}("name" => "changed")]
    updated_root = Any[
        Dict{String,Any}("name" => "changed"),
        Dict{String,Any}("name" => "tail"),
    ]
    @test runtime_parse(nested_writes, "x").value == Any[
        updated_payload_once,
        updated_payload,
        updated_payload,
        nothing,
        nothing,
        nothing,
        updated_root_once,
        updated_root,
        nothing,
        updated_root,
    ]

    captures = runtime_engine(raw"""
Top::
 /(?<name>\w+)=(\d+)/
 E {
   return(hash(
     "entry_text", entry_text(),
     "match_text", match_text(),
     "entry_groups", entry_groups(),
     "match_group_1", match_group(1),
     "entry_named", entry_named(name),
     "match_named", match_named(name),
     "entry_has", entry_has(name),
     "match_has", match_has(name),
     "entry_map", entry_map(),
     "match_map", match_map(),
     "entry_len", entry_len(),
     "match_len", match_len(),
     "entry_start", entry_start_pos(),
     "entry_end", entry_end_pos(),
     "match_start", match_start_pos(),
     "match_end", match_end_pos(),
     "entry_line", entry_line(),
     "entry_col", entry_col(),
     "entry_end_line", entry_end_line(),
     "entry_end_col", entry_end_col(),
     "match_line", match_line(),
     "match_col", match_col(),
     "match_end_line", match_end_line(),
     "match_end_col", match_end_col()
   ))
 }
""")
    @test runtime_parse(captures, "🙂\n key=42").value == Dict{String,Any}(
        "entry_text" => "key=42",
        "match_text" => "key=42",
        "entry_groups" => Any["key", "42"],
        "match_group_1" => "42",
        "entry_named" => "key",
        "match_named" => "key",
        "entry_has" => true,
        "match_has" => true,
        "entry_map" => Dict{String,Any}("name" => "key"),
        "match_map" => Dict{String,Any}("name" => "key"),
        "entry_len" => 6,
        "match_len" => 6,
        "entry_start" => 3,
        "entry_end" => 9,
        "match_start" => 3,
        "match_end" => 9,
        "entry_line" => 2,
        "entry_col" => 2,
        "entry_end_line" => 2,
        "entry_end_col" => 8,
        "match_line" => 2,
        "match_col" => 2,
        "match_end_line" => 2,
        "match_end_col" => 8,
    )
end

@testset "Runtime string scalar and numeric helpers" begin
    runtime_engine(source) = LinkedSpecRuntimeEngine(compile_spec(parse_spec(source)))

    string_helpers = runtime_engine(raw"""
Top::
 /(.+)/
 E {
   raw = entry_group(0)
   set(array(tmp), ["x"])
   missing = tmp[5]
   return(hash(
     "cat", cat("A", undef, "B"),
     "trim", trim(raw),
     "chain", raw.trim().lowercase().replace_substr("-", "_").rm_suffix("_end"),
     "substr", substr(trim(raw), 1, 3),
     "contains", contains_substr(raw, "-B-"),
     "starts", starts_with(trim(raw), "A"),
     "ends", ends_with(trim(raw), "END"),
     "matches", matches(trim(raw), /^A/),
     "flagged_match", matches("AbC", /^abc$/i),
     "split", raw.trim().split("-"),
     "coalesce", coalesce(missing, "fallback"),
     "coalesce_nonempty", coalesce_nonempty("", "filled"),
     "defined", is_defined(""),
     "undefined", is_undefined(missing),
     "empty", is_empty(""),
     "nonempty", is_nonempty("x"),
     "empty_array", is_empty(array()),
     "nonempty_hash", is_nonempty(hash("k", "v")),
     "unicode_length", length("🙂a"),
     "unicode_substr", substr("🙂ab", 1, 2),
     "str_eq", str_eq("a", "a"),
     "str_ne", str_ne("a", "b"),
     "str_lt", str_lt("a", "b"),
     "str_ge", str_ge("b", "b")
   ))
 }
""")
    @test runtime_parse(string_helpers, " A-B-END ").value == Dict{String,Any}(
        "cat" => "AB",
        "trim" => "A-B-END",
        "chain" => "a_b",
        "substr" => "-B-",
        "contains" => true,
        "starts" => true,
        "ends" => true,
        "matches" => true,
        "flagged_match" => true,
        "split" => Any["A", "B", "END"],
        "coalesce" => "fallback",
        "coalesce_nonempty" => "filled",
        "defined" => true,
        "undefined" => true,
        "empty" => true,
        "nonempty" => true,
        "empty_array" => true,
        "nonempty_hash" => true,
        "unicode_length" => 2,
        "unicode_substr" => "ab",
        "str_eq" => true,
        "str_ne" => true,
        "str_lt" => true,
        "str_ge" => true,
    )

    numeric_helpers = runtime_engine(raw"""
Top::
 /x/
 E {
   scores += 1
   scores += 5
   scores += 3
   scores += 5
   return(hash(
     "symbol_add", +(2, *(3, 4)),
     "sub", sub(10, 3, 2),
     "div", num_div(7, 2),
     "mod", 17.mod(5),
     "abs_floor", -3.2.abs().floor(),
     "ceil", ceil(3.2),
     "clamp", num_clamp(42, 0, 10),
     "gt", gt(10, 2),
     "le", <=(2, 2),
     "round", 3.5.round(),
     "half_round", round(2.5),
     "sum", sum(array(2, 4, 6)),
     "range", num_range(array(3, 9, 1, 7)),
     "avg", avg(array(2, 4, 6)),
     "median", median(array(5, 1, 4, 2)),
     "minimum", min(array(8, 3, 5, 1)),
     "bare_min", min(scores),
     "bare_max", max(scores),
     "bad_div", num_div(5, 0),
     "bad_mod", num_mod(5.5, 2),
     "bad_number", num_add("x", 1)
   ))
 }
""")
    @test runtime_parse(numeric_helpers, "x").value == Dict{String,Any}(
        "symbol_add" => 14,
        "sub" => 5,
        "div" => 3.5,
        "mod" => 2,
        "abs_floor" => 3,
        "ceil" => 4,
        "clamp" => 10,
        "gt" => true,
        "le" => true,
        "round" => 4,
        "half_round" => 3,
        "sum" => 12,
        "range" => 8,
        "avg" => 4,
        "median" => 3,
        "minimum" => 1,
        "bare_min" => 1,
        "bare_max" => 5,
        "bad_div" => nothing,
        "bad_mod" => nothing,
        "bad_number" => nothing,
    )
end

@testset "Runtime array helpers and mutations" begin
    runtime_engine(source) = LinkedSpecRuntimeEngine(compile_spec(parse_spec(source)))

    array_helpers = runtime_engine(raw"""
Top::
 /x/
 E {
   items += "b"
   items += "a"
   items += "c"
   items += "a"
   phrases += "aa-b"
   phrases += "cc-aa"
   set(array(public), [" x ", "", "Y"])
   return(hash(
     "sorted_drop_first", items.sorted().drop_front(2).first(),
     "reverse_take_last", array(items).reversed().take(2).last(),
     "contains", items.sorted().contains("c"),
     "index", items.sorted().index_of("c"),
     "drop_join", items.drop_back().join_values("|"),
     "uniq_join", items.uniq().join_values(","),
     "filter_count", items.filter_match(/^a$/).count(),
     "split_filter_count", phrases.split_each("-").filter_match(/^aa$/).count(),
     "transform_join", public.trim_each().filter_nonempty().lowercase_each().join_values("|"),
     "take_last", items.take_last(2),
     "slice", items.sorted().slice(1, 2),
     "flat", flat_array(array("p", "q"), "r"),
     "array_flat_splice", array("tag", flat_array(array("p", "q")), "tail"),
     "array_copy_nested", array("tag", copy(array("p", "q"))),
     "concat", concat_arrays(array("x"), array("y", "z")),
     "sum", array(2, 4, 6).sum(),
     "avg", array(2, 4, 6).avg(),
     "source", copy(array(items)),
     "empty_missing", missing.sorted().is_empty()
   ))
 }
""")
    @test runtime_parse(array_helpers, "x").value == Dict{String,Any}(
        "sorted_drop_first" => "b",
        "reverse_take_last" => "c",
        "contains" => true,
        "index" => 3,
        "drop_join" => "b|a|c",
        "uniq_join" => "b,a,c",
        "filter_count" => 2,
        "split_filter_count" => 2,
        "transform_join" => "x|y",
        "take_last" => Any["c", "a"],
        "slice" => Any["a", "b"],
        "flat" => Any["p", "q", "r"],
        "array_flat_splice" => Any["tag", "p", "q", "tail"],
        "array_copy_nested" => Any["tag", Any["p", "q"]],
        "concat" => Any["x", "y", "z"],
        "sum" => 12,
        "avg" => 4,
        "source" => Any["b", "a", "c", "a"],
        "empty_missing" => true,
    )

    array_mutations = runtime_engine(raw"""
Top::
 /x/
 E {
   raw = " left , right,,third "
   split(array(parts), raw, /\s*,\s*/)
   items.push_back("a")
   items.push_back("b")
   items.push_front("z")
   items.pop_back()
   items.pop_front()
   array(items).push_back("c")
   scalar_items = ["s"]
   scalar_items.push_back("t")
   return(hash(
     "parts", copy(array(parts)),
     "receiver_split", "a, b".split(/\s*,\s*/),
     "items", copy(array(items)),
     "scalar_items", scalar_items,
     "value_push", items.push_back("bad"),
     "after_value_push", copy(array(items)),
     "tagged", split_tagged_records("a,b", /,/, "?tag:", "field")
   ))
 }
""")
    @test runtime_parse(array_mutations, "x").value == Dict{String,Any}(
        "parts" => Any[" left", "right", "", "third "],
        "receiver_split" => Any["a", "b"],
        "items" => Any["a", "c"],
        "scalar_items" => Any["s", "t"],
        "value_push" => nothing,
        "after_value_push" => Any["a", "c"],
        "tagged" => Any[Any["?tag:", "a", "field"], Any["?tag:", "b", "field"]],
    )
end

@testset "Runtime hash helpers and mutations" begin
    engine = LinkedSpecRuntimeEngine(compile_spec(parse_spec(raw"""
Top::
 /x/
 E {
   set_key(meta, "b", 2)
   set_key(meta, "a", 1)
   set_key(meta, "drop", 0)
   set_key(hash(meta), "stmt_hash", 4)
   set_key(overlay, "a", 10)
   set_key(overlay, "c", 3)
   value_set = set_key(meta, "value_only", 9)
   receiver_set = meta.set_key("receiver_only", 5)
   return(hash(
     "keys", meta.sorted_keys().join_values(","),
     "values", meta.sorted_values().join_values("|"),
     "count", meta.count_keys(),
     "has_a", meta.has_key("a"),
     "drop_pick", meta.drop_keys("drop").pick_keys("a", "stmt_hash").sorted_values(),
     "rename", hash(meta).rename_key("a", "aa").drop_keys("drop").set_key("z", 7).sorted_keys().join_values(","),
     "merged", merge_hash(copy(hash(meta)), overlay).sorted_values(),
     "bare_first_merge", merge_hash(meta, overlay).sorted_keys(),
     "value_set_has", value_set.has_key("value_only"),
     "receiver_set_has", receiver_set.has_key("receiver_only"),
     "after_value_set", copy(hash(meta)).has_key("value_only"),
     "after_receiver_set", copy(hash(meta)).has_key("receiver_only"),
     "index_value", meta["expr"] = "E",
     "after_index_value", copy(hash(meta)).has_key("expr"),
     "flat_splice", hash("z", 0, flat(hash(meta))).sorted_keys().join_values(","),
     "flat_hash_splice", hash("z", 0, meta.flat_hash()).sorted_keys().join_values(","),
     "map_field", hash("nested", copy(hash(meta))).pick_keys("nested")
   ))
 }
""")))

    @test runtime_parse(engine, "x").value == Dict{String,Any}(
        "keys" => "a,b,drop,stmt_hash",
        "values" => "1|2|0|4",
        "count" => 4,
        "has_a" => true,
        "drop_pick" => Any[1, 4],
        "rename" => "aa,b,stmt_hash,z",
        "merged" => Any[10, 2, 3, 0, 4],
        "bare_first_merge" => Any["a", "c"],
        "value_set_has" => true,
        "receiver_set_has" => true,
        "after_value_set" => false,
        "after_receiver_set" => false,
        "index_value" => Dict{String,Any}(
            "b" => 2,
            "a" => 1,
            "drop" => 0,
            "stmt_hash" => 4,
            "expr" => "E",
        ),
        "after_index_value" => true,
        "flat_splice" => "a,b,drop,expr,stmt_hash,z",
        "flat_hash_splice" => "a,b,drop,expr,stmt_hash,z",
        "map_field" => Dict{String,Any}(
            "nested" => Dict{String,Any}(
                "b" => 2,
                "a" => 1,
                "drop" => 0,
                "stmt_hash" => 4,
                "expr" => "E",
            ),
        ),
    )
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

@testset "User function definition shell projection" begin
    source = join([
        "fn zero() {return(\"zero\")}",
        "Top::",
        " /x/ -> Done { return(zero()) }",
        "",
        "Done:",
        " /[a-z]+/",
        "",
        "fn after(value) { return(value) }",
        "",
    ], "\n")

    nodes = [
        _definition_node(source, "zero", String[], "return(\"zero\")"),
        _definition_node(source, "after", ["value"], " return(value) "),
    ]

    @test _throws_parse_message(
        () -> parse_spec_with_user_function_definition_asts(source, Any[]),
        "rule parse after function extraction failed",
    )

    projection = project_user_function_definition_asts(source, nodes)
    @test [function_definition.name for function_definition in projection.functions] == ["zero", "after"]
    @test length(split(projection.stripped_source, '\n'; keepempty = true)) ==
        length(split(source, '\n'; keepempty = true))
    @test !occursin("fn zero", projection.stripped_source)
    @test occursin("Top::", projection.stripped_source)

    zero = projection.functions[1]
    @test isempty(zero.params)
    @test zero.arity == 0
    @test zero.body_source == "return(\"zero\")"
    @test zero.body_payload["parent_ast_path"] == ["functions", "0", "body_source"]
    @test zero.body_parse_job.parent_ast_path == ["functions", "0", "body_source"]
    @test zero.body_parse_job.job_id ==
        "parse_job:function_body:functions.0.body_source:actionir-body.spec:action_block:11-25"
    @test zero.body_parse_job.version == 1
    @test zero.body_parse_job.function_name == "zero"
    @test zero.body_parse_job.params == String[]
    @test zero.body_parse_job.arity == 0
    @test zero.body_parse_job.diagnostic_owner == "function_body"
    @test zero.body_ast === nothing

    parsed = parse_spec_with_user_function_definition_asts(source, nodes)
    @test validate_spec(parsed) === nothing
    @test length(parsed.functions) == 2
    @test [rule.header.label for rule in parsed.rules] == ["Top", "Done"]

    malformed = Dict{String,Any}(
        "type" => "function_definition_error",
        "kind" => "user_function_definition_error",
        "message" => "invalid user function definition",
        "source_text" => "fn bad(value",
        "source_span" => Dict("start" => 0, "end" => 12, "line_start" => 1, "line_end" => 1),
    )
    @test _throws_parse_message(
        () -> project_user_function_definition_asts("fn bad(value\nTop::\n /x/\n", [malformed]),
        "user function definition parse error at line 1",
    )

    drift = _definition_node("fn zero() {return(\"zero\")}\nTop::\n /x/\n", "zero", String[], "return(\"zero\")")
    drift["body_parse_job"]["text"] = "return(\"drift\")"
    @test _throws_user_function_message(
        () -> project_user_function_definition_asts("fn zero() {return(\"zero\")}\nTop::\n /x/\n", [drift]),
        "body_parse_job text does not match body_source",
    )

    node = Dict{String,Any}("type" => "function_definition")
    @test definition_nodes_from_user_function_definition_output(nothing) == Any[]
    @test definition_nodes_from_user_function_definition_output(Any[]) == Any[]
    @test definition_nodes_from_user_function_definition_output(node) == Any[node]
    @test definition_nodes_from_user_function_definition_output(Any[node]) == Any[node]
    @test definition_nodes_from_user_function_definition_output(Any[Any[node], Any[]]) == Any[node]
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
