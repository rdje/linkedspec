module NestedTreeChecks

using LinkedSpecJulia

function require(condition, message)
    condition || error(message)
    return true
end

function exact_json(actual, expected, path = "root")
    if expected isa AbstractDict
        require(actual isa AbstractDict, "$path must be an object")
        require(Set(keys(actual)) == Set(keys(expected)), "$path object keys")
        for key in keys(expected)
            exact_json(actual[key], expected[key], "$path.$key")
        end
    elseif expected isa AbstractVector
        require(actual isa AbstractVector, "$path must be an array")
        require(length(actual) == length(expected), "$path array size")
        for index in eachindex(expected)
            exact_json(actual[index], expected[index], "$path[$index]")
        end
    else
        # Bool is a Number in Julia; JSON booleans and numbers remain distinct.
        same_kind = if expected === nothing
            actual === nothing
        elseif expected isa Bool
            actual isa Bool
        elseif expected isa Number
            actual isa Number && !(actual isa Bool)
        elseif expected isa AbstractString
            actual isa AbstractString
        else
            error("non-JSON oracle at $path")
        end
        require(same_kind && actual == expected, "$path expected $expected, received $actual")
    end
    return true
end

function sequence(cases, parse; accepted_count = 6, rejected_count = 7, recovery_id = "nested_state")
    accepted, rejected = cases["accept"], cases["reject"]
    require(length(accepted) == accepted_count && length(rejected) == rejected_count, "authored inventory")
    recovery = only(filter(row -> row["id"] == recovery_id, accepted))
    executions = 0
    for _ in 1:2
        for row in accepted
            exact_json(parse(row["input"]), row["expected"], row["id"])
            executions += 1
        end
        for row in rejected
            typed_exit = false
            try
                parse(row["input"])
            catch failure
                failure isa RuntimeExitNow || rethrow()
                require(failure.status == get(row, "status", 1), "$(row["id"]) exact exit status")
                typed_exit = true
            end
            require(typed_exit, "$(row["id"]) must reject without a value")
            exact_json(parse(recovery["input"]), recovery["expected"], "recovery after $(row["id"])")
            executions += 2
        end
    end
    require(executions == 2 * (accepted_count + 2 * rejected_count), "complete execution sequence")
    return executions
end

function mutation(id, cases, parse; span_case = "nested_state", span_end = 9)
    find_case(group, case_id) = only(filter(row -> row["id"] == case_id, cases[group]))
    if id == "comparison"
        return exact_json(parse(find_case("reject", "mismatch")["input"]),
            find_case("accept", "empty_element")["expected"], "comparison mutant")
    elseif id == "state"
        typed_exit = false
        try
            parse(find_case("accept", "siblings_restore_parent")["input"])
        catch failure
            failure isa RuntimeExitNow || rethrow()
            require(failure.status == 2, "state mutant exact mismatch status")
            typed_exit = true
        end
        return require(typed_exit, "state mutant wrongly rejects valid siblings")
    end
    group, case_id = if id == "prefix"
        "reject", "hidden_prefix"
    elseif id == "gap"
        "reject", "interstitial_junk"
    elseif id == "span"
        "accept", span_case
    else
        error("unknown mutation $id")
    end
    row = only(filter(row -> row["id"] == case_id, cases[group]))
    value = parse(row["input"])
    require(value isa AbstractVector, "$id mutant must execute and return a document")
    if id == "span"
        exact_json(first(value)["span"], [span_end, span_end])
        exact_json(first(row["expected"])["span"], [0, span_end])
    else
        require(length(value) == (id == "prefix" ? 1 : 2), "$id mutant wrongly accepts forms")
    end
    return true
end

function variant(id, cases, parse; accepted_count = 6, rejected_count = 7,
    recovery_id = "nested_state", span_case = "nested_state", span_end = 9)
    if id == "original"
        return sequence(cases, parse; accepted_count, rejected_count, recovery_id) ==
            2 * (accepted_count + 2 * rejected_count)
    end
    return mutation(id, cases, parse; span_case, span_end)
end

end
