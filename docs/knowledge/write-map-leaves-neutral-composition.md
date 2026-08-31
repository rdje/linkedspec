---
id: write-map-leaves-neutral-composition
title: "Nested writes inside map_leaves bang keep receiver, unrelated, shadow, and continuation transactions distinct"
answers:
  - "how do write vivification and map_leaves bang compose"
  - "can a map_leaves bang callback vivify its copied value"
  - "is a callback value replacement subtree revisited after vivification"
  - "does an unrelated nested write survive a later map_leaves callback failure"
  - "does a failed unrelated nested write roll back map_leaves bang"
  - "which diagnostic wins when a callback nested-writes the active receiver"
  - "do same-receiver nested-write segment and RHS expressions evaluate before the map guard"
  - "can a same-spelling shadow binding vivify during map_leaves bang"
  - "can continuation write the receiver after map_leaves bang commits"
  - "does continuation nested-write failure roll back the map_leaves bang commit"
  - "what is the current six-runtime boundary for composed write and map_leaves bang source"
date: 2026-08-31
status: accepted future-neutral composition; backend implementation pending
tags: [dsl, mutation, vivification, map-leaves, composition, identity, atomicity, diagnostics, FUTURE-PARITY-BACKLOG]
evidence: "FUTURE-PARITY-BACKLOG.19.1.3 adds capability_conformance/write_map_leaves_composition_contract.json without a new executable entrypoint. The existing write checker validates eight embedded nested writes; the existing mutation checker executes six callback compositions and one post-commit continuation, retains 167 base mutations, and rejects 593 composition scalar/container-shape mutations. Exact primary-command probes return the non-bang control {\"leaf\":[]} on Perl, Rust, Dart, Julia, PUC Lua, and LuaJIT. The bang source stops before callback nested-write lowering: Perl returns null; Rust warns at the stopped map_leaves identifier then returns null; Dart, Julia, and both Lua ABIs exit 1 with the generic parser-invocation boundary. No backend or capability is admitted."
evidence_update_2026_08_31_perl_write_boundary: "FUTURE-PARITY-BACKLOG.19.2.1 makes the nested-write half executable on Perl but leaves map_leaves! parsing/runtime untouched. The composed callback/continuation cases therefore remain neutral-only on every backend until .19.2.2 and later backend/admission leaves."
reverify: "bash tools/run_python_project_data.sh tools/check_write_vivification_contract.py && bash tools/run_python_project_data.sh tools/check_map_leaves_mutation_contract.py && rg -n 'write-map-leaves-composition|callback compositions|post-commit|593 composition|action_parse_before_callback_nested_write_lowering' capability_conformance/README.md capability_conformance/write_map_leaves_composition_contract.json TOOLBOX.md docs/decisions/0036-write-vivification-and-receiver-mutation.md docs/tasks/FUTURE-PARITY-BACKLOG.15-24.md"
---

# Future-neutral write/`map_leaves!` composition

`linkedspec-write-map-leaves-composition-v1` binds the unchanged
[[write-vivification-neutral-contract]] and [[map-leaves-mutation-neutral-contract]] authorities by identity,
repo-relative path, and canonical-JSON digest. It supplies shared fixtures to the two existing checkers; it is not
a third executable or a backend admission.

## Callback transaction boundaries

A callback may nested-write its detached `value` and return the updated result. That result becomes the leaf
replacement, remains detached, and is not revisited during the same original-shape traversal. Merely changing the
callback local still cannot update the receiver without returning it.

A write to an unrelated binding follows the nested-write contract independently of receiver rebuild. Completed
unrelated writes persist if a later callback fails. If the write itself fails, its unchanged diagnostic aborts the
bang call before receiver commit; partial structural path creation is discarded, while any segment/RHS side effect
completed before structural validation retains ordinary write semantics.

The active guard compares resolved identity before attempting a same-receiver nested write. It raises
`receiver_mutation_reentrant` before segment or RHS evaluation, so that diagnostic outranks invalid selectors,
evaluation failures, kind conflicts, and gaps. A helper parameter with receiver spelling but a distinct identity
may vivify normally and cannot write the guarded outer binding.

## Commit and continuation

Complete callback success commits the rebuilt receiver once and releases its guard. Continuation then runs
against the detached result. A continuation helper may reach the receiver and perform an ordinary nested write;
if that write fails, its structural attempt rolls back but the earlier `map_leaves!` receiver commit remains.

The exact current composed source is still future-only. Its non-bang control returns the same empty-array leaf on
all six runtime routes. Every bang route stops before callback nested-write lowering, with the existing soft-null
Perl/Rust boundary and generic nonzero Dart/Julia/Lua boundary. Implementation starts at `.19.2.1`.

Related: ADR `0036`, [[write-vivification-receiver-mutation-direction]], and
[[tool-project-data-ssd-storage]].
