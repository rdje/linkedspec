---
id: julia-primary-cli-native-execution-canonical-json
title: Julia primary CLI executes native requests and emits direct recursive canonical JSON
answers:
  - can the Julia primary CLI execute parser requests
  - does the Julia primary CLI support rule only and top level function source
  - what value does the Julia primary CLI print
  - does Julia CLI output use RuntimeParseResult value or output
  - how does the Julia primary CLI sort JSON object keys
  - are nested Julia CLI JSON keys canonical
  - does Julia primary execution support top rule and trace
  - does Julia primary execution accept a global parse mode
  - what did JULIA-BACKEND-PARITY.7.3.2.3 implement
date: 2026-07-10
status: current
tags: [julia, cli, execution, json, parser, compiler, runtime, parity, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.7.3.2.3 composes prepared requests through native rule/function parsing, compile/runtime controls, and recursive canonical JSON. Twenty-two focused assertions, the 942-assertion suite, direct canonical primary smoke, and 99/99 pass."
evidence_update_2026_07_18_cursor_option_removal: "FUTURE-PARITY-BACKLOG.9.1.6.5 removes the global cursor control from prepared requests and engine construction. Rule families now provide the only high-level cursor policy; explicit --top-rule and all trace controls remain."
reverify: "bash tools/run_julia_local.sh && rg -n '_execute_primary_cli_request|_parse_primary_cli_spec|_write_primary_cli_canonical_json|Primary CLI execution and canonical JSON' julia/src/cli/LinkedSpecJuliaCli.jl julia/test/runtests.jl"
---

Julia's primary parser command executes prepared requests entirely in process. It
tries rule-only `parse_spec(...)` first and falls back to
`parse_spec_with_staged_user_function_definitions(...)` only on a source parse
exception. It then uses `compile_spec(...)`, constructs
`LinkedSpecRuntimeEngine` with source identity, and calls
`runtime_execute(...)` with the selected top rule. One optional trace emitter is
shared across every phase.

Successful output serializes `RuntimeParseResult.value`: the direct top-rule
value users observe across backends. It deliberately does not serialize
`RuntimeParseResult.output`, whose one-level array wrapper exists for corpus
comparison. The dedicated compact writer supports null, booleans, strings,
numbers, arrays/tuples, and string-keyed objects. It recursively sorts every
object level lexicographically before encoding and the command adds exactly one
newline, so Julia dictionary insertion order cannot change stdout.

Focused coverage includes rule-only and top-level-function source, explicit top
rule, family-derived AND consumption, inline/file source and input, routed trace reset, direct
scalar/null/array values, JSON escaping, nested unsorted maps, and rejection of
non-string object keys. `.7.3.2.4` has since closed failure/exit normalization
and the complete trace routing matrix.

Related facts: [[julia-primary-cli-arguments-resolution-loading]],
[[julia-primary-cli-mechanism-audit]], [[julia-frontend-compiler-staged-trace-events]],
[[user-observable-backend-cli-parity-contract]], [[native-in-memory-backend-contract]],
[[julia-primary-cli-failure-trace-routing]], [[julia-global-cursor-option-removal]].

## September 11 source-reading reconciliation

`JULIA-STARTUP-READING.1.6` reads the complete 838-line primary adapter. The earlier single-emitter
description applies to its internal `_execute_primary_cli_request` helper. Current public `run_cli` constructs
an independent canonical trace and calls compile/invoke without that native emitter. Named/file requests
reuse `LoadedCompiledSpec`; inline requests parse and compile in the adapter. Both finish compilation before
deferred input loading. Canonical trace write/reset failure becomes the stable compilation-failure boundary.
Fatal errors rethrow at the outer operational catches; this does not certify every nested IO/trace catch.

The direct-value recursive writer remains current. The unchanged ten-family process checker freshly proves
nested sorted JSON, exact help/status/error outputs, compilation-before-input ordering and routed/mirrored
trace behavior. This is bounded process conformance, not a complete package or cross-backend run.
Replay: `bash tools/check_julia_primary_cli.sh`; complementary native compiled/registry checks are
[[julia-compiled-spec-state]]. Canonical trace authority remains [[julia-canonical-primary-cli-trace]].

## September 11 main-test prefix reading and focused replay (.1.41)

`runtests.jl`1–964 is read; the first50 includes name separate consumers and
grant no additional source-reading credit. Helpers retain structured function
sidecars/source spans and corpus fixtures. The complete testsets through904
pass145 assertions: routed temporary root2, Unicode casing39, scalar text5,
scalar numeric4, scaffold19, argument/loading56 and execution/canonical JSON20.
Loading verifies exact shared help, deterministic nonrecursive resolution, raw
invalid UTF-8 rejection and repository-derived fixtures. Execution verifies
sorted nested JSON, non-string key rejection, explicit root, AND consume, staged
functions and exact routed/reset trace. The failure/trace testset906–1134 is only
read through964 here and is excluded from this bounded execution. Its remaining
source belongs to .1.42. Existing numeric/trace/other repair owners stay open.

The unchanged cursor consumers add104 execution,353 normalization and53 removal
assertions:655 total. The following in-memory harness preserves source line
coordinates and filename, blanks only the separate consumer includes, then runs
the three selected consumers explicitly. It creates no source file or broad-suite
claim. Runtime temporary data follows the managed wrapper's repository storage.

```bash
bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'using LinkedSpecJulia, JSON3, Test; source=readlines("julia/test/runtests.jl"; keep=true); source[18:67].="\n"; include_string(Main, join(source[1:904]), joinpath(pwd(),"julia/test/runtests.jl")); include("julia/test/rule_local_cursor_execution_test.jl"); include("julia/test/rule_local_cursor_normalization_test.jl"); include("julia/test/rule_local_cursor_option_removal_test.jl")'
bash tools/run_python_project_data.sh tools/check_rule_local_cursor_contract.py
bash tools/check_julia_primary_cli.sh
```

The independent ten-family process checker passes. Neutral cursor governance is
74 migration files,8 complete/0 pending and60 rejected drift mutations; it retains
36 family spellings,18 edges,8 parent/child cases,15 Julia roles and six recurring
legs. Reading and focused results do not execute every recurring runtime leg.
