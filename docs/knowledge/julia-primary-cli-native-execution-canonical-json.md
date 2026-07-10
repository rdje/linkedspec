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
  - does Julia primary execution support top rule parse mode and trace
  - what did JULIA-BACKEND-PARITY.7.3.2.3 implement
date: 2026-07-10
status: current
tags: [julia, cli, execution, json, parser, compiler, runtime, parity, JULIA-BACKEND-PARITY]
evidence: "JULIA-BACKEND-PARITY.7.3.2.3 composes prepared requests through native rule/function parsing, compile/runtime controls, and recursive canonical JSON. Twenty-two focused assertions, the 942-assertion suite, direct canonical primary smoke, and 99/99 pass."
reverify: "LINKEDSPEC_JULIA_CMD=/opt/homebrew/bin/julia LINKEDSPEC_JULIA_DEPOT_PATH=/private/tmp/linkedspec-julia-depot bash tools/run_julia_local.sh && rg -n '_execute_primary_cli_request|_parse_primary_cli_spec|_write_primary_cli_canonical_json|Primary CLI execution and canonical JSON' julia/src/cli/LinkedSpecJuliaCli.jl julia/test/runtests.jl"
---

Julia's primary parser command executes prepared requests entirely in process. It
tries rule-only `parse_spec(...)` first and falls back to
`parse_spec_with_staged_user_function_definitions(...)` only on a source parse
exception. It then uses `compile_spec(...)`, constructs
`LinkedSpecRuntimeEngine` with source identity and seek/consume mode, and calls
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
rule, consume mode, inline/file source and input, routed trace reset, direct
scalar/null/array values, JSON escaping, nested unsorted maps, and rejection of
non-string object keys. Final failure text, exit normalization, and the complete
trace routing matrix remain owned by `.7.3.2.4`.

Related facts: [[julia-primary-cli-arguments-resolution-loading]],
[[julia-primary-cli-mechanism-audit]], [[julia-frontend-compiler-staged-trace-events]],
[[user-observable-backend-cli-parity-contract]], [[native-in-memory-backend-contract]].
