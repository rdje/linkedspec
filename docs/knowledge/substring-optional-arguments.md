---
id: substring-optional-arguments
title: Ordinary substring distinguishes omitted and null width with helper-specific Boolean offsets
answers:
  - does substr treat null width as omitted
  - can substring start or width be Boolean
  - which policy owns substring optional argument parity
  - why do Dart Julia and Lua substring null widths differ from Perl
date: 2026-10-27
status: frozen reference target; three backend repairs scheduled
tags: [substring, scalar, parity, optional-arguments]
evidence: "TYPE23.2.20; substring-optional-arguments.md and shared authored fixture; Perl native/fresh, Rust native/restored/plan reference; independent Dart/Julia/safe Lua distinctions."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl docs/checkpoints/type-operation-inventory/probe_substring_arguments.pl"
  - "bash tools/run_cargo_local.sh test --manifest-path rust/Cargo.toml --locked --offline -p linkedspec-runtime --test substring_optional_arguments"
---

ADR0006 Perl oracle plus ADR0023 equivalent accepted-input/results resolve ordinary
substr: omitted width selects through end; explicit null source/start/width returns
null. Boolean start/width uses true1/false0 specifically here; ADR0029 rejects Bool
for num_* arithmetic, not every helper parameter. Integer/fraction/negative/null/
Unicode and eager SIWC source snapshots remain. Global integer converters, typed
Array selectors and named-target regex mutation are separate contracts.

Independent retained argument probes: Dart and safe PUC5.5.1/LuaJIT omit null
width and turn Boolean arguments into invalid0; Julia omits null width but already
uses Boolean1/0. Perl native/fresh and Rust native/restored/in-process plan agree
with the explicit shared JSON oracle. Bounded repairs are TYPE23.3.20.1 Dart,
.2 Julia, .3 safe Lua; no full domain/standalone/declared5.4/portable admission.
See docs/checkpoints/type-operation-inventory/substring-optional-arguments.md.
