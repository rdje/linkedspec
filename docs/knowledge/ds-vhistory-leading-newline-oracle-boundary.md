---
id: ds-vhistory-leading-newline-oracle-boundary
title: ds_vhistory leading-newline fixture exposes a public-parser versus descriptor-handler oracle boundary
answers:
  - "why does ds_vhistory_version_entry expect null object name"
  - "why does Dart return /proj/foo for ds_vhistory_version_entry"
  - "what is the ds_vhistory public parser descriptor handler discrepancy"
  - "should Dart weaken ActionIndexedVarExpr for cur_object[1]"
  - "which leaf owns the ds_vhistory leading-newline oracle boundary"
date: 2026-07-09
status: current
tags: [dart, perl, rust, oracle, ds_vhistory, parser-smoke, DART-BACKEND-PARITY]
evidence: "DART-BACKEND-PARITY.6.2.4.4.5 probed the `ds_vhistory_version_entry` residual before changing Dart. Public `LinkedSpec::get_parser(\"ds_vhistory\")` returns the checked null object name for the leading-newline fixture, and Rust `oracle_corpus_matches_perl_reference` passes that fixture. Directly invoking the generated `vhistory` descriptor handler on the same source prints and returns `/proj/foo`. `call_spec_handler_subst` lowers `cur_object[1]` to `$cur_object->[1]`, and a minimal public parser with `payload = [\"tag\", \"name\"]; return(payload[1])` returns `\"name\"`, so scalar-held indexed reads are valid in ordinary public-parser execution. A minimal leading-newline action-edge grammar reproduces the null, while the same shape without the leading-newline regex returns `/proj/foo`. Therefore `.6.2.4.4.5` split `.6.2.4.4.6` for the actual public-parser/oracle boundary instead of weakening Dart `ActionIndexedVarExpr` globally."
reverify: "perl -Iperl -MLinkedSpec -MJSON::PP -e 'my $p=LinkedSpec::get_parser(\"ds_vhistory\"); open my $fh,\"<\",\"rust/linkedspec-runtime/tests/corpus/ds_vhistory_version_entry/input.txt\" or die $!; local $/; my $in=<$fh>; print JSON::PP->new->canonical(1)->allow_nonref(1)->encode($p->(\\$in)),\"\\n\";' && cd dart && dart run bin/corpus_runner.dart --corpus ../rust/linkedspec-runtime/tests/corpus --execute --case ds_vhistory_version_entry || true"
---

The `ds_vhistory_version_entry` mismatch is not a safe request to weaken Dart
indexed-variable reads. The public Perl parser returns a null object name for the
checked fixture, but direct generated descriptor-handler execution returns
`/proj/foo` for the same source.

Ordinary scalar-held indexed access still works through the public parser:
`payload[1]` over a scalar-held list returns the indexed item in a minimal probe.
The null behavior appears when the object edge is reached through a
leading-newline/start-of-input shape. That boundary is now owned by
`DART-BACKEND-PARITY.6.2.4.4.6`.

Related facts: [[dart-residual-parser-smoke-split]],
[[dart-legacy-structural-accumulator-parity]], [[rust-perl-output-oracle]].
