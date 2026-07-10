module LinkedSpecJulia

export backend_name,
    backend_status,
    cli_entrypoint,
    corpus_runner_entrypoint,
    run_cli,
    run_corpus_runner

const BACKEND_NAME = "julia"
const PACKAGE_NAME = "LinkedSpecJulia"
const PACKAGE_VERSION = v"0.1.0"
const CLI_ENTRYPOINT = "julia/bin/linkedspec_julia.jl"
const CORPUS_RUNNER_ENTRYPOINT = "julia/bin/corpus_runner.jl"
const PARITY_STATUS = "scaffold"

include("corpus/CorpusManifest.jl")
include("cli/LinkedSpecJuliaCli.jl")

backend_name() = BACKEND_NAME
cli_entrypoint() = CLI_ENTRYPOINT
corpus_runner_entrypoint() = CORPUS_RUNNER_ENTRYPOINT

function backend_status()
    return (;
        backend = BACKEND_NAME,
        package = PACKAGE_NAME,
        version = string(PACKAGE_VERSION),
        parity = PARITY_STATUS,
        cli = CLI_ENTRYPOINT,
        corpus_runner = CORPUS_RUNNER_ENTRYPOINT,
    )
end

end
