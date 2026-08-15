const RULE_LOCAL_CURSOR_DESCRIPTOR_CONTRACT = JSON3.read(
    read(
        joinpath(REPO_ROOT, "capability_conformance", "rule_local_cursor_contract.json"),
        String,
    ),
    Dict{String,Any},
)

function _descriptor_cursor_rows(name::AbstractString)
    return RULE_LOCAL_CURSOR_DESCRIPTOR_CONTRACT[String(name)]
end

function _descriptor_normalized_spec(source::AbstractString)
    parsed = parse_spec(source)
    return from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed))))
end

function _descriptor_edge_source(parent_family, sources, declared_rules)
    io = IOBuffer()
    println(io, parent_family == "and" ? "Top::AND" : "Top::")
    for source in sources
        println(io, " ", source)
    end
    for label in declared_rules
        println(io)
        println(io, label, ":")
        println(io, " /x/ /y/")
    end
    return String(take!(io))
end

function _descriptor_validation_failure(spec::SpecFile)
    try
        compile_spec(spec)
    catch error
        if error isa SpecValidationException && error.diagnostic isa SpecPortableDiagnostic
            return error.diagnostic
        end
        rethrow()
    end
    error("expected portable descriptor validation failure")
end

function _descriptor_with_source_id(descriptor, source_id::AbstractString)
    expected = deepcopy(descriptor)
    for rule in values(expected["spec"])
        metadata = rule["meta"]
        for slot in metadata["regex_slots"]
            slot["source_id"] = String(source_id)
        end
        if metadata["capture_gaps"] !== nothing
            metadata["capture_gaps"]["source_id"] = String(source_id)
        end
    end
    return expected
end

function _descriptor_expected_root_meta_keys()
    variants = DESCRIPTOR_CONTRACT["meta_contract_variants"]
    legacy = variants["legacy_global_v0"]
    cursor = variants["rule_local_cursor_v1"]
    result = Set(String(value) for value in DESCRIPTOR_CONTRACT["required_meta_keys"])
    for key in legacy["required_keys"]
        delete!(result, String(key))
    end
    for key in cursor["required_keys"]
        push!(result, String(key))
    end
    push!(result, "entry_rule_contract")
    push!(result, "regex_slot_identity_contract")
    return result
end

@testset "Neutral rule-local cursor descriptor contract" begin
    descriptor_contract = RULE_LOCAL_CURSOR_DESCRIPTOR_CONTRACT["descriptor_contract"]
    descriptor_variant = DESCRIPTOR_CONTRACT["meta_contract_variants"]["rule_local_cursor_v1"]

    @testset "all 36 families project cursor v1 from normalized state" begin
        expected_root_keys = _descriptor_expected_root_meta_keys()
        expected_rule_keys = Set([
            "label",
            "line",
            "is_top",
            "family",
            "cursor_policy",
            "edge_ownership",
            "regex_slots",
            "capture_gaps",
            "resolved_slot_edges",
            "resolved_edges",
            "mode",
        ])
        for row in _descriptor_cursor_rows("family_cases")
            source = "$(row["header"])\n /x/\n"
            parsed = parse_spec(source)
            direct = to_descriptor_json(compile_spec(parsed))
            normalized = to_descriptor_json(compile_spec(_descriptor_normalized_spec(source)))

            @test normalized == direct
            @test Set(keys(direct)) == Set(String(value) for value in DESCRIPTOR_CONTRACT["top_level_keys"])
            root_meta = direct["meta"]
            @test Set(keys(root_meta)) == expected_root_keys
            @test root_meta["cursor_contract"] == descriptor_contract["meta"]["cursor_contract"]
            @test root_meta["cursor_contract"] == descriptor_variant["cursor_contract"]
            @test root_meta["entry_rule_contract"] == ENTRY_RULE_CONTRACT_ID
            for field in descriptor_variant["forbidden_keys"]
                @test !haskey(root_meta, String(field))
            end

            rule = only(parsed.rules)
            rule_descriptor = direct["spec"]["Top"]
            rule_meta = rule_descriptor["meta"]
            @test Set(keys(rule_meta)) == expected_rule_keys
            @test rule_descriptor["handler"]["label"] == "Top"
            @test rule_meta["label"] == "Top"
            @test rule_meta["line"] == rule.header.line
            @test rule_meta["is_top"] == rule.header.is_top
            @test rule_meta["family"] == row["family"]
            @test rule_meta["cursor_policy"] == row["cursor_policy"]
            @test rule_meta["edge_ownership"] == "none"
            @test rule_meta["regex_slots"] == Any[Dict{String,Any}(
                "regex_index" => 0,
                "slot_id" => nothing,
                "source_id" => "inline",
                "line" => 2,
            )]
            @test rule_meta["capture_gaps"] === nothing
            @test isempty(rule_meta["resolved_slot_edges"])
            @test isempty(rule_meta["resolved_edges"])
            @test rule_meta["mode"]["is_and"] == (row["family"] == "and")
            @test !haskey(rule_meta, "parse_mode")
        end
    end

    @testset "all valid normalized edges project deterministic semantic rows" begin
        semantic_fields = Set(
            String(value) for value in descriptor_contract["resolved_edge_fields"]
        )
        for row in _descriptor_cursor_rows("edge_resolution_cases")
            expected = get(row, "expected", nothing)
            if !(expected isa Dict) || get(expected, "kind", nothing) != "edge"
                continue
            end
            declared = String[String(value) for value in row["declared_rules"]]
            source = _descriptor_edge_source(
                row["parent_family"],
                [String(row["source"])],
                declared,
            )
            direct = to_descriptor_json(compile_spec(parse_spec(source)))
            normalized = to_descriptor_json(compile_spec(_descriptor_normalized_spec(source)))
            @test normalized == direct

            rule_meta = direct["spec"]["Top"]["meta"]
            actual_rows = rule_meta["resolved_edges"]
            expected_targets = expected["targets"]
            @test rule_meta["edge_ownership"] == expected["ownership"]
            @test length(actual_rows) == length(expected_targets)
            for (actual, target) in zip(actual_rows, expected_targets)
                @test Set(keys(actual)) == semantic_fields
                @test actual["ownership"] == expected["ownership"]
                @test actual["target"] == target["label"]
                @test actual["regex_index"] == (
                    expected["ownership"] == "action" ? something(target["index"], 0) : nothing
                )
                @test actual["block"] == expected["has_block"]
                @test actual["fluent"] == target["fluent"]
                @test !haskey(actual, "source_form")
            end
        end
    end

    @testset "direct loaded and normalized descriptor bytes agree with runtime" begin
        source = raw"""
Top::AND
 /x/
 -> Top { return("hit") }
"""
        direct_compiled = compile_spec(parse_spec(source))
        direct = to_descriptor_json(direct_compiled)
        direct_bytes = JSON3.write(direct)
        normalized = to_descriptor_json(compile_spec(_descriptor_normalized_spec(source)))
        @test JSON3.write(normalized) == direct_bytes

        mktempdir() do scratch
            path = joinpath(scratch, "descriptor.spec")
            write(path, source)
            loaded = load_and_compile_spec(path_spec_request(path), SpecLoadOptions(scratch))
            loaded_descriptor = to_descriptor_json(loaded.compiled)
            @test loaded_descriptor ==
                  _descriptor_with_source_id(direct, "descriptor.spec")
            @test loaded_descriptor["spec"]["Top"]["meta"]["family"] == "and"
            @test loaded_descriptor["spec"]["Top"]["meta"]["cursor_policy"] == "consume"
            @test runtime_parse(create_engine(loaded), "prefix x").value === nothing
            @test runtime_parse(create_engine(loaded), "x").value == "hit"
        end
    end

    @testset "normalized invalid state preserves every portable edge failure" begin
        diagnostics = Dict(
            String(row["code"]) => row for row in _descriptor_cursor_rows("diagnostics")
        )
        invalid_rows = Any[
            [
                row for row in _descriptor_cursor_rows("edge_resolution_cases")
                if haskey(row, "expected_error")
            ]...,
            [
                row for row in _descriptor_cursor_rows("rule_edge_set_cases")
                if haskey(row, "expected_error")
            ]...,
        ]
        for row in invalid_rows
            expected_code = String(row["expected_error"])
            sources = haskey(row, "sources") ?
                String[String(value) for value in row["sources"]] :
                [String(row["source"])]
            source = _descriptor_edge_source(
                row["parent_family"],
                sources,
                String[String(value) for value in row["declared_rules"]],
            )
            diagnostic = _descriptor_validation_failure(_descriptor_normalized_spec(source))
            diagnostic_json = to_json(diagnostic)
            @test diagnostic.code == expected_code
            @test diagnostic.stage == diagnostics[expected_code]["stage"]
            @test Set(keys(diagnostic_json["fields"])) == Set(
                String(value) for value in diagnostics[expected_code]["fields"]
            )
        end
    end
end
