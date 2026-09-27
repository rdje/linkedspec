---
id: perl-emitted-public-entry-trivia
title: Perl emitted Execute must share native leading-trivia cursor preparation
answers:
  - why does a prefix guard mutation differ between native and emitted Perl
  - does emitted Perl skip leading blank and hash comment lines
  - why did emitted cursor_pos start at zero after a comment
  - which test proves Perl nesting recovery and mutation sensitivity
  - does parser input have to begin with a spec rule declaration
date: 2026-09-27
status: verified native/emitted repair and Perl nesting proof
tags: [perl, emitted-source, public-entry, unicode, cursor, readiness]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.1.1 owns the immediate repair exposed by nesting mutation proof. Public Get versus emit_generated_source returns6/0 for a hash-comment prefix and1/0 for leading LF; ordinary input returns0/0. The original implementation fails15/192 new top-level tests. Shared Runtime preparation makes the minimal probe agree and the new regression pass192; five dependent suites pass274. Complete Phase0 passes1033/1033 in1026s. Exact commands and source/log hashes are in docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.1.1-verification.json."
reverify: "env PERL5LIB= bash tools/project_data_run.sh prove -v -Iperl t/nested_tree_readiness.t t/generated_source_contract.t t/sexpr_document_v1.t t/typed_source_location_values.t t/typed_source_location_perl_contract.t; env PERL5LIB= bash tools/project_data_run.sh prove -v -Iperl t/phase0_regression.t"
---

The first composed nesting mutation removes only its prefix guard. Native Get then wrongly accepts a
wrapper-skipped hash-comment line, while the old fresh emitted parser still rejects through its catch-all.
The original grammar agrees across routes; the mutation exposes a public-entry implementation gap.
A minimal `Top` entry action returning `cursor_pos()` reproduces the difference without nesting: input
`#skip\n(a)` starts at6 natively and0 emitted; `\n(a)` starts at1 and0 respectively.

`perl/LinkedSpec/Runtime.pm` wrapped native parser calls with a scalar-reference-safe position reset and
leading-trivia skip. `perl/LinkedSpec/Compiler.pm` generated postamble `Execute` only reset position0.
The repair extracts `_prepare_public_input` in Runtime and invokes it from both paths. Emitted source
loads that runtime owner explicitly. The v2 contract/schema and direct child-handler behavior remain unchanged.
Regenerate pre-repair artifacts to receive the corrected emitted entry behavior.

The skip consumes complete spaces/tabs-plus-LF blank lines and spaces/tabs-plus-# comments through LF or EOF.
It does not consume ordinary horizontal/non-ASCII whitespace or CRLF blank lines. Original input text remains
intact, Unicode scalar coordinates remain absolute, and child entry does not repeat public preparation.
Invalid input shapes bypass preparation and retain the existing parser guard's ownership.

`t/nested_tree_readiness.t` checks all five descriptor rules as ActionIR-ready,40 original executions per
native/emitted route (including14 immediate recoveries after typed status1 rejection), three independent
prefix/gap/span mutations,14 authored entry controls repeated twice, and two child-entry controls. The emitted
route loads in a separate process and validates the v2 plan/source identity. JSON comparison distinguishes
number/string and other scalar kinds. `cases.json` and the grammar are unchanged.

The related runtime-semantics appendix incorrectly applied spec-source rules to ordinary parser input.
Empty/ordinary/comment-only entry controls establish that parser input need not be nonblank or begin with a
rule declaration. The corrected book distinguishes spec compilation from runtime input and grammar acceptance.

Related: [[nested-tree-public-native-readiness]], [[sexpr-document-entry-prefix-validation]],
[[rust-leading-input-trivia-boundary]], [[ds-vhistory-leading-newline-oracle-boundary]].
