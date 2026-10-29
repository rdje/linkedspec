---
id: gap-selected-match-ls-live-cursor-authority
title: Capture-enabled LS observes selected end while gap-boundary commit and authored cursor mutation remain distinct
answers:
  - "where should the live cursor be before capture_gaps LS"
  - "does LS rewind survive selected edge acceptance"
  - "is selected-match cursor advance the same as gap boundary commit"
  - "what is the shared early LS cursor repair target"
date: 2026-10-29
status: shared38.0 frozen; Dart38.1 fixed/targeted-checked, independent Julia38.2/Lua38.3 next
tags: [cursor, lifecycle, LS, capture-gaps, mutation, authority, qualification]
evidence: "gap-ls-cursor-authority-intake.json.gz retains public Perl8sources10inputs native/separate emitted process exact values/cursors/typed error fields; portable7sources9inputs plus unflagged compatibility1/1, current neutral checker and exact producers/receipts."
reverify: "Recover prepare_gap_ls_cursor.py and probe_gap_ls_cursor_reference.pl from the packet; run Perl native and --fresh separately through tools/project_data_run.sh, then read_gap_ls_reference.py. Run tools/check_inter_match_gap_capture_contract.py through tools/run_python_project_data.sh."
---

Capture-enabled selection has already advanced the existing live cursor to the
selected match end before LS. Candidate gap text is still the exact span from
the separately committed gap boundary to selected start. Only accepted post-LE
completion advances that boundary; whole-rule return/unwind discards candidate
without boundary commit or tail. Existing recognition rollback authority remains.

Explicit LS rewind is real cursor mutation. It survives an early lifecycle
return and the following action. A repeated accepted edge whose post-LE cursor
lies behind selected end retains source_location_cursor_regression; do not reset
the authored cursor to make that guard pass. No new cursor, token or frame owner.

Public Perl native and independently loaded separate-process emitted modules
agree on8sources10inputs. Hcat reads4 in LS/caller, H-cat reads5 and H😀cat reads
Unicode-scalar5 with exact prefix gaps. Normal LS/LE observe4, explicit rewind
reads1 through action/early return, repeated LS rewind and action-rewind guard
both reject selected3 -> cursor0 at gap commit. All actual typed fields retained.

Portable target dart/test/fixtures/gap_ls_cursor.json has7sources9inputs.
Unflagged timing is a separate compatibility source/input: Perl observes4/4,
but that is not a portable target; each backend must preserve its independently
observed baseline. Current early-LS drift cards are dated evidence, not new RED
or repair credit here. Backend38.1-.3 establish independent actual RED before
edits and cover exact normal/generated/cursor/recognition neighbors. No broader
phase, full admission or rollback-runtime coverage is claimed by this matrix.

2026-10-29 Dart38.1 independently confirms portable7/9 has3healthy4actualRED
and one healthy legacy compatibility source/input; after narrow cursor advance/
accept preservation all7/9 pass plus legacy1/1. Same8 modules and inputs/four
healthy observations/legacy traces unchanged.28normal/nullable plus2gap native/
rollback/reconstructed/plan tests and fatal changed-file analysis pass. Existing
matching SDK warnings stay startup2.25-owned; no full gate claim. Current proof:
[[dart-gap-early-ls-return-cursor-drift]]. Julia/Lua remain independent owners.
