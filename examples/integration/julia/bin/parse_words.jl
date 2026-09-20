using LinkedSpecJulia
using JSON3

function main(arguments)
    try
        offset = 1
        diagnostics = !isempty(arguments) && arguments[1] == "--diagnostics"
        diagnostics && (offset += 1)
        if offset <= length(arguments) && arguments[offset] == "--"
            offset += 1
        end
        length(arguments) - offset >= 1 || throw(ArgumentError(
            "Usage: parse_words.jl [--diagnostics] [--] GRAMMAR INPUT [INPUT ...]",
        ))
        # The managed Julia wrapper changes cwd; use an explicit application root.
        app_root = normpath(joinpath(@__DIR__, ".."))
        loaded = load_and_compile_spec(
            path_spec_request(arguments[offset]),
            SpecLoadOptions(; cwd = app_root),
        )
        engine = create_engine(loaded)
        sink = if diagnostics
            event -> println(stderr, JSON3.write(
                merge(Dict("type" => "diagnostic_output"), to_json(event)),
            ))
        else
            nothing
        end
        for input in arguments[(offset + 1):end]
            # Compile once, then parse independent inputs in this Julia process.
            result = runtime_execute(engine, input;
                top_rule = "Top", diagnostic_output_sink = sink,
            )
            println(JSON3.write(result.value))
        end
        return 0
    catch error
        if error isa InterruptException || error isa OutOfMemoryError || error isa StackOverflowError
            rethrow()
        end
        record = if error isa SpecPipelineException
            to_json(error)
        elseif error isa RuntimeExitNow
            # Process status is application policy; retain the grammar's status.
            Dict("type" => "runtime_exit_now", "status" => error.status)
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
