---
id: substring-optional-arguments
title: Ordinary substring distinguishes omitted and null width with helper-specific Boolean offsets
answers:
  - does substr treat null width as omitted
  - can substring start or width be Boolean
  - which policy owns substring optional argument parity
  - why do Dart Julia and Lua substring null widths differ from Perl
date: 2026-10-27
status: all bounded reference/repair checks pass; full admission separate
tags: [substring, scalar, parity, optional-arguments]
evidence: "TYPE23.2.20; substring-optional-arguments.md and shared authored fixture; Perl native/fresh, Rust native/restored/plan reference; independent Dart/Julia/safe Lua distinctions."
reverify:
  - "bash tools/run_lua_project_data.sh puc lua/test/substring_optional_arguments_test.lua && bash tools/run_lua_project_data.sh luajit lua/test/substring_optional_arguments_test.lua"
  - "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no --depwarn=error -e 'using LinkedSpecJulia,JSON3,Test;include(\"julia/test/substring_optional_arguments_test.jl\");include(\"julia/test/scalar_string_results_test.jl\")'"
  - "cd dart && bash ../tools/run_dart_project_data.sh test test/substring_optional_arguments_test.dart test/scalar_string_results_test.dart"
  - "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/type-operation-inventory/probe_substring_arguments.pl"
  - "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test substring_optional_arguments"
---

ADR0006 Perl oracle plus ADR0023 equivalent accepted-input/results resolve ordinary
substr: omitted width selects through end; explicit null source/start/width returns
null. Boolean start/width uses true1/false0 specifically here; ADR0029 rejects Bool
for num_* arithmetic, not every helper parameter. Integer/fraction/negative/null/
Unicode and eager SIWC source snapshots remain. Global integer converters, typed
Array selectors and named-target regex mutation are separate contracts.

Assessment20 pre-repair probes distinguish Dart/Lua null-width omission and Bool
invalid0 from Julia's null-width omission/healthy Bool1/0. The frozen ledger
retains exact observations and explicit shared JSON oracle; no result is inferred
from another backend. Perl native/fresh and Rust native/restored/in-process plan
reference checks pass.

Dart20.1 locally guards ordinary null width/converts Bool1/0; new2/direct String7
tests plus format/fatal analysis pass. Julia20.2 adds only the null guard; shared9/
legacy3/direct String54 strict assertions pass. Safe Lua20.3 adds the null guard
and branch-local Bool1/0; shared/legacy/direct eight String groups/source loads
pass PUC5.5.1/LuaJIT. Every backend retains source capture/eager SIWC, Unicode,
identity/shape/rejection and mutation checks. Unary/extra-arity compatibility and
global converters stay unchanged. All bounded repairs are targeted-checked; no
full signature/domain/context/standalone/declared5.4/portable admission follows.
See docs/checkpoints/type-operation-inventory/substring-optional-arguments.md.
