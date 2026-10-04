---
id: perl-basic-regex-source-provenance
title: Nine basic Perl regex scanner contracts retain exact original match spans privately
answers:
  - "which PrimitiveBasicRules regex contracts retain source provenance"
  - "how are basic regex helper occurrences distinguished from equal quoted twins"
  - "does basic helper provenance change public events or callback dependencies"
  - "which basic scanner statement provenance work remains"
date: 2026-10-04
status: nine regex contracts implemented; statement framing and family composition pending
tags: [perl, actionir, scanner, source-provenance, unicode, source-span]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.0 retains the actual complete ten-group frozen-owner RED (nine failures, empty-result guard green) and unchanged ten-group GREEN. Independent authored Unicode-scalar positions cover quoted and repeated equal calls for all nine regex contracts. Complete compiler/consumer acceptance is recorded by the source-bound reviewer and claim."
reverify:
  - "bash tools/project_data_run.sh env PERL5LIB= prove -v -Iperl t/actionir_basic_regex_source_provenance.t t/actionir_helper_source_provenance.t"
  - "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.0-review.py"
---

# Nine basic Perl regex scanner contracts retain exact original match spans privately

PrimitiveBasicRules captures `$-[0]` and `$+[0]` directly from each original
full-input regex match, before calling the existing private ScannerCore recorder.
The original event object and arguments are constructed unchanged; ordinary public
scans gain no fields. The five dependency callbacks, family dispatch precedence,
regexes and statement-based scanner implementations remain unchanged.

The selected contracts are `assign_call_my`, `assign_call`,
`push_child_call_indexed_builtin`, `push_child_call_builtin`, `return_call`,
`entry_slot`, `gap_span`, `gap_text` and `gap_kind`. The last four share the
existing zero-argument producer. Independently authored fixtures distinguish a
quoted syntactic occurrence at scalar8 from two later equal real occurrences,
including a Unicode prefix, CRLF and tabs. The recorder retains all three;
it does not decide executable membership or replace source.

The preceding three-contract channel proof is historical at80ecf47f258a7f23a59598a1c5500a34fe662a7c.
Its current permanent guard suite remains separate. P1 selected consumer/render input-closure repair `.1.1.3` runs first; its disclosed
gaps do not widen the fully source-bound private/compiler result. Eleven basic statement
contracts still need exact producer-side statement frames under `.1.1.1`, then
`.1.1.2` independently composes the family. Remaining scanner producers,
membership/replacement, recurring canonical admission, marker provenance and
comments retain their existing owners. No public event schema or backend admission
is implied by private telemetry.
