# Copied-null index and rejection across copy

Owner: TYPE-REFERENCE-BOOK.1.2.23.3.72.6; assessment72.6.0 and repairs72.6.1-.5.

ADR0138 preserves legitimate null through copy. Existing canonical nullable
index_of evaluates its needle once and returns undef. Earlier incompatible
consumers reject before later copy/needle/default/with work. Null and prior
rejection are distinct states; no general nullable Array policy follows.

```text
{undef}.copy().index_of(needle)          # undef; needle runs once
copy({undef}).index_of(needle)           # same
index_of(copy({undef}),needle)           # same
{undef}.copy().copy().index_of(needle)   # same
index_of(["a"],"a").take(1).copy().index_of(needle) # undef; needle skipped
["a"].copy().index_of("a")               # numeric0
[undef,""].copy().index_of("")          # numeric1; null differs from empty
```

Shared12: tests/fixtures/copied_null_index_cases.json. The original selection33
rejected-copy control is unchanged; two original null-policy diagnostics are
also observed unchanged, with separate explicit expected outcomes. Source and
needle are evaluated once in order; needed errors propagate. Snapshot/null-with/
numeric-null/repeated-copy/wrong-kind/Array controls distinguish the obligations.
Preserve equality, copy depth, malformed signatures and excluded context roles.
Independently baseline each backend normal before production edits.

## Actual independent assessment

Assessment72.6.0 freezes twelve copied-null index value/effect/error/rejection controls plus two unchanged selection33 null-source diagnostics; original rejected-copy source is also unchanged. Independent Perl native/fresh observations retain ten healthy groups and expose four rejection-copy failures: copied-null ABC is correct but rejected D also runs; rejected copy chains revive later needle/body/default work with and without with. Get/descriptor/substitution/full emission show generic copy folding nests the rejected prefix before outer nullable index dispatch; guarded_copy_chain currently covers presence/membership, excluding index. All fourteen Perl cases ready1/raw0/fallback0/unresolved0, freshly loaded/executed and warning-free; native needed errors are read from runtime_ctx_ref.last_error. Independent Rust/Dart native/restored/plan and Julia/installed PUC5.5.1/LuaJIT2.1.1788460057 native/restored/plan/fresh routes retain seven healthy groups and expose seven failing copied-null groups, including the unchanged copied-null diagnostic. Receiver copy skips needle A versus free-copy/free-index BC; repeated/numeric-null/with-null copies suppress needed effects and binding_kind_mismatch. Healthy peers preserve both rejection forms/original default bridge, wrong kinds, Array snapshots/index0-null identity and direct/free/selected null FRS. Public four-shape projections and exact source owners locate leading-only nullable index dispatch; Dart/Julia/Lua scalar guards also need method-specific nullable qualification. Freeze canonical one-needle nullable index dispatch and explicit rejection state across copy, retaining index0/null/no-match/null-empty/equality/copy depth/source snapshots/excluded context roles. P1 Perl72.6.1 then independent Rust.2/Dart.3/Julia.4/safe Lua.5 repairs precede unrelated selection. All six observer transports exit0; value/error comparisons establish the gaps. Actual Cargo-consumed example is bound before/after first run, retained before exact removal. Declared authority/source/instrument/generation input identities remain exact; complete transitive generation closure remains23.4.2. One pre-runtime template conversion missed a syntax projection token; validation rejected it, original failed producer/probe bytes are retained, and a continuation corrected only that projection without replay. It is not product RED. Generic route captions retain their presence origin; actual fourteen index payloads are explicit. Actual producers/templates/inputs/raw channels/diagnosis/setup qualification retained in copied-null-index-assessment-intake.json.gz. Shared12/target/book/card/map/task/roadmap/live/resume/history align; production unchanged. General SESSION17 isolation/full23.4/pressure/registration/task-evidence/declared-host admission remain separate; no full suite or push.

## Bounded Perl72.6.1 repair

Perl72.6.1 retains canonical index rejection across copy. Unchanged fourteen native/fresh groups10PASS4RED become14PASS: shared12 plus two source-exact original null diagnostics. Four rejected-copy groups no longer run later needles/default/body work; nine healthy value observations and the needed binding_kind_mismatch error stay exact. All thirteen value groups ready1/raw0/fallback0/unresolved0/warning-free/cursor0. Existing canonical index role now joins guarded_copy_chain with presence/membership; logical producer folding keeps its existing route. Reuse the rejection flag with or without with and permit legitimate null index needles within retained copy state. No null-is-rejection or generic nullable Array shortcut. Three input-bound public substitutions show rejected take setting state before copy and legitimate numeric null retaining needle dispatch. Producer/equality/index0-null/null-empty/source snapshots/copy depth/arity/preflight/excluded traversal/deferred/function/schema stay. Nearest index19/contains-copy11/value-copy23=53, eighteen original source fences before/after and owner/normal syntax pass. Five actual runtime fixture edges/two inline diagnostics/inline copy programs/per-phase declared identities and105 other activation inputs stay exact; complete transitive generation closure remains23.4.2. Actual sources/instruments/templates/commands/raw phases/deltas/inputs retained in copied-null-index-perl-intake.json.gz. Book/card/map/target/task/roadmap/live/resume/history align; new normal14/shared12 canonical registration remains23.4.1-owned. Regenerate emitted Perl. Independent Rust72.6.2 then Dart/Julia/safe Lua nullable index repairs next. General isolation/full23.4/pressure/task-evidence/declared-host admission remain separate; no full suite or push.
