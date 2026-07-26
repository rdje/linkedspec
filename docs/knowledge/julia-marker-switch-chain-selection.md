---
id: julia-marker-switch-chain-selection
title: "Julia groups marker switch siblings into one selectable chain"
answers:
  - "how does Julia execute marker form switch case default"
  - "why did Julia run default after a matching marker case"
  - "does Julia support nested marker switches"
  - "what does the Julia control capability fixture return"
date: 2026-07-10
status: confirmed
tags: [julia, runtime, control-flow, switch, markers, nesting, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.1.2.2.3.3. Julia parsed marker switch siblings into typed nodes but did not claim their statement range, so ordinary branch assignments all executed. Action and value blocks now evaluate the subject once and execute only the first matching case or otherwise default while tracking nested switch depth. Existing i/elif normalization is unchanged. The governed fixture returns [\"elif\",\"case-b\"]. The offline package suite passes 1,023 assertions, both 61-case CLI environments pass, and unchanged corpus passes 99/99."
reverify: "bash tools/run_julia_project_data.sh --project=julia --startup-file=no --history-file=no -e 'import Pkg; Pkg.test()'"
---

# Julia Marker Switch Chain Selection

Marker switch is a sibling-statement control structure. Julia owns the range from `switch(...)` through its
matching `endswitch()`, uses `endcase()` as a branch boundary, and tracks nested switch depth so inner markers
cannot close or select an outer chain.

## Links

- Owner: [[FUTURE-PARITY-BACKLOG]] `.1.6.1.2.2.3.3`.
- Governed source: `capability_conformance/fixtures/capability_control_marker_surface.spec`.
