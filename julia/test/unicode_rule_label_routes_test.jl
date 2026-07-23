# FUTURE-PARITY-BACKLOG.10.6.1.1 — Julia label parsing/validation routes.

function _julia_unicode_spec_with(label::AbstractString, kind)
    return SpecFile(rules = [
        Rule(
            header = RuleHeader(String(label), true, default_rule_mode(), "", 1),
            body = [BodyElement(kind, "", 2)],
        ),
    ])
end

function _julia_unicode_validation_error(spec::SpecFile)
    try
        validate_spec(spec)
    catch error
        return error
    end
    return nothing
end

function _julia_unicode_reconstruct(spec::SpecFile)
    encoded = JSON3.write(to_json(spec))
    return from_json(SpecFile, JSON3.read(encoded))
end

function _julia_unicode_invalid_label_json(
    role::AbstractString,
    label::AbstractString,
    line::Int;
    owner = nothing,
)
    fields = Dict{String,Any}(
        "label" => String(label),
        "line" => line,
        "role" => String(role),
    )
    if owner !== nothing
        fields["rule_label"] = String(owner)
    end
    return Dict{String,Any}(
        "code" => "invalid_rule_label",
        "stage" => "validate_rule_labels",
        "message" => "$(role) '$label' is not a nonempty Unicode 17.0.0 XID_Continue rule label",
        "fields" => fields,
    )
end

@testset "scanner parses every declaration and edge form with exact identity" begin
    decomposed_top = "To\u0308p"
    action = parse_spec("""
Töp::AND
 -> $decomposed_top | Δοκιμή { return(entry_text()) }

$decomposed_top:
 /x/

Δοκιμή:
 /x/
""")
    validate_spec(action)
    @test [rule.header.label for rule in action.rules] == ["Töp", decomposed_top, "Δοκιμή"]
    action_edge = only(action.rules[1].body).kind
    @test action_edge isa ActionEdgeBodyElementKind
    @test [target.label for target in action_edge.targets] == [decomposed_top, "Δοκιμή"]

    blind = parse_spec("""
規則::AND
 => 𐐀Rule

𐐀Rule:
 /x/
""")
    validate_spec(blind)
    blind_edge = only(blind.rules[1].body).kind
    @test blind_edge isa BlindEdgeBodyElementKind
    @test blind_edge.target == "𐐀Rule"

    bare = parse_spec("""
9_root::OR
 A·B | _ { return(entry_text()) }

A·B:
 /x/

_:
 /x/
""")
    validate_spec(bare)
    bare_edge = only(bare.rules[1].body).kind
    @test bare_edge isa BareEdgeBodyElementKind
    @test [target.label for target in bare_edge.targets] == ["A·B", "_"]
end

@testset "invalid suffixes never become partial action blind or bare edges" begin
    invalid_labels = ("", "Top-Rule", "Top Rule", "Top😀", "Top:", "Top/Rule", raw"$Top")
    for invalid in invalid_labels
        for arrow in ("->", "=>")
            spec = parse_spec(string("Top::\n ", arrow, " ", invalid, "\n"))
            @test only(only(spec.rules).body).kind isa RawBodyElementKind
            error = _julia_unicode_validation_error(spec)
            @test error isa SpecValidationException
            @test occursin("unrecognized body syntax", error.message)
        end

        if !isempty(invalid)
            spec = parse_spec(string("Top::\n ", invalid, "\n"))
            @test all(
                !(element.kind isa ActionEdgeBodyElementKind) &&
                !(element.kind isa BlindEdgeBodyElementKind) &&
                !(element.kind isa BareEdgeBodyElementKind)
                for rule in spec.rules for element in rule.body
            )
            @test _julia_unicode_validation_error(spec) isa SpecValidationException
        end
    end
end

@testset "invalid declarations never become suffix or prefix headers" begin
    invalid_labels = ("", "Top-Rule", "Top Rule", "Top😀", "Top:", "Top/Rule", raw"$Top")
    for invalid in invalid_labels
        @test_throws SpecParseException parse_spec(string(invalid, "::\n /x/\n"))
    end
    @test_throws SpecParseException parse_spec("Top:::\n /x/\n")
end

@testset "validator rejects every programmatic declaration and target role" begin
    invalid_declaration = _julia_unicode_spec_with("Top-Rule", RegexBodyElementKind("x"))
    declaration_error = _julia_unicode_validation_error(invalid_declaration)
    @test declaration_error isa SpecValidationException
    @test to_json(declaration_error.diagnostic) ==
        _julia_unicode_invalid_label_json("declaration", "Top-Rule", 1)

    target_kinds = (
        ActionEdgeBodyElementKind(targets = [EdgeTarget(label = "Bad-Target")]),
        BlindEdgeBodyElementKind(target = "Bad-Target"),
        BareEdgeBodyElementKind(targets = [BareEdgeTarget(label = "Bad-Target")]),
    )
    for kind in target_kinds
        error = _julia_unicode_validation_error(_julia_unicode_spec_with("Top", kind))
        @test error isa SpecValidationException
        @test to_json(error.diagnostic) ==
            _julia_unicode_invalid_label_json("edge_target", "Bad-Target", 2; owner = "Top")
    end
end

@testset "validator rejects invalid labels reconstructed from AST JSON" begin
    invalid_target = _julia_unicode_spec_with(
        "Top",
        ActionEdgeBodyElementKind(targets = [EdgeTarget(label = "Bad-Target")]),
    )
    target_error = _julia_unicode_validation_error(_julia_unicode_reconstruct(invalid_target))
    @test target_error isa SpecValidationException
    @test to_json(target_error.diagnostic) ==
        _julia_unicode_invalid_label_json("edge_target", "Bad-Target", 2; owner = "Top")

    invalid_declaration = _julia_unicode_spec_with("Bad-Declaration", RegexBodyElementKind("x"))
    declaration_error = _julia_unicode_validation_error(
        _julia_unicode_reconstruct(invalid_declaration),
    )
    @test declaration_error isa SpecValidationException
    @test to_json(declaration_error.diagnostic) ==
        _julia_unicode_invalid_label_json("declaration", "Bad-Declaration", 1)
end
