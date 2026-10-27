---
id: static-named-capture-lowering-and-function-fence
title: Static capture-name getters lower through typed values and retain the pure-function parser-state fence
answers:
  - does Perl accept quoted entry_named or match_has names
  - does a bare capture name read a working variable
  - why does quoted match_has report ready but call an undefined host helper
  - are computed capture-name expressions supported on ordinary Perl
  - do empty and zero named captures retain String kinds
  - can discarded named capture calls use VALUE_DROP
  - can a pure function read input_text or named captures
  - how can a pure function normalize a capture without reading parser state
  - which task owns remaining function parser-state helper boundaries
date: 2026-10-27
status: bounded Perl static names/current15-reader function fence repaired; remaining family/context assessment29.2 next
tags: [perl, capture, names, functions, purity, lowering, readiness]
evidence: "TYPE29.1 retained ordinary quoted intake and exact four unchanged4ecd1e6dc function producers/emission; five new native/fresh/metadata groups plus source-location4/statement-provenance16."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= prove -q -Iperl t/named_capture_literal_names.t"
---

Bare Contracts callbacks recognize only word names; quoted known calls therefore
reached missing host functions with ready metadata. Typed static-name lowering now
shares existing entry/local named/has primitive rendering with native callbacks.
Bare tokens remain symbolic capture identities even under working-variable
shadowing; quoted Strings are escaped as data. String0/empty/nonparticipating/
missing values and numeric presence are preserved. Dynamic/computed shapes and
wrong arities use existing unsupported markers and unready metadata, distinct from
valid unknown-name undef/0. No new helper/schema/callback operation.

Paired VALUE_DROP contract/primitive scanner lists now include the four existing
named helpers. Discarded quoted calls compile without raw fallback. The original
entry/match raw recognizers, frame recorders and source-membership authority remain.
A first candidate passes four new groups but misses those four dropped statements;
adding paired membership closes the remaining group without a new IR kind.

The accepted function contract/Phase0 negative forbids parser-state readers. The
mixed bare named probes actually fail/unready; they do not prove successful fresh
frame execution. A separate isolated fn read_input(){return(input_text())} returns
caller x with raw0/unresolved0/ready1 before repair. Current active function lowering
now rejects the four named and eleven input/cursor readers touched here with
explicit helper diagnostics/unready metadata, preserving explicit caller argument
forwarding. Other helper classes/contexts stay independently owned29.2; no full
purity/callback/portable admission follows. Exact original programs, emission and
diagnostic preludes remain in named-capture-function-intake.json.gz.

All five new native/fresh/metadata groups pass after RED; getter contract4 and
statement-provenance16 also pass. Valid ordinary metadata is raw0/unresolved0/ready1;
invalid shapes skip effects/stay unready and all15 function readers diagnose.
No capture/cursor mutation, copy-depth, source-coordinate or compiled-format policy
changes. Full source/domain/function/context admission remains23.4.
