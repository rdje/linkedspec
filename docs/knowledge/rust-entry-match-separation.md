---
id: rust-entry-match-separation
title: Rust engine separates entry_* (the dispatcher's match) from match_* (the rule's own match) by emulating Perl's per-handler IMATCH/LMATCH lexicals with save/restore on the shared RuntimeContext
answers:
  - "how does the Rust engine separate entry_* from match_*"
  - "what is the difference between entry_* and match_* in the Rust runtime"
  - "does a child rule's match clobber the parent's match in Rust"
  - "what is the entry match for a dispatched child rule in Rust"
  - "why did entry_text and match_text return the same value in the Rust runtime"
  - "how does the Rust engine emulate Perl IMATCH and LMATCH"
date: 2026-06-16
status: confirmed
tags: [rust, engine, runtime, entry-match, dispatch, RUST-PARITY]
evidence: "RUST-PARITY.5.2 (2026-06-16): rust/linkedspec-runtime/src/engine.rs execute_rule SavedMatchState save/restore + match-set seed. Matches Perl source: SpecEntry::_build_handler_preamble (IMATCH=$$info{match}), HandlerVariantEmitter::_build_lmatch_extraction (LMATCH=$$minfo{match}), MethodLowering.pm:332 (child invoked with parent $minfo as $info). 189/189 tests green (186 baseline + 3 match_5_2_*)."
reverify: "cd rust && cargo test --manifest-path Cargo.toml 2>&1 | grep -E 'test result'; grep -n 'SavedMatchState\\|entry_groups\\|match_groups' linkedspec-runtime/src/engine.rs | head"
---

# Rust Engine: `entry_*` vs `match_*` Separation

**Confirmed 2026-06-16 (RUST-PARITY.5.2).** Fixes the audit's match/entry-unification MAJOR:
before this, every regex match set `entry_groups`/`entry_named` **and**
`match_groups`/`match_named` to the same groups (one `ctx.set` site), so `entry_*` and
`match_*` could never diverge and a dispatched child clobbered the parent's match.

## The two match registers (the Perl contract)

- **Entry match** (`entry_*` helpers) = the match that **brought the rule into context** — the
  dispatcher's local match, passed in as `$info`. Perl: `_build_handler_preamble` sets
  `IMATCH = $$info{match}`, and a parent invokes a child handler with **its own** `$minfo`
  (`ActionIR/MethodLowering.pm:332`). For the top rule there is no dispatcher, so the
  framework's own match is `$info`.
- **Local match** (`match_*` helpers) = the rule's **own** regex match. Perl:
  `HandlerVariantEmitter::_build_lmatch_extraction` sets `LMATCH = $$minfo{match}`.

In Perl these are per-handler `my` lexicals, so a child's matching can never mutate the
parent's registers.

## How Rust emulates it

The Rust runtime shares **one** `RuntimeContext` across the whole parse, so `execute_rule`
emulates Perl's lexical scoping with explicit save/restore (the same pattern as the `.5.1`
`return_value` channel):

1. On entry, `SavedMatchState` saves the caller's `entry_*`/`match_*`; the new invocation's
   **entry** match is set to the **caller's local match** (`$info = $minfo`). Its **local**
   match starts empty.
2. On each own regex match, only `match_*` is updated. The entry match is left alone **unless
   it is still empty** (the top-rule / dispatcher-less case), where the rule's first own match
   seeds it — mirroring the framework passing the top rule's own match as `$info`.
3. On exit (both the blind-call early return and the normal return), `SavedMatchState.restore`
   puts the caller's registers back, so a child's matching is transparent to the parent.

## Consequence

A dispatched child's `entry_*` reads the **parent's** match while its `match_*` reads its
**own** — they diverge in nested contexts. The parent's `match_*` after a child dispatch still
reads the parent's own match. (See the `match_5_2_*` integration tests.)

## Out of scope here

Group **indexing** is unchanged (`entry_group(0)` reads `entry_groups[0]` = full match in
Rust). The Perl `match_group(0)` = *first capture* indexing difference is a separate parity
item, not part of `.5.2`.

## Links

- Task tree: [[RUST-PARITY]] (leaf `.5.2`)
- Related: [[rust-retv-propagation]], [[rust-edge-semantics-bug]], [[runtimecontext-boundary]]
- Files: `rust/linkedspec-runtime/src/engine.rs`
- Contract: `docs/linkedspec-book/src/dsl/capture-marks-and-source-locations.md`,
  `docs/linkedspec-book/src/dsl/source-boundary-helper-reference.md`
