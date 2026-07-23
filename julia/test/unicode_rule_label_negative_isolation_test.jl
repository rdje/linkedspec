# FUTURE-PARITY-BACKLOG.10.6.1.3 — negative labels and grammar isolation.

const JULIA_UNICODE_NEGATIVE_FIXTURES = [
    Dict{String,Any}(String(key) => value for (key, value) in pairs(fixture))
    for fixture in JULIA_UNICODE_RULE_LABEL_CONTRACT["negative_fixtures"]
]

function _julia_unicode_negative_error(call)
    try
        call()
    catch error
        return error
    end
    return nothing
end

function _julia_unicode_negative_role_cases(label::AbstractString)
    return [
        (
            role = "declaration",
            owner = nothing,
            line = 1,
            spec = _julia_unicode_spec_with(label, RegexBodyElementKind("x")),
        ),
        (
            role = "edge_target",
            owner = "Root",
            line = 2,
            spec = _julia_unicode_spec_with(
                "Root",
                ActionEdgeBodyElementKind(targets = [EdgeTarget(label = label)]),
            ),
        ),
        (
            role = "edge_target",
            owner = "Root",
            line = 2,
            spec = _julia_unicode_spec_with(
                "Root",
                BlindEdgeBodyElementKind(target = label),
            ),
        ),
        (
            role = "edge_target",
            owner = "Root",
            line = 2,
            spec = _julia_unicode_spec_with(
                "Root",
                BareEdgeBodyElementKind(targets = [BareEdgeTarget(label = label)]),
            ),
        ),
    ]
end

function _julia_unicode_negative_artifact_operations(identity::AbstractString)
    return [
        (name = "validate", call = validate_spec),
        (name = "compile", call = compile_spec),
        (
            name = "descriptor",
            call = spec -> to_descriptor_json(compile_spec(spec)),
        ),
        (
            name = "generated_plan",
            call = spec -> build_generated_rule_plan(compile_spec(spec)),
        ),
        (
            name = "emitted_source",
            call = spec -> emit_julia_source_v2(compile_spec(spec), identity),
        ),
    ]
end

function _julia_unicode_negative_function(name, params)
    return FunctionDefinition(
        name = name,
        params = params,
        arity = length(params),
        body_source = "return(value)",
        source = "fn $name($(join(params, ", "))) { return(value) }",
        source_span = SourceSpan(1, 1),
        body_span = SourceSpan(1, 1),
    )
end

function _julia_unicode_negative_function_spec(functions)
    return SpecFile(
        functions = functions,
        rules = [
            Rule(
                header = RuleHeader("Top", true, default_rule_mode(), "", 1),
                body = [BodyElement(RegexBodyElementKind("x"), "/x/", 2)],
            ),
        ],
    )
end

@testset "every negative label fails every external AST trust and artifact route" begin
    @test length(JULIA_UNICODE_NEGATIVE_FIXTURES) == 8
    operations = _julia_unicode_negative_artifact_operations(
        "unicode-label/negative-artifact.spec",
    )

    for fixture in JULIA_UNICODE_NEGATIVE_FIXTURES
        label = String(fixture["label"])
        fixture_id = String(fixture["id"])
        @test !LinkedSpecJulia.is_rule_label(label)

        for route in _julia_unicode_negative_role_cases(label)
            expected = _julia_unicode_invalid_label_json(
                route.role,
                label,
                route.line;
                owner = route.owner,
            )
            for (trust_name, candidate) in (
                ("programmatic", route.spec),
                ("reconstructed", _julia_unicode_reconstruct(route.spec)),
            )
                for operation in operations
                    error = _julia_unicode_negative_error(
                        () -> operation.call(candidate),
                    )
                    @test error isa SpecValidationException
                    if error isa SpecValidationException
                        @test to_json(error.diagnostic) == expected
                    end
                    @test error !== nothing
                    @test operation.name in (
                        "validate",
                        "compile",
                        "descriptor",
                        "generated_plan",
                        "emitted_source",
                    )
                    @test !isempty("$fixture_id/$trust_name/$(operation.name)")
                end
            end
        end
    end
end

@testset "source no-prefix and newline routes reject complete invalid tokens" begin
    for fixture in JULIA_UNICODE_NEGATIVE_FIXTURES
        label = String(fixture["label"])
        fixture_id = String(fixture["id"])
        @test _julia_unicode_negative_error(
            () -> parse_spec("$label::\n /x/\n"),
        ) isa SpecParseException

        if fixture_id == "newline"
            continue
        end

        for arrow in ("->", "=>")
            source_line = "$arrow $label"
            parsed = parse_spec("Root::\n $source_line\n")
            @test length(parsed.rules) == 1
            @test length(only(parsed.rules).body) == 1
            kind = only(only(parsed.rules).body).kind
            @test kind isa RawBodyElementKind
            if kind isa RawBodyElementKind
                @test kind.text == strip(source_line)
            end
            error = _julia_unicode_negative_error(() -> validate_spec(parsed))
            @test error isa SpecValidationException
            @test occursin("unrecognized body syntax at line 2", sprint(showerror, error))
            @test occursin(strip(source_line), sprint(showerror, error))
        end

        if !isempty(label)
            parsed = parse_spec("Root::\n $label\n")
            @test all(
                !(element.kind isa ActionEdgeBodyElementKind) &&
                !(element.kind isa BlindEdgeBodyElementKind) &&
                !(element.kind isa BareEdgeBodyElementKind)
                for rule in parsed.rules for element in rule.body
            )
            if fixture_id == "colon"
                @test [rule.header.label for rule in parsed.rules] == ["Root", "Top"]
                @test validate_spec(parsed) === nothing
            else
                @test _julia_unicode_negative_error(
                    () -> validate_spec(parsed),
                ) isa SpecValidationException
            end
        end
    end

    no_prefix = raw"$Top"
    @test _julia_unicode_negative_error(
        () -> parse_spec("$no_prefix::\n /x/\n"),
    ) isa SpecParseException
    for source in (
        "Root::\n -> $no_prefix\n",
        "Root::\n => $no_prefix\n",
        "Root::\n $no_prefix\n",
    )
        parsed = parse_spec(source)
        @test [rule.header.label for rule in parsed.rules] == ["Root"]
        @test all(
            !(element.kind isa ActionEdgeBodyElementKind) &&
            !(element.kind isa BlindEdgeBodyElementKind) &&
            !(element.kind isa BareEdgeBodyElementKind)
            for element in only(parsed.rules).body
        )
        @test _julia_unicode_negative_error(
            () -> validate_spec(parsed),
        ) isa SpecValidationException
    end

    split = parse_spec("""
Root::OR
 -> Top
 Rule

Top:
 /x/

Rule:
 /x/
""")
    validate_spec(split)
    root_kinds = [element.kind for element in first(split.rules).body]
    action = only(kind for kind in root_kinds if kind isa ActionEdgeBodyElementKind)
    bare = only(kind for kind in root_kinds if kind isa BareEdgeBodyElementKind)
    @test [(target.label, target.index) for target in action.targets] == [("Top", 0)]
    @test [(target.label, target.index) for target in bare.targets] == [("Rule", nothing)]
end

@testset "selectors loaders and primary commands preserve every exact invalid identity" begin
    valid = compile_spec(parse_spec("Top::\n /x/\n"))
    engine = LinkedSpecRuntimeEngine(valid)
    plan = build_generated_rule_plan(valid)
    identity = "unicode-label/negative-selector.spec"

    for fixture in JULIA_UNICODE_NEGATIVE_FIXTURES
        label = String(fixture["label"])
        native = _julia_unicode_negative_error(
            () -> runtime_parse(engine, "x"; top_rule = label),
        )
        @test native isa RuntimeInterpreterException
        if native isa RuntimeInterpreterException
            @test to_json(native.diagnostic) == Dict{String,Any}(
                "type" => "runtime_parser",
                "stage" => "select_entry_rule",
                "owner_stage" => "julia_runtime",
                "summary" => "Julia runtime entry-rule selection failed",
                "detail" => "entry rule '$label' is not defined",
                "code" => "entry_rule_not_found",
                "top_rule" => label,
                "entry_rule" => label,
                "rule_label" => label,
                "handler_source_label" => "julia_runtime:rule:$label",
            )
        end

        generated = _julia_unicode_negative_error() do
            execute_generated_parser_v2(
                valid,
                plan,
                "x",
                identity;
                top_rule = label,
            )
        end
        @test generated isa GeneratedSourceException
        if generated isa GeneratedSourceException
            @test to_json(generated) == Dict{String,Any}(
                "type" => "generated_source_error",
                "stage" => "select_entry_rule",
                "code" => "entry_rule_not_found",
                "summary" => "Generated Julia parser entry-rule selection failed",
                "source_identity" => identity,
                "entry_rule" => label,
                "rule_label" => label,
                "detail" => "entry rule '$label' is not defined",
            )
        end
    end

    mktempdir() do scratch
        for (index, fixture) in enumerate(JULIA_UNICODE_NEGATIVE_FIXTURES)
            label = String(fixture["label"])
            source = "$label::\n /x/\n"
            filename = "invalid-$index.spec"
            path = joinpath(scratch, filename)
            write(path, source)

            loaded = _julia_unicode_negative_error(
                () -> load_and_compile_spec(
                    path_spec_request(filename),
                    SpecLoadOptions(scratch),
                ),
            )
            @test loaded isa SpecPipelineException
            if loaded isa SpecPipelineException
                @test loaded.stage == ParseSpecStage
                @test loaded.code == SpecParseFailedCode
                @test loaded.requested == filename
                @test loaded.resolved_path == path
                @test loaded.detail !== nothing
                @test !occursin(path, something(loaded.detail, ""))
            end

            for args in (
                ["--inline-spec", source, "--input", "x"],
                ["--spec-file", path, "--input", "x"],
            )
                output = IOBuffer()
                errors = IOBuffer()
                @test run_cli(args; io = output, err = errors) == 1
                @test isempty(String(take!(output)))
                @test String(take!(errors)) ==
                    "linkedspec: parser compilation failed\n"
            end
        end
    end
end

@testset "unrelated identifier grammars retain their existing boundaries" begin
    valid_functions = _julia_unicode_negative_function_spec([
        _julia_unicode_negative_function("_function9", ["value_2"]),
    ])
    validate_spec(valid_functions)

    for name in ("Töp", "9_function", "A·B", "𐐀Rule")
        function_error = _julia_unicode_negative_error(
            () -> validate_spec(_julia_unicode_negative_function_spec([
                _julia_unicode_negative_function(name, ["value"]),
            ])),
        )
        @test function_error isa SpecValidationException
        @test sprint(showerror, function_error) == "invalid user function name '$name'"

        parameter_error = _julia_unicode_negative_error(
            () -> validate_spec(_julia_unicode_negative_function_spec([
                _julia_unicode_negative_function("valid_name", [name]),
            ])),
        )
        @test parameter_error isa SpecValidationException
        @test sprint(showerror, parameter_error) ==
            "user function 'valid_name' has invalid parameter '$name'"
    end

    for (source, expected_name) in (
        ("trim(value)", "trim"),
        ("Töp(value)", "Töp"),
    )
        helper = parse_action_expression(source)
        @test helper isa ActionCallExpr
        if helper isa ActionCallExpr
            @test helper.name == expected_name
        end
    end
    for source in ("A·B(value)", "𐐀Rule(value)")
        helper = parse_action_expression(source)
        @test helper isa ActionRawExpr
        if helper isa ActionRawExpr
            @test helper.reason == "unsupported_expression"
        end
    end

    for source in ("value_2", "Töp")
        variable = parse_action_expression(source)
        @test variable isa ActionVariableExpr
        if variable isa ActionVariableExpr
            @test variable.name == source
        end
    end
    @test parse_action_expression("A·B") isa ActionRawExpr
    @test parse_action_expression("𐐀Rule") isa ActionRawExpr

    for (source, method) in (
        ("\"x\"._method9()", "_method9"),
        ("\"x\".Töp()", "Töp"),
    )
        fluent = parse_action_expression(source)
        @test fluent isa ActionFluentChainExpr
        if fluent isa ActionFluentChainExpr
            @test only(fluent.calls).method == method
        end
    end
    @test parse_action_expression("\"x\".A·B()") isa ActionRawExpr
    @test parse_action_expression("\"x\".𐐀Rule()") isa ActionRawExpr

    valid_assignment = parse_action_expression("value_2 = 1")
    unicode_assignment = parse_action_expression("Töp = 1")
    @test !(valid_assignment isa ActionRawExpr)
    @test !(unicode_assignment isa ActionRawExpr)
    @test parse_action_expression("A·B = 1") isa ActionRawExpr

    lifecycle_markers = ("I", "LS", "LE", "LX", "E", "EX", "IT")
    lifecycle = parse_spec(
        "Root::\n" *
        join((" $marker { return(\"$marker\") }" for marker in lifecycle_markers), "\n") *
        "\n /x/\n",
    )
    @test [
        kind.lifecycle for kind in (element.kind for element in only(lifecycle.rules).body)
        if kind isa CodeBlockBodyElementKind
    ] == collect(lifecycle_markers)
    for marker in ("IX", "Töp", "𐐀Rule")
        parsed = parse_spec("Root::\n $marker { return(\"bad\") }\n /x/\n")
        @test all(
            !(element.kind isa CodeBlockBodyElementKind)
            for element in only(parsed.rules).body
        )
        @test _julia_unicode_negative_error(
            () -> validate_spec(parsed),
        ) isa SpecValidationException
    end

    for (source, expected_type, expected_name) in (
        ("mark_here(shared_9)", ActionVariableExpr, "shared_9"),
        ("mark_here(Töp)", ActionVariableExpr, "Töp"),
        ("mark_here(A·B)", ActionRawExpr, nothing),
    )
        mark = parse_action_expression(source)
        @test mark isa ActionCallExpr
        if mark isa ActionCallExpr
            value = only(mark.args).value
            @test value isa expected_type
            if expected_name !== nothing && value isa ActionVariableExpr
                @test value.name == expected_name
            end
        end
    end

    parsed_mark = parse_spec("Root::\n @mark(Töp)\n /x/\n")
    @test first(only(parsed_mark.rules).body).kind isa SplitMarkerBodyElementKind
    raw_mark = parse_spec("Root::\n @mark(A·B)\n /x/\n")
    @test first(only(raw_mark.rules).body).kind isa RawBodyElementKind

    for pattern in ("Töp", "A·B", "𐐀Rule", "Top-Rule")
        parsed = parse_spec("Top::\n /$pattern/\n")
        validate_spec(parsed)
        regex = only(only(parsed.rules).body).kind
        @test regex isa RegexBodyElementKind
        if regex isa RegexBodyElementKind
            @test regex.pattern == pattern
        end
    end

    bounded = parse_spec("Top::OR{2,3}\n /x/\n")
    @test only(bounded.rules).header.mode == or_bounded_rule_mode(min = 2, max = 3)
    invalid_bounded = parse_spec("Top::OR{2,Töp}\n /x/\n")
    @test only(invalid_bounded.rules).header.mode == default_rule_mode()
    @test only(invalid_bounded.rules).header.rest == "OR{2,Töp}"
    first_kind = first(only(invalid_bounded.rules).body).kind
    @test first_kind isa BareEdgeBodyElementKind
    if first_kind isa BareEdgeBodyElementKind
        @test [target.label for target in first_kind.targets] == ["OR"]
        @test first_kind.code == "2,Töp"
    end
end
