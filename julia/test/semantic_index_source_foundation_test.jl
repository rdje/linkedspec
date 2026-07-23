function _captured_semantic_index_error(call)
    try
        call()
    catch error
        @test error isa SemanticIndexError
        return error
    end
    @test false
    return nothing
end

@testset "Semantic index source foundation" begin
    unicode_source = "A😀\r\né\u0301Z"
    text_index = semantic_index(
        unicode_source;
        logical_name = "unicode-source.spec",
        source_detail_ceiling = SemanticSourceTextDetail,
        entry_rule = "Töp",
    )

    @test text_index isa SemanticIndex
    @test_throws MethodError SemanticIndex(
        unicode_source,
        nothing,
        "unicode-source.spec",
        SemanticSourceTextDetail,
        "digest",
        nothing,
    )
    @test isempty(propertynames(text_index))
    @test_throws ArgumentError text_index._source_text
    @test repr(text_index) ==
          "SemanticIndex(source_id=\"source:0\", snapshot_state=\"failed_compilation\", source_detail_ceiling=\"text\", has_execution=false)"
    @test !occursin("unicode-source.spec", repr(text_index))
    @test !occursin(unicode_source, repr(text_index))
    @test !occursin("57e1b234", repr(text_index))

    identity = source_identity(text_index)
    @test identity == SemanticSourceIdentity(
        "source:0",
        "unicode-source.spec",
        12,
        7,
        "sha256:57e1b2340598ecf42cdcbb3f811e43de57603f4b5ed3d2baa8850007436a7aba",
    )
    @test Base.hash(identity, UInt(0)) ==
          Base.hash(source_identity(text_index), UInt(0))
    @test to_json(identity) == Dict{String,Any}(
        "source_id" => "source:0",
        "logical_name" => "unicode-source.spec",
        "byte_length" => 12,
        "scalar_length" => 7,
        "content_digest" =>
            "sha256:57e1b2340598ecf42cdcbb3f811e43de57603f4b5ed3d2baa8850007436a7aba",
    )

    emoji_span = SemanticSourceSpan(1, 5, 1, 2, 1, 3)
    @test source_span_for_bytes(text_index, 1, 5) == emoji_span
    @test source_span_for_scalars(text_index, 1, 2) == emoji_span
    @test Base.hash(emoji_span, UInt(0)) ==
          Base.hash(source_span_for_bytes(text_index, 1, 5), UInt(0))
    @test source_excerpt_for_bytes(text_index, 1, 5) == "😀"
    @test source_span_for_bytes(text_index, 5, 7) ==
          SemanticSourceSpan(5, 7, 1, 3, 2, 1)
    @test source_span_for_scalars(text_index, 2, 4) ==
          SemanticSourceSpan(5, 7, 1, 3, 2, 1)
    @test source_span_for_bytes(text_index, 7, 11) ==
          SemanticSourceSpan(7, 11, 2, 1, 2, 3)
    @test source_excerpt_for_bytes(text_index, 7, 11) == "é\u0301"
    @test source_span_for_bytes(text_index, 12, 12) ==
          SemanticSourceSpan(12, 12, 2, 4, 2, 4)
    @test source_span_for_scalars(text_index, 7, 7) ==
          SemanticSourceSpan(12, 12, 2, 4, 2, 4)
    @test source_excerpt_for_bytes(text_index, 12, 12) == ""

    span_json = to_json(emoji_span)
    @test span_json == Dict{String,Any}(
        "start_byte" => 1,
        "end_byte" => 5,
        "start_line" => 1,
        "start_column" => 2,
        "end_line" => 1,
        "end_column" => 3,
    )
    span_json["start_byte"] = 999
    @test source_span_for_bytes(text_index, 1, 5) == emoji_span

    duplicate_index = semantic_index(
        "α α α";
        logical_name = "duplicates.spec",
        source_detail_ceiling = SemanticSourceTextDetail,
    )
    @test locate_exact(duplicate_index, "α") == SemanticSourceSpan(0, 2, 1, 1, 1, 2)
    @test locate_exact(duplicate_index, "α"; after_byte = 2) ==
          SemanticSourceSpan(3, 5, 1, 3, 1, 4)
    @test locate_exact(duplicate_index, "α"; after_byte = 5) ==
          SemanticSourceSpan(6, 8, 1, 5, 1, 6)
    @test locate_exact(duplicate_index, "missing") === nothing

    none_index = semantic_index(
        "not a LinkedSpec grammar";
        logical_name = "none.spec",
        source_detail_ceiling = SemanticSourceNoneDetail,
    )
    none_error = _captured_semantic_index_error(() -> source_identity(none_index))
    @test none_error.stage == "apply_source_ceiling"
    @test none_error.code == "semantic_source_detail_forbidden"
    @test Dict(none_error.fields) == Dict{String,Any}(
        "ceiling" => "none",
        "required" => "identity",
    )

    identity_index = semantic_index(
        "still not a grammar";
        logical_name = "identity.spec",
        source_detail_ceiling = SemanticSourceIdentityDetail,
    )
    @test source_identity(identity_index).content_digest === nothing
    identity_error = _captured_semantic_index_error(
        () -> source_span_for_bytes(identity_index, 0, 0),
    )
    @test identity_error.code == "semantic_source_detail_forbidden"

    span_index = semantic_index(
        "span only";
        logical_name = "span.spec",
        source_detail_ceiling = SemanticSourceSpanDetail,
    )
    @test source_identity(span_index).content_digest === nothing
    @test source_span_for_scalars(span_index, 0, 4) ==
          SemanticSourceSpan(0, 4, 1, 1, 1, 5)
    span_error = _captured_semantic_index_error(
        () -> source_excerpt_for_bytes(span_index, 0, 4),
    )
    @test span_error.code == "semantic_source_detail_forbidden"

    identity_json = to_json(source_identity(text_index))
    identity_json["logical_name"] = "mutated.spec"
    @test source_identity(text_index).logical_name == "unicode-source.spec"

    caller_bytes = Vector{UInt8}(codeunits("copied 😀 source"))
    bytes_index = semantic_index(
        @view(caller_bytes[:]);
        logical_name = "bytes.spec",
        source_detail_ceiling = SemanticSourceTextDetail,
    )
    caller_bytes .= UInt8('x')
    @test source_excerpt_for_bytes(bytes_index, 0, 18) == "copied 😀 source"
    @test source_identity(bytes_index).byte_length == 18
    @test source_identity(bytes_index).scalar_length == 15

    backing = "prefix copied suffix"
    substring_index = semantic_index(
        SubString(backing, 8, 13);
        logical_name = "substring.spec",
        source_detail_ceiling = SemanticSourceTextDetail,
    )
    @test source_excerpt_for_bytes(substring_index, 0, 6) == "copied"

    invalid_string = String(UInt8[0xff])
    invalid_text = _captured_semantic_index_error(
        () -> semantic_index(
            invalid_string;
            logical_name = "invalid-text.spec",
            source_detail_ceiling = SemanticSourceTextDetail,
        ),
    )
    @test invalid_text.stage == "decode_source"
    @test invalid_text.code == "semantic_index_invalid_unicode"

    for bytes in (
        UInt8[0xff],
        UInt8[0xc3, 0x28],
        UInt8[0xe2, 0x82],
        UInt8[0xed, 0xa0, 0x80],
    )
        invalid_utf8 = _captured_semantic_index_error(
            () -> semantic_index(
                bytes;
                logical_name = "invalid-bytes.spec",
                source_detail_ceiling = SemanticSourceTextDetail,
            ),
        )
        @test invalid_utf8.stage == "decode_source"
        @test invalid_utf8.code == "semantic_index_invalid_utf8"
    end

    for (logical_name, entry_rule) in (
        ("", nothing),
        ("line\nname", nothing),
        (invalid_string, nothing),
        ("valid.spec", ""),
        ("valid.spec", "Top-"),
        ("valid.spec", invalid_string),
    )
        option_error = _captured_semantic_index_error(
            () -> semantic_index(
                "invalid grammar is intentionally never parsed";
                logical_name = logical_name,
                source_detail_ceiling = SemanticSourceTextDetail,
                entry_rule = entry_rule,
            ),
        )
        @test option_error.stage == "validate_options"
        @test option_error.code == "semantic_index_invalid_option"
    end

    ceiling_error = _captured_semantic_index_error(
        () -> SemanticIndexOptions("source.spec", :text),
    )
    @test ceiling_error.code == "semantic_index_invalid_option"
    type_error = _captured_semantic_index_error(
        () -> SemanticIndexOptions(42, SemanticSourceTextDetail),
    )
    @test type_error.code == "semantic_index_invalid_option"
    selector_type_error = _captured_semantic_index_error(
        () -> SemanticIndexOptions(
            "source.spec",
            SemanticSourceTextDetail;
            entry_rule = 42,
        ),
    )
    @test selector_type_error.code == "semantic_index_invalid_option"

    for call in (
        () -> source_span_for_bytes(text_index, -1, 0),
        () -> source_span_for_bytes(text_index, 0, 13),
        () -> source_span_for_bytes(text_index, 5, 4),
        () -> source_span_for_scalars(text_index, -1, 0),
        () -> source_span_for_scalars(text_index, 0, 8),
        () -> source_span_for_scalars(text_index, 2, 1),
        () -> source_span_for_bytes(text_index, true, 1),
        () -> source_span_for_bytes(text_index, 0, false),
        () -> source_span_for_scalars(text_index, true, 1),
        () -> source_span_for_bytes(text_index, 0.0, 1),
        () -> source_span_for_bytes(text_index, typemax(UInt128), typemax(UInt128)),
        () -> locate_exact(text_index, "A"; after_byte = true),
    )
        range_error = _captured_semantic_index_error(call)
        @test range_error.stage == "map_source"
        @test range_error.code == "semantic_source_range_invalid"
    end

    start_boundary_error = _captured_semantic_index_error(
        () -> source_span_for_bytes(text_index, 2, 5),
    )
    @test start_boundary_error.code == "semantic_source_boundary_invalid"
    @test Dict(start_boundary_error.fields) == Dict{String,Any}("start_byte" => 2)
    end_boundary_error = _captured_semantic_index_error(
        () -> source_span_for_bytes(text_index, 1, 4),
    )
    @test end_boundary_error.code == "semantic_source_boundary_invalid"
    @test Dict(end_boundary_error.fields) == Dict{String,Any}("end_byte" => 4)
    after_boundary_error = _captured_semantic_index_error(
        () -> locate_exact(text_index, "A"; after_byte = 2),
    )
    @test after_boundary_error.code == "semantic_source_boundary_invalid"

    empty_needle_error = _captured_semantic_index_error(
        () -> locate_exact(text_index, ""),
    )
    @test empty_needle_error.code == "semantic_source_needle_invalid"
    malformed_needle_error = _captured_semantic_index_error(
        () -> locate_exact(text_index, invalid_string),
    )
    @test malformed_needle_error.code == "semantic_source_needle_invalid"
    needle_type_error = _captured_semantic_index_error(
        () -> locate_exact(text_index, UInt8[0x41]),
    )
    @test needle_type_error.code == "semantic_source_needle_invalid"

    error_json = to_json(start_boundary_error)
    @test error_json["fields"] == Dict{String,Any}("start_byte" => 2)
    error_json["fields"]["start_byte"] = 999
    @test Dict(start_boundary_error.fields) == Dict{String,Any}("start_byte" => 2)
end
