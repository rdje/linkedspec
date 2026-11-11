---
id: perl-native-source-dump-custody
title: Perl Get source dumps are post-compilation observations, not native precompile inputs
answers:
  - "does Perl handler_input prove native handler custody before compilation"
  - "when does Get compile handlers relative to parser_source_ref persistence"
  - "which task owns historical Perl native source dump timing claims"
date: 2026-11-11
status: source-bound qualification; native precompile closure remains open
tags: [perl, custody, generated-source, verification, qualification]
evidence: "Retained78.6.1.0 observer/Compiler/SpecEntry source order; readonly native-dump-timing actual0/empty stderr and three source corruption controls. Original narrative and stopped candidate log retained; no runtime replay or retroactive timing receipt."
reverify: "bash tools/project_data_run.sh env PYTHONPATH= python3 -P docs/checkpoints/array-transform-callable-perl-2026-11-11/review_native_dump_timing.py"
---

The retained Perl observer persists emit_generated_source's module before its
fresh eval. It then calls Get with dump_parser_source/parser_source_ref, persists
that standalone source dump under handler_input/handler.pl, and invokes the
returned native CODE afterward. SpecEntry::_build_runtime_handler has already
eval-compiled the internal handler before Get returns. Its internal eval source
also wraps the handler with a source directive; the standalone dump is not that
actual native compilation input.

The established order therefore proves module-before-fresh-load and
dump-before-native-invocation, without proving native-input-before-compilation.
Named SDK/instrument archives before Get remain useful source custody. Actual
values/errors/metadata and retained source bodies remain unchanged. This fact is
derived from the retained producer's control flow, not a new dynamic event trace.

Intake78.6.1.0 corrects its new prose and the current selection card before landing.
Original prose survives in native-dump-timing/original-narratives.json.gz. Existing
TYPE-REFERENCE-BOOK.1.2.23.4.2 coordinates with SESSION-STARTUP-READING.5 after feature
coverage and before admission/push: audit earlier reused Perl observers and their
claims; qualify each demonstrated overstatement, retain original receipts, and
establish prospective actual native-input capture where supported. Never present
a later capture as recovered original custody. No exhaustive historical finding
or complete native/transitive/toolchain closure is claimed here.
