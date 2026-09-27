module LosslessChildCarriers

using LinkedSpecJulia, JSON3, Test
include(joinpath(@__DIR__, "julia_checks.jl"))
using .LosslessChildChecks: digest, exact_json
const C = LosslessChildChecks

function replace_once(source, from, to)
    @test length(findall(from, source)) == 1
    return replace(source, from => to)
end

function segment_variants(source)
    prefix = "  if(num_ne(cursor_pos(), 0));\n" *
        "   push(parts, hash(\"kind\", \"entry_prefix\", \"span\", [0, cursor_pos()], \"text\", input_slice(0, cursor_pos())))\n" *
        "  endif();\n"
    tail = " LX {\n  push(parts, hash(\"kind\", gap_kind(), \"span\", gap_span(), \"text\", gap_text()))\n"
    return ["selection" => replace_once(source, "[0-9]", "[1-9]"),
        "tail" => replace_once(source, tail, " LX {\n"),
        "item_span" => replace_once(source, "[entry_start_pos(), entry_end_pos()]", "[entry_end_pos(), entry_end_pos()]"),
        "entry_prefix" => replace_once(source, prefix, "")]
end

function child_variants(parent, child)
    return [("leading_zero", false, replace_once(child, "(0|[1-9][0-9]*)", "([0-9]+)")),
        ("wrong_span", false, replace_once(child, "\"start\", entry_start_pos()", "\"start\", num_add(entry_start_pos(), 1)")),
        ("whole_item", true, replace_once(parent, "parse_job(entry_group(0)", "parse_job(entry_text()"))]
end

function carriers(source, labels)
    parsed = parse_spec_with_staged_user_function_definitions(source)
    validate_spec(parsed)
    restored = from_json(SpecFile, JSON3.read(JSON3.write(to_json(parsed)), Dict{String,Any}))
    validate_spec(restored)
    routes = Function[]
    for spec in (parsed, restored)
        compiled = compile_spec(spec)
        plan = build_generated_rule_plan(compiled)
        validate_generated_rule_plan_v2(compiled, plan, "lossless/readiness")
        @test [row.label for row in plan] == labels
        let compiled = compiled, plan = plan
            push!(routes, seed -> begin
                engine = LinkedSpecRuntimeEngine(compiled; staged_ast_enrichment_seed = seed)
                input -> runtime_parse(engine, input).value
            end)
            # Public generated v2 creates an engine for every invocation.
            push!(routes, seed -> (input -> execute_generated_parser_v2(compiled, plan, input,
                "lossless/readiness"; staged_ast_enrichment_seed = seed)))
        end
    end
    return routes
end

function verify(repo_root, with_workspace, run_host)
    fixture = joinpath(repo_root, "tests", "language-readiness", "lossless-child")
    segment_fixture = joinpath(repo_root, "tests", "language-readiness", "lossless-segments")
    segments = read(joinpath(segment_fixture, "grammar.spec"), String)
    parent = read(joinpath(fixture, "parent.spec"), String)
    child = read(joinpath(fixture, "child.spec"), String)
    cases = JSON3.read(read(joinpath(segment_fixture, "cases.json"), String), Dict{String,Any})
    strict = JSON3.read(read(joinpath(fixture, "cases.json"), String), Dict{String,Any})
    segment_changes = segment_variants(segments)
    child_changes = child_variants(parent, child)

    @testset "four in-process matched lossless child carriers" begin
        segment_routes = carriers(segments, ["Item", "Segments"])
        parents = carriers(parent, ["Item", "Segments"])
        children = carriers(child, ["Number", "Digits"])
        records = nothing
        for route in 1:4
            @test C.segmentation(cases, segment_routes[route](nothing))
            observed = C.children(cases, strict, parents[route], children[route](nothing), digest(child))
            @test length(observed) == 26
            if records === nothing
                records = observed
            else
                @test exact_json(observed, records)
            end
        end
        for (id, source) in segment_changes
            for builder in carriers(source, ["Item", "Segments"])
                @test C.segment_mutation(id, cases, builder(nothing))
            end
        end
        for (id, is_parent, source) in child_changes
            routes = carriers(source, is_parent ? ["Item", "Segments"] : ["Number", "Digits"])
            for route in 1:4
                parent_builder = is_parent ? routes[route] : parents[route]
                child_parse = (is_parent ? children[route] : routes[route])(nothing)
                @test C.child_mutation(id, parent_builder, child_parse, digest(is_parent ? child : source))
            end
        end
    end

    @testset "fresh emitted lossless parent and actual children" begin
        with_workspace() do scratch
            private_depot = joinpath(scratch, "depot")
            mkpath(private_depot)
            write(joinpath(scratch, "Project.toml"), "name = \"LosslessChildGeneratedHost\"\nuuid = \"6888b502-d606-4b84-ac49-b43b5198b8b1\"\nversion = \"0.1.0\"\n")
            mkpath(joinpath(scratch, "checks", "lossless-child"))
            mkpath(joinpath(scratch, "checks", "nested-tree"))
            cp(joinpath(fixture, "julia_checks.jl"), joinpath(scratch, "checks", "lossless-child", "julia_checks.jl"))
            cp(joinpath(repo_root, "tests", "language-readiness", "nested-tree", "julia_checks.jl"),
                joinpath(scratch, "checks", "nested-tree", "julia_checks.jl"))
            cp(joinpath(segment_fixture, "cases.json"), joinpath(scratch, "cases.json"))
            cp(joinpath(fixture, "cases.json"), joinpath(scratch, "strict.json"))
            modules = ["segments" => segments, "parent" => parent, "child" => child]
            append!(modules, ["segment_$id" => source for (id, source) in segment_changes])
            append!(modules, [id => source for (id, _, source) in child_changes])
            config = Dict("ids" => first.(modules), "child_digest" => digest(child),
                "segment_mutations" => first.(segment_changes),
                "child_mutations" => [Dict("id" => id, "is_parent" => is_parent,
                    "digest" => digest(is_parent ? child : source)) for (id, is_parent, source) in child_changes])
            write(joinpath(scratch, "config.json"), JSON3.write(config))
            for (id, source) in modules
                parsed = parse_spec_with_staged_user_function_definitions(source)
                validate_spec(parsed)
                write(joinpath(scratch, "$id.jl"), emit_julia_source_v2(compile_spec(parsed), "lossless/$id"))
            end
            runner = joinpath(scratch, "runner.jl")
            write(runner, raw"""
using LinkedSpecJulia, JSON3
include(joinpath(ARGS[1], "checks", "lossless-child", "julia_checks.jl"))
const C = LosslessChildChecks
latest_binding(owner::Module, name::Symbol) = Base.invokelatest(() -> Core.getglobal(owner, name))
function main()
    cases = JSON3.read(read(joinpath(ARGS[1], "cases.json"), String), Dict{String,Any})
    strict = JSON3.read(read(joinpath(ARGS[1], "strict.json"), String), Dict{String,Any})
    config = JSON3.read(read(joinpath(ARGS[1], "config.json"), String), Dict{String,Any})
    builders = Dict{String,Function}()
    for id in config["ids"]
        host = Module(gensym(:LosslessGenerated))
        Base.include(host, joinpath(ARGS[1], "$id.jl"))
        parser = latest_binding(host, :LinkedSpecGeneratedParser)
        metadata = Base.invokelatest(latest_binding(parser, :metadata))
        C.exact_json(to_json(metadata), Dict("contract_id" => "linkedspec-generated-source-v2",
            "format_version" => 2, "source_identity" => "lossless/$id"))
        plan = Base.invokelatest(latest_binding(parser, :plan))
        Base.invokelatest(latest_binding(parser, :validate_plan), plan)
        let execute = latest_binding(parser, :execute)
            builders[id] = seed -> (input -> Base.invokelatest(execute, input; staged_ast_enrichment_seed = seed))
        end
    end
    @assert C.segmentation(cases, builders["segments"](nothing))
    records = C.children(cases, strict, builders["parent"], builders["child"](nothing), config["child_digest"])
    @assert length(records) == 26
    for id in config["segment_mutations"]
        @assert C.segment_mutation(id, cases, builders["segment_$id"](nothing))
    end
    for row in config["child_mutations"]
        parent = builders[row["is_parent"] ? row["id"] : "parent"]
        child = builders[row["is_parent"] ? "child" : row["id"]](nothing)
        @assert C.child_mutation(row["id"], parent, child, row["digest"])
    end
    print(JSON3.write(Dict("modules" => length(builders), "segmentation_cases" => 13,
        "child_accept" => 4, "child_reject" => 15, "mutations" => 7, "alias_control" => true)))
end
main()
""")
            passed, output = run_host(scratch, runner, scratch, private_depot)
            @test passed
            if passed
                @test exact_json(JSON3.read(output, Dict{String,Any}), Dict("modules" => 10,
                    "segmentation_cases" => 13, "child_accept" => 4, "child_reject" => 15,
                    "mutations" => 7, "alias_control" => true))
            else
                @error "lossless emitted host failed" output
            end
        end
    end
end

end
