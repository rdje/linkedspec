---
id: julia-recognition-effect-integration-gap
title: Julia recognition permits forbidden binding writes and misses structural observation edges
answers:
  - why can a Julia recognized child write a binding before rollback
  - is the Julia recognition effect classifier connected to runtime execution
  - can Julia observation effects hide behind action or blind edges
  - which task owns Julia recognition effect integration
  - how can I reproduce Julia recognition binding write persistence
date: 2026-09-11
status: confirmed; repair owned by JULIA-STARTUP-READING.2.3
tags: [julia, recognition, observation, effects, rollback, defect, startup]
evidence: "JULIA-STARTUP-READING.1.7 uses native parser/compiler/runtime lifecycle controls: explicit call(Observer) rejects, while action/blind edges enter its observation-writing lifecycle. A recognized child writes seen=1 and rollback leaves [true,1]; the pure twin leaves [true,0]. The independent neutral classifier rejects binding_write. Adding then removing a process-local explicit call edge makes the special compiler validator reject then accept both structural-edge cases. All production source bytes remain unchanged."
reverify:
  - "Run JULIA_RECOGNITION_EFFECT_REPLAY below through the managed Julia wrapper."
  - "rg -n 'classify_effects' julia/src julia/test julia/test_dormant"
  - "bash tools/run_python_project_data.sh tools/check_recognition_transaction_contract.py"
---

# Mechanism and bounded evidence

Clean activation: `e2f8edeceeaf5b59d5efa2ccc2ebe93dcb2fcc70`.
The census above finds the generic classifier declaration at
`julia/src/runtime/RecognitionTransaction.jl:879` and its two direct test call sites at
`julia/test/recognition_transaction_contract_test.jl:725` and `:730`. There is no production caller
in that enumerated source population. It correctly rejects a neutral `binding_write` graph and accepts
`pure_value`, but these direct calls do not prove validation of executable rule graphs.

`julia/src/compiler/CompiledSpec.jl:745` builds the additional observation policy from action payloads.
Its expression visitor and fixed point follow explicit rule/function calls; they do not insert structural
action/blind targets. Supplying the omitted edge as a temporary `call(Observer)` payload causes rejection;
removing it restores acceptance. This isolates graph coverage without changing repository code.
The neighboring progressive policy uses a similar collector; this intake does not claim a reproduced
progressive-dispatch failure.

`julia/src/runtime/Interpreter.jl:3857` invokes the recognized child before recording the attempt.
Its observation branch at 3871 executes and binds the result normally. Frame projection at 549 and restoration
at 560 contain cursor, anonymous capture boundary and invocation marks, with rollback at 1104 applying that
state. Bindings are intentionally outside this snapshot. The repair must enforce forbidden effects before
execution rather than silently expanding rollback to arbitrary binding state.

| Native control | Result |
| --- | --- |
| Bridge explicitly calls Observer | Compile rejects `recognition_effect_forbidden:binding_write` |
| Bridge action edge enters Observer I | Compiles and returns `true` |
| Bridge blind edge enters Observer I | Compiles and returns `false` |
| Pure action-edge twin | Compiles and returns `true` |
| Child writes seen=1, then recognition rolls back | Returns `[true,1]` |
| Pure recognized child, then rollback | Returns `[true,0]` |
| Ordinary call with the same write | Returns `[false,1]` |

Lifecycle records independently identify the Observer I or Child E that ran; result truthiness alone is not
dispatch evidence. These diagnostic controls exercise native Julia only. No reconstructed/generated/emitted
result or repair is inferred. Existing suites separately pass recognition207, observation30, mutation496 and
write406 assertions; their covered routes remain valid evidence while this missing integration remains open.
The neutral checker remains 138 node rows /250 calls /58 mutations; fixture admission is not complete effect
integration proof.

Repair `.2.3.1` reconciles the full producer-derived graph and contract; `.2.3.2` enforces it before execution;
`.2.3.3` closes all supported carriers and public claims. Startup `.3/.4/.5` gate each repair.
The prior Dart finding has its own owner, [[dart-recognition-effect-integration-gap]].

# Reproduction and causal controls

The following assertions describe the observed defect and controls, not the desired repaired behavior.
The two temporary payload changes affect only fresh in-process compiled objects. All source identities remain
governed by [[julia-startup-reading-coverage]].

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_RECOGNITION_EFFECT_REPLAY'
using LinkedSpecJulia, JSON3, Test
function observation_source(bridge; pure=false)
    observer=pure ? "Observer:\n /x/\n I { return(false) }\n" :
        "Observer:\n /x/\n I { value = observe_recognition(observation, call(Child)); return(value) }\n"
    return "Top::\n I {\n tx = recognition_checkpoint()\n matched = recognize_once(tx, call(Bridge))\n recognition_rollback(tx)\n return(matched)\n }\n" *
        bridge * observer * "Child:AND\n /x/\n"
end
function compile_source(source)
    return compile_spec(parse_spec_with_staged_user_function_definitions(source))
end
function native_row(source)
    row=Dict{String,Any}(); phase="parse"
    try
        spec=parse_spec_with_staged_user_function_definitions(source); phase="compile"
        compiled=compile_spec(spec); row["compiled"]=true; phase="execute"
        result=runtime_execute(LinkedSpecRuntimeEngine(compiled),"x")
        row["value"]=result.value; row["lifecycle"]=to_json.(result.lifecycle_events)
    catch error
        row["phase"]=phase; row["error"]=sprint(showerror,error)
    end
    return row
end
@testset "native recognition effect gap controls" begin
    for (name,bridge,expected) in [
        ("ordinary_call","Bridge:\n I { return(call(Observer)) }\n",nothing),
        ("action_edge","Bridge:\n -> Observer\n",true),
        ("blind_edge","Bridge:AND\n Observer\n",false),
        ("pure_action_control","Bridge:\n -> Observer\n",true),
    ]
        row=native_row(observation_source(bridge;pure=name=="pure_action_control"))
        row["case"]=name; println(JSON3.write(row))
        if name=="ordinary_call"
            @test row["phase"]=="compile"
            @test occursin("recognition_effect_forbidden:binding_write",row["error"])
        else
            @test row["compiled"]===true
            @test row["value"]===expected
            @test count(e->e["rule_label"]=="Observer" && e["lifecycle"]=="I",row["lifecycle"])==1
        end
    end
    for (mode,expected) in [("write_rollback",Any[true,1]),("pure_rollback",Any[true,0]),("write_ordinary",Any[false,1])]
        body=mode=="pure_rollback" ? "return(false)" : "set(seen, 1); return(false)"
        invoke=mode=="write_ordinary" ? "matched = call(Child)" :
            "tx = recognition_checkpoint()\n matched = recognize_once(tx, call(Child))\n recognition_rollback(tx)"
        source="Top::\n I {\n seen = 0\n $invoke\n return(array(matched, seen))\n }\nChild:AND\n /x/\n E { $body }\n"
        row=native_row(source); row["case"]=mode; println(JSON3.write(row))
        @test row["value"]==expected
        @test count(e->e["rule_label"]=="Child" && e["lifecycle"]=="E",row["lifecycle"])==1
    end
end
@testset "authority and omitted-edge causal controls" begin
    R=LinkedSpecJulia.RecognitionTransaction
    source_authority=LinkedSpecJulia.SourceLocation.SourceAuthority(sources=Dict{String,String}("input"=>"x"))
    authority=R.RecognitionTransactionAuthority(source_authority=source_authority,source_identity="input")
    for effect in ["binding_write","pure_value"]
        graph=Dict{String,Any}("entry"=>"Child","rules"=>Dict("Child"=>Dict("base"=>[effect],"calls"=>String[])))
        outcome=try R.classify_effects(authority,graph); "accepted" catch error; sprint(showerror,error) end
        println(JSON3.write(Dict("effect"=>effect,"outcome"=>outcome)))
        @test effect=="binding_write" ? occursin("recognition_effect_forbidden",outcome) : outcome=="accepted"
    end
    for bridge in ["Bridge:\n -> Observer\n","Bridge:AND\n Observer\n"]
        compiled=compile_source(observation_source(bridge))
        @test LinkedSpecJulia.validate_recursive_observation_policy(compiled)===nothing
        rule=compiled_rule(compiled,"Bridge"); ast=parse_action_block("call(Observer)")
        payload=LinkedSpecJulia.CompiledActionPayload(role="diagnostic_edge",line=0,source="call(Observer)",code="call(Observer)",action_ast=ast,contracts=resolve_action_block_contracts(ast))
        push!(rule.lifecycle_action_payloads,payload)
        outcome=try LinkedSpecJulia.validate_recursive_observation_policy(compiled); "accepted" catch error; sprint(showerror,error) end
        println(JSON3.write(Dict("bridge"=>bridge,"with_explicit_graph_edge"=>outcome)))
        @test occursin("recognition_effect_forbidden:binding_write",outcome)
        pop!(rule.lifecycle_action_payloads)
        @test LinkedSpecJulia.validate_recursive_observation_policy(compiled)===nothing
    end
end
JULIA_RECOGNITION_EFFECT_REPLAY
```

Direct-dependent suite replay:

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_GROUP7_CONTRACTS'
using LinkedSpecJulia, JSON3, Test
const REPO_ROOT=pwd()
include("julia/test/recognition_transaction_contract_test.jl")
include("julia/test/recursive_observation_contract_test.jl")
include("julia/test/map_leaves_mutation_contract_test.jl")
include("julia/test/write_vivification_contract_test.jl")
JULIA_GROUP7_CONTRACTS
```

# Perl reference qualification

The same reference source rejects `write_rollback` at compile time with
`recognition_effect_forbidden` / `binding_write` in `recognition_transaction_policy`;
the pure twin returns `[1,0]`. This supports pre-execution rejection of the forbidden effect.
The ordinary reference call returns `[null,0]`: generated-source inspection shows a Child
preamble and binding declaration but no authored E write or return. `SpecEntry.pm:198`
requires an action edge or I body for the single-regex AND variant; the default builder at
`HandlerVariantEmitter.pm:100` requires action code. The no-edge E-only child therefore
has no selected handler body, matching the existing mode/lifecycle repair scope in startup
`.27.1-.27.3` and [[perl-lifecycle-final-value-e-drift]]. It is not a value-parity oracle for
Julia's executed E body. No additional independent repair root is created.

```bash
bash tools/project_data_run.sh perl -Iperl -MLinkedSpec -MTest::More - <<'PERL_RECOGNITION_REFERENCE'
for my $mode (qw(write_rollback pure_rollback write_ordinary)) {
 my $body=$mode eq 'pure_rollback' ? 'return(false)' : 'set(seen, 1); return(false)';
 my $invoke=$mode eq 'write_ordinary' ? 'matched = call(Child)' :
  'tx = recognition_checkpoint(); matched = recognize_once(tx, call(Child)); recognition_rollback(tx)';
 my $source="Top::\n I { seen = 0; $invoke; return(array(matched, seen)) }\nChild:AND\n /x/\n E { $body }\n";
 my %ctx;
 my $parser=LinkedSpec::Get(\$source,runtime_ctx_ref=>\%ctx);
 if ($mode eq 'write_rollback') {
  ok(!$parser,'reference rejects recognized binding write');
  is($ctx{last_error}{code},'recognition_effect_forbidden','reference diagnostic code');
  is($ctx{last_error}{effect},'binding_write','reference forbidden effect');
 } else {
  ok(ref($parser) eq 'CODE',"$mode compiles"); my $input='x';
  is_deeply($parser->(\$input),$mode eq 'pure_rollback' ? [1,0] : [undef,0],"$mode exact reference result");
  if ($mode eq 'write_ordinary') {
   my $generated='';
   LinkedSpec::Get(\$source,return_descriptor=>1,dump_parser_source=>1,parser_source_ref=>\$generated);
   my ($child)=$generated=~/\bChild\s*=>\s*sub\s*\{(.*?)\n\s+\},/s;
   ok(defined $child,'generated Child body extracted');
   unlike($child,qr/\$seen\s*=\s*1/,'Child omits authored binding write');
   unlike($child,qr/return\s+0/,'Child omits authored false return');
   like($child,qr/my \$seen;/,'Child retains binding declaration');
  }
 }
}
done_testing();
PERL_RECOGNITION_REFERENCE
```
