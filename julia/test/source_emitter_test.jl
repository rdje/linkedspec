function _generated_source_test_spec()
    value = string("λ:", Char(0x24))
    source = "Top::\n /é/\n E { return(" * String(JSON3.write(value)) * ") }\n"
    return compile_spec(parse_spec(source)), value
end

function _generated_source_host_process(scratch, runner, generated, private_depot)
    separator = Sys.iswindows() ? ';' : ':'
    parent_depot = get(ENV, "JULIA_DEPOT_PATH", "")
    depot_path = isempty(parent_depot) ?
        private_depot : string(private_depot, separator, parent_depot)
    load_path = join(
        [scratch, joinpath(REPO_ROOT, "julia"), "@stdlib"],
        separator,
    )
    command = `$(Base.julia_cmd()) --project=$scratch --startup-file=no --history-file=no --compiled-modules=no $runner $generated`
    environment = copy(ENV)
    environment["JULIA_DEPOT_PATH"] = depot_path
    environment["JULIA_LOAD_PATH"] = load_path
    environment["JULIA_PKG_OFFLINE"] = "true"
    output = IOBuffer()
    process = run(
        pipeline(ignorestatus(setenv(command, environment)); stdout = output, stderr = output),
    )
    return success(process), String(take!(output))
end

@testset "Generated Julia source scaffold" begin
    compiled, expected_value = _generated_source_test_spec()
    identity = string("generated/λ", Char(0x24), ".spec")
    generated = emit_julia_source_v1(compiled, identity)
    inline_generated = emit_julia_source(compiled)

    @test generated == emit_julia_source_v1(compiled, identity)
    @test generated != emit_julia_source_v1(compiled, "generated/other.spec")
    @test generated == replace(
        inline_generated,
        bytes2hex(codeunits("<inline>")) => bytes2hex(codeunits(identity)),
    )
    @test occursin("module LinkedSpecGeneratedParser", generated)
    @test occursin(bytes2hex(codeunits(identity)), generated)
    @test occursin(bytes2hex(codeunits(expected_value)), generated)
    @test !occursin(identity, generated)

    metadata = GeneratedSourceMetadata(identity)
    @test to_json(metadata) == Dict(
        "contract_id" => "linkedspec-generated-source-v1",
        "format_version" => 1,
        "source_identity" => identity,
    )

    empty_identity_error = try
        emit_julia_source_v1(compiled, "")
        nothing
    catch error
        error
    end
    @test empty_identity_error isa GeneratedSourceException
    @test to_json(empty_identity_error) == Dict(
        "type" => "generated_source_error",
        "stage" => "emit_source",
        "code" => "generated_source_emit_failed",
        "summary" => "Generated Julia source identity must not be empty",
        "source_identity" => "",
        "detail" => "source_identity is required",
    )

    compile_error = generated_source_compile_failed(identity, ArgumentError("broken payload"))
    @test generated_source_stage_name(compile_error.stage) ==
          "compile_or_load_generated_source"
    @test generated_source_code_name(compile_error.code) ==
          "generated_source_compile_failed"
    @test sprint(showerror, compile_error) ==
          "Generated Julia source failed to compile or load: ArgumentError: broken payload"

    mktempdir() do scratch
        private_depot = joinpath(scratch, "depot")
        mkpath(private_depot)
        write(
            joinpath(scratch, "Project.toml"),
            "name = \"GeneratedSourceHost\"\n" *
            "uuid = \"4096c05b-8f48-4ee1-89a1-52480dbf986d\"\n" *
            "version = \"0.1.0\"\n",
        )
        generated_path = joinpath(scratch, "generated_parser.jl")
        runner_path = joinpath(scratch, "runner.jl")
        write(generated_path, generated)
        write(
            runner_path,
            """
import LinkedSpecJulia
include(ARGS[1])

const Parser = LinkedSpecGeneratedParser
expected_identity = string("generated/λ", Char(0x24), ".spec")
expected_value = string("λ:", Char(0x24))
@assert Parser.LINKEDSPEC_GENERATED_SOURCE_CONTRACT == "linkedspec-generated-source-v1"
@assert Parser.LINKEDSPEC_GENERATED_SOURCE_FORMAT == 1
@assert LinkedSpecJulia.to_json(Parser.metadata()) == Dict(
    "contract_id" => "linkedspec-generated-source-v1",
    "format_version" => 1,
    "source_identity" => expected_identity,
)
@assert Parser.execute("é") == expected_value

execution_error = try
    Parser.execute("é"; top_rule = "Missing")
    nothing
catch error
    error
end
@assert execution_error isa LinkedSpecJulia.GeneratedSourceException
@assert LinkedSpecJulia.generated_source_stage_name(execution_error.stage) == "execute_generated"
@assert LinkedSpecJulia.generated_source_code_name(execution_error.code) == "generated_execution_failed"
print("generated-host-ok")
""",
        )

        passed, output = _generated_source_host_process(
            scratch,
            runner_path,
            generated_path,
            private_depot,
        )
        @test passed
        @test output == "generated-host-ok"

        corrupt_path = joinpath(scratch, "corrupt_parser.jl")
        corrupt_source = replace(
            generated,
            r"const _COMPILED_SPEC_JSON_HEX = \"[0-9a-f]+\"" =>
                "const _COMPILED_SPEC_JSON_HEX = \"00\"",
        )
        @test corrupt_source != generated
        write(corrupt_path, corrupt_source)
        write(
            runner_path,
            """
import LinkedSpecJulia
failure = try
    include(ARGS[1])
    nothing
catch error
    while error isa LoadError
        error = error.error
    end
    error
end
@assert failure isa LinkedSpecJulia.GeneratedSourceException
projection = LinkedSpecJulia.to_json(failure)
@assert projection["type"] == "generated_source_error"
@assert projection["stage"] == "compile_or_load_generated_source"
@assert projection["code"] == "generated_source_compile_failed"
@assert projection["source_identity"] == string("generated/λ", Char(0x24), ".spec")
print("generated-failure-ok")
""",
        )
        failed_as_expected, failure_output = _generated_source_host_process(
            scratch,
            runner_path,
            corrupt_path,
            private_depot,
        )
        @test failed_as_expected
        @test failure_output == "generated-failure-ok"
    end
end
