---
id: perl-legacy-call-source-origins
title: Legacy call/return/push origins retain the selected original event objects
answers:
  - "which Legacy call return push contracts retain private source origins"
  - "does Legacy call provenance include recognize_once nested calls"
  - "does target push provenance include primitive literal targets"
  - "how do Legacy call return push hooks preserve callback and event identities"
date: 2026-10-06
status: verified private source hooks; other Legacy families remain active
tags: [perl, actionir, legacy, source-provenance, callbacks, event-identity]
evidence: "SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.1.4.1 owns seven original regex source hooks and preserves return_general. The standard helper-source fixture reuses independently authored original diagnosis intervals/arguments and tests selected constructor/returned/argument identities, callback effects, Unicode/CRLF repeats and two exclusion controls."
reverify:
  - "bash tools/project_data_run.sh prove -Iperl t/actionir_helper_source_provenance.t"
  - "Full .1.4.1 review is historical at da5c8d1f66732f0989cecca745557005fe44e7c1; current .1.4.5 cursor/input recurrence preserves this call-source family."
---

# Selected original Legacy call/return/push occurrences

Seven LegacyRules producers snapshot `$-[0]`/`$+[0]` at their original regex
match, before prefix exclusion checks or trim callbacks. Their original event
hash and argument hash pass through ScannerCore's private recorder unchanged.
The existing `return_general` helper-pattern view, original-source slice and
hook remain byte-exact. No recognizer regex, callback or dispatch changes.

The family is `call`, `push_single_arg`, `push_indexed_arg`, `push_target_arg`,
`push_target_indexed_arg`, `push_scope_target_arg`, `return_general` and `return`.
The call scanner still excludes nested `recognize_once`/`observe_recognition`
operands; target push still rejects its original primitive literal targets.
Only selected original events receive origins. Empty scans retain empty sidecars.
Repeated equal raw text has independent scalar intervals, including Unicode
prefixes and CRLF. The public event fields gain no source metadata.

These are internal compatibility IDs, not new public helper admission. Other
Legacy source families, executable membership,
comments, replacement and global audits retain their separate task owners.

The exact clean0083dc7 boundary supplies4318 regular Git originals, a declared
standard-fixture replacement and three authored overlays per epoch, with one
LegacyRules replacement after. All112 contracts/115 cases recur under three
hash seeds:227 original events remain exact while private origins grow2 to18.
Complete original compiler/callback channels stay equal. The standard fixture
is actual RED9/GREEN23; seven consumers including Phase01034 pass1147 groups.
The actual reviewer rejects140 reason-specific evidence corruptions, including
lost origins/references/input/TAP and changed source regex/snapshot. Removing
only the seven new snapshots/wrappers reconstructs the complete original
Legacy file byte-exactly. The complete58-input book renders22 examples across
three chapters with21 rejection controls. See the owned retained claim for
scope, producer/input/channel identities and exact replay boundaries.

The later quoted-label repair changes only the boundary token decoder/imports;
call/return/push hooks and callbacks remain exact. The complete original
112-contract recurrence above is frozen at da5c8d; current quoted labels and the
verified nested unknown-escape repair are in [[perl-quoted-boundary-labels]].
