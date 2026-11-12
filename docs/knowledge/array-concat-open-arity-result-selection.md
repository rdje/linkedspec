---
id: array-concat-open-arity-result-selection
title: Existing open-arity Array concatenation needs result guard and readiness coverage
answers:
  - "which task owns open arity concat array result continuations"
  - "why does concat_arrays with one or three Arrays lose result guards"
  - "does Perl concat_arrays support one or more Array arguments"
  - "why does function concat_arrays set_key stay unresolved or retain raw DSL"
  - "why does concat receiver copy logical with run after Hash rejection"
date: 2026-11-12
status: focused selection42 frozen; Perl80.1 focused-complete, independent peers pending
tags: [arrays, concat, arity, results, guards, perl, selection, recovery]
evidence: "TYPE-REFERENCE-BOOK.1.2.23.1.42; docs/checkpoints/array-concat-open-arity-selection-2026-11-12/REVIEW.md;84 own public Perl programs/66 contract passes/18 terminal-supported composition failures,84 actual module/dump pairs, first readonly0/empty stderr/fourteen corruptions/current126; no production change or peer verdict."
reverify:
  - "bash tools/project_data_run.sh env PYTHONPATH= python3 -P docs/checkpoints/array-concat-open-arity-selection-2026-11-12/review.py"
---

At cleand21b84a4c, MethodLowering.pm's existing aggregate helper signature near4222
is concat_arrays[1,unbounded], while ordinary Array-transform result roles near1883
select free-two/receiver-one. Existing public book examples already use three
Array arguments. The narrowed helper-catalog description is corrected in42.

Own84 public Get/descriptor/substitution/native/full-emitted questions use valid
Arrays, ordinary constructor/function sources and one/two/three-input free/receiver
terminal/compatible/with/Hash/later tails, empty controls and needed errors. All
corresponding terminal producers work;66 contract intents pass.18 compositions
fail: four ordinary free Hash errors, two ordinary receiver tails running D/W,
six function free unresolved/source-or-error losses, two function receiver tails
losing source/unresolved copy, four ready-reported receiver compile failures.
Readiness is independent of values; unloaded modules have no fresh-call fields.

Family80 owns repair through independent80.1 Perl/80.2 Rust/80.3 Dart/80.4 Julia/
80.5 installed Lua. Existing signatures, first producers, S/T/U once/order,
initial fallback/errors, snapshots/nested kinds and fixed/rest signatures stay
fenced. Rejected Hash operands K/V and later D/W must skip after a valid Array
result, while needed producer errors propagate. Each backend acquires its own
supported policies; these Perl counts/errors are not peer authority.

Perl80.1 now repairs the selected result-role boundary with focused504/26 supported
targets/four separate compatibility/474 preserved records and direct1028. Its
strict first historical reader passes25 controls/current186; original failures
and qualification boundaries remain. See [[perl-open-arity-concat-result-guards]].
Independent Rust80.2 is next; the selection evidence above is historical.

All84 actual module/dump pairs and full records/fields/warnings survive source-
bound archives. Emitted bytes persist/read back before fresh eval. Get's standalone
dumps follow internal handler compilation and precede invocation; full native4.2/
SESSION5 remains open. First readonly0/empty stderr/fourteen reason-sensitive
corruptions and current126 identities pass; no SDK replay or used-source rewrite.
Source seal precedes the first reader; later launch/results/prose are explicitly
outside it. Fresh packages share runtime/process. Full source/context/isolation/
registration/historical4.24/raw-error4.28/launcher/declared5.4/formatter/full23.4
stay separate. Selection itself changes no production code or helper contract.

Related: [[perl-callable-array-transform-intake]],
[[array-transform-callable-result-selection]], [[array-transform-result-guard-selection]],
[[perl-native-source-dump-custody]].
