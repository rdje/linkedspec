---
id: native-spec-resolution-policy-drift
title: Portable named spec resolution replaced the earlier adapter fallback drift
answers:
  - how does Perl PathSearch choose among duplicate spec names
  - do Perl Rust Dart and Julia resolve named specs with the same fallback order
  - why must native named spec resolution use explicit ordered search roots
  - where does named spec resolution currently live in Rust Dart and Julia
  - what did FUTURE-PARITY-BACKLOG 1.6.4.0 audit
date: 2026-09-07
status: historical drift with adopted portable resolution; Perl legacy extension remains bounded
tags: [resolution, pathsearch, parity, rust, dart, julia, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.4.0 source/test audit: Perl Resolver checks exact cwd, cwd name.spec, and module-root specs/name.spec before bare-name PathSearch fallback. PathSearch recursively caches cwd plus the repository tree, hash-deduplicates directories, and returns the first matching hash-key iteration result. Rust and Dart primary adapters stop after the three local candidates; Julia adds a sorted/pruned recursive repository fallback. All three non-Perl mechanisms are process-adapter-only."
evidence_update_2026_07_11_contract: "FUTURE-PARITY-BACKLOG.1.6.4.1 adopts ADR 0026 and a checked executable contract: portable named identities, separate exact paths, explicit roots in declared order, no recursion, first regular file, strict preserved UTF-8, structured pipeline stages/codes, and 13/9/4 neutral cases."
evidence_update_2026_07_11_rust: "FUTURE-PARITY-BACKLOG.1.6.4.2 expands the name proof to 14 cases for Windows-drive absolutes and makes Rust native/CLI resolution delegate to the portable policy; Dart and Julia remain active gaps."
evidence_update_2026_07_11_dart: "FUTURE-PARITY-BACKLOG.1.6.4.3 makes Dart native/CLI resolution delegate to the portable 14/9/4 policy; Julia remains the active implementation gap."
evidence_update_2026_07_11_julia: "FUTURE-PARITY-BACKLOG.1.6.4.4 makes Julia native/CLI resolution delegate to the portable 14/9/4 policy and removes the sorted recursive repository fallback. Only Perl's explicitly bounded legacy PathSearch extension remains outside the portable policy."
reverify: "sed -n '1,180p' perl/PathSearch.pm && rg -n '_resolve_local_spec_path|PathSearch::go|resolve_named_spec|resolvePrimaryCliNamedSpec|_resolve_named_spec_path|_find_primary_cli_repository_spec' perl/LinkedSpec/Resolver.pm rust/linkedspec-runtime/src/primary_cli.rs dart/lib/src/cli/primary_cli.dart julia/src/cli/LinkedSpecJuliaCli.jl"
---

At the July 11 preflight, each command path could try the requested path relative to its working directory,
then append `.spec`, then try the repository's `specs/` directory. Behavior after that prefix differed.
Rust and Dart reported a miss. Julia recursively scanned selected repository directories in sorted order. Perl
called legacy `PathSearch` for a bare-name miss. The later adoption below replaces that Julia behavior.

`PathSearch` cannot serve as a portable duplicate-name contract in its current form. Its process-wide state starts
with the current working directory plus a recursive repository walk, later roots are merged through a hash, and
matches are selected from hash-key iteration order. It also caches the discovered set across calls. The result is
implicit, process-dependent discovery rather than caller-visible deterministic precedence.

The native parity lane therefore separates compatibility from the portable API. Rust, Dart, and Julia now take
explicit ordered search roots, and the checked-in fixture owns precedence, regular-file handling, strict preserved
UTF-8, source identity, parse/compile order, and structured stages. Perl may retain implicit recursive `PathSearch`
for legacy callers, but Julia's earlier recursive adapter search is removed and future variants must not reproduce
either extension.

Related facts: [[backend-capability-census]], [[native-in-memory-backend-contract]],
[[julia-primary-cli-arguments-resolution-loading]], [[native-spec-resolution-contract]].

September 7 startup checkpoint .3.3.35 reconciles this historical description with the card's existing
.1.6.4.4 completion evidence and ADR0026. It does not rerun Julia or change the adopted resolution policy.
Fresh neutral 14/9/4 proof and complete Rust loader reading remain bounded to this checkpoint's declared scope.
