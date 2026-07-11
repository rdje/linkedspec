---
id: native-spec-resolution-policy-drift
title: Current named spec adapters do not share one portable fallback policy
answers:
  - how does Perl PathSearch choose among duplicate spec names
  - do Perl Rust Dart and Julia resolve named specs with the same fallback order
  - why must native named spec resolution use explicit ordered search roots
  - where does named spec resolution currently live in Rust Dart and Julia
  - what did FUTURE-PARITY-BACKLOG 1.6.4.0 audit
date: 2026-07-11
status: current
tags: [resolution, pathsearch, parity, rust, dart, julia, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.4.0 source/test audit: Perl Resolver checks exact cwd, cwd name.spec, and module-root specs/name.spec before bare-name PathSearch fallback. PathSearch recursively caches cwd plus the repository tree, hash-deduplicates directories, and returns the first matching hash-key iteration result. Rust and Dart primary adapters stop after the three local candidates; Julia adds a sorted/pruned recursive repository fallback. All three non-Perl mechanisms are process-adapter-only."
evidence_update_2026_07_11_contract: "FUTURE-PARITY-BACKLOG.1.6.4.1 adopts ADR 0026 and a checked executable contract: portable named identities, separate exact paths, explicit roots in declared order, no recursion, first regular file, strict preserved UTF-8, structured pipeline stages/codes, and 13/9/4 neutral cases."
reverify: "sed -n '1,180p' perl/PathSearch.pm && rg -n '_resolve_local_spec_path|PathSearch::go|resolve_named_spec|resolvePrimaryCliNamedSpec|_resolve_named_spec_path|_find_primary_cli_repository_spec' perl/LinkedSpec/Resolver.pm rust/linkedspec-runtime/src/primary_cli.rs dart/lib/src/cli/primary_cli.dart julia/src/cli/LinkedSpecJuliaCli.jl"
---

The common prefix is real: each current command path can try the requested path relative to its working directory,
then append `.spec`, then try the repository's `specs/` directory. What happens after that prefix is not equivalent.
Rust and Dart report a miss. Julia recursively scans selected repository directories in sorted order. Perl calls
legacy `PathSearch` for a bare-name miss.

`PathSearch` cannot serve as a portable duplicate-name contract in its current form. Its process-wide state starts
with the current working directory plus a recursive repository walk, later roots are merged through a hash, and
matches are selected from hash-key iteration order. It also caches the discovered set across calls. The result is
implicit, process-dependent discovery rather than caller-visible deterministic precedence.

The native parity lane therefore separates compatibility from the portable API. New native APIs will take explicit
ordered search roots and a checked-in fixture will own precedence, regular-file handling, strict preserved UTF-8,
source identity, parse/compile order, and structured stages. Perl may retain implicit recursive `PathSearch` for
legacy callers, but Rust, Dart, Julia, Lua, and future variants must not reproduce its unordered selection.

Related facts: [[backend-capability-census]], [[native-in-memory-backend-contract]],
[[julia-primary-cli-arguments-resolution-loading]], [[native-spec-resolution-contract]].
