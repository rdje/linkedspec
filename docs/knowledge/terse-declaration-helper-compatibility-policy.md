---
id: terse-declaration-helper-compatibility-policy
title: "declare(...) is retired on the Perl reference after SPEC-FORMAT-TERSE.8.3; Rust compatibility remains pending; new authoring uses terse auto-existing variables and assignment/mutation forms"
answers:
  - "does declare remain supported"
  - "should declare be removed after the terse migration"
  - "what is the post-migration declare compatibility policy"
  - "is declare legacy compatibility"
  - "where are declaration helpers allowed"
date: 2026-07-06
status: current
tags: [spec-format-terse, declare, compatibility, dsl, decision]
evidence: "ADR 0018 and SPEC-FORMAT-TERSE.6.4 originally kept `declare(...)` and declaration aliases as accepted legacy compatibility after live shipped specs, public examples, and root corpus examples moved to terse replacements. SPEC-FORMAT-TERSE.8 supersedes that retention policy for this unreleased project. SPEC-FORMAT-TERSE.8.3 now makes Perl `declare(...)`, `declare_s(...)`, `declare_a(...)`, `declare_h(...)`, `declare_scalar(...)`, `declare_array(...)`, and `declare_hash(...)` emit retired-helper diagnostics. Rust still retains declaration compatibility until `SPEC-FORMAT-TERSE.8.4` resolves the recursive accumulator scoping boundary."
reverify: "rg -n 'declare\\(|\\.declare\\(' specs || true; rg -n 'declare\\(|\\.declare\\(' docs/linkedspec-book/src --glob '*.md' --glob '!**/declaration-helper-reference.md' --glob '!**/helper-contract-catalog.md'; cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test corpus_oracle -- --nocapture"
---

# Terse Declaration Helper Compatibility Policy

The post-migration policy changed in `SPEC-FORMAT-TERSE.8`: compatibility retention is being removed.

On the Perl reference, `declare(...)` and declaration aliases now emit
`LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:<name>` diagnostics. Rust still accepts them
until `SPEC-FORMAT-TERSE.8.4` resolves or diagnoses the recursive accumulator boundary.

They are not the current authoring surface. New shipped specs, current-facing examples,
and root corpus examples should use:

- `name = value`;
- `items = []` or `items += value`;
- `meta = { ... }` or `meta[key] = value`;
- `set(...)`;
- bare value reads, with `array(...)` / `hash(...)` wrappers where an explicit aggregate-storage boundary is needed.

The remaining compatibility work is Rust-side hard retirement plus final book/KM cleanup.
