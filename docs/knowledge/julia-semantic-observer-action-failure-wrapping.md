---
id: julia-semantic-observer-action-failure-wrapping
title: Julia action child calls replace semantic observer exceptions
answers:
  - "does Julia preserve semantic observer failures inside action child calls"
  - "why does Julia wrap a semantic callback as RuntimeInterpreterException"
  - "why does a generated Julia parser translate an observer exception"
  - "which task owns Julia semantic callback exception identity loss"
date: 2026-09-11
status: confirmed-open
tags: [julia, semantic-introspection, observation, callback, errors, JULIA-STARTUP-READING]
evidence: "JULIA-STARTUP-READING.1.14; Interpreter1616-3115; SourceEmitter285-319; six source/event cases through four public routes; repair .2.6.1/.2.6.2"
reverify: "Run the managed JULIA_OBSERVER_ACTION14 fence below; assertions describe the current pre-repair boundary."
---

# Semantic callback identity is lost inside action child calls

At clean activation `ef676281fa8841dedcfaf5f3951d009d4088a95a`, the Julia
runtime marks the original observer exception at Interpreter2716-2729.
The catch in `_execute_runtime_action_block!` (2871-2883) recognizes other control
and sink failures, but does not recognize this marked semantic failure. It creates
`RuntimeInterpreterException` with the original printed message. The outer parse
and generated-plan catches test identity against the retained original object;
that comparison fails after wrapping. Generated execution consequently translates
it again into `GeneratedSourceException`.

| Source / failure event | Native and traced parse | Generated-plan and traced plan |
| --- | --- | --- |
| Direct Top / selected slot | Original caller object | Original caller object |
| Direct Top / final result | Original caller object | Original caller object |
| Blind-dispatched Child / selected slot | Original caller object | Original caller object |
| Top I `return(call(Child))` / Child slot | RuntimeInterpreterException | GeneratedSourceException |
| Same explicit call / final Top result | Original caller object | Original caller object |
| Same explicit call / nonthrowing observer | Matched result with value ok | Value ok |

The failure occurs before accepted-slot effects, while final-result observation
occurs after action execution. This explains why the final-result control avoids
the intervening action catch. Native errors retain `observer-sentinel` in their
message; the confirmed defect concerns object identity, not loss of all error text.

All 108 diagnostic assertions pass across 24 case/route combinations using ordinary
compiled source and a public sink.
Traced conveniences use `trace_config_disabled()` here: enabled trace closure,
original backtrace identity, JSON reconstruction and fresh emitted-module defect
reproduction are not measured by this diagnostic. Repair .2.6 owns that recurrence.
The related Dart finding remains [[dart-semantic-observer-action-failure-wrapping]];
its private-wrapper mechanism differs, and no new other-backend proof is inferred.

Existing focused rule39/control6/emitter13+32+20/capture66 suites pass (176
assertions plus one selected-set equality). The neutral semantic checker passes
6 fixture groups,20 exact queries,128 rejected mutations, rollout9/0 and admission6/0.
Those fixtures do not close the new action callback composition gap. An initial
probe incorrectly treated generated value-only results as RuntimeParseResult and
reported four harness field errors; the replay below checks the actual public
return types separately. It changes no runtime or test source.

## Exact diagnostic replay

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_OBSERVER_ACTION14'
using LinkedSpecJulia, JSON3, Test
mutable struct ObserverSentinel14 <: Exception
    label::String
end
Base.showerror(io::IO, error::ObserverSentinel14) = print(io, error.label)
direct = "Top::\n /x/\n E { return(\"ok\") }\n"
child = "Child:\n /x/\n E { return(\"ok\") }\n"
blind = "Top::\n => Child\n E { return(\"ok\") }\n" * child
called = "Top::\n I { return(call(Child)) }\n" * child
cases = [("direct_slot", direct, "regex_slot_selected", true),
         ("direct_final", direct, "rule_result", true),
         ("blind_slot", blind, "regex_slot_selected", true),
         ("called_slot", called, "regex_slot_selected", false),
         ("called_final", called, "rule_result", true),
         ("called_success", called, nothing, true)]
@testset "Julia observer action composition diagnostic" begin
    for (name, source, failkind, same) in cases
        compiled = compile_spec(parse_spec(source))
        engine = LinkedSpecRuntimeEngine(compiled)
        plan = build_generated_rule_plan(compiled)
        routes = [
            ("native", sink -> runtime_parse(engine, "x"; semantic_observation_sink=sink)),
            ("traced", sink -> runtime_parse_with_trace(engine, "x", trace_config_disabled(); semantic_observation_sink=sink)),
            ("plan", sink -> execute_generated_parser_v2(compiled, plan, "x", "reading-observer.spec"; semantic_observation_sink=sink)),
            ("plan_traced", sink -> execute_generated_parser_with_trace_v2(compiled, plan, "x", trace_config_disabled(), "reading-observer.spec"; semantic_observation_sink=sink)),
        ]
        for (route, run) in routes
            sentinel = ObserverSentinel14("observer-sentinel")
            events = Any[]
            value = nothing
            sink = event -> begin
                row = to_json(event)
                push!(events, row)
                row["event_kind"] == failkind && throw(sentinel)
                nothing
            end
            caught = try
                value = run(sink)
                nothing
            catch error
                error
            end
            if failkind === nothing
                @test caught === nothing
                if route in ["native", "traced"]
                    @test value.value == "ok"
                    @test value.matched
                else
                    @test value isa String
                    @test value == "ok"
                end
            else
                @test caught !== nothing
                @test (caught === sentinel) == same
            end
            @test length(events) == (failkind == "rule_result" || failkind === nothing ? 2 : 1)
            @test events[1]["rule_label"] == (startswith(name, "direct") ? "Top" : "Child")
            if name == "called_slot"
                @test caught isa (route in ["native", "traced"] ? RuntimeInterpreterException : GeneratedSourceException)
                @test occursin("action block failed in rule Top: observer-sentinel", sprint(showerror, caught))
            end
            println(JSON3.write(Dict("case"=>name, "route"=>route,
                "same_error"=>caught===sentinel, "error_type"=>string(typeof(caught)),
                "events"=>length(events))))
        end
    end
end
JULIA_OBSERVER_ACTION14
```
