---
id: staged-consumer-current-projection-lockstep
title: Admitted staged-AST consumers snapshot the complete neutral current projection
answers:
  - "why did Dart dormant activation require changing Perl and Rust staged tests"
  - "which staged AST assertions must move when a backend lifecycle changes"
  - "why did canonical CI fail after the neutral staged checker passed at 85 mutations"
  - "how do admitted staged consumers prevent stale backend lifecycle projections"
date: 2026-08-26
status: current
tags: [staged-parsing, conformance, tests, lifecycle, mutations, drift, perl, rust, dart, julia, lua]
evidence: "The first exact FUTURE-PARITY-BACKLOG.14.7.5.0 canonical candidate passed the independent 85-mutation neutral checker, then the admitted Perl consumer failed only its three pre-Dart current-projection values: status, mutation count, and Dart pending_absent lifecycle. Exact scan found the same values in the admitted Rust consumer. Both consumers intentionally snapshot the entire neutral contract, so backend lifecycle movement requires their projection literals to move even when their own runtime behavior is unchanged. The task-owned repair changes only those six literals/messages; production, carriers, policies, rollout, generated format, and outward behavior remain unchanged."
evidence_update_2026_08_27_julia_admission: "Julia admission .14.7.6.4 applies the same rule: the neutral contract advances Julia to complete, rollout to 5/9, and governance to 97 mutations, so the admitted Perl, Rust, and Dart snapshot literals move together with the Julia consumer. Their production behavior is unchanged and all four admitted consumers pass."
evidence_update_2026_08_27_lua_current_depth: "Lua .14.7.7.2 does not move lifecycle, rollout, or the 98-mutation snapshot, but the rule still requires every admitted projection to be rerun. Perl 143/143, Rust 1/1, Dart 19/19, and Julia 491/491 pass unchanged while both Lua ABIs advance privately to 597 GREEN/one recursive-carrier RED."
evidence_update_2026_08_27_lua_recursive_carriers: "Lua .14.7.7.3 does not move lifecycle, rollout, or the 98-mutation snapshot. The stable dormant consumer reaches 888/888 on both ABIs; admitted Perl/Rust/Dart/Julia projections must still pass unchanged before landing."
evidence_update_2026_08_27_lua_admission: "Lua .14.7.7.4 exercises the lockstep rule directly: aggregate status, mutation count 98→106, Lua lifecycle, and rollout rows 6/7 move in the neutral contract and in all five admitted consumers. Perl 143/143, Rust 1/1, Dart 19/19, Julia 491/491, and Lua 888/888 per ABI pass without production behavior changes."
reverify:
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
  - "prove -Iperl -It/lib t/staged_ast_enrichment_perl_contract.t"
  - "bash tools/run_cargo_local.sh test --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test staged_ast_enrichment_contract"
  - "cd dart && bash ../tools/run_dart_project_data.sh test --reporter failures-only test/staged_ast_enrichment_contract_test.dart"
  - "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no julia/test/staged_ast_enrichment_contract_test.jl"
---

# Staged consumer current-projection lockstep

The independent neutral checker is the semantic authority, but every admitted backend consumer also freezes the
complete current neutral snapshot before exercising backend-specific behavior. A later backend's lifecycle change
therefore changes three cross-consumer projection values: the aggregate status string, the governed mutation
count, and that backend's lifecycle row.

This is an intentional cross-check, not backend behavior coupling. Perl and Rust runtime semantics do not change
when another backend lifecycle moves; only their current neutral snapshot changes. Julia admission repeats the
same cross-check over Perl, Rust, and Dart. Any future backend lifecycle transition must run every already-admitted
staged consumer, not only the independent checker and the backend currently moving. Lua admission applies that
rule to all five sources/six routes and leaves a 106-mutation all-private-complete projection.

Related: [[general-staged-ast-enrichment-neutral-contract]], [[dart-staged-ast-enrichment-dormant-red]],
[[lua-staged-ast-enrichment-carriers-admission]], and ADR
`0088`. Owner: [[FUTURE-PARITY-BACKLOG]] `.14.7.5.0`.
