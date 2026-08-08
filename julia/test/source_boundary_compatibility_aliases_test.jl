# FUTURE-PARITY-BACKLOG.14.2.4.0.1 — Julia source-boundary compatibility aliases.

const JULIA_SOURCE_BOUNDARY_ALIAS_CONTRACT = JSON3.read(
    read(
        joinpath(
            REPO_ROOT,
            "capability_conformance",
            "typed_source_location_contract.json",
        ),
        String,
    ),
    Dict{String,Any},
)

const JULIA_SOURCE_BOUNDARY_ALIASES = Dict{String,String}(
    String(row[1]) => String(row[2])
    for row in JULIA_SOURCE_BOUNDARY_ALIAS_CONTRACT["compatibility_aliases"]
)

const JULIA_SOURCE_BOUNDARY_ALIAS_INPUT = "é🙂  ab"

const JULIA_SOURCE_BOUNDARY_ALIAS_NORMAL = """Top::OR{1,1}
 /(?<name>ab)/
 I { started = capture_slice_here() }
 E {
   return(array(
     started,
     capture_from_rule_start(),
     capture_len_from_rule_start(),
     capture_slice_length(),
     capture_rest_length(),
     entry_named_map(),
     match_named_map()
   ))
 }
"""

const JULIA_SOURCE_BOUNDARY_CANONICAL_NORMAL = """Top::OR{1,1}
 /(?<name>ab)/
 I { started = start_capture_slice() }
 E {
   return(array(
     started,
     capture_slice(),
     capture_slice_len(),
     capture_slice_len(),
     capture_rest_len(),
     entry_map(),
     match_map()
   ))
 }
"""

const JULIA_SOURCE_BOUNDARY_ALIAS_REVERSED = """Top::OR{1,1}
 /(?<name>ab)/
 E {
   started = capture_slice_here();
   return(array(
     started,
     capture_from_rule_start(),
     capture_len_from_rule_start(),
     capture_slice_length(),
     capture_rest_length(),
     entry_named_map(),
     match_named_map()
   ))
 }
"""

const JULIA_SOURCE_BOUNDARY_CANONICAL_REVERSED = """Top::OR{1,1}
 /(?<name>ab)/
 E {
   started = start_capture_slice();
   return(array(
     started,
     capture_slice(),
     capture_slice_len(),
     capture_slice_len(),
     capture_rest_len(),
     entry_map(),
     match_map()
   ))
 }
"""

const JULIA_SOURCE_BOUNDARY_NORMAL_EXPECTED = Any[
    nothing,
    "é🙂  ",
    4,
    4,
    6,
    Dict{String,Any}("name" => "ab"),
    Dict{String,Any}("name" => "ab"),
]

const JULIA_SOURCE_BOUNDARY_REVERSED_EXPECTED = Any[
    nothing,
    nothing,
    nothing,
    nothing,
    0,
    Dict{String,Any}("name" => "ab"),
    Dict{String,Any}("name" => "ab"),
]

function _compile_julia_source_boundary_alias(source::AbstractString)
    spec = parse_spec(source)
    validate_spec(spec)
    return compile_spec(spec)
end

function _reconstruct_julia_source_boundary_alias(
    compiled::CompiledSpec,
    identity::AbstractString,
)
    emitted = emit_julia_source_v2(compiled, identity)
    encoded = match(r"const _COMPILED_SPEC_JSON_HEX = \"([^\"]+)\"", emitted)
    @assert encoded !== nothing
    normalized = JSON3.read(
        String(hex2bytes(only(encoded.captures))),
        Dict{String,Any},
    )
    return compile_spec(from_json(SpecFile, normalized))
end

function _load_julia_source_boundary_alias(source::AbstractString)
    return mktempdir() do scratch
        source_path = joinpath(scratch, "fixture.spec")
        write(source_path, source)
        loaded = load_and_compile_spec(
            path_spec_request("fixture.spec"),
            SpecLoadOptions(scratch),
        )
        runtime_parse(create_engine(loaded), JULIA_SOURCE_BOUNDARY_ALIAS_INPUT).value
    end
end

function _assert_julia_source_boundary_alias_carriers(
    source::AbstractString,
    identity::AbstractString,
    expected,
)
    compiled = _compile_julia_source_boundary_alias(source)
    native = runtime_parse(
        LinkedSpecRuntimeEngine(compiled),
        JULIA_SOURCE_BOUNDARY_ALIAS_INPUT,
    ).value
    reconstructed = runtime_parse(
        LinkedSpecRuntimeEngine(
            _reconstruct_julia_source_boundary_alias(compiled, "$identity-reconstructed"),
        ),
        JULIA_SOURCE_BOUNDARY_ALIAS_INPUT,
    ).value
    loaded = _load_julia_source_boundary_alias(source)
    generated = execute_generated_parser_v2(
        compiled,
        build_generated_rule_plan(compiled),
        JULIA_SOURCE_BOUNDARY_ALIAS_INPUT,
        "$identity-generated",
    )

    @test native == expected
    @test reconstructed == expected
    @test loaded == expected
    @test generated == expected
    return compiled
end

function _execute_julia_source_boundary_emitted(
    compiled::CompiledSpec,
    identity::AbstractString,
)
    return mktempdir() do scratch
        generated_path = joinpath(scratch, "generated_parser.jl")
        write(generated_path, emit_julia_source_v2(compiled, identity))
        host = Module(gensym(:JuliaSourceBoundaryAliasHost))
        Base.include(host, generated_path)
        parser = Base.invokelatest(() -> getfield(host, :LinkedSpecGeneratedParser))
        execute = Base.invokelatest(() -> getfield(parser, :execute))
        metadata = Base.invokelatest(() -> getfield(parser, :metadata))
        value = Base.invokelatest(execute, JULIA_SOURCE_BOUNDARY_ALIAS_INPUT)
        source_identity = Base.invokelatest(metadata).source_identity
        return value, source_identity
    end
end

@testset "Julia source-boundary compatibility aliases" begin
    @testset "all seven aliases resolve to exact canonical helpers" begin
        @test JULIA_SOURCE_BOUNDARY_ALIASES == Dict{String,String}(
            "capture_from_rule_start" => "capture_slice",
            "capture_len_from_rule_start" => "capture_slice_len",
            "capture_rest_length" => "capture_rest_len",
            "capture_slice_here" => "start_capture_slice",
            "capture_slice_length" => "capture_slice_len",
            "entry_named_map" => "entry_map",
            "match_named_map" => "match_map",
        )
        @test length(JULIA_SOURCE_BOUNDARY_ALIASES) == 7

        for (alias, canonical) in JULIA_SOURCE_BOUNDARY_ALIASES
            @test is_known_action_ir_call_name(alias)
            @test is_known_action_ir_call_name(canonical)
            @test canonical_action_helper_name(alias) == canonical

            for arity in (0, 1)
                arguments = arity == 0 ? "" : "1"
                resolution = resolve_action_expression_contracts(
                    parse_action_expression("$alias($arguments)"),
                )
                @test resolution.ok
                @test length(resolution.contracts) == 1
                contract = only(resolution.contracts)
                @test contract.source_name == alias
                @test contract.canonical_name == canonical
                @test contract.positional_arg_count == arity
                @test canonicalized(contract)
            end
        end
    end

    @testset "unrelated names retain the exact runtime diagnostic" begin
        source = """Top::
 /x/
 E { invented_source_boundary_alias() }
"""
        failure = try
            runtime_parse(
                LinkedSpecRuntimeEngine(_compile_julia_source_boundary_alias(source)),
                "x",
            )
            nothing
        catch error
            error
        end
        @test failure isa RuntimeInterpreterException
        if failure isa RuntimeInterpreterException
            detail = "unsupported runtime helper 'invented_source_boundary_alias' in rule Top"
            @test failure.message == detail
            @test failure.diagnostic !== nothing
            if failure.diagnostic !== nothing
                diagnostic = to_json(failure.diagnostic)
                @test diagnostic["stage"] == "runtime_execution"
                @test diagnostic["owner_stage"] == "julia_runtime"
                @test diagnostic["detail"] == detail
                @test diagnostic["rule_label"] == "Top"
                @test diagnostic["top_rule"] == "Top"
            end
        end
    end

    @testset "aliases equal canonical helpers across every Julia carrier" begin
        alias_normal = _assert_julia_source_boundary_alias_carriers(
            JULIA_SOURCE_BOUNDARY_ALIAS_NORMAL,
            "source-boundary/julia-alias-normal.spec",
            JULIA_SOURCE_BOUNDARY_NORMAL_EXPECTED,
        )
        canonical_normal = _assert_julia_source_boundary_alias_carriers(
            JULIA_SOURCE_BOUNDARY_CANONICAL_NORMAL,
            "source-boundary/julia-canonical-normal.spec",
            JULIA_SOURCE_BOUNDARY_NORMAL_EXPECTED,
        )
        alias_reversed = _assert_julia_source_boundary_alias_carriers(
            JULIA_SOURCE_BOUNDARY_ALIAS_REVERSED,
            "source-boundary/julia-alias-reversed.spec",
            JULIA_SOURCE_BOUNDARY_REVERSED_EXPECTED,
        )
        canonical_reversed = _assert_julia_source_boundary_alias_carriers(
            JULIA_SOURCE_BOUNDARY_CANONICAL_REVERSED,
            "source-boundary/julia-canonical-reversed.spec",
            JULIA_SOURCE_BOUNDARY_REVERSED_EXPECTED,
        )

        emitted = Dict{String,Any}()
        for (name, compiled, expected) in (
            ("alias_normal", alias_normal, JULIA_SOURCE_BOUNDARY_NORMAL_EXPECTED),
            ("canonical_normal", canonical_normal, JULIA_SOURCE_BOUNDARY_NORMAL_EXPECTED),
            ("alias_reversed", alias_reversed, JULIA_SOURCE_BOUNDARY_REVERSED_EXPECTED),
            ("canonical_reversed", canonical_reversed, JULIA_SOURCE_BOUNDARY_REVERSED_EXPECTED),
        )
            identity = "source-boundary/$name-emitted.spec"
            value, source_identity = _execute_julia_source_boundary_emitted(compiled, identity)
            @test value == expected
            @test source_identity == identity
            emitted[name] = value
        end
        @test emitted["alias_normal"] == emitted["canonical_normal"]
        @test emitted["alias_reversed"] == emitted["canonical_reversed"]
    end
end
