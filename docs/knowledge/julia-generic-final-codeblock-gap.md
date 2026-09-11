---
id: julia-generic-final-codeblock-gap
title: Julia generic final-codeblock normalization uses metadata projection and one post-registry seam
answers:
  - "why does Julia not support generic contextual final codeblock arguments"
  - "does Julia preserve callback codeblock parameter kinds"
  - "where does Julia hard code receiver trailing block names"
  - "does Julia distinguish attached and parenthesized contextual blocks"
  - "what owns FUTURE-PARITY-BACKLOG 11.6.3"
  - "does Julia callable normalization visit complete switch and deferred bodies"
date: 2026-09-11
status: current implementation; completed by FUTURE-PARITY-BACKLOG.11.6.3
tags: [julia, actionir, codeblock, callable-contract, trailing-block, user-functions, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "Baseline probes on clean bc85c0fa exposed missing fixed_params/codeblock_param/parameter_kinds projection, a four-name receiver parser allowlist, and no codeblock_argument normalizer. FUTURE-PARITY-BACKLOG.11.6.3 now preserves final-only metadata through definition/staged/registry/descriptor/semantic state, parses receiver attachment generically, and applies one post-registry CallableContract.jl pass. Focused proof passes 125 dynamic + 118 contextual + 239 construction assertions across native, reconstructed, generated-plan, and freshly loaded emitted Julia; the complete package passes."
reverify: "bash tools/run_python_project_data.sh tools/check_callable_codeblock_contract.py && bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT=pwd(); include(\"julia/test/callable_codeblock_literal_contract_test.jl\")'"
---

# Julia Generic Final-Codeblock Normalization

The shared `specs/user_function_definition.spec` returns a final-only typed declaration as `fixed_params`,
`codeblock_param`, and the sole `parameter_kinds` entry. Julia now projects that exact record through the
definition shell, both staged sidecars, validator, registry, version-3 descriptor, generated effective spec, and
semantic signature. Definition, payload, and job metadata are correlated independently so malformed reconstructed
state cannot silently grant a typed callback slot.

Function-surface attached blocks retain `trailing_block_arg`; parenthesized immediate blocks remain
`ActionBlockValueExpr`; attached controls parse before ordinary calls. Receiver attachment is now recognized
without a method-name allowlist, but syntax alone grants no semantics. `CallableContract.jl` combines builtin
helper/receiver contracts with the complete user-function registry, rejects unknown attached calls and wrong
pre-block arity, and converts only an admitted final immediate block into the neutral zero-positional
`ActionCodeblockArgumentExpr`. Ordinary parenthesized blocks remain eager.

Runtime helper/receiver `with`, typed user functions, and hash/array tree traversal validate a plain final
codeblock value and reuse the `.11.6.2` dynamic executor. Contextual blocks invoke it with zero positional values
and read scoped dynamic bindings; explicit codeblock values keep their authored signatures. Native, compiled-JSON
reconstruction, generated plans, and independently loaded emitted source all compile through the same normalizer
and execute through the same interpreter. No Julia closure, host callback, or second executor exists.

Related facts: [[final-codeblock-parameter-declaration]], [[julia-callable-codeblock-dynamic-invocation]],
[[dart-generic-final-codeblock-gap]], [[rust-generic-final-codeblock-normalization]],
[[julia-user-function-definition-projection]], [[julia-user-function-registry]].

## September 11 source traversal reconciliation

Full CallableContract reading shows normalization descends through the complete retained switch body and
its extracted branches, as well as explicit/contextual callable bodies. It recursively normalizes arguments
before testing a final eager block against helper/receiver or registered-user metadata. Known bounds admit
only the declared pre-block arity; an undeclared attached block rejects, while an ordinary parenthesized
block without a final-block contract stays eager. A promoted contextual argument carries a zero-positional
signature and the original body/source spans.

Eight direct native outcomes below reject the unknown attached helper and admit valid with blocks in direct,
omitted-switch-body, explicit-callable and contextual-body locations. The four valid forms are idempotent.
These controls qualify the separate [[julia-attached-switch-body-omission]] and
[[julia-callable-selector-validation-gap]] findings; neither defect is repaired by this reading.
Existing contextual 118 / registry 23 / variadic 55 assertions also pass. No component/canonical gate is claimed.

Replay the following code with the managed Julia wrapper:

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'NORMALIZER_REPLAY'
using LinkedSpecJulia, JSON3
for good in (false,true)
    call=(good ? "with" : "mystery_probe")*"() { return(1) }"
    sources=[call,
        "switch(1) { case(1) { return(7) }; "*call*" }",
        "callback = {|| "*call*" }",
        "with() { "*call*" }"]
    for (index,source) in enumerate(sources)
        block=parse_action_block(source)
        error_message=nothing
        try
            LinkedSpecJulia.normalize_action_block_final_codeblocks!(block,empty_user_function_registry())
        catch error
            error_message=sprint(showerror,error)
        end
        if good
            @assert error_message===nothing (index,error_message)
            first=to_json(block)
            LinkedSpecJulia.normalize_action_block_final_codeblocks!(block,empty_user_function_registry())
            @assert to_json(block)==first index
        else
            @assert error_message=="callable_contract_rejected: helper 'mystery_probe' does not declare a final codeblock parameter" (index,error_message)
        end
        println(JSON3.write(Dict("case"=>index,"valid"=>good,"error"=>error_message)))
    end
end
NORMALIZER_REPLAY
```
