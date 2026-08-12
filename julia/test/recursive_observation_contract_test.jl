# FUTURE-PARITY-BACKLOG.14.4.5 — Julia recursive-observation admission.
#
# Ordinary Julia discovery and canonical CI execute this exact consumer through
# repository-local project data. The implementation remains private: this adds
# no facade export, descriptor/schema revision, semantic/MCP projection, or CLI
# surface.

module JuliaRecursiveObservationAdmission

using JSON3
using LinkedSpecJulia
using Test

const JULIA_RECURSIVE_OBSERVATION_SOURCE = """Top::
 I {
  value = observe_recognition(observation, call(Child))
  return(array(value, observation))
 }

Child::AND
 /🙂/
 E { return(false) }
"""

function _julia_recursive_observation_compile(source::AbstractString)
    parsed = parse_spec_with_staged_user_function_definitions(source)
    validate_spec(parsed)
    return parsed, compile_spec(parsed)
end

function _julia_recursive_observation_objects(value)
    objects = Dict{String,Any}[]
    if value isa AbstractDict
        object = Dict{String,Any}(String(key) => child for (key, child) in pairs(value))
        push!(objects, object)
        for child in values(object)
            append!(objects, _julia_recursive_observation_objects(child))
        end
    elseif value isa AbstractVector
        for child in value
            append!(objects, _julia_recursive_observation_objects(child))
        end
    end
    return objects
end

function _julia_recursive_observation_kind(value, kind::AbstractString)
    return [
        object for object in _julia_recursive_observation_objects(value)
        if get(object, "kind", nothing) == kind
    ]
end

function _julia_recursive_observation_expected(;
    rule_label::AbstractString,
    invocation_id::Int,
    parent_invocation_id::Union{Nothing,Int},
    entry_offset::Int,
    selected_match::Union{Nothing,Tuple{Int,Int}} = nothing,
    accepted_exit::Union{Nothing,Int} = nothing,
    outcome::AbstractString,
    diagnostic::Union{Nothing,AbstractString} = nothing,
)
    return Dict{String,Any}(
        "source_id" => "input",
        "rule_label" => String(rule_label),
        "invocation_id" => invocation_id,
        "parent_invocation_id" => parent_invocation_id,
        "entry_position" => Dict{String,Any}(
            "source_id" => "input",
            "offset" => entry_offset,
        ),
        "selected_match" => selected_match === nothing ? nothing : Dict{String,Any}(
            "source_id" => "input",
            "start" => selected_match[1],
            "end" => selected_match[2],
            "provenance" => "match",
        ),
        "accepted_exit" => accepted_exit === nothing ? nothing : Dict{String,Any}(
            "source_id" => "input",
            "offset" => accepted_exit,
        ),
        "outcome" => String(outcome),
        "diagnostic" => diagnostic === nothing ? nothing : String(diagnostic),
    )
end

function _julia_recursive_observation_expect_error(
    needle::AbstractString,
    operation::Function,
)
    captured = try
        operation()
        nothing
    catch error
        error
    end
    @test captured !== nothing
    captured === nothing && return
    @test occursin(String(needle), sprint(showerror, captured))
end

function _julia_recursive_observation_execute_emitted(
    compiled::CompiledSpec,
    identity::AbstractString,
    input::AbstractString,
)
    emitted = emit_julia_source_v2(compiled, identity)
    host = Module(gensym(:JuliaRecursiveObservationHost))
    Base.include_string(host, emitted, "recursive_observation_generated.jl")
    parser = Base.invokelatest(() -> getfield(host, :LinkedSpecGeneratedParser))
    execute = Base.invokelatest(() -> getfield(parser, :execute))
    metadata = Base.invokelatest(() -> getfield(parser, :metadata))
    value = Base.invokelatest(execute, String(input))
    source_identity = Base.invokelatest(metadata).source_identity
    return value, source_identity
end

@testset "Julia recursive-observation contract" begin
    @testset "dedicated non-eager node and static policy are exact" begin
        _, compiled = _julia_recursive_observation_compile(
            JULIA_RECURSIVE_OBSERVATION_SOURCE,
        )
        top = compiled_rule(compiled, "Top")
        action = to_json(only(top.lifecycle_action_payloads).action_ast)
        observation = only(_julia_recursive_observation_kind(
            action,
            "observe_recognition",
        ))
        @test observation["target"] == "observation"
        @test observation["rule"] == "Child"
        @test isempty([
            object for object in _julia_recursive_observation_objects(action)
            if get(object, "kind", nothing) == "call" &&
               get(object, "name", nothing) == "Child"
        ])
        serialized = JSON3.write(to_json(compiled))
        @test length(collect(eachmatch(r"\"kind\":\"observe_recognition\"", serialized))) == 1

        fixtures = [
            (
                """Top:: I { value = observe_recognition(observation[\"nested\"], call(Child)) } Child::AND /x/""",
                "source_location_recursive_observation_target",
            ),
            (
                """Top:: I { value = observe_recognition(observation, dynamic_child) } Child::AND /x/""",
                "source_location_recursive_observation_operand",
            ),
            (
                """Top:: I { value = observe_recognition(observation, call(Missing)) }""",
                "source_location_recursive_observation_operand",
            ),
            (
                """Top::
 I {
  tx = recognition_checkpoint()
  matched = recognize_once(tx, call(Observer))
  recognition_rollback(tx)
  return(matched)
 }
Observer:
 I { value = observe_recognition(observation, call(Child)); return(value) }
Child::AND
 /x/
""",
                "recognition_effect_forbidden:binding_write",
            ),
            (
                """fn inspect() {
 value = observe_recognition(observation, call(Child))
 return(value)
}
Top::
 I {
  tx = recognition_checkpoint()
  matched = recognize_once(tx, call(Observer))
  recognition_rollback(tx)
  return(matched)
 }
Observer: I { return(inspect()) }
Child::AND
 /x/
""",
                "recognition_effect_forbidden:binding_write",
            ),
        ]
        for (source, diagnostic) in fixtures
            _julia_recursive_observation_expect_error(
                diagnostic,
                () -> _julia_recursive_observation_compile(source),
            )
        end
    end

    @testset "native and reconstructed carriers preserve false and detachment" begin
        parsed, compiled = _julia_recursive_observation_compile(
            JULIA_RECURSIVE_OBSERVATION_SOURCE,
        )
        expected = Any[
            false,
            _julia_recursive_observation_expected(
                rule_label = "Child",
                invocation_id = 2,
                parent_invocation_id = 1,
                entry_offset = 0,
                selected_match = (0, 1),
                accepted_exit = 1,
                outcome = "accepted",
            ),
        ]
        engine = LinkedSpecRuntimeEngine(compiled)
        first = runtime_parse(engine, "🙂").value
        @test first == expected
        first[2]["entry_position"]["offset"] = 99
        first[2]["selected_match"]["start"] = 99
        @test runtime_parse(engine, "🙂").value == expected

        normalized = JSON3.read(JSON3.write(to_json(parsed)), Dict{String,Any})
        reconstructed = from_json(SpecFile, normalized)
        validate_spec(reconstructed)
        @test runtime_parse(
            LinkedSpecRuntimeEngine(compile_spec(reconstructed)),
            "🙂",
        ).value == expected
    end

    @testset "failed zero-regex and action-edge cursor semantics are exact" begin
        _, failed = _julia_recursive_observation_compile("""Top::
 I { value = observe_recognition(observation, call(Missing)); return(array(value, observation)) }
Missing::AND
 /z/
""")
        @test runtime_parse(LinkedSpecRuntimeEngine(failed), "x").value == Any[
            nothing,
            _julia_recursive_observation_expected(
                rule_label = "Missing",
                invocation_id = 2,
                parent_invocation_id = 1,
                entry_offset = 0,
                outcome = "failed",
            ),
        ]

        _, zero = _julia_recursive_observation_compile("""Top::
 I { value = observe_recognition(observation, call(Coordinator)); return(array(value, observation)) }
Coordinator:
 I { return(\"coordinated\") }
""")
        @test runtime_parse(LinkedSpecRuntimeEngine(zero), "").value == Any[
            "coordinated",
            _julia_recursive_observation_expected(
                rule_label = "Coordinator",
                invocation_id = 2,
                parent_invocation_id = 1,
                entry_offset = 0,
                accepted_exit = 0,
                outcome = "accepted",
            ),
        ]

        _, edge = _julia_recursive_observation_compile("""Top::
 /a/ -> Top {
  value = observe_recognition(observation, call(Child))
  return(array(value, observation))
 }
Child::AND
 /b/
 /c/
 -> Child[0] { first = match_text() }
 -> Child[1] { return(array(entry_text(), entry_start_pos())) }
""")
        @test runtime_parse(LinkedSpecRuntimeEngine(edge), "abc").value == Any[
            Any["a", 0],
            _julia_recursive_observation_expected(
                rule_label = "Child",
                invocation_id = 2,
                parent_invocation_id = 1,
                entry_offset = 1,
                selected_match = (2, 3),
                accepted_exit = 3,
                outcome = "accepted",
            ),
        ]
    end

    @testset "direct and mutual nonprogress keep typed diagnostics" begin
        _, ordinary = _julia_recursive_observation_compile("""Top:: I { value = observe_recognition(observation, call(Child)); return(array(value, observation)) }
Child: I { nested = call(Child); return(\"guarded\") }
""")
        @test runtime_parse(LinkedSpecRuntimeEngine(ordinary), "").value == Any[
            "guarded",
            _julia_recursive_observation_expected(
                rule_label = "Child",
                invocation_id = 2,
                parent_invocation_id = 1,
                entry_offset = 0,
                accepted_exit = 0,
                outcome = "accepted",
            ),
        ]

        _, direct = _julia_recursive_observation_compile("""Top:: I { value = observe_recognition(top_observation, call(DirectRecur)); return(value) }
DirectRecur: I { value = observe_recognition(observation, call(DirectRecur)); return(value) }
""")
        _julia_recursive_observation_expect_error(
            "source_location_nonprogress_direct_recursion",
            () -> runtime_parse(LinkedSpecRuntimeEngine(direct), "x"),
        )

        _, mutual = _julia_recursive_observation_compile("""Top:: I { value = observe_recognition(top_observation, call(MutualA)); return(value) }
MutualA: I { value = observe_recognition(observation_a, call(MutualB)); return(value) }
MutualB: I { value = observe_recognition(observation_b, call(MutualA)); return(value) }
""")
        _julia_recursive_observation_expect_error(
            "source_location_nonprogress_mutual_recursion",
            () -> runtime_parse(LinkedSpecRuntimeEngine(mutual), "x"),
        )
    end

    @testset "aborted observation propagates the original runtime diagnostic" begin
        _, aborted = _julia_recursive_observation_compile("""Top::
 I { value = observe_recognition(observation, call(AbortChild)); return(value) }
AbortChild:
 I { recognition_commit(missing) }
""")
        _julia_recursive_observation_expect_error(
            "recognition_token_expected",
            () -> runtime_parse(LinkedSpecRuntimeEngine(aborted), ""),
        )
    end

    @testset "generated plan executes the same private observation runtime" begin
        _, compiled = _julia_recursive_observation_compile(
            JULIA_RECURSIVE_OBSERVATION_SOURCE,
        )
        @test execute_generated_parser_v2(
            compiled,
            build_generated_rule_plan(compiled),
            "🙂",
            "recursive-observation/julia.spec",
        ) == Any[
            false,
            _julia_recursive_observation_expected(
                rule_label = "Child",
                invocation_id = 2,
                parent_invocation_id = 1,
                entry_offset = 0,
                selected_match = (0, 1),
                accepted_exit = 1,
                outcome = "accepted",
            ),
        ]
    end

    @testset "independently loaded emitted source uses the same private runtime" begin
        _, compiled = _julia_recursive_observation_compile(
            JULIA_RECURSIVE_OBSERVATION_SOURCE,
        )
        identity = "recursive-observation/julia-emitted.spec"
        value, source_identity = _julia_recursive_observation_execute_emitted(
            compiled,
            identity,
            "🙂",
        )
        @test value == Any[
            false,
            _julia_recursive_observation_expected(
                rule_label = "Child",
                invocation_id = 2,
                parent_invocation_id = 1,
                entry_offset = 0,
                selected_match = (0, 1),
                accepted_exit = 1,
                outcome = "accepted",
            ),
        ]
        @test source_identity == identity
    end
end

end
