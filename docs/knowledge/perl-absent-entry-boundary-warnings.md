---
id: perl-absent-entry-boundary-warnings
title: Perl entry-start lowering preserves absent entry values without warning-prone arithmetic
answers:
  - why does a fresh Perl emitted parser warn about uninitialized subtraction at entry_start_pos
  - which Perl entry helpers use an absent entry match width
  - does fixing entry-start warnings change absent captures or zero-width matches
  - why are native constructor results correct while fresh emitted hosts warn
date: 2026-09-27
status: verified under SPEC-LANGUAGE-SELF-CONTAINMENT.1.1.3.1.2.2.7
tags: [perl, entry, captures, generated-source, source-location, warnings]
evidence: "Canonical f80b4693b passes generated_source_contract.t values but emits two warnings. The public emit_generated_source probe isolates constructor-matrix generated line87: $IPOS - length($IMATCH), with undefined root-entry match. Initial87-assertion regression reproduces exactly six emitted warning failures; every native/emitted value and matched-entry control passes. Seven calculations in ActionIR/Contracts.pm now normalize absent width; final104 assertions, focused218 and full Phase01033 pass."
reverify: "bash tools/project_data_run.sh prove -v -Iperl t/generated_source_contract.t t/typed_source_location_perl_contract.t t/complete_named_mark_contract.t t/nested_tree_readiness.t"
---

Selecting the root does not perform a regex match. Its entry position is valid but its entry match text is absent.
The emitted host inherits lexical warnings; unguarded subtraction converts length(undef) to zero and warns. The
isolated warning-enabled child uses public emitted source and Carp attribution; no dependency internals are read.
Logs from the discovery are .linkedspec-data/scratch/lua-census-warning-matrices-probe.log and the generated
.linkedspec-data/scratch/lua-census-warning-matrix.pl (line87). The warning is unrelated to generic flat container-kind dispatch.

Affected lowering sites are entry_line, entry_start_line, entry_col, entry_start_col, entry_start_pos,
mark_entry_start and rewind_entry_start in perl/LinkedSpec/ActionIR/Contracts.pm. Only those seven computations
normalize absent text to an empty string for width arithmetic. Already guarded entry_text/entry_len and all local
match projections remain unchanged; absent text/length stay null and a present empty capture stays empty/zero.

The regression extends the existing generated-source temporary owner. Six fixtures, each executed twice natively
and twice in a warning-enabled fresh process, retain exact JSON kinds/values, root offsets after leading trivia,
Unicode line/column positions, marks and rewind effects. The initial five-fixture RED fails six emitted no-warning
assertions out of87; all value assertions and matched Unicode/empty controls pass. Four pre-existing Phase0 source-expression
expectations move with the seven-site lowering correction, without changing behavioral expected values.

A final matched-zero-text control proves that the fallback uses definedness rather than truthiness. The expanded
regression passes104 assertions across six fixtures and24 total native/fresh emitted calls; the initial RED retains
its original six warning failures out of87. Every frozen source-location/mark authority and nesting fixture remains
byte-identical. Final Phase0 passes1033/1033 in1040s after the fourth source-pattern pin is corrected. The complete first run
records only that stale pin failure; all behavioral expected values are retained.
