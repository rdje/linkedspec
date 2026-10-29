---
id: dart-blind-target-regex-validation-gap
title: Dart blind-target validation wrongly requires a target regex slot
answers:
  - "why does Dart reject a blind call to a rule with no regex"
  - "why does Dart bare AND require a child regex slot zero"
  - "which Dart validator conflates blind rule existence and action regex identity"
  - "which task owns Dart no-regex intermediate blind-target repair"
date: 2026-10-29
status: confirmed P1 TYPE48.3;48.0 target frozen, no production/runtime/fresh repair credit
tags: [dart, validator, blind, rule, regex, compiler, defect]
evidence: "referenced-intermediate-authority-intake.json.gz retains final12-source6valid blind compile failures, direct/regex controls, public source/validator snapshots and reference native/fresh ownership proof."
reverify: "Recover probe_referenced_intermediate_compile.dart and candidate12 inputs under TYPE48; run via tools/run_dart_project_data.sh with the Dart project package configuration."
---

_checkEdgeTargets passes BlindEdgeBodyElementKind's declared target to
_checkTarget(...,0), which unconditionally checks regex count. Bare AND targets
take the same erroneous slot-check path. _checkEdgeStructure separately forbids
authored blind indices. A valid blind parser-step reference needs the declared
rule, not a regex slot. Action targets retain real slot selection, and unknown
targets must still reject. CompileSpec validation fails before source generation.

Current12 public compile candidates: Perl accepts all8 valid forms and rejects4
action-to-missing-slot forms. Dart accepts direct-call and regex-action controls
but rejects6 valid blind variants (explicit/default/AND/bare-AND/marked/markerless,
including the otherwise identical historical => twin). No runtime/fresh/peer
failure or completed repair inferred. P1 TYPE48.3 owns focused normal RED/repair/
source/diagnostic compatibility before45/wider features/admission.
