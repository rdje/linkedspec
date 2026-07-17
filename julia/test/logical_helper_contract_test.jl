using JSON3
using LinkedSpecJulia
using Test

const LOGICAL_HELPER_REPO_ROOT = normpath(joinpath(@__DIR__, "..", ".."))
const LOGICAL_HELPER_CONTRACT = JSON3.read(
    read(
        joinpath(
            LOGICAL_HELPER_REPO_ROOT,
            "capability_conformance",
            "logical_helper_contract.json",
        ),
        String,
    ),
    Dict{String,Any},
)

function _logical_helper_fixture(id::AbstractString)
    return LOGICAL_HELPER_CONTRACT["fixtures"][String(id)]
end

function _logical_helper_case(rows, id::AbstractString)
    return only(row for row in rows if row["id"] == id)
end

function _logical_helper_compile(source::AbstractString)
    return compile_spec(parse_spec(source))
end

function _logical_helper_reconstruct(compiled::CompiledSpec, identity::AbstractString)
    emitted = emit_julia_source_v1(compiled, identity)
    encoded = match(r"const _COMPILED_SPEC_JSON_HEX = \"([^\"]+)\"", emitted)
    @assert encoded !== nothing
    normalized = JSON3.read(
        String(hex2bytes(only(encoded.captures))),
        Dict{String,Any},
    )
    return compile_spec(from_json(SpecFile, normalized))
end

function _logical_helper_runtime_value(value)
    kind = value["kind"]
    if kind == "null"
        return nothing
    elseif kind in ("boolean", "number", "string")
        return value["value"]
    elseif kind == "array"
        return Any[_logical_helper_runtime_value(item) for item in value["items"]]
    elseif kind == "harray"
        return Dict{String,Any}(
            String(key) => _logical_helper_runtime_value(item) for
            (key, item) in pairs(value["entries"])
        )
    elseif kind == "codeblock"
        return parse_action_block("fail(\"codeblock must not run\")")
    end
    error("unsupported logical-helper value kind $kind")
end

function _logical_helper_native_failure(compiled::CompiledSpec)
    try
        runtime_parse(LinkedSpecRuntimeEngine(compiled), "x")
    catch error
        return error
    end
    return nothing
end

function _logical_helper_generated_failure(compiled::CompiledSpec, identity::AbstractString)
    try
        execute_generated_parser_v1(
            compiled,
            build_generated_rule_plan(compiled),
            "x",
            identity,
        )
    catch error
        return error
    end
    return nothing
end

function _expect_logical_helper_arity_failure(error, row)
    @test error isa RuntimeInterpreterException
    error isa RuntimeInterpreterException || return
    @test error.diagnostic !== nothing
    error.diagnostic === nothing && return
    diagnostic = to_json(error.diagnostic)
    @test diagnostic["stage"] == "helper_arity_mismatch"
    @test diagnostic["code"] == row["expected_code"]
    @test diagnostic["helper_name"] == row["helper_name"]
    @test diagnostic["actual_arity"] == row["actual_arity"]
    @test diagnostic["expected_arity"] == row["expected_arity"]
    @test diagnostic["rule_label"] == "Top"
    @test occursin("helper_arity_mismatch", error.message)
    @test occursin("helper_name=$(row["helper_name"])", error.message)
    @test occursin("actual_arity=$(row["actual_arity"])", error.message)
    @test !occursin("must not run", error.message)
end

function _expect_logical_helper_generated_arity_failure(error, row)
    @test error isa GeneratedSourceException
    error isa GeneratedSourceException || return
    @test error.stage == ExecuteGeneratedStage
    @test error.code == GeneratedExecutionFailedCode
    detail = something(error.detail, "")
    @test occursin("helper_arity_mismatch", detail)
    @test occursin("helper_name=$(row["helper_name"])", detail)
    @test occursin("actual_arity=$(row["actual_arity"])", detail)
    @test !occursin("must not run", detail)
end

function _logical_helper_primary(source::AbstractString)
    output = IOBuffer()
    error_output = IOBuffer()
    status = run_cli(
        ["--inline-spec", String(source), "--input", "x"];
        io = output,
        err = error_output,
    )
    return status, String(take!(output)), String(take!(error_output))
end

function _logical_helper_emitted_host_process(scratch, runner, private_depot)
    separator = Sys.iswindows() ? ';' : ':'
    parent_depot = get(ENV, "JULIA_DEPOT_PATH", "")
    depot_path = isempty(parent_depot) ?
        private_depot : string(private_depot, separator, parent_depot)
    load_path = join(
        [scratch, joinpath(LOGICAL_HELPER_REPO_ROOT, "julia"), "@stdlib"],
        separator,
    )
    command = `$(Base.julia_cmd()) --project=$scratch --startup-file=no --history-file=no --compiled-modules=no $runner`
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

@testset "Neutral logical-helper contract" begin
    @testset "exact authority and typed truth seam" begin
        @test LOGICAL_HELPER_CONTRACT["format"] == 1
        @test LOGICAL_HELPER_CONTRACT["contract_id"] == "linkedspec-logical-helper-v1"
        @test length(LOGICAL_HELPER_CONTRACT["truthiness_cases"]) == 17
        @test length(LOGICAL_HELPER_CONTRACT["helper_cases"]) == 10

        for row in LOGICAL_HELPER_CONTRACT["truthiness_cases"]
            @test LinkedSpecJulia._runtime_truthy(
                _logical_helper_runtime_value(row["value"]),
            ) == row["expected"]
        end
    end

    for fixture_id in ("values", "effects", "receiver_and_lazy_control")
        @testset "$fixture_id native normalized generated and primary" begin
            fixture = _logical_helper_fixture(fixture_id)
            compiled = _logical_helper_compile(fixture["spec_source"])
            expected = fixture["expected"]

            @test runtime_parse(LinkedSpecRuntimeEngine(compiled), "x").value == expected

            reconstructed = _logical_helper_reconstruct(
                compiled,
                "logical-helper/$fixture_id-normalized.spec",
            )
            @test runtime_parse(LinkedSpecRuntimeEngine(reconstructed), "x").value == expected

            @test execute_generated_parser_v1(
                compiled,
                build_generated_rule_plan(compiled),
                "x",
                "logical-helper/$fixture_id-generated.spec",
            ) == expected

            status, output, error_output = _logical_helper_primary(fixture["spec_source"])
            @test status == 0
            @test isempty(error_output)
            @test JSON3.read(output, Dict{String,Any}) == expected
        end
    end

    invalid_rows = LOGICAL_HELPER_CONTRACT["invalid_arity_cases"]
    for fixture in LOGICAL_HELPER_CONTRACT["fixtures"]["invalid_arity"]
        id = fixture["id"]
        row = _logical_helper_case(invalid_rows, id)
        @testset "$id rejects before effects on every in-process role" begin
            compiled = _logical_helper_compile(fixture["spec_source"])
            _expect_logical_helper_arity_failure(
                _logical_helper_native_failure(compiled),
                row,
            )

            reconstructed = _logical_helper_reconstruct(
                compiled,
                "logical-helper/$id-normalized.spec",
            )
            _expect_logical_helper_arity_failure(
                _logical_helper_native_failure(reconstructed),
                row,
            )

            _expect_logical_helper_generated_arity_failure(
                _logical_helper_generated_failure(
                    compiled,
                    "logical-helper/$id-generated.spec",
                ),
                row,
            )

            status, output, error_output = _logical_helper_primary(fixture["spec_source"])
            @test status == 1
            @test isempty(output)
            @test error_output == "linkedspec: parser invocation failed\n"
        end
    end

    @testset "independently compiled emitted modules" begin
        mktempdir() do scratch
            private_depot = joinpath(scratch, "depot")
            mkpath(private_depot)
            write(
                joinpath(scratch, "Project.toml"),
                "name = \"LogicalHelperGeneratedHost\"\n" *
                "uuid = \"e55afcb2-a313-4f91-a87d-f85713590eec\"\n" *
                "version = \"0.1.0\"\n",
            )

            for fixture_id in ("values", "effects", "receiver_and_lazy_control")
                fixture = _logical_helper_fixture(fixture_id)
                write(
                    joinpath(scratch, "$fixture_id.jl"),
                    emit_julia_source_v1(
                        _logical_helper_compile(fixture["spec_source"]),
                        "logical-helper/$fixture_id-emitted.spec",
                    ),
                )
            end
            invalid_fixture = _logical_helper_case(
                LOGICAL_HELPER_CONTRACT["fixtures"]["invalid_arity"],
                "not_many",
            )
            write(
                joinpath(scratch, "invalid.jl"),
                emit_julia_source_v1(
                    _logical_helper_compile(invalid_fixture["spec_source"]),
                    "logical-helper/not_many-emitted.spec",
                ),
            )
            write(
                joinpath(scratch, "expected.json"),
                JSON3.write(Dict(
                    fixture_id => _logical_helper_fixture(fixture_id)["expected"] for
                    fixture_id in ("values", "effects", "receiver_and_lazy_control")
                )),
            )
            runner = joinpath(scratch, "runner.jl")
            write(
                runner,
                raw"""
import JSON3
import LinkedSpecJulia

module LogicalValues
include(joinpath(@__DIR__, "values.jl"))
end
module LogicalEffects
include(joinpath(@__DIR__, "effects.jl"))
end
module LogicalReceiver
include(joinpath(@__DIR__, "receiver_and_lazy_control.jl"))
end
module LogicalInvalid
include(joinpath(@__DIR__, "invalid.jl"))
end

expected = JSON3.read(read(joinpath(@__DIR__, "expected.json"), String), Dict{String,Any})
@assert LogicalValues.LinkedSpecGeneratedParser.execute("x") == expected["values"]
@assert LogicalEffects.LinkedSpecGeneratedParser.execute("x") == expected["effects"]
@assert LogicalReceiver.LinkedSpecGeneratedParser.execute("x") == expected["receiver_and_lazy_control"]

failure = try
    LogicalInvalid.LinkedSpecGeneratedParser.execute("x")
    nothing
catch error
    error
end
@assert failure isa LinkedSpecJulia.GeneratedSourceException
@assert LinkedSpecJulia.generated_source_stage_name(failure.stage) == "execute_generated"
@assert LinkedSpecJulia.generated_source_code_name(failure.code) == "generated_execution_failed"
detail = something(failure.detail, "")
@assert occursin("helper_arity_mismatch", detail)
@assert occursin("helper_name=not", detail)
@assert occursin("actual_arity=2", detail)
@assert !occursin("must not run", detail)
print("logical-helper-emitted-host-ok")
""",
            )

            passed, output = _logical_helper_emitted_host_process(
                scratch,
                runner,
                private_depot,
            )
            @test passed
            @test output == "logical-helper-emitted-host-ok"
        end
    end
end
