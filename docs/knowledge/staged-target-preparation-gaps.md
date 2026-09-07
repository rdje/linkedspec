---
id: staged-target-preparation-gaps
title: Individual staged target checks miss competing destinations before the first callback
answers:
  - "do staged jobs reserve all destination fields before callbacks"
  - "why can two staged replace_field jobs overwrite the same field"
  - "why does staged sibling collision run one callback before rejection"
  - "which task repairs complete-depth staged target reservation"
date: 2026-09-07
status: paired Rust/Perl counterexamples measured; repair pending under SESSION-STARTUP-READING.73
tags: [perl, rust, staged-parsing, stitching, queue, startup-reading]
evidence: "SESSION-STARTUP-READING.3.3.37 uses public host enrichment entrypoints, caller-prepared neutral registry data and independent callback counters; .73 owns complete destination preparation."
reverify:
  - "bash tools/project_data_run.sh .linkedspec-data/scratch/startup96-staged-boundaries/probe .linkedspec-data/scratch/startup96-staged-boundaries"
  - "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl .linkedspec-data/scratch/startup96-staged-boundaries/perl-probe.pl .linkedspec-data/scratch/startup96-staged-boundaries"
  - "bash tools/run_python_project_data.sh tools/check_staged_ast_enrichment_contract.py"
---

# Competing destinations are not reserved as a complete depth

Both one-depth and recursive Perl and Rust entrypoints reproduce these controls:

| Two authored destination choices | Callback count | Outcome |
| --- | --- | --- |
| separate sibling fields | 2 | both results retained |
| the same initially absent sibling field | 1 | staged_stitch_target_collision |
| the same existing replacement field | 2 | success; the second result overwrites the first |
| first result replaces the second queued marker | 1 | staged_marker_mismatch |
| append twice to one existing array | 2 | both results retained in order |

The ordinary nested-marker control succeeds with one callback. A marker supplied as the whole root instead
receives Perl's explicit no-parent-path denial and Rust staged_stitch_target_missing before callbacks; this control is kept separate from destination
reservation defects and does not adopt root-marker replacement as new syntax.

Perl's _prepare_depth in `perl/LinkedSpec/StagedASTEnrichment.pm` 323–443 validates each target against the
unchanged starting AST. _execute_depth and _stitch_value recheck the currently modified AST later. There is no
complete-depth reservation table, so competing jobs can pass preparation. The same source structure appears in
Rust's enrich_current_depth/enrich_recursively and validate_stitch_target; all fourteen paired native records confirm the same callback counts and success ASTs.

ADR0088's Dart .14.7.5.3 evidence already identifies and fixes this class through complete target reservation.
The repair must preserve multiple deterministic appends and distinct targets, reject conflicting target paths
before callback one, and retain the existing rule that a failure publishes no partial AST. Callback counts
prove completed child work even when the composed AST itself is not returned. No external callback side effect
or user data exposure is claimed by these synthetic local controls.

The Perl harness constructs real private markers through construct_marker with matching local input/capture
spans; it does not forge the marker class or private state. It consumes the same seven logical target cases and
options as the Rust harness, while recording backend-specific source identities. Full response equality is not
claimed. Both modes complete in 0.102 seconds total with empty stderr; all fourteen response records are kept
under `.linkedspec-data/scratch/startup96-staged-boundaries/`. Fresh staged 123 base/129 public mutations and
typed-source14/0/231 pass; these unchanged fixtures do not cover the competing-destination cases.

The Rust probe compiles against the hash-verified current debug runtime/serde libraries with empty compiler
stderr (385.205 seconds); all twenty original Rust records run in 0.357 seconds. Its one caught arithmetic
panic belongs to returned-marker repair .74, not target reservation. The paired target subset has no panic.
All artifact evidence is inventoried in the local manifest: 48 files/2,885,337 bytes; manifest 9,790 bytes,
SHA-256 `b87f41e3f3c796ff80a6a10df8cd2d6c8372eb866e3764323c1b88ee5cd6c218`.
Independent assertions verify 28 paired targets, six original returned-marker records, six validation controls
and six resource-boundary controls; assertions SHA-256
`459cbd58c047336e9036c5e87eebc371fbfa6406ae692740438f8a5f67dddb42`.
These host API probes do not establish generated/reconstructed carrier behavior or other backend outcomes.
