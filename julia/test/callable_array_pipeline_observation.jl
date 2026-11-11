module JuliaCallablePipelineObservation
using LinkedSpecJulia

export observe, strict_equal

function observe(operation)
    try
        Dict{String,Any}("value" => operation())
    catch failure
        row = Dict{String,Any}(
            "error" => sprint(showerror, failure),
            "class" => string(nameof(typeof(failure))),
        )
        if failure isa Union{RuntimeInterpreterException,GeneratedSourceException}
            row["error_json"] = to_json(failure)
        end
        row
    end
end

function strict_equal(actual, expected)
    if expected isa Bool
        return actual === expected
    elseif expected isa Number
        return actual isa Number && !(actual isa Bool) && actual == expected
    elseif expected === nothing
        return actual === nothing
    elseif expected isa AbstractString
        return actual isa AbstractString && actual == expected
    elseif expected isa AbstractVector
        return actual isa AbstractVector && length(actual) == length(expected) &&
            all(strict_equal(a, e) for (a, e) in zip(actual, expected))
    elseif expected isa AbstractDict
        return actual isa AbstractDict && Set(keys(actual)) == Set(keys(expected)) &&
            all(strict_equal(actual[key], value) for (key, value) in expected)
    end
    error("unexpected callable pipeline fixture kind $(typeof(expected))")
end
end # module
