function _print_main_help(io)
    println(io, "LinkedSpec Julia backend")
    println(io)
    println(io, "Usage:")
    println(io, "  linkedspec_julia --help")
    println(io, "  linkedspec_julia status")
    println(io, "  linkedspec_julia corpus --corpus <path> [--execute] [--case <name> ...] [--offset <n>] [--limit <n>]")
end

function _print_status(io)
    status = backend_status()
    println(io, "backend: ", status.backend)
    println(io, "package: ", status.package)
    println(io, "version: ", status.version)
    println(io, "parity: ", status.parity)
    println(io, "cli: ", status.cli)
    println(io, "corpus_runner: ", status.corpus_runner)
end

function run_cli(args = ARGS; io = stdout, err = stderr)
    if isempty(args) || args == ["--help"] || args == ["-h"]
        _print_main_help(io)
        return 0
    end

    command = first(args)
    rest = args[2:end]
    if command == "status"
        if !isempty(rest)
            println(err, "error: status does not accept arguments")
            return 2
        end
        _print_status(io)
        return 0
    elseif command == "corpus"
        return run_corpus_runner(rest; io = io, err = err)
    end

    println(err, "error: unknown command: ", command)
    return 2
end
