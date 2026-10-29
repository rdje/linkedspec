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
