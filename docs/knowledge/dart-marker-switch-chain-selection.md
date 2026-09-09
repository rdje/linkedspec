---
id: dart-marker-switch-chain-selection
title: "Dart groups marker switch siblings into one selectable chain"
answers:
  - "how does Dart execute marker form switch case default"
  - "why did Dart run default after a matching marker case"
  - "does Dart support nested marker switches"
  - "what does the Dart control capability fixture return"
date: 2026-07-10
status: confirmed
tags: [dart, runtime, control-flow, switch, markers, nesting, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.1.2.2.3.2. Dart parsed marker-form switch/case/default/endcase/endswitch into typed nodes but did not claim the sibling statement range, so case/default nodes were skipped while every ordinary branch assignment executed. Action and value blocks now select one nesting-aware range: evaluate the subject once, execute only the first matching case or otherwise default, and ignore nested switch boundaries while scanning the outer chain. Existing i/elif normalization is unchanged. The governed fixture returns [\"elif\",\"case-b\"]. Formatting, fatal analysis, all 155 package tests, both 61-case CLI environments, and unchanged 99-case corpus pass."
reverify: "cd dart && bash ../tools/run_dart_project_data.sh test test/runtime_interpreter_test.dart -n 'matches the governed marker-control fixture exactly' && bash ../tools/run_dart_project_data.sh analyze --fatal-infos --fatal-warnings"
---

# Dart Marker Switch Chain Selection

Marker switch is a sibling-statement control structure, not a set of independent calls. The runtime owns the range
from `switch(...)` through its matching `endswitch()`, uses `endcase()` as a branch boundary, and tracks nested
switch depth so inner markers cannot close or select an outer chain.

## Links

- Owner: [[FUTURE-PARITY-BACKLOG]] `.1.6.1.2.2.3.2`.
- Governed source: `capability_conformance/fixtures/capability_control_marker_surface.spec`.

## 2026-09-09 — selected value-range composition limit

Marker grouping itself remains intact in the .1.17 controls, including direct local return
inside a selected case. An attached if nested in that selected value range instead returns
from the surrounding rule. The shared range executor also causes the mixed marker-if
failures in [[dart-mixed-control-value-block-gap]]. Ten native/reconstructed controls own
this separate composition defect under DART-STARTUP-READING.2.9; the historical admission
does not establish mixed attached/marker value-return locality.
