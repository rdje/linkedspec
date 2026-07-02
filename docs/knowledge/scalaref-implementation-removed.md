---
id: scalaref-implementation-removed
title: scalaref implementation support is removed; direct nested access is the replacement
answers:
  - "is scalaref still supported"
  - "does Perl still lower scalaref"
  - "does Rust still parse scalaref paths"
  - "what happens if scalaref is used"
  - "which leaf removed scalaref"
  - "what replaced scalaref after removal"
date: 2026-07-02
status: confirmed
tags: [dsl, retirement, scalaref, direct-access, perl, rust]
evidence: "SCALAREF-RETIREMENT.4 removed Perl _lower_scalaref_value_expr support, receiver-dot hash-chain scalaref support, helper whitelists, Rust ScalarRefPath parsing/runtime dispatch, validation support, and the runtime call_helper arm. Focused Perl negative tests emit LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:scalaref; focused Rust negative tests return JSON null. Migrated direct-access positives stay green."
reverify: "bash -lc '! rg -n \"ScalarRefPath|_lower_scalaref|_split_scalaref|_lower_scalaref_segment|callee_expects_scalaref|parse_scalaref|eval_scalaref|format_scalaref|scalaref_container_arg|\\\"scalaref\\\" =>|\\| \\\"scalaref\\\"\" perl/LinkedSpec rust/linkedspec-core/src rust/linkedspec-runtime/src' && cargo test -q --manifest-path rust/linkedspec-runtime/Cargo.toml scalaref_retirement_4"
---

# `scalaref(...)` Implementation Removal

`SCALAREF-RETIREMENT.4` removed implementation support for the legacy helper.
It is no longer a supported `.spec` helper on either backend.

Current replacement contract:

- scalar hashref/arrayref payload reads use direct nested access, such as `retv["content"]` or `retv[0]`;
- named working-hash reads use `scalar(hash(name), key)`;
- receiver expressions that used `.scalaref(key)` should first assign the hash value to a named working hash, then
  read it with `scalar(hash(temp), key)`.

Old spellings follow the existing unsupported/unknown-helper policy. Perl focused lowering reports
`LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:scalaref`; Rust unknown-helper evaluation returns `undef`/JSON `null`.
