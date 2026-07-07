---
id: legacy-helper-retirement-split-inventory
title: "SPEC-FORMAT-TERSE.8 inventory: Perl legacy helpers are hard-retired; Rust retirement remains pending; push_nonempty is semantic, not a plain push alias."
answers:
  - "which legacy helpers still succeed before SPEC-FORMAT-TERSE.8 retirement"
  - "is push_nonempty just a push alias"
  - "which Perl helper spellings are already retired before SPEC-FORMAT-TERSE.8"
  - "which Rust helper spellings still execute before SPEC-FORMAT-TERSE.8"
  - "what must be migrated before removing legacy helper support"
date: 2026-07-06
status: current
tags: [spec-format-terse, legacy-helpers, compatibility, retirement, push_nonempty, perl, rust, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.8.1 classified the helper-retirement surface before behavior changes. Perl `LinkedSpec::call_spec_handler_subst` showed `assign(x, 1)` raw/unlowered, `scalar(...)` and `s(...)`/`a(...)`/`h(...)` diagnostics, and still-successful `declare(...)` plus declaration aliases, `concat(...)`, `array_copy(...)`, `hash_copy(...)`, `push_value(...)`, and `push_nonempty(...)`. SPEC-FORMAT-TERSE.8.3 then hard-retired those still-successful Perl helper spellings: they now emit `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:<name>` diagnostics while `cat(...)`, `copy(...)`, `push(...)`, assignments, and typed wrappers keep current behavior. Rust `engine.rs` still has successful runtime arms for `declare`, `array_copy`, `hash_copy`, `concat`, `push_value`, `push_nonempty`, and `array|a` / `hash|h` wrapper aliases until `SPEC-FORMAT-TERSE.8.4`. `push_nonempty(...)` skips undef, empty strings, empty arrays, and empty hashes while preserving data such as the string \"0\", so current sources migrated to explicit `is_nonempty(...)` guards before hard retirement."
reverify: "perl -Iperl -MLinkedSpec -e 'my @stmts=(q{assign(x, 1)}, q{return(concat(\"a\", \"b\"))}, q{return(array_copy(array(items)))}, q{return(hash_copy(hash(meta)))}, q{push_value(items, \"a\")}, q{push_nonempty(array(items), \"a\")}, q{declare(array, items)}, q{return(s(foo))}, q{return(a(foo))}, q{return(h(foo))}, q{return(scalar(foo))}, q{declare_s(x)}, q{declare_a(items)}, q{declare_h(meta)}); for my $stmt (@stmts) { my $out=LinkedSpec::call_spec_handler_subst(\"Top\",$stmt); $out =~ s/\\n/\\\\n/g; print \"$stmt => $out\\n\" }' && rg -n '\"declare\"|\"array_copy\"|\"hash_copy\"|\"push_value\"|\"push_nonempty\"|\"concat\" \\| \"cat\"|\"array\" \\| \"a\"|\"hash\" \\| \"h\"' rust/linkedspec-runtime/src/engine.rs"
---

# Legacy Helper Retirement Split Inventory

`SPEC-FORMAT-TERSE.8` cannot be a single blind removal. The current implementation surface is uneven:

- Perl already treats `assign(...)` as raw/unlowered.
- Perl already diagnoses `scalar(...)`, `s(...)`, `a(...)`, and `h(...)` as unsupported helper spellings.
- Perl `.8.3` now diagnoses declaration helpers, `concat(...)`, `array_copy(...)`, `hash_copy(...)`,
  `push_value(...)`, and `push_nonempty(...)` instead of lowering them successfully.
- Rust still executes `declare`, `array_copy`, `hash_copy`, `concat`, `push_value`, `push_nonempty`, and the
  `array|a` / `hash|h` wrapper aliases.

`push_nonempty(...)` is not equivalent to `push(...)`: it filters absence/empty values. Current-source migration
preserved that behavior with explicit `is_nonempty(...)` flow before the Perl helper was retired.
