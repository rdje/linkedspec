---
id: julia-callable-codeblock-dynamic-invocation
title: Julia invokes bound callable codeblocks in dynamic caller context
answers:
  - "does Julia execute cb args codeblock calls"
  - "how does Julia invoke a callable codeblock variable"
  - "do Julia codeblock parameters restore after an error"
  - "do Julia codeblock mutations affect caller variables"
  - "can a Julia codeblock result feed key access or a receiver chain"
  - "does a helper or function shadow a same named Julia codeblock"
  - "what diagnostics does Julia callable codeblock invocation emit"
  - "how does Julia reject direct and mutual codeblock recursion"
  - "does emitted Julia execute callable codeblocks"
  - "does Julia preserve ordinary unknown helper diagnostics outside codeblocks"
date: 2026-07-30
status: implemented; helper callback identity limitation remains open under Julia .2.8
tags: [julia, actionir, codeblock, callable, dynamic-scope, diagnostics, generated-source, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.11.6.2 adds bound-codeblock fallback after static callables, once-only ordered arguments, recursively copied temporary fixed/rest bindings, cleanup-safe three-store restoration, caller-visible nonparameter state, invocation-local results, typed value access, exact portable failures and ordered cycles. Focused proof passes 125 dynamic plus 239 construction assertions across native/reconstructed/generated-plan/fresh emitted-module roles; the complete package and Julia local gate pass with unchanged 18-owner/five-package repository storage, primary CLI, and corpus 105/105. Final proof passes Knowledge Map 770/6251, mdBook 79/13972 KiB, all seven doctrines, canonical containment/moved-root, CLI 66x2, RAM 57%, and Phase 0 1031/1031 in 655 seconds."
reverify: "bash tools/run_python_project_data.sh tools/check_callable_codeblock_contract.py && bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; const REPO_ROOT=pwd(); include(\"julia/test/callable_codeblock_literal_contract_test.jl\")' && bash tools/run_julia_local.sh"
---

# Julia Callable Codeblock Dynamic Invocation

**Current qualification (2026-09-11):** helper names incorrectly act as callback
recursion identities. Distinct nested with/map callbacks can fail, and a bound
callback passed through with loses its name in the cycle. Exact evidence and repair
are [[julia-callback-helper-recursion-identity-gap]], Julia .2.8. Generic final-block
normalization is now implemented under .11.6.3; the pending wording below describes
the original dynamic-invocation milestone.

Julia resolves `cb(args)` as a bound codeblock only after controls, helpers, and registered user functions. A
colliding static callable wins. A bound non-codeblock fails as `value_not_callable`; an unknown call reached
inside an active codeblock fails with the portable `unknown_helper` record. Ordinary unknown helpers outside a
codeblock retain Julia's established general `runtime_execution` diagnostic.

Positional arguments evaluate exactly once from left to right. Fixed values and a fresh final-rest array are
recursively copied into `_RuntimeScopedBinding` frames. The frames restore all prior same-name scalar, array, and
harray state in reverse order on success or failure. Other names keep using the caller's current stores, so
nonparameter mutation persists. Invocation executes retained typed ActionIR, catches `return(...)` at the
codeblock boundary even when a nested helper raises it, copies the result before restoration, and allows that
result to enter typed key/index access, continue through a receiver chain, or be discarded.

The structured runtime envelope reports `codeblock_arity_mismatch`,
`codeblock_keyword_arguments_unsupported`, `value_not_callable`, `unknown_helper`, and
`codeblock_recursion_unsupported` with neutral `callable_name`, `expected`, `got`, `value_kind`, `name`, and
ordered `cycle` fields as applicable. A separate active-codeblock stack rejects direct and mutual recursion while
cleanup remains exception-safe. Narrow colon-keyword parsing supplies the governed rejection; `name = value`
inside a call remains a positional assignment expression.

Native execution, normalized emitted-payload reconstruction, generated-plan execution, and freshly loaded emitted
Julia all reuse the same parser/compiler/interpreter and plain eight-field record. Generic attached or
parenthesized final-block normalization remains `FUTURE-PARITY-BACKLOG.11.6.3`; explicit invocation does not
promote the complete generic capability.

Related facts: [[julia-callable-codeblock-literal-state]], [[callable-codeblock-literal-contract]],
[[julia-callable-codeblock-dynamic-invocation-gap]], [[dart-callable-codeblock-dynamic-invocation]],
[[rust-callable-codeblock-dynamic-invocation]], [[julia-uniform-binding-runtime]].

## September 11 scope and executor reading

Julia .1.16 reads Interpreter4616-6115. Bound-call fallback follows known static
callables, decodes the copied plain value, rejects keywords, evaluates positional
arguments in order, and checks arity before active-name recursion. It caches body
AST by source_text, installs copied fixed/rest parameters with fresh identities,
returns a copied result and restores three-store bindings in reverse order.
Helper/receiver with evaluates its callback before installing scoped value;
contextual callbacks receive no positional arguments and explicit values receive
one. This executor catches local action return and rethrows other errors.
User functions instead replace the complete variable/array/harray and identity
stores, normalize/cache body source by registry index and restore caller stores.
Their established pure-function scope remains separate from dynamic codeblocks.

Existing callable 125 / contextual 118 / construction 239 and map-mutation 496
assertions pass, with array 2 / hash 1 / function 9 / tree 2 (992 plus one selected-
set equality). New nested-callback diagnostic 84 is preserved in the linked gap
fact. No enabled-trace, fresh emitted defect reproduction or repair closure is claimed.

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no - <<'JULIA_READING16'
using LinkedSpecJulia, JSON3, Test
const REPO_ROOT = pwd()
const CORPUS_ROOT = joinpath(REPO_ROOT, "tests", "corpus")
const selected = Set(["Runtime array helpers and mutations", "Runtime hash helpers and mutations", "Runtime registered user functions", "Runtime hash and array tree traversal callbacks"])
const seen = Set{String}()
for expression in Meta.parseall(read("julia/test/runtests.jl", String)).args
    expression isa Expr || continue
    if expression.head == :function
        Core.eval(Main, expression)
    elseif expression.head == :macrocall && expression.args[1] == Symbol("@testset") && expression.args[3] in selected
        Core.eval(Main, expression)
        push!(seen, expression.args[3])
    end
end
@test seen == selected
include("julia/test/callable_codeblock_literal_contract_test.jl")
include("julia/test/map_leaves_mutation_contract_test.jl")
JULIA_READING16
bash tools/run_python_project_data.sh tools/check_callable_codeblock_contract.py
bash tools/run_python_project_data.sh tools/check_map_leaves_mutation_contract.py
bash tools/run_python_project_data.sh tools/check_write_vivification_contract.py
```
