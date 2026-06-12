---
id: compilerstate-internal-model
title: CompilerState owns the internal compiled-spec, dependency-regex, and descriptor state records; Compiler.pm and Validation.pm no longer carry raw state logic
answers:
  - "where is compiled-spec state defined"
  - "what is CompilerState and why was it extracted"
  - "how does descriptor assembly work"
  - "where does migration-summary shaping live"
  - "what owns compiled_rule_order and redefined_rule_labels"
date: 2026-06-12
status: current
tags: [architecture, compiler, compilerstate, state-model]
evidence: "perl/LinkedSpec/CompilerState.pm extracted from Compiler.pm; ARCHITECTURE_STATE.md §What the Main Owners Do documents the extraction"
reverify: "test -f perl/LinkedSpec/CompilerState.pm && grep -l CompilerState perl/LinkedSpec/Compiler.pm perl/LinkedSpec/Validation.pm"
---

`LinkedSpec::CompilerState` owns the explicit internal state model behind the compiler's
descriptor output. Before its extraction, `Compiler.pm` and `Validation.pm` carried duplicated
state-shaping logic over loose `spec`/`dependency_regex_map` hashes.

The three state records:
- **compiled_spec_state** — `definition_order`, `compiled_rule_order`, `rules_by_label`, `redefined_rule_labels`
- **compiled_dependency_regex_state** — derived dependency-regex by-label map (formerly `gdata_by_label`)
- **compiled_descriptor_state** — composes spec state + dependency-regex state; feeds validation

CompilerState also owns:
- Normalization of legacy compatibility hashes into explicit state records
- Read-side accessors (definition-order, duplicate-label, rule-map reads)
- Ordered compiled-rule iteration (`rule_rows` view)
- Descriptor metadata assembly over compiled-spec state
- Migration-summary shaping (action_rewriter_migration)
- Validation-friendly shape checks
- Projection back to outward `spec`/`dependency_regex_map` hashes

The extraction means `Compiler.pm` no longer hand-mutates owner metadata or computes migration
summaries as local reductions. `Validation.pm` no longer flattens descriptor state for inspection
or performs repeated owner dispatch inside validation loops.

Related: [[runtimecontext-boundary]], [[ownerdispatch-shared-seam]].
