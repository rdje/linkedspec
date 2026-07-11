---
id: rust-marker-short-alias-control
title: "Rust executes i and elif as statement-control aliases"
answers:
  - "does Rust support i and elif marker aliases"
  - "why did Rust report unknown helpers i and elif"
  - "does Rust default run after a matching switch case"
  - "what does the Rust control capability fixture return"
date: 2026-07-10
status: confirmed
tags: [rust, runtime, validation, control-flow, aliases, switch, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.1.2.2.3.1. Rust's known ActionIR call registry omitted i/elif and its statement-if gate matched only if/elseif, although the current language surface includes both short aliases. Validation and statement execution now recognize i as if and elif as elseif. The existing StatementSwitchFrame already prevents default after a matching case, so no switch behavior change was needed. The governed fixture returns [\"elif\",\"case-b\"]. Formatting, 137 library tests, 194 integration tests, the unchanged 99-case oracle, three emitter tests, ten trace tests, and both 61-case CLI environments pass."
reverify: "cd rust && cargo test -p linkedspec-runtime --test integration_test future_parity_backlog_1_6_1_2_2_3_1_rust_marker_control_values -- --exact"
---

# Rust Short Marker Aliases

`i(condition)` and `elif(condition)` are statement-control aliases, not ordinary value helpers. They must be known
to validation and claimed by the statement-control gate before generic helper dispatch. Switch selection remains
owned by `StatementSwitchFrame`, whose `branch_taken` state excludes `default` after the first matching case.

## Links

- Owner: [[FUTURE-PARITY-BACKLOG]] `.1.6.1.2.2.3.1`.
- Governed source: `capability_conformance/fixtures/capability_control_marker_surface.spec`.
