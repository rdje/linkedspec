---
id: semantic-grouped-edge-source-correlation-gaps
title: Grouped edge projection loses selector and source evidence on Rust and Perl
answers:
  - "why does Rust semantic selector evidence change when target names share a prefix"
  - "why does Perl grouped semantic edge have no source"
  - "does Rust parse per-target indexes in a grouped explicit action edge"
  - "which task repairs grouped semantic edge correlation and complete parsing"
date: 2026-09-07
status: dated public query and execution evidence; repairs pending under SESSION-STARTUP-READING.70
tags: [rust, perl, semantic-introspection, grouped-edges, selectors, source, parser, startup-reading]
evidence: "SESSION-STARTUP-READING.3.3.33 runs five paired public query controls and three paired Perl Get/Rust CLI execution controls with independently checked source/index facts."
reverify:
  - "bash tools/run_python_project_data.sh tools/check_semantic_introspection_contract.py"
  - "bash tools/project_data_run.sh .linkedspec-data/scratch/startup91-semantic-failure/probe .linkedspec-data/scratch/startup92-semantic-group-selector"
  - "bash tools/project_data_run.sh env PERL5LIB= perl -Iperl .linkedspec-data/scratch/startup89-semantic-bindings/probe.pl .linkedspec-data/scratch/startup92-semantic-group-selector"
---

# Grouped targets need correlation by identity and occurrence

Each tested source declares `Top::` plus two target rules. The first target has slots c/d and Child has slots
a/b. All three controls below compile and query successfully with empty diagnostics/stderr; three separate
Perl Get and Rust CLI controls on input b return `"b"`, normally and without warnings.

| Top action member(s) | Rust source_form rows | Perl source_form rows | Perl second source |
| --- | --- | --- | --- |
| `-> ChildLong \| Child[1] { return(match_text()) }` | direct, direct | direct, direct | null |
| `-> Other \| Child[1] { return(match_text()) }` | direct, indexed | direct, direct | null |
| Separate `-> ChildLong[1]` and `-> Child[1]`, each with that block | indexed, indexed | indexed, indexed | exact second member |

Rust retains both group-member excerpts, but `explicit_target_index` at
`rust/linkedspec-runtime/src/semantic_index/static_projection.rs` 1003–1024 searches for the first substring
matching the label after the first arrow. Child therefore matches the prefix in ChildLong and loses its explicit
selector. The helper also requires a bracket immediately after each located label, although the Rust action
parser applies the final group's selector to all its targets. The separate indexed controls retain correct facts.

Perl `SemanticStaticProjection.pm` 445–468 joins flattened descriptor edges to one scanned member per physical
group using the same numeric offset. `_edge_fields` 707–722 extracts only the first target from each member.
The second expanded edge thus loses its source and index even though the descriptor retains it and the shared
block executes. Source-based selects_regex construction is consequently incomplete; no fresh relations query
or execution-observation derivation is claimed in this checkpoint.

The initial two controls instead place indexes on both group members:
`-> ChildLong[0] | Child[1] { return(match_text()) }` and the Other twin. Rust's public index silently retains
one edge with has_block=false; Perl retains two shared-block edges, with its second source still absent.
Rust parser.rs 777–813 reads labels separated by pipes before parsing one selector after the final label.
With a bracket on the first label, it stops that group early. The body remainder loop at 373–430 preserves
unsupported tails only after I blocks; this action tail is discarded. These initial controls do not demonstrate
target execution. Repair .70.2 must reconcile the accepted explicit-selector grammar and preserve/reject the
complete remainder, rather than silently accepting only a prefix. No new syntax is adopted by this audit.

Task .70 separates static correlation, complete source parsing, and backend/carrier/public recurrence.
The neutral model's six groups/20 exact queries/128 mutations remain green at rollout 9/0 and admission 6/0;
matching frozen fixtures do not establish these additional source correlations.

Exact inputs, responses, commands, process status/output, source identities and independent assertions:

- `.linkedspec-data/scratch/startup92-semantic-target-index/`: 17 files/51,409 bytes plus 2,609-byte manifest,
  SHA-256 `3fb86ddcf0e1d0b09c35bb7b3b2cdd459b4b9f05ad401ce5594a7d18959a1955`.
- `.linkedspec-data/scratch/startup92-semantic-group-selector/`: 39 files/90,984 bytes plus 6,124-byte manifest,
  SHA-256 `252da991f555c3d798d6f88e79b638ce3efaacf6c91507f6794e824921c42ef7`.
- Independent assertions: 455 bytes, SHA-256 `dc3f6d9fc5697af6d32d499d73315857dc34a87c02ec251f814f323a2f00b5f4`.

The verified existing Rust probe/library and CLI are reused without compiling. Native query runs take
2.551s and 3.824s; Perl queries 10.897s and 12.078s; Get 11.180s; three CLI calls 1.279/1.233/1.246s.
Harness logical names remain startup91.spec for Rust and startup89.spec for Perl, so no full-response equality
is claimed. Retained binaries are dated evidence and require current managed rebuilding before repair signoff.
