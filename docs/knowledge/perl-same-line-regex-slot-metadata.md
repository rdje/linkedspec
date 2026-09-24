---
id: perl-same-line-regex-slot-metadata
title: Perl preserves regex-slot identity across same-line lifecycle members
answers:
  - why is a named regex slot unknown after an I block on the same line
  - why does a named regex slot before E disappear from selector resolution
  - why does an anonymous regex after I report slot index out of range
  - which repair owns Perl same-line regex slot metadata
date: 2026-09-24
status: .86.5.3 verified; .86.3 canonical receipt governs parent closeout
tags: [perl, validation, regex-slots, metadata, source, lifecycle]
evidence: "At fb955602e and clean4ca4f745e, the five-case public checkpoint retains the separate-line control but loses three same-line named declarations and one anonymous declaration. The final metadata consumer completes111 baseline groups and fails only added group4. Candidate focused11files240 and six exact Markdown examples103 pass; slot observation uses the depth-aware structural scan, and permanent/bootstrap declarations accept adjacent members. Bare lifecycle payloads remain shielded in the permanent grammar."
reverify: "bash tools/project_data_run.sh env PERL5LIB= prove -Iperl t/inter_match_gap_capture_perl_contract.t t/generated_source_contract.t t/standalone_lifecycle_block_self_hosted_contract.t; bash tools/run_primary_cli_matrix.sh --manifest docs/checkpoints/SESSION-STARTUP-READING.86.5.3-cli.json"
---

At the baseline, `Validation::_validate_inter_match_gap_authored_metadata` accepts a named
slot only when its regex matches the entire physical fragment. Anonymous slots
come only from `_extract_leading_regex_literals_from_fragment`. The subsequent
edge scan tracks braces and selectors but does not revisit declarations after
lifecycle content. Therefore later regex members do not enter the slot list
used by selector resolution. Named declarations with a following E block also
miss the whole-fragment match.

The baseline also exposes both parser grammar paths:
`BootstrapSpec::Core::_build_named_re_pattern_rule` and `regex_slot_declaration` in
`specs/spec.spec` anchor a declaration to a whole physical line. The permanent
self-hosted grammar remains the authority; the hardcoded parser is its bridge.
Removing only the validation rejection would not establish parsed `RE_SLOT`
identity. These are source-level repair requirements; the five-case public
intake above stopped at validation and did not prove later execution.

The expanded matrix also checks bare lifecycle blocks. Public Perl
correctly treats `{fake=/x/}first=/a/` as code followed by a named slot, but the
permanent grammar's whole-line `standalone_lifecycle_block` production misses
that block. Its payload becomes a false `fake` slot after declaration matching
is relaxed. ADR0094 already admits same-line bare blocks; `.86.5.3` therefore shields
their complete payload before accepting the declaration repair. The explicit-I
twins and the primary/bootstrap slot identities pass. This required grammar
repair does not change lifecycle execution `.27` or the other independently
owned self-hosted grammar gaps.

The formal paragraph grammar allows body members on the same line; ADR0045 and
the governed gap contract define a named declaration as one same-line
`REGEX_SLOT_NAME HSPACE* = HSPACE* REGEX` member outside code. This observation
identifies a Perl implementation gap, not a new slot syntax or a cross-backend
claim. `.86.5.3` completes the required slot repair after verified slash repair
`.86.5.2.2`; exact canonical parent `.86.3` remains next. Keep lifecycle execution `.27` and bootstrap
regex-brace handling `.54.1` independent.

The standalone named-declaration control was the verified workaround. Matching
only an I assignment's numeric result can hide this failure; explicit slot
selection and descriptor identity expose it without relying on the known
no-edge lifecycle value leak.

## Repair and bounded verification

The existing depth-aware edge scan optionally reports named and anonymous regex
members at depth zero. Quotes, parentheses and code braces keep their existing
structural handling. A rule-level comment disables slot observation for that
line without changing the independent comment-depth scanner. One shared token
helper excludes structural delimiters from a name; the established whole-line
invalid-name route still preserves its typed diagnostics. The same helper checks
named-member remainders, so admitting a declaration cannot silently accept an
unknown tail. Exact Unicode names, duplicate detection, authored order and
named/numeric selector provenance retain their existing contract.

The permanent grammar and BootstrapSpec bridge no longer require a named member
to occupy the whole line. The permanent bare-lifecycle rule also accepts its
complete balanced block at the current cursor, including header rest. It keeps
the line-start alternative for standalone lines and does not search arbitrarily
inside unknown members. All four corpus copies exactly mirror `specs/spec.spec`.
No shared runtime format, dependency implementation or submodule pin changes.

Fourteen body layouts run under LF/CRLF and named/numeric selectors. They check
public descriptors, exact source, live/generated values and mismatches, permanent
grammar slot nodes and complete bare payloads. Three normalization-sensitive
Unicode names, five typed negatives, authored-validation callbacks and two
unsupported tails are covered. Focused checks pass 240 tests across 11 files; the
six exact book sources pass 103 assertions, including the new second-slot selection.
Clean4ca4f745e runs 111 metadata groups and fails only new group4. The gap/slot/bare
neutral checks and exact Unicode/mirror checks pass. LuaJIT passes all six CLI
grammar cases under default and POSIX environments. Full Phase0 passes 1033/1033
in 2099 wallclock seconds /1181.98 CPU seconds at frozen diff
`a80c914626100ac1fbe7c7448a42547574d7adfbc7ec0de8da4aadef88394a32`.
The six cases pass on all six runtimes in both environments, for
72 grammar case legs composed from retained Perl/Rust legs and fresh other-runtime
legs; the two stopped whole-driver attempts remain failed. All120 final checkpoint records remain exact after the last
bare-block shield, including the original five permanent/bootstrap AST controls.
This grammar recurrence does not imply broad native runtime or self-hosting parity.

The first native matrix exposed a separate pre-existing final-E projection
difference. Current and clean-baseline Rust both select the complete-line
lifecycle production at a nonzero suffix boundary, adding `source_form:
explicit`. [[rust-regex-input-context-drift]] and startup `.63.1` now retain the
exact permanent CLI regression. The common slot fixture places E between named
members and still compares the entire AST; it does not remove or normalize the
extra field. The original failed run remains evidence, and general self-hosted
projection parity remains outside this slot repair.

Dart needed the corresponding exact shipped-pattern bridge update; see
[[dart-structural-pcre-parser-smoke-parity]]. Its current-grammar AST tests cover
native, reconstructed and generated-plan execution. Focused20 and independent
package502/storage25owners47packages/CLI66x2/corpus105 pass; known complete-gate
formatter/SDK blockers remain separately owned and unsuppressed.

Canonical parent `.86.3` reconciles the committed scoped proofs and unchanged
executable book fences. A fresh56-case Rust public replay passes; all runtime
sources remain unchanged from their verified child commits. The exact staged
canonical receipt is required before parent landing. Independent repair owners
and the known optional Dart component-gate failures remain open.
