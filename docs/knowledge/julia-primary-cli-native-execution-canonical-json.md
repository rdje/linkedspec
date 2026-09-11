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
