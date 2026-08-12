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
  - "what is the exact future recursive observation syntax"
  - "how is a recursive observation returned without changing the child payload"
  - "what carrier and field access does recursive observation use"
  - "how many executable recursive observation transitions and mutations are current"
  - "what is the recursive source observation rollout order"
date: 2026-08-12
status: accepted audit; numeric lineage corrected and executable neutral observation contract current
tags: [architecture, source-location, recursion, invocation, provenance, cursor, diagnostics, portability]
evidence: "FUTURE-PARITY-BACKLOG.14.4.0 audit landed at 2c968259; corrective .14.4.0.1 exact RED rejects the committed textual fixture, then positive numeric fixtures plus four reason-checked lineage mutations pass. Executable neutral .14.4.1 selects observe_recognition(observation, call(Child)) plus one detached nine-field harray, executes 33 transitions, and advances typed-source governance to 70 mutations without backend or rollout admission. ADR 0056 sections 19-21 preserve the boundary and historical cause."
evidence_update_2026_08_12_neutral_signoff: "Exact six-runtime composition passes Perl 10, Rust/Dart 4/4, Julia 127, and PUC Lua/LuaJIT 240/240 plus strict generated Rust 105/105, capability 80/0/0, and language 246/105+1/122. The rendered book, Knowledge 821/6831, all eight doctrines, host-permitted six-family containment, repository relocation, CLI 66x2, RAM 35%, and canonical Phase 0 1031/1031 in 714 seconds pass through the exact local-CI success marker and exit 0 without runtime or public admission."
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

Executable neutral `.14.4.1` selects future
`value = observe_recognition(observation, call(Child))`. `observation` is one bare rule-local harray binding and the
operand is exactly one unevaluated statically named call. The expression returns the unchanged ordinary child
payload; a separate recursively detached harray contains exactly `source_id`, `rule_label`, `invocation_id`,
`parent_invocation_id`, `entry_position`, `selected_match`, `accepted_exit`, `outcome`, and `diagnostic`. Positions
and the selected span are ordinary detached harrays, read with existing field access such as
`observation["accepted_exit"]`. This avoids both payload-truthiness collapse and a new authored value/accessor family.

The independent machine executes 33 transitions over ids `1..11`. It proves action-edge carried entry matches,
direct-call absence, caller-cursor entry before `I`, child-owned seek/consume, terminal selected-match replacement,
zero-regex absence, accepted-only exit, all four outcomes, pre-entry rejection without a frame, and immediate
detach with no retained history. Two static target/operand diagnostics and 13 new mutation checks advance the
neutral total from 57 to 70. Rollout remains 8 complete / 6 pending because no backend, ActionIR, facade, schema,
semantic/MCP, CLI, README, or public behavior is admitted until `.14.4.2-.8`.
