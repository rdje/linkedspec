---
id: ds-vhistory-leading-newline-oracle-boundary
title: ds_vhistory passes by mirroring Perl public-parser leading trivia
answers:
  - "why does ds_vhistory_version_entry expect null object name"
  - "why did Dart return /proj/foo for ds_vhistory_version_entry"
  - "what is the ds_vhistory public parser descriptor handler discrepancy"
  - "should Dart weaken ActionIndexedVarExpr for cur_object[1]"
  - "how did Dart fix ds_vhistory_version_entry"
  - "which leaf closed the ds_vhistory leading-newline oracle boundary"
date: 2026-07-09
status: current
tags: [dart, perl, rust, oracle, ds_vhistory, leading-trivia, parser-smoke, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.6.2.4.4.5 probed the `ds_vhistory_version_entry` residual before changing Dart. Public `LinkedSpec::get_parser(\"ds_vhistory\")` returns the checked null object name for the leading-newline fixture, and Rust `oracle_corpus_matches_perl_reference` passes that fixture. Directly invoking the generated `vhistory` descriptor handler on the same source prints and returns `/proj/foo`. `call_spec_handler_subst` lowers `cur_object[1]` to `$cur_object->[1]`, and a minimal public parser with `payload = [\"tag\", \"name\"]; return(payload[1])` returns `\"name\"`, so scalar-held indexed reads are valid in ordinary public-parser execution. DART-BACKEND-PARITY.6.2.4.4.6 then root-caused the boundary to `perl/LinkedSpec/Runtime.pm`: the public parser wrapper resets `pos` and skips leading blank/comment lines before invoking the top handler, while direct descriptor handlers bypass that wrapper. Dart `LinkedSpecRuntimeEngine.parse` now mirrors that public-parser leading-trivia skip, and the focused `ds_vhistory_version_entry` corpus run passes. DART-BACKEND-PARITY.6.2.4.6 later closes the remaining structural regex blockers, so the full parser-smoke diagnostic window is now 31/31 green."
reverify: "cd dart && dart test test/runtime_interpreter_test.dart test/corpus_manifest_test.dart && dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --case ds_vhistory_version_entry"
---

The `ds_vhistory_version_entry` mismatch was not a safe request to weaken Dart
indexed-variable reads. The public Perl parser returns a null object name for the
checked fixture, but direct generated descriptor-handler execution returns
`/proj/foo` for the same source.

Ordinary scalar-held indexed access still works through the public parser:
`payload[1]` over a scalar-held list returns the indexed item in a minimal probe.
The null behavior comes from the public parser wrapper, which skips leading
blank/comment lines before invoking the top rule. Direct descriptor handlers
bypass that wrapper, which explains the `/proj/foo` direct-handler probe.

`DART-BACKEND-PARITY.6.2.4.4.6` closes the boundary by mirroring the Perl
public-parser leading-trivia skip in Dart's public `parse(...)` entrypoint.
`ds_vhistory_version_entry` now passes on Dart, and ordinary scalar-held indexed
reads remain valid.

Related facts: [[dart-residual-parser-smoke-split]],
[[dart-legacy-structural-accumulator-parity]], [[dart-structural-pcre-parser-smoke-parity]],
[[rust-perl-output-oracle]].
