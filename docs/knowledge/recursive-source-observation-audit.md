---
id: recursive-source-observation-audit
title: Recursive source observation reuses one monotonic invocation authority and preserves child cursor ownership
answers:
  - "how will recursive rules expose entry match and accepted exit positions"
  - "what fields are in a recursive source observation"
  - "does recursive observation use a second invocation stack"
  - "when is recursive entry position captured"
  - "what is the selected match in a recursive observation"
  - "when is accepted exit absent"
  - "how are recursive parent child invocation ids related"
  - "what happens to invocation identity when a recursion guard rejects before rule entry"
  - "does a parent rule choose the child cursor policy"
  - "where do Perl Rust Dart Julia and Lua guard nonprogress recursion"
  - "why is the typed source direct nonprogress fixture inconsistent"
  - "which task fixes recursive observation invocation lineage"
  - "what is the recursive source observation rollout order"
date: 2026-08-12
status: accepted behavior-free audit; neutral lineage correction implemented before executable observation work
tags: [architecture, source-location, recursion, invocation, provenance, cursor, diagnostics, portability]
evidence: "FUTURE-PARITY-BACKLOG.14.4.0 audit landed at 2c968259; corrective .14.4.0.1 exact RED rejects the committed textual fixture, then positive numeric fixtures plus four reason-checked lineage mutations pass. ADR 0056 sections 19-20 preserve the boundary and historical cause."
reverify: "bash tools/run_python_project_data.sh tools/check_typed_source_location_contract.py && rg -n 'Make recursive invocation lineage|direct_nonprogress|validate_recursive_observation_lineage|recursion_guard|enter_recognition_invocation|enter_invocation' docs/decisions/0056-typed-source-location-and-cursor-algebra.md capability_conformance/typed_source_location_contract.json tools/check_typed_source_location_contract.py perl/LinkedSpec/SpecEntry.pm rust/linkedspec-runtime/src/engine.rs dart/lib/src/runtime/interpreter.dart julia/src/runtime/Interpreter.jl lua/src/linkedspec/interpreter.lua"
---

Recursive observation extends the private recognition invocation authority already implemented by Perl, Rust,
Dart, Julia, PUC Lua, and LuaJIT. It does not create another stack, expose a runtime object, or retain a completed
parse history. One requested record is detached and immutable: source identity, rule identity, invocation id,
nullable direct-parent id, entry position, nullable selected-match span, nullable accepted-exit position, terminal
outcome, and nullable diagnostic.

Entry is the caller's current position before the entered rule's `I` lifecycle. An action edge carries the parent's
selected local match into the child's entry-match register; a direct call carries no invented entry match. The
child still derives seek or consume from its own family. Its terminal selected match is absent for a zero-regex
coordinator or no-selection outcome. Accepted exit is present only for normal accepted return and is the cursor from
which the caller resumes. Outcomes are `accepted`, `failed`, `aborted`, or `rejected`.

All live engines guard an already-active `(rule, cursor)` edge before pushing a child recognition frame. A rejected
attempt must therefore reserve a fresh monotonic child identity from the existing authority, point to the active
invocation as its distinct earlier parent, emit a detached rejected record, and avoid pushing a live frame. Parent
links are parse-local, same-source, direct, acyclic numeric provenance—not stack frames or backend addresses.

The original neutral artifact violated that rule for `direct_nonprogress`: both `invocation_id` and
`parent_invocation_id` were `recursive-1`. The row entered with the original typed-source contract at `e8f6198b`;
later transaction work made invocation identities monotonic and non-reused, but exact tuple comparison masked the
missing lineage invariants. Corrective `.14.4.0.1` replaces textual rows with positive numeric identities and
assigns rejected attempted children `9` and `11` to active parents `8` and `10`. Validation now rejects invalid
identity kinds/ranges, self-parenting, reuse, non-earlier parents, and represented cycles before tuple equality.
Four reason-checked regressions advance governance from 53 to 57 mutations without changing behavior or rollout.

After that completed prerequisite, rollout is neutral `.14.4.1`, Perl `.2`, Rust `.3`, Dart `.4`, Julia `.5`, shared Lua with
independent PUC Lua/LuaJIT proof `.6`, recurring composition `.7`, and public closeout `.8`. The audit itself adds
no syntax, helper, ActionIR node, descriptor/generated version, semantic/MCP field, CLI option, or runtime behavior.
