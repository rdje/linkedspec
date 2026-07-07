---
id: legacy-helper-retirement-split-inventory
title: "SPEC-FORMAT-TERSE.8 inventory: Perl and Rust legacy helper spellings are hard-retired; push_nonempty is semantic, not a plain push alias."
answers:
  - "which legacy helpers still succeed before SPEC-FORMAT-TERSE.8 retirement"
  - "is push_nonempty just a push alias"
  - "which Perl helper spellings are already retired before SPEC-FORMAT-TERSE.8"
  - "which Rust helper spellings were retired by SPEC-FORMAT-TERSE.8.4"
  - "what must be migrated before removing legacy helper support"
date: 2026-07-06
status: current
tags: [spec-format-terse, legacy-helpers, compatibility, retirement, push_nonempty, perl, rust, SPEC-FORMAT-TERSE]
evidence: "SPEC-FORMAT-TERSE.8.1 classified the helper-retirement surface before behavior changes. Perl `LinkedSpec::call_spec_handler_subst` showed `assign(x, 1)` raw/unlowered, `scalar(...)` and `s(...)`/`a(...)`/`h(...)` diagnostics, and still-successful `declare(...)` plus declaration aliases, `concat(...)`, `array_copy(...)`, `hash_copy(...)`, `push_value(...)`, and `push_nonempty(...)`. SPEC-FORMAT-TERSE.8.3 hard-retired those still-successful Perl helper spellings: they now emit `LINKEDSPEC_UNSUPPORTED_ACTIONIR_HELPER:<name>` diagnostics while `cat(...)`, `copy(...)`, `push(...)`, assignments, and typed wrappers keep current behavior. SPEC-FORMAT-TERSE.8.4 then hard-retired the Rust successful paths for `declare`, `array_copy`, `hash_copy`, `concat`, `push_value`, `push_nonempty`, and wrapper aliases `a(...)` / `h(...)`; Rust validation allows those names to reach runtime only so the diagnostic is explicit. Current replacements keep corpus parity, including recursive TOP-RULE aggregate reset via `set(array(items), [])` and current hash receiver `.copy()` chains. `push_nonempty(...)` skips undef, empty strings, empty arrays, and empty hashes while preserving data such as the string \"0\", so current sources migrated to explicit `is_nonempty(...)` guards before hard retirement."
reverify: "perl -Iperl -MLinkedSpec -e 'my @stmts=(q{return(concat(\"a\", \"b\"))}, q{return(array_copy(array(items)))}, q{return(hash_copy(hash(meta)))}, q{push_value(items, \"a\")}, q{push_nonempty(array(items), \"a\")}, q{declare(array, items)}, q{return(a(foo))}, q{return(h(foo))}); for my $stmt (@stmts) { my $out=LinkedSpec::call_spec_handler_subst(\"Top\",$stmt); $out =~ s/\\n/\\\\n/g; print \"$stmt => $out\\n\" }' && cargo test --manifest-path rust/Cargo.toml -p linkedspec-runtime helpers_5_1_retired_terse_8_4_spellings_diagnose -- --nocapture"
---

# Legacy Helper Retirement Split Inventory

`SPEC-FORMAT-TERSE.8` was not a single blind removal. The initial implementation surface was uneven:

- Perl already treats `assign(...)` as raw/unlowered.
- Perl already diagnoses `scalar(...)`, `s(...)`, `a(...)`, and `h(...)` as unsupported helper spellings.
- Perl `.8.3` diagnoses declaration helpers, `concat(...)`, `array_copy(...)`, `hash_copy(...)`,
  `push_value(...)`, and `push_nonempty(...)` instead of lowering them successfully.
- Rust `.8.4` diagnoses `declare`, `array_copy`, `hash_copy`, `concat`, `push_value`, `push_nonempty`, and the
  `a(...)` / `h(...)` wrapper aliases instead of executing them successfully.

`push_nonempty(...)` is not equivalent to `push(...)`: it filters absence/empty values. Current-source migration
preserved that behavior with explicit `is_nonempty(...)` flow before the Perl helper was retired.
