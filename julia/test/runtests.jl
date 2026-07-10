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
    @test status.parity == "compiled-state"

    cli_output = IOBuffer()
    cli_error = IOBuffer()
    @test run_cli(["--help"]; io = cli_output, err = cli_error) == 0
    @test occursin("LinkedSpec Julia backend", String(take!(cli_output)))
    @test isempty(String(take!(cli_error)))

    status_output = IOBuffer()
    @test run_cli(["status"]; io = status_output, err = IOBuffer()) == 0
    @test occursin("parity: compiled-state", String(take!(status_output)))

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
