# FUTURE-PARITY-BACKLOG.14.2.4.0.2 — dormant Julia typed source-location RED.
#
# Ordinary Julia discovery is the explicit include list in `test/runtests.jl`;
# that list deliberately omits this pre-admission consumer. Run either mode
# through repository-local project data from the repository root:
#
#   LINKEDSPEC_JULIA_TYPED_SOURCE_RED_MODE=core \
#     bash tools/run_julia_project_data.sh --project=julia \
#       --startup-file=no --history-file=no -e \
#       'using LinkedSpecJulia, JSON3, Test; include("julia/test/typed_source_location_contract_test.jl")'
#
#   LINKEDSPEC_JULIA_TYPED_SOURCE_RED_MODE=projection \
#     bash tools/run_julia_project_data.sh --project=julia \
#       --startup-file=no --history-file=no -e \
#       'using LinkedSpecJulia, JSON3, Test; include("julia/test/typed_source_location_contract_test.jl")'
#
# Core implementation makes `core` green. Projection implementation then
# makes the independently nested `projection` mode green. Admission removes
# this mode switch and adds the unchanged assertions to `test/runtests.jl`.

using LinkedSpecJulia
using JSON3
using Test

const JULIA_TYPED_SOURCE_RED_MODE = get(
    ENV,
    "LINKEDSPEC_JULIA_TYPED_SOURCE_RED_MODE",
    "core",
)

if !(JULIA_TYPED_SOURCE_RED_MODE in ("core", "projection"))
    error(
        "LINKEDSPEC_JULIA_TYPED_SOURCE_RED_MODE must be 'core' or 'projection', " *
        "got '$(JULIA_TYPED_SOURCE_RED_MODE)'",
    )
end

# The namespace is deliberately private. LinkedSpecJulia already exports an
# unrelated parser `SourceSpan`; nesting the neutral Position/Span vocabulary
# prevents a collision and does not create authored DSL or facade methods.
const JuliaTypedSource = getproperty(LinkedSpecJulia, :SourceLocation)

# Projection lookup is ordered strictly after the core namespace. Today both
# modes stop at the missing core. Once the core lands, projection mode advances
# to one exact missing projection API instead of reclassifying that failure.
const JULIA_TYPED_SOURCE_PROJECTION_ROWS = if JULIA_TYPED_SOURCE_RED_MODE == "projection"
    getproperty(LinkedSpecJulia, :typed_source_projection_rows)
else
    nothing
end
const JULIA_TYPED_SOURCE_COMPATIBILITY_ALIASES = if JULIA_TYPED_SOURCE_RED_MODE == "projection"
    getproperty(LinkedSpecJulia, :typed_source_compatibility_aliases)
else
    nothing
end

const JULIA_TYPED_SOURCE_CONTRACT = JSON3.read(
    read(
        normpath(
            joinpath(
                @__DIR__,
                "..",
                "..",
                "capability_conformance",
                "typed_source_location_contract.json",
            ),
        ),
        String,
    ),
    Dict{String,Any},
)

const JULIA_TYPED_SOURCE_CONTEXT = JuliaTypedSource.SourceLocationContext(
    rule_role = "typed_source_fixture_rule",
    invocation_role = "typed_source_fixture_invocation",
)

const JULIA_TYPED_SOURCE_CURSOR_SOURCE = """Top::
 /ab/ -> Done {
  after_match = cursor_pos()
  save_cursor()
  rewind_match_start()
  match_start = cursor_pos()
  restore_cursor()
  restored_match = cursor_pos()
  save_cursor()
  rewind_entry_start()
  entry_start = cursor_pos()
  restore_cursor()
  restored_entry = cursor_pos()
  return(hash(
   "after_match", after_match,
   "match_start", match_start,
   "restored_match", restored_match,
   "entry_start", entry_start,
   "restored_entry", restored_entry
  ))
 }

Done:
 /ab/
"""

const JULIA_TYPED_SOURCE_CURSOR_EXPECTED = Dict{String,Any}(
    "after_match" => 2,
    "entry_start" => 0,
    "match_start" => 0,
    "restored_entry" => 2,
    "restored_match" => 2,
)

const JULIA_TYPED_SOURCE_ALIAS_SOURCE = """Top::OR{1,1}
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

const JULIA_TYPED_SOURCE_ALIAS_EXPECTED = Any[
    nothing,
    "é🙂  ",
    4,
    4,
    6,
    Dict{String,Any}("name" => "ab"),
    Dict{String,Any}("name" => "ab"),
]

function _julia_typed_source_object_rows(key::AbstractString)
    return JULIA_TYPED_SOURCE_CONTRACT[String(key)]
end

function _julia_typed_source_decoded_sources()
    return Dict{String,String}(
        String(fixture["id"]) => String(fixture["decoded_text"])
        for fixture in _julia_typed_source_object_rows("sources")
    )
end

function _julia_typed_source_position(authority, source_id::AbstractString, offset::Int)
    return JuliaTypedSource.position(
        authority;
        source_id = String(source_id),
        offset,
        context = JULIA_TYPED_SOURCE_CONTEXT,
    )
end

function _julia_typed_source_expect_diagnostic(
    diagnostic_id::AbstractString,
    operation::Function,
    expected_context::Dict{String,Any},
)
    captured = try
        operation()
        nothing
    catch error
        error
    end
    @test captured isa JuliaTypedSource.SourceLocationException
    captured isa JuliaTypedSource.SourceLocationException || return

    diagnostic = only(
        row for row in _julia_typed_source_object_rows("diagnostics")
        if row["id"] == diagnostic_id
    )
    record = JuliaTypedSource.to_json(captured)
    @test record["code"] == diagnostic["code"]
    @test record["phase"] == diagnostic["phase"]
    for field in diagnostic["required_context"]
        @test haskey(record, String(field))
    end
    for (key, value) in expected_context
        @test record[key] == value
    end
    for forbidden in (
        "decoded_text",
        "source_text",
        "path",
        "match",
        "parser_state",
        "host_reference",
    )
        @test !haskey(record, forbidden)
    end
end

function _julia_typed_source_compile(source::AbstractString)
    parsed = parse_spec(source)
    validate_spec(parsed)
    return parsed, compile_spec(parsed)
end

function _julia_typed_source_assert_carriers(
    source::AbstractString,
    input::AbstractString,
    identity::AbstractString,
    expected,
)
    parsed, compiled = _julia_typed_source_compile(source)
    native = runtime_parse(LinkedSpecRuntimeEngine(compiled), input).value

    normalized = JSON3.read(JSON3.write(to_json(parsed)), Dict{String,Any})
    reconstructed_spec = from_json(SpecFile, normalized)
    validate_spec(reconstructed_spec)
    reconstructed = runtime_parse(
        LinkedSpecRuntimeEngine(compile_spec(reconstructed_spec)),
        input,
    ).value

    generated = execute_generated_parser_v2(
        compiled,
        build_generated_rule_plan(compiled),
        input,
        identity,
    )

    @test native == expected
    @test reconstructed == expected
    @test generated == expected
end

@testset "Julia dormant typed source-location contract" begin
    @testset "neutral immutable values and coordinate conversions" begin
        @test JULIA_TYPED_SOURCE_CONTRACT["contract_id"] ==
              "linkedspec-typed-source-location-v1"
        expected_counts = JULIA_TYPED_SOURCE_CONTRACT["expected_counts"]
        @test expected_counts["sources"] == 3
        @test expected_counts["position_conversions"] == 7
        @test expected_counts["direct_spans"] == 6
        @test expected_counts["derived_text_cases"] == 3

        sources = _julia_typed_source_decoded_sources()
        authority = JuliaTypedSource.SourceAuthority(sources = sources)
        positions = Dict{Tuple{String,Int},Any}()
        function position(source_id::AbstractString, offset::Int)
            key = (String(source_id), offset)
            return get!(positions, key) do
                _julia_typed_source_position(authority, source_id, offset)
            end
        end

        for fixture in _julia_typed_source_object_rows("position_conversions")
            source_id = String(fixture["source_id"])
            offset = Int(fixture["offset"])
            value = position(source_id, offset)
            @test JuliaTypedSource.to_json(value) == Dict{String,Any}(
                "source_id" => source_id,
                "offset" => offset,
            )
            @test JuliaTypedSource.to_json(
                JuliaTypedSource.coordinates(
                    authority,
                    value;
                    context = JULIA_TYPED_SOURCE_CONTEXT,
                ),
            ) == Dict{String,Any}(
                "source_id" => source_id,
                "offset" => offset,
                "line" => fixture["line"],
                "column" => fixture["column"],
                "utf8_byte_offset" => fixture["utf8_byte_offset"],
            )
        end

        stable_position = positions[("unicode", 1)]
        detached_position = JuliaTypedSource.to_json(stable_position)
        detached_position["offset"] = 99
        @test detached_position["offset"] == 99
        @test JuliaTypedSource.to_json(stable_position)["offset"] == 1

        spans = Dict{String,Any}()
        for fixture in _julia_typed_source_object_rows("direct_spans")
            source_id = String(fixture["source_id"])
            start = Int(fixture["start"])
            stop = Int(fixture["end"])
            provenance = String(fixture["provenance"])
            span = JuliaTypedSource.direct_span(
                authority;
                start = position(source_id, start),
                stop = position(source_id, stop),
                provenance,
                context = JULIA_TYPED_SOURCE_CONTEXT,
            )
            spans[String(fixture["id"])] = span
            @test JuliaTypedSource.to_json(span) == Dict{String,Any}(
                "source_id" => source_id,
                "start" => start,
                "end" => stop,
                "provenance" => provenance,
            )
            @test JuliaTypedSource.materialize(
                authority,
                span;
                context = JULIA_TYPED_SOURCE_CONTEXT,
            ) == fixture["expected_text"]
        end

        for fixture in _julia_typed_source_object_rows("derived_text_cases")
            ordered_spans = Any[spans[String(id)] for id in fixture["span_ids"]]
            derived = JuliaTypedSource.derived_text(
                authority;
                policy = JuliaTypedSource.ConcatenateInOrder,
                spans = ordered_spans,
                context = JULIA_TYPED_SOURCE_CONTEXT,
            )
            @test JuliaTypedSource.to_json(derived) == Dict{String,Any}(
                "policy" => "concatenate_in_order",
                "spans" => Any[JuliaTypedSource.to_json(span) for span in ordered_spans],
            )
            @test JuliaTypedSource.materialize(
                authority,
                derived;
                context = JULIA_TYPED_SOURCE_CONTEXT,
            ) == fixture["expected_text"]
        end
    end

    @testset "authority ownership and four exact private diagnostics" begin
        sources = _julia_typed_source_decoded_sources()
        authority = JuliaTypedSource.SourceAuthority(sources = sources)
        sources["unicode"] = "changed"

        position(source_id::AbstractString, offset::Int) =
            _julia_typed_source_position(authority, source_id, offset)

        owned_span = JuliaTypedSource.direct_span(
            authority;
            start = position("unicode", 0),
            stop = position("unicode", 1),
            provenance = "input",
            context = JULIA_TYPED_SOURCE_CONTEXT,
        )
        @test JuliaTypedSource.materialize(
            authority,
            owned_span;
            context = JULIA_TYPED_SOURCE_CONTEXT,
        ) == "é"

        _julia_typed_source_expect_diagnostic(
            "source_mismatch",
            () -> JuliaTypedSource.direct_span(
                authority;
                start = position("unicode", 0),
                stop = position("ascii", 1),
                provenance = "input",
                context = JULIA_TYPED_SOURCE_CONTEXT,
            ),
            Dict{String,Any}(
                "rule_role" => "typed_source_fixture_rule",
                "invocation_role" => "typed_source_fixture_invocation",
                "source_id" => "unicode",
                "other_source_id" => "ascii",
            ),
        )
        _julia_typed_source_expect_diagnostic(
            "position_out_of_range",
            () -> position("unicode", 5),
            Dict{String,Any}(
                "rule_role" => "typed_source_fixture_rule",
                "invocation_role" => "typed_source_fixture_invocation",
                "source_id" => "unicode",
                "position_offset" => 5,
                "source_length" => 4,
            ),
        )
        _julia_typed_source_expect_diagnostic(
            "reversed_span",
            () -> JuliaTypedSource.direct_span(
                authority;
                start = position("unicode", 2),
                stop = position("unicode", 1),
                provenance = "capture",
                context = JULIA_TYPED_SOURCE_CONTEXT,
            ),
            Dict{String,Any}(
                "rule_role" => "typed_source_fixture_rule",
                "invocation_role" => "typed_source_fixture_invocation",
                "source_id" => "unicode",
                "start_offset" => 2,
                "end_offset" => 1,
            ),
        )

        foreign_authority = JuliaTypedSource.SourceAuthority(
            sources = Dict{String,String}("foreign" => "foreign text"),
        )
        foreign_span = JuliaTypedSource.direct_span(
            foreign_authority;
            start = _julia_typed_source_position(foreign_authority, "foreign", 0),
            stop = _julia_typed_source_position(foreign_authority, "foreign", 1),
            provenance = "input",
            context = JULIA_TYPED_SOURCE_CONTEXT,
        )
        _julia_typed_source_expect_diagnostic(
            "invalid_derived_provenance",
            () -> JuliaTypedSource.derived_text(
                authority;
                policy = JuliaTypedSource.ConcatenateInOrder,
                spans = Any[foreign_span],
                context = JULIA_TYPED_SOURCE_CONTEXT,
            ),
            Dict{String,Any}(
                "rule_role" => "typed_source_fixture_rule",
                "invocation_role" => "typed_source_fixture_invocation",
                "provenance_index" => 0,
                "source_id" => "foreign",
            ),
        )
    end

    if JULIA_TYPED_SOURCE_RED_MODE == "projection"
        @testset "detached exact 92 projection rows and seven aliases" begin
            engine = LinkedSpecRuntimeEngine(
                compile_spec(parse_spec("Top::\n I { return(\"ok\") }\n")),
            )
            expected_rows = JULIA_TYPED_SOURCE_CONTRACT["helper_projections"]
            rows = JULIA_TYPED_SOURCE_PROJECTION_ROWS(engine)
            @test rows == expected_rows

            families = JULIA_TYPED_SOURCE_CONTRACT["helper_projection_schema"]["families"]
            names = String[]
            for family in families
                append!(names, String(row[1]) for row in rows[String(family)])
            end
            @test length(names) == 92
            @test length(Set(names)) == 92

            expected_aliases = JULIA_TYPED_SOURCE_CONTRACT["compatibility_aliases"]
            @test JULIA_TYPED_SOURCE_COMPATIBILITY_ALIASES(engine) == expected_aliases
            @test length(expected_aliases) == 7

            rows["capture_mark"][1][2] = "wrong"
            @test JULIA_TYPED_SOURCE_PROJECTION_ROWS(engine) == expected_rows
        end

        @testset "mark capture cursor and alias results on all carriers" begin
            named_mark_contract = JSON3.read(
                read(
                    normpath(
                        joinpath(
                            @__DIR__,
                            "..",
                            "..",
                            "capability_conformance",
                            "complete_named_mark_contract.json",
                        ),
                    ),
                    String,
                ),
                Dict{String,Any},
            )
            fixture = named_mark_contract["fixture"]
            _julia_typed_source_assert_carriers(
                fixture["spec_source"],
                fixture["input"],
                "typed-source/complete-named-mark.spec",
                fixture["expected"],
            )
            _julia_typed_source_assert_carriers(
                JULIA_TYPED_SOURCE_CURSOR_SOURCE,
                "ab",
                "typed-source/cursor-control.spec",
                JULIA_TYPED_SOURCE_CURSOR_EXPECTED,
            )
            _julia_typed_source_assert_carriers(
                JULIA_TYPED_SOURCE_ALIAS_SOURCE,
                "é🙂  ab",
                "typed-source/compatibility-aliases.spec",
                JULIA_TYPED_SOURCE_ALIAS_EXPECTED,
            )
        end
    end
end
