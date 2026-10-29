# Local-match mark writer endpoint presence

Owner: TYPE-REFERENCE-BOOK.1.2.23.3.49.0; independent backend children49.1-.5.

This target composes linkedspec-complete-named-mark-v1's current-local-match
snapshot, ADR0056's source/position validity and existing mark update timing,
named42's ordered String word-name statement effects and47's explicit distinction
between local-match absence and a real empty match. It adds no helper, alias,
domain, frame/state/schema or public diagnostic policy.

- mark_match_start(name) and mark_match_end(name) snapshot existing current local
  match edges. Without that endpoint they perform no write and no implicit delete.
  Existing targets survive; a fresh target stays absent. Only explicit clear or
  existing mark-copy missing-source policy deletes a mark.
- Accepted names evaluate once before endpoint qualification. Their own authored
  effects remain, including writes to the eventual target. The unavailable writer
  adds no further effect; it must not manufacture0, use the live cursor or store
  an invalid position. Do not weaken the recognition-frame mark validator.
- Real empty matches and text0 are present. Empty at0 writes defined0; empty after
  a Unicode prefix writes its true edge. Local start/end remain independent of a
  later live-cursor movement, capture boundary, incoming entry match and package
  globals. Existing scope/name/domain/arity/function ownership is unchanged.
- Input/current/capture/entry writers keep their own endpoints. In particular,
  documented Perl root entry coordinates remain valid at rule-entry cursor even
  without entry-match text. mark_entry_start uses IPOS minus the defined-or-empty
  entry width; mark_entry_end uses IPOS. This legacy boundary behavior must not be
  replaced by an inferred universal absent-entry no-op. See the entry-boundary
  book section and perl-absent-entry-boundary-warnings canonical fact.

tests/fixtures/named_writer_endpoint_absence.json freezes15 sources: blind/regex I,
cursor/capture moves before local matching, incoming child I, Unicode prefix,
empty at0/after prefix, text0, local edge versus moved live cursor, available writer
independence and four effectful-name absent/present writer cases. Fresh and seeded
marks distinguish no-op from deletion and from invalid/fabricated writes. The
original47.0 writer discovery is retained verbatim in the normative target now
that its existing local-match behavior is qualified; read/take47 remains separate.

Current Perl native/separate emitted clean+seeded has7healthy8RED. Actual values,
structured errors, cleanup/uninitialized warnings and full public metadata remain
retained; do not classify a typed error as null or suppress the validating guard.
Current Dart native/restored/plan/separate VM passes15, including preexisting mark
preservation and name effects, providing a distinguishing no-op/clear control.
No Rust/Julia/Lua failure or compatibility is inferred; each child independently
assesses current sources and public owners before edits.

Public substitution of10 writer bodies shows Perl local writers using unguarded
LSPOS/LMATCH arithmetic/storage, while entry fallback is already qualified.49.1
owns the actual missing-local repair and emitted source compatibility/regeneration
proof; other writer and named read/take contracts stay intact. Canonical selection
23.4.1/full23.4 and49/48/45/prerequisites remain before push. No production change
or policy/version bump occurs in this qualification slice.

Packet named-writer-absence-authority-intake.json.gz retains actual producers,
candidate/frozen inputs/source/public bodies/modules/results/errors/warnings/
metadata/traces and existing entry-authority records. Accepted reader is self-
contained; initial comparator reuse replayed old recorded data only and is retained
as instrument history, not new product or endpoint failure credit.

## Perl repair49.1 (2026-10-29)

Only mark_match_start/end now require defined LMATCH/LSPOS before their original
storage/trace body. Names already finish outside that body; no missing-endpoint
write/delete/trace is added, and existing targets/name effects survive. Other8
public writer bodies, including valid root entry/IPOS fallback, remain exact.
No new state/frame/helper/domain/schema or validator weakening. Current15 native/
separate clean+seeded7healthy8RED ->15pass; ordinary15 groups8RED ->15pass. Writer15/
name-write17/complete marks2 pass34 groups and Contracts syntax. Seven healthy
full semantic records and all metadata unchanged. All15 emitted payloads change;
original15 modules replay30 calls with original outcomes/errors/warnings and v2
accepted: regenerate affected emitted parsers. Warning eval ordinals normalize;
raw host error text excluded only with typed fields, full raw channels retained.
Packet perl-writer-absence-intake.json.gz retains closure. New normal canonical
selection23.4.1/independent49.2-.5/48/45/full admission remain separate.

## Rust repair49.2 (2026-10-29)

mark_match_start/end now require existing match_present after name resolution;
two guards prevent default numeric registers from fabricating/replacing targets.
Names already evaluate, current typed mark owner/state/frame/schema/domain/arity
remain. Independent15 SDK/reconstructed/plan/separate emitted7healthy8RED ->15pass;
ordinary1 harness24 bad routes ->pass. Writer1/named read-take1/complete marks1
tests pass3; engine/new normal/temp format clean. Seven healthy observations and
all source/parsed/compiled/serde/plan/emitted/public metadata exact. Same15 baseline
modules relink with updated runtime, rebuild apps/no source regeneration. Native/
fresh lock identities match; dependency diagnostics opaque. Temporary producer
exactly verified/snapshotted/removed, normal no allocator. Packet
rust-writer-endpoint-intake.json.gz retains closure. Independent49.3-.5/48/45,
selection23.4.1/full admission remain separate.

## Dart compatibility49.3 (2026-10-29)

Current15 native/restored/plan/separate VM allpass. Existing markName evaluation
and nullable localMatch start/end guard already preserve fresh/seeded/name-effect
targets without extra writes; valid empty/zero/Unicode and local/live cursor remain.
No runtime change. Exact source/normalized/compiled/plan/emitted/full metadata/
results/traces equal49.0; original15 modules reused. Writer15/named endpoint15/
named Number-function-scope2/complete marks3 pass35 tests, fatal new-file analysis/
format clean. Wrong first-mark oracle fails1case14pass, actual fixture unchanged,
no product RED. Packet dart-writer-endpoint-intake.json.gz retains closure. Ordinary
normal discovered, canonical selection23.4.1/SDK deprecations2.25/independent49.4-.5/
48/45/full admission remain separate. No AOT/full-package/dependency isolation claim.

## Julia compatibility49.4 (2026-10-29)

Current15 native/restored/plan/separate emitted allpass. Existing name evaluation
then nullable local_match guard before typed mark update already preserves fresh/
seeded/name-effect targets and real empty/zero/Unicode/local-live cursor behavior.
No runtime change. Writer105/named endpoint105/named Number-function-scope155/
complete marks13 pass378 assertions with depwarn=error/empty healthy stderr. Wrong
first-mark oracle3fail102pass, fixture/runtime untouched; no product RED. Exact
source/normalized/compiled/plan/emitted/full metadata/results/high traces retained;
runtime/compiler/emitter/fixture match activation HEAD, no regeneration. Packet
julia-writer-endpoint-intake.json.gz retains closure. Normal runtests include
verified; selection23.4.1/safe Lua49.5/48/45/full admission remain separate. Same
project/depot, no isolated dependency or full package claim.

## Safe Lua compatibility49.5 (2026-10-29)

Installed PUC5.5/LuaJIT2.1.1788460057 independently pass all15 native/restored/plan/
separate emitted cases. Existing name evaluation then nullable local_match guard
before validated write_mark already preserves fresh/seeded/name-effect targets
and real empty/zero/Unicode/local-live cursor behavior. No runtime edit. Writer105/
named endpoint105/named Number-function-scope219 pass429 checks per host, empty
healthy stderr/syntax loads. Wrong first-mark oracle3fail102pass per host, actual
fixture/runtime unchanged, no product RED. Full source/normalized/compiled/plan/
emitted/metadata/results/debug traces retained, runtime/emitter/fixture match HEAD,
no regeneration. Packet lua-writer-endpoint-intake.json.gz retains closure. Normal
run.lua registration verified; exact selection23.4.1/declared5.4/unsafe formatter/
phase/full admission remain separate. Bounded49.0-.5 focused work complete on
recorded routes/hosts; parent admission open,48/45 precede wider features/push.
