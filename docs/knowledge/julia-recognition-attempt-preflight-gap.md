---
id: julia-recognition-attempt-preflight-gap
title: Julia validates recognition tokens after executing their requested child
answers:
  - "does Julia validate a recognition token before child execution"
  - "can Julia recognize_once run a child with a missing token"
  - "does Julia execute a second child before rejecting a repeated recognition attempt"
  - "what happens when Julia recognize_once uses a committed token"
  - "which task owns Julia recognition attempt preflight"
date: 2026-09-11
status: confirmed-open
tags: [julia, recognition, transaction, token, observation, JULIA-STARTUP-READING]
evidence: "JULIA-STARTUP-READING.1.15; activation 867f5cc8be3699fbd0cab40fd3c02988d97a6258; Interpreter3856-3871 and1039-1075; RecognitionTransaction770-801; 80 assertions across16 source/route combinations"
reverify: "Run JULIA_TOKEN_PREFLIGHT15 below; assertions describe pre-repair child execution before rejection."
---

# Attempt checks follow child execution

`ActionRecognizeOnceExpr` dispatches the requested child, assigns `context.retv`,
and only then calls `_runtime_recognition_attempt!`. That adapter first looks up
the token slot, then the private authority checks token ownership/status and
whether an attempt already happened. These checks run too late to prevent an
invalid request from entering the child.

The portable contract [[cursor-transaction-authored-contract]] requires a linear
token with exactly one attempt, primarily rejected statically and defended at
runtime. All four ordinary authored sources below compile. `Child::AND` consumes
exactly one `x`; its slot event establishes execution without a forbidden authored
side effect. Input is `xx` and the nonthrowing public observer retains slot positions.

| Case | Observed child positions | Outcome |
| --- | --- | --- |
| Checkpoint, one attempt, commit | 1 | value ok; one final Top event |
| No checkpoint/token | 1 | recognition_token_expected |
| Same token attempted twice | 1, 2 | recognition_attempt_count |
| Attempt after successful commit | 1, 2 | recognition_token_expected |

The first invalid case should not enter Child; the other two should not enter it
a second time. Native parse and its traced convenience wrap the authority error in
RuntimeInterpreterException; validated generated-plan conveniences translate it
into GeneratedSourceException. All 16 combinations agree, with 80 assertions. Traced
conveniences use disabled tracing; enabled trace closure, fresh emitted modules,
other backends and post-error private frame contents were not measured.

An initial default-mode Child consumed both input characters in its first call;
that established missing-token late rejection but could not distinguish a second
matching child. The exact AND-mode control below removes that ambiguity. Existing
recognition 207 assertions and neutral 138/250/58 with rollout 9/9 remain green.

Julia .2.7.1/.2.7.2 own preflight, static-sequence reconciliation and full supported-
route proof after startup .3/.4/.5. Effect classification .2.3, semantic callback
passthrough .2.6 and startup .38 obsolete-snapshot restoration have separate causes.
No runtime or test source changed during this diagnostic.

## Exact replay

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_TOKEN_PREFLIGHT15'
using LinkedSpecJulia, JSON3, Test
cases = [
    ("valid", "tx = recognition_checkpoint(); matched = recognize_once(tx, call(Child)); return(recognition_commit(tx))", nothing, [1]),
    ("missing", "return(recognize_once(tx, call(Child)))", "recognition_token_expected", [1]),
    ("repeated", "tx = recognition_checkpoint(); matched = recognize_once(tx, call(Child)); return(recognize_once(tx, call(Child)))", "recognition_attempt_count", [1,2]),
    ("after_commit", "tx = recognition_checkpoint(); matched = recognize_once(tx, call(Child)); value = recognition_commit(tx); return(recognize_once(tx, call(Child)))", "recognition_token_expected", [1,2]),
]
@testset "Julia recognition token preflight diagnostic" begin
    for (name, body, code, positions) in cases
        source = "Top::\n I { " * body * " }\nChild::AND\n /x/\n E { return(\"ok\") }\n"
        compiled = compile_spec(parse_spec(source))
        engine = LinkedSpecRuntimeEngine(compiled)
        plan = build_generated_rule_plan(compiled)
        routes = [
            ("native", sink -> runtime_parse(engine, "xx"; semantic_observation_sink=sink)),
            ("traced", sink -> runtime_parse_with_trace(engine, "xx", trace_config_disabled(); semantic_observation_sink=sink)),
            ("plan", sink -> execute_generated_parser_v2(compiled, plan, "xx", "reading-token.spec"; semantic_observation_sink=sink)),
            ("plan_traced", sink -> execute_generated_parser_with_trace_v2(compiled, plan, "xx", trace_config_disabled(), "reading-token.spec"; semantic_observation_sink=sink)),
        ]
        for (route, run) in routes
            events = Any[]
            value = nothing
            error = try
                value = run(event -> push!(events, to_json(event)))
                nothing
            catch error
                error
            end
            slots = [event for event in events if event["event_kind"] == "regex_slot_selected"]
            @test [event["position"] for event in slots] == positions
            @test all(event["rule_label"] == "Child" for event in slots)
            @test count(event -> event["event_kind"] == "rule_result", events) == (code === nothing ? 1 : 0)
            if code === nothing
                @test error === nothing
                @test (route in ["native", "traced"] ? value.value : value) == "ok"
            else
                @test error isa (route in ["native", "traced"] ? RuntimeInterpreterException : GeneratedSourceException)
                @test occursin("LINKEDSPEC_RECOGNITION_TRANSACTION_ERROR:" * code, sprint(showerror, error))
            end
            println(JSON3.write(Dict("case"=>name, "route"=>route,
                "child_positions"=>positions, "code"=>code)))
        end
    end
end
include("julia/test/recognition_transaction_contract_test.jl")
JULIA_TOKEN_PREFLIGHT15
bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py
```
