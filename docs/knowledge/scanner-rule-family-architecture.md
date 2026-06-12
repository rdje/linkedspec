---
id: scanner-rule-family-architecture
title: Scanner rule families are deliberately split into PrimitiveBasicRules, PrimitivePipelineRules, FlowRules, and LegacyRules by complexity and lifecycle
answers:
  - "how are scanner rules organized in linkedspec"
  - "what is the difference between PrimitiveBasicRules and LegacyRules"
  - "where do new scanner rules go"
  - "what is the scanner rule family split"
date: 2026-06-12
status: current
tags: [architecture, scanner, actionir, lowering]
evidence: "perl/LinkedSpec/ActionIR/Scanner/ contains 6 files; ScannerCore dispatches to all 4 rule families via a central registry"
reverify: "ls perl/LinkedSpec/ActionIR/Scanner/*.pm"
---

The ActionIR scanner (which finds helper-like and compatibility-like surfaces in `.spec` action
code) splits its rules across four families by complexity and lifecycle:

- **PrimitiveBasicRules** — foundational helpers: `push`, `push_single_arg`, `push_indexed_arg`, etc.
- **PrimitivePipelineRules** — pipeline-oriented: `return_imatch`, `push_value`, `push_nonempty`, `split_array`, `split_each`, `trim_each`, `filter_nonempty`, etc.
- **FlowRules** — control-flow: `if`, `elseif`, `else`, `endif`, `switch`, `case`, `default`, `endswitch`, etc.
- **LegacyRules** — compatibility-surface helpers: `return_a`, `return_m`, `return_ma`, `return_general`, `return`, `capture_macro`, `capture_if`, etc.

`ScannerCore` owns the family registry and dependency contract. New scanner rules should be added
to the family that matches their lifecycle (primitive → pipeline → flow → legacy). LegacyRules
is specifically for compatibility-surface patterns that are tracked for eventual removal.

Related: [[actionir-lowering-stack]].
