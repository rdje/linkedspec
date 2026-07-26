---
id: julia-nullable-match-state-preserves-absence
title: "Julia projects absent local matches from nullable register state"
answers:
  - "how does Julia distinguish no local match from a zero width match at offset zero"
  - "what do Julia match position helpers return without a local match"
  - "why do Julia match line and column helpers return one without a local match"
  - "why are Julia entry_has and match_has numeric one or zero"
date: 2026-07-10
status: confirmed
tags: [julia, runtime, match-state, positions, zero-width, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.1.2.2.2.3. Julia stores entry/local registers as Union{Nothing,RuntimeRegexMatch}, so absence is already distinct from a present zero-width match at offset zero. Helper projection maps absence to null capture/length/start/end values, empty group/map containers, numeric match_has=0, and 1-based line/column defaults. Entry/local named-presence helpers return numeric 1/0. A zero-width regression proves a present match at offset zero still returns empty capture text, length/start/end 0, and match_has=1. The governed exact position fixture, 1,022 package assertions, both 61-case CLI environments, and unchanged 99-case corpus pass."
reverify: "JULIA_DEPOT_PATH=\"${TMPDIR:-/tmp}/linkedspec-julia-depot:$(julia --startup-file=no --history-file=no -e 'print(join(Base.DEPOT_PATH, \":\"))')\" julia --project=julia --startup-file=no --history-file=no -e 'import Pkg; Pkg.test()'"
---

# Julia Match Absence Uses Register Nullability

The nullable match register answers whether a match exists; offsets answer where a present match exists. Julia
therefore keeps `Union{Nothing,RuntimeRegexMatch}` as the state boundary and projects each helper according to the
LinkedSpec contract. Code must not infer presence from a zero span or empty captures.

## Links

- Owner: [[FUTURE-PARITY-BACKLOG]] `.1.6.1.2.2.2.3`.
- Governed source: `capability_conformance/fixtures/capability_position_helper_surface.spec`.
