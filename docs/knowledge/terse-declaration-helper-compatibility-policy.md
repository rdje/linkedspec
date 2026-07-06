---
id: terse-declaration-helper-compatibility-policy
title: "declare(...) remains accepted legacy compatibility after SPEC-FORMAT-TERSE.6; new authoring uses terse auto-existing variables and assignment/mutation forms"
answers:
  - "does declare remain supported"
  - "should declare be removed after the terse migration"
  - "what is the post-migration declare compatibility policy"
  - "is declare legacy compatibility"
  - "where are declaration helpers allowed"
date: 2026-07-04
status: confirmed
tags: [spec-format-terse, declare, compatibility, dsl, decision]
evidence: "ADR 0018 and SPEC-FORMAT-TERSE.6.4 decide that `declare(...)` and declaration aliases remain accepted legacy compatibility syntax after live shipped specs, public examples, and root corpus examples moved to terse replacements. The policy keeps Perl/Rust compatibility support and the declare/no-declare oracle fixtures (`autoexist_scalar_declare`, `autoexist_array_declare`) while forbidding new shipped specs/current examples from depending on declaration helpers."
reverify: "rg -n 'declare\\(|\\.declare\\(' specs || true; rg -n 'declare\\(|\\.declare\\(' docs/linkedspec-book/src --glob '*.md' --glob '!**/declaration-helper-reference.md' --glob '!**/helper-contract-catalog.md'; cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime --test corpus_oracle -- --nocapture"
---

# Terse Declaration Helper Compatibility Policy

The post-migration policy is compatibility retention, not immediate removal.

`declare(...)` and declaration aliases stay accepted for existing specs so older source
can still compile and so the declare/no-declare convergence fixtures keep proving that
auto-existing variables match the older explicit form.

They are not the current authoring surface. New shipped specs, current-facing examples,
and root corpus examples should use:

- `name = value`;
- `items = []` or `items += value`;
- `meta = { ... }` or `meta[key] = value`;
- `set(...)`;
- bare value reads, with `array(...)` / `hash(...)` wrappers where an explicit aggregate-storage boundary is needed.

Future removal or diagnostics must be owned by a new focused leaf because it would be a
compatibility break across Perl, Rust, fixtures, and the book.
