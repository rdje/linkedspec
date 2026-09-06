---
id: terse-source-migration-runtime-boundaries
title: "SPEC-FORMAT-TERSE.15.2.4 source migration required several runtime/lowering boundaries to preserve output"
answers:
  - "why did source migration from colon scalar slots require runtime fixes"
  - "why does split_tagged_records not use optional scope normalization"
  - "why normalize parser AST assign back to set"
  - "why can descriptor scalar bare reads coexist with same-name arrays"
  - "why must action-edge call child returns publish after the block"
  - "is array(retv) a one element scalar array constructor"
date: 2026-07-06
status: current
tags: [spec-format-terse, scalar-slot, bare-read, actionir, rust, oracle, source-migration]
evidence: "SPEC-FORMAT-TERSE.15.2.4 migrated shipped specs, root corpus inputs, generated Rust oracle inputs, and mdBook examples from `:name` scalar-slot reads to bare reads while keeping oracle expected JSON unchanged. Fixes landed in `perl/LinkedSpec/ActionIR/ControlFlow.pm`, `perl/LinkedSpec/ActionIR/MethodLowering.pm`, `perl/LinkedSpec/BootstrapSpec/Core.pm`, `perl/LinkedSpec/RuleIR/EmitContext.pm`, `rust/linkedspec-runtime/src/engine.rs`, `rust/linkedspec-runtime/src/runtime.rs`, and `tools/gen_oracle_corpus.pl`; the full phase0 suite and Rust corpus oracle pass."
reverify: "rg -n 'split_tagged_records|descriptor_scalar_bare_read|bind_descriptor_scalar_bare_read|_control_ast_value_source_expr|array_copy|hash_copy|copy\\(' perl rust tools/gen_oracle_corpus.pl"
---

# Terse Source Migration Runtime Boundaries

This is the dated July 6 migration record. Retired helper spellings below describe that checkpoint; they are
not current authoring aliases. [[terse-helper-retirement-no-drift-closeout]] records the later removal and
current replacements. The historical causal evidence remains intact.

`SPEC-FORMAT-TERSE.15.2.4` proved that after Perl/Rust bare-read parity, current source migration from `:name` to
bare reads is output-preserving only if four boundaries stay explicit:

1. Parser-backed `set(...)` may appear in ActionIR AST as an internal `assign(...)`; control-flow value-source
   reconstruction must normalize it back to `set(...)` unless the user source was explicit `assign(...)`.
2. `split_tagged_records(source, delimiter, tag, ...)` treats its first argument as the required source value, so
   it must not spend the optional-scope normalizer that strips a first bare argument as a scope label.
3. Fluent `.return(array_copy(...))`, `.return(hash_copy(...))`, and `.return(copy(...))` are general payload
   returns; they must not be label-injected as `return(Label, payload)`.
4. Rust action-edge `call(child)` blocks must compute the child result but publish `retv` and descriptor scalar
   bare-read tags only after the attached block completes normally. Descriptor scalar bare reads may coexist with
   same-name aggregate accumulators: bare `rule` can read the descriptor scalar, while `array(rule)` /
   `flat_array(rule)` keep reading aggregate storage.

Also, `array(retv)` is an aggregate wrapper/read, not a one-element scalar array constructor. Use `[retv]` when the
intent is a one-element array containing the scalar value.
