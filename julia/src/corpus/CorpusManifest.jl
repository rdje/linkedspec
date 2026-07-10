function _print_corpus_help(io)
    println(io, "LinkedSpec Julia corpus runner")
    println(io)
    println(io, "Usage:")
    println(io, "  corpus_runner --corpus <path> [--execute]")
end

function _parse_corpus_runner_args(args)
    corpus_path = nothing
    execute = false
    help = false
    unknown = String[]

    index = firstindex(args)
    while index <= lastindex(args)
        arg = args[index]
        if arg == "--help" || arg == "-h"
            help = true
            index += 1
        elseif arg == "--execute"
            execute = true
            index += 1
        elseif arg == "--corpus"
            next_index = index + 1
            if next_index > lastindex(args)
                push!(unknown, "--corpus requires a path")
                index += 1
            else
                corpus_path = args[next_index]
                index += 2
            end
        else
            push!(unknown, arg)
            index += 1
        end
    end

    return (; corpus_path, execute, help, unknown)
end

function run_corpus_runner(args = ARGS; io = stdout, err = stderr)
    parsed = _parse_corpus_runner_args(args)
    if parsed.help || isempty(args)
        _print_corpus_help(io)
        return 0
    end

    if !isempty(parsed.unknown)
        println(err, "error: unknown corpus argument: ", join(parsed.unknown, ", "))
        return 2
    end

    if parsed.corpus_path === nothing
        println(err, "error: --corpus <path> is required")
        return 2
    end

    if parsed.execute
        println(err, "error: corpus execution is not implemented in the Julia scaffold")
        return 2
    end

    println(io, "corpus: ", parsed.corpus_path)
    println(io, "status: scaffold only; manifest validation starts in JULIA-BACKEND-PARITY.1.3")
    return 0
end
