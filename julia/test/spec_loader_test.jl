const NATIVE_SPEC_RESOLUTION_CONTRACT = JSON3.read(
    read(
        joinpath(
            REPO_ROOT,
            "capability_conformance",
            "native_spec_resolution_contract.json",
        ),
        String,
    ),
    Dict{String,Any},
)

const NATIVE_SPEC_USER_FUNCTION_SOURCE = """fn label() {return(\"hit\")}

Top::
 /x/
 E { return(label()) }
"""

function _native_spec_fixture_path(root::AbstractString, portable_path::AbstractString)
    return joinpath(String(root), split(String(portable_path), '/')...)
end

function _write_native_spec_entry(root::AbstractString, entry)
    path = _native_spec_fixture_path(root, entry["path"])
    if entry["kind"] == "file"
        mkpath(dirname(path))
        write(path, "fixture")
    elseif entry["kind"] in ("directory", "non_regular")
        mkpath(path)
    else
        error("unsupported native spec fixture kind $(entry["kind"])")
    end
end

function _native_spec_pipeline_failure(operation)
    try
        operation()
    catch error
        @test error isa SpecPipelineException
        return error
    end
    error("native spec operation unexpectedly succeeded")
end

@testset "Native spec name validation contract" begin
    for case in NATIVE_SPEC_RESOLUTION_CONTRACT["name_validation_cases"]
        expected = case["expect"]
        request = named_spec_request(case["value"])
        if expected["status"] == "ok"
            @test validate_spec_request(request) === nothing
        else
            failure = _native_spec_pipeline_failure(
                () -> validate_spec_request(request),
            )
            @test spec_pipeline_stage_name(failure.stage) == expected["stage"]
            @test spec_pipeline_code_name(failure.code) == expected["code"]
        end
    end
end

@testset "Native spec resolution and file-kind contract" begin
    for case in NATIVE_SPEC_RESOLUTION_CONTRACT["resolution_cases"]
        mktempdir() do scratch
            foreach(entry -> _write_native_spec_entry(scratch, entry), case["entries"])
            cwd = _native_spec_fixture_path(scratch, case["cwd"])
            mkpath(cwd)
            options = SpecLoadOptions(
                cwd;
                search_roots = [
                    _native_spec_fixture_path(scratch, root)
                    for root in case["search_roots"]
                ],
            )
            request = case["request"]["kind"] == "name" ?
                named_spec_request(case["request"]["value"]) :
                path_spec_request(case["request"]["value"])
            expected = case["expect"]
            if expected["status"] == "ok"
                resolved = resolve_spec(request, options)
                @test resolved.path == _native_spec_fixture_path(scratch, expected["path"])
                @test resolved.origin == expected["origin"]
            else
                failure = _native_spec_pipeline_failure(
                    () -> resolve_spec(request, options),
                )
                @test spec_pipeline_stage_name(failure.stage) == expected["stage"]
                @test spec_pipeline_code_name(failure.code) == expected["code"]
                expected_path = get(expected, "resolved_path", nothing)
                @test failure.resolved_path == (
                    expected_path === nothing ?
                    nothing : _native_spec_fixture_path(scratch, expected_path)
                )
            end
        end
    end
end

@testset "Native spec strict UTF-8 contract" begin
    for case in NATIVE_SPEC_RESOLUTION_CONTRACT["text_cases"]
        mktempdir() do scratch
            write(joinpath(scratch, "source.spec"), hex2bytes(case["bytes_hex"]))
            result = try
                load_spec(path_spec_request("source.spec"), SpecLoadOptions(scratch))
            catch error
                error
            end
            expected = case["expect"]
            if expected["status"] == "ok"
                @test result isa LoadedSpec
                @test result.source_text == expected["text"]
            else
                @test result isa SpecPipelineException
                @test spec_pipeline_stage_name(result.stage) == expected["stage"]
                @test spec_pipeline_code_name(result.code) == expected["code"]
            end
        end
    end
end

@testset "Native spec full pipeline and engine identity" begin
    mktempdir() do scratch
        specs = joinpath(scratch, "specs")
        mkpath(specs)
        path = joinpath(specs, "Demo.spec")
        write(path, NATIVE_SPEC_USER_FUNCTION_SOURCE)
        loaded = load_and_compile_spec(
            named_spec_request("Demo"),
            SpecLoadOptions(joinpath(scratch, "cwd"); search_roots = [specs]),
        )

        @test loaded.loaded.source_text == NATIVE_SPEC_USER_FUNCTION_SOURCE
        @test loaded.loaded.resolved.path == path
        @test length(compiled_functions(loaded.compiled)) == 1
        engine = create_engine(loaded)
        @test engine.spec_name == "Demo"
        @test engine.spec_path == path
        @test runtime_execute(engine, "x").value == "hit"
    end
end

@testset "Native spec structured pipeline failures" begin
    mktempdir() do scratch
        write(joinpath(scratch, "parse.spec"), "not a spec\n")
        write(joinpath(scratch, "validation.spec"), "Only::\n /x/\n\nOnly:\n /y/\n")
        options = SpecLoadOptions(scratch)

        parse_failure = _native_spec_pipeline_failure(
            () -> load_and_compile_spec(path_spec_request("parse.spec"), options),
        )
        @test parse_failure.stage == ParseSpecStage
        @test parse_failure.code == SpecParseFailedCode

        validation_failure = _native_spec_pipeline_failure(
            () -> load_and_compile_spec(path_spec_request("validation.spec"), options),
        )
        @test validation_failure.stage == ValidateSpecStage
        @test validation_failure.code == SpecValidationFailedCode

        missing = _native_spec_pipeline_failure(
            () -> resolve_spec(named_spec_request("Missing"), options),
        )
        @test to_json(missing) == Dict(
            "type" => "spec_pipeline_error",
            "stage" => "resolve_spec_path",
            "code" => "spec_path_not_found",
            "summary" => "Spec path not found",
            "request_kind" => "name",
            "requested" => "Missing",
        )
    end
end
