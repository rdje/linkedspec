---
id: rust-staged-ast-enrichment-dormant-red
title: Rust general staged-AST enrichment retains one dormant recurrence RED after current-depth authority
answers:
  - "what is the Rust staged AST enrichment dormant RED"
  - "is general parse_job implemented in Rust"
  - "how do I run the Rust staged AST enrichment contract"
  - "why does Rust parse_job return null"
  - "does Rust have STAGED_PARSE_JOB_MARKER"
  - "does Rust have staged_parse_job_v2 typed provenance"
  - "is the Rust staged AST consumer in canonical CI"
  - "does function body staged parsing still work in Rust"
  - "what does FUTURE-PARITY-BACKLOG 14.7.4.0 establish"
date: 2026-08-26
status: dormant current-depth authority complete; recurrence, bounds, and rebasing remain FUTURE-PARITY-BACKLOG.14.7.4.3-owned
tags: [rust, staged-parsing, parse-job, dormant-red, source-location, generated-source, backend-parity]
evidence: "FUTURE-PARITY-BACKLOG.14.7.4.0 adds one outer-cfg Rust consumer and no production source. Ordinary Cargo discovery runs 0 tests. With linkedspec_staged_ast_enrichment_red enabled, the one test completes neutral inventory, function-body-v1 queue/resolve/load/compile/execute/cache/stitch and wrong-top controls, general expr-v1 resolve denial, and native/normalized-reconstructed/generated-plan/independently-compiled-emitted generic-call observations before failing only its final assertion: LINKEDSPEC_STAGED_AST_ENRICHMENT_RED: missing node=[STAGED_PARSE_JOB_MARKER]; typed provenance sidecar=[staged_parse_job_v2] unavailable. The neutral checker reports 79 reason-checked mutations, requires the exact dormant path, proves zero canonical references, leaves Rust rollout pending, and keeps Dart/Julia/Lua consumers absent."
root_cause: "Rust's authored expression parser represents assignment-form parse_job(...) as ordinary Expr::AssignScalar containing Expr::Call; no compiler pass claims it as a dedicated node. Native and serialized compiled specs therefore retain one generic name=parse_job call, and generated/emitted carriers preserve the same generic form. The engine's unknown-helper default at rust/linkedspec-runtime/src/engine.rs returns Undef, observed as JSON null. Separately, rust/linkedspec-runtime/src/staged_parser_registry.rs remains the explicit function-body-v1 adapter and rejects expr-v1 during resolve."
evidence_update_2026_08_26_marker_provenance: "FUTURE-PARITY-BACKLOG.14.7.4.1 resolves this exact generic-call/missing-provenance boundary. Expr::StagedParseJobMarker now exclusively owns exact assignment-form parse_job with strict literal options. Live entry/match/capture spans build exact text and Unicode-scalar direct or ordered-derived provenance; the detached staged_parse_job_v2 marker contains no execution authority. Native, reconstructed, generated-plan, and independently compiled emitted routes agree. Ordinary discovery and canonical references remain zero, Rust rollout remains pending, and the cfg consumer reaches only the final .14.7.4.2 caller-frozen-authority RED."
evidence_update_2026_08_26_current_depth_authority: "FUTURE-PARITY-BACKLOG.14.7.4.2 adds the private caller-frozen resolution/cache/current-depth policy engine. All neutral resolution, authority, identity, cache, queue/isolation, result/failure, detachment, atomicity, and denial cases pass. The exact final sentinel now names only .14.7.4.3 breadth-first recurrence, decreasing-chain/cycle/resource guards, and source-rebased diagnostics. Ordinary/canonical dormancy, v1, generated format, Rust rollout, and public/outward truth remain unchanged."
reverify:
  - "bash tools/run_cargo_local.sh test --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test staged_ast_enrichment_contract"
  - "RUSTFLAGS='--cfg linkedspec_staged_ast_enrichment_red' bash tools/run_cargo_local.sh test --offline --manifest-path rust/Cargo.toml -p linkedspec-runtime --test staged_ast_enrichment_contract"
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
  - "rg -n 'parse_job|unknown helper|staged_parse_job_marker|STAGED_PARSE_JOB_MARKER' rust/linkedspec-runtime/tests/staged_ast_enrichment_contract.rs rust/linkedspec-runtime/src/engine.rs rust/linkedspec-runtime/src/staged_parser_registry.rs rust/linkedspec-core/src/expr.rs"
---

# Rust staged-AST enrichment dormant RED

Rust still ships only the explicit function-body-v1 staged adapter. It accepts
`actionir-body.spec` / `action_block`, orders jobs deterministically, records resolve/load/compile/execute and
cache identity, and supports the function-specific `replace_field` / `body_ast` / `fail` stitch. The dormant
consumer proves that baseline and its complete wrong-top diagnostic context without changing the existing test.

The dormant boundary historically parsed the future general authored form as an ordinary scalar assignment whose
value was a generic `Expr::Call` named `parse_job`; all four routes returned JSON `null` through the engine's
unknown-helper fallback. `.14.7.4.1` now claims only the exact static assignment form as a dedicated logical marker,
while the current v1 registry independently rejects `expr-v1` at resolve and grants no accidental general parser
authority.

The exact consumer is `rust/linkedspec-runtime/tests/staged_ast_enrichment_contract.rs`. Its file-level cfg keeps
ordinary discovery at zero tests, and `tools/run_ci_local.sh` contains no reference to it. The opt-in run proves the
marker, strict options, typed provenance, denials, four logical carriers, and complete current-depth authority,
then fails one test only at the final recursive-authority assertion. That RED is a deliberate boundary contract,
not an admitted runtime failure.

`.14.7.4.1` completes the private dedicated marker and typed direct/ordered-derived provenance. `.2` completes
frozen resolution/cache and policy stitching, `.3` owns bounded breadth-first recurrence and diagnostic rebasing, and
`.4` owns four fresh-authority carriers plus ordinary/canonical admission and Rust rollout. No earlier leaf may
register the consumer or promote Rust.

Related: [[general-staged-ast-enrichment-neutral-contract]], [[general-staged-ast-current-boundary]],
[[staged-parser-registry-dispatch-contract]], [[rust-staged-ast-enrichment-marker-provenance]],
[[rust-staged-ast-enrichment-current-depth-authority]], and
[[typed-source-location-cursor-algebra-direction]].
