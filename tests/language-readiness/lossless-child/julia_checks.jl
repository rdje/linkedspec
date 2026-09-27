module LosslessChildChecks

using LinkedSpecJulia, JSON3, SHA
include(joinpath(@__DIR__, "..", "nested-tree", "julia_checks.jl"))
using .NestedTreeChecks: require, exact_json

const D = Dict{String,Any}
digest(source) = "sha256:" * bytes2hex(sha256(codeunits(source)))
case_by_id(cases, id) = only(filter(row -> row["id"] == id, cases["accept"]))

function seed(child, child_digest, calls; change = "")
    caps = ["staged-parse-job-v2", "typed-source-location-v1"]
    modes = ["fail", "sibling_field"]
    ceilings = D("source_detail" => "span", "max_steps" => 100,
        "max_result_nodes" => 512, "max_diagnostic_bytes" => 4096)
    snapshot = D(
        "immutable" => true, "prepared_before_authored_execution" => true,
        "filesystem_access_during_dispatch" => false,
        "aliases" => (change == "missing_identity" ? Any[] : [D(
            "declaring_spec_id" => "readiness/parent.spec", "authored_id" => "integer",
            "resolved_spec_id" => "registry:integer-v1")]),
        "declaring_relative" => Any[], "search_roots" => Any[], "providers" => Any[],
        "entries" => [D("resolved_spec_id" => "registry:integer-v1", "compiled_authority" => "opaque:integer",
            "content_digest" => child_digest, "import_graph_fingerprint" => digest(""),
            "default_top_rule" => (change == "forbidden_top" ? "Other" : "Number"),
            "allowed_top_rules" => [change == "forbidden_top" ? "Other" : "Number"],
            "spec_language_version" => 2, "helper_contract_version" => "actionir-v3", "staged_contract_version" => 2,
            "capabilities" => caps, "policy_modes" => modes, "ceilings" => ceilings)],
    )
    options = D("declaring_spec_id" => "readiness/parent.spec", "caller_capabilities" => caps,
        "caller_policy_modes" => modes, "caller_ceilings" => ceilings, "required_source_detail" => "span",
        "required_versions" => D("spec_language_version" => 2, "helper_contract_version" => "actionir-v3", "staged_contract_version" => 2))
    factory = function()
        callback = function(request, context)
            push!(calls, D("text" => request["text"], "top" => request["top_rule"]))
            # Actual precompiled child recognition and semantic construction stay in the .spec.
            result = try
                child(request["text"])
            catch failure
                failure isa RuntimeExitNow || rethrow()
                return LinkedSpecJulia._staged_child_failure(D("code" => "child_exit", "status" => failure.status))
            end
            result["source_span"] = LinkedSpecJulia._staged_rebase_span(context, result["span"])
            return LinkedSpecJulia._staged_child_success(result)
        end
        return D("compiled_authorities" => Dict{String,Function}("opaque:integer" => callback),
            "recursive_authority" => D("cancellation_token" => "lossless-child-readiness", "deadline" => 100,
                "remaining_steps" => (change == "no_budget" ? 0 : 100), "required_steps" => 1,
                "max_depth" => 4, "max_calls" => (change == "one_call" ? 1 : 16)),
            "cancelled" => (_ -> false), "clock" => (() -> 0))
    end
    return LinkedSpecJulia.StagedAstEnrichmentSeed(snapshot = snapshot, options = options, authority_factory = factory)
end

function segments(actual, expected, input)
    exact_json(actual, expected)
    scalars = collect(input)
    cursor = 0
    reconstructed = IOBuffer()
    for part in actual
        span = part["span"]
        start, stop = span isa AbstractVector ? (span[1], span[2]) : (span["start"], span["end"])
        require(start == cursor && 0 <= start <= stop <= length(scalars), "ordered scalar adjacency")
        exact_json(part["text"], join(scalars[start + 1:stop]))
        print(reconstructed, part["text"])
        cursor = stop
    end
    require(cursor == length(scalars), "complete scalar coverage")
    exact_json(String(take!(reconstructed)), input)
    return true
end

function segmentation(cases, parse)
    require(length(cases["accept"]) == 13, "original segmentation inventory")
    for _ in 1:2, row in cases["accept"]
        segments(parse(row["input"]), row["expected"], row["input"])
    end
    row = case_by_id(cases, "unicode_edges")
    returned = parse(row["input"])
    returned[1]["text"] = "changed gap"
    returned[1]["span"]["start"] = 999
    segments(parse(row["input"]), row["expected"], row["input"])
    return true
end

function composed(result, row, calls)
    original = deepcopy(result["ast"])
    requests, sidecars = Any[], Any[]
    for (index, item) in enumerate(row["expected"])
        item["kind"] == "item" || continue
        token = item["text"]
        text = token[2:end - 1] # The selected token grammar uses ASCII brackets/digits.
        span = D("kind" => "direct_span", "source_id" => "input", "provenance" => "entry_group",
            "start" => item["span"][1] + 1, "end" => item["span"][2] - 1)
        exact_json(original[index]["child"], text)
        exact_json(original[index]["parsed"], D("kind" => "integer", "text" => text,
            "span" => D("start" => 0, "end" => length(text)), "source_span" => span))
        delete!(original[index], "child"); delete!(original[index], "parsed")
        push!(requests, D("text" => text, "top" => "Number"))
        push!(sidecars, (Any[index - 1, "child"], span))
    end
    segments(original, row["expected"], row["input"])
    exact_json(calls, requests)
    require(length(result["sidecars"]) == length(sidecars), "sidecar count")
    for (actual, (path, span)) in zip(result["sidecars"], sidecars)
        exact_json(actual["parent_ast_path"], path)
        exact_json(actual["provenance"], span)
        exact_json(actual["resolved_spec_id"], "registry:integer-v1")
        exact_json(actual["top_rule"], "Number")
        exact_json(actual["state"], "succeeded")
    end
    exact_json(result["resources"]["total_calls"], length(requests))
    exact_json(result["cache"]["misses"], isempty(requests) ? 0 : 1)
    exact_json(result["cache"]["hits"], max(length(requests) - 1, 0))
    exact_json(result["diagnostics"], Any[])
    return true
end

function rejects(parse, input, code)
    rejected = false
    try
        parse(input)
    catch failure
        failure isa LinkedSpecJulia.StagedAstEnrichmentException || rethrow()
        exact_json(to_json(failure)["code"], code)
        rejected = true
    end
    require(rejected, "typed staged rejection without a result: $input")
    return true
end

function actual_result_isolation(first, second)
    expected = deepcopy(second)
    # Mutate the public result itself, never a copy of the value being challenged.
    first["ast"][2]["parsed"]["text"] = "changed actual child"
    first["ast"][2]["parsed"]["source_span"]["start"] = 999
    require(second == expected, "actual child results alias")
    return true
end

function children(cases, strict, parent_builder, child, child_digest)
    calls = Any[]
    parse = parent_builder(seed(child, child_digest, calls))
    records = Any[]
    for _ in 1:2, row in cases["accept"]
        empty!(calls)
        result = parse(row["input"])
        composed(result, row, calls)
        push!(records, result)
    end
    empty!(calls)
    rejects(parse, "[12][00][7]", "staged_child_failed")
    exact_json(calls, [D("text" => "12", "top" => "Number"), D("text" => "00", "top" => "Number")])
    recovery = deepcopy(case_by_id(cases, "single_zero"))
    recovery["input"] = "[8]"; recovery["expected"][2]["text"] = "[8]"
    empty!(calls); result = parse("[8]"); composed(result, recovery, calls)
    for (change, code, count) in [("missing_identity", "staged_registry_missing", 0),
            ("forbidden_top", "staged_top_rule_forbidden", 0), ("no_budget", "staged_budget_exhausted", 0),
            ("one_call", "staged_call_limit_exceeded", 1)]
        changed = parent_builder(seed(child, child_digest, calls; change))
        empty!(calls); rejects(changed, "[1][2]", code)
        require(length(calls) == count, "callback count: $change")
    end
    first_result, second_result = parse("α[12]🙂"), parse("α[12]🙂")
    actual_result_isolation(first_result, second_result)
    aliased = deepcopy(second_result)
    caught_alias = false
    try
        actual_result_isolation(aliased, aliased)
    catch failure
        failure isa ErrorException && failure.msg == "actual child results alias" || rethrow()
        caught_alias = true
    end
    require(caught_alias, "the isolation oracle must reject deliberately aliased results")
    empty!(calls)
    result = parse("α[12]🙂")
    composed(result, case_by_id(cases, "unicode_edges"), calls)
    empty!(calls)
    inert = parent_builder(nothing)("α[12]🙂")
    exact_json(inert[2]["child"]["kind"], "STAGED_PARSE_JOB_MARKER")
    exact_json(inert[2]["child"]["staged_parse_job_v2"]["text"], "12")
    require(isempty(calls), "no seed executes no child")
    require(length(strict["accept"]) == 4 && length(strict["reject"]) == 15, "strict child inventory")
    for row in strict["accept"]
        exact_json(child(row["input"]), row["expected"])
    end
    for input in strict["reject"]
        rejected = false
        try
            child(input)
        catch failure
            failure isa RuntimeExitNow || rethrow()
            exact_json(failure.status, 1); rejected = true
        end
        require(rejected, "typed strict child rejection: $input")
    end
    return records
end

function child_mutation(id, parent_builder, child, child_digest)
    calls = Any[]
    parse = parent_builder(seed(child, child_digest, calls))
    if id == "leading_zero"
        result = parse("[00]")
        exact_json(result["ast"][2]["parsed"], D("kind" => "integer", "text" => "00",
            "span" => D("start" => 0, "end" => 2), "source_span" => D("kind" => "direct_span",
                "source_id" => "input", "start" => 1, "end" => 3, "provenance" => "entry_group")))
    elseif id == "wrong_span"
        result = parse("α[12]🙂")["ast"][2]["parsed"]
        exact_json(result["span"], D("start" => 1, "end" => 2))
        exact_json(result["source_span"], D("kind" => "direct_span", "source_id" => "input",
            "start" => 3, "end" => 4, "provenance" => "entry_group"))
    elseif id == "whole_item"
        rejects(parse, "α[12]🙂", "staged_child_failed")
        exact_json(calls, [D("text" => "[12]", "top" => "Number")])
    else
        error("unknown child mutation $id")
    end
    return true
end

function segment_mutation(id, cases, parse)
    row = case_by_id(cases, id == "selection" ? "single_zero" : id == "entry_prefix" ? "leading_lf" : "unicode_edges")
    expected = deepcopy(row["expected"])
    if id == "selection"
        expected = [D("kind" => "tail", "span" => D("source_id" => "input", "start" => 0,
            "end" => 3, "provenance" => "gap"), "text" => "[0]")]
    elseif id == "tail"
        pop!(expected)
    elseif id == "item_span"
        expected[2]["span"] = [5, 5]
    elseif id == "entry_prefix"
        popfirst!(expected)
    else
        error("unknown segmentation mutation $id")
    end
    exact_json(parse(row["input"]), expected)
    require(expected != row["expected"], "mutation differs from original oracle")
    return true
end

end
