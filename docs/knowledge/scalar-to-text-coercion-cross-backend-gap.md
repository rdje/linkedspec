---
id: scalar-to-text-coercion-cross-backend-gap
title: Scalar-to-text fixture parity has bounded coverage and an open large-number spelling gap
answers:
  - does cat convert booleans identically on all LinkedSpec backends
  - does cat accept null arrays hashes identically on all variants
  - how does cat stringify 1.0 across backends
  - what task closed scalar string coercion parity
  - is concat still an alias for cat
date: 2026-09-07
status: current
tags: [scalar, string, coercion, cat, perl, rust, dart, julia, lua, parity]
evidence: "Historical July 12 LUA-BACKEND-PARITY.4.3.2.1.3 fixture proof covers Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT. SESSION-STARTUP-READING.3.3.10 reads the complete authority and proves cat(1e20-as-full-decimal-literal, empty-string) returns different native Rust/Perl text; .55.2 owns resolution. .3.3.7 separately proves unary cat arity divergence under .51. Existing numeric fixture samples -0.0, 1.0 and 1.25 do not establish arbitrary magnitude parity."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/scalar_text_contract.t && bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml -p linkedspec-runtime lua_backend_parity_4_3_2_1_3_scalar_text_contract && (cd dart && bash ../tools/run_dart_project_data.sh test test/scalar_text_contract_test.dart) && bash tools/run_lua_local.sh"
---

## Fact

The portable scalar-to-text authority specifies:

- strings are unchanged;
- booleans become `1` and `0`;
- finite numbers use stable decimal text, including `-0.0` as `0`, integral-looking `1.0` as `1`, and `1.25`
  as `1.25`;
- null, array, harray, and codeblock values are not scalar text, so any such argument makes the whole result null.

The July executable fixture established its selected cases on Perl, Rust, Dart,
Julia, PUC Lua and LuaJIT. It did not cover every portable source value or numeric
magnitude. Its codeblock row fixes the semantic value-kind rule; the original
construction-only rollout note is historical. Rust bound-variable invocation and
generic final blocks subsequently landed under `.11.4.2` and `.11.4.3`, as recorded
in [[rust-callable-codeblock-literal-state]].

September native controls expose two open boundaries: unary `cat("a")` succeeds
on Rust but returns null on Perl (`SESSION-STARTUP-READING.51`), and two-argument
`cat(100000000000000000000,"")` returns full decimal text on Rust but `"1e+20"`
on Perl (`.55.2`). The latter requires reference-policy reconciliation before
changing the frozen authority. Neither the earlier six-runtime fixture pass nor
the separate scalar-numeric helper fixture closes these cases. Exact commands and
limits: [[rust-hash-separator-and-cat-arity-defects]],
[[rust-large-number-conversion-defect]].

`cat` is the current helper name. The old `concat` spelling remains retired and is not an alias.
