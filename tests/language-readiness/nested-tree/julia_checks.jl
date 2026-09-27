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

function sequence(cases, parse)
    accepted, rejected = cases["accept"], cases["reject"]
    require(length(accepted) == 6 && length(rejected) == 7, "authored inventory")
    recovery = only(filter(row -> row["id"] == "nested_state", accepted))
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
                require(failure.status == 1, "$(row["id"]) exact exit status")
                typed_exit = true
            end
            require(typed_exit, "$(row["id"]) must reject without a value")
            exact_json(parse(recovery["input"]), recovery["expected"], "recovery after $(row["id"])")
            executions += 2
        end
    end
    require(executions == 40, "complete execution sequence")
    return executions
end

function mutation(id, cases, parse)
    group, case_id = if id == "prefix"
        "reject", "hidden_prefix"
    elseif id == "gap"
        "reject", "interstitial_junk"
    elseif id == "span"
        "accept", "nested_state"
    else
        error("unknown mutation $id")
    end
    row = only(filter(row -> row["id"] == case_id, cases[group]))
    value = parse(row["input"])
    require(value isa AbstractVector, "$id mutant must execute and return a document")
    if id == "span"
        exact_json(first(value)["span"], [9, 9])
        exact_json(first(row["expected"])["span"], [0, 9])
    else
        require(length(value) == (id == "prefix" ? 1 : 2), "$id mutant wrongly accepts forms")
    end
    return true
end

function variant(id, cases, parse)
    return id == "original" ? sequence(cases, parse) == 40 : mutation(id, cases, parse)
end

end
