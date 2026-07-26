---
id: julia-canonical-primary-cli-trace
title: Julia primary trace is canonical and independent of rich native trace
answers:
  - does Julia emit the canonical primary CLI trace protocol
  - how does Julia keep primary and native trace independent
  - how does Julia count UTF-8 bytes in primary trace
  - how does Julia escape canonical trace fields
  - do Julia trace stdout route mirror reset and append match other backends
  - how many shared CLI cases does Julia pass after canonical trace
  - what did FUTURE-PARITY-BACKLOG 1.5.4.2 implement
date: 2026-07-15
status: current
tags: [julia, cli, trace, canonical, utf8, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.5.4.2 adds an adapter-local ADR 0024 recorder; 1,019 package assertions, nine process families, 99/99 corpus, and 61/61 default/POSIX shared cases pass."
evidence_update_2026_07_18_cursor_option_removal: "FUTURE-PARITY-BACKLOG.9.1.6.5 removes the global parse_mode field from the canonical request record. Source/input/top-rule and every routing byte remain stable; shared primary advances to 65/65 in both environments."
reverify: "bash tools/run_julia_local.sh"
---

`run_cli(...)` constructs `_PrimaryCliCanonicalTrace` before request preparation and emits ADR `0024`'s
compile/input/invoke records around native operations. It does not pass that recorder into `parse_spec(...)`,
`compile_spec(...)`, or `runtime_execute(...)`; those APIs retain the separate `LinkedSpecTraceEmitter` and its rich
Julia frontend/compiler/runtime events.

The adapter maps named aliases and optional-minus ASCII integer thresholds independently of host `Int` width,
counts valid Julia UTF-8 text with `ncodeunits`, and percent-escapes user field `codeunits` bytewise. It implements
exact stdout/route/mirror defaults, file reset/append/persistence, event emoji, JSON framing, and traced phase
failures. Trace setup/write failure becomes the stable compilation failure without leaking a host exception.

After `.1.5.4.2`, Julia passes all 61 unchanged primary-command fixtures under default and
`POSIXLY_CORRECT=1` environments. The local gate also passes 1,019 assertions, nine direct process families, and
99/99 corpus. `.1.5.4.3` closes the original recurring warmed four-command integration; Lua `.7.2` extends the
same matrix to five commands, not further Julia trace semantics.

Cursor policy is deliberately absent from the canonical request record. The
primary adapter records the requested top rule; rich native runtime trace below
it records each entered rule's independently derived family policy.

Related facts: [[canonical-primary-cli-trace-protocol]], [[julia-primary-cli-failure-trace-routing]],
[[julia-trace-controls-sinks]], [[julia-global-cli-61-audit]], [[cross-backend-cli-contract-gap]],
[[native-in-memory-backend-contract]], [[primary-cli-four-backend-matrix]],
[[julia-global-cursor-option-removal]].
