using LinkedSpecJulia
using Test

@testset "LinkedSpecJulia scaffold" begin
    @test backend_name() == "julia"
    @test cli_entrypoint() == "julia/bin/linkedspec_julia.jl"
    @test corpus_runner_entrypoint() == "julia/bin/corpus_runner.jl"

    status = backend_status()
    @test status.backend == "julia"
    @test status.package == "LinkedSpecJulia"
    @test status.parity == "scaffold"

    cli_output = IOBuffer()
    cli_error = IOBuffer()
    @test run_cli(["--help"]; io = cli_output, err = cli_error) == 0
    @test occursin("LinkedSpec Julia backend", String(take!(cli_output)))
    @test isempty(String(take!(cli_error)))

    status_output = IOBuffer()
    @test run_cli(["status"]; io = status_output, err = IOBuffer()) == 0
    @test occursin("parity: scaffold", String(take!(status_output)))

    corpus_output = IOBuffer()
    corpus_error = IOBuffer()
    @test run_corpus_runner(["--corpus", "../rust/linkedspec-runtime/tests/corpus"];
        io = corpus_output,
        err = corpus_error,
    ) == 0
    @test occursin("JULIA-BACKEND-PARITY.1.3", String(take!(corpus_output)))
    @test isempty(String(take!(corpus_error)))

    execute_error = IOBuffer()
    @test run_corpus_runner(["--corpus", "fixtures", "--execute"]; io = IOBuffer(), err = execute_error) == 2
    @test occursin("not implemented", String(take!(execute_error)))
end
