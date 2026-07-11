---
id: perl-outward-descriptor-model-tag-drift
title: Perl outward descriptor metadata names the nested spec state instead of its composing descriptor state
answers:
  - "why does Perl descriptor_model differ from Dart and Julia"
  - "what does Perl return_descriptor report for descriptor_model"
  - "is Perl's internal descriptor owner actually compiled_descriptor_state"
  - "which leaf reconciles outward descriptor model identity"
  - "why is Rust descriptor projection split before implementation"
date: 2026-07-11
status: resolved
tags: [descriptor, compiler-state, perl, rust, dart, julia, parity, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.1.6.2.0. A LinkedSpec::Get(..., return_descriptor=>1) toolbox probe returns top-level spec/functions/dependency_regex_map/meta and meta.descriptor_model=compiled_spec_state_v1. perl/LinkedSpec/CompilerState.pm build_compiled_descriptor_meta delegates to compiled_spec_state_meta, which stamps that value, even though new_compiled_descriptor_state constructs kind=compiled_descriptor_state and owns final projection. The mdBook, Dart, and Julia expose compiled_descriptor_state. Phase 0 lines 12105 and 43795 explicitly lock the stale Perl value."
evidence_update_2026_07_11: "FUTURE-PARITY-BACKLOG.1.6.2.1 changes Perl outward descriptor_model to compiled_descriptor_state and adds compiled_spec_model=compiled_spec_state plus compiled_dependency_regex_model=compiled_dependency_regex_state. The focused four-key probe and Phase 0 1..1030 pass in 509 seconds."
reverify: "perl -Iperl -MLinkedSpec -e 'my $s=qq{Top::\\n /x/\\n}; my $d=LinkedSpec::Get(\\$s, return_descriptor=>1); print $d->{meta}{descriptor_model}, qq{\\n}' && rg -n 'descriptor_model|new_compiled_descriptor_state' perl/LinkedSpec/CompilerState.pm dart/lib/src/compiler/compiled_spec.dart julia/src/compiler/CompiledSpec.jl t/phase0_regression.t docs/linkedspec-book/src/public-api/descriptor-introspection.md"
---

# Perl Outward Descriptor Model-Tag Drift

The Perl compiler correctly builds a `compiled_descriptor_state` that composes compiled-spec and dependency-regex
state before public projection. Its outward metadata is assembled from `compiled_spec_state_meta(...)`, however,
and that helper stamps `descriptor_model = compiled_spec_state_v1`. The value therefore names one nested component,
not the owner that is actually being projected.

The mdBook and existing Dart/Julia APIs use `compiled_descriptor_state`, which matches the public field's meaning.
`.1.6.2.1` reconciled Perl to that identity and added explicit names for both nested models. Rust projection
`.1.6.2.2` can therefore implement one singular contract rather than choosing between divergent precedents.
