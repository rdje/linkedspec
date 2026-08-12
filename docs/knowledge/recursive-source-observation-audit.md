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
  - "is recursive observation recurring proof current"
  - "what is the recursive source observation rollout order"
date: 2026-08-12
status: accepted audit; numeric lineage corrected, neutral executable, all six runtimes privately admitted, and recurring proof current
tags: [architecture, source-location, recursion, invocation, provenance, cursor, diagnostics, portability]
evidence: "FUTURE-PARITY-BACKLOG.14.4.0 audit landed at 2c968259; corrective .14.4.0.1 exact RED rejects the committed textual fixture, then positive numeric fixtures plus four reason-checked lineage mutations pass. Executable neutral .14.4.1 selects observe_recognition(observation, call(Child)) plus one detached nine-field harray, executes 33 transitions, and advances typed-source governance to 70 mutations without backend or rollout admission. ADR 0056 sections 19-21 preserve the boundary and historical cause."
evidence_update_2026_08_12_neutral_signoff: "Exact six-runtime composition passes Perl 10, Rust/Dart 4/4, Julia 127, and PUC Lua/LuaJIT 240/240 plus strict generated Rust 105/105, capability 80/0/0, and language 246/105+1/122. The rendered book, Knowledge 821/6831, all eight doctrines, host-permitted six-family containment, repository relocation, CLI 66x2, RAM 35%, and canonical Phase 0 1031/1031 in 714 seconds pass through the exact local-CI success marker and exit 0 without runtime or public admission."
evidence_update_2026_08_12_perl_admission: "FUTURE-PARITY-BACKLOG.14.4.2 admits only Perl through one private OBSERVE_RECOGNITION node, fail-closed target/operand policy, the existing monotonic authority, detached carrier construction, and live/generated execution. The exact seven-group consumer is ordinary/canonical; the pending recursive_observation row records only perl. Typed-source truth is 8/6/71. Recognition inventory becomes 129 current + four dedicated transaction nodes with OBSERVE_RECOGNITION rejected as binding_write; language coverage classifies its authored form as grammar-owned/non-public."
evidence_update_2026_08_12_perl_signoff: "Definitive Perl-admission signoff passes book 79/14508 KiB, Knowledge 822/6843, all eight doctrines, containment/relocation, CLI 66x2, RAM 50%, Phase 0 1031/1031 in 723 seconds, and the complete six-runtime typed-source opt-in through exact local-CI success with exit 0."
evidence_update_2026_08_12_rust_dart_admission: "Rust .14.4.3 and Dart .14.4.4 each add one dedicated private node, fail-closed static/effect policy, existing-authority parent/rejected identity, pending-entry-only observation, and one ephemeral detached completion across native, reconstructed, generated-plan, and emitted carriers. Rust preserves UTF-8-byte registers; Dart preserves UTF-16 code-unit registers; both project Unicode-scalar records only at the typed boundary. The still-pending row records perl, rust, and dart at 8/6/73."
evidence_update_2026_08_12_julia_admission: "Julia .14.4.5 adds one dedicated private node, fail-closed static/effect policy, existing-authority parent/rejected identity, pending-entry-only observation, and one ephemeral detached completion across native, reconstructed, generated-plan, and independently loaded emitted-module carriers. Julia preserves zero-based UTF-8 code-unit registers and projects Unicode-scalar records only through SourceLocation at the typed boundary. The still-pending row records perl, rust, dart, and julia at 8/6/74."
evidence_update_2026_08_12_julia_signoff: "Julia admission signoff passes the exact 207+30+127+162 composed proof, full ordinary discovery, storage 19/5, book 79/14528 KiB, Knowledge 825/6883, all eight doctrines, permission-authorized containment and relocation, CLI 66x2, RAM 60%, Phase 0 1031/1031 in 725 seconds, and the complete six-runtime typed-source opt-in through exact local-CI success."
evidence_update_2026_08_12_lua_admission: "Shared Lua .14.4.6 adds one Lua-5.1-compatible dedicated node, fail-closed static/effect policy, existing-authority parent/rejected identity, pending-entry-only observation, and one ephemeral detached completion across native, reconstructed, generated-plan, and independently loaded emitted carriers. PUC Lua and LuaJIT independently pass the same 43-assertion consumer, including captured bind-before-error records for direct rejection, mutual rejection, and abort. Lua preserves zero-based UTF-8-byte registers and projects Unicode-scalar records only through source_location at the typed boundary. The still-pending row records all six runtimes at 8/6/75; recurrence and public closeout remain separately owned."
evidence_update_2026_08_12_lua_signoff: "Shared-Lua admission signoff passes the exact 246+43+240+175 per-ABI focused proof, ordinary/storage and composed gates, book 79/14548 KiB, Knowledge 826/6897, all eight doctrines, permission-authorized containment and relocation, CLI 66x2, RAM 61%, Phase 0 1031/1031 in 734 seconds, and the complete six-runtime typed-source opt-in through exact local-CI success with exit 0."
evidence_update_2026_08_12_recurrence: "FUTURE-PARITY-BACKLOG.14.4.7 composes the unchanged neutral and exact Perl/Rust/Dart/Julia/PUC-Lua/LuaJIT observation consumers plus three support ledgers through one repository-routed driver. Five sources form six ordered routes because the shared Lua consumer runs once per ABI. Twelve new regressions promote only recursive_observation and advance typed-source truth to 9 complete / 5 pending / 87; public no-drift remains separately pending."
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
neutral total from 57 to 70. Perl `.14.4.2` now admits the exact private form and adds one rollout-regression
mutation, bringing governance to 71. Rust `.14.4.3`, Dart `.14.4.4`, Julia `.14.4.5`, and shared Lua `.14.4.6`
then add one omission regression each, bringing governance to 75 while the parent row stays pending with Perl,
Rust, Dart, Julia, PUC Lua, and LuaJIT recorded. Recurrence `.14.4.7` now composes those unchanged consumers and
three support ledgers through one rooted five-source/six-route driver; twelve regressions promote only the parent
row and advance truth to 9/5/87. Facades, schemas, semantic/MCP, CLI, README, and public behavior remain owned by
`.14.4.8` and the final combined `.14.8` row.
