using LinkedSpecJulia
using JSON3

function main(arguments)
    try
        length(arguments) >= 2 || throw(ArgumentError(
            "Usage: parse_words.jl GRAMMAR INPUT [INPUT ...]",
        ))
        # The managed Julia wrapper changes cwd; use an explicit application root.
        app_root = normpath(joinpath(@__DIR__, ".."))
        loaded = load_and_compile_spec(
            path_spec_request(arguments[1]),
            SpecLoadOptions(; cwd = app_root),
        )
        engine = create_engine(loaded)
        for input in arguments[2:end]
            # Compile once, then parse independent inputs in this Julia process.
            result = runtime_execute(engine, input; top_rule = "Top")
            println(JSON3.write(result.value))
        end
        return 0
    catch error
        if error isa InterruptException || error isa OutOfMemoryError || error isa StackOverflowError
            rethrow()
        end
        record = if error isa SpecPipelineException
            to_json(error)
        elseif error isa RuntimeInterpreterException
            merge(Dict("type" => "runtime_error"), to_json(error))
        else
            Dict("type" => "consumer_error", "detail" => sprint(showerror, error))
        end
        println(stderr, JSON3.write(record))
        return 1
    end
end

exit(main(ARGS))
