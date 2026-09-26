---
id: perl-single-numeric-array-constructor
title: Perl array(3) reads an aggregate name instead of a numeric literal
answers:
  - "why does array(3) return an empty array on Perl"
  - "why does sum(array(3)) return zero while sum([3]) returns three"
  - "which task repairs single numeric array constructor literals"
date: 2026-09-26
status: confirmed defect; required repair SESSION-STARTUP-READING.94 after .93 and .92 before .51
tags: [perl, arrays, constructor, numeric, lowering]
evidence: "Explicit clean49678 MethodLowering and91 candidate both return [] for array(3), [3] for [3],0 for sum(array(3)) and3 for sum([3]); public substitution emits return [@3]. Exact source and values: docs/checkpoints/SESSION-STARTUP-READING.94-numeric-constructor.json."
reverify: "Replay the checkpoint sources through LinkedSpec::Get/runtime_ctx_ref and call_spec_handler_subst under tools/project_data_run.sh; inspect values and numeric aggregate-name residue."
---

The single-argument array constructor compatibility arm at the end of
`perl/LinkedSpec/ActionIR/MethodLowering.pm::_lower_method_value_expr` extracts
an aggregate name before lowering its argument. Its legacy word regex accepts
numeric literals as names, yielding `[@3]` for `array(3)`. This is distinct from
`.91`'s numeric reducer source acceptance and fast-path repairs: changing a
reducer cannot repair an already incorrect array value produced by a constructor.

Startup `.94` owns the bounded constructor repair, including primitive and
function-scope twins, current one-identifier retirement, fresh emitted proof,
public book updates and a public-interface audit of neighboring name consumers.
The failing constructor control is retained as intake, not blessed as a reducer
expectation. `[3]` and multi-argument `array(3,1,2)` remain usable controls.
