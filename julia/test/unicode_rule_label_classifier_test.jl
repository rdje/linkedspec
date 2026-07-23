# FUTURE-PARITY-BACKLOG.10.6.1.1 — generated Julia rule-label primitives.

const JULIA_UNICODE_RULE_LABEL_CONTRACT = JSON3.read(
    read(
        joinpath(REPO_ROOT, "capability_conformance", "unicode_rule_label_contract.json"),
        String,
    ),
    Dict{String,Any},
)

@testset "generated metadata and all range boundaries match the contract" begin
    contract = JULIA_UNICODE_RULE_LABEL_CONTRACT
    ranges = contract["xid_continue_ranges"]
    @test LinkedSpecJulia.UNICODE_RULE_LABEL_CONTRACT_ID == contract["contract_id"]
    @test LinkedSpecJulia.UNICODE_RULE_LABEL_VERSION == contract["unicode_version"]
    @test LinkedSpecJulia.UNICODE_RULE_LABEL_DATA_SHA256 == contract["data_sha256"]
    @test LinkedSpecJulia.UNICODE_RULE_LABEL_RANGE_COUNT == length(ranges)

    for range in ranges
        start = parse(Int, String(range[1]); base = 16)
        stop = parse(Int, String(range[2]); base = 16)
        @test LinkedSpecJulia.is_rule_label_codepoint(start)
        @test LinkedSpecJulia.is_rule_label_codepoint(stop)
    end
    @test !LinkedSpecJulia.is_rule_label_codepoint(-1)
    @test !LinkedSpecJulia.is_rule_label_codepoint(0xD800)
    @test !LinkedSpecJulia.is_rule_label_codepoint(0x110000)
end

@testset "complete-label validation matches every neutral fixture" begin
    contract = JULIA_UNICODE_RULE_LABEL_CONTRACT
    for fixture in contract["positive_fixtures"]
        @test LinkedSpecJulia.is_rule_label(String(fixture["label"]))
    end
    for fixture in contract["negative_fixtures"]
        @test !LinkedSpecJulia.is_rule_label(String(fixture["label"]))
    end
    for fixture in contract["distinct_fixtures"]
        left = String(fixture["left"])
        right = String(fixture["right"])
        @test LinkedSpecJulia.is_rule_label(left)
        @test LinkedSpecJulia.is_rule_label(right)
        @test left != right
    end
end

@testset "longest-prefix scanning preserves scalar and Julia string boundaries" begin
    for fixture in JULIA_UNICODE_RULE_LABEL_CONTRACT["positive_fixtures"]
        label = String(fixture["label"])
        scan = LinkedSpecJulia.take_rule_label_prefix(string(label, "[2]"))
        @test scan !== nothing
        @test scan.label == label
        @test scan.remainder == "[2]"
    end

    partial = LinkedSpecJulia.take_rule_label_prefix("Top😀Rule")
    @test partial !== nothing
    @test partial.label == "Top"
    @test partial.remainder == "😀Rule"
    @test LinkedSpecJulia.take_rule_label_prefix("😀Top") === nothing
    @test LinkedSpecJulia.take_rule_label_prefix("") === nothing
end
