---
id: perl-array-receiver-required-capture
title: Required array, number and string receiver callbacks preserve native effects
answers:
  - "which required callbacks does the array receiver normalizer acquire"
  - "can trim replace the array normalizer parser after selection"
  - "does receiver splitting pass actual substring arguments to trim"
  - "why can trim mutation turn sorted into a rejected dot call"
  - "does array receiver callback capture copy its arguments"
  - "where is required array receiver isolation verified"
  - "why did the array consumer wrapper refuse passing suites"
  - "which required callbacks do number and string receiver normalizers acquire"
  - "does the string receiver normalizer mutate the parser returned call"
  - "can parser argument mutation change __source_expr"
  - "are shared parser returned call references preserved"
  - "can trim replace the selected number or string parser"
  - "where is required number and string callback isolation verified"
date: 2026-10-11
status: focused receiver proof verified; related facts consolidated within the existing card limit
tags: [perl, actionir, receivers, callbacks, aliases, publication]
evidence: "PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.1 retains immutable189-input first-native8 callback outcomes/34 branches/4 authority rows/2 public source rows/2 cold rows. Identical215 TAP has6 original authority REDs/209 controls/all215 current GREEN. Five syntax-valid full-module faults fail6/2/4/3/4. Actual supplied62 suites/191 inputs/11879 assertions book89/three controls and seven actual evidence RED/restorations pass. Supplemental standard syntax/public Phase0 passes1035 with complete channels and no full transitive input capsule. Original322 predecessor bindings stay historical atc90b99a83. Original consumer wrapper outer1 is distinct from its actual inner PASS; separate path-complete review checks every command/header/plan and predecessor diagnostics. Number/string boundary: PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2 retains immutable193-input native16 callback outcomes/73 branches/8 actual authority rows/4 public source/4 cold rows. Identical436 TAP has12 original authority REDs/424 controls/all436 current GREEN. Five separate syntax-valid source faults for each owner fail6/2/4/3/4 for number and6/2/6/3/4 for string. Supplied63 suites/195 inputs/12315 assertions, seven actual evidence RED/restorations and full book89/three controls pass. Original314 predecessor bindings remain historical at5bf068c92."
reverify:
  - "bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2-publish-claim.py"
  - "Earlier array proof requires accepted5bf068c92 Git inputs. Current original-publication replay supplies its exact logical inputs. Capture/freezer/fault/evidence writers are one-shot; native/runtime observations are never refreshed."
---

This stable card covers related required receiver callbacks. Earlier array proof
uses its accepted5bf068c92 input boundary; number/string proof and consolidation
have their separately retained instruments and limits.

## Array receiver callbacks

The legacy array receiver normalizer eagerly requires trim and method parsing.
It validates both before its first trim or input guard. Missing/non-CODE roles
retain the required-dependency diagnostic. Parser replacement during trim cannot
change the actual parser already selected for this invocation.

The normalizer now binds only its required resolver return. Each selected child
has a separate private capture, keeping opaque publication from the enclosing
normalizer and retaining known-child authority by actual callback reference.
Public dependency maps, scalar context, effects, successful error state and fatal
object identity stay native. Cold require-only calls leave SourceEmissions unloaded.

The splitter passes actual `substr` arguments to trim, alongside local scalar
copies. A controlled trim callback returns its incoming text and then appends `!`
through the argument. Mutation of the receiver substring shifts the later call
argument to `.sorted()`, which the parser declines. The caller's original
`items.sorted()` remains unchanged. All observed argument flags are clear, so
flags alone do not distinguish these aliases from copied scalar arguments.
The syntax-valid copied-argument fault loses the native effect and fails the
whole callback ledger and authored result, as well as known-callback identity.

The native/current comparison retains all ordinary callback/branch observations.
Only the four missing/non-CODE diagnostic locations are normalized in shallow
comparison copies; their exact diagnostic stems and original source line remain
checked, while complete raw channels retain the original supplied paths.
Source, method, arity, terminal-family, nested/quoted/decimal splitter guards and
optional kind non-invocation keep their native outcomes. Optional/direct capture
stays with `.3.2`; other required families and full helper/AST/language/private
pipeline admissions retain their separate owners.

The consumer capture's original postcondition expected bare `t/*.t` lines. Actual
prove headers carry progress dots, and one accepted suite lives under
`docs/checkpoints/`. Its retained command succeeded with all62 suites; the
wrapper then refused. The separate readonly reviewer checks all62 ordered
command paths, headers and complete plans, the success summary and byte-exact
predecessor diagnostic stream. It does not rerun or refresh the original result.

Producers, exact runtime inputs, whole mutant sources and distinct channels are
retained under `docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.1-`.

The first evidence writer stopped at an inverse artifact-hash guard before its
intended semantic denial. Its original source and observed outer1 transcription
are retained; reached inner channels were not saved and are unavailable. The
corrected fresh seven-control recurrence retains those actual channels before
assertions, reproduces the hash-only denial separately, and tests the semantic
reason beyond its updated immediate binding. This does not reconstruct lost
original channels or refresh any native/runtime observation.

Canonical fixture selection remains an explicit integration prerequisite. Adding
this focused test does not automatically register it in canonical CI; the
canonical contract is owned by
`docs/knowledge/perl-receiver-copy-canonical-selection.md`. Complete focused
private-fixture registration is scheduled under
`PERL-PRIVATE-FACTORY-CAPTURE.7`, before pipeline activation `.6`. This card's
source-bound focused proof makes no independent canonical-coverage claim.

## Number and string receiver callbacks

Both normalizers eagerly require trim and method parsing before their input
guards. The two resolver returns now bind each selected actual callback to a
separate private capture. Opaque callbacks cannot donate equal-text publication
to the enclosing owner; actual known callbacks retain their eligibility.
Public maps, ordinary values, contexts, successful error states, fatal-object
identity and require-only lazy loading stay native. Optional/direct capture and
other private families retain separate owners.

Trim receives local scalar copies and actual substring arguments from the shared
splitter. Returning the incoming text and then appending `!` through the argument
changes the later split and declines normalization, while the caller's original
`score.abs()` or `raw.trim()` stays intact. Clear readonly flags alone cannot
distinguish these actual aliases from copied arguments.

The string owner annotates the actual parser-returned hash with `__source_expr`.
A controlled parser that recognizes `trim()` and then appends `!` through its
argument returns the same call object annotated with `trim()!`. Copying arguments
loses this native effect. A controlled parser returning one shared call hash for
`raw.trim().lowercase()` leaves both retained references pointing at that hash,
with its final `lowercase()` annotation and actual `trim(trim(raw))` result.
The number owner also preserves shared returned references and native results.
These are injection controls, not new DSL methods or public runtime admission.

Parser selection precedes trim. Replacing the map entry during trim does not
replace the callback already retained. Both owners preserve source/splitter,
method, arity, family-transition and terminal guards. Missing/non-CODE dependency
comparisons normalize only supplied-root diagnostic locations in shallow copies;
exact diagnostic stems and original source lines7521/7604 stay checked, and raw
channels retain their complete locations.

The first independent reviewer used an overbroad `-missing-` label match, which
also selected `parser-missing-args` with no error. It exited1 before a review
report existed. A prematurely started dependent evidence writer then exited1 at
that absent report, before copying inputs or writing results. The exact draft
reviewer and explicit observed-boundary transcriptions remain in
`PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2-review-draft.py` and `-review-correction.json`
under `docs/checkpoints/`. Anchoring the selector to actual required-role labels
repairs only reconstruction; no native/runtime instrument or observation changed.
Neither failed attempt is claimed as a partial success.

The current consumer producer checks every ordered actual command path/header,
all63 complete TAP plans and the success summary, including the accepted suite
under `docs/checkpoints/`. Its diagnostic stream exactly matches the predecessor.
The predecessor's refused t-only census remains historical, without refresh.

Seven actual evidence corruptions reject and exact restoration passes. Separate
controls distinguish artifact-hash failure from a missing semantic reason beyond
the updated immediate inverse binding, and checkpoint omission beyond the updated
immediate consumer-review binding. Full healthy/RED/restored channels, changed
bytes and exact supplied populations are retained before each assertion.

Complete producers, supplied input identities, full mutant sources and channels
are retained under `docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2-`.
Supplemental standard checks pass both Perl syntax commands and public Phase0
with1035 assertions, retaining complete channels. This additional live-worktree
compatibility record has no full transitive input capsule, benchmark or broader
private/canonical admission.
Canonical focused-fixture registration stays scheduled under `.7`, before pipeline
activation `.6`; this proof establishes no independent canonical coverage.
