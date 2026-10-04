---
id: perl-basic-statement-source-frames
title: Basic statement diagnosis establishes contiguous original text; eleven producer origins are now implemented
answers:
  - "does the Perl ActionIR statement splitter strip comments"
  - "can basic statement source frames be contiguous"
  - "which eleven basic statement contracts lack private provenance"
  - "how are statement source offsets distinguished from equal quoted raw strings"
  - "what does default trim_action_ir_value remove"
date: 2026-10-04
status: diagnosis historical at c02/e614; private frames .1 and eleven producer hooks .2 implemented; statement-family acceptance .3 verified with canonical landing requirement
tags: [perl, actionir, statements, source-provenance, comments, unicode]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0 captures22 authored cases/three seeds at3738 regular immutable Git inputs plus two explicit overlays,59 statements and37 selected events per run, zero private origins;19 diagnosis/9 consumer/5 book RED controls,52 complete consumer groups and three rendered original examples."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-review.py"
  - "bash tools/run_python_project_data.sh docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.1.1.0-consumer-review.py"
---

# Basic statements need producer frames, rather than raw-string search

The default callback resolves to EmitContext.pm, which forwards through StatementSplit
and StatementSplit::Core. Core's quote/comment modes append original characters.
Top-level semicolons, line breaks and attached-method boundaries flush accumulated
text; the default EmitContext trim removes only leading/trailing whitespace. A nested
comment newline is retained inside the statement. No interior comment removal was
observed in this bounded default-callback corpus.

For `my #inside` followed by CRLF and ` $x;`, the splitter returns `my #inside` and
`$x`; neither is a bare declaration. `exit #inside` followed by CRLF and ` 7;`
returns two statements and the existing exit scanner recognizes the first, with
payload `#inside`. This is existing compile/inspection behavior; the probes do not
execute it or repair comment semantics. Comment classification remains owned by .7.3.

The independent oracle assembles original literal segments and accumulates Unicode
scalar offsets. It distinguishes quoted equal text, duplicate declarations, nested
attached bodies, regex delimiters, CRLF, non-ASCII comments and Unicode whitespace.
All59 returned statements per run match authored contiguous intervals. Each of the
eleven basic statement contracts produces two repeated events in its named fixture:
return_bare, exit_bare, linecount_prefix_newline_matches, print_capture_substr,
my_declare_bare, assign_match_my, destructure_imatch_list_my, regex_subst_assignment,
next_bare, ref_field_assign and position_tracking. At the recorded diagnosis none had a private source origin; .2 now retains the exact original events through the .1 frames.

Private frame capture under .1 records original boundaries inside the canonical splitter and binds the returned array
and statement occurrence index, then record the original event identity at emission.
Retain all five dependency callbacks and their existing signatures/call effects.
Unknown callbacks, custom interior transformations and arbitrary host input remain
unassessed; decline invented spans instead of searching equal raw text. Child .1 implements private frames and .2 implements all eleven producer hooks; .3 owns canonical family acceptance. Follow perl-basic-statement-event-source-provenance for the implementation evidence.

The conservative fixed snapshot excludes Gitlinks/non-regular metadata without reading
submodule payload. It is a supplied-input superset, not a minimal IO read set. All actual
before/after contents, modes and population gates are retained. OS/host Perl and standard
libraries are necessary read-only prerequisites; no cross-host transcript identity or
new runtime/backend admission is claimed. The first incorrect AST-suite selection is
retained separately; the corrected existing four suites pass52 complete groups.

Statement-family .3 repeats the complete immutable ab2c activation boundary:3864
regular inputs/no overlays, four fixtures80 groups,66 exact prior guarded compiler
recurrences,177 authored frames and111 exact original event origins. Three foreign-source
probes preserve events without origins. Fifteen reason-specific RED controls and five
render controls pass; final source-bound diagnostic repair and updated teaching follow below.
The original .2 claim freezes at ab2c after61 input hashes verify. Exact staged canonical
receipt is the family landing condition; twenty-contract composition remains .1.1.2.

The final .3 boundary additionally binds two failed reviewer replays to the exact
executed source: all six logical traceback frames match, and six controls reject both
original unbound contexts plus producer/channel/completeness corruptions. Original
uncached diagnostics disclose the unbound formatter input rather than claiming it
recovered. Final 58-input book renders five examples/two chapters with six controls.
The interrupted first canonical attempt is retained without a complete pass claim;
exact staged canonical CI repeats after repair. Follow python-replay-traceback-source-binding.
