# FUTURE-PARITY-BACKLOG.14.3.5.3 — admitted Julia recognition transactions.
#
# Ordinary Julia discovery and canonical CI execute this exact consumer through
# repository-local project data. The transaction namespace remains private.

using LinkedSpecJulia
using JSON3
using Test

const JULIA_RECOGNITION_TRANSACTION_CONTRACT = JSON3.read(
    read(
        normpath(
            joinpath(
                @__DIR__,
                "..",
                "..",
                "capability_conformance",
                "recognition_transaction_contract.json",
            ),
        ),
        String,
    ),
    Dict{String,Any},
)

# This namespace is deliberately private and must remain absent from the
# LinkedSpecJulia export list.
const JuliaRecognitionTransaction = getproperty(
    LinkedSpecJulia,
    :RecognitionTransaction,
)

const JULIA_RECOGNITION_AUTHORED_SOURCE = """Top::AND
 => Child {
  tx = recognition_checkpoint()
  matched = recognize_once(tx, call(Child))
  if(matched) {
   payload = recognition_commit(tx)
   return(payload)
  } else {
   recognition_rollback(tx)
   return("miss")
  }
 }

Child::AND
 /x/
 E { return(false) }
"""

const JULIA_RECOGNITION_ORDINARY_CURSOR_SOURCE = """Top::AND
 /a/ E {
  save_cursor()
  rewind_match_start()
  restore_cursor()
  return("ok")
 }
"""

function _julia_recognition_fixture_rows(key::AbstractString)
    return JULIA_RECOGNITION_TRANSACTION_CONTRACT["fixtures"][String(key)]
end

function _julia_recognition_object_rows(key::AbstractString)
    return JULIA_RECOGNITION_TRANSACTION_CONTRACT[String(key)]
end

function _julia_recognition_authority(source_identity::AbstractString)
    source_authority = LinkedSpecJulia.SourceLocation.SourceAuthority(
        sources = Dict{String,String}("input" => "abcdef"),
    )
    return JuliaRecognitionTransaction.RecognitionTransactionAuthority(
        source_authority = source_authority,
        source_identity = String(source_identity),
    )
end

function _julia_recognition_state(
    cursor::Int,
    boundary::Union{Nothing,Int},
    marks::AbstractDict,
)
    return JuliaRecognitionTransaction.RecognitionFrameState(
        cursor = cursor,
        boundary = boundary,
        marks = Dict{String,Int}(String(name) => Int(offset) for (name, offset) in marks),
    )
end

_julia_recognition_initial_state() =
    _julia_recognition_state(2, 1, Dict{String,Int}("a" => 1))

_julia_recognition_staged_state() = _julia_recognition_state(
    5,
    4,
    Dict{String,Int}("a" => 3, "b" => 4),
)

function _julia_recognition_frame_state(authority, frame)
    snapshot = JuliaRecognitionTransaction.to_json(
        JuliaRecognitionTransaction.frame_snapshot(authority, frame),
    )
    return Dict{String,Any}(
        "cursor" => snapshot["cursor"],
        "boundary" => snapshot["boundary"],
        "marks" => snapshot["marks"],
    )
end

function _julia_recognition_expect_diagnostic(
    code::AbstractString,
    operation::Function,
    expected::AbstractDict,
)
    captured = try
        operation()
        nothing
    catch error
        error
    end
    @test captured isa JuliaRecognitionTransaction.RecognitionTransactionException
    captured isa JuliaRecognitionTransaction.RecognitionTransactionException || return

    record = JuliaRecognitionTransaction.to_json(captured)
    fixture = only(
        row for row in _julia_recognition_object_rows("diagnostics")
        if row["code"] == code
    )
    @test Set(String.(keys(record))) == Set(String.(fixture["fields"]))
    @test record["code"] == code
    for (key, value) in expected
        @test record[String(key)] == value
    end
    @test sprint(showerror, captured) ==
          "LINKEDSPEC_RECOGNITION_TRANSACTION_ERROR:$code"
end

function _julia_recognition_payload(operation::AbstractString)
    operation == "attempt_match:false" && return false
    operation == "attempt_match:0" && return 0
    operation == "attempt_match:" && return ""
    operation == "attempt_match:null" && return nothing
    operation == "attempt_match:value" && return "value"
    error("unowned matched-payload operation $operation")
end

function _julia_recognition_all_objects(value)
    objects = Dict{String,Any}[]
    if value isa AbstractDict
        object = Dict{String,Any}(String(key) => child for (key, child) in value)
        push!(objects, object)
        for child in values(object)
            append!(objects, _julia_recognition_all_objects(child))
        end
    elseif value isa AbstractVector
        for child in value
            append!(objects, _julia_recognition_all_objects(child))
        end
    end
    return objects
end

function _julia_recognition_objects_with_kind(value, kind::AbstractString)
    return [
        object for object in _julia_recognition_all_objects(value)
        if get(object, "kind", nothing) == kind
    ]
end

function _julia_recognition_compile(source::AbstractString)
    parsed = parse_spec(source)
    validate_spec(parsed)
    return parsed, compile_spec(parsed)
end

function _julia_recognition_execute_emitted(
    compiled::CompiledSpec,
    identity::AbstractString,
    input::AbstractString,
)
    emitted = emit_julia_source_v2(compiled, identity)
    host = Module(gensym(:JuliaRecognitionTransactionHost))
    Base.include_string(host, emitted, "recognition_transaction_generated.jl")
    parser = Base.invokelatest(() -> getfield(host, :LinkedSpecGeneratedParser))
    execute = Base.invokelatest(() -> getfield(parser, :execute))
    metadata = Base.invokelatest(() -> getfield(parser, :metadata))
    value = Base.invokelatest(execute, String(input))
    source_identity = Base.invokelatest(metadata).source_identity
    return value, source_identity
end

@testset "Julia admitted recognition-transaction contract" begin
    @testset "neutral contract and admitted Julia boundary are exact" begin
        contract = JULIA_RECOGNITION_TRANSACTION_CONTRACT
        @test contract["contract_id"] == "linkedspec-recognition-transaction-v1"
        @test contract["format"] == 1
        @test contract["status"] ==
              "neutral_through_recurring_complete_public_no_drift_red"

        counts = contract["expected_counts"]
        @test counts["current_action_ir_nodes"] == 128
        @test counts["dedicated_action_ir_nodes"] == 4
        @test counts["all_action_ir_nodes"] == 132
        @test counts["canonical_call_contracts"] == 246
        @test counts["token_positive_cases"] == 8
        @test counts["token_negative_cases"] == 17
        @test counts["effect_graph_cases"] == 6
        @test counts["mark_cases"] == 6
        @test counts["progress_cases"] == 8
        @test counts["diagnostics"] == 15
        @test counts["mutations"] == 58

        @test contract["authored_surface"] == Dict{String,Any}(
            "checkpoint" => "tx = recognition_checkpoint()",
            "attempt" => "matched = recognize_once(tx, call(Child))",
            "commit" => "payload = recognition_commit(tx)",
            "rollback" => "recognition_rollback(tx)",
            "operand" =>
                "recognize_once accepts exactly one unevaluated static call(Rule) operand",
            "result_separation" =>
                "recognize_once returns a strict match boolean; the recognized payload remains staged until commit",
            "availability" =>
                "available in Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT; exact recurring proof is current and public no-drift remains future and unavailable",
        )

        rollout = contract["rollout"]
        @test length(rollout) == 9
        @test [row["leg"] for row in rollout[1:5]] ==
              ["neutral", "perl", "rust", "dart", "julia"]
        @test all(row["status"] == "complete" for row in rollout[1:5])
        @test rollout[5] == Dict{String,Any}(
            "order" => 5,
            "owner" => "FUTURE-PARITY-BACKLOG.14.3.5",
            "leg" => "julia",
            "status" => "complete",
            "paths" => Any["julia/test/recognition_transaction_contract_test.jl"],
        )
        @test rollout[6] == Dict{String,Any}(
            "order" => 6,
            "owner" => "FUTURE-PARITY-BACKLOG.14.3.6",
            "leg" => "puc_lua",
            "status" => "complete",
            "paths" => Any["lua/test/recognition_transaction_contract_test.lua"],
        )
        @test rollout[7] == Dict{String,Any}(
            "order" => 7,
            "owner" => "FUTURE-PARITY-BACKLOG.14.3.6",
            "leg" => "luajit",
            "status" => "complete",
            "paths" => Any["lua/test/recognition_transaction_contract_test.lua"],
        )
        @test rollout[8] == Dict{String,Any}(
            "order" => 8,
            "owner" => "FUTURE-PARITY-BACKLOG.14.3.7",
            "leg" => "recurring",
            "status" => "complete",
            "paths" => Any["tools/check_recognition_transaction_six_runtime.sh"],
        )
        @test rollout[9]["leg"] == "public_no_drift"
        @test rollout[9]["status"] == "red"
    end

    @testset "invocation identities and same-label marks are isolated" begin
        authority = _julia_recognition_authority("input.spec")
        parent = JuliaRecognitionTransaction.enter_invocation(
            authority;
            rule = "Top",
            origin = "root",
            state = _julia_recognition_initial_state(),
        )
        JuliaRecognitionTransaction.write_mark!(authority, parent, "shared", 1)
        parent_snapshot = JuliaRecognitionTransaction.to_json(
            JuliaRecognitionTransaction.frame_snapshot(authority, parent),
        )

        child = JuliaRecognitionTransaction.enter_invocation(
            authority;
            rule = "Top",
            origin = "Top->Top",
            state = _julia_recognition_state(3, 2, Dict{String,Int}()),
        )
        child_snapshot = JuliaRecognitionTransaction.to_json(
            JuliaRecognitionTransaction.frame_snapshot(authority, child),
        )
        @test child_snapshot["invocation"] > parent_snapshot["invocation"]
        @test child_snapshot["generation"] > parent_snapshot["generation"]
        @test JuliaRecognitionTransaction.read_mark(authority, child, "shared") ===
              nothing
        JuliaRecognitionTransaction.write_mark!(authority, child, "shared", 4)
        @test JuliaRecognitionTransaction.read_mark(authority, parent, "shared") == 1
        JuliaRecognitionTransaction.leave_invocation!(authority, child)

        next = JuliaRecognitionTransaction.enter_invocation(
            authority;
            rule = "Top",
            origin = "Top->Top:next",
            state = _julia_recognition_state(3, 2, Dict{String,Int}()),
        )
        next_snapshot = JuliaRecognitionTransaction.to_json(
            JuliaRecognitionTransaction.frame_snapshot(authority, next),
        )
        @test next_snapshot["invocation"] > child_snapshot["invocation"]
        @test next_snapshot["generation"] > child_snapshot["generation"]
        JuliaRecognitionTransaction.leave_invocation!(authority, next)

        detached_marks = parent_snapshot["marks"]
        detached_marks["shared"] = 99
        @test JuliaRecognitionTransaction.read_mark(authority, parent, "shared") == 1
        JuliaRecognitionTransaction.leave_invocation!(authority, parent)
        _julia_recognition_expect_diagnostic(
            "recognition_mark_generation_invalid",
            () -> JuliaRecognitionTransaction.frame_snapshot(authority, parent),
            Dict{String,Any}(
                "rule" => "Top",
                "origin" => "root",
                "generation" => parent_snapshot["generation"],
            ),
        )
    end

    @testset "all eight positive tokens preserve falsey staged payloads" begin
        for fixture in _julia_recognition_fixture_rows("token_positive")
            authority = _julia_recognition_authority("input.spec")
            id = String(fixture["id"])
            frame = JuliaRecognitionTransaction.enter_invocation(
                authority;
                rule = "Top",
                origin = id,
                state = _julia_recognition_initial_state(),
            )
            token = JuliaRecognitionTransaction.checkpoint(authority, frame, id)
            operations = String.(fixture["ops"])
            attempt_operation = only(filter(op -> startswith(op, "attempt_"), operations))
            matched = attempt_operation != "attempt_miss"
            payload = matched ? _julia_recognition_payload(attempt_operation) : nothing
            @test JuliaRecognitionTransaction.attempt!(
                authority,
                frame,
                token;
                matched = matched,
                payload = payload,
                state = matched ?
                    _julia_recognition_staged_state() :
                    _julia_recognition_initial_state(),
            ) == matched

            if last(operations) == "commit"
                @test JuliaRecognitionTransaction.commit!(authority, frame, token) == payload
            else
                @test JuliaRecognitionTransaction.rollback!(authority, frame, token) === nothing
            end
            JuliaRecognitionTransaction.leave_invocation!(authority, frame)
        end
    end

    @testset "commit retains and rollback restores detached frame state" begin
        for fixture in _julia_recognition_fixture_rows("marks")[1:2]
            authority = _julia_recognition_authority("input.spec")
            id = String(fixture["id"])
            frame = JuliaRecognitionTransaction.enter_invocation(
                authority;
                rule = "Top",
                origin = id,
                state = _julia_recognition_initial_state(),
            )
            token = JuliaRecognitionTransaction.checkpoint(authority, frame, id)
            JuliaRecognitionTransaction.attempt!(
                authority,
                frame,
                token;
                matched = true,
                payload = "payload",
                state = _julia_recognition_staged_state(),
            )
            if fixture["terminal"] == "commit"
                JuliaRecognitionTransaction.commit!(authority, frame, token)
            else
                JuliaRecognitionTransaction.rollback!(authority, frame, token)
            end
            @test _julia_recognition_frame_state(authority, frame) == fixture["expected"]
            JuliaRecognitionTransaction.leave_invocation!(authority, frame)
        end
    end

    @testset "escape and lifecycle failures use portable diagnostics" begin
        escapes = Set([
            "copy",
            "comparison",
            "aggregate_storage",
            "function_storage",
            "codeblock_storage",
            "return",
            "capture",
            "serialization",
        ])
        for fixture in _julia_recognition_fixture_rows("token_negative")
            escape = get(fixture, "violation", nothing)
            escape in escapes || continue
            authority = _julia_recognition_authority("input.spec")
            id = String(fixture["id"])
            frame = JuliaRecognitionTransaction.enter_invocation(
                authority;
                rule = "Top",
                origin = id,
                state = _julia_recognition_initial_state(),
            )
            token = JuliaRecognitionTransaction.checkpoint(authority, frame, id)
            _julia_recognition_expect_diagnostic(
                "recognition_token_escape",
                () -> JuliaRecognitionTransaction.reject_escape(
                    authority,
                    frame,
                    token,
                    String(escape),
                ),
                Dict{String,Any}(
                    "rule" => "Top",
                    "origin" => id,
                    "escape" => escape,
                ),
            )
            JuliaRecognitionTransaction.leave_invocation!(authority, frame)
        end

        missing_authority = _julia_recognition_authority("input.spec")
        missing_frame = JuliaRecognitionTransaction.enter_invocation(
            missing_authority;
            rule = "Top",
            origin = "missing_attempt",
            state = _julia_recognition_initial_state(),
        )
        missing_token = JuliaRecognitionTransaction.checkpoint(
            missing_authority,
            missing_frame,
            "missing_attempt",
        )
        _julia_recognition_expect_diagnostic(
            "recognition_attempt_count",
            () -> JuliaRecognitionTransaction.rollback!(
                missing_authority,
                missing_frame,
                missing_token,
            ),
            Dict{String,Any}(
                "rule" => "Top",
                "origin" => "missing_attempt",
                "count" => 0,
            ),
        )
        JuliaRecognitionTransaction.leave_invocation!(missing_authority, missing_frame)

        retry_authority = _julia_recognition_authority("input.spec")
        retry_frame = JuliaRecognitionTransaction.enter_invocation(
            retry_authority;
            rule = "Top",
            origin = "retry",
            state = _julia_recognition_initial_state(),
        )
        retry_token = JuliaRecognitionTransaction.checkpoint(
            retry_authority,
            retry_frame,
            "retry",
        )
        JuliaRecognitionTransaction.attempt!(
            retry_authority,
            retry_frame,
            retry_token;
            matched = false,
            payload = nothing,
            state = _julia_recognition_initial_state(),
        )
        _julia_recognition_expect_diagnostic(
            "recognition_attempt_count",
            () -> JuliaRecognitionTransaction.attempt!(
                retry_authority,
                retry_frame,
                retry_token;
                matched = true,
                payload = "value",
                state = _julia_recognition_staged_state(),
            ),
            Dict{String,Any}(
                "rule" => "Top",
                "origin" => "retry",
                "count" => 2,
            ),
        )
        JuliaRecognitionTransaction.leave_invocation!(retry_authority, retry_frame)
    end

    @testset "cross-owner nesting reuse discard and unwind restore" begin
        invocation_authority = _julia_recognition_authority("input.spec")
        parent = JuliaRecognitionTransaction.enter_invocation(
            invocation_authority;
            rule = "Top",
            origin = "parent",
            state = _julia_recognition_initial_state(),
        )
        parent_token = JuliaRecognitionTransaction.checkpoint(
            invocation_authority,
            parent,
            "parent",
        )
        child = JuliaRecognitionTransaction.enter_invocation(
            invocation_authority;
            rule = "Top",
            origin = "child",
            state = _julia_recognition_initial_state(),
        )
        _julia_recognition_expect_diagnostic(
            "recognition_cross_invocation",
            () -> JuliaRecognitionTransaction.rollback!(
                invocation_authority,
                child,
                parent_token,
            ),
            Dict{String,Any}("rule" => "Top", "origin" => "child"),
        )
        JuliaRecognitionTransaction.leave_invocation!(invocation_authority, child)
        JuliaRecognitionTransaction.leave_invocation!(invocation_authority, parent)

        first = _julia_recognition_authority("first.spec")
        first_frame = JuliaRecognitionTransaction.enter_invocation(
            first;
            rule = "Top",
            origin = "cross_source",
            state = _julia_recognition_initial_state(),
        )
        first_token = JuliaRecognitionTransaction.checkpoint(
            first,
            first_frame,
            "cross_source",
        )
        second = _julia_recognition_authority("second.spec")
        second_frame = JuliaRecognitionTransaction.enter_invocation(
            second;
            rule = "Top",
            origin = "cross_source",
            state = _julia_recognition_initial_state(),
        )
        _julia_recognition_expect_diagnostic(
            "recognition_cross_source",
            () -> JuliaRecognitionTransaction.rollback!(
                second,
                second_frame,
                first_token,
            ),
            Dict{String,Any}("rule" => "Top", "origin" => "cross_source"),
        )
        JuliaRecognitionTransaction.leave_invocation!(second, second_frame)
        JuliaRecognitionTransaction.leave_invocation!(first, first_frame)

        reuse_authority = _julia_recognition_authority("input.spec")
        reuse_frame = JuliaRecognitionTransaction.enter_invocation(
            reuse_authority;
            rule = "Top",
            origin = "double_terminal",
            state = _julia_recognition_initial_state(),
        )
        reuse_token = JuliaRecognitionTransaction.checkpoint(
            reuse_authority,
            reuse_frame,
            "double_terminal",
        )
        JuliaRecognitionTransaction.attempt!(
            reuse_authority,
            reuse_frame,
            reuse_token;
            matched = true,
            payload = "value",
            state = _julia_recognition_staged_state(),
        )
        JuliaRecognitionTransaction.commit!(reuse_authority, reuse_frame, reuse_token)
        _julia_recognition_expect_diagnostic(
            "recognition_token_reused",
            () -> JuliaRecognitionTransaction.rollback!(
                reuse_authority,
                reuse_frame,
                reuse_token,
            ),
            Dict{String,Any}(
                "rule" => "Top",
                "origin" => "double_terminal",
                "operation" => "rollback",
            ),
        )
        JuliaRecognitionTransaction.leave_invocation!(reuse_authority, reuse_frame)

        nesting_authority = _julia_recognition_authority("input.spec")
        nesting_parent = JuliaRecognitionTransaction.enter_invocation(
            nesting_authority;
            rule = "Top",
            origin = "nesting_parent",
            state = _julia_recognition_initial_state(),
        )
        nesting_before = _julia_recognition_frame_state(
            nesting_authority,
            nesting_parent,
        )
        nesting_token = JuliaRecognitionTransaction.checkpoint(
            nesting_authority,
            nesting_parent,
            "nesting_parent",
        )
        JuliaRecognitionTransaction.attempt!(
            nesting_authority,
            nesting_parent,
            nesting_token;
            matched = true,
            payload = "value",
            state = _julia_recognition_staged_state(),
        )
        nesting_child = JuliaRecognitionTransaction.enter_invocation(
            nesting_authority;
            rule = "Child",
            origin = "nesting_child",
            state = _julia_recognition_state(3, 2, Dict{String,Int}()),
        )
        _julia_recognition_expect_diagnostic(
            "recognition_nesting_forbidden",
            () -> JuliaRecognitionTransaction.checkpoint(
                nesting_authority,
                nesting_child,
                "nesting_child",
            ),
            Dict{String,Any}("rule" => "Child", "origin" => "nesting_child"),
        )
        @test _julia_recognition_frame_state(nesting_authority, nesting_parent) ==
              nesting_before
        JuliaRecognitionTransaction.leave_invocation!(nesting_authority, nesting_child)
        JuliaRecognitionTransaction.leave_invocation!(nesting_authority, nesting_parent)

        discard_authority = _julia_recognition_authority("input.spec")
        discard_frame = JuliaRecognitionTransaction.enter_invocation(
            discard_authority;
            rule = "Top",
            origin = "discard",
            state = _julia_recognition_initial_state(),
        )
        discard_before = _julia_recognition_frame_state(discard_authority, discard_frame)
        discard_token = JuliaRecognitionTransaction.checkpoint(
            discard_authority,
            discard_frame,
            "discard",
        )
        JuliaRecognitionTransaction.attempt!(
            discard_authority,
            discard_frame,
            discard_token;
            matched = true,
            payload = "value",
            state = _julia_recognition_staged_state(),
        )
        JuliaRecognitionTransaction.discard_token!(
            discard_authority,
            discard_frame,
            discard_token,
        )
        @test _julia_recognition_frame_state(discard_authority, discard_frame) ==
              discard_before
        JuliaRecognitionTransaction.leave_invocation!(discard_authority, discard_frame)

        unwind_authority = _julia_recognition_authority("input.spec")
        unwind_frame = JuliaRecognitionTransaction.enter_invocation(
            unwind_authority;
            rule = "Top",
            origin = "unwind",
            state = _julia_recognition_initial_state(),
        )
        unwind_token = JuliaRecognitionTransaction.checkpoint(
            unwind_authority,
            unwind_frame,
            "unwind",
        )
        JuliaRecognitionTransaction.attempt!(
            unwind_authority,
            unwind_frame,
            unwind_token;
            matched = true,
            payload = "value",
            state = _julia_recognition_staged_state(),
        )
        _julia_recognition_expect_diagnostic(
            "recognition_terminal_required",
            () -> JuliaRecognitionTransaction.leave_invocation!(
                unwind_authority,
                unwind_frame,
            ),
            Dict{String,Any}("rule" => "Top", "origin" => "unwind"),
        )
    end

    @testset "authored forms lower to four dedicated non-eager nodes" begin
        _, compiled = _julia_recognition_compile(
            JULIA_RECOGNITION_AUTHORED_SOURCE,
        )
        top = compiled_rule(compiled, "Top")
        payload = only(top.blind_edges).action_payload
        action = to_json(payload.action_ast)
        expected = Dict(
            "recognition_checkpoint" => 1,
            "recognize_once" => 1,
            "recognition_commit" => 1,
            "recognition_rollback" => 1,
        )
        for (kind, count) in expected
            @test length(_julia_recognition_objects_with_kind(action, kind)) == count
        end
        attempt = only(
            _julia_recognition_objects_with_kind(action, "recognize_once"),
        )
        @test attempt["token"] == "tx"
        @test attempt["rule"] == "Child"
        @test isempty([
            object for object in _julia_recognition_all_objects(action)
            if get(object, "kind", nothing) == "call" &&
               get(object, "name", nothing) == "Child"
        ])
    end

    @testset "effect closure and cursor-only progress are exact" begin
        authority = _julia_recognition_authority("input.spec")
        for graph in _julia_recognition_fixture_rows("effect_graphs")
            if graph["accepted"]
                @test JuliaRecognitionTransaction.classify_effects(authority, graph) ===
                      nothing
            else
                _julia_recognition_expect_diagnostic(
                    String(graph["diagnostic"]),
                    () -> JuliaRecognitionTransaction.classify_effects(
                        authority,
                        graph,
                    ),
                    Dict{String,Any}(),
                )
            end
        end
        for fixture in _julia_recognition_fixture_rows("progress")
            if fixture["accepted"]
                @test JuliaRecognitionTransaction.validate_progress(
                    authority,
                    fixture,
                ) === nothing
            else
                _julia_recognition_expect_diagnostic(
                    String(fixture["diagnostic"]),
                    () -> JuliaRecognitionTransaction.validate_progress(
                        authority,
                        fixture,
                    ),
                    Dict{String,Any}(),
                )
            end
        end
    end

    @testset "native reconstructed and generated-plan carriers preserve false" begin
        parsed, compiled = _julia_recognition_compile(
            JULIA_RECOGNITION_AUTHORED_SOURCE,
        )
        @test runtime_parse(LinkedSpecRuntimeEngine(compiled), "xx").value === false

        normalized = JSON3.read(
            JSON3.write(to_json(parsed)),
            Dict{String,Any},
        )
        reconstructed = from_json(SpecFile, normalized)
        validate_spec(reconstructed)
        reconstructed_compiled = compile_spec(reconstructed)
        @test runtime_parse(
            LinkedSpecRuntimeEngine(reconstructed_compiled),
            "xx",
        ).value === false
        @test execute_generated_parser_v2(
            compiled,
            build_generated_rule_plan(compiled),
            "xx",
            "recognition-transaction/julia.spec",
        ) === false

        _, ordinary = _julia_recognition_compile(
            JULIA_RECOGNITION_ORDINARY_CURSOR_SOURCE,
        )
        @test runtime_parse(LinkedSpecRuntimeEngine(ordinary), "a").value == "ok"
    end

    @testset "independently loaded emitted module uses the same runtime" begin
        _, compiled = _julia_recognition_compile(
            JULIA_RECOGNITION_AUTHORED_SOURCE,
        )
        identity = "recognition-transaction/julia-emitted.spec"
        value, source_identity = _julia_recognition_execute_emitted(
            compiled,
            identity,
            "xx",
        )
        @test value === false
        @test source_identity == identity
    end
end
