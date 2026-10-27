---
id: julia-logical-helper-execution
title: Julia consumes the typed eager logical-helper contract through one truth seam
answers:
  - does Julia support and or not receiver methods
  - do malformed Julia logical receiver shapes evaluate their source
  - does Julia support and or not helpers
  - are Julia LinkedSpec logical helpers short circuit
  - what arity do Julia and or not accept
  - do Julia logical arity failures run operands
  - what is Julia LinkedSpec truthiness
  - are Julia empty arrays and hashes truthful
  - do generated Julia logical helpers match native execution
  - which Julia test consumes the neutral logical helper contract
  - what does FUTURE-PARITY-BACKLOG.5.2.5 prove
  - which Julia portmap fixtures pass after logical helpers
  - why did Julia portmap_constant fail after its first logical implementation
date: 2026-10-27
status: current
tags: [julia, runtime, logical, truthiness, arity, generated-source, primary-cli, corpus, FUTURE-PARITY-BACKLOG]
evidence: "TYPE23.3.17.4 public producer/shared/rejected-effect/actual-Bool/source-error and direct neutral/default native-plan-fresh focused proof. Full prior July/September admission, reading and replay detail at Git40cc7b4581a8826200c65f04b9fa1622515042d8 for this path."
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no --depwarn=error -e 'using LinkedSpecJulia,JSON3,Test;include(\"julia/test/logical_result_receivers_test.jl\");include(\"julia/test/default_selected_receivers_test.jl\");include(\"julia/test/logical_receiver_methods_test.jl\")'"

---

_runtime_truthy is Julia's typed helper/condition seam: nothing/false/numeric zero
and empty String/Array/Hash are false; nonzero numbers/nonempty Strings and
aggregates are true. Built-in and/or require1+ positional values, not exactly1;
after original-call arity validation, every operand runs once left to right
and returns actual Bool. Registered user functions retain static precedence.
Invalid arity carries helper/code/actual/expected/rule fields; generated framing
keeps deterministic details. Lazy controls remain separately branch/body-lazy.

Logical17.4 independently confirms producers/typed Bool/strict numeric-null,
valid flow/source snapshots and native/plan/fresh source errors before code.
Shared scalar->container[] and incompatible take operandA (SA), plus actual
selected/block/literal Bool sorted fallthrough, fail on all three routes.
_evaluate_runtime_fluent_chain! now starts scalar_result from actual Bool and
retains it after Bool results. Actual containers still release the boundary;
free/named-context/numeric/truth/error policies are unchanged.214 focused
assertions across new100/direct defaults9/three actual neutral fixtures105 pass
with strict compilation. Bool identity/raw/meta/flag and Number-not-Bool
counter checks avoid Julia's true==1/false==0 lookalikes. Rejected LR/LRC/S
prefixes survive and consumer operands remain skipped. Full admission open.

The original inert codeblock truth row used parsed ActionBlock without
invocation. Exact callable construction11.6.1 and invocation11.6.2 are current;
Julia startup2.8 still owns the separate callback-identity gap. This slice
changes no callable carrier/ABI or complete context/portable admission.

Historical July5.2.5/September consumer/standalone/CLI/corpus and source-reading
facts remain at the exact Git pointer above; the shared logical ledger remains
closed8/0 for its admitted projection, not these broader fluent contexts. Old
portmap_bare/portmap_bit/portmap_concatenation/tablegrep_simple_term fixes were
logical; residual portmap_constant was independently traced to Regex flago and
later normalized, not an eager truth failure. No historical proof is freshly
replayed or promoted by the current narrow checks.

Related: [[logical-helper-neutral-contract]], [[julia-generated-source-scaffold]],
[[julia-helper-regex-flag-normalization]], [[julia-callable-codeblock-literal-state]].

## Ordinary logical receiver methods, October27

TYPE23.4 confirms existing pure-helper fluent dispatch already preserves valid
logical kinds/eager snapshots/Boolean boundaries/scopes/free errors and value
copies. Producer/copy PASS12, valid/error controls PASS91 before changes; malformed
shapes run SCSCSAC or an unknown operand. Six preflight lines require positional
one-plus RHS and/or and zero-RHS not before effects. Registered strict native/
plan/fresh test PASS109 plus direct logical result PASS100 and strict compilation.
No free producer/truth/arity/callback/deferred/copy/serialized model changes;
Bool value copies stay true/false. Copy-domain1.2.1.4.2 and full method/context/
portable admission remain separate; safe Lua23.5 independently follows.
