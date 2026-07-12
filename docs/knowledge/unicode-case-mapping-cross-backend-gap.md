---
id: unicode-case-mapping-cross-backend-gap
title: Unicode special casing is not yet behaviorally identical across LinkedSpec variants
answers:
  - do all LinkedSpec variants lowercase Unicode identically
  - do all LinkedSpec variants uppercase Unicode identically
  - what happens to sharp s in lowercase uppercase helpers
  - what happens to dotted capital I in lowercase helpers
  - what happens to the ffi ligature in uppercase helpers
  - is UTF-8 the same thing as Unicode casing
  - which task owns Unicode case mapping parity
date: 2026-07-11
status: current
tags: [unicode, casing, lowercase, uppercase, perl, rust, dart, julia, lua, parity]
evidence: "LUA-BACKEND-PARITY.4.3.2.1.0 ran direct host probes and inspected the active helper implementations. Perl `lc`/`uc` yields `ß`→`SS`, `İ`→`i` plus combining dot, and `ﬃ`→`FFI` for uppercase/lowercase pairs; Rust uses `str::to_lowercase`/`to_uppercase` and follows full Unicode mappings. Dart `String.toLowerCase`/`toUpperCase` yields `ß` unchanged, `İ`→`i`, and `ﬃ` unchanged. Julia `lowercase`/`uppercase` yields `ß`→`ẞ`, `İ`→`i`, and `ﬃ` unchanged. The mdBook previously promised only generic case normalization and selected no Unicode version or simple/full/special-casing policy. `.4.3.2.1.2` now owns that decision and all-variant alignment."
evidence_update_2026_07_12: "Director authorized the expert signoff/SOTA route. ADR 0027 adopts Unicode 17.0.0 full Default Case Conversion, locale-independent, including standard context rules such as Final_Sigma and excluding locale tailoring or implicit normalization. `.4.3.2.1.2.1`-.4 own verified official data/generation, Perl+Rust, Dart+Julia, and Lua+six-variant admission."
implementation_update_2026_07_12: "`.4.3.2.1.2.2` completes Perl/Rust generated-table consumption across scalar helper, receiver, value-array, and mutating-array paths. All 12 fixtures and full backend gates pass. The remaining observable gap is Dart/Julia/Lua until `.3` and `.4` close."
reverify: "perl -CS -Mutf8 -e 'for my $s (\"é\", \"ß\", \"İ\", \"Σ\", \"ﬃ\") { print \"$s => \", lc($s), \" / \", uc($s), \"\\n\" }' && julia --startup-file=no -e 'for s in [\"é\", \"ß\", \"İ\", \"Σ\", \"ﬃ\"] println(repr(s), \" => \", repr(lowercase(s)), \" / \", repr(uppercase(s))) end' && rg -n 'to_lowercase|to_uppercase|toLowerCase|toUpperCase|lowercase|uppercase' rust/linkedspec-runtime/src/engine.rs dart/lib/src/runtime/interpreter.dart julia/src/runtime/Interpreter.jl"
---

## Fact

The current variants do not define one identical result for every Unicode special-casing character. This is a
semantic gap, not an encoding gap: a host may store the same Unicode scalar text as UTF-8, UTF-16, or another
encoding without changing which case mapping the DSL intends.

Measured examples expose three different policies:

| Input/operation | Perl and current Rust mechanism | Dart | Julia |
| --- | --- | --- | --- |
| `uppercase("ß")` | `SS` | `ß` | `ẞ` |
| `lowercase("İ")` | `i` + combining dot | `i` | `i` |
| `uppercase("ﬃ")` | `FFI` | `ﬃ` | `ﬃ` |

The root cause is that LinkedSpec delegated to host case APIs without first choosing a Unicode version and a
simple-versus-full/special-casing policy. Standard Lua adds another constraint: neither PUC Lua nor LuaJIT provides
a portable built-in Unicode case mapper, so copying `string.lower`/`string.upper` would silently make the gap worse.

`LUA-BACKEND-PARITY.4.3.2.1.2` therefore owns a neutral fixture, the canonical policy decision, and coordinated
alignment across Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT. Deterministic pure helpers that do not depend on that
decision remain independently implementable under `.4.3.2.1.1`.

ADR `0027` now selects the repair contract: Unicode 17.0.0 full Default Case Conversion, locale-independent, with
standard context rules and no implicit normalization. The gap remains observable until the ordered backend rollout
finishes; host case APIs are no longer the intended semantic authority.

The neutral data layer is complete under [[unicode-17-case-contract-data]], and Perl/Rust now consume it under
[[perl-rust-unicode-17-case-mapping]]. Backend behavior remains divergent until Dart/Julia and Lua rollout close.
