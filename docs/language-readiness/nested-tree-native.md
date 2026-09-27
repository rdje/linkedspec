# Bounded nested-tree native readiness

Owner: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.1`, verified 2026-09-27 from clean `fa8b0e8af`.

The grammar at `tests/language-readiness/nested-tree/grammar.spec` and its independently authored
`cases.json` remain unchanged. The six accepted inputs cover empty input/list, nested scope, multiple forms,
CRLF and supplementary Unicode. Seven malformed inputs cover trailing/interstitial text, skipped prefix,
missing inner/outer close, a bare document atom and an unmatched close. This small language has no string,
comment, escape or standard-format conformance claim.

## Public native results

| Runtime | Accepted cases | Rejected cases | Accepted parses through one engine | Error projection |
| --- | ---: | ---: | ---: | --- |
| Perl | 6 | 7 | 12 | typed JSON runtime_exit_now, status1 |
| Rust | 6 | 7 | 12 | published adapter Display: exit_now(1) |
| Dart | 6 | 7 | 12 | typed JSON runtime_exit_now, status1 |
| Julia | 6 | 7 | 12 | typed JSON runtime_exit_now, status1 |
| PUC Lua | 6 | 7 | 12 | typed JSON runtime_exit_now, status1 |
| LuaJIT | 6 | 7 | 12 | typed JSON runtime_exit_now, status1 |

All six public loaders compile the same grammar. Every accepted AST, scalar kind and half-open Unicode span
matches the authored oracle, first forward then in reverse order through one engine. Every rejected input
produces no result. The verifier hashes grammar, cases, public adapter and prepared product/config inputs
before and after execution. It uses the published integration APIs and does not inspect dependency internals.

Run each runtime after the corresponding public integration example is prepared:

```sh
bash tools/run_python_project_data.sh tests/language-readiness/nested-tree/verify_native.py --runtime perl
bash tools/run_python_project_data.sh tests/language-readiness/nested-tree/verify_native.py --runtime rust
bash tools/run_python_project_data.sh tests/language-readiness/nested-tree/verify_native.py --runtime dart
bash tools/run_python_project_data.sh tests/language-readiness/nested-tree/verify_native.py --runtime julia
bash tools/run_python_project_data.sh tests/language-readiness/nested-tree/verify_native.py --runtime puc
bash tools/run_python_project_data.sh tests/language-readiness/nested-tree/verify_native.py --runtime luajit
```

The Rust integration binary is rebuilt through the documented locked offline command. Dart uses the retained
integration package config; Julia uses its application-local project/depot with offline loading; both Lua ABIs
use their retained native modules. All project data remains on the repository volume. The verifier derives
paths from its current checkout; no persisted machine-specific path is required.

## Limits and next proof

The text adapters exit at the first rejection, so this trial does not prove recovery after rejection in the
same engine. Rust's Display output is also not typed-diagnostic evidence. The earlier Perl test separately
covers native/fresh emitted rejection recovery. Supported reconstructed/generated/emitted routes, descriptors,
and independent prefix/gap/span mutations remain owned by `.1.1.3.1.2.2`, split into backend-sized children before
execution. Parent reconciliation requires canonical milestone proof. The broad format campaign remains gated.

Exact source/product/log hashes are in `docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.1-verification.json`.

## Subsequent Perl carrier proof

`SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.1.1` repairs emitted public-entry trivia drift exposed by the prefix
mutation. The separate `t/nested_tree_readiness.t` passes192 tests and verifies five ready rules,40 original
executions per native/fresh emitted route,14 immediate typed-rejection recoveries per route, three controlled
mutants,14 repeated entry cases and two child-entry controls. Focused274 and complete Phase01033 pass. Other
backends' carriers and canonical parent reconciliation remain separate; the native adapter table above is unchanged.
