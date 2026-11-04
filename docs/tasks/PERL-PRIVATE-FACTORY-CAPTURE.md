# PERL-PRIVATE-FACTORY-CAPTURE: Actual factory and dependency emission capture

## Metadata

- Tree ID: `PERL-PRIVATE-FACTORY-CAPTURE`
- Status: `active` / bounded callback handoff accepted; metadata QA .13 queued; original admissions open
- Roadmap lane: `.spec language evolution / producer-bound residual repair`
- Created: `2026-10-10`
- Last updated: `2026-11-04`
- Owner: LinkedSpec repo-local PNT
- Parent: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.3` in `docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md`
- Planning owner: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.3.0`

## Goal

Implement the selected private actual-callback registration and separate injected dependency capture protocol.
Keep public callback references, dependency/context maps, ordinary values, contexts, aliases, effects, error objects
and canonical family order intact. This linked implementation tree preserves every existing stable parent ID;
no existing task content or machine consumer moves.

## Scope and boundaries

The selected protocol and original opaque dependency diagnosis remain canonical in
`docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.0-plan.json` and
`docs/knowledge/perl-private-input-authority-selection.md`. Detailed proposed owner/API boundaries are in
`docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.3.0-plan.json`. Planning introduces no runtime measurement or new behavior.

Known callbacks come from actual built-in factory references in the current original-source/producer scope.
Opaque dependencies receive separate captures and cannot donate nested publications to an outer callback.
Private lexical thunks may retain and invoke the actual callback only while caller maps and public returned
callback fields stay exact. List and void calls retain native contexts under publication-disabled boundaries;
only scalar calls use the existing scalar-string packet capture. Trusted later output builders must explicitly
retain and compose child captures; ordinary values alone transfer no packet.

Typed/raw output construction, packet composition, original interval mapping, complete private Phase0 and
independent canonical admission stay with the original parent owners. The current replacement algorithm and
quoted-first example do not change here. Other repositories and all submodules remain read-only black boxes.

## Task Tree

- ID: `PERL-PRIVATE-FACTORY-CAPTURE`
  Status: `active`
  Goal: Actual factory/dependency registration and invocation boundaries under the selected original-source protocol.
  Dependencies: `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.3.0`
  Children: `PERL-PRIVATE-FACTORY-CAPTURE.1`, `PERL-PRIVATE-FACTORY-CAPTURE.2`, `PERL-PRIVATE-FACTORY-CAPTURE.3`, `PERL-PRIVATE-FACTORY-CAPTURE.4`, `PERL-PRIVATE-FACTORY-CAPTURE.5`, `PERL-PRIVATE-FACTORY-CAPTURE.7`, `PERL-PRIVATE-FACTORY-CAPTURE.6`.
  Acceptance: Individual bounded owners preserve current public behavior and pass source-bound focused proof. Return independent composition to the original owner; no separate parent admission is inferred.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.1`
  Status: `done` / `focused-signoff-complete` (activated from clean `02345ee21f9cd674dea073b5e25f6200bd0a6ead`)
  Goal: Private registration/dependency boundary framework and native differential lifecycle/context/alias/error proof; no production factory or pipeline activation.
  Dependencies: `RUST-DEPENDENCY-WARNING-ZERO.8`
  Verification tier: `focused`
  Focused checks: Actual/native callback and invocation identities; scalar/list/void context, aliases, once-only effects, exact return/error/fatal values, opaque nested delegation, scope restoration/release and unchanged public maps. Complete supplied direct consumers, effective semantic faults, retained instrument/input/channel identities, complete relevant book and ordinary doctrines.
  Canonical trigger: none for bounded private implementation without public/generated/mechanical change; reclassify before writes if scope crosses those boundaries. Complete private Phase0 and canonical replacement remain separately owned.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.1.json`
  Acceptance: Follow the retained owner plan; choose no authority by name, copied metadata or equal value. Preserve existing selected input grants and callback references. Split further before writes if actual code paths exceed a safe slice. Commit before activating the next owner.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.1 - isolate native dependency calls`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.1`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.2`
  Status: `active` / implementation children accepted; original independent admission open
  Goal: Actual built-in contract lower registration plus separate injected dependency calls. Reuse the canonical input_slice opaque-delegation diagnosis; prove current factory behavior without changing public maps/callback fields.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.1`
  Children: `PERL-PRIVATE-FACTORY-CAPTURE.2.0`, `PERL-PRIVATE-FACTORY-CAPTURE.2.1`.
  Owned paths: The actual EmitContext callback/owner bridge prerequisite, Contracts and its StagedParseJob/ProgressiveSpanDispatch callback factories; bounded proof/Knowledge/book/continuity. Shared OwnerDispatch mechanics remain unchanged.
  Split rationale: Contracts defaults are actual EmitContext facade callbacks; current names alone cannot select them as built-in. Establish definition-bound references and isolate resolved owner calls before default factory registration. Register locally constructed lower callbacks at their own seams, including the two delegated factory owners, while isolating injected dependencies.
  Parent handoff: After accepted child .2.1.1, the next owner depends on that exact child. No separate factory parent admission is inferred; original independent composition/full-private/canonical owners retain closeout.
  Planned tier: `focused`
  Planned focused proof: Actual/native callback and invocation identities; scalar/list/void context where applicable, aliases, once-only effects, exact return/error/fatal values, opaque nested delegation, scope restoration/release and unchanged public maps. Complete supplied direct consumers, effective semantic faults, retained instrument/input/channel identities, relevant book and ordinary doctrines.
  Planned canonical boundary: none for bounded private implementation without public/generated/mechanical change; reclassify before writes if scope crosses those boundaries. Complete private Phase0 and canonical replacement remain separately owned.
  Planned claim record: none: Planning only; declare the actual source-bound measurement record at activation before publishing results.
  Acceptance: Follow the retained owner plan; choose no authority by name, copied metadata or equal value. Preserve existing selected input grants and callback references. Split further before writes if actual code paths exceed a safe slice. Commit before activating the next owner.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.2.0`
  Status: `done` / `focused-signoff-complete` (activated from clean `b21b3bb9f6a414d50c71468c3e4193d04ad9b56a`)
  Goal: Definition-bound actual EmitContext callback selection and separate resolved-owner/factory call boundaries, preserving native lazy loading, values, contexts, existing argument copies, errors, trace and public maps.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.1`
  Verification tier: `focused`
  Focused checks: Actual native facade reference versus same-name override/custom target/copied metadata; source/producer scopes and ordinary reference return; actual opaque owner nested-publication control; native scalar/list/void value/effect/error/reference/context comparisons including the existing copied-argument behavior; Trace/cold require and complete supplied direct consumers; effective semantic source faults, retained actual instruments/inputs/channels and reviewer controls; complete relevant book; ordinary doctrines.
  Canonical trigger: none for this bounded private prerequisite without public/generated/mechanical changes. Escalate before writes if selected proof exposes cross-cutting uncertainty. No parent/canonical admission inferred.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.2.0.json`
  Acceptance: Snapshot the actual definition-owned native references without selecting authority from a later public name lookup. A changed callback or custom target remains opaque; a retained same actual reference remains selectable. Separate every resolved owner/default-factory invocation; preserve existing lazy load, native context/arguments/effects/error behavior and trace order. Do not activate pipeline scopes or transfer child packets implicitly. Preserve original framework claim before changing its inputs. Commit before child .2.1.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.2.0 - bind native facade callback identity`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.2.0`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.2.1`
  Status: `active` / implementation children accepted; original independent admission open
  Goal: Actual Contracts/default callback registration at trusted construction seams and isolated injected calls, including the two delegated contract factories.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.2.0`
  Owned paths: `perl/LinkedSpec/ActionIR/Contracts.pm`, `StagedParseJob.pm`, `ProgressiveSpanDispatch.pm` for their own actual lower callbacks; bounded proof/Knowledge/book/continuity. No global owner-dispatch or mapping change.
  Planned tier: `focused`
  Planned focused proof: Complete actual contract callback/order/metadata and public map/reference compatibility, exact native-default/custom/same-name callback distinction, actual input_slice opaque-delegation diagnosis, scalar/list/void and effect/error/lifetime observations, complete supplied direct consumers, effective semantic faults and actual evidence/book controls. Split further before writes if needed.
  Planned canonical boundary: none for bounded private implementation; original independent composition/full-private/mapped/canonical obligations remain open.
  Planned claim record: none: Planning only; declare source-bound actual measurement at activation.
  Acceptance: Register callbacks inside their own built-in construction seams without granting authority to callbacks returned by substituted factories. Isolate injected dependencies through private bindings or actual call sites while retaining public maps/default results/returned callback fields and family order. Commit before MethodLowering owner .3.
  Children: `PERL-PRIVATE-FACTORY-CAPTURE.2.1.0`, `PERL-PRIVATE-FACTORY-CAPTURE.2.1.1`.
  Split rationale: Isolate private injected bindings/default selection first, then register locally constructed lower callbacks and the two delegated factories. This bounds source ownership and avoids introducing known callbacks before their injected calls are isolated.
  Parent handoff: After accepted .2.1.1, MethodLowering .3 depends on that exact child; no separate parent admission is inferred.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.2.1.0`
  Status: `done` / `focused-signoff-complete` (activated from clean `2d878478028fc417ac5b7790c016543c18c1f48b`)
  Goal: Isolate Contracts private injected callback bindings and select actual native contract defaults while preserving public maps, callback references, native contexts/aliases/effects/errors and cold loading.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.2.0`
  Verification tier: `focused`
  Focused checks: Actual native default references versus custom targets/same-name overrides, exact public map preservation; direct native scalar/list/void alias/effect/value/error ledgers and actual injected callback identity; each required/optional/bare binding, original input_slice opaque-publication control, weak lifetime and cold loading; complete supplied direct consumers, effective semantic source faults, actual input/instrument/channel identities and reviewer controls; complete book and ordinary doctrines.
  Canonical trigger: none for bounded private owner integration without public/generated/mechanical changes. Escalate before writes if proof exposes cross-cutting uncertainty. Complete private/mapped/canonical admission remains open.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.2.1.0.json`
  Acceptance: Preserve the current EmitContext claim before input writes. Select native default callbacks only for the built-in target and exact retained native references. Caller maps/default results/public lower fields stay actual and unchanged. Private lexical thunks must retain/invoke the actual callback and forward aliases/context/errors without autoloading SourceEmissions. Optional dropped and bare paths must not bypass isolation. No actual contract lower registration or pipeline activation. Commit before .2.1.1.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.2.1.0 - isolate contract dependencies`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.2.1.0`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.2.1.1`
  Status: `done` / `focused-signoff-complete` (activated from clean `be7d70719856e76b7cb5a427ad6061a7109028ea`)
  Goal: Register actual locally constructed contract lower callbacks and the two delegated factory owners at their own construction seams.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.2.1.0`
  Verification tier: `focused`
  Focused checks: Actual complete native/current contract metadata/order/ordinary values/reference patterns, each actual local/delegated construction seam and returned array/hash/lower identity; changed/substituted factory opacity, current/nested source/producer scope selection/release and cold loading; complete supplied direct consumers, effective syntax-valid semantic source faults, retained producer/input/channel identities and reason-sensitive reviewer/book controls.
  Canonical trigger: none for bounded private factory construction; original complete private/independent/mapped/canonical owners remain open.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.2.1.1.json`
  Acceptance: Register actual native lower CODE references inside each owning factory, never blindly register callbacks returned by a substituted factory. Preserve actual public array/hash/lower references and family order. Commit before MethodLowering .3.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.2.1.1 - register own lower callbacks`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.2.1.1`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3`
  Status: `active` / bounded implementation children
  Goal: Actual default native callback registration and injected method/value dependency boundaries. Split by function families before writes if this owner exceeds a safe slice.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.2.1.1`
  Owned paths: `perl/LinkedSpec/ActionIR/MethodLowering.pm` and definition-owned EmitContext selection; focused fixture/proof/claim, relevant Knowledge/book and continuity. No unrelated producer or mapping changes.
  Planned tier: `focused`
  Planned focused proof: Actual/native callback and invocation identities; scalar/list/void context where applicable, aliases, once-only effects, exact return/error/fatal values, opaque nested delegation, scope restoration/release and unchanged public maps. Complete supplied direct consumers, effective semantic faults, retained instrument/input/channel identities, relevant book and ordinary doctrines.
  Planned canonical boundary: none for bounded private implementation without public/generated/mechanical change; reclassify before writes if scope crosses those boundaries. Complete private Phase0 and canonical replacement remain separately owned.
  Planned claim record: none: Planning only; declare the actual source-bound measurement record at activation before publishing results.
  Acceptance: Follow the retained owner plan; choose no authority by name, copied metadata or equal value. Preserve existing selected input grants and callback references. Split further before writes if actual code paths exceed a safe slice. Commit before activating the next owner.

  Children: `PERL-PRIVATE-FACTORY-CAPTURE.3.0`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1`, `PERL-PRIVATE-FACTORY-CAPTURE.3.2`.
  Split rationale: Establish actual native default selection first, then required dependency bindings, then optional/direct callbacks. Refine function families before writes if necessary; no parent closeout inferred from individual children.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.0`
  Status: `done` / `focused-signoff-complete` (activated from clean `33e57deee73e27b97e9c21116bc70942f3f33772`)
  Goal: Definition-owned MethodLowering native default references and target/ref selection, preserving the exact public dependency map.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.2.1.1`
  Verification tier: `focused`
  Focused checks: Complete actual native/current public callback map ledgers, actual map/ref identity and individual definition-owned selection, every same-name replacement and custom target opacity, source/producer scope separation/restoration and cold lazy loading; complete supplied direct suites, effective per-entry source faults and actual reviewer controls, exact retained producers/inputs/channels and original claim preservation; complete relevant book and ordinary doctrines.
  Canonical trigger: none for bounded private reference selection without public/generated/mechanical change. Complete private Phase0 and independent canonical/parent admission remain separately owned.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.0.json`
  Acceptance: Preserve the previous244 live claim bindings before changing inputs. Return the exact actual map/callback references; only the built-in target and actual definition-owned callback can register. Names, copies and custom native aliases confer no authority. Commit before required bindings.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.0 - select native method defaults`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.0`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1`
  Status: `active` / bounded function-family children
  Goal: Isolate MethodLowering required injected callback calls using private bindings; split function families before writes as needed.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.0`
  Owned paths: `perl/LinkedSpec/ActionIR/MethodLowering.pm` required callback bindings; focused proof/claim, Knowledge/book/continuity.
  Planned tier: `focused`
  Planned focused proof: Actual opaque dependency boundaries, native contexts/aliases/effects/errors/public maps and retained source-bound controls/consumers.
  Planned canonical boundary: none for bounded private implementation; complete private Phase0 and canonical admission stay with original owners.
  Planned claim record: none: Planning only; declare measurement at activation.
  Acceptance: Preserve native behavior and actual public references; commit bounded children before optional/direct calls.

  Children: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.0`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.1`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.4`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6`.
  Split rationale: Separate the private binding primitive and small trim callers, assignment/declaration inference, inline/block controls, guarded AST calls, large value lowering, scalar/return/mutation helpers and receiver/parser helpers. Each family owns actual-call proof before writes; refine further if needed.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.0`
  Status: `done` / `focused-signoff-complete` (activated from clean `89a4ede6fbbb0f3b7a4e4f98a4b477b79c0cfeb7`)
  Goal: Private native-context dependency binding and required trim isolation for direct shape inference, method tag normalization and inline switch-case normalization.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.0`
  Verification tier: `focused`
  Focused checks: Paired original/current actual-call publication fixture, direct native/current scalar/list/void values/aliases/effects/errors/fatal identities, actual three caller outcomes and copied top-level arguments, map references, required missing-dependency diagnostics, scoped opaque/known child separation and lexical lifetime/cold loading; supplied direct suites, effective per-seam and primitive faults, retained original producers/inputs/channels and reviewer/book controls.
  Canonical trigger: none for bounded private implementation without public/generated/mechanical change. Complete private Phase0 and independent canonical/parent admission remain original owners.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.0.json`
  Acceptance: Preserve all282 current claim live inputs before writes. Retain actual dependencies in private lexical thunks forwarding original aliases/context, return ordinary values and preserve caller maps. The three actual injected trim calls cannot donate nested publication. Commit before other required function families.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.0 - isolate required trim dependencies`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.0`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.1`
  Status: `done` / `focused-signoff-complete` (activated from clean `429d0c6d959e883304bc06d8c569c76e7bdcedfc`)
  Goal: Assignment/declaration inference required dependency boundaries; split further before writes if needed.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.0`
  Verification tier: `focused`
  Focused checks: Every eight required callback roles across three actual callers; native/current full value/context/effect/error/reference ledgers, paired original/current semantic publication fixture, unchanged caller maps and required diagnostics, actual native identity versus private wrapper, cold loading and supplied direct consumers; effective per-seam faults, retained producers/all inputs/channels, reason-sensitive reviewer/original-binding controls and complete relevant book.
  Canonical trigger: none for bounded private implementation without public/generated/mechanical changes; original full-private/mapped/canonical owners retain admission.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.1.json`
  Acceptance: Preserve original262 live bindings before input writes. Bind only the three required resolution seams, keeping actual public maps/callbacks and native behavior. Explicit controlled secondary helpers isolate these three actual caller mechanisms; no optional/direct call or authored-language change. Commit before inline/block .3.1.2; no independent parent admission inferred.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.1 - isolate required inference dependencies`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.1`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2`
  Status: `done` / bounded inline and block child implementation complete; independent private admission remains open
  Goal: Inline/block required dependency boundaries with bounded native/current actual-call proof.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.1`
  Children: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.0`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.1`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2`.
  Acceptance: Commit each bounded child before advancing. The following guarded AST owner depends on the last exact child.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.2`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.0`
  Status: `done` / `focused-signoff-complete` (activated from clean `9032b20e921540833ee0b5204594835b10e7b55b`)
  Goal: Inline if/switch required dependency boundaries with all five actual callback roles.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.1`
  Verification tier: `focused`
  Focused checks: Five actual callback roles across two owners, native/current full ledgers and copied/shared argument behavior, required diagnostics, paired publication RED/GREEN, actual callback identity, cold lazy loading and supplied direct consumers; independent per-seam boundary/identity/diagnostic faults, retained producers/all inputs/channels, reviewer/original-binding controls and complete book.
  Canonical trigger: none for bounded private implementation without public/generated/mechanical changes; original full-private/mapped/canonical owners retain admission.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.0.json`
  Acceptance: Preserve all240 original live input bindings before source/fixture/book writes. Bind only two required returns; retain original public maps/references and native values/contexts/alias/effect/error behavior. Explicit constant branch payload/case/truthiness helper controls isolate the two actual caller bodies; no full successful conditional-language admission. Commit before .3.1.2.1.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.0 - isolate inline control dependencies`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.0`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.1`
  Status: `done` / `focused-signoff-complete` (activated from clean `65bd00faa0b10abc106a6da2283391c268ee88fa`)
  Goal: Block component and side-effect required dependency boundaries with actual native fallback/reference behavior.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.0`
  Verification tier: `focused`
  Focused checks: Six invoked callback roles and separate validation-only lower_flow_composite_expr requirement; complete native/current string/undefined/fatal/reference ledgers, actual native fallback values and shared normalizer arrays, copied inputs/public references/contexts/effects/errors, exact required diagnostics and paired publication RED/GREEN. Explicit constant/undef secondary and AST controls isolate the actual two bodies. Per-seam boundary/identity/diagnostic faults include the validation-only missing-flow requirement; cold loading, supplied direct consumers, retained producers/all inputs/channels, actual reviewer/original-binding controls and complete book.
  Canonical trigger: none for bounded private implementation without public/generated/mechanical changes; original full-private/mapped/canonical owners retain admission.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.1.json`
  Acceptance: Preserve all242 original inline claim live inputs before source/fixture/book writes. Bind only the two required returns, preserving undefined-result fallbacks and actual references/aliases/native behavior. Do not claim an invocation for the validation-only flow callback. Commit before the separately owned finite history-capacity prerequisite .3.1.2.3; retain a concise complete note under existing limits.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.1 - isolate block component dependencies`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.1`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3`
  Status: `done` / `canonical accepted at268891fdf` (activated from clean `cdc45f9cbddbc53603e885225af2a35688657292`)
  Goal: Admit one exact engineering-notes archive member and its exact manifest capacity through a separately indexed accepted decision; preserve all prior history and current runtime proof inputs.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.1`
  Verification tier: `canonical`
  Focused checks: Independent clean-Git preservation; exact old/new canonical limit and contract objects; actual production boundary/accepted-indexed-authority REDs, retained all inputs/producers/channels and reviewer corruption controls; unchanged public documentation authority contract. Actual original504-input supplied replay, unchanged public selector classifier70/36 RED/GREEN, complete current book57+32 with three controls, retained failed draft render/producer and three actual new evidence REDs/restoration.
  Canonical trigger: Routing-capacity infrastructure requires exact complete staged-candidate CI/receipt before landing.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3.json`
  Acceptance: Use finite engineering-maintenance authority under current PNT and ADR0128/0129/0130 precedent. Preserve every old immutable byte and manifest record; admit only one measured new member and exact manifest growth. Account for the sole ADR in decision-store limits where required. Commit canonical proof before local-return/value .3.1.2.2.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3 - admit history capacity and reconcile factory audit`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2`
  Status: `done` / bounded local-return and block-value implementation complete; independent private admission remains open
  Goal: Block-local return and block-value required dependency boundaries.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3`
  Children: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.0`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.1`.
  Acceptance: Preserve current claim inputs before writes; retain existing AST-first and guarded local-return behavior. Commit before guarded AST .3.1.3; no independent parent admission inferred.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.0`
  Status: `done` / `focused-signoff-complete; normal doctrine hooks govern landing` (activated from clean `268891fdf948b1ccf875087416b62100e0ddc059`)
  Goal: Isolate the two required callbacks of block-local return without changing native payload behavior.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3`
  Verification tier: `focused`
  Focused checks: Actual parser/normalizer native string/undefined/fatal ledgers, shared argument array and public callbacks, opaque/known publication separation, exact diagnostics and payload guards; paired original/current complete TAP, three semantic source faults, unchanged supplied33/152 plus two fixtures, historical399-input preservation with actual corruption RED/restoration, complete recursive-include book and evidence controls; standard public Phase0 compatibility, ordinary doctrines, both history checks and diff hygiene.
  Canonical trigger: None for this bounded private required binding; complete private Phase0/mapped/parent and final push admission remain independently owned.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.0.json`
  Acceptance: Preserve all399 current capacity/audit claim live bindings at clean268891fdf before their source/book/history inputs change. Edit exactly one required return. Preserve parser-result argument identity, existing scalar copies, error effects/fatal objects, undefined/empty/zero payload guards and brace prefix. Do not infer complete payload-helper, block-value or language admission. Commit before .3.1.2.2.1.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.0 - isolate local return required callbacks`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.0`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.1`
  Status: `done` / `focused-signoff-complete; normal doctrine hooks govern landing` (activated from clean `de3b50dd06d4aff6babf379282f90368810d49e5`)
  Goal: Isolate block-value required dependencies while retaining AST-first dispatch and guarded legacy fallback.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.0`
  Verification tier: `focused`
  Focused checks: Actual trim/split/parse native string/undefined/fatal ledgers; locally validated never-invoked normalizer and exact diagnostics; actual copied AST bridge/early-return/fallback/guarded local-return/shared-split-array paths under explicit secondary controls. Paired complete original/current TAP, three effective source faults, unchanged supplied35/154 plus two fixtures, original273-input preservation with actual corruption RED/restoration, evidence controls and complete recursive-include book. Standard public Phase0, syntax, ordinary doctrines/history/diff hygiene.
  Canonical trigger: None for bounded private implementation; original complete private Phase0/mapped/parent and final push owners retain admission.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.1.json`
  Acceptance: Preserve all273 original local-return live bindings at clean de3b50dd0 before bound writes. Bind exactly one required resolver return. Preserve AST-first dispatch and copied bridge dependencies, existing fallback/native aliases/errors/public maps and guarded nonfinal returns. Distinguish local normalizer validation from actual trim/split/parse invocations; controlled secondary helpers do not admit complete helper or authored-language behavior. Commit before guarded AST .3.1.3.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.1 - isolate block value required callbacks`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.1`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3`
  Status: `active` / bounded guarded AST implementation children verified; original independent admission open
  Goal: Guarded AST required dependency boundaries with separate native validation-order proof.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.1`
  Children: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.0`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.1`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.2`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.3`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.4`.
  Owned paths: MethodLowering required seams in _lower_ast_scalar_held_hash_index_assignment_value_node, _lower_ast_call_statement, _lower_ast_array_end_mutation_method_statement, _lower_ast_assignment_operator_statement; focused fixtures/proof/claim, Knowledge/book/continuity. Optional/direct calls remain .3.2.
  Planned tier: `focused`
  Planned focused proof: Actual native/current caller behavior, opaque dependency separation, contexts/aliases/effects/errors/public maps, retained source-bound faults/consumers and complete relevant book.
  Planned canonical boundary: none for bounded private implementation; original full-private/mapped/canonical owners retain admission.
  Planned claim record: none: Planning only; declare source-bound measurement at activation.
  Acceptance: Preserve actual public references and native behavior. Commit each bounded family before advancing; no independent parent admission inferred.
  Parent handoff: After accepted assignment child .3.1.3.3, main method/value .3.1.4 depends on that exact child. This implementation handoff is not a separate group/full-private/canonical admission.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.0`
  Status: `done` / `focused-signoff-complete; normal doctrine hooks govern landing` (activated from clean `b50ce085a63c8777973bc4c4e4a999a8840c462b`)
  Goal: Isolate the guarded scalar-held hash-index assignment key callback without changing native guard or source-fallback order.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.1`
  Verification tier: `focused`
  Focused checks: Actual required key callback native string/undefined/fatal ledgers, scalar context/copy/alias/effects/errors/fatal identity/public maps, opaque/known publication and actual identity; actual node/target guards before dependency validation, source/fallback/output guards and exact missing/non-CODE diagnostics under explicit secondary controls. Paired full original/current TAP, three effective semantic source faults, unchanged supplied37/156 plus two fixtures, original275-input preservation with actual corruption RED/restoration, evidence controls and full recursive-include book. Standard public Phase0 and Perl syntax, ordinary doctrines/history/memory/diff checks.
  Canonical trigger: None for bounded private implementation; original full-private/mapped/parent and final push owners retain admission.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.0.json`
  Acceptance: Preserve all275 original block-value live bindings at clean b50ce085a before bound writes. Edit exactly one required return. Preserve nonmatching-node/invalid-target early rejection, eager validation for valid nodes, source fallback, actual callback identity, copied key-source scalar and all existing native results/errors. Explicit secondary controls admit no complete source/payload/assembly helper, AST grammar or authored-language behavior. Commit before .3.1.3.1.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.0 - isolate guarded AST hash key callbacks`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.0`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.1`
  Status: `done` / `focused-signoff-complete; normal doctrine hooks govern landing` (activated from clean `2e9e5443ea38789fe454ee7ee24a68be81d4546c`)
  Goal: Isolate all six required AST call-statement callback roles while retaining branch-specific validation and native argument behavior.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.0`
  Verification tier: `focused`
  Focused checks: Six actual required roles (normalizer, trim, hash extraction, key lowering, array extraction, primitive lowering), native string/undefined/fatal ledgers, scalar contexts, actual argument ARRAY/slot aliases versus local scalar copies, effects/errors/fatal/public map identities. Eager versus lazy branch validation/guard order, opaque/known publication separation, exact diagnostics, bounded return/return_undef/set/set_key/push behavior under explicit secondary-helper controls. Paired full original/current TAP, three syntax-valid semantic faults, supplied39/158 plus two fixtures, original280-input preservation with corruption RED/restoration, evidence controls and full recursive-include book. Standard public Phase0/Perl syntax and ordinary doctrines/history/memory/diff.
  Canonical trigger: None for bounded private implementation; full-private/mapped/parent/final push admissions remain separate.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.1.json`
  Acceptance: Preserve all280 current hash-key inputs at clean 2e9e5443e before bound writes. Change exactly one required return; retain callback references, native results, lazy validation order and actual aliases/copies. Normalizer/trim are eager, hash/key require successful set_key normalization, array extractor precedes push arity checks, primitive lowerer follows arity/scoped-target guards. Explicit source/secondary helpers admit no complete helper, AST grammar, authored-language, optional/direct or independent private behavior. Commit before .3.1.3.2.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.1 - isolate AST call required callbacks`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.1`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.2`
  Status: `done` / `focused-signoff-complete; normal doctrine hooks govern landing` (activated from clean `b0099d9ade78623b38c2213867b84f1e32014fe7`)
  Goal: Isolate the AST array-end mutation required symbol-extraction callback without changing native guards or results.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.1`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.4`
  Verification tier: `focused`
  Focused checks: Four actual mutation methods and one required extractor role; complete native string/undefined/fatal callback ledgers, scalar context/local receiver-copy alias behavior, effects/errors/fatal/public-map identities and opaque/known publication separation. Actual node/calls/method/arity guards precede required validation; source/target/payload guards, bare-name fallback with and without callback mutation, host push/unshift/pop/shift and direct uniform-binding receiver results run under explicit secondary-helper controls. Paired identical original/current TAP, three syntax-valid semantic faults, supplied41/160 consumer baseline plus bounded fixtures and public uniform-binding test/contract, original356-input preservation with actual corruption RED/restoration, evidence controls, complete recursive-include book, public Phase0/Perl syntax and ordinary doctrines/history/memory/diff.
  Canonical trigger: None for one bounded private required resolver; optional/direct/other guarded owners, complete helper/AST grammar/language, output/mapped/full-private/parent and final push admissions remain separate.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.2.json`
  Acceptance: Preserve all356 current capacity inputs at clean b0099d9ad before bound writes. Change exactly one required return. Preserve actual callback/map/node/span references, local receiver scalar copy, native fallback, result, guard order and exact missing/non-CODE diagnostic. A mutating undefined callback may prevent bare-name fallback; a nonmutating undefined callback must still permit it. Push arity1/pop arity0 is checked before dependency validation. Secondary helper controls admit no complete helper or authored-language expansion. Commit before .3.1.3.3.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.2 - isolate AST array-end required callback`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.2`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.3`
  Status: `done` / `focused-signoff-complete; normal doctrine hooks govern landing` (activated from clean `4fde89c1958faf4057ab80eb7e7cd50962c7ac3c`)
  Goal: Isolate the AST assignment-operator required key callback without changing native lazy validation, helper paths or guard behavior.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.2`
  Verification tier: `focused`
  Focused checks: One actually invoked lower_scalar_access_key_expr role on hash-index fallback; native string/undefined/fatal callback ledgers, scalar context/local key-copy aliases, effects/errors/fatal identities, actual public maps and opaque/known publication separation. Node/expected-kind/target/source guards and scalar-held fast path precede required validation. Explicit secondary controls cover scalar, append, scalar-held/fallback hash and nested-access branches; variable-source fast read/fallback, empty/undefined/zero guards, untracked/tracked writes, new target-span values/reference and direct guard results. Identical original/current TAP, three effective syntax-valid faults, supplied44/164 consumer seed plus two fixtures, original283 binding preservation with corruption RED/restoration, evidence controls, complete recursive-include book, required Perl syntax/public Phase0 and ordinary doctrines/history/memory/diff.
  Canonical trigger: None for one bounded private required resolver. Other required/optional, complete helpers/AST grammar/language, output/mapped/full-private/parent and final push admissions remain separate.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.3.json`
  Acceptance: Preserve all283 current inputs at clean4fde89c19 before bound writes; retain every original proof/hash field without refresh. Change one required return only. Preserve actual callback/map/node references, local key scalar copy, lazy required diagnostic after source/fast-path guards, native helper order/results and the new tracked target-span construction. Commit before main method/value .3.1.4; split before writes if actual branch scope exceeds a safe slice.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.3 - isolate AST assignment required callback`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.3`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.4`
  Status: `done` / `exact staged canonical receipt and normal hooks govern admission` (activated from clean `9085eb1e5075146ca00dab52304f85937cf7ea05`)
  Goal: Admit exactly one change-history archive member and measured manifest/decision overhead before further guarded AST slices.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.1`
  Verification tier: `canonical`
  Focused checks: Retain actual pressure RED before governed rollover GREEN; independently reconstruct exact clean-source suffix/blob/range/digest, current root and all older archive/manifest/decision bytes. Execute unchanged production threshold and accepted/indexed/exact-object authority functions with actual measured inputs and distinguishing REDs; reason-sensitive reviewer corruptions/restoration; current279-input AST-call preservation before bound writes and full book/include render. Normal doctrines/history/Knowledge/memory/diff and exact staged canonical CI/receipt.
  Canonical trigger: Registry capacity and decision/history infrastructure require exact staged canonical admission; focused proof alone cannot land.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.4.json`
  Acceptance: Current CHANGES58706 bytes is276 bytes below mandatory rollover; collection48 files and manifest47 lines/26831 bytes reach admitted limits. Own the imminent required rollover rather than discard/shorten accepted history. Admit only one actual archive and its exact manifest growth plus this sole indexed ADR overhead under ADR0128/0129/0131 engineering precedent; no future reserve or new director grant. Preserve279 current AST-call inputs at clean9085eb1e5 before bound writes; no old measurement/hash refresh. Resume .3.1.3.2 only after canonical clean commit.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.4 - admit finite guarded AST history capacity`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.4`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.4`
  Status: `done` / focused-signoff-complete; normal doctrine hooks govern landing (activated from clean `049e1ba537f2bde635b2c0fed31fe83f6b3c129b`)
  Goal: Isolate main method/value required dependencies with native eager/lazy acquisition, alias and controlled caller-path proof.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.3`
  Verification tier: `focused`
  Focused checks: Refine every eager/lazy required role and actual invocation before production writes. Preserve eager CODE validation before undefined-input guard, locally validated-only inference, lazy initializer and key re-acquisition, actual callbacks/maps/spans/returned arrays, local copies versus shared source/argument slots, native contexts/effects/errors/fatal objects and opaque/known publication separation. Explicit secondary controls and original/current full native observations bound representative actual owner paths, AST/legacy bridge and recursive/local adapters without complete helper/language admission. Retain identical complete TAP, effective syntax-valid source faults, supplied46/166 consumer seed plus bounded fixtures, original291-input preservation with actual corruption RED/restoration, evidence controls, complete recursive-include book, standard syntax/public Phase0 and ordinary doctrines/history/memory/diff. Split before writes if actual scope exceeds a safe slice.
  Canonical trigger: None for a bounded private required resolver. Complete helper/AST/language, optional/direct, output/mapped/full-private/parent and final push admissions stay independent.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.4.json`
  Acceptance: Preserve all291 current inputs at clean049e1ba53 before bound writes; retain every old proof/hash field without refresh. Change only the selected required resolver seam after native proof. Preserve actual callback selection, acquisition/guard order, native argument aliases/copies/results and exact diagnostics. Commit before .3.1.5; no independent parent admission inferred.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.4 - isolate main method value required callbacks`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.4`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5`
  Status: `done` / routing children verified; original independent admission open
  Goal: Scalar/return/mutation helpers required dependency boundaries; split further before writes if needed.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.4`
  Acceptance: Preserve actual public references and native behavior. Commit each bounded family before advancing; no independent parent admission inferred.
  Children: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.0`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.1`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.2`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3`.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.5`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.0`
  Status: `done` / focused-signoff-complete; normal doctrine hooks govern landing (activated from clean `4b48593b59acb7aba4d616ae1bdc4320fbbf5364`)
  Goal: Isolate required bare-source and mutation-slot callbacks while preserving eager validation, native local copies, source classification and secondary fallback order.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.4`
  Verification tier: `focused`
  Focused checks: Preserve299 original live inputs before bound writes. Refine all actual required roles, eager validation before undefined input, local expression copies, actual callbacks/maps, scalar contexts/effects/errors/fatal objects and opaque/known publication separation. Bare/reserved/retired/source-kind guards and mutation bare/primitive/flow/method fallback have explicit secondary controls. Retain identical original/current TAP/native observations, effective syntax-valid faults, supplied48/168 seed plus bounded fixtures, actual original-binding/evidence corruptions/restoration, full recursive-include book, required syntax/public Phase0 and ordinary doctrines/history/memory/diff. Split further before production writes if needed.
  Canonical trigger: None for two bounded private required resolver returns; complete helper/AST/language, optional/direct/output/mapped/full-private/parent and final push admissions remain independent.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.0.json`
  Acceptance: Freeze all299 current identities at clean4b48593b5 and retain every old proof/hash field. Preserve native role/guard/callback selection and actual aliases/results before changing only the two required returns. Commit before .5.1.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.0 - isolate bare mutation required callbacks`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.0`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.1`
  Status: `done` / focused-signoff-complete (activated from clean `2c5f84092d91c808ab82b4b886b51e65fc1ac864`)
  Goal: Generalized return payload/statement required callbacks; refine/split before writes if needed.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.0`
  Verification tier: `focused`
  Focused checks: Preserve307 original live bindings before bound writes. Native payload trim validates after the undefined-input guard; statement parser validates before AST fast path and label trim is lazy. Refine actual source copies versus parser-array slots, AST/method/bare/raw fallback and stabilization bound, lazy label/multiple payload guards, actual callback/maps/references, scalar contexts/effects/errors/fatal objects and opaque/known child publication. Retain identical complete native/TAP populations, effective source faults, supplied50/170 seed plus bounded fixtures, original-binding/evidence corruptions/restoration, whole recursive-include book, required syntax/public Phase0 and normal doctrines/history/memory/diff. Split before production writes if this exceeds a safe slice.
  Canonical trigger: None for two bounded private required resolver returns. Complete helper/AST/language, optional/direct/output/mapped/full-private/parent and final push admissions remain independent.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.1.json`
  Acceptance: Preserve native caller behavior, commit before the next child and infer no separate parent admission.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.1 - isolate generalized return required callbacks`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.1`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.2`
  Status: `done` / bounded three-resolver required proof verified
  Goal: Assignment wrapper/scalar operator/array append required callbacks; refine/split before writes if needed.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.1`
  Verification tier: `focused`
  Focused checks: Preserve306 accepted generalized-return bindings before bound writes. Establish actual assignment trim/extractor/source/initializer acquisition and invocation paths, initializer kind-literal readonly versus source copies, scalar/append trim once-or-twice behavior, AST/regex/empty/zero/fallback order, public maps, native context/error/fatal/reference effects and known/opaque publication. Hold secondary AST/value/tracked/push/migration helpers at explicit controls; preserve optional kind selection and distinguish private legacy wrapper paths from current public selector rejection. Retain complete native-current/TAP populations, effective source faults, supplied52/172 seed plus bounded fixtures, original-binding/evidence restoration, full recursive book, required syntax/public Phase0 and normal memory/Knowledge/history/claim/doctrine/diff proof. Refine/split before production edits if needed.
  Canonical trigger: none for bounded private required resolver returns; complete helper/AST/language, optional/direct, output/mapped/full-private and independent admissions remain open.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.2.json`
  Acceptance: Preserve native caller behavior, commit before the next child and infer no separate parent admission.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.2 - isolate assignment required callbacks`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.2`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3`
  Status: `done` / all three bounded routing children verified; no broader admission
  Goal: Remaining helper statement required callbacks; preserve independent native selection and alias proof.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.2`
  Claim verification: none: Routing/refinement only; each child owns its actual measurement.
  Children: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.0`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.1`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.2`.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.0`
  Status: `done` / bounded one-resolver set-key proof verified
  Goal: Isolate required set-key dependencies without changing eager validation or actual normalized argument slots.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.2`
  Verification tier: `focused`
  Focused checks: Preserve all300 accepted assignment bindings before bound writes. Establish five eager roles before AST fast path, actual parser/normalizer arrays and literal arities, three trim slots and shared local target/key slots, scalar context/error/fatal/reference/effect/public-map contracts. Bound AST/mutation/uniform target/index helpers explicitly. Retain native-current ledgers, identical original/current TAP, effective source faults, supplied54/174 seed plus bounded fixtures, evidence/original-binding restoration, full recursive book and required syntax/public Phase0 compatibility; normal memory/Knowledge/history/claim/doctrine/diff checks govern landing.
  Canonical trigger: none for one private required resolver return; optional/direct, complete helper/AST/language, mapped/output/full-private and independent canonical admissions stay separate.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.0.json`
  Acceptance: Native selection, argument slots and outcomes preserved; commit before push child.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.0 - isolate set-key required callbacks`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.0`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.1`
  Status: `done` / bounded one-resolver push proof verified
  Goal: Isolate required push callbacks while preserving child-call precedence and repeated raw/effective argument handling.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.0`
  Verification tier: `focused`
  Focused checks: Actual parser/extractor/trim/primitive roles; two/three/other arity and ambiguous/bare/typed target branches, actual raw versus effective array slots and repeated trim effects, contexts/errors/maps/results, source faults/consumers/book/required public compatibility.
  Canonical trigger: none for bounded private resolver; independent admissions remain open.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.1.json`
  Acceptance: Commit verified child before regex/undefined-return child; no child-call or public-language expansion.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.1 - isolate push required callbacks`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.1`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.2`
  Status: `done` / bounded two-resolver proof verified
  Goal: Isolate regex-substitution and undefined-return required callbacks with native literal/flags and parser/normalizer guards.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.1`
  Verification tier: `focused`
  Focused checks: Actual eager extractor/strip/trim and parser/normalizer acquisition, copied pattern/replacement/flags including default temporary, actual arity array/literals, native contexts/errors/maps/results, source faults/consumers/book/required public compatibility. Existing quoted-flags/callback/receiver defects remain owned by SESSION-STARTUP-READING.59; this required capture scope does not admit their repair.
  Canonical trigger: none for bounded private resolvers; independent admissions remain open.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.2.json`
  Acceptance: Commit verified child and close routing parent before receiver/parser required .3.1.6; no broader parent admission inferred.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.2 - isolate regex and undefined-return callbacks`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.2`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6`
  Status: `done` / bounded routing children verified; original independent admission remains open
  Goal: Receiver/parser helpers required dependency boundaries; split further before writes if needed.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3`
  Acceptance: Preserve actual public references and native behavior. Commit each bounded family before advancing; no independent parent admission inferred.
  Children: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.1`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.3`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.4`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.5`.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.6`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0`
  Status: `done` / both distinct correctness children verified
  Goal: Repair scalar-held hash single-step receiver-copy type loss and the separate legacy hash kind-callback failure before required receiver capture.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.2`
  Claim verification: none: Routing/refinement only; children own actual measured acceptance.
  Children: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.0`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.1`.
  Acceptance: Each child must fix and verify its own mechanism and commit before the next; preserve existing multi-step and aggregate receiver behavior. No broader factory admission.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.0`
  Status: `done` / composed focused proof verified; exact canonical receipt governs landing
  Goal: Preserve the runtime container type when a scalar-held binding is copied with receiver .copy().
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.2`
  Verification tier: `canonical`
  Focused checks: Preserve all307 accepted regex/undefined-return inputs before bound writes. Retain identical original/current public regression with explicit shape, empty/container snapshot and array/hash/legacy aggregate controls; prove typed AST fields instead of source text and existing function-form behavior. Retain complete input-bound channels, effective source faults and unchanged supplied60/182 seed consumers plus new regression. Full recursive book, original-binding restoration and ordinary memory/Knowledge/history/claim/diff checks; canonical tracked-input/syntax/execution selection, exact historical CI inverse/native RED/full192 inputs/22 recovery/74 evolution/evidence3 and one-shot publication extension are required.
  Canonical trigger: P1 public value correctness repair and its canonical regression wiring; exact staged canonical receipt required before ordinary hooks/commit.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.0.json`
  Acceptance: Fix the confirmed scalar-held hash loss without changing single-step array snapshots, legacy aggregate bindings or multi-step chain selection. Split further before widening to other receiver populations. Commit before the distinct legacy callback child.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.0 - preserve scalar-bound receiver copy types`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.0`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.1`
  Status: `done` / `focused-signoff-complete` P2 private legacy hash kind callback (activated from clean `770cffcccea44df8d0e578ed68ad6f9a4b5e0b0e`)
  Goal: Select the injected bare_symbol_kind callback or documented undefined default locally in legacy hash normalization; preserve actual aliases/context/effects and private authority.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.0`
  Verification tier: `focused`
  Focused checks: Preserve all546 predecessor live inputs before bound writes. Retain first native observations and paired regression RED/GREEN; distinguish injected/default selection from unrelated package state. Cover explicit container and lookahead branches, guards/arity, readonly match aliases, scalar context/effects/errors/fatal identity, selection timing/public maps and opaque/known publication separation. Run effective source faults, exact supplied consumers, evidence/original-binding corruption controls, full recursive-include book, required Perl syntax/public Phase0, history/memory/Knowledge/whitespace and normal doctrines.
  Canonical trigger: none for bounded private fallback selection; escalate before any new public/API/format or mechanical-owner effect.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.1.json`
  Acceptance: Resolve the owned failure with actual selected callback/default and no package-state dependence; commit before required receiver children.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.1 - select legacy hash kind callback locally`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.1`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.1`
  Status: `done` / `focused-signoff-complete` (activated from clean `c90b99a831461e25adbc2b34d7da7d3deed11531`)
  Goal: Isolate array receiver required callbacks while preserving actual native behavior.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.1`
  Verification tier: `focused`
  Focused checks: Preserve all322 predecessor live inputs before bound writes. Retain first native required trim/parser observations before assertions or source edits; acquisition order, missing/non-CODE diagnostics, selection timing, splitter/receiver/method/arity/family guards, actual callback arguments and alias/write constraints, contexts/errors/fatal/maps/results. Paired RED/GREEN and effective source faults, exact supplied direct consumers, independent evidence/original-binding controls, full book render/recursive includes, required Perl syntax/public Phase0 and ordinary history/memory/Knowledge/whitespace/doctrines.
  Canonical trigger: none for bounded private required resolver capture; escalate before public/API/generated-format or mechanical-owner changes. Original independent admissions remain separate.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.1.json`
  Acceptance: Preserve accepted predecessor bindings before bound writes. Split before unsafe expansion; commit before the next bounded family.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.1 - isolate required array receiver callbacks`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.1`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2`
  Status: `done` / `focused-signoff-complete` (activated from clean `5bf068c924f190fdc7b9f904b9b9720cc638f2e9`)
  Goal: Isolate number/string receiver required callbacks while preserving actual native behavior.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.1`
  Verification tier: `focused`
  Focused checks: Preserve all314 predecessor live bindings before bound writes. Retain first native observations for both actual required trim/parser pairs before assertions or source changes, including eager validation, splitter aliases, parser selection, actual returned call-reference/source annotation, contexts/errors/fatal/maps and guards/arity/family transitions. Paired RED/GREEN, effective full-source faults, supplied direct consumers, independent evidence/original-binding controls, recursive-include book rendering, standard Perl syntax/public Phase0 and ordinary history/memory/Knowledge/whitespace/doctrines.
  Canonical trigger: none for bounded private required resolver capture; reclassify before public/generated/mechanical changes. Existing independent admissions and scheduled canonical registration .7 remain separate.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2.json`
  Acceptance: Preserve accepted predecessor bindings before bound writes. Split before unsafe expansion; commit before the next bounded family.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2 - isolate number/string required callbacks`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6`
  Status: `done` / canonical-admitted at d95a25c8b
  Goal: Admit only the next measured engineering-notes rollover before further required receiver commits.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2`
  Children: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6.1` owns the subsequently discovered readonly-command repair.
  Verification tier: `canonical`
  Focused checks: Preserve predecessor live claim bindings before bound writes; retain actual next-record rollover pressure and existing admission RED. Independently reconstruct the exact clean-Git suffix/blob/range/digest and lossless root/manifest, all prior immutable bytes, finite registry/decision overhead, unchanged production threshold/accepted-indexed-object authority and actual reason-sensitive evidence RED/restorations. Required ordinary doctrines/history/Knowledge/memory/diff and exact staged canonical CI/receipt.
  Canonical trigger: Documentation/storage/registry infrastructure changes require exact staged canonical admission before landing.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6.json`
  Acceptance: Follow the established finite maintenance authority and ADR0131 precedent; no user decision or new runtime scope is inferred. Do not rewrite accepted immutable archives. Commit the exact canonical prerequisite before hash .3.1.6.3.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6 - admit one finite engineering-history member`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6.1`
  Status: `done` / `focused-signoff-complete`
  Goal: Repair ADR0133's stale readonly review command while preserving accepted finite-admission evidence.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6`
  Verification tier: `focused`
  Focused checks: Enumerate all live claims intersecting intended writes and preserve every accepted binding before edits. Retain the actual stale-command failure and current guarded baseline, replay the accepted publication in its original Git input state, independently reconstruct the sole ADR pointer correction and related guidance, exercise distinguishing actual RED/restoration controls, render the book, and run ordinary doctrines/history/Knowledge/memory/whitespace checks.
  Canonical trigger: none for a documentation-command correction with unchanged infrastructure, capacity authorization and runtime; the predecessor's exact canonical receipt remains historical.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6.1.json`
  Acceptance: Keep the full accepted predecessor claim and original hashes/producer/input state recoverable; do not refresh old observations or silently repoint a command to another historical-only instrument. The new current reviewer must work against the final current documents. Commit before required hash .3.1.6.3.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6.1 - repair the current admission review command`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6.1`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.3`
  Status: `done` / focused proof verified; normal hooks govern landing
  Goal: Isolate hash receiver required callbacks while preserving actual native behavior.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6.1`
  Verification tier: `focused`
  Focused checks: Preserve every intersecting live claim before bound writes. Retain actual native acquisition order/required role inventory, source and caller guards, aliases/context/error/fatal/maps/results and shared returned references; complete native/current ledgers, identical paired RED/GREEN, effective whole-source faults, path-complete supplied consumers, actual evidence controls/book and standard syntax/public Phase0. Ordinary doctrine/history/Knowledge/memory/whitespace checks and normal hooks govern landing.
  Canonical trigger: none for bounded private required-resolver capture; optional/direct, independent admissions and canonical fixture registration .7 remain separately owned.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.3.json`
  Acceptance: Preserve accepted predecessor bindings before bound writes. Split before unsafe expansion; commit before the next bounded family.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.3 - isolate required hash receiver callbacks`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.3`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.4`
  Status: `done` / focused proof verified; normal hooks govern landing
  Goal: Isolate array-end parser required callbacks while preserving actual native behavior.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.3`
  Verification tier: `focused`
  Focused checks: Actual acquisition order and invoked-role inventory, helper/AST controls and caller guards, aliases/context/error/fatal/maps/results; complete native/current ledgers, paired RED/GREEN, effective faults and supplied consumers/book.
  Canonical trigger: none for bounded private resolver capture; original independent admissions remain separate.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.4.json`
  Acceptance: Preserve accepted predecessor bindings before bound writes. Split before unsafe expansion; commit before the next bounded family.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.4 - isolate required array-end parser callbacks`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.4`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7`
  Status: `done` / canonical-admitted at557a7d9e5
  Goal: Admit only the next measured change-history rollover before required hash-index callbacks.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.4`
  Verification tier: `canonical`
  Focused checks: Preserve every intersecting live claim before governed writes; actual next-record pressure and old admission REDs; independent whole-suffix/root/manifest/registry/decision reconstruction, immutable census, unchanged production thresholds/accepted-indexed-object authority, reason-sensitive reviewer/preservation REDs with restoration, complete book, normal doctrines/history/Knowledge/memory/diff.
  Canonical trigger: Storage/registry infrastructure requires exact staged canonical CI and receipt before landing.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7.json`
  Acceptance: Admit exactly one archive slot and measured manifest/sole decision overhead, leaving root/per-file/aggregate controls and all unrelated fields exact. Preserve all accepted history and original proof fields. Commit before .5.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7 - admit one finite change-history member`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.5`
  Status: `done` / focused proof verified; normal hooks govern landing
  Goal: Isolate hash-index parser/lowerer required callbacks while preserving actual native behavior.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7`
  Verification tier: `focused`
  Focused checks: Actual acquisition order and invoked-role inventory, helper/AST controls and caller guards, aliases/context/error/fatal/maps/results; complete native/current ledgers, paired RED/GREEN, effective faults and supplied consumers/book; standard public Phase0 and ordinary doctrine/history/Knowledge/memory checks.
  Canonical trigger: none for bounded private resolver capture; original independent admissions remain separate.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.5.json`
  Acceptance: Preserve accepted predecessor bindings before bound writes. Split before unsafe expansion; commit before the next bounded family.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.5 - isolate required hash-index callbacks`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.5`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.2`
  Status: `active` / package-flow child first
  Goal: Isolate MethodLowering optional and direct injected callback calls; split function families before writes as needed.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6`
  Owned paths: `perl/LinkedSpec/ActionIR/MethodLowering.pm` optional/direct callback calls; focused proof/claim, Knowledge/book/continuity.
  Planned tier: `focused`
  Planned focused proof: Actual opaque dependency boundaries, native contexts/aliases/effects/errors/public maps and retained source-bound controls/consumers.
  Planned canonical boundary: none for bounded private implementation; complete private Phase0 and canonical admission stay with original owners.
  Planned claim record: none: Planning only; declare measurement at activation.
  Acceptance: Preserve native behavior and actual public references; commit before FlowExpr. No separate parent admission inferred.
  Children: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.0`, `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1`.
  Owned issue: P2 private-protocol gap in _lower_mutation_slot_value_expr: the optional flow branch reads package variable $LinkedSpec::ActionIR::MethodLowering::lower_flow_composite_expr rather than acquiring a map callback. Toolbox call_spec_handler_subst('Top', 'items += and(true,false)') uses the normal RuntimeLogical expression with no package override; localizing that package variable to a callback returning FLOW_OVERRIDE produces BindingRuntime::push_value(..., FLOW_OVERRIDE) and invokes it once. This is an actual reachable legacy direct callback, not a missing required-role acquisition. Preserve its native selection/behavior and isolate its publication under .3.2.0; do not silently replace it with a new map dependency or infer an authored-language failure. Retain a supplied native probe before the current required edits.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.0`
  Status: `done` / `focused-signoff-complete`
  Goal: Isolate the reachable legacy mutation package-flow direct callback while preserving its actual callback selection, context, arguments, ordinary value/effects/errors and public behavior.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6`
  Verification tier: `focused`
  Focused checks: Reuse the original4b48593b5 Toolbox diagnosis with its exact historical inputs; independently reproduce opaque/known packet isolation and actual callback identity, native selection versus an unrelated map callback, undefined/equal/empty/zero/fatal branches, actual trimmed-slot aliases/effects/errors/results/maps, cold laziness, source/input/evidence controls, complete supplied consumers/book and standard syntax/public Phase0. Ordinary doctrine/history/Knowledge/memory checks govern landing.
  Canonical trigger: none for one private call binding that preserves native behavior; reclassify before any public dependency/API/format change.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.0.json`
  Acceptance: Resolve this owned P2 boundary before remaining optional families. Preserve the existing package callback rather than inventing new map semantics. Commit before .3.2.1; complete helper/language and parent admissions remain separate.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.0 - isolate package-flow callback`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.2.0`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1`
  Status: `active`
  Goal: Remaining MethodLowering optional/direct dependency families; refine and split actual callers before writes.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.0`
  Owned paths: All remaining MethodLowering optional/direct calls, bounded proof/claim, Knowledge/book/continuity. Accepted required-resolver and package-flow proofs retain their earlier owners; the newly diagnosed inline-required direct call belongs to child .3.2.1.1.
  Planned tier: `focused`
  Planned focused proof: Actual native/public callback identities, contexts/aliases/effects/errors and opaque publication isolation; retained source faults/consumers, input/evidence controls, book and standard compatibility.
  Planned canonical boundary: none for bounded private implementation; original independent admissions remain open.
  Planned claim record: none: Planning only; declare measurements at activation.
  Acceptance: Commit each bounded family before FlowExpr and infer no separate parent admission.

  Children: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.0` through `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.8`, plus discovered repairs `.3.2.1.11` and `.3.2.1.12`, and deferred metadata QA `.3.2.1.13`; inventory precedes eight independently committed implementation families. Discovered native container-cache guard repair .3.2.1.9 follows .2 before .3 and does not add an original inventory ingress site. Readonly accepted-claim census repair .3.2.1.10 follows due hygiene before .9; it adds no runtime ingress site. FlowExpr depends on the completed bounded .11 handoff; the aggregate remains open without a separate parent admission. P3 metadata projection .12 follows pipeline .6 and therefore does not block that runtime sequence.


- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.0`
  Status: `done` / focused static inventory
  Goal: Produce the exact remaining MethodLowering optional/direct callback inventory and split bounded implementation families before production writes.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.0`
  Verification tier: `focused`
  Focused checks: Preserve every intersecting live binding/full accepted publication and actual readonly baseline before bound documentation writes. Retain first compiled/source observations before census assertions; independently reconstruct actual variable-call and already-bound/required/optional/direct classifications, source identities and complete populations. Exercise syntax-valid omission/addition/binding and reason-sensitive artifact controls, full book rendering and unchanged accepted production/consumer input hashes. This documentation/diagnostic inventory changes no action-rewriter runtime; reuse accepted .3.2.0 standard compatibility without claiming new runtime admission. Ordinary doctrine/history/Knowledge/memory/whitespace checks govern landing.
  Canonical trigger: none for read-only source inventory and documentation; reclassify before runtime/public/API/format or mechanical infrastructure writes.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.0.json`
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.0 - inventory remaining callback ingress`
  Acceptance: Every actual remaining caller is assigned to a bounded child with its native selection/context/alias/result/error requirements before implementation; current production and accepted runtime artifacts stay byte-identical. Commit this inventory before activating the first family. No complete helper/language/private/parent/canonical admission follows from a static or compiled census.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.0`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.1`
  Status: `done`
  Goal: Isolate the inline-validated required trim call in _lower_dropped_value_statement, preserving actual selection, guards, aliases, diagnostics, AST/method fallbacks and values/errors.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.0`
  Verification tier: `focused`
  Focused checks: Preserve every intersecting live binding/full publication and actual readonly baseline first. Retain original required callback/native caller selection, actual local argument/reference aliases, scalar context/effect/error/fatal identities and full input/CODE/AST/unknown-helper/lowered/fallback guard population before assertions/source changes. Check original two-row gap diagnosis, actual map selection/replacement and cold laziness; identical paired RED/GREEN, effective syntax-valid full-source faults, complete supplied direct consumers, reason-sensitive evidence controls, complete book and both syntax/public Phase0 standard compatibility. Normal doctrine/history/Knowledge/memory/whitespace hooks govern landing.
  Canonical trigger: none for one bounded private required invocation; public/API/format/infrastructure movement requires reclassification, while independent helper/private/parent/canonical admissions remain separate.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.1.json`
  Acceptance: Resolve the diagnosed P2 direct-required boundary first, before optional kind/predicate/formal families, and commit before moving on. Keep every original inventory observation intact.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.1 - isolate dropped-value trim`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.1`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2`
  Status: `done`
  Goal: Isolate small optional kind callbacks with a private emission boundary.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.1`
  Verification tier: `focused`
  Focused checks: Preserve intersecting accepted bindings/full record and actual baseline first. Retain native selection/contexts/aliases/maps/values/effects/errors/fatal and cold observations before assertions/production edits; identical distinguishing RED/GREEN, effective full-source faults, complete supplied consumers and evidence controls, full book and standard compatibility. Register the resulting fixtures later under .7.
  Canonical trigger: none for bounded private dependency bindings; escalate before public/API/format/mechanical changes. Independent full-private/parent/canonical admissions remain open.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2.json`
  Acceptance: Commit only this family before selecting the next. Update the book's remaining-site explanation accurately. Every encountered defect is owned; split further before writes if the family grows beyond a safe slice.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2 - isolate three optional kind callbacks`; normal focused doctrine/memory/whitespace hooks govern landing from clean61cca1ccc. No push. First clean boundary activates due daily hygiene, then P2 container-cache .9 before .3.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.3`
  Status: `done`
  Goal: Isolate giant method optional kind callbacks with a private emission boundary.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.9`
  Verification tier: `focused`
  Focused checks: Preserve intersecting accepted bindings/full record and actual baseline first. Retain native selection/contexts/aliases/maps/values/effects/errors/fatal and cold observations before assertions/production edits; identical distinguishing RED/GREEN, effective full-source faults, complete supplied consumers and evidence controls, full book and standard compatibility. Register the resulting fixtures later under .7.
  Canonical trigger: none for bounded private dependency bindings; escalate before public/API/format/mechanical changes. Independent full-private/parent/canonical admissions remain open.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.3.json`
  Acceptance: Commit only this family before selecting the next. Update the book's remaining-site explanation accurately. Every encountered defect is owned; split further before writes if the family grows beyond a safe slice.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.3 - isolate main method kind callbacks`; normal focused all10 doctrines, explicit memory, both bounded histories and whitespace govern landing from clean61a73324. Clear brief/post-pointer/post-memory/clean Git before activating .4. No push.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.3`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.4`
  Status: `done`
  Goal: Isolate source and assignment optional kind callbacks with a private emission boundary.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.3`
  Verification tier: `focused`
  Focused checks: Preserve intersecting accepted bindings/full record and actual baseline first. Retain native selection/contexts/aliases/maps/values/effects/errors/fatal and cold observations before assertions/production edits; identical distinguishing RED/GREEN, effective full-source faults, complete supplied consumers and evidence controls, full book and standard compatibility. Register the resulting fixtures later under .7.
  Canonical trigger: none for bounded private dependency bindings; escalate before public/API/format/mechanical changes. Independent full-private/parent/canonical admissions remain open.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.4.json`
  Acceptance: Commit only this family before selecting the next. Update the book's remaining-site explanation accurately. Every encountered defect is owned; split further before writes if the family grows beyond a safe slice.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.4 - isolate source and assignment kind callbacks`; ordinary focused normal all10 doctrines, explicit memory, both bounded histories and whitespace govern landing from clean dd82f9cb. Clear brief/post-pointer/post-memory/clean before .5; no push.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.4`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.5`
  Status: `done`
  Goal: Isolate optional AST dependency callbacks with a private emission boundary.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.4`
  Verification tier: `focused`
  Focused checks: Preserve intersecting accepted bindings/full record and actual baseline first. Retain native selection/contexts/aliases/maps/values/effects/errors/fatal and cold observations before assertions/production edits; identical distinguishing RED/GREEN, effective full-source faults, complete supplied consumers and evidence controls, full book and standard compatibility. Register the resulting fixtures later under .7.
  Canonical trigger: none for bounded private dependency bindings; escalate before public/API/format/mechanical changes. Independent full-private/parent/canonical admissions remain open.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.5.json`
  Acceptance: Commit only this family before selecting the next. Update the book's remaining-site explanation accurately. Every encountered defect is owned; split further before writes if the family grows beyond a safe slice.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.5 - isolate optional AST callbacks`; ordinary focused normal all10 doctrines, explicit memory, both histories and whitespace govern landing from clean15197dfd. Clear brief/post-pointer/post-memory/clean before .6; no push.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.5`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.6`
  Status: `done`
  Goal: Isolate mutation and write predicates with a private emission boundary.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.5`
  Verification tier: `focused`
  Focused checks: Preserve intersecting accepted bindings/full record and actual baseline first. Retain native selection/contexts/aliases/maps/values/effects/errors/fatal and cold observations before assertions/production edits; identical distinguishing RED/GREEN, effective full-source faults, complete supplied consumers and evidence controls, full book and standard compatibility. Register the resulting fixtures later under .7.
  Canonical trigger: none for bounded private dependency bindings; escalate before public/API/format/mechanical changes. Independent full-private/parent/canonical admissions remain open.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.6.json`
  Acceptance: Commit only this family before selecting the next. Update the book's remaining-site explanation accurately. Every encountered defect is owned; split further before writes if the family grows beyond a safe slice.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.6 - isolate tracking predicate callbacks`; focused normal all10 doctrines, explicit memory, both history checks and whitespace govern landing from clean99f2939ac. Clear brief and verify post-pointer/post-memory/clean Git before .7; no push.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.6`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.7`
  Status: `done`
  Goal: Isolate formal trim callback boundaries with a private emission boundary.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.6`
  Verification tier: `focused`
  Focused checks: Preserve intersecting accepted bindings/full record and actual baseline first. Retain native selection/contexts/aliases/maps/values/effects/errors/fatal and cold observations before assertions/production edits; identical distinguishing RED/GREEN, effective full-source faults, complete supplied consumers and evidence controls, full book and standard compatibility. Register the resulting fixtures later under .7.
  Canonical trigger: none for bounded private dependency bindings; escalate before public/API/format/mechanical changes. Independent full-private/parent/canonical admissions remain open.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.7.json`
  Acceptance: Commit only this family before selecting the next. Update the book's remaining-site explanation accurately. Every encountered defect is owned; split further before writes if the family grows beyond a safe slice.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.7 - isolate formal trim callback calls`; focused normal all10 doctrines, explicit memory, both history checks and whitespace govern landing from cleanb1133da42. Clear brief and verify post-pointer/post-memory/clean Git before .8; no push.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.7`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.8`
  Status: `done`
  Goal: Isolate selected named-helper CODE dispatch with a private emission boundary.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.7`
  Verification tier: `focused`
  Focused checks: Preserve intersecting accepted bindings/full record and actual baseline first. Retain native selection/contexts/aliases/maps/values/effects/errors/fatal and cold observations before assertions/production edits; identical distinguishing RED/GREEN, effective full-source faults, complete supplied consumers and evidence controls, full book and standard compatibility. Register the resulting fixtures later under .7.
  Canonical trigger: none for bounded private dependency bindings; escalate before public/API/format/mechanical changes. Independent full-private/parent/canonical admissions remain open.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.8.json`
  Acceptance: Commit only this family before selecting the next. Update the book's remaining-site explanation accurately. Every encountered defect is owned; split further before writes if the family grows beyond a safe slice.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.8 - isolate selected named-helper dispatch`; focused normal all10 doctrines, explicit memory, both history checks and whitespace govern landing from clean22132b2b. Clear brief and verify post-pointer/post-memory/clean Git before .11; no push.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.8`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.9`
  Status: `done` / P2 native container-regex cache repair
  Goal: Make uniform binding target recognition honor the current container argument on every invocation, independent of the first array/hash call in the process.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.10`
  Verification tier: `focused`
  Focused checks: Preserve intersecting accepted claims/full records and actual baseline first; keep first order-dependent observations, verify both first-container orders plus current/empty/mismatched container arguments, retain paired RED/GREEN and source inverse, inspect actual emitted/public behavior, run direct consumers/book and standard syntax/public Phase0, then normal doctrines.
  Canonical trigger: none for a bounded implementation repair of the existing container contract; reclassify before public/API/format/mechanical changes.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.9.json`
  Acceptance: Verify a current-argument decision without changing optional callback selection/identity/aliases. Commit before resuming .3; full-helper/parent/canonical admissions remain separate.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.9 - honor current target container`; normal focused all10 doctrines, explicit memory architecture, both bounded histories and whitespace govern landing from cleande02b83a1. Clear brief/post-pointer/post-memory/clean Git before giant kind .3. No push; complete canonical fixture registration stays owned by root .7 before pipeline .6.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.9`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.4`
  Status: `active` / bounded implementation children
  Goal: Actual default callbacks and flow-composite injected dependency boundaries, preserving native effects and arguments.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11`
  Children: `PERL-PRIVATE-FACTORY-CAPTURE.4.0`, `PERL-PRIVATE-FACTORY-CAPTURE.4.2`, `PERL-PRIVATE-FACTORY-CAPTURE.4.1`.
  Owned paths: FlowExpr injected bindings and defaults; EmitContext's definition-owned FlowExpr callback selection prerequisite; focused proofs/claims, relevant Knowledge/book and continuity. No unrelated producer, mapping, dispatch or pipeline change.
  Split rationale: Isolate required callbacks, separately preserve the optional two-read kind selection, then register actual native defaults. FlowExpr's defaults overlap the existing method/contract catalogues but need their own exact definition-owned population; callback names or the union of unrelated catalogues cannot select FlowExpr authority. Keep each child independently reviewable and committed before the next.
  Planned tier: `focused`
  Planned focused proof: Native contexts/aliases/effects/errors, actual callback identity and separate publication; exact default map/reference and native/custom/replacement selection, cold loading/lifetime, effective source faults, complete supplied consumers and independent artifact/book controls. Run the composed public selector guard when compiler teaching or synthetic native sources change.
  Planned canonical boundary: none for bounded private implementation; reclassify before a public/generated/mechanical change. Complete private/parent/pipeline admissions retain their existing owners.
  Planned claim record: none: Parent planning only; measured claims belong to implementation children.
  Acceptance: After accepted .4.1, ControlFlow follows that bounded child. No separate parent admission is inferred.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.4.0`
  Status: `done` / `focused-signoff-complete` (activated from clean `81b356cef997ea2bb65a8fb120c77506fed9241e`)
  Goal: Give each required injected FlowExpr callback its own private invocation boundary while preserving native helper behavior.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11`
  Verification tier: `focused`
  Focused checks: Preserve all intersecting accepted bindings/full records and actual readonly baseline before bound writes, including KNOWLEDGE_MAP.md and both roadmaps. Capture native callbacks/contexts/arguments/aliases/maps/values/effects/errors/fatal behavior before expectations or source edits; retain identical distinguishing RED/GREEN, effective full-source faults, complete supplied direct consumers and evidence controls, full book and composed public selector guard, standard Perl syntax/Phase0 and ordinary doctrines.
  Canonical trigger: none for bounded private invocation bindings without public/API/format/mechanical changes; escalate before crossing those boundaries. Complete private/parent admission remains separate.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.4.0.json`
  Acceptance: Preserve required validation and selection order, actual CODE identity, original local copies and shared references, scalar/list/void behavior, callback effects/error identity and cold loading. Public maps retain actual callbacks; no child publication is implicitly lent to a parent. Commit before .4.2.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.4.0 - isolate required FlowExpr callbacks`; ordinary focused all10 doctrines, explicit memory architecture, both bounded histories, composed public selector guard and whitespace govern landing from clean81b356ce. Clear brief/post-pointer/post-memory/clean Git before activating .4.2; no push.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.4.0`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.4.2`
  Status: `done` / `focused-signoff-complete` (activated from clean `708c1afa04bb10aeacbdaf0a8133a95f380df434`)
  Goal: Isolate both optional kind invocations in FlowExpr emptiness lowering while preserving the original two-read selection and native callable/error behavior.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.4.0`
  Verification tier: `focused`
  Focused checks: Preserve intersecting claims, retain first native ordinary/tied-map observations before assertions/source edits, actual CODE identity versus opaque non-CODE callable/error behavior, both wrapped-container branches/guards, two fetches and local selection, aliases/coercions/effects/errors/fatal/cold contexts; exact full-source faults, complete supplied consumers, evidence/book and composed public guard.
  Canonical trigger: none for bounded private invocation changes; escalate before public/generated/mechanical changes. Complete private/parent admission remains open.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.4.2.json`
  Acceptance: Preserve original fetch order, native invocation locations and error identity. Keep actual CODE references selected independently from opaque caller-local invokers. Commit before .4.1.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.4.2 - isolate optional FlowExpr kind calls`; normal focused all10 doctrines, explicit memory architecture, both histories and whitespace govern landing. Clear brief, verify post-pointer/post-memory and clean Git before .4.1. No push.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.4.2`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.4.1`
  Status: `done` / `focused-signoff-complete` (activated from clean `98f8d5d7fabdc9b1ac074ca0d8f3c53d218c8ccb`)
  Goal: Select actual definition-owned FlowExpr default callbacks in their current source/producer scope, preserving the exact public factory result.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.4.2`
  Verification tier: `focused`
  Focused checks: Preserve intersecting claims first; actual full native default map/reference population, same-name replacement/custom target/copied metadata and retained native references, nested source/producer scopes, restoration/release/error/cold behavior; distinguishing original RED/GREEN and source faults, complete supplied consumers, evidence/book controls and composed public guard.
  Canonical trigger: none for bounded actual-reference selection; escalate before public/generated/mechanical changes. Independent private/parent/pipeline admissions remain open.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.4.1.json`
  Acceptance: Register only actual definition-owned FlowExpr references through the built-in target; public map/callback identities remain exact. Commit before ControlFlow .5; no parent closeout inferred.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.4.1 - select exact native FlowExpr defaults`; normal focused all10 doctrines, explicit memory architecture, both bounded histories and whitespace govern landing. Clear brief, verify post-pointer/post-memory and clean Git before ControlFlow .5. No push.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.4.1`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.5`
  Status: `active` / bounded implementation children; independent admission open
  Goal: Actual default callbacks and separate ControlFlow dependency invocations, preserving native contexts/maps/AST/control semantics.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.4.1`
  Children: `PERL-PRIVATE-FACTORY-CAPTURE.5.0`, `PERL-PRIVATE-FACTORY-CAPTURE.5.1`, `PERL-PRIVATE-FACTORY-CAPTURE.5.2`, `PERL-PRIVATE-FACTORY-CAPTURE.5.3`, `PERL-PRIVATE-FACTORY-CAPTURE.5.4`, `PERL-PRIVATE-FACTORY-CAPTURE.5.5`, `PERL-PRIVATE-FACTORY-CAPTURE.5.6`, `PERL-PRIVATE-FACTORY-CAPTURE.5.7`, `PERL-PRIVATE-FACTORY-CAPTURE.5.8`.
  Owned paths: ControlFlow; exact mixed-provider definition-owned default prerequisites only when their bounded child activates; focused proof/Knowledge/book/continuity. No OwnerDispatch or unrelated mapping change.
  Split rationale: Foundation, branch plumbing, if/while, switch and output required families precede optional kind, direct calls and mixed-provider defaults. Preserve original global diagnostic lines. The original parent is not independently admitted by child acceptance.
  Planned tier: `focused`
  Planned focused proof: Native-first actual reference/context/alias/error observations, original distinguishing RED/GREEN, effective source faults, complete supplied consumers, book/Knowledge/artifact controls and composed public guard.
  Planned canonical boundary: none for bounded private implementation; reclassify before public/generated/mechanical changes. Fixture selection .7 owns the later exact canonical boundary.
  Planned claim record: none: Child-specific source-bound claims own implementation measurements.
  Acceptance: Commit each bounded child before activating the next; .7 follows the final bounded .5.7 handoff. Complete helper/private/parent admission remains separate.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.5.0`
  Status: `done` / `focused-signoff-complete` (activated from clean `aa88233432976a019b41d05578f8e6a5f6e3c082`)
  Goal: Foundation value and bare-marker required callbacks.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.4.1`
  Verification tier: `focused`
  Focused checks: Preserve accepted449/full106177 and actual readonly baseline; first native observations before assertions/source edits, all native contexts/aliases/map selection/guards/effects/errors/fatal identities/cold loading; identical RED/GREEN and complete-source semantic faults; complete predecessor consumers plus new fixture, standard syntax/public Phase0, Knowledge/book/artifact controls and composed public guard.
  Canonical trigger: none for bounded private required bindings; escalate before public/generated/mechanical changes. Complete private/parent admission remains open.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.0.json`
  Acceptance: Preserve public maps/callback references and ordinary behavior. Actual identity carries only its own scope authority. Commit before the next child; no aggregate admission inferred.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.5.0`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.5.1`
  Status: `done` / all implementation children and finite prerequisite complete
  Goal: Isolate required branch expansion, attached parser and single-statement dependencies while preserving native AST/control contracts.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.5.0`
  Children: `PERL-PRIVATE-FACTORY-CAPTURE.5.1.0`, `PERL-PRIVATE-FACTORY-CAPTURE.5.1.1`, `PERL-PRIVATE-FACTORY-CAPTURE.5.1.2`; finite continuity prerequisite `PERL-PRIVATE-FACTORY-CAPTURE.5.1.3`.
  Acceptance: Commit each child before the next. .5.2 follows the .5.1.2 runtime handoff and finite .5.1.3 continuity prerequisite; no independent aggregate/private/parent admission inferred.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.5.1`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.5.1.0`
  Status: `done` / focused verified
  Goal: Branch expression expansion required callbacks.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.5.0`
  Verification tier: `focused`
  Focused checks: Preserve original428/full100775 and actual readonly baseline before all bound writes. First native scalar/list/void helper contexts, actual splitter/body/array references, aliases/read-only behavior, eager selection/validation, guards, once-only effects, successful errors/fatal identities and cold loading precede assertions/source edits. Identical RED/GREEN, complete-source semantic faults, complete predecessor consumers plus new fixture; full Knowledge/book/artifact controls, composed public guard and standard syntax/public Phase0.
  Canonical trigger: none for one private required-validator binding; escalate before public/generated/mechanical changes. Independent private/parent admission remains open.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.1.0.json`
  Acceptance: Preserve actual public callback/map and returned reference identities, eager validation/selection and all original global diagnostic lines. Actual registration supplies only its own authority. Commit before the next child; no independent aggregate admission inferred.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.5.1.0 - isolate branch expansion callbacks`; derive accepted hash from Git.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.5.1.0`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.5.1.1`
  Status: `done` / focused verified
  Goal: Attached method parser required callbacks.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.5.1.0`
  Verification tier: `focused`
  Focused checks: Native-first actual callbacks/contexts/aliases/selected maps/guards/AST/control/error behavior; original RED/GREEN, full-source faults, complete supplied consumers and book/Knowledge/artifact/public controls.
  Canonical trigger: none without public/generated/mechanical changes; reclassify before crossing those boundaries.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.1.1.json`
  Acceptance: Preserve actual public callback/map and returned reference identities, eager validation/selection and all original global diagnostic lines. Actual registration supplies only its own authority. Commit before the next child; no independent aggregate admission inferred.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.5.1.1`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.5.1.2`
  Status: `done` / focused verified
  Goal: Single-statement trim dependency.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.5.1.1`
  Verification tier: `focused`
  Focused checks: Native-first actual callbacks/contexts/aliases/selected maps/guards/AST/control/error behavior; original RED/GREEN, full-source faults, complete supplied consumers and book/Knowledge/artifact/public controls.
  Canonical trigger: none without public/generated/mechanical changes; reclassify before crossing those boundaries.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.1.2.json`
  Acceptance: Preserve actual public callback/map and returned reference identities, eager validation/selection and all original global diagnostic lines. Actual registration supplies only its own authority. Commit before the next child; no independent aggregate admission inferred.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.5.1.2`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.5.1.3`
  Status: `done` / canonical landing requires exact receipt
  Goal: Finite engineering-history rollover prerequisite before the next implementation record.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.5.1.2`
  Verification tier: `canonical`
  Focused checks: Actual next-record pressure/rollover candidate, exact complete-suffix/root/manifest reconstruction, finite resulting member/manifest/authority arithmetic, old-cap RED and unrelated-limit controls, claim preservation and exact staged canonical gate.
  Canonical trigger: Documentation storage/registry/authority infrastructure.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.1.3.json`
  Acceptance: Admit only the finite capacity proved necessary for one complete rollover, preserve exact accepted history/queryability and all original callback evidence, and commit canonical proof before .5.2.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.5.1.3 - admit one engineering history member`
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.5.1.3`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.5.2`
  Status: `done` / `focused-signoff-complete`; normal hooks govern landing
  Goal: If and while family required callbacks.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.5.1.3`
  Verification tier: `focused`
  Focused checks: Native-first actual references, contexts, argument/slot aliases, selected maps and ordinary effects/errors; distinguish actual child identity/own eligibility from enclosing publication; identical paired RED/GREEN, complete-source faults, supplied direct consumers, public syntax/Phase0, full Knowledge/book/artifact controls and normal doctrines.
  Canonical trigger: none without public/generated/mechanical changes; reclassify before crossing those boundaries.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.2.json`
  Acceptance: Preserve public maps/callback references and ordinary behavior. Actual identity carries only its own scope authority. Commit before the next child; no aggregate admission inferred.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.5.2 - isolate if/while required callbacks`.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.5.2`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.5.3`
  Status: `done`
  Goal: Switch family required callbacks.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.5.2`
  Verification tier: `focused`
  Focused checks: Native-first actual references, contexts, aliases, selected maps and ordinary effects/errors; distinguishing authority RED/GREEN, complete-source faults, supplied direct consumers and book/Knowledge/public/artifact controls; standard syntax/public Phase0, both history-pressure checks and normal doctrine hooks.
  Canonical trigger: none without public/generated/mechanical changes; reclassify before crossing those boundaries.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.3.json`
  Acceptance: Preserve public maps/callback references and ordinary behavior. Actual identity carries only its own scope authority. Commit before the next child; no aggregate admission inferred.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.5.3 - isolate switch required callbacks`.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.5.3`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.5.4`
  Status: `done`
  Goal: Output family required callbacks.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.5.3`
  Verification tier: `focused`
  Focused checks: Native-first actual references, contexts, aliases, selected maps and ordinary effects/errors; distinguishing authority RED/GREEN, complete-source faults, supplied direct consumers and book/Knowledge/public/artifact controls.
  Canonical trigger: none without public/generated/mechanical changes; reclassify before crossing those boundaries.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.4.json`
  Acceptance: Preserve public maps/callback references and ordinary behavior. Actual identity carries only its own scope authority. Commit before the next child; no aggregate admission inferred.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.5.4 - isolate output required callbacks`.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.5.4`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.5.5`
  Status: `done` / `focused-signoff-complete` (activated from clean `dadce45ac8f0a4bc6d65a3497ac99fc735e9187c`)
  Goal: Optional print_each kind invocation.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.5.4`
  Verification tier: `focused`
  Focused checks: Native-first actual references, contexts, match aliases, first/second tied-map selection, ordinary effects/errors and guarded skips; identical authority RED/GREEN, complete-source faults, complete supplied direct consumers, actual public diagnostics, book/Knowledge/public/artifact controls and normal doctrines.
  Canonical trigger: none without public/generated/mechanical changes; reclassify before crossing those boundaries.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.5.json`
  Acceptance: Preserve public maps/callback references and ordinary behavior. Actual identity carries only its own scope authority. Commit before the next child; no aggregate admission inferred.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.5.5 - isolate optional print_each kind`.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.5.5`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.5.6`
  Status: `done` / focused-signoff-complete
  Goal: Direct selected lowerer and rule apply invocations.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.5.5`
  Verification tier: `focused`
  Focused checks: Native-first actual built-in and controlled replacement references, tail-call scalar/list/void contexts, scalar rule apply, argument/reference aliases, exact selection reads, branch candidate state, values/errors/fatal objects and cold loading. Identical authority RED/GREEN, complete-source controls, complete supplied direct consumers, standard/public diagnostics, Knowledge/book/public/artifact controls and normal hooks.
  Canonical trigger: none without public/generated/mechanical changes; reclassify before crossing those boundaries.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.6.json`
  Acceptance: Preserve public maps/callback references and ordinary behavior. Actual identity carries only its own scope authority. Commit before the next child; no aggregate admission inferred.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.5.6 - isolate selected control callbacks`.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.5.6`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.5.7`
  Status: `done` / `focused-signoff-complete` (activated from clean `ce9eaf32e19002c5fe11e22e5de3c3094270843d`)
  Goal: Exact mixed-provider default references and native package-object effects at the directly related default selectors.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.5.6`
  Verification tier: `focused`
  Focused checks: Native-first actual references, contexts, aliases, selected maps and ordinary effects/errors; distinguishing authority RED/GREEN, complete-source faults, supplied direct consumers and book/Knowledge/public/artifact controls.
  Canonical trigger: none without public/generated/mechanical changes; reclassify before crossing those boundaries.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.7.json`
  Acceptance: Preserve public maps/callback references and ordinary behavior. Actual identity carries only its own scope authority. Commit before the next child; no aggregate admission inferred.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.5.7 - select mixed native control defaults`.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.5.7`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.5.8`
  Status: `done` / `canonical-admission-required` (activated from clean `54bb5eb65178a57ac6e61e53324c9291863e716d`)
  Goal: Admit exact finite continuity growth before fixture admission, preserving every original archive and compiler proof.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.5.7`
  Verification tier: `canonical`
  Focused checks: Reverify current pressure from canonical route/card homes; retain exact unchanged-limit refusals and independently reconstruct every resulting archived byte/manifest/source coordinate. Preserve the complete .5.7 publication and actual readonly baseline before bound writes. Declare a concrete bounded continuation population, admit only its measured finite overhead, and falsify numeric/authority/preservation alternatives using the unchanged production checks. Keep all unrelated fields and budgets exact.
  Canonical trigger: Document-storage/governance infrastructure requires exact staged canonical receipt plus all normal hooks.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.5.8.json`
  Acceptance: Exact recoverable original publication/history, observed production refusals and distinguishing effective controls, one accepted/indexed finite authority with only measured growth, complete current book/Knowledge, staged canonical receipt and clean committed handoff. No runtime or fixture/pipeline admission inferred.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.5.8 - admit finite continuity capacity`.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.5.8`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.7`
  Status: `done` / source-bound signoff; exact canonical receipt governs admission
  Goal: Register and verify the complete focused private factory/dependency regression population in canonical CI before pipeline scope activation.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.5.8`
  Verification tier: `canonical`
  Focused checks: Preserve complete175-input/43696-byte retained-review publication and actual readonly baseline before shared bound writes. Inventory the complete accepted .5.7-final91-suite/363-input population against actual canonical tracked/syntax/execution selections; retain exact original omission RED. Register the bounded explicit population, prove effective missing/duplicated/disabled/foreign selection faults and exact historical runner inverse, retain original audit RED and corrected complete recovery/read-denied audit, supplied fixtures, complete Knowledge/book and artifact controls. Both histories, memory/whitespace, exact staged canonical CI and all normal doctrines govern admission.
  Canonical trigger: tools/run_ci_local.sh mechanical selection change and pre-pipeline admission; exact staged receipt required.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.7.json`
  Acceptance: Complete actual file/command inventory, effective missing-selection RED/restoration, exact tracked/syntax/run registration and preserved historical audit contract, canonical receipt, public book and clean committed handoff. No pipeline activation before this owner closes.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.7 - admit complete private fixture selection`; Git owns accepted identity.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.7`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.6`
  Status: `done` / focused signoff with complete supplied context
  Goal: Invocation-local scope activation before contract factories, separate factory dependencies and actual canonical apply captures; preserve current replacement algorithm and all public shapes/order.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.7`
  Verification tier: `focused`
  Focused checks: Actual/native callback and invocation identities; scalar/list/void context where applicable, aliases, once-only effects, exact return/error/fatal values, opaque nested delegation, scope restoration/release and unchanged public maps. Complete supplied direct consumers, effective semantic faults, retained instrument/input/channel identities, relevant book and ordinary doctrines; run tools/check_public_aggregate_selector_surface.py when editing public compiler teaching or adding synthetic native sources, retaining exact-path/byte negative classification and the public syntax contract.
  Canonical trigger: none for bounded private implementation without public/generated/mechanical change; reclassify before writes if scope crosses those boundaries. Complete private Phase0 and canonical replacement remain separately owned.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.6.json`
  Acceptance: Follow the retained owner plan; choose no authority by name, copied metadata or equal value. Preserve existing selected input grants and callback references. Split further before writes if actual code paths exceed a safe slice. Commit before activating the next owner.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.6 - isolate pipeline callbacks per invocation`; Git owns accepted identity.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.6`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.10`
  Status: `done` / P2 readonly original-claim population repair
  Goal: Make the accepted .2 readonly review independent of unrelated claims added after its fixed baseline, while retaining the complete original claim census and every native observation.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2`, `REPO-HYGIENE.16`
  Verification tier: `focused`
  Focused checks: Actual original refusal with the new unrelated claim; independent fixed-Git claim population rather than current namespace, unrelated addition/omission controls and effective return-to-original fault. Reconstruct the sole reviewer correction and exact original publication, reuse immutable runtime/book proof, verify current readonly endpoints and ordinary doctrines.
  Canonical trigger: none for bounded readonly proof routing without product/storage/gate changes; reclassify before crossing those surfaces.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.10.json`
  Acceptance: Restore current readonly review without weakening original census or refreshing observations. Commit before .9; independent admissions remain separate.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.10`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11`
  Status: `done` / focused-signoff-complete; exact staged canonical receipt required for landing
  Goal: Reject malformed constrained Knowledge front matter, including orphan list items following scalar values, and retain strict current reverify routing.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.8`
  Verification tier: `canonical`
  Focused checks: Retain original header/list census and all intersecting accepted claims before bound writes; run unchanged actual gate fixtures RED/GREEN, valid scalar/inline/block-list controls, orphan-after-scalar/inline and detached-list denials with source/input/channel identities. Check current full Knowledge population, derived map, mdBook and unchanged70/40 public classifier, native private labels20/two old REDs, exact scanner8/14/24 controls, whole frozen337/full79329 supplied replay and three final semantic forgeries. Run composed public gate, ordinary doctrines, memory, both history-pressure checks and whitespace.
  Canonical trigger: Existing doctrine/Knowledge enforcement infrastructure changes require exact staged tools/run_ci_local.sh receipt under ADR0073.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11.json`
  Acceptance: Fix and verify the gate gap immediately after .8 before FlowExpr; preserve historical claims/observations and current fact bodies. Follow COMMIT.md and clean handoff.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.12`
  Status: `done` / canonical boundary; exact staged receipt required for landing
  Goal: Resolve accepted block metadata whose evidence/reverify values disappear from the generated Knowledge Map; preserve the documented field contract and historical observations.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.6`, `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11`
  Verification tier: `canonical`
  Focused checks: Preserve intersecting claims; retain current affected population and public missing-metadata reproductions; declare actual field contract, distinguish scalar/list controls and add a recurring projection regression. Exact staged canonical gate and normal commit required.
  Canonical trigger: Knowledge generator/enforcement and generated retrieval format are mechanical infrastructure; exact staged tools/run_ci_local.sh receipt is required.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.12.json`
  Acceptance: Supported metadata remains recoverable and displayed or receives an explicit contract-consistent rejection; original facts/claims retain their historical boundaries.
  Commit: PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.12 - preserve Knowledge list metadata; Git owns accepted identity.
  Narrative epoch: `TYPE-REFERENCE-BOOK.1.2.20.2`; exact accepted source via `bash tools/run_python_project_data.sh tools/read_task_narrative.py --tree PERL-PRIVATE-FACTORY-CAPTURE --epoch TYPE-REFERENCE-BOOK.1.2.20.2 --id PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.12`.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.13`
  Status: `pending` / P3 unconfirmed metadata literal-format question
  Goal: Assess scalar evidence/reverify code-span rendering and repair only an observed loss of authored literal content.
  Dependencies: `TYPE-REFERENCE-BOOK.1`, `TYPE-REFERENCE-BOOK.8`
  Reproduce question: The accepted .12 preserves the existing scalar presentation while list items use adaptive code-span fences. Check actual scalar values containing backticks or boundary spaces through the published generator/checker and independent actual mdBook rendering. No new failing case, affected count or root-cause claim has been established.
  Owned paths: Future bounded diagnostic fixtures/producer/reviewer/claim and, only after actual RED and preservation, the scalar presentation branch plus relevant Knowledge/book/continuity. Preserve every accepted .12 epoch and its complete publication before bound changes.
  Schedule: After the first type-reference inventory and already-owned legacy status repair; raise priority if actual evidence establishes a blocker. No current metadata implementation pivot.
  Planned tier: `focused` for diagnosis; require `canonical` before any generator/generated-format repair.
  Claim verification: none: Unactivated qualitative question; declare actual source-bound measurement proof before execution/publication.
  Acceptance: Resolve from native source/render evidence rather than a suspected Markdown mechanism. Retain distinguishing controls and exact original observations; either close with supported no-defect evidence or verify a bounded repair. No full YAML/type-validator or broader renderer guarantee.

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `TYPE-REFERENCE-BOOK.1.2` | `pending` | .1.1 current guidance is verified; clean activation starts complete inventory before .8 status reconciliation. |
| 2 | `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.13` | `pending` | Deferred unconfirmed scalar literal-format question after Type .1/.8; original private/mapping/admission owners remain open. |

## Handoff

Metadata .12 preserves evidence/reverify lists in authored order/multiplicity and keeps scalar presentation. Original full1487-source/1349-fact baseline accepts248 fields but omits897 entries; independent current source/code-span review restores all897 and10455 question rows. Original80 controls stay exact; corrected176 plan has38 projection REDs/138 controls then176 GREEN. Ten syntax-valid source faults retain all120 native controls and restore exact healthy state; three coherent map/report/graph forgeries reject and restore. Actual22596/22500 pressure RED precedes blank-only containment with identical actual mdBook main content and changed-heading control. Current fifteen routes, architecture/template/book and full89-input/four-control book pass. Knowledge8386908 bytes and map21249 lines fit unchanged budgets. Exact39-file/98579726-byte failed render output is archived, freshly byte/mode reproduced and removed with residue absent; first unsaved render channels remain explicitly unavailable. Whole711/full120239 .6 baseline and all inputs are preserved at real f7e8b292f by mode/revision only. Current readonly publication binds208 inputs/full39111. Whole original196/full35922 and the failed108-file candidate remain recoverable; actual original-reader baseline/replay pass. Standard JSON solidus transport preserves decoded render arguments and exact inverse bytes; three isolated transport/draft REDs restore. The original extra-file review failure is retained; its distinct correction retains actual tool temporary outputs and guards all supplied sources. Canonical2 passes all10 doctrines/private91/32235 and reaches the documented nested-sandbox prerequisite, then exits1/driver71 without a receipt. Exact121 candidate/full channels and current208/full39111 remain preserved; fresh controls return restricted71/host0 and the unchanged full six-family host oracle passes. Approved host execution is required from the start for the fresh exact canonical receipt and normal hooks. TYPE-REFERENCE-BOOK.1 is next from clean Git. No full YAML/type-validator, runtime/DSL, allocator/selector/budget, lifecycle/recovery/purge or independent private/parent admission is inferred. Preserve the complete current publication and actual readonly baseline before future bound writes. Activate TYPE-REFERENCE-BOOK.1 only after exact canonical/normal commit, brief0, explicit post checks and clean Git.

## Decisions

- `2026-10-10`: Link new bounded implementation owners instead of expanding the existing monolith or migrating
  its IDs/consumers. Existing task collection and per-file rules remain unchanged.
- `2026-10-10`: Preserve native list/void contexts with isolated nonpublishing dependency calls; do not force
  them through the scalar-string packet protocol. Registration and publication remain separate authorities.
- `2026-10-10`: Public dependency maps and callback fields retain actual references. Any private lexical thunk
  must forward the retained actual callback and original argument aliases; otherwise instrument the call site.

## Blockers

Projection repair `RUST-DEPENDENCY-WARNING-ZERO.8` is complete. No factory implementation blocker is known.

Exact implementation details and any necessary finer function-family splits belong to the next owner
before its production writes. Artifact recovery/purge remains prohibited pending SESSION-STARTUP-READING.7.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.4.2

- [x] **REPRODUCE / ISSUE** — Unchanged100-input first native captures retain150 warm/150 cold rows and exact recurrences before assertions/edits. The identical final762 TAP has154 authority REDs/608 controls; first semantic failures are preserved exactly.
- [x] **ROOT CAUSE (WHY + WHERE)** — Both optional calls at the original246/256 statement boundaries execute in their enclosing publication frame. Tied maps separately check and select; callback names/blessed/native callable values cannot receive actual CODE authority. Native captures and strict-vars probes identify both rejected placement/scope candidates.
- [x] **FIX** — Preserve two reads/selection and both name guards; use actual CODE identity or caller-local opaque delegation. Complete lexical setup on the original opening condition line, append the bounded private helper, and preserve all original function/diagnostic lines. Public maps, aliases, scalar contexts, values, once-only effects, errors/fatal objects and cold loading stay native. Only test-name display changes in the final fixture.
- [x] **ADDRESSED (verified)** — All762 final assertions pass; all300 native compatibility rows and recurrences remain exact. Fourteen full-source faults fail154/77/77/56/24/156/184/8/156/450/2/284/48/266, with exact original inverse. Six deeper artifact denials and unchanged-reader replay/two integrity controls restore PASS; original sources/observations are immutable.
- [x] **NO REGRESSION** — All78 supplied suites/263 complete inputs/20232 assertions pass, including required FlowExpr. Supplemental strict-vars/standard syntax/public Phase01035 and staged composed public guard pass. Full prior451 bindings/112004 publication and actual readonly baseline remain recoverable at708c1afa. Defaults and independent admissions stay open.
- [x] **LOCKSTEP** — Full Knowledge1485/1349/seven overlays retains8384530 under unchanged8388608 and every member limit; book89/four controls passes. Current426/full99413 readonly publication, task/frontier, roadmaps/index, live/history/memory align. Normal focused hooks, explicit memory, both histories and whitespace govern clean handoff to .4.1.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.4.0

- [x] **REPRODUCE / ISSUE** — Unchanged first native100-input/387-warm/235-cold captures and recurrences precede expectations/source edits. Identical1795 TAP has490 original authority REDs and1305 passing controls; exact first normal prove failures match the complete raw TAP names/order.
- [x] **ROOT CAUSE (WHY + WHERE)** — Five FlowExpr required validators returned actual callbacks directly in their parent's publication frame. Original callbacks borrow parent eligibility and can donate equal-text publication; actual CODE and retained-child packet oracles distinguish both failures.
- [x] **FIX** — Bind exactly five required returns; append the lazy alias/context-preserving private helper after all original bodies. Preserve validation order/diagnostic lines, public callback maps, local scalar copies/shared argument arrays, values/effects/errors/fatal objects and cold loading. Optional kind/defaults stay separate.
- [x] **ADDRESSED (verified)** — Same1795 assertions all GREEN; all622 complete native rows unchanged. Thirteen syntax-valid full-source faults fail490/111/119/117/74/126/338/18/522/1012/2/602/100; exact inverse restores every original failure. Five actual beyond-hash artifact denials restore readonly PASS.
- [x] **NO REGRESSION** — Complete77 ordered consumer suites/256 supplied inputs/19470 assertions pass. Supplemental standard syntax/public Phase01035 passes with full channels. Original218 bindings/full58582 and actual baseline remain exact except historical mode/revision at81b356ce; system tools/private/parent admission limits remain explicit.
- [x] **LOCKSTEP** — Whole first408/full94719 candidate replays in1887 supplied inputs/two corruption controls; seven exact header extractions reduce8401572 to8381805 bytes under unchanged8388608. Original/current header lineages, full Knowledge1485/1349, final book89/four controls and two further artifact denials/restorations pass. Final readonly438-input/105949-byte publication owns current routes. Current task/frontier, roadmap/index, live/history/memory agree; stale MethodLowering handoff teaching is corrected. Focused normal hooks, both bounded histories, composed public guard, explicit memory and whitespace govern landing before .4.2.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.1

- [x] **REPRODUCE / ISSUE** — Actual `perl -Iperl t/actionir_factory_capture.t` supplied runs distinguish a separate dependency boundary from an enclosing known callback inheriting opaque nested publication. The scalar/list/void boundary-removal source controls retain complete semantic RED plans; this is a private integration requirement, not a claimed shipped pipeline defect.
- [x] **ROOT CAUSE (WHY + WHERE)** — `SourceEmissions.pm:218` binds actual callback registration to the current source/producer; `SourceEmissions.pm:232` isolates injected calls from the dynamic publication slot. Actual native reference probing explains the four initial draft failures: its no-lexical-state factory returned one shared CODE reference. The fixture premise was wrong; production bytes stay exact across its correction.
- [x] **FIX** — Return the same actual registered callback; isolate scalar calls with actual captures and list/void calls with their native contexts and locally disabled publication. Forward original argument aliases; keep ordinary values/errors and public maps unchanged. Give the distinct-closure fixture actual lexical state.
- [x] **ADDRESSED (verified)** — Source-bound PASS224 assertions/30 native differential modes and eleven effective, syntax-valid semantic faults; actual reviewer and original-binding corruption controls reject then restore PASS. `PERL-PRIVATE-FACTORY-CAPTURE.1-final-review.py` and `-preservation-control.py` are the repeatable readonly entrypoints under `tools/run_python_project_data.sh`.
- [x] **NO REGRESSION** — Focused tier: seventeen actual supplied direct suites PASS with136 exact files, including all three JSON reader inputs; only SourceEmissions production bytes are overlaid. `perl -c -Iperl` checks the module/fixture; all source faults have coherent224-assertion TAP. Complete private Phase0 and mapped/canonical acceptance stay separately owned, without a full-suite claim here.
- [x] **LOCKSTEP** — Complete57-source mdBook build and two actual source/render controls PASS; Knowledge, current roadmaps/task index and bounded history/live/memory pointers are synchronized. Original232 bindings remain historical. No public/generated contract, submodule or pin change; Contracts `.2` is next.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.2.0

- [x] **REPRODUCE / ISSUE** — Same-name replacement and opaque nested owner/factory publication are explicit private integration constraints. Actual source-fault captures retain complete semantic REDs for name-based selection and missing call boundaries; no shipped pipeline defect is inferred.
- [x] **ROOT CAUSE (WHY + WHERE)** — EmitContext's private catalog must retain actual native definition references; resolving a later public name cannot establish the same identity. `_actionir_owner_default_deps`, `_call_actionir_owner` and `_call_actionir_owner_with_deps` each invoke actual resolved dependencies and require separate boundaries. Actual unchanged/current ledgers show the pre-existing copied scalars and caller-error restoration.
- [x] **FIX** — Return/register only the matching retained actual callback; isolate every resolved dependency through the existing native-context helper when loaded. Preserve require-only loading and existing argument/map/error behavior without changing OwnerDispatch or activating pipeline scopes.
- [x] **ADDRESSED (verified)** — Main345/cold5, exact native30 and thirteen effective syntax-valid semantic controls PASS. Four reviewer corruptions and one original-binding corruption reject then restore actual PASS. Repeatable readonly final-review/preservation-control entrypoints retain exact producer, capsule and channel identities.
- [x] **NO REGRESSION** — Focused tier: nineteen direct suites PASS in138 supplied files, including Trace and all three JSON reader inputs. Source-fault syntax and complete TAP remain checked. No complete private Phase0, mapped replacement or canonical/parent admission inferred.
- [x] **LOCKSTEP** — Complete57-source book and missing-SUMMARY/removed-rendered-marker controls PASS. Knowledge, roadmaps/index and bounded history/live/memory pointers align. Original233 bindings are preserved; .2.1 is the next bounded owner.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.2.1.0

- [x] **REPRODUCE / ISSUE** — Reuse the canonical input_slice dynamic-publication diagnosis. Actual required/optional/fallback/bare boundary-removal faults retain complete semantic REDs. Current production lowerers still do not publish packets; no shipped pipeline defect is inferred.
- [x] **ROOT CAUSE (WHY + WHERE)** — `_require_lowering_deps` and `_build_call_and_dispatch_contracts` retained direct injected callback calls. A known parent could inherit an opaque nested publication. Default selection also needs both the actual built-in target and retained native callback references. The isolated lifetime RED is reproduced on original/current sources and the lexical-state control passes both, matching the known native fixture issue.
- [x] **FIX** — Use private lexical bindings for required/optional/bare calls, forwarding actual callbacks/aliases/context; preserve caller maps/public fields and cold loading. Select built-in defaults through the accepted actual-reference getter. Correct only the lifetime fixture's lexical premise after preserving its actual failed inputs/channels.
- [x] **ADDRESSED (verified)** — Main312/cold6, native15 and sixteen effective syntax-valid semantic controls PASS. Four reviewer corruptions and one frozen original-binding corruption reject then restore actual PASS; all producer/input/channel identities remain bound. Repeatable final-review/preservation-control entrypoints are retained.
- [x] **NO REGRESSION** — Focused tier: twenty-one suites PASS in140 exact supplied files, including Trace and all three JSON reader artifacts. Production bytes do not change for fixture correction. No complete private Phase0, mapped/canonical or parent admission inferred.
- [x] **LOCKSTEP** — Complete57-source book/two actual render controls PASS; Knowledge, task index/roadmaps and bounded history/live/memory pointers align. All235 original EmitContext bindings remain historical. Actual local/delegated lower registration .2.1.1 is next.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.2.1.1

- [x] **REPRODUCE / ISSUE** — Every local/delegated constructor needs its own actual callback registration; a substituted factory must remain opaque. Twenty effective actual source faults include each missing seam, blind aggregate registration, wrong callback, public-reference copying, global retention and eager cold loading.
- [x] **ROOT CAUSE (WHY + WHERE)** — The twelve local group returns and StagedParseJob/ProgressiveSpanDispatch build_contracts own their actual literal callback construction. Aggregate catalogue metadata/names do not establish that identity. SourceEmissions' current source/producer registry and eligible-call probe distinguish actual registered callbacks from opaque returned references.
- [x] **FIX** — Register at each own literal return, returning the same public references; delegated owners register their own arrays. Leave aggregate assembly/order unchanged. Reuse the existing private scope registry without eager loading or global callback caches.
- [x] **ADDRESSED (verified)** — Main447/cold6 and twenty syntax-valid complete semantic controls PASS; two actual native/current174-entry catalogues match. All174 actual callbacks select in scope; twelve actual reference snapshots/fourteen substitutions pass. Four reviewer corruptions and one frozen original-binding corruption reject then restore actual PASS.
- [x] **NO REGRESSION** — Focused tier: twenty-three suites PASS in142 supplied files with all three JSON reader artifacts. Complete catalogue comparison is explicitly benign-input/controlled-dependency proof; full successful helper behavior/private Phase0, mapped/canonical and parent admission stay open.
- [x] **LOCKSTEP** — Complete57-source book/two actual render controls PASS. Knowledge, current task index/roadmaps and bounded history/live/memory align. All248 original dependency bindings remain historical; MethodLowering .3 is next.


## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.0

- [x] **REPRODUCE / ISSUE** — Actual default selection requires both built-in target and retained native CODE reference. Every native-entry omission and actual target/ref/map/cold source fault produces a complete semantic RED in the supplied fixtures; no shipped pipeline failure is inferred.
- [x] **ROOT CAUSE (WHY + WHERE)** — MethodLowering::default_deps_for_package returns actual EmitContext callbacks from OwnerDispatch::build_dep_map. A later public-name lookup cannot distinguish a replacement from the definition-owned callback. The separate EmitContext method catalogue and actual source/producer known-reference probes make that distinction.
- [x] **FIX** — Retain the nineteen actual definition-owned method facade references and select only matching callbacks for the built-in target. Return the exact OwnerDispatch map/public callbacks; leave injected calls and pipeline scopes for their owners. Correct inherited capture-scope prose, retaining all original channels/producer; production and fixtures remain exact across recapture.
- [x] **ADDRESSED (verified)** — Main426/cold6 and24 effective syntax-valid complete semantic source controls PASS; two native/current19-callback ledgers match. All nineteen replacement/native-alias/publication controls and scope restoration pass. Four reviewer corruptions and one frozen original-binding corruption reject then restore actual PASS; readonly final-review/preservation-control entrypoints retain every actual input/channel identity.
- [x] **NO REGRESSION** — Focused tier: twenty-five direct suites PASS in144 supplied files with all three JSON reader artifacts. Original Contracts construction, native facade/dependency fixtures and Trace remain supplied. No universal helper behavior, native packet production, complete private Phase0 or mapped/canonical/parent admission inferred.
- [x] **LOCKSTEP** — Complete57-source book/two actual render controls PASS; Knowledge, task index/roadmaps and bounded history/live/memory pointers align. All244 original construction bindings remain historical. Required .3.1 is next, followed by optional/direct .3.2.


## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.1.0

- [x] **REPRODUCE / ISSUE** — The same actual perl -Iperl t/actionir_method_trim_capture.t fixture reaches complete255 TAP on original/current inputs: eleven original publication-isolation REDs, other244 original controls pass, all255 current GREEN. A known enclosing caller can inherit an unisolated injected trim publication; production lowerers do not yet publish packets, so no shipped pipeline failure is inferred.
- [x] **ROOT CAUSE (WHY + WHERE)** — The three owned MethodLowering require_dep closures returned direct actual callbacks. SourceEmissions' dynamic publication slot therefore remained the parent's while trim executed. Actual eligible-call/packet retrieval and known-child capture distinguish this mechanism. The partial retention source fault correctly reaches RED255; the original harness expected the obsolete cache label, so diagnosis is an instrument matcher defect, not a production retention regression.
- [x] **FIX** — Add the private lexical native-context binding and return it only from direct shape inference, tag and inline switch-case required trim seams. Forward actual aliases/context and ordinary results/errors; preserve caller maps and top-level copies. Retain partial producer/channels and correct only two matcher labels before unchanged-input recapture.
- [x] **ADDRESSED (verified)** — Paired11 RED/255 GREEN, native15/caller9 and thirteen effective syntax-valid complete source-fault controls PASS. Known-child packet separation, exact required diagnostics, lexical lifetime and cold5 pass. Four reviewer corruptions and one frozen original-binding corruption reject/restored PASS; readonly final-review/preservation-control entrypoints bind all actual inputs/channels.
- [x] **NO REGRESSION** — Focused tier: twenty-seven suites PASS in146 supplied files, including all three JSON reader artifacts, previous default/constructor/dependency fixtures and Trace. The shape secondary value result is explicitly controlled in the bounded three-caller oracle. No universal helper behavior, complete private Phase0 or mapped/canonical/parent admission inferred.
- [x] **LOCKSTEP** — Complete57-source book/two actual render controls PASS; Knowledge, roadmaps/index and bounded history/live/memory align. All282 original default bindings stay historical. Assignment/declaration required .3.1.1 is next; remaining required/optional owners stay open.


## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.1.1

- [x] **REPRODUCE / ISSUE** — Same actual fixture reaches complete277 TAP on original/current inputs:24 original publication-isolation REDs,253 original controls pass, all277 current GREEN. All eight actual callback roles are exercised; no shipped pipeline failure is inferred.
- [x] **ROOT CAUSE (WHY + WHERE)** — The three required-resolution closures returned direct injected callbacks while the parent's dynamic publication slot remained active. Actual eligible-call/packet retrieval distinguishes opaque and known child identity; actual wrapper substitution independently loses known identity. The initial reviewer was started before consumers.json finished, so it stopped at a missing result rather than a runtime failure.
- [x] **FIX** — Return the existing private native-context binding from only assignment container inference, value binding and retained typed-declaration resolver closures. Preserve actual public maps/callbacks, copied scalars and shared parser-returned array aliases. Wait for the consumer capture before dependent review; the fifth evidence control reproduces missing-result rejection with exact restoration and unchanged runtime inputs.
- [x] **ADDRESSED (verified)** — Paired24 RED/277 GREEN, exact25 native/current caller ledgers, all eight roles and nine effective syntax-valid complete semantic faults PASS. Five actual evidence controls and original-binding corruption reject/restored PASS. Cold4 and exact required missing/non-CODE diagnostics pass; readonly final-review/preservation-control entrypoints retain all actual identities.
- [x] **NO REGRESSION** — Focused tier:29 suites PASS in148 supplied files with all three JSON reader artifacts and prior direct fixtures. Controlled undef secondary helpers bound the actual three-owner oracle; no universal helper behavior, authored declaration syntax, complete private Phase0 or mapped/canonical/parent admission inferred.
- [x] **LOCKSTEP** — Complete57-source book/two actual render controls PASS. Knowledge, roadmaps/index and bounded history/live/memory align; all262 original trim bindings remain historical. Inline/block .3.1.2 is next; remaining required/optional and pipeline owners stay open.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.0

- [x] **REPRODUCE / ISSUE** — Same actual fixture reaches complete177 TAP:15 original publication-isolation REDs,162 original controls pass and all177 current GREEN. Five actual roles distinguish enclosing publication from ordinary expression results; no shipped pipeline failure is inferred.
- [x] **ROOT CAUSE (WHY + WHERE)** — Inline if/switch require_dep closures returned direct injected callbacks while their enclosing SourceEmissions publication slot remained active. Actual eligible-call/packet retrieval and actual-to-wrapper faults distinguish callback identity. The copied freezer's old PREFIX triggers an existing replay guard before any writes; actual rejection and original input snapshot prove the cause.
- [x] **FIX** — Bind only the two required returns through the unchanged native-context helper. Preserve original maps, copied if/shared switch branch scalars and actual parser-array aliases; explicit constant secondary helpers bound the oracle. Correct freezer PREFIX/docstring/console after retaining/reproducing its rejection, then preserve original inputs before runtime writes.
- [x] **ADDRESSED (verified)** — Paired15 RED/177 GREEN, exact15 native/current ledgers and six complete syntax-valid semantic faults PASS. Five actual evidence controls and one original-binding corruption reject/restored PASS; cold4 and exact required diagnostics pass. Readonly final-review/preservation-control retain every actual producer/input/channel identity.
- [x] **NO REGRESSION** — Focused tier:31 suites PASS in150 supplied files with all three reader JSONs, previous dependency/default/construction fixtures and Trace. This is bounded two-caller proof with controlled branch/case/truthiness helpers; no universal language behavior, complete private Phase0 or mapped/canonical/parent admission inferred.
- [x] **LOCKSTEP** — Complete57-source book/two actual render controls PASS. Knowledge, roadmaps/index and bounded history/live/memory align; all240 original inference bindings remain historical. Block component/side-effect .3.1.2.1 is next, followed by local-return/value .3.1.2.2 and remaining required/optional owners.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.1

- [x] **REPRODUCE / ISSUE** — Identical actual fixture reaches complete223 TAP:18 original publication-isolation REDs,205 original controls pass and all223 current GREEN. Six actual invoked roles distinguish ordinary fallback/reference values from donated nested publication; no shipped pipeline failure is inferred.
- [x] **ROOT CAUSE (WHY + WHERE)** — Component/side-effect require_dep closures returned direct injected callbacks while the enclosing SourceEmissions publication slot stayed active. Actual eligible-call/packet retrieval and wrapper-identity faults distinguish the boundary. The component's local flow binding is eagerly validated but has no direct invocation; secondary helpers are explicitly controlled, with no complete transitive-graph claim.
- [x] **FIX** — Bind only the two required returns through the unchanged native-context helper. Preserve undefined-result fallback, actual reference identity, copied top-level inputs, public callbacks and shared parser-array mutations. Keep local flow validation and its original diagnostic rather than fabricating invocation coverage.
- [x] **ADDRESSED (verified)** — Paired18 RED/223 GREEN, exact20 native/current ledgers and six complete syntax-valid semantic faults PASS; the component diagnostic fault specifically distinguishes its validation-only missing-flow requirement. Five actual evidence controls and original-binding corruption reject/restored PASS; cold4 and all required diagnostics pass. Readonly final-review/preservation-control retain exact producer/input/channel identities.
- [x] **NO REGRESSION** — Focused tier:33 suites PASS in152 supplied files with all three reader JSONs, previous dependency/default/construction fixtures and Trace. Explicit constant/undef AST and secondary helpers bound the two actual caller bodies; no universal helper/AST/language behavior, complete private Phase0 or mapped/canonical/parent admission inferred.
- [x] **LOCKSTEP** — Complete57-source book/two actual render controls PASS. Knowledge, roadmaps/index and bounded history/live/memory align; all242 original inline bindings remain historical. The concise new note fits existing pressure limits; no immutable history or capacity is changed. Finite history-capacity .3.1.2.3 precedes local-return/value .3.1.2.2.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3

- [x] **REPRODUCE / ISSUE** — Existing engineering-history membership/manifest limits reject the newly required archive member; the ordinary feature commit retains a concise complete note and grants no capacity. Actual production controls reproduce each old-limit failure with the actual resulting census.
- [x] **ROOT CAUSE (WHY + WHERE)** — The production roller reaches a finite history-member requirement while README_POLICY and ADR0130 require a new exact accepted/indexed decision for membership/contract changes. Actual unchanged exceeds_limits and adr_authorizes_limit_change/adr_authorizes_contract_change functions distinguish threshold versus authority denial.
- [x] **FIX** — Separately indexed ADR0131 admits only one member, its exact manifest line/byte overhead and the sole decision/index overhead. Preserve stable routes/owner and all other controls. Independently reconstruct complete clean-source suffix/root/blob/range/digest and every original manifest row; no immutable rewriting or runtime/checker change.
- [x] **ADDRESSED (verified)** — Retained30 actual production threshold observations and23 authority REDs distinguish old/new limits, excess usage, missing/proposed/duplicate status/index/decision and mismatched canonical objects. Three actual reviewer corruption subprocesses reject omitted history and forged original/resulting identities, then exact restoration passes. Readonly capacity.py final is the frozen-boundary reverify entrypoint.
- [x] **NO REGRESSION** — All220 prior immutable history/decision files remain byte-exact; only one new complete clean-source segment appears. Original nine policy/support identities are historical and current245 producer/input identities live-gated. Public runtime, test, threshold-checker, dependency and external repository bytes are unchanged. The separately owned historical auditor admits only the exact two committed Contracts source revisions; healthy134-input recovery and64 evolution denials pass. Canonical tier: exact full staged CI/receipt is mandatory before landing, with no focused-only admission claim.
- [x] **LOCKSTEP** — Exact sole ADR/index and bounded history/Knowledge/roadmap/live/memory pointers align. Existing mdBook accepted-decision authority and bounded-history contracts stay accurate; the updated architecture chapter explains exact committed factory source reconciliation without product behavior movement. No future archive reserve is granted; local-return/value .3.1.2.2 resumes only after canonical commit.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.0

- [x] **REPRODUCE / ISSUE** — Identical actual fixture reaches complete115 TAP:6 original publication-isolation REDs,109 original controls and all115 current GREEN. Two actual invoked roles distinguish ordinary hash/array return values from donated nested publication; no shipped pipeline failure is inferred.
- [x] **ROOT CAUSE (WHY + WHERE)** — The local-return require_dep closure returned actual injected callbacks with the enclosing publication slot active. Actual eligible-call identity/packet retrieval and wrapper substitution distinguish the missing private boundary. The secondary payload helper is explicitly controlled; no transitive helper/AST admission follows.
- [x] **FIX** — Bind exactly the one required resolver return through the unchanged native-context helper. Preserve actual public callbacks, parser-returned shared arguments/counts, scalar copies, effects/error/fatal identities, exact diagnostics and payload undefined/empty/zero/brace guards.
- [x] **ADDRESSED (verified)** — Paired6 RED/115 GREEN, six complete native-current ledgers, cold4 and three syntax-valid complete semantic source REDs pass. Five actual evidence controls and original-binding corruption reject/restored PASS. Readonly reviewers constrain the exact one-line production delta and every producer/input/channel identity.
- [x] **NO REGRESSION** — Supplied35 suites PASS in154 exact files, including all three reader JSONs, prior dependency/default/construction fixtures and Trace. Standard public Phase0 compatibility passes1035/1035 and required Perl syntax checks pass. The controlled payload helper and separately owned block-value/pipeline/full-private/mapped/canonical admissions retain their limits.
- [x] **LOCKSTEP** — Complete book57+32/three controls PASS. Original399 live bindings are historical at268891fdf, with both already historical claims and every original proof/hash field unchanged. Knowledge1328/10184, roadmaps/index and bounded history/live/memory align; both history checks and diff hygiene pass. Normal doctrine hooks govern ordinary landing; block-value .3.1.2.2.1 follows separately.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.1

- [x] **REPRODUCE / ISSUE** — Same complete222 assertion names retain9 original publication-isolation REDs/213 passing controls/all222 current GREEN. Exactly one trim publication distinguishes required-boundary isolation from the existing ambiguity guard; no shipped language failure inferred.
- [x] **ROOT CAUSE (WHY + WHERE)** — Block-value require_dep returned direct injected callbacks with the enclosing publication slot active. Actual eligible-call/parent-packet controls distinguish trim/split/parse identity. The fourth normalizer requirement is validated only locally; secondary helper results are explicit controls.
- [x] **FIX** — Bind exactly one required return through the unchanged native-context helper. Keep actual public callbacks, split-array slot aliases, scalar copies, effects/errors/fatal identity, AST-first/copied bridge guard, early zero/reference results and fallback control flow.
- [x] **ADDRESSED (verified)** — Native9/branches16 exact, cold5 and three syntax-valid complete222-assertion source faults PASS. Diagnostic fault distinguishes missing validation-only normalizer. Independent execution of three controlled generated blocks confirms return values and guarded side effects. Five evidence REDs and original-binding corruption reject, restore exact bytes and obtain PASS.
- [x] **NO REGRESSION** — Supplied37 suites/156 files PASS; all prior154 Git inputs remain exact except the one owned module overlay, including three reader JSON artifacts and Trace. Standard public Phase0 compatibility passes1035/1035 in1204 seconds. No complete secondary-helper, grammar/language, optional/direct, private pipeline/full-private/mapped/canonical/parent admission inferred.
- [x] **LOCKSTEP** — Complete book57+32/three actual controls PASS; original273 bindings are historical at de3b50dd with all old proof/hash fields exact. Knowledge1329/10191, roadmaps/index and bounded history/live/memory align; ordinary hooks govern landing. Guarded AST .3.1.3 follows the clean commit.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.0

- [x] **REPRODUCE / ISSUE** — Same complete171 assertions retain3 original publication-isolation REDs/168 passing controls/all171 current GREEN. Actual child identity and parent packet retrieval distinguish equal ordinary values from inherited publication; no authored-language failure inferred.
- [x] **ROOT CAUSE (WHY + WHERE)** — The guarded scalar-held hash-index owner returned the actual required key callback directly while the enclosing publication slot remained active. Node/target checks precede dependency validation; valid nodes validate CODE before source helpers. Explicit source/payload/assembly controls isolate that actual caller.
- [x] **FIX** — Bind exactly one required return through the unchanged native-context helper. Preserve actual public callback, copied key-source scalar, native contexts/counts/effects/errors/fatal identity, source fallback, guards and zero/reference handoff.
- [x] **ADDRESSED (verified)** — Native3/branches15, cold4 and three syntax-valid complete171-assertion source REDs PASS. Five evidence controls and original-binding corruption reject/restored PASS. Draft producer/results retained; source differs only by stale header and both baseline rows otherwise stay exact.
- [x] **NO REGRESSION** — Supplied39/158 PASS; original156 Git inputs exact except owned module overlay, with three prior reader JSONs and Trace. Public Phase0 passes1035/1035 in1200 seconds. No complete secondary-helper/AST grammar/language, other guarded owner or independent private admission inferred.
- [x] **LOCKSTEP** — Full book57+32/three controls PASS; all275 original bindings historical at b50ce085a. Knowledge1330/10199 and bounded current roadmap-index/live/history/memory align; ordinary doctrine hooks govern landing. AST call .3.1.3.1 follows clean commit.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.1

- [x] **REPRODUCE / ISSUE** — Same complete695 assertions retain18 original publication-isolation REDs/677 passing controls/all695 current GREEN. Six actual child identity/parent packet controls distinguish equal ordinary values from inherited publication; no authored-language failure inferred.
- [x] **ROOT CAUSE (WHY + WHERE)** — AST call-statement require_dep returned actual callbacks while the enclosing publication slot stayed active. Actual eager/lazy guard order, source-helper ARRAY, trim slots/scoped copies, local scalar and payload-slice aliases distinguish the native mechanisms. Secondary helpers have explicit controlled results.
- [x] **FIX** — Bind exactly one required return through the unchanged native-context helper. Preserve all six actual public callbacks, path-specific validation, native contexts/counts/order/effects/errors/fatal identity, guards and branch fallback.
- [x] **ADDRESSED (verified)** — Native18/branches44, cold12 and three syntax-valid complete695-assertion source REDs PASS. Diagnostic fault distinguishes lazy primitive validation. Five reviewer controls and original-binding corruption reject/restored PASS; readonly reviews constrain source/producer/input/channel identities.
- [x] **NO REGRESSION** — Supplied41/160 PASS; original158 Git inputs exact except owned module overlay, with three prior reader JSONs and Trace. Standard public Phase0 passes1035/1035 in1186 seconds; both required Perl syntax checks PASS. Complete helpers/AST grammar/language, optional assignment callback, other guarded owners and independent private admissions remain outside this proof.
- [x] **LOCKSTEP** — Full book57+32/three controls PASS; all280 original bindings historical at2e9e5443e with every old proof/hash field exact. Knowledge1331/10207 PASS; bounded roadmap-index/live/history/memory align and final ordinary checks/hooks govern landing. Array-end .3.1.3.2 follows a clean commit.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.4

- [x] **REPRODUCE / ISSUE** — Actual production history --check exits255 at292 lines/59406 bytes before rollover. Existing member48/manifest47/26831 limits are full. Accepted0130/0131 index rows occur below authoring instructions. Initial matcher/source-blob/metadata instruments and actual RED channels remain retained.
- [x] **ROOT CAUSE (WHY + WHERE)** — Required complete-record rollover adds one immutable member/manifest row. Previous capacity producer appends old(INDEX)+INDEX_ROW; filename authority checks do not enforce table placement. Physical index growth adds both a row and a separating LF, so the first13179 allowance rejects actual13180. Own tools and exact source/blob/census controls establish each mechanism.
- [x] **FIX** — ADR0132 admits only one actual member, exact manifest growth and sole new ADR/index/separator overhead; all other fields/old immutable bytes stay exact. Move unchanged0130/0131 rows into the table and add0132. Retain all initial instruments/plans/results; separate finalizer corrects only the measured same-width scalar and rejects census overflow.
- [x] **ADDRESSED (verified)** — Independent exact prefix/suffix/blob/range/digest/manifest reconstruction retains222 prior immutable files. Production30 threshold/23 authority cases pass. Four actual reviewer corruptions, including displaced index row with rehashed plan, reject; full restoration passes. Original279-binding corruption rejects beyond mode/revision. Full book89/3 passes; readonly composed proof and publication agree.
- [x] **NO REGRESSION** — Runtime/source/tests, prior accepted ADRs, unchanged production checker/roller and dependency pins remain byte-exact. Exact staged canonical CI/receipt and normal hooks are the required admission boundary; focused capacity proof alone cannot land. Original AST-call public Phase0 compatibility remains historical at9085eb1e5, without remeasurement or hash refresh.
- [x] **LOCKSTEP** — Current task/frontier, roadmap/index, bounded live/history/memory and Knowledge1332/10215 align. Book teaching clarifies finite capacity and decision-table placement; complete render/includes/three controls pass. Both history checks pass; original279 inputs remain historical. Current claim gates356 live inputs in86568 bytes; canonical receipt governs landing before array-end .3.1.3.2.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.2

- [x] **REPRODUCE / ISSUE** — Same complete858-assertion fixture against clean b0099d9ad retains exactly12 original publication failures and846 passing controls across all four methods. Actual native callback/branch channels precede the production edit.
- [x] **ROOT CAUSE (WHY + WHERE)** — The required resolver in _lower_ast_array_end_mutation_method_statement returns the actual callback directly. Nested publication therefore reaches the parent invocation and opaque children borrow its eligibility. Actual packet/identity probes distinguish both failures; native local receiver-copy mutation and fallback are preserved, not reinterpreted.
- [x] **FIX** — Exactly one return becomes _bind_emission_dependency($cb); actual public callbacks/maps, guards and helper/result paths stay native. No optional/direct/secondary helper, AST grammar or authored-language expansion.
- [x] **ADDRESSED (verified)** — PASS858/cold8/native12/branches44/three syntax-valid source faults; identical12 RED/846 controls/858 GREEN. Supplied44 suites/164 files include unchanged public uniform binding. Five actual evidence corruptions and original356-binding corruption reject and restore. Complete book57+32/three controls, actual readonly composed review and283-live-input67540-byte publication agree; prior356 hashes/proof fields remain historical at b0099d9ad.
- [x] **NO REGRESSION** — Both required Perl syntax checks and standard public Phase0 PASS1035/1035 in1472 seconds. Broader helper/AST, optional/direct/output/mapped/full-private/parent/canonical admissions remain separately owned.
- [x] **LOCKSTEP** — Knowledge1335/10231 and book teaching/complete render pass. Qualitative TYPE-REFERENCE-BOOK/.8 findings are owned and scheduled without pivot; current ROADMAP_V2 frontier drift is repaired. Both bounded history checks, the exact staged memory handoff and whitespace pass. Ordinary doctrine hooks, including resulting-tree pressure, govern landing before assignment .3.1.3.3.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.3

- [x] **REPRODUCE / ISSUE** — Identical complete864 TAP against clean4fde89c19 retains exactly3 publication failures and861 passing controls. Actual native callback/branch observations precede the one production edit.
- [x] **ROOT CAUSE (WHY + WHERE)** — The hash-fallback required resolver in _lower_ast_assignment_operator_statement returns the actual key callback directly; nested child publication reaches the parent capture and opaque children borrow eligibility. Actual packet/identity controls distinguish both failures while native lazy validation and local key copies remain fixed.
- [x] **FIX** — One required return binds _bind_emission_dependency($cb). Public map/callback references, native source/fast-path guards, helper order, new target-span construction and direct results remain native; no complete secondary helper/AST grammar/language or optional/direct expansion.
- [x] **ADDRESSED (verified)** — PASS864/cold8/native3/branches66/three syntax-valid faults; paired3 original REDs/861 controls/864 current GREEN. Supplied46/166, evidence5, correct original283-binding corruption/restoration and complete book89/3 pass. Initial wrong-target instrument/result/reviewer stay exact and independently reject; corrected actual control restores PASS. Composed review and readonly291-live-input69504-byte publication agree; original283 proof/hash fields stay historical at4fde89c19.
- [x] **NO REGRESSION** — Both required Perl syntax checks and supplemental standard public Phase0 PASS1035/1035, with complete channels retained. Full transitive capsule/private/canonical admissions stay with existing parent owners; no runtime benchmark or output-volume comparison is inferred.
- [x] **LOCKSTEP** — Book teaching/render89/3 and Knowledge1336/10239 generation pass; stale planning-card projection repaired. Claim110/139/seven existing gaps, exact staged memory handoff, both history checks, matching roadmap projections and whitespace pass. Fresh readonly publication remains291 inputs/69504 bytes after complete compatibility retention. Ordinary doctrine hooks govern landing before main method/value .3.1.4.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.1.4

- [x] **REPRODUCE / ISSUE** — Identical518 TAP against clean049e1ba53 retains42 publication REDs/476 passing controls. Native42/branches23 observations precede the single production edit.
- [x] **ROOT CAUSE (WHY + WHERE)** — Main required resolver returns actual callbacks while the parent's publication slot stays active. Actual child eligibility/parent packet lookup distinguish donation and borrowed identity; eager validation, lazy initializer/key reacquisition and path-specific aliases remain native.
- [x] **FIX** — Bind one shared required return through the unchanged native-context helper. Preserve actual public callbacks/maps, native guard/acquisition order, local copies/shared array slots, readonly kind literal/source/span references, successful error effects and fatal objects. No public syntax/format or complete helper/AST/language expansion.
- [x] **ADDRESSED (verified)** — PASS518/cold10/native42/branches23/three effective syntax-valid faults; paired42 RED/476 controls/518 GREEN. Evidence5, original291-binding corruption/restoration, exact retained native drafts and complete book89/3 pass. Readonly299-input69961-byte claim agrees; all old291 proof/hash fields stay historical at049e1ba53.
- [x] **NO REGRESSION** — Supplied48 suites/168 files PASS. Both required syntax checks and supplemental standard public Phase0 PASS1035/1035 with complete channels retained. Broader/private/canonical input-capsule limits remain explicit.
- [x] **LOCKSTEP** — Knowledge1337/10249 and book teaching/render pass; framework-card stale frontier repaired. Current roadmap/index/live/history/memory handoff, both history checks and whitespace align. Exact final staged claim verification and all10 normal doctrine hooks govern landing before .3.1.5.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.0

- [x] **REPRODUCE / ISSUE** — Identical455 TAP against clean4b48593b5 retains9 publication REDs/446 passing controls. Native9/branches58 precede the two required source edits.
- [x] **ROOT CAUSE (WHY + WHERE)** — Both required resolvers return actual callbacks while parent publication remains active. Actual child eligibility and parent packet lookup distinguish nested donation/borrowed identity. Package-flow is a separate actual direct callback, diagnosed through public Toolbox and owned under P2 .3.2.0.
- [x] **FIX** — Bind only the two required resolver returns. Preserve actual public maps/callbacks, eager validation, local scalar copies, native source classification/guard/fallback order, empty/zero/reference results, scalar contexts, successful error effects and fatal objects. Optional selection and complete secondary helpers remain separate.
- [x] **ADDRESSED (verified)** — PASS455/cold11/native9/branches58/inverse6, paired9 RED/446 controls/455 GREEN. Evidence5/original299-binding restoration/book89/3 and readonly307-input73390-byte publication pass. Flow native16/169 and branch-removal RED retain the rejected compact-argument premise; six replay channels preserve raw stderr and normalize only its one expected ARRAY address. Rejected reviewer/actual rerun/raw diagnostic stay tracked.
- [x] **NO REGRESSION** — Supplied50 suites/170 files PASS. Both required syntax checks and supplemental public Phase0 PASS1035/1035 with complete channels retained. Full transitive/private/canonical admission stays separately owned.
- [x] **LOCKSTEP** — Knowledge1338/10259 and book teaching/render pass; two historical-card stale frontiers repaired. Matching roadmap/index/live/history/memory and whitespace align. Exact staged memory/claim verification and all10 normal doctrine hooks govern landing before generalized returns .5.1.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.1

- [x] **REPRODUCE / ISSUE** — Identical574 TAP against clean2c5f84092 retains9 publication REDs/565 controls. Native9/branches52/public9 precede the two required source edits; original initial565/partial28 instruments remain exact.
- [x] **ROOT CAUSE (WHY + WHERE)** — Both required resolvers return actual callbacks while parent publication stays active. Actual child eligibility and parent packet lookup distinguish nested donation/borrowed identity. Explicit owner import corrects the rejected fixture's loading premise; no production loading defect is inferred.
- [x] **FIX** — Bind only two required resolver returns. Preserve payload undefined guard before trim, eager statement parser/lazy label trim, public maps, local source copies and writable parser-array slots, native contexts/effects/errors/fatal/reference identity, AST/method/bare/raw64 guards and results. Secondary helpers remain explicit controls.
- [x] **ADDRESSED (verified)** — PASS574/cold15/native9/branches52/public9/inverse6, paired9 RED/565 controls/574 GREEN. Evidence5/original307 restoration/book89/3 and readonly306-input72937-byte publication pass. Exact loading-import and565-to574 alias refinements reconstruct; four historical172-file replays retain all raw channels, normalizing only one draft expected HASH address.
- [x] **NO REGRESSION** — Supplied52 suites/172 files PASS. Both required syntax checks and supplemental public Phase0 PASS1035/1035 with complete channels retained. Full transitive/private/canonical admission remains separately owned.
- [x] **LOCKSTEP** — Knowledge1339/10270 and complete book teaching/render pass; stale local-return current projection repaired, old migration recipes owned/scheduled under TYPE-REFERENCE-BOOK.1. Roadmap/index/live/history/memory and whitespace align; exact staged memory/claim and normal hooks govern clean landing before due hygiene/.5.2.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.2

- [x] **REPRODUCE / ISSUE** — Identical938 TAP against clean2b1f949b8 retains27 publication REDs/911 controls. Native27/branches60/public5 precede all three required resolver edits.
- [x] **ROOT CAUSE (WHY + WHERE)** — Required resolvers return actual callbacks while parent publication remains active. Actual child eligibility and parent packet lookup distinguish nested donation and borrowed identity.
- [x] **FIX** — Bind only three required resolver returns. Preserve eager validation, actual public maps, local copies, readonly initializer kind/writable source, shared target and distinct repeated operator trim/RHS-helper slots, native contexts/effects/errors/fatal/reference identities and guard/AST/regex/result order. Optional kind selection and secondary helpers remain explicit controls.
- [x] **ADDRESSED (verified)** — PASS938/cold17/native27/branches60/public5/inverse9, paired27 RED/911 controls/938 GREEN. Supplied54/174/evidence5/original306 restoration/book89/3 and readonly300-input71043-byte publication pass; no instrument correction or old result refresh.
- [x] **NO REGRESSION** — Supplied54 suites/174 files PASS. Both required syntax checks and supplemental public Phase0 PASS1035/1035 with full channels retained. Full transitive/private/canonical admission remains separately owned.
- [x] **LOCKSTEP** — Knowledge1340/10280 and book teaching/render pass. Roadmap/index/live/history/memory and whitespace align; exact staged memory/claim and normal hooks govern clean landing before remaining statement helpers .5.3.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.0

- [x] **REPRODUCE / ISSUE** — Identical539 TAP against clean ea6926fef retains15 publication REDs/524 controls. Native15/branches37/public3 precede the one required resolver edit.
- [x] **ROOT CAUSE (WHY + WHERE)** — The required resolver returns actual callbacks while parent publication stays active. Actual child eligibility and parent packet lookup distinguish nested donation and borrowed identity.
- [x] **FIX** — Bind only the set-key required resolver return. Preserve eager roles before AST fast path, actual parser/selected arrays and readonly arity literals, three trim slots versus local target/key/value copies, shared extractor/binding target, native contexts/effects/errors/fatal/reference/maps/results. Secondary helpers remain explicit controls.
- [x] **ADDRESSED (verified)** — PASS539/cold17/native15/branches37/public3/inverse3, paired15 RED/524 controls/539 GREEN. Supplied56/176/evidence5/original300 restoration/book89/3 and readonly296-input69937-byte publication pass. No instrument correction or old observation refresh.
- [x] **NO REGRESSION** — Supplied56 suites/176 files PASS. Both required syntax checks and supplemental public Phase0 PASS1035/1035 with full channels retained; full transitive/private/canonical admission stays separately owned.
- [x] **LOCKSTEP** — Knowledge1341/10286 and book teaching/render pass. Roadmap/index/live/history/memory and whitespace align; exact staged memory/claim and normal hooks govern clean landing before push required .5.3.1.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.1

- [x] **BUG / SYMPTOM** — Required push callbacks could donate nested equal-text publication or borrow parent identity across two/three-argument paths.
- [x] **PROOF** — Accepted d74c53485 complete850 TAP has exactly24 isolation REDs/826 controls. Final native24/branch56/public6 ledgers precede the one resolver edit; original probe correction remains immutable and independently reconstructible.
- [x] **ROOT CAUSE (WHY + WHERE)** — The required resolver returned actual callbacks while enclosing publication remained active. Actual child eligibility and parent packet lookup distinguish donation/borrowed identity.
- [x] **FIX** — Bind only the push required resolver return. Preserve four eager roles, actual raw/effective arrays and scalar aliases, repeated trim/extractor effects, native guards/order/maps/context/error/fatal/reference/results. Secondary helpers remain controls.
- [x] **ADDRESSED (verified)** — PASS850/cold15/native24/branches56/public6/inverse3, paired24 RED/826 controls/850 GREEN, supplied58/178/evidence5/original296 restoration/book89/3 and readonly303-input71948-byte publication. Original count/label/diagnostic-name instrument correction is fully retained/reconstructed.
- [x] **NO REGRESSION** — Supplied58 suites/178 files and both required syntax checks/public Phase0 PASS1035/1035 with complete channels retained. No full transitive/private/canonical admission inferred.
- [x] **LOCKSTEP** — Knowledge1342/10293 and complete book teaching/render pass. Both stale roadmap table cells corrected; history/whitespace pass and claim gate117/152/seven existing gaps passes. Exact staged docs/memory and normal hooks govern clean landing before .5.3.2.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.2

- [x] **BUG / SYMPTOM** — Required regex/undefined-return callbacks could donate nested publication or borrow parent identity across defined/default flags and plain return paths.
- [x] **PROOF** — Immutable179-file native probe retains24 callback outcomes/32 branches/four public Toolbox rows before assertion construction and two resolver edits. Identical619 TAP on accepted ae65603bc has exactly24 isolation REDs/595 controls; all619 current GREEN.
- [x] **ROOT CAUSE (WHY + WHERE)** — Both required resolvers returned actual callbacks while enclosing publication stayed active. Actual child eligibility and parent packet lookup distinguish donation and borrowed identity.
- [x] **FIX** — Bind only those two required resolver returns. Preserve five eager roles/three paths/eight role targets, local scalar slots, repeated stripping, writable defined/readonly default flags, actual normalizer arrays and readonly0/0 arities, maps/context/errors/fatal/reference/results.
- [x] **ADDRESSED (verified)** — PASS619/cold23/native24/branches32/public4/inverse6, paired24 RED/595 controls/619 GREEN, supplied60/182/evidence5/original303 restoration/book89/3 and readonly307-input73113-byte publication. Original fault-generator failure and exact separate EOF fix are retained/reconstructed; native probe/assertions remain unchanged.
- [x] **NO REGRESSION** — Supplied60 suites/182 files and both required syntax checks/supplemental public Phase0 PASS1035 with complete channels retained. Existing .59 and newly owned receiver-copy failures stay explicitly separate; no broader admission inferred.
- [x] **LOCKSTEP** — Knowledge1343/10299/book teaching/render and staged claim118/154/seven existing gaps PASS. Duplicate index projections repaired; continuity/history/memory/whitespace align. Exact staged handoff and normal doctrine hooks govern ordinary landing; P1 receiver repair is owned and scheduled.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.0

- [x] **REPRODUCE / ISSUE** — Immutable184-input probe and identical50 original TAP retain9 semantic REDs/41 controls: scalar-held hash .copy() returns[] in live, standalone and poisoned-source typed AST execution, while function-form and multi-step controls work.
- [x] **ROOT CAUSE (WHY + WHERE)** — AST copy_starts_hash_receiver_chain recognizes aggregate hash kind or later hash methods, but bare assignment remembers scalar storage. Single-step scalar-held hashes fall into array wrapping. Full actual Get/generated/typed source and result channels retain the mechanism.
- [x] **FIX** — One exact12-line AST insertion routes a scalar-bound variable, one copy call and zero arguments through the existing aggregate function-form copy lowerer. Preserve all other receiver/arity/family selection and actual typed receiver fields.
- [x] **ADDRESSED (verified)** — PASS50 with exact9-RED/41-control original names. Live/standalone14-case ledgers preserve hash/array/empty/scalar values, outer/nested identity and typed source poisoning. Three syntax-valid complete source faults fail9/4/8 named assertions; evidence5/original307 restoration and the final composed publication pass. No native probe/assertion correction. Exact book/census/scanner/historical prerequisites have their own retained proof stages.
- [x] **NO REGRESSION** — Supplied61 suites/184 files pass, retaining all60 predecessor suites plus the regression. Legacy rule aggregate array, wrong arity and multi-step controls remain exact. Exact staged canonical receipt is required before landing this public repair; no broader factory admission inferred.
- [x] **LOCKSTEP** — Knowledge1346/10319 and final book89/three controls pass. Current roadmap/index/live/history/memory align; exact staged memory/history/whitespace and canonical receipt/normal doctrine hooks govern intended clean landing before legacy .6.0.1.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.1

- [x] **REPRODUCE / ROOT CAUSE** — Injected kind callbacks were ignored for package state. First-native35 cases/23 controls/12 intended repairs plus cold2 retained before four-line binding change;487 paired TAP has48 original semantic REDs/439 controls.
- [x] **FIX / VERIFIED** — Select actual CODE once before trim or undefined default; isolate its publication. All487 current pass; five syntax-valid complete faults fail48/3/9/5/3. Context, actual match aliases/write rejection, maps/effects/errors/fatal identity and native guards retain behavior.
- [x] **ORACLE / DURABILITY** — Independent Perl four-case slot/write probe, six actual evidence RED/restorations, byte-exact correction replays and original546 Git binding preservation pass. Original draft/failed wrapper remain recoverable; no native/runtime/CI observation refreshed.
- [x] **NO REGRESSION / LOCKSTEP** — Supplied61 suites/187 inputs/11664 assertions, book89/three controls and supplemental syntax/public Phase01035 pass. Claim/Knowledge/roadmap/continuity align; normal focused hooks govern landing before .3.1.6.1.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.1

- [x] **REPRODUCE / ROOT CAUSE** — First189-input native8 callback/34 branch/4 authority/2 public Toolbox/2 cold rows retain raw required child donation. Original215 TAP has exactly6 authority REDs/209 controls before the one-return binding.
- [x] **FIX / VERIFIED** — Bind required trim/parser resolver return, keeping eager selection/maps/context/errors/fatal identity and actual substring aliases. All215 current pass; five full syntax-valid faults fail6/2/4/3/4 with identical plans and named semantic reasons.
- [x] **DURABILITY / ORACLES** — All322 original Git bindings preserved. Seven actual evidence RED/restorations include hash-only and beyond-binding semantic/checkpoint controls. Original consumer outer1 retained; first evidence partial channels unavailable and excluded from measured scope. Fresh corrected recurrence retains every reached channel before assertions.
- [x] **FOCUSED COMPATIBILITY / BOOK** — Actual62 suites/191 inputs/11879 assertions, complete command/header/plan census and exact predecessor diagnostic bytes pass. Full book89/three controls and derived Knowledge1349/10337 agree. Standard syntax/public Phase01035 and readonly314-input/74509-byte publication pass; ordinary gates and normal hooks govern landing.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2

- [x] **REPRODUCE / ROOT CAUSE** — Immutable193-input native16 callback/73 branch/8 authority/4 public Toolbox/4 cold rows precede identical436 original TAP with12 exact authority REDs/424 controls. Raw required children donate publication in both owners.
- [x] **FIX / VERIFIED** — Two resolver returns bind four retained actual callbacks. All436 current pass; ten separate syntax-valid complete faults fail6/2/4/3/4 for number and6/2/6/3/4 for string. Actual substring effects, parser-returned object annotation/shared references, eager selection, maps/context/errors/fatal identity and cold loading stay native.
- [x] **ORACLES / DURABILITY** — All314 original Git bindings remain historical. Seven actual evidence RED/restorations retain all reached channels and changed bytes, including beyond-binding semantic/checkpoint denials. Exact first reviewer draft and two failed outer-preflight transcriptions remain recoverable; only the anchored diagnostic reader changes, with no native/runtime refresh.
- [x] **NO REGRESSION / LOCKSTEP** — Supplied63 suites/195 inputs/12315 assertions, all actual ordered paths/headers/plans and exact predecessor diagnostics pass. Book89/three controls, Knowledge1349/10343, standard syntax/public Phase01035 and readonly337-input/83792-byte metadata closure pass; original323 publication/card/publisher remain exact and replayable. Both history roots preserve all predecessor bytes outside their sole new complete records. Normal focused hooks govern landing; finite notes prerequisite .6 is next.
- [x] **COMMIT BLOCKER RESOLVED** — Existing-card consolidation retains both bodies/all13 questions and every original323 hash. Original exact publication healthy/card RED/restored PASS and two metadata RED/restorations pass. Readonly337/83792 and the actual restaged README20/62/40 gate pass; no native/runtime/book refresh or limit increase. First failed hook boundary and interrupted later checks remain explicit.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6

- [x] **BUG / SYMPTOM** — Next complete note requires rollover; the old gate rejects the archive slot and manifest lines/bytes.
- [x] **PROOF / ROOT CAUSE** — Actual464-line/59032-byte pressure and old47/46,46/45,27857/27245 admission REDs are retained. Independent clean-Git reconstruction preserves224 immutable files and the exact suffix/blob/range/digest/root/manifest.
- [x] **FIX** — Sole ADR0133 admits one measured member,612 manifest bytes/one line and35 decision/index lines. All unrelated/root/aggregate/per-file limits stay exact; no future reserve.
- [x] **ADDRESSED / NO REGRESSION** — Production30 thresholds/23 authority denials, three reviewer and two preservation REDs each restore. Original337 scalar bindings and all claim fields remain historical without refresh. Runtime/checkers/dependencies stay exact; full book89/3 passes.
- [x] **LOCKSTEP** — Existing capacity card retains original body/questions and adds three; readonly377/103173 publication, live roadmap/index/memory and both history checks align. Exact staged canonical receipt and all normal hooks are required for landing; no full private-fixture admission is inferred.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6.1

- [x] **REPRODUCE / ISSUE** — Actual stale capacity.py review exits1 against current notes while the accepted guarded baseline passes; complete pre-edit channels retained.
- [x] **ROOT CAUSE (WHY + WHERE)** — Tool-backed traceback identifies historical verify_base root reconstruction at capacity.py:264. The current correction changes one readonly pointer, with every other ADR byte compared against accepted Git. Initial recovery omissions and variable shadowing have retained exact drafts, named failure boundaries and separate corrected proof.
- [x] **FIX** — ADR0133 names the current readonly review.py; the existing related card and book explain historical input boundaries. No capacity authorization, registry or runtime changes.
- [x] **ADDRESSED (verified)** — Current reviewer PASS; actual original publication395-input PASS/two named REDs/restoration and three current-reviewer REDs/restorations pass. Original377 hashes/full claim preserved without refresh; the17 historical hygiene inputs derive from their original published claim.
- [x] **NO REGRESSION** — Full mdbook build proof89/three controls passes; historical producers and observations remain exact. Parent canonical CI/public Phase01035/CLI66 per environment passed at d95a25c8b. This ordinary documentation repair requires focused checks and normal hooks, with no new runtime admission claim.
- [x] **LOCKSTEP** — Readonly publication115 live/395 historical inputs/121873 bytes, reused Knowledge card, roadmap/index/live/MEMORY and bounded histories align. Ordinary doctrine/memory/whitespace checks and all normal commit hooks govern landing before hash activation.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.3

- [x] **REPRODUCE / ISSUE** — Immutable first-native197-input inventory retains8 callback outcomes/52 branches/4 actual authority/2 public-source/2 cold rows before assertions or source edits. Original paired308 TAP has6 named authority failures and302 passing controls.
- [x] **ROOT CAUSE (WHY + WHERE)** — The required hash resolver returns raw children, allowing parent capture to receive their publication. Eager trim/parser selection, actual splitter aliases, caller maps and parser-returned shared objects are independently retained; hash owner adds no source annotation.
- [x] **FIX** — Only the one required resolver return binds the actual callback with _bind_emission_dependency; optional kind handling and every other Module byte remain accepted Git-exact.
- [x] **ADDRESSED (verified)** — Identical308 current assertions pass; actual opaque/known child eligibility and zero parent packet distinguish isolation from wrapper identity. Five complete syntax-valid faults fail6/2/4/5/8; seven actual evidence REDs each restore.
- [x] **NO REGRESSION** — Path-complete supplied64 suites/199 inputs/12623 assertions, native value/alias/context/error/fatal/maps/shared-reference/copy-family/terminal controls and book89/three controls pass. Standard syntax/public Phase0 passes1035 with full channels; no full transitive input capsule or broader admission is claimed.
- [x] **LOCKSTEP** — All115 original bindings/full claim remain historical at e4507973a without refresh; the actual accepted publisher baseline and mode/revision-only reconstruction pass. Readonly321/75495 publication, reused Knowledge card, book/roadmap/index/live/MEMORY and bounded histories align. Normal focused gates/hooks govern landing before .3.1.6.4.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.4

- [x] **REPRODUCE / ISSUE** — Completed native201-input capture retains12 callback outcomes/57 branches/6 authority/4 public-source/2 cold rows before assertions or production edits. Original paired325 TAP has9 named authority failures and316 passing controls. Original compile-failed first attempt/full inner channels/input census remain exact.
- [x] **ROOT CAUSE (WHY + WHERE)** — The legacy array-end parser's raw required resolver allows callback publication to reach an enclosing producer. Actual structured-result serialization, eagerly selected parser/extractor, splitter and returned payload-slot aliases, fallback/guards and caller maps are independently retained. Original instrument failure is exactly an undeclared case-loop variable; only that loop is corrected before successful native observations.
- [x] **FIX** — Only the one required resolver return in _parse_array_end_mutation_method_statement binds the actual callback through _bind_emission_dependency. Every other Module byte stays accepted Git-exact; actual argument and returned-object identities remain native.
- [x] **ADDRESSED (verified)** — Identical325 assertions pass, with actual opaque/known eligibility and zero parent publication under explicit outer serialization. Five full syntax-valid faults fail9/3/36/9/18. Eight actual evidence REDs each restore, including concealed compile failure beyond its updated immediate correction hash.
- [x] **NO REGRESSION** — Path-complete supplied65 suites/203 inputs/12948 assertions and book89/three controls pass. Standard syntax/public Phase0 passes1035 with complete channels; no full transitive input capsule or broader admission is claimed. The greedy injected-parser tail example is a delegated callback control, not public grammar acceptance; all four public mutation source controls remain exact.
- [x] **LOCKSTEP** — All321 accepted hash bindings/full claim and actual baseline remain historical at98990ffbc without observation refresh. Exact failed instrumentation/sole repair and wrong-wrapper126 preflight are explicit, with unavailable original outer transport envelopes disclosed. Readonly329/78324 publication, reused Knowledge card, book/roadmap/index/live/MEMORY and bounded histories align. Normal focused hooks govern landing before .3.1.6.5.

## Verification Log

- `2026-10-19`, `.5.8`: independent544-input review and readonly550/full128458 publication PASS; actual old-cap RED and1980/1981 original-project inputs;230 unchanged files/exact257-line archive;60 numeric/31 authority controls after independent original census RED; seven full artifact denials/restorations; Knowledge1487/1349/8388337 and book89/four controls. Exact staged canonical CI/receipt and normal hooks govern infrastructure landing; due artifact review follows clean commit.

- `2026-10-18`, `.5.7`: corrected mixed445/53 and object444/100 proofs all GREEN;28 source faults; native mixed26/26/object108/108 exact;91/363/30394 consumers; diagnostics358/16 before/after; eight standard commands/public1035; ten artifact controls; Knowledge8388255/book89/four; original546/full127929 saved and actual2020-file replay; readonly corrected565/full129686. Normal focused hooks and explicit memory/history/whitespace plus post-pointer/brief0/clean checks govern landing. .5.8 remains next.

- `2026-10-18`, `.5.5`: original176 native rows/recurrences exact; paired452/77 RED/375 controls/all GREEN;12 full-source faults;88 suites/339 inputs/28214 assertions; public diagnostics336/16 before/after; standard1035; evidence5; Knowledge8388480/book89/four; readonly506/full116166. Explicit memory/history/whitespace/all10 doctrines PASS; normal hook/post-commit checks required.

- `2026-10-18`, `.5.4`: Output .5.4 binds six required roles through four validator returns; all22 required validators now use the existing private helper. All432 native rows/recurrences stay exact; identical1146 assertions retain264 original authority REDs/882 controls and all GREEN. Thirteen complete-source faults reject. All87 supplied suites/332 inputs/27762 top-level assertions and dedicated public diagnostics before/after329 inputs/16 top-level assertions pass. Standard public Phase01035, nine artifact controls, full Knowledge1486/1349/twelve overlays/8388501 bytes, book89/four controls and public guard pass. Whole prior480/full111654 publication/baseline stays historical at4a8e92aef. Original duplicate-label guard rejection and exact correction remain frozen. Readonly publication binds495 compiler inputs/full117562 bytes; its separate kernel sample explicitly leaves a falsification gap with existing startup.7. Wrapper source, recovery and purge are unchanged. Optional kind .5.5 follows clean landing, then direct/rule .5.6, mixed defaults .5.7, registration .7, pipeline .6, metadata .12 and TYPE-REFERENCE-BOOK. Broader admissions remain open. Normal all-doctrine hooks govern focused landing.

- `2026-10-18`, `.5.3`: Switch .5.3 binds six required normalizers through six original validator returns. All630 ordinary native rows/recurrences remain exact; identical1641 assertions retain273 original authority REDs/1368 controls and all GREEN. All85 supplied suites/317 inputs/26600 assertions and standard public Phase01035 pass. Fifteen complete-source faults reject; the copied-array variant has no observed witness and stays outside the sensitivity claim. Nine artifact denials/restorations pass. Whole prior463/full109061 publication and actual baseline stay historical at09000223f. First465-input proof stays frozen and replays before the single workflow-paragraph correction; both full book89/four-control epochs pass. Knowledge1486/1349/twelve overlays/8388218 bytes and public guard pass. Readonly480-input/111654-byte publication owns current routes. No public contract, dependency, gate or budget changes. Output .5.4 follows clean focused landing, then optional kind .5.5, dispatch/rule .5.6, defaults .5.7, fixture .7, pipeline .6, metadata .12 and TYPE-REFERENCE-BOOK. Independent broader admissions stay open. Normal all-doctrine hooks govern focused landing; no canonical admission claimed.

- 2026-10-12 — PERL-PRIVATE-FACTORY-CAPTURE.5.0: ControlFlow foundation .5.0 isolates required dependencies in control value, switch case value and bare marker normalization: three validators and seven roles. Native scalar callbacks retain their own actual identity; the switch tag normalizer keeps its native list context with publication disabled. Public maps/references, eager selection, argument aliases, diagnostic lines, ordinary effects/errors/fatal objects and cold loading remain exact. Native100/176 warm/132 cold recurs exactly; all308 original ordinary rows match. Identical848 assertions retain198 original authority REDs/650 controls/all GREEN. Thirteen complete-source faults,80 supplied suites/277 inputs/21482 assertions, six coherent artifact denials/restorations, full Knowledge1485/1349/nine overlays and book89/four controls pass. Original449/full106177 and actual baseline remain historical at aa8823343. The first reader serialization failure remains immutable; the distinct final reader compares complete decoded records and binds both exact gzip identities. Knowledge8384946 stays within unchanged8388608. Supplemental strict-vars/standard syntax/public Phase01035/composed guard pass. Readonly428-input/100775-byte publication owns current routes. Branch plumbing .5.1 follows the clean focused landing; .5.2–.5.7 precede fixture .7, pipeline .6, metadata .12 and TYPE-REFERENCE-BOOK. Independent helper/private/parent/canonical admissions remain open. Actual standard48734/0, independent review32918/0, evidence1960/0 and publication42597/0 complete. Normal focused commit hooks govern landing.

- `2026-10-11`, `.3.2.1.2`: Native18/105/6/cold9, symbolic42/object10; first1135/58 retains one wrong oracle, final1135/57 RED/1078 controls/allGREEN. Nine faults15/15/27/7/29/34/19/12/70; supplied69/223/15093, evidence6/book89/3/original339/full78325/standard1035 and readonly366/85779 PASS. Three owned bindings only; warning/oracle/census first failures/sole repairs exact. Normal focused hooks govern landing; due hygiene then P2 cache .9 before .3.

- `2026-10-11`, `.3.2.0`: Package-flow .3.2.0 isolates the single direct package callback while preserving actual package selection, trimmed-slot aliases, context/maps/replacement/errors and public generated source. Native209/4 outcomes/32 branches/2 authority/2 public/2 cold precedes paired299:3 original isolation REDs/296 controls/all299 GREEN. Six source faults, final supplied67/211/13660, seven evidence RED/restorations, book89/3 and supplemental standard syntax/public Phase01035 pass. Original350/full84391 publication and first instruments/channels remain exact. Normal focused hooks govern landing before remaining optional/direct .3.2.1; TYPE-REFERENCE-BOOK and independent admissions stay queued. Fixture registration .7 precedes pipeline .6.

- `2026-10-11`, `.3.1.6.4`: Required array-end .3.1.6.4 binds one resolver return for trim/parser/extractor, preserving eager selection, actual payload argument slots, splitter effects, structured results, maps/context/errors and fatal identity. Completed native201/12 callbacks/57 branches/6 authority/4 public-source/2 cold precedes paired325:9 original authority REDs/316 controls/all325 GREEN. Five faults fail9/3/36/9/18; supplied65/203/12948, evidence8/original321 and book89/three controls pass. Standard syntax/public Phase0 passes1035 with full channels; readonly329-input/78324-byte publication passes. Compile-failed instrumentation and wrong-wrapper preflight remain explicit without runtime refresh. Normal focused hooks govern landing before hash-index .3.1.6.5; optional/direct, independent admissions and TYPE-REFERENCE-BOOK stay queued. Fixture registration .7 precedes pipeline .6.

- `2026-10-11`, `.3.1.6.3`: Required hash .3.1.6.3 binds one resolver return and preserves eager trim/parser selection, substring effects, actual shared call references without annotation, maps/context/errors and fatal identity. Immutable native197/8 callbacks/52 branches/4 authority/2 public-source/2 cold precedes paired308:6 original authority REDs/302 controls/all308 GREEN. Five full-source faults fail6/2/4/5/8; supplied64 suites/199 inputs/12623 assertions, evidence7/original115 and book89/three controls pass. Standard syntax/public Phase0 passes1035 with full channels; readonly321-input/75495-byte publication passes. Normal focused hooks govern landing before array-end .3.1.6.4. Optional/direct, independent admissions and TYPE-REFERENCE-BOOK remain queued; fixture registration .7 precedes pipeline .6.

- `2026-10-11`, `.3.1.6.6.1`: Review-command repair .3.1.6.6.1 replaces only ADR0133's stale pointer and related current guidance. All377 accepted bindings remain historical at d95a25c8b, whose canonical CI and normal hooks passed. Actual accepted-publication recovery supplies395 files (377 live bindings,17 historical hygiene inputs and its full claim), rejects changed ADR/omitted input and restores PASS. Three current-reviewer REDs each restore; book89/three controls and readonly115-input/121873-byte publication pass. Both failed recovery drafts remain exact with their observed limits; no original producer/hash/observation refresh or runtime/capacity change. Required hash .3.1.6.3 follows this focused commit; TYPE-REFERENCE-BOOK and independent admissions remain queued.

- `2026-10-11`, `.3.1.6.6`: Finite notes prerequisite .3.1.6.6 preserves all224 prior immutable history/decision files and337 accepted scalar bindings at clean d8418423e. Exact segment4961/612 manifest bytes/one line and sole ADR0133/index35-line overhead are independently reconstructed. Actual next-note and old admission REDs, production30 thresholds/23 authority denials, three reviewer/two preservation REDs with exact restoration, full book89/3 and readonly377-input/103173-byte publication pass. Existing related Knowledge card retains its historical body/questions; no slot or future reserve is added. Exact staged canonical CI/receipt and normal hooks govern admission before hash .3.1.6.3; remaining families, TYPE-REFERENCE-BOOK and independent admissions stay queued.

- `2026-10-11`, `.3.1.6.2`: Required number/string .3.1.6.2 binds four actual trim/parser callbacks through two resolver returns, preserving eager selection, substring effects, actual parser-returned object annotations, maps/context/errors and fatal identity. Paired436 assertions retain12 original authority REDs/424 controls/all436 GREEN; ten separate full-source faults, supplied63/195/12315, evidence7/original314 and book89/3 pass. The first reviewer label error and premature dependent preflight are retained and repaired without native/runtime refresh. Supplemental standard syntax/public Phase0 passes1035 with complete channels; readonly337-input/83792-byte metadata closure passes; original323 publication/card/publisher remain exact and replayable. Finite notes rollover prerequisite .3.1.6.6 precedes hash .3; remaining required families, TYPE-REFERENCE-BOOK and independent admissions stay queued. Canonical private-fixture registration .7 precedes pipeline .6.

- `2026-10-11`, `.3.1.6.1`: Required array receiver .3.1.6.1 binds its two required trim/parser callbacks while preserving actual substring effects, eager selection, maps/context/errors and caller values. Paired215 assertions retain6 original authority REDs/209 controls/all215 GREEN; five full-source faults, supplied62/191/11879, evidence7/original322 and book89/3 pass. Original consumer/evidence refusals and unavailable partial-channel limits are explicit; separate path-complete and fresh controls govern proof. Supplemental standard syntax/public Phase0 passes1035 with complete channels; no full transitive input capsule. Number/string .3.1.6.2 follows; other required families, TYPE-REFERENCE-BOOK and independent admissions remain queued. Canonical private-fixture registration .7 precedes pipeline activation .6. Current readonly review/evidence validate exact observations and changed-byte controls; first partial evidence channels remain explicitly unavailable.

- `2026-10-11`, `.3.1.6.0.1`: P2 legacy hash kind callback .3.1.6.0.1 selects the injected CODE callback once before trim and defaults missing/non-CODE to unknown. First-native35 cases retain23 complete controls/12 intended repairs plus two cold rows; paired487 assertions retain48 original REDs/439 controls/all487 GREEN. Five syntax-valid faults fail48/3/9/5/3. Supplied61 suites/187 inputs/11664 assertions, six evidence RED/restorations and book89/3 pass. Independent Perl5.34.1 four-case slot/write oracle proves a match argument can have readonly flag0 yet reject writes. All546 predecessor bindings remain historical at770cffcc, with original observations and both bounded instrument corrections retained/replayed. Supplemental standard syntax/public Phase0 passes1035; no full transitive capsule or broader admission is inferred. Required array receiver .3.1.6.1 follows, then .6.2-.6.5; TYPE-REFERENCE-BOOK and independent admissions stay queued. Readonly review/evidence/publication and required focused checks govern landing.

- `2026-10-10`, `.3.1.6.0.0`: P1 scalar-bound receiver-copy .3.1.6.0.0 verifies50 assertions, original9 REDs/41 controls/50 GREEN, live/standalone14-case ledgers, typed source poisoning and shallow snapshot identity. Three source faults reject9/4/8; supplied61/184, evidence5/original307 restoration and book89/3 pass. Exact CI inverse/native registration RED, complete192 supplied inputs,22 recovery/74 evolution controls and evidence3 pass. Initial runtime publication is retained; its publisher extension adds the CI supplement without refreshing native proof. Readonly304-core/198-CI bindings and118034-byte claim pass. Fresh exact canonical receipt and normal hooks govern landing. Legacy hash callback .3.1.6.0.1 follows, before required .6.1-.6.5; TYPE-REFERENCE-BOOK and independent admissions stay queued.

- `2026-10-10`, `.3.1.5.3.2`: PASS619/23/native24/branches32/public4/inverse6, paired24 RED/595 controls/619 GREEN, native179/test182/supplied60/evidence5/original303/book89/3 and readonly307/73113. Both syntax checks/public Phase0 PASS1035/full channels; claim118/154/seven existing gaps and Knowledge1343/10299 PASS. Exact staged memory/history/diff and normal hooks govern landing. Routing .5/.5.3 close only their verified children; independent admissions remain open.

- `2026-10-10`, `.3.1.5.3.1`: Push required .3.1.5.3.1 verifies850/cold15/native24/branches56/public6/inverse3, paired24 RED/826 controls/850 GREEN and supplied58/178/evidence5/book89/3. All296 original set-key bindings stay historical at d74c53485; readonly303-input71948-byte claim passes. Four eager roles preserve actual raw versus copied effective arrays, repeated trim/extractor effects, local scalar copies and final extractor/binding identity. Original count/public-label/diagnostic-name probe correction is retained and independently reconstructed. Secondary helpers and independent admissions remain separate. Both stale roadmap table next-task cells are corrected. Both required syntax checks and supplemental public Phase0 PASS1035/1035 with full channels retained; normal hooks govern clean landing. Regex/undefined-return .5.3.2 follows clean handoff; TYPE-REFERENCE-BOOK stays queued.

- `2026-10-10`, `.3.1.5.3.0`: Bounded539/cold17/native15/branches37/public3/inverse3, paired15 RED/524 controls/539 GREEN, supplied56/176/evidence5/original300 restoration/book89/3 and readonly296-input69937-byte publication PASS. Actual parser/selected arrays, readonly arities and trim/local scalar slots remain exact. Both required syntax checks and supplemental public Phase0 PASS1035/1035 with full channels retained. History/memory/claim/diff and normal hooks govern clean landing.

- `2026-10-10`, `.3.1.5.2`: Bounded938/cold17/native27/branches60/public5/inverse9, paired27 RED/911 controls/938 GREEN, supplied54/174/evidence5/original306 restoration/book89/3 and readonly300-input71043-byte publication PASS. Native eager roles, readonly kind/source and repeated trim slots remain exact. Both required syntax checks and supplemental public Phase0 PASS1035/1035 with full channels retained. History/memory/claim/diff and normal hooks govern clean landing.

- `2026-10-10`, `.3.1.5.1`: Runtime574/cold15/native9/branches52/public9/inverse6, paired9 RED/565 controls/574 GREEN, supplied52/172/evidence5/original307 restoration/book89/3 and readonly306-input72937-byte publication PASS. Original partial28 loading draft/initial565 remain exact; four historical172-file replays normalize only one expected HASH address, with raw channels retained. Both required syntax checks/public Phase0 PASS1035/full channels. Knowledge1339/10270, history/diff and exact staged normal hooks govern landing.

- `2026-10-10`, `.3.1.5.0`: Main455/cold11/native9/branches58/inverse6, paired9 RED/446 controls/455 GREEN, supplied50/170/evidence5/original299 restoration/book89/3 and readonly307-input73390-byte publication PASS. Native flow16/169/branch-removal RED and all original/replay channels remain retained; only one actual Test::More ARRAY address is normalized. Both required syntax checks and supplemental public Phase0 PASS1035 with complete channels. Knowledge1338/10259, history/whitespace and exact staged handoff/normal doctrines govern landing.

- `2026-10-10`, `.3.1.4`: Main518/cold10/native42/branches23/inverse3, identical42 RED/476 controls/518 GREEN, supplied48/168/evidence5/original291 restoration and book89/3 PASS. Actual native drafts and deterministic traceback-path review retain every original instrument/result. Readonly299-input69961-byte publication agrees; both required syntax checks/public Phase0 PASS1035 with complete channels. Knowledge1337/10249 and history/memory/task/whitespace checks pass; exact staged normal doctrines govern landing before .3.1.5.

- `2026-10-10`, `.3.1.3.4`: Focused capacity222/30/23/4, original279 preservation/corruption, instrument chain and book89/3 PASS; readonly356-input claim86568 bytes. Exact clean-source suffix112/27100 and every old immutable/manifest/ADR byte survive. All initial matcher/source-blob/separator defects stay retained; final metadata13180 accounts exactly for index growth2. Canonical staged receipt and normal hooks govern admission; no future reserve or runtime change.

- `2026-10-10`, `.3.1.3.1`: Bounded695/cold12/native18/branches44/inverse3, paired18 RED/677 controls/695 GREEN, supplied41/160/evidence5/original-binding restoration and book89/3 PASS. Original280 bindings stay historical at2e9e5443e; readonly279-live-input publication67298 bytes. Both required Perl syntax checks and standard public Phase0 1035/1035 in1186 seconds PASS. Claim107/133/7 and Knowledge1331/10207 PASS; final ordinary checks/hooks govern landing.

Planning/routing verification belongs to `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.3.0`.

- `2026-10-10`, `.3.1.2.3`: Uninterrupted approved-host canonical CI passes all10 doctrines, repaired historical recovery, cross-backend admissions, selector retirement, six-family process containment, relocated primary anchors, CLI66/66 in each option environment and public Phase0 1035. Restricted sandbox-exec no-op exits71; approved-host no-op exits0, matching the existing documented harness prerequisite. No profile/checker weakening occurs. Exact candidate fe7baef9aba4d179759b913347ff4a775642279d6aa65a91d3dda00d5831bbea receipt matches before commit; normal hooks pass all10, post-commit activation matches CDC and receipt promotes to268891fdf. Brief0 and clean Git are verified before the next leaf activates.

- `2026-10-10`, `.3.1.2.2.0`: Bounded proof PASS115/cold4, native6/roles2, paired6 original RED/109 controls/115 current GREEN, inverse3, supplied35/154, evidence5, original-binding RED/restoration and complete book57+32/3. All399 original capacity/audit live bindings freeze at268891fdf with all older fields unchanged. The65482-byte readonly publication gates273 live inputs and compact original-record/final-publisher historical identities. Standard public Phase0 compatibility passes1035/1035 with both required syntax checks; ordinary doctrine hooks govern landing.

- `2026-10-10`, `.1`: PASS224/11, native30, supplied17/136, evidence4/book57/2 and original232 preservation. The four initial draft identity failures are retained and diagnosed, with no production change hidden by their fixture correction. SourceEmissions syntax is checked in every source-fault run; direct supplied consumers recur. All normal doctrine hooks are required before landing.
- `2026-10-10`, `.1`: Initial commit hooks rejected the missing formal acceptance checklist in this new tree. The completed checklist above now cites the existing actual proof and its limits; no runtime instrument, artifact or source changes for this workflow correction.

- `2026-10-10`, `.2.0`: EmitContext passes345 main/five cold assertions,30 exact native/current observation ledgers and13 effective semantic source faults. Nineteen direct suites in138 supplied files, four actual reviewer REDs and complete57-source book/two controls pass. Actual definition-owned references select28 native callbacks; same-name replacements and copied metadata remain opaque. Resolved owner/default-factory calls cannot donate nested publication in six scalar/list/void modes. Existing argument copies, shared references, return/error/fatal identities, actual factory maps and lazy loading remain unchanged. All233 original framework bindings are historical atb21b3bb9. Contracts construction/dependency integration .2.1 is next; pipeline/output/full-private/mapped/canonical obligations remain open.

- `2026-10-10`, `.2.1.0`: Contracts private dependency/default integration passes312 main/six cold assertions,15 exact native/current observation ledgers and16 effective semantic source faults;21 direct suites in140 supplied files, evidence4 and complete book57/two controls pass. Required/optional/bare calls retain actual callbacks in private native-context bindings; public maps/default results/lower fields stay unchanged. Built-in target plus retained definition identity selects native defaults. Actual input_slice, dropped fallback and both bare push paths deny opaque nested publication. All235 original EmitContext bindings are historical at2d8784780. One draft lifetime failure is reproduced on original/current sources and fixed only in the lexical-state fixture; all failed channels/probe inputs remain. Actual lower construction .2.1.1 is next; other owners/pipeline/output/full-private/mapped/canonical obligations remain open.

- `2026-10-10`, `.2.1.1`: Actual local/delegated lower construction passes447 main/six cold assertions and20 effective semantic source faults. Two complete174-entry native/current catalogues match metadata/order, ordinary benign-input values and callback reuse patterns. All174 actual returned callbacks select in their current scope; twelve local return seams preserve actual array/hash/lower references and fourteen substituted factories remain opaque. Twenty-three suites in142 supplied files, evidence4 and complete book57/two controls pass. Nested source/producer selection restores, a lexical callback releases at scope exit, and cold construction stays lazy. All248 original dependency bindings are historical atbe7d70719. MethodLowering .3 is next; other dependency owners/pipeline/output/full-private/mapped/canonical obligations remain open.

- `2026-10-10`, `.3.0`: PASS426/cold6, exact native/current2x19 maps,24 effective semantic source faults and supplied25/144. Evidence4, original244 preservation with actual RED/restored PASS and complete book57/two controls pass. Initial30 all-GREEN captures retain their original producer; prose-only inverse-scope correction is reconstructed before accepting unchanged-source recapture. All normal doctrine hooks govern admission.

- `2026-10-10`, `.3.1.0`: Private trim bindings pass255 main/five cold assertions and13 effective syntax-valid source faults. The same full fixture has exactly eleven original publication-isolation REDs and all255 current GREEN, with244 original controls passing. Fifteen native dependency and nine actual caller ledgers match context, aliases, copied top-level inputs, public references and value/effect/error/fatal behavior. Twenty-seven suites in146 supplied files, evidence4, original-binding RED and complete book57/two controls pass. All282 original method-default bindings remain historical at89a4ede6f. The partial attempt retains18 actual captures/producer; only two inherited assertion matcher labels change before recapture, with unchanged production/fixtures. Other required .3.1 children, optional/direct .3.2, other owners/pipeline/output/full-private/mapped/canonical and parent obligations remain open. Ordinary doctrine hooks govern admission.

- `2026-10-10`, `.3.1.1`: Three MethodLowering assignment/declaration required resolvers pass 277 main/four cold assertions and nine effective syntax-valid source faults. All eight callback roles and 25 native/current ledgers match; the same complete fixture has exactly 24 original publication-isolation REDs, 253 original passing controls and 277 current GREEN. Twenty-nine suites in 148 supplied files, evidence5, original-binding RED/restoration and complete book57/two controls pass. All262 original trim bindings stay historical at429d0c6d. An early review started before consumers.json existed; the fifth actual evidence control reproduces that missing-result rejection and restores PASS, with unchanged production/fixtures/capture programs. Inline/block .3.1.2 is next; remaining required/optional, other owners/pipeline/output/full-private/mapped/canonical and parent obligations remain open. Ordinary doctrine hooks govern staged admission.

- `2026-10-10`, `.3.1.2.0`: Two inline if/switch required resolvers pass177 main/cold4 and six effective syntax-valid source faults. All five actual roles and15 native/current ledgers match; paired complete177 TAP has15 original publication-isolation REDs,162 passing original controls and all177 current GREEN. Supplied31 suites/150 files, evidence5, original-binding RED/restoration and book57/two controls pass. All240 original inference bindings stay historical at9032b20e. The initial copied freezer rejects at its wrong-prefix replay guard before writes; retain actual rejection/original-input snapshot and reconstruct only prefix/docstring/console correction. Block component/side-effect .3.1.2.1 is next; remaining required/optional, pipeline/output/full-private/mapped/canonical and parent owners remain open. Ordinary doctrine hooks govern staged admission.

- `2026-10-10`, `.3.1.2.1`: Block component/side-effect required bindings pass223 main/cold4 and six effective syntax-valid source faults. Six invoked roles, a separately validated local flow binding and20 native/current ledgers preserve fallback/reference/context/alias/effect/error behavior. Paired complete223 TAP has18 original publication-isolation REDs,205 original passing controls and all223 current GREEN. Supplied33 suites/152 files, evidence5, original-binding RED/restoration and book57/two controls pass. All242 original inline bindings remain historical at65bd00faa. Local-return/value .3.1.2.2 is next; remaining required/optional, other owners/pipeline/output/full-private/mapped/canonical and parent obligations stay open. Ordinary doctrine hooks govern staged admission.

## Commit Log

- `PERL-PRIVATE-FACTORY-CAPTURE.5.8 - admit finite continuity capacity` — activated from clean54bb5eb65; exact staged canonical receipt and normal hooks required. Clear brief and verify post-pointer/memory/clean Git before the due metadata-only artifact review. No push.

- `PERL-PRIVATE-FACTORY-CAPTURE.5.5 - isolate optional print_each kind` — actual CODE and opaque optional calls isolated; Git owns the resulting commit identity.

- `.5.4`: `PERL-PRIVATE-FACTORY-CAPTURE.5.4 - isolate output required callbacks`, activated from clean4a8e92aef; full focused/public diagnostic/standard proof passes; normal hooks and post-clean checks govern landing. No push.

- `.5.3`: `PERL-PRIVATE-FACTORY-CAPTURE.5.3 - isolate switch required callbacks`, activated from clean09000223f; all focused proof and standard Phase0 complete; normal hooks and post-clean checks govern landing. No push.

- `PERL-PRIVATE-FACTORY-CAPTURE.5.0 - isolate ControlFlow foundation callbacks` — focused COMMIT.md landing; activation aa8823343, actual source-bound proof complete. Clear brief and check post-pointer/post-memory/clean Git before the next leaf.

- `.3.2.1.2`: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.2 - isolate three optional kind callbacks`, from clean61cca1ccc; ordinary focused proof/standard compatibility verified, normal hooks govern landing.

- `.3.2.0`: `PERL-PRIVATE-FACTORY-CAPTURE.3.2.0 - isolate package-flow callback`, from clean4cc0b5a2a; focused proof and standard compatibility verified, normal hooks govern landing.

- `.3.1.6.4`: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.4 - isolate required array-end parser callbacks`, activated from clean98990ffbc; focused proof and standard compatibility verified, normal hooks govern landing.

- `.3.1.6.3`: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.3 - isolate required hash receiver callbacks`, activated from clean e4507973a; focused proof and standard compatibility verified, normal hooks govern landing.

- `.3.1.6.6.1`: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6.1 - repair the current admission review command`, activated from clean d95a25c8b; focused proof and normal hooks govern landing.

- `.3.1.6.6`: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.6 - admit one finite engineering-history member`, from clean d8418423e; exact staged canonical receipt required; no push.

- `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.2 - isolate number/string required callbacks` — focused proof, supplemental public compatibility and bounded readonly publication verified; normal hooks govern landing.

- `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.1 - isolate generalized return required callbacks` — required574/15/native9/branches52/public9/inverse6, supplied52/172/evidence5/book89/3; original307 historical; original instruments retained/replayed; public Phase01035/full channels; normal hooks govern landing.

- `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.0 - isolate bare mutation required callbacks` — bounded required455/11/native9/branches58/inverse6, supplied50/170/evidence5/book89/3; original299 historical; flow diagnosis retained/repair scheduled; public Phase01035/full channels; normal doctrine hooks govern landing.

The planning commit belongs to the original tree. Every implementation leaf records its own result and commit
beside its stable ID; Git is the commit-identity authority.

- `.1`: `PERL-PRIVATE-FACTORY-CAPTURE.1 - isolate native dependency calls`, from clean02345ee21; no push.
- `.2.0`: `PERL-PRIVATE-FACTORY-CAPTURE.2.0 - bind native facade callback identity`, from cleanb21b3bb9; no push.
- `.2.1.0`: `PERL-PRIVATE-FACTORY-CAPTURE.2.1.0 - isolate contract dependencies`, from clean2d8784780; no push.
- `.2.1.1`: `PERL-PRIVATE-FACTORY-CAPTURE.2.1.1 - register own lower callbacks`, from cleanbe7d70719; no push.

- `.3.0`: `PERL-PRIVATE-FACTORY-CAPTURE.3.0 - select native method defaults`, from clean33e57deee; no push.

- `.3.1.0`: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.0 - isolate required trim dependencies`, from clean89a4ede6f; no push.

- `.3.1.1`: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.1 - isolate required inference dependencies`, from clean429d0c6d; no push.

- `.3.1.2.0`: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.0 - isolate inline control dependencies`, from clean9032b20e; no push.

- `.3.1.2.1`: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.1 - isolate block component dependencies`, from clean65bd00faa; no push.

- `.3.1.2.3`: `268891fdf` — `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3 - admit history capacity and reconcile factory audit`, from cleanCDC; canonical receipt promoted and brief0/clean verified; no push.

- `.3.1.2.2.0`: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.0 - isolate local return required callbacks`, from clean268891fdf; no push.

- `.3.1.5.2`: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.2 - isolate assignment required callbacks`, from clean2b1f949b8; no push.

- `.3.1.5.3.0`: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.0 - isolate set-key required callbacks`, from clean ea6926fef; no push.

- `.3.1.5.3.1`: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.1 - isolate push required callbacks`, from clean d74c53485; no push.

- `.3.1.5.3.2`: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.2 - isolate regex and undefined-return callbacks`, from clean ae65603bc; no push.

- `.3.1.6.0.0`: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.0.0 - preserve scalar-bound receiver copy types`, from clean2b4e484a9; exact canonical receipt required, no push.

## Changelog

- `2026-10-18`, `.5.5`: optional kind implementation and focused proof complete; retain whole predecessor, first instrument/Knowledge failures and all restored artifact controls. Direct/rule .5.6 resumes only after clean landing.

- 2026-10-18 — .5.4: Four output validators/six roles; matching scalar own packets and reference-valued packet denial; public diagnostic before/after; known wrapper recurrence retained with explicit startup.7 gap; optional kind next.

- 2026-10-18 — .5.3: Six switch normalizer boundaries; unchanged native behavior; explicit15-effective/one-unobserved source-fault limit; complete prior/source/book proof retained; output .5.4 next.

- 2026-10-12 — PERL-PRIVATE-FACTORY-CAPTURE.5.0: native-first ControlFlow foundation, bounded .5 children, private actual scalar/list boundaries, full focused proof, retained reader correction and public book.

- 2026-10-12: .3.2.1.11 repairs orphan-list gate association with immutable original/native/fault evidence, complete population capsule, current gate and book proof. Exact canonical landing precedes FlowExpr; deferred P3 metadata projection .12 is scheduled after pipeline.

- `2026-10-11`, `.3.2.1.2`: Native18/105/6/cold9, symbolic42/object10; first1135/58 retains one wrong oracle, final1135/57 RED/1078 controls/allGREEN. Nine faults15/15/27/7/29/34/19/12/70; supplied69/223/15093, evidence6/book89/3/original339/full78325/standard1035 and readonly366/85779 PASS. Three owned bindings only; warning/oracle/census first failures/sole repairs exact. Normal focused hooks govern landing; due hygiene then P2 cache .9 before .3.

- `2026-10-11`, `.3.2.0`: Package-flow .3.2.0 isolates the single direct package callback while preserving actual package selection, trimmed-slot aliases, context/maps/replacement/errors and public generated source. Native209/4 outcomes/32 branches/2 authority/2 public/2 cold precedes paired299:3 original isolation REDs/296 controls/all299 GREEN. Six source faults, final supplied67/211/13660, seven evidence RED/restorations, book89/3 and supplemental standard syntax/public Phase01035 pass. Original350/full84391 publication and first instruments/channels remain exact. Normal focused hooks govern landing before remaining optional/direct .3.2.1; TYPE-REFERENCE-BOOK and independent admissions stay queued. Fixture registration .7 precedes pipeline .6.

- `2026-10-11`, `.3.1.6.4`: Required array-end .3.1.6.4 binds one resolver return for trim/parser/extractor, preserving eager selection, actual payload argument slots, splitter effects, structured results, maps/context/errors and fatal identity. Completed native201/12 callbacks/57 branches/6 authority/4 public-source/2 cold precedes paired325:9 original authority REDs/316 controls/all325 GREEN. Five faults fail9/3/36/9/18; supplied65/203/12948, evidence8/original321 and book89/three controls pass. Standard syntax/public Phase0 passes1035 with full channels; readonly329-input/78324-byte publication passes. Compile-failed instrumentation and wrong-wrapper preflight remain explicit without runtime refresh. Normal focused hooks govern landing before hash-index .3.1.6.5; optional/direct, independent admissions and TYPE-REFERENCE-BOOK stay queued. Fixture registration .7 precedes pipeline .6.

- `2026-10-11`, `.3.1.6.3`: Required hash .3.1.6.3 binds one resolver return and preserves eager trim/parser selection, substring effects, actual shared call references without annotation, maps/context/errors and fatal identity. Immutable native197/8 callbacks/52 branches/4 authority/2 public-source/2 cold precedes paired308:6 original authority REDs/302 controls/all308 GREEN. Five full-source faults fail6/2/4/5/8; supplied64 suites/199 inputs/12623 assertions, evidence7/original115 and book89/three controls pass. Standard syntax/public Phase0 passes1035 with full channels; readonly321-input/75495-byte publication passes. Normal focused hooks govern landing before array-end .3.1.6.4. Optional/direct, independent admissions and TYPE-REFERENCE-BOOK remain queued; fixture registration .7 precedes pipeline .6.

- `2026-10-11`, `.3.1.6.6`: Finite notes prerequisite .3.1.6.6 preserves all224 prior immutable history/decision files and337 accepted scalar bindings at clean d8418423e. Exact segment4961/612 manifest bytes/one line and sole ADR0133/index35-line overhead are independently reconstructed. Actual next-note and old admission REDs, production30 thresholds/23 authority denials, three reviewer/two preservation REDs with exact restoration, full book89/3 and readonly377-input/103173-byte publication pass. Existing related Knowledge card retains its historical body/questions; no slot or future reserve is added. Exact staged canonical CI/receipt and normal hooks govern admission before hash .3.1.6.3; remaining families, TYPE-REFERENCE-BOOK and independent admissions stay queued.

- `2026-10-11`, `.3.1.6.2`: Required number/string .3.1.6.2 binds four actual trim/parser callbacks through two resolver returns, preserving eager selection, substring effects, actual parser-returned object annotations, maps/context/errors and fatal identity. Paired436 assertions retain12 original authority REDs/424 controls/all436 GREEN; ten separate full-source faults, supplied63/195/12315, evidence7/original314 and book89/3 pass. The first reviewer label error and premature dependent preflight are retained and repaired without native/runtime refresh. Supplemental standard syntax/public Phase0 passes1035 with complete channels; readonly337-input/83792-byte metadata closure passes; original323 publication/card/publisher remain exact and replayable. Finite notes rollover prerequisite .3.1.6.6 precedes hash .3; remaining required families, TYPE-REFERENCE-BOOK and independent admissions stay queued. Canonical private-fixture registration .7 precedes pipeline .6. New engineering note stays under existing pressure limits; .3.1.6.6 owns the next exact finite rollover.

- `2026-10-11`, `.3.1.6.1`: Required array receiver .3.1.6.1 binds its two required trim/parser callbacks while preserving actual substring effects, eager selection, maps/context/errors and caller values. Paired215 assertions retain6 original authority REDs/209 controls/all215 GREEN; five full-source faults, supplied62/191/11879, evidence7/original322 and book89/3 pass. Original consumer/evidence refusals and unavailable partial-channel limits are explicit; separate path-complete and fresh controls govern proof. Supplemental standard syntax/public Phase0 passes1035 with complete channels; no full transitive input capsule. Number/string .3.1.6.2 follows; other required families, TYPE-REFERENCE-BOOK and independent admissions remain queued. Canonical private-fixture registration .7 precedes pipeline activation .6. New live note remains within existing limits; no history threshold change.

- `2026-10-11`, `.3.1.6.0.1`: P2 legacy hash kind callback .3.1.6.0.1 selects the injected CODE callback once before trim and defaults missing/non-CODE to unknown. First-native35 cases retain23 complete controls/12 intended repairs plus two cold rows; paired487 assertions retain48 original REDs/439 controls/all487 GREEN. Five syntax-valid faults fail48/3/9/5/3. Supplied61 suites/187 inputs/11664 assertions, six evidence RED/restorations and book89/3 pass. Independent Perl5.34.1 four-case slot/write oracle proves a match argument can have readonly flag0 yet reject writes. All546 predecessor bindings remain historical at770cffcc, with original observations and both bounded instrument corrections retained/replayed. Supplemental standard syntax/public Phase0 passes1035; no full transitive capsule or broader admission is inferred. Required array receiver .3.1.6.1 follows, then .6.2-.6.5; TYPE-REFERENCE-BOOK and independent admissions stay queued. Normal focused commit workflow precedes array receiver activation.

- `2026-10-10`: From clean268891fdf, split local-return/value .3.1.2.2 before writes into local-return .0 and block-value .1; guarded AST now depends on .1. Preserve all399 current capacity/audit bindings before any bound input changes. Local-return changes only one required return and verifies115/4/3, native6/roles2, paired6 RED/109 controls/115 GREEN, supplied35/154, evidence5 and complete book57+32/3. Dated older reviewers require their accepted Git input boundaries. Public Phase0 passes1035/1035; ordinary hooks govern the focused commit. Block-value .1 is next; broader private/parent admissions stay open.

- `2026-10-10`: Created the linked bounded implementation tree under the existing private producer protocol.
- `2026-10-10`: `.1` accepts the standalone actual registration/native dependency framework and hands off to Contracts `.2`. Initial fixture reference reuse is durably diagnosed; factory/pipeline activation remains open.
- `2026-10-10`: Before Contracts production writes, split `.2` into `.2.0` actual facade identity/resolved-owner boundaries and `.2.1` actual contract/default/delegated callback construction plus dependency isolation. This follows current public bridge interfaces and leaves shared OwnerDispatch mechanics unchanged.

- `2026-10-10`: `.2.0` accepts definition-owned EmitContext selection and separate native owner/factory calls, with exact original framework preservation. Contracts .2.1 remains next.

- `2026-10-10`: Before .2.1 production writes, split private required/optional/bare dependency isolation and native defaults (.2.1.0) from actual local/delegated lower construction registration (.2.1.1). Activate .2.1.0 from clean2d8784780.

- `2026-10-10`, `.2.1.0` investigation: Initial main fixture has complete312 TAP with one RED (private binding release), while other311 and cold6 PASS. Retain actual instrument/fixture/source/channels. Reproduce the exact final lifetime block against original/current Contracts and a lexical-state control before changing production or classifying retention. Owner .2.1.0 fixes and verifies this immediately; consumer result remains in flight.

- `2026-10-10`, `.2.1.0` diagnosis/fix: The exact extracted final lifetime block fails on both original and current Contracts without lexical callback state; the lexical-state control passes on both. This reverifies the existing canonical native shared-closure fixture finding, rather than a production retention defect. Preserve failed main312/consumer21 runs, original instrument/fixture/source and actual four probe channels. Give only the lifetime fixture actual lexical state; production bytes stay exact. Final captures use separate final-* paths.

- `2026-10-10`: `.2.1.0` accepts private actual dependency bindings/native default selection with exact original235 preservation. Actual lower construction .2.1.1 remains next.

- `2026-10-10`: Activate actual lower construction registration .2.1.1 from cleanbe7d70719. Own the twelve local constructor returns and two delegated owners; preserve all248 current dependency-claim bindings before source writes.

- `2026-10-10`, `.2.1.1` in flight: Three production owners pass syntax. Main447/cold6 and supplied23/142 PASS; two complete native/current catalogues of174 entries match actual metadata, ordinary values and callback reuse patterns. Twelve local literal-return seams preserve actual array/hash/lower references; fourteen substituted factories remain opaque, and scope selection/release controls pass. Semantic inverses are running; readonly evidence/book/claim admission remains pending.

- `2026-10-10`: `.2.1.1` accepts actual local/delegated construction registration and preserves original248 bindings. Contracts implementation children are accepted; no separate parent admission inferred. MethodLowering .3 is next.

- `2026-10-10`: Split MethodLowering before writes into default selection .3.0, required .3.1 and optional/direct .3.2. Activate .3.0 from clean33e57deee and preserve original244 construction bindings. Own and correct the inherited constructor-specific inverse description here; all original producer/captures remain and production/fixtures stay exact.

- `2026-10-10`: `.3.0` accepts actual native method default selection. Required .3.1 is next; optional/direct .3.2 precedes FlowExpr. Individual child acceptance does not close original parent/full-private/mapped/canonical obligations.

- `2026-10-10`: Split required MethodLowering seams into seven explicit function-family children before writes. .3.1.0 owns only the private binding and three trim callers; all282 original bindings freeze first. Actual partial retention RED255 exposes an inherited matcher-label defect; own and correct that plus the cold label here, retaining all18 partial captures and unchanged production/fixtures.

- `2026-10-10`: .3.1.0 accepts required trim isolation with exact paired native RED/GREEN and native callback/caller proof. Assignment/declaration inference .3.1.1 is next; no parent/full-private/canonical admission inferred.

- `2026-10-10`: `.3.1.1` accepts three required inference resolver seams/eight callback roles with original262 preservation; inline/block .3.1.2 is next. Early missing consumer-result review is reproduced/restored in its fifth evidence control without changing runtime inputs.

- `2026-10-10`: Before inline/block production writes, split .3.1.2 into inline if/switch .0, component/side-effect .1 and local-return/value .2. Declare the two existing validation-only requirements separately from actual invocations. Activate .3.1.2.0 from clean9032b20e; guarded AST .3.1.3 depends on final .3.1.2.2.

- `2026-10-10`: `.3.1.2.0` accepts inline if/switch required boundaries and original240 preservation. Wrong-prefix freezer guard rejection is reproduced before successful preservation; production remains exactly two required return edits. Block component/side-effect .3.1.2.1 is next.

- `2026-10-10`: Activate block component/side-effect .3.1.2.1 from clean65bd00faa. Own two required returns, six actual invoked roles and separate flow validation; native undefined-result fallback and direct reference outcomes are explicit proof requirements. Preserve all242 original inline input bindings before writes.

- `2026-10-10`: `.3.1.2.1` accepts component/side-effect required boundaries, native fallback/reference outcomes and separate local flow validation, preserving original242 inputs. The attempted rollover was blocked by README-STABILITY file-count/manifest controls. Withdraw only the uncommitted redundant segment after exact clean-source verification; shorten only this new note. Pending P1 .3.1.2.3 owns a separate finite canonical capacity admission before local-return/value .3.1.2.2.

- `2026-10-10`: Activate finite capacity .3.1.2.3 from clean cdc45f9cb. Preserve prior immutable history/decision bytes and runtime proof; retain exact one-member rollover and production authority/threshold evidence before staged canonical admission.

- `2026-10-10`: Finite capacity .3.1.2.3 focused proof passes with exact220 preservation,30 production thresholds/23 authority denials and three reviewer REDs/restoration. Exact staged canonical receipt governs landing; runtime .3.1.2.2 follows the canonical commit.

- `2026-10-10`: The first .3.1.2.3 canonical candidate stops at CLAIM-VERIFICATION: the nine-input historical claim lacks a producer role; other nine doctrines pass. Own the publisher metadata defect here. Retain the exact rejected claim and actual validator rejection; a guarded repair labels unchanged original production checker/roller bytes as producers without refreshing hashes or capacity measurements. Then restage and rerun exact canonical CI.

- `2026-10-10`: Guarded .3.1.2.3 publication repair passes the actual validator, retaining the exact initial claim and complete actual schema RED channel. Only two original producer-role labels, explicit disclosure and five retained repair/validator inputs change; all original hashes/capacity measurements stay exact. Readonly repair-publication.py review independently reconstructs the corrected record and reproduces RED/GREEN. Restage the complete candidate before rerunning canonical CI.

- `2026-10-10`: Second canonical candidate passes all10 doctrines, syntax and structural contracts, then actual .0.4.2.1 recovery rejects unreviewed Contracts boundary drift. Toolbox/KM trace identifies the absent two-commit factory inverse; own P1 repair within this canonical prerequisite, preserving exact staged candidate, original auditor and actual RED channel before writes. No other new selected executable-source drift is present beyond existing admitted Phase0/CI evolution.

- `2026-10-10`: Historical prerequisite complete: exact two-commit Contracts inverse, retained failed staged candidate/original auditor/actual RED, full134 inputs/84613241 bytes,22 recovery controls/64 evolution denials and guard0. Freeze original241 runtime/book inputs at cdc45f9cb before architecture teaching edits; runtime artifact review223/4/6 and supplied33/152 remains exact. Book57/2 and four actual reviewer counterfactual REDs/restoration pass. The bounded123912-byte claim retains original capacity245/nine inputs and adds historical repair259/two. Stage the complete final candidate and rerun canonical CI; no capacity or full-private admission before receipt.

- `2026-10-10`: Block-value .3.1.2.2.1 freezes all273 original local-return inputs before bound writes; one required return passes paired222/9RED, native9/branches16/cold5/inverse3, supplied37/156, evidence5, original-binding RED/restoration and full book89/3. Actual trim publication is limited to one to avoid ambiguity masking. Standard public Phase0 passes1035/1035 in1204 seconds; ordinary doctrine hooks govern landing. Guarded AST .3.1.3 follows the clean commit.

- `2026-10-10`: Split guarded AST .3.1.3 into four stable owner leaves before writes; activate hash-index key .3.1.3.0 from clean b50ce085a. Freeze275 current block-value inputs first. Preserve exact draft producer/two baseline results before stale header-only correction; same original rows otherwise compare byte-for-byte. Bounded171/cold4/native3/branches15/inverse3 and supplied39/158/full book89/3 pass; Evidence/claim pass; public Phase0 passes1035/1035 in1200 seconds. Ordinary doctrine hooks govern landing; AST call .3.1.3.1 follows clean commit.

- `2026-10-10`: Activate AST call .3.1.3.1 from clean2e9e5443e; preserve280 inputs first. Refine all six required roles and eager/lazy validation before writes. Bounded695/cold12/native18/branches44/inverse3, supplied41/160/evidence5/original-binding restoration/full book89/3 PASS. Public Phase0 passes1035/1035 in1186 seconds; Claim107/133/7 and Knowledge1331/10207 PASS. Final ordinary checks/hooks govern landing; commit before array-end .3.1.3.2.

- `2026-10-10`: AST-call commit9085eb1e5 passes all10 doctrines/post-pointer; brief0/clean Git verified. Own imminent change-history capacity under .3.1.3.4 before array-end: root58706 is276 bytes below rollover; collection48 and manifest47/26831 reach admitted limits. Existing ADR0129/0131 engineering precedent governs one finite canonical prerequisite, with no old immutable or threshold weakening.

- `2026-10-10`: Finite change-history .3.1.3.4 focused proof222/30/23/4, original279 and book89/3 PASS; retain every initial instrument/result, exact final separator count and bounded356-input claim. Stage final canonical candidate/receipt before landing; then resume array-end .3.1.3.2.

- `2026-10-10`: Clean b0099d9ad activates array-end .3.1.3.2. Scope/contract/book and native callback-copy/fallback guards reviewed; preserve356 capacity bindings first. Queue qualitative per-type book intake and exact legacy task-status repair without changing the active runtime frontier.

- `2026-10-10`: Array-end freezer verifies all356 original capacity bindings against clean b0099d9ad before bound writes; only one live mode/revision changes, existing historical claim stays exact. TYPE-REFERENCE-BOOK and its Knowledge/index/roadmap projections record the qualitative DBIQNP follow-up and exact legacy metadata defects as pending work.

- `2026-10-10`: Own and correct a current projection defect here: ROADMAP_V2 still selected block-value .3.1.2.2.1 while MEMORY/task/ROADMAP selected array-end after accepted b0099d9ad. Reproduce with its Expressive self-containment row; mirror the exact current ROADMAP row to restore the shared frontier, retaining historical evidence in Git and the owning task. This is continuity repair, not a task pivot.

- `2026-10-10`: Array-end bounded proof and actual readonly reconstruction PASS858/8/3, native12/branches44, paired12 RED/846 controls/858 GREEN, supplied44/164, evidence5/original356 restoration and full book89/3. Publication283 live inputs/67540 bytes; Knowledge1334/10228. Both Perl syntax checks pass; public Phase0 and claim validator remain in flight before final handoff/ordinary commit.

- `2026-10-10`: Claim validator PASS109 records/137 claims/seven existing disclosed gaps, including self-test3 positive/16 rejected; the new array-end record has all three legs. Only standard public Phase0 remains running before final handoff and ordinary landing checks.

- `2026-10-10`: Standard public Phase0 PASS1035/1035 in1472 seconds. Own an output-observation diagnostic before signoff: the final tool response reported more pre-truncation tokens than the earlier canonical final response, while the complete first stream was not retained. These are per-poll recent-output metadata, so whole-run comparison is not yet justified. Use a bounded two-chunk public tool producer in the owned output-diagnostic directory, retain actual responses and check the transport boundary before classifying any runtime issue. The fixed283-input runtime publication stays untouched.

- `2026-10-10`: Output diagnostic resolves the observation error: actual bounded producer responses contain disjoint first/second stdout blocks, and concatenation is exact. original_token_count describes each recent-output response, so comparing final responses does not establish whole-run volume change. Retain producer/actual response JSON and Knowledge card; full original Phase0 stream remains unavailable, so no warning-volume claim is made. Standard Phase0 PASS1035/1472 remains valid; runtime283-input publication is unchanged. Future content/volume diagnostics retain full streams before filtering.

- `2026-10-10`: Array-end public compatibility PASS1035/1472 seconds; bounded858/8/3, native12/branches44, paired12 RED/846 controls/858 GREEN, supplied44/164/evidence5/book89/3 and283-live-input publication remain exact. Claim109/137/seven existing gaps and Knowledge1335/10231 PASS. Output comparison error resolves through retained actual disjoint-chunk producer/results; no whole-stream warning claim. Final history/memory/pressure/whitespace/ordinary hooks govern landing; assignment .3.1.3.3 follows clean HEAD with283-input preservation.

- `2026-10-10`: Final diff review caught a continuity writer matching the inline `## ` example instead of a heading, placing the new CHANGES record inside its preamble. Restore the exact preamble and place the complete new record before the first anchored heading; verify both chronology checks and whitespace before landing. No immutable archive, bound producer or measured input changed.

- `2026-10-10`: Final readonly publisher still verifies283 live inputs/67540 bytes; composed review PASS. Both chronology checks PASS at197/34109 and211/38165 lines/bytes. Early memory/pressure checks correctly reject mixed staged/unstaged final continuity; stage the exact final records, then memory architecture and staged whitespace PASS. Normal all-doctrine commit hooks rerun resulting-tree pressure for the complete candidate.

- `2026-10-10`: Array-end .3.1.3.2 accepted at4fde89c19 with all10 doctrines; post-pointer/brief0/clean Git verified. Activate assignment .3.1.3.3; own the stale current planning-card projection (local-return/value incorrectly still next). Preserve283 prior live bindings before bound writes; refine the one lazy hash-fallback role and all explicitly controlled branch contracts.

- `2026-10-10`: Assignment initial preservation instrument incorrectly retained CLAIM .3.1.3.4 from its capacity predecessor. It mutated an unrelated historical claim, which restored exactly; the actual assignment reviewer still returned0, so the instrument correctly refused admission. Retain unchanged initial producer/result/reviewer, reconstruct this invalid control independently, correct only CLAIM to the frozen array-end .3.1.3.2 record and require an actual nonzero RED/restored PASS. Production, fixtures, runtime captures and original283 hashes are unchanged.

- `2026-10-10`: Assignment runtime864/8/3/native3/branches66, paired3 RED/861 controls/864 GREEN and supplied46/166 PASS. Corrected preservation control obtains actual original283 RED/restored PASS; initial wrong-target source/result/reviewer remain exact and independent supplied-tree audit rejects its readonly validation. Evidence5 and book89/3 PASS. Composed readonly review and291-input69504-byte publication PASS; Knowledge1336/10239 generated. Public Phase0 runs separately with complete channels retained and explicit input-capsule limitation.

- `2026-10-10`: Claim verification PASS110 records/139 claims/seven existing disclosed leg gaps, self-test3 positive/16 rejected; new assignment record has all three legs. Both chronology checks PASS217/35875 and232/40017 lines/bytes; whitespace PASS. Standard public Phase0 remains in flight; full channel retention is separate from bounded source/input acceptance.

- `2026-10-10`: Both required Perl syntax checks and supplemental standard public Phase0 PASS1035/1035; compatibility producer/result retain complete channels and explicit transitive input-capsule limit. Claim110/139/seven existing gaps and Knowledge1336/10239 PASS. Final continuity/history/memory/whitespace and normal doctrine hooks govern landing; main method/value .3.1.4 follows the accepted assignment child without separate group admission. Preserve291 current inputs before later bound writes.

- `2026-10-10`: Exact final staged memory architecture PASS; both history checks PASS218/36013 and233/40130 lines/bytes, matching expressive roadmap rows and staged whitespace PASS. Fresh readonly bounded publisher still gates291 live inputs/69504 bytes after separate full-channel compatibility result; its readonly verification passes. All acceptance boxes complete; normal all-doctrine hooks govern the ordinary commit.

- `2026-10-10`: Assignment .3.1.3.3 accepted at049e1ba53 with all10 doctrines, post-pointer/brief0 and clean Git. Activate main method/value .3.1.4; preserve291 original inputs first. Preliminary source recovery identifies eager validation, a locally unused inference binding, an additional initializer acquisition and key re-acquisition within an AST adapter. Establish exact native/alias/path proof before changing the required seam; split if needed.

- `2026-10-10`: Main required resolver source-bound proof PASS518/10/3, native42/branches23 and exact paired42 RED/476 controls/518 GREEN. Supplied48/168, evidence5/original291 restoration, actual retained draft replays and book89/3 PASS. Random supplied traceback-path drift is resolved by a separate deterministic replay with full raw channels retained; original producer/result remain exact. Readonly publication gates299 live inputs/69961 bytes. Standard public compatibility runs separately before final handoff/ordinary commit.

- `2026-10-10`: Pre-stage claim scan PASS110 records/139 claims/seven existing gaps and self-test3/16. As the existing claim-verification-index-snapshot card explains, this reads accepted index blobs, so it does not admit the new unstaged main record. The exact staged normal doctrine hook must validate111 records/141 claims (derive actual result there). Knowledge1337/10249, memory, task metadata and whitespace PASS. Public Phase0 remains in flight; no index mutation overlapped the completed claim scan.

- `2026-10-10`: Both required Perl syntax checks and supplemental public Phase0 PASS1035/1035; full channels retained and compatibility runner closes. Main518/10/3/native42/branches23, paired42 RED/476 controls/518 GREEN, supplied48/168/evidence5/book89/3 and readonly299-input69961-byte claim remain exact. Final staged normal claim/doctrine hooks govern landing; then scalar/return/mutation .3.1.5 activates from clean HEAD with299-input preservation.

- `2026-10-10`: Main .4 accepted at4b48593b59 with all10 doctrines, post-pointer/brief0 and clean Git. Split scalar/return/mutation .5 into four bounded children and activate .5.0. Preserve299 inputs before bound writes. Own stale default/block-component current projections within this family; probe the existing mutation package-flow path through LinkedSpec tools before classification. Optional/direct repair remains .3.2; no source edit yet.

- `2026-10-10`: All299 main bindings are frozen at4b48593b5 before bound writes. Actual public Toolbox probes distinguish normal mutation RuntimeLogical lowering from a localized package-flow override, invoked once and present in generated mutation text. Own/schedule that reachable direct callback's private boundary under P2 .3.2.0, before other optional families .3.2.1. Preserve native selection; no missing-map-callback fix or public syntax change is inferred. Current required slice remains .5.0.

- `2026-10-10`: Bare/mutation required .5.0 runtime/book/claim proof verifies455/11/native9/branches58/inverse6, paired9 RED/446 controls/455 GREEN, supplied50/170/evidence5 and book89/3. All299 original main identities remain historical at4b48593b5; current claim307/73390 is readonly-reconstructible. Flow diagnosis retains compact-argument premise failure and exact raw address drift; P2 optional repair stays .3.2.0. Public Phase0 and ordinary handoff/hooks remain in flight.

- `2026-10-10`: Required syntax checks and supplemental public Phase0 PASS1035 with complete channels; the compatibility runner closes. All bounded .5.0 proof/publication remains exact. Final staged memory/claim and normal doctrine hooks govern the ordinary clean commit, then .5.1 activates with307-input preservation.

- `2026-10-10`: Bare/mutation .5.0 accepted at2c5f84092 with all10 doctrines, post-pointer/brief0 and clean Git. Activate generalized returns .5.1; preserve307 inputs before bound writes. Required payload trim follows the undefined guard; statement parser is eager before AST fallback, while label trim is lazy. Own stale local-return card future projection within this leaf; no source edit yet.

- `2026-10-10`: Generalized-return .5.1 retains574/15/native9/branches52/public9/inverse6, paired9 RED/565 controls/574 GREEN, supplied52/172/evidence5/book89/3 and readonly306-input72937-byte claim. Original307 identities stay historical at2c5f84092; original loading draft/initial565 and all raw replay channels remain unchanged. Only two required seams change. Public compatibility, normal gates and commit remain in flight; due artifact census follows the clean boundary.

- `2026-10-10`: Both required syntax checks and supplemental public Phase0 PASS1035 with complete channels; runner closes. Current bounded .5.1 publication remains exact. Normal staged hooks govern commit; due retained artifact review follows the clean boundary before assignment .5.2. One overly broad filename discovery listed submodule paths; no implementation content was opened or used and no submodule writes occurred. Subsequent discovery uses parent tracked paths explicitly.

- `2026-10-10`: Hygiene.15 accepted at2b1f949b8 with all10 doctrines, post-pointer/brief0 and clean Git. Activate assignment required .5.2 with three planned required resolver seams. Preserve306 generalized-return live inputs before bound writes, then establish eager validation, distinct initializer kind/source aliases and repeated trim behavior. Secondary helpers/optional selection and broader admissions remain separate; no source edit yet.

- `2026-10-10`: Assignment .5.2 retains27 native callback outcomes/60 branches/five public Toolbox rows before exactly three required resolver edits. All938 current TAP pass against the identical27-RED/911-control original population. Cold17, nine effective source faults, supplied54/174, evidence5/original306 restoration/book89/3 and readonly300/71043 proof pass. No fixture correction needed; both required syntax checks/public Phase0 PASS1035 with full channels retained; normal hooks govern ordinary landing.

- `2026-10-10`: Assignment required .5.2 accepted at ea6926fef with all10 doctrines, post-pointer/brief0 and clean Git. Split remaining helper .5.3 before writes into set-key .0, push .1 and regex/undefined-return .2; activate .0. Five eager set-key roles and actual normalized argument slots need native proof before the one required resolver edit. Existing regex discrepancy owners remain separate.

- `2026-10-10`: Set-key .5.3.0 retains15 native outcomes/37 controlled branches/three actual public Toolbox rows before exactly one required resolver edit. All539 current TAP pass against identical15-RED/524-control original names. Cold17, source faults3, supplied56/176, evidence5/original300 restoration/book89/3 and readonly296/69937 proof pass. No instrument correction needed; both required syntax checks/public Phase0 PASS1035 with full channels retained; normal hooks govern ordinary landing.

- `2026-10-10`: Set-key accepted d74c53485 with all10 doctrines, post-pointer/brief0 and clean Git. Activate push .5.3.1; preserve296 original bindings before bound writes. Own stale assignment-next cells in both roadmap tables in this leaf.

- `2026-10-10`, push native preflight: Initial driver incorrectly expected55 branches, actual immutable capture has24 callbacks/56 branches/four public rows. Preserve original producer/fixture/cold fixture/native channels and identities in .5.3.1-initial-probe/. Numeric push probes select documented child/index precedence at Contracts.pm:495/517, not a new product defect. Retain those probes with correct labels and add quoted-value append probes; diagnostic mutant expected name gains actual arity2. Source remains accepted d74c53485. Final native capture must precede production edit; independent review binds the complete correction lineage.

- `2026-10-10`, push native checkpoint: Final native24 callback rows/56 guard cases/six public Toolbox rows captured on accepted d74c53485. Complete850 TAP retains exactly24 publication/identity REDs and826 passing controls. Repeated trim raw-slot/copy behavior and extractor/primitive local slots match source. Initial branch-count/label/diagnostic-reason draft stays immutable under initial-probe; production edit is limited to one required resolver return.

- `2026-10-10`: Push required .3.1.5.3.1 verifies850/cold15/native24/branches56/public6/inverse3, paired24 RED/826 controls/850 GREEN and supplied58/178/evidence5/book89/3. All296 original set-key bindings stay historical at d74c53485; readonly303-input71948-byte claim passes. Four eager roles preserve actual raw versus copied effective arrays, repeated trim/extractor effects, local scalar copies and final extractor/binding identity. Original count/public-label/diagnostic-name probe correction is retained and independently reconstructed. Secondary helpers and independent admissions remain separate. Both stale roadmap table next-task cells are corrected. Both required syntax checks and supplemental public Phase0 PASS1035/1035 with full channels retained; normal hooks govern clean landing. Regex/undefined-return .5.3.2 follows clean handoff; TYPE-REFERENCE-BOOK stays queued.

- `2026-10-10`: Push accepted ae65603bc with all10 doctrines, post-pointer/brief0 and clean Git. Activate regex/undefined-return .5.3.2; preserve303 original bindings before bound writes. Existing .59 language/receiver repairs remain separate; no broader parent admission.

- `2026-10-10`, regex/undefined-return instrument: Keep the native probe immutable and separate from subsequent assertions. Native capsule supplies accepted178 seed inputs plus probe; paired tests/consumers additionally supply main/cold tests and the retained native JSON reader. The first flags-slot observations precede assertion construction and both production edits; no native observation replacement is permitted.

- `2026-10-10`, regex/undefined-return native checkpoint: Immutable179-file native capsule captures24 callback outcomes/32 branches/four public Toolbox rows. Separate assertions against the first native record retain complete619 TAP with exactly24 isolation REDs/595 controls in the182-file test capsule. Defined flags are writable local copies, default flags a readonly empty literal; strip invokes both local slots before its defined guard. Undefined-return normalizer sees actual parser array and readonly0/0 arities. No instrument correction or original observation refresh. Change exactly the two required resolver returns next.

- `2026-10-10`, owned fault-instrument defect: First inverse job91356 failed before any mutant capture because shared edit() required a following sub and undefined-return is the module final owner. Preserve original capture/probe/assertions and successful native/current/TAP/cold/consumer channels. Actual .5.3.2-fault-boundary.py recurrence retains the182-input failure/unchanged census; separate faults.py fixes only end-of-file handling. Independent review must reconstruct that exact producer delta and gate all six semantic faults; no original runtime observation is refreshed.

- `2026-10-10`: Regex/undefined-return required .3.1.5.3.2 verifies619/cold23/native24/branches32/public4/inverse6, paired24 RED/595 controls/619 GREEN and supplied60/182/evidence5/book89/3. All303 original push bindings remain historical at ae65603bc; readonly307-input73113-byte claim passes. Immutable179-file native probe precedes182-file paired assertions; defined/default flags, repeated stripping, actual normalizer array and readonly0/0 arities remain native. Original final-owner fault-generator failure and exact EOF correction are retained and independently reconstructed. Only two required returns change. Both required syntax checks and supplemental public Phase0 PASS1035 with complete channels retained. Staged claim118 records/154 claims/seven existing disclosed gaps PASS; normal doctrine hooks govern landing. P1 receiver-copy diagnosis/repair .3.1.6.0 precedes required receiver/parser capture; TYPE-REFERENCE-BOOK and independent admissions remain queued. Knowledge1343/10299 generated. Fault-instrument defect is fixed/verified by exact original recurrence and six effective mutants; original capture/probe/assertions remain unchanged. Own and correct the duplicate task-index current projection within this leaf.

- `2026-10-10`, receiver preflight finding: Public Toolbox source exposes scalar-held hash .copy() selecting an array-only read; local normalizer instrumentation shows AST selection bypasses legacy normalizers. Root AST hash discriminator only handles remembered aggregate hash or later hash methods. Own P1 .3.1.6.0 for exact runtime diagnosis/repair after current clean landing. Investigate a distinct suspicious unbound kind callback in legacy hash normalization; do not infer its public reach from source alone. Current source/proof remains untouched.

- `2026-10-10`, retained receiver diagnosis: docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.5.3.2-receiver-diagnostic/ retains the actual producer/probe and complete supplemental channels. Get confirms scalar-held hash .copy() yields an empty array; function-form copy yields the original hash and multi-step hash-copy/count yields1. Direct legacy hash normalizer with injected kind callback fails at the unbound callback. These are two distinct mechanisms; pending P1 .3.1.6.0 must split them before writes. Full transitive diagnostic inputs/repair acceptance remain with that owner; current307-input required-capture proof does not admit these unrelated paths.

- `2026-10-10`: Both required syntax checks and supplemental public Phase0 PASS1035/1035 with complete channels retained; compatibility job closes. Required-capture307-input73113-byte readonly publication remains exact. Standalone staged claim verification and final ordinary landing checks remain pending. P1 receiver-copy diagnosis/repair .3.1.6.0 follows clean handoff and splits the public AST and legacy callback mechanisms before writes.

- `2026-10-10`: Standalone staged claim verification PASS118 records/154 claims/seven existing disclosed gaps, self-test3 positive/16 rejected. Current leaf and .5/.5.3 routing parents have verified children; original independent admissions stay open. Intended clean handoff selects P1 receiver .3.1.6.0, split before writes. Final history/memory/whitespace and normal hooks govern landing.

- `2026-10-10`: Clean2b4e484a9 activates P1 .3.1.6.0.0 after all10 doctrines/post-pointer/brief0 and clean Git. Split public AST copy and legacy callback repairs before writes, and give each remaining required receiver/parser family a bounded owner. No new observation or production edit yet; preserve307 current bindings first.

- `2026-10-10`, receiver-copy preservation: All307 accepted regex/undefined-return bindings verified against clean2b4e484a9 before bound writes; only one live mode/revision becomes historical, with the existing push preservation claim unchanged. Immutable public probe/regression and one-shot184-input capture producer now establish native live/standalone/typed-AST behavior before any source change. No handoff or admission yet.

- `2026-10-10`, public copy native checkpoint: Immutable184-file capsule retains live/standalone14-case ledgers, full actual generated source, shallow identity, typed-AST poisoned-source and aggregate/arity controls. Identical50 TAP before the source edit has exactly9 semantic REDs/41 controls. Add only the scalar-bound, one-call, zero-argument AST copy dispatch to the existing aggregate copy lowerer; current verification starts. Multi-step, other receiver families and legacy callback selection remain separate.

- `2026-10-10`: P1 scalar-bound receiver-copy .3.1.6.0.0 verifies50 assertions, original9 REDs/41 controls/50 GREEN, live/standalone14-case ledgers, typed source poisoning and shallow snapshot identity. Three source faults reject9/4/8; supplied61/184, evidence5/original307 restoration and book89/3 pass. Exact CI inverse/native registration RED, complete192 supplied inputs,22 recovery/74 evolution controls and evidence3 pass. Initial runtime publication is retained; its publisher extension adds the CI supplement without refreshing native proof. Readonly304-core/198-CI bindings and118034-byte claim pass. Fresh exact canonical receipt and normal hooks govern landing. Legacy hash callback .3.1.6.0.1 follows, before required .6.1-.6.5; TYPE-REFERENCE-BOOK and independent admissions stay queued. Intended clean handoff is prepared before exact staged canonical CI; no candidate mutation may overlap that gate.

- `2026-10-10`, owned CI selection gap (P2): The canonical runner has an explicit Perl test list and did not select the new public receiver-copy regression. Reproduce by searching accepted2b4e484a9 tools/run_ci_local.sh for t/actionir_receiver_scalar_copy.t (absent). Focused61/184 proof passes, but future canonical runs would omit this guard. Stop first canonical session80828 (actual exit130) before index mutation, retain complete redirected channels and disclosed post-cancel fingerprint under the owned canonical/attempt-01.json, and add tracked-input/syntax/execution selection in this leaf. Exact updated candidate must run canonical CI afresh; no initial receipt/admission is claimed.

- `2026-10-10`, canonical selection repair: tools/run_ci_local.sh now requires both new files tracked, checks each Perl syntax, and executes the regression beside the AST parser suite. Shell syntax passes; Knowledge1345/10312 generated. Focused303-input71361-byte publication remains unchanged. Final staged docs and fresh canonical attempt02 must validate this exact updated candidate before commit.

- `2026-10-10`, canonical prerequisite repaired: Attempt02 exits1 after all10 doctrines pass, at historical runner registration. Full failed binary candidate/channels and original runner/auditor are retained. Original RED/activation control and exact three-insertion historical inverse/full192 inputs/22 recovery/74 evolution/evidence3 pass. Initial303 runtime publication/publisher stay retained; extension changes only publisher identity plus added CI supplement, preserving every runtime proof field. Readonly304-core/198-CI bindings/118034-byte claim and Knowledge1345/10312 pass. Fresh attempt03 must use approved host execution from the start per existing process-locality prerequisite. No canonical success is inferred.

- `2026-10-11`, canonical attempt03 prerequisites: Retain full failed candidate/channels/original502 declarations/487 files and initial521 declarations/506 files. Correct one synthetic AST book example; retain all four valid rejected public additions and advance only36-to40 census. Public70/40/0, parent69/36, migration11/three actual REDs; scanner17 paths/27 lines/51 strict denials; final book89/3 and fresh isolated historical183 inputs/134 restored/22 recovery/80 evolution denials pass. Original and initial publications replay exact inputs. The draft192/135 wrapper refuses after retaining inner success; nine supplementary capsule inputs explain192 versus actual183, and unused scanner historical branches are removed. Original native/runtime proof unchanged. Final composed publication/Knowledge1346/10319 and fresh exact attempt04 receipt/normal hooks govern landing; no admission is inferred from failed03.

- `2026-10-11`, `.3.1.6.6.1`: Review-command repair .3.1.6.6.1 replaces only ADR0133's stale pointer and related current guidance. All377 accepted bindings remain historical at d95a25c8b, whose canonical CI and normal hooks passed. Actual accepted-publication recovery supplies395 files (377 live bindings,17 historical hygiene inputs and its full claim), rejects changed ADR/omitted input and restores PASS. Three current-reviewer REDs each restore; book89/three controls and readonly115-input/121873-byte publication pass. Both failed recovery drafts remain exact with their observed limits; no original producer/hash/observation refresh or runtime/capacity change. Required hash .3.1.6.3 follows this focused commit; TYPE-REFERENCE-BOOK and independent admissions remain queued.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.1.6.7

- [x] **CAPACITY** — Exactly one member/576 manifest bytes/one line and sole ADR0134/index35-line overhead; root/per-file/aggregate and unrelated controls remain exact. Actual pressure/old-admission REDs and independent complete-suffix/root/manifest/registry/decision reconstruction pass.
- [x] **PROOF** — All226 prior files and329 accepted array-end bindings/full claim retained. Production30 thresholds/23 authority denials, four named reviewer/two beyond-immediate-SHA preservation REDs each restore. Original180-file draft/46-file extension, failed reason ordering and wrong-book census remain explicit, byte-bound and owned; corrected readonly producer reconstruction and complete book89/three controls pass.
- [x] **LOCKSTEP** — Guarded readonly392-input/108215-byte claim, exact original369/380 publications, two portable-evidence RED/restorations and11 strict selector denials, reused card and derived map, book/current roadmaps/index/live/MEMORY and bounded histories align. Exact staged canonical CI/receipt and all normal hooks are mandatory landing conditions. Hash-index .5 remains next; no runtime/full-private/parent admission or future capacity reserve.


## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.2.0

- [x] **REPRODUCE / ISSUE** — Actual first-native209 inputs retain opaque/known child publication donation; identical299 TAP has exactly three isolation failures and296 native controls. Original4b48593b5 public argument-premise rejection and six historical replay channels remain explicit.
- [x] **ROOT CAUSE (WHY + WHERE)** — `_lower_mutation_slot_value_expr` directly invoked the actual package CODE callback with parent publication active. The dependency map entry does not select this branch. Actual eligibility and parent packet lookup distinguish borrowed identity and donation.
- [x] **FIX** — Bind only that direct invocation; retain the existing CODE guard/reference and actual trimmed-slot alias. Context, results/errors/effects, callback replacement/localization, method/equality/source fallback and cold loading remain native.
- [x] **ADDRESSED (verified)** — Paired299 now GREEN; six complete syntax-valid source faults fail3/1/35/85/55/7. Seven actual evidence corruptions reject for named reasons and every exact restoration passes. First observations/hashes and rejected indentation/count instruments/merged channels remain unchanged; separate final runs verify the sole whitespace correction.
- [x] **NO REGRESSION** — Final supplied67 actual paths/plans/211 inputs/13660 assertions and exact predecessor diagnostics pass. Supplemental standard syntax/public Phase01035 retains full channels without a full transitive input capsule. Complete secondary helpers/language/private/canonical admission stays separate.
- [x] **LOCKSTEP** — Full book89/three controls, reused Knowledge1349/10375, roadmap/index/live/memory and both bounded histories align. Original350/full84391-byte claim and actual accepted publisher baseline stay exact except one live mode/revision pair. Normal focused doctrine/memory/whitespace hooks govern landing before .3.2.1.

- `2026-10-11`: Remaining-call inventory .3.2.1.0 verifies108/218/812/207/17, six semantic census RED/restorations, two evidence controls, original355/full120239/actual baseline and full book89/3. Readonly339/78574 publication and unchanged211 runtime inputs preserve exact scope. Original returned-CODE reviewer failure/correction retained. Eight bounded fix leaves follow; inline required trim .1 is next after the focused clean commit.

- `2026-10-11`: Inline-required .3.2.1.1 changes one invocation; native213/6/33/2/cold3, paired298/3 original RED/295 controls, six source faults, supplied68/215/13958, evidence6/book89/3, original339/full78574 and standard Phase01035 PASS. Readonly339/78325 publication; stale roadmap table routing repaired. Normal focused hooks govern landing; small optional kind .2 follows the clean commit.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.10

- [x] **REPRODUCE / ISSUE** — Original readonly .2 publication actually rejects the unrelated newer hygiene claim; full separate child channels and accepted baseline are retained.
- [x] **ROOT CAUSE (WHY + WHERE)** — The original .2 live-intersection loop lists current files but reads fixed61cca1ccc objects. Complete fixed namespaces and sole source diff establish the mechanism.
- [x] **FIX** — A separately identified executed reader selects that fixed Git population; retired original capture source/observations remain exact. Current Knowledge/book commands reach readonly accepted reviewers.
- [x] **ADDRESSED (verified)** — Accepted532/extended533 seven cases and maintenance25 recovery pass with actual distinguishing REDs/restorations. Four semantic evidence mutations reject beyond updated immediate hashes.
- [x] **NO REGRESSION** — All390 original bindings/full85779+9306 publications stay exact except historical mode/revision. Runtime/retired proof sources unchanged; full current book89/three controls PASS. No new runtime admission.
- [x] **LOCKSTEP** — Readonly422/97759 publication, three current card routes, public workflow chapter, derived Knowledge, root roadmaps/index/live/MEMORY and both bounded histories align. Normal focused hooks and clean handoff govern landing before .9.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.9

- [x] **REPRODUCE / ISSUE** — First224-input four-process Toolbox/native capture retains40 native rows. Identical285 fixture has98 original REDs/187 controls; both order-dependent rejection and stale acceptance are observed.
- [x] **ROOT CAUSE (WHY + WHERE)** — MethodLowering::_uniform_binding_target_symbol uses /o on its interpolated container regex. Exact accepted Git source, first opposite-order observations and effective full-source inverse establish the mechanism; public selector retirement remains intact.
- [x] **FIX** — Remove only /o from that regex; keep literal quoting, anchors, defined/bare guards and selected callback identity/aliases/errors/native locations. Migrate only the measured five-field legacy row plus its authored result.
- [x] **ADDRESSED (verified)** — All285 GREEN; inverse/unquoted/hardcoded complete source faults reject98/8/67. Four actual semantic evidence corruptions reject beyond updated immediate hashes and exact restorations pass. Original observations/first failed reviewer remain immutable.
- [x] **NO REGRESSION** — Every ordered70 supplied suite/225 input/15378 numeric-plan assertion passes; all other main legacy observations and complete symbolic/object streams are exact. Actual supported public live/standalone results and emitted bytes unchanged. Supplemental standard syntax/public Phase01035 PASS with full channels, without a full transitive capsule/admission.
- [x] **LOCKSTEP** — Readonly490/113730 publication preserves original422/full97759/baseline atde02b83a1. Complete book89/four controls, three current Knowledge routes/derived map, roadmap/index/live/MEMORY and both bounded histories align. Normal focused hooks/clean handoff required before .3; independent admissions stay owned.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.3

- [x] **REPRODUCE / ISSUE** — First226-input loaded/cold Toolbox-style private probes and separate227-input supplemental authority capture retain91+36 loaded/six cold rows before assertions/source edits. Opaque/known native children donate parent publication; corrected229 source pair records50 isolation REDs/179 controls.
- [x] **ROOT CAUSE (WHY + WHERE)** — _lower_method_value_expr outer base_bare_symbol_kind and inner AST-assignment shadow invoke injected selected values without their own private boundary. First complete native observations, exact accepted Git source and disjoint25/25 source inverses establish both sites; actual local outer helper remains distinct.
- [x] **FIX** — Bind only the two injected invocation lines. Actual CODE identity is direct; selected non-CODE values use opaque caller-local delegation. Preserve scalar-name refusal, outer-before-trim/inner-reselection, aliases/effects/context/coercion/errors/fatal identity, cold loading, native locations2550/3850 and global lines.
- [x] **ADDRESSED (verified)** — All229 GREEN, nine full-source variants reject25/25/6/53/41/2/2/74/32 and five beyond-hash semantic evidence controls reject with exact restorations. Exact encoded diagnostic bytes and complete512-input original recovery pass after the retained first hook/context failures. First wrong known-parent oracle, six current failures, failed consumers and two pre-execution fault builders remain exact; the sole oracle correction and separate scoped producer are reconstructed.
- [x] **NO REGRESSION** — Every ordered71 supplied suite/230 input/15607 numeric-plan assertion passes. All native127 loaded/six cold observations preserve complete rows except20 intended authority changes; supplemental original replay exact. Standard syntax/public Phase01035 PASS with full channels, without a full transitive capsule/admission.
- [x] **LOCKSTEP** — Readonly531/125217 final publication preserves original490/full113730/baseline at61a73324 and full first75-file/511-input119230 candidate. Book89/four controls, three current Knowledge routes/derived map1349/10392, roadmap/index/live/MEMORY and bounded histories align. Normal focused hooks/clean handoff required before .4; independent admissions stay owned.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.4

- [x] **REPRODUCE / ISSUE** — First231-input Toolbox-style private native probe retains156 loaded/six cold rows before assertions/source edits. Original identical286 TAP has56 isolation REDs/230 controls; opaque and known children can donate parent packets at both real optional calls.
- [x] **ROOT CAUSE (WHY + WHERE)** — _lower_source_slot_bare_scalar_read_expr kind call6883 and _lower_assign_statement kind call7156 lack independent private invocation boundaries. Complete first native authority rows, exact accepted Git source and disjoint28/28 inverses establish both sites. Read selects before trim; assignment selects after trim/guards.
- [x] **FIX** — Bind only the two invocation lines. Actual CODE binds directly; tied-selected symbolic/blessed values retain opaque caller-local dispatch. Every other source byte/global line, native invalid-call location, reserved/migration/target guard, actual local name alias/mutation, context/coercion/error/fatal/default and cold-loading behavior stays exact.
- [x] **ADDRESSED (verified)** — Current286 GREEN and nine syntax-valid full-source faults reject28/28/8/52/37/8/6/75/18; inverse28/28 sets are disjoint and cover original56. Five actual beyond-hash evidence corruptions reject with exact restorations, including forged native output beyond updated report/reached hashes. Original producers/observations/fixture stay immutable without a correction.
- [x] **NO REGRESSION** — Complete72 ordered supplied suites/233 inputs/15893 assertions and native156/six cold with only20 intended authority changes pass. Actual supplemental standard syntax/public Phase01035 PASS retains separate complete channels without a full transitive capsule or new admission.
- [x] **LOCKSTEP** — Original531/full125217/baseline preserved atdd82f9cb; readonly498/114980 publication PASS. Book89/four controls, four current Knowledge routes/derived map1349/10394, roadmap/index/live/MEMORY and bounded histories align. Normal focused hooks/clean handoff required before .5; independent admissions remain owned.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.5

- [x] **REPRODUCE / ISSUE** — Original234-input native captures precede assertions/source edits. Unchanged-source iterator recurrence varies24 rows solely in clone FETCH order; distinct235 stable input repeats148 loaded/six cold rows/stdout exactly. Identical272 has44 original isolation REDs/228 controls.
- [x] **ROOT CAUSE (WHY + WHERE)** — AST block pipeline and AST call assignment optional calls lack independent private boundaries. Exact accepted source/first native authority rows and disjoint10/34 inverses establish both sites. Original probe unordered FIRSTKEY/NEXTKEY causes the separate unstable diagnostic trace; no production defect is inferred from iterator behavior.
- [x] **FIX** — Bind only two invocation lines. Preserve actual CODE identity, pipeline single-read CODE guard/source/span slots/first nonempty fallback, assignment normalization/two map reads/effective ARRAY slots/local fallback map and opaque caller-local tied dispatch. Distinct stable probe changes only two iterator bodies; original producers/observations stay exact.
- [x] **ADDRESSED (verified)** — All272 GREEN; eleven syntax-valid complete-source faults reject10/34/8/26/37/35/47/82/2/36/11. Inverses are disjoint and cover original44. Six semantic evidence corruptions reject beyond rehashed immediate reports and exact restorations pass. Native148/six changes only16 authority rows; ordinary results/context/coercion/errors/native2170/global lines/fatal/cold remain exact.
- [x] **NO REGRESSION** — Every73 ordered supplied suite/237 input/16165 numeric-plan assertion passes. Supplemental standard syntax/public Phase01035 retains complete channels without a full transitive capsule/admission. Secondary helpers remain controls.
- [x] **LOCKSTEP** — Original498/full114980/baseline preserved at15197dfd; readonly517/119899 publication PASS. Book89/four controls, six Knowledge routes/map1349/10399, all current roadmap/index copies/live/MEMORY and histories align. Stale book kind-isolation sentence is corrected. Normal focused hooks/clean handoff required before .6; seven ingress sites and independent admissions remain owned.


## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.7

- [x] **REPRODUCE / ISSUE** — The actual first native230 loaded/68 cold rows and identical507 original fixture expose144 callback-authority failures while363 native controls pass. This is bounded private integration behavior, without a shipped-language defect claim.
- [x] **ROOT CAUSE (WHY + WHERE)** — The real brace helper316 and dot helper7306/7341/7342 directly invoke formal callable values. Readonly B active-pad probes expose local expr and shared substr lvalues; actual complete rows retain native callable forms and source diagnostics.
- [x] **FIX** — Bind only four invocation expressions. Actual CODE retains its reference; other callable values keep native opaque local dispatch. All other source bytes/global lines and existing bound nesting remain exact.
- [x] **ADDRESSED (verified)** — Identical507/144 original RED/363 controls/all GREEN; all14 syntax-valid faults distinguish authority, aliases, contexts and scan order. Four inverses cover exactly144 original failures, including disclosed dot whole-row overlap. Six semantic evidence corruptions reject beyond updated immediate hashes and restore exact PASS.
- [x] **NO REGRESSION** — Every75 ordered supplied suite/243 input/17188 numeric-plan assertion passes. Complete230/68 native population changes only52 authority rows; unchanged-source recurrence is byte-exact. Supplemental standard syntax/public Phase01035 passes with actual channels, without a complete transitive capsule or admission.
- [x] **LOCKSTEP** — Original519/full119936/baseline remains exact atb1133da42. Readonly522/120245 publication, book89/four controls, six Knowledge routes/map1349/10406, root projections, bounded histories and live/MEMORY pointers align. Normal focused hooks and clean handoff precede named dispatch .8; independent admissions remain open.


## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.8

- [x] **REPRODUCE / ISSUE** — Complete185 loaded/28 cold rows and identical487 original fixture retain132 authority-only REDs/355 native controls. Original six-card header census retains four orphan entries and actual semantic header RED before correction. Bounded private integration and current documentation defects do not imply a shipped language defect.
- [x] **ROOT CAUSE (WHY + WHERE)** — Real dispatch invocation694 bypasses the child boundary. Readonly active pads expose actual selected CODE/local trimmed/deps argument slots and six-reference snapshot. Actual portable awk clears its list key after scalar reverify fields, ignoring the orphan entries; the existing gate checks field presence and accepts that malformed syntax.
- [x] **FIX** — Bind only the retained selected CODE invocation. Normalize six current headers to scalar readonly routing, retaining every original route/body and actual .5 iterator inputs. Keep canonical gate hardening separately owned by .11 before FlowExpr.
- [x] **ADDRESSED (verified)** — Identical487/132 original RED/355 controls/all GREEN; all12 syntax-valid source faults, exact inverse132 failure population and seven actual semantic evidence RED/restorations distinguish source/native/original/consumer/book/header forgeries beyond immediate hashes. Header current6/zero orphan passes the same original-RED reviewer.
- [x] **NO REGRESSION** — Every76 ordered supplied suite/246 input/17675 numeric-plan assertion passes. Native185/28 changes only54 authority rows; original recurrence is byte-exact. Supplemental standard syntax/public Phase01035 passes with actual channels, without a full transitive capsule or admission. Six named helper implementations remain secondary controls.
- [x] **LOCKSTEP** — Original522/full120245/baseline remains exact at22132b2b. Readonly534/123810 publication, book89/four controls, six scalar Knowledge routes/map1349/10411, root projections, bounded histories and live/MEMORY pointers align. Normal focused hooks and clean handoff precede canonical gate .11; independent admissions remain open.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.11

- [x] **REPRODUCE / ISSUE** — Public knowledge-map/scripts/check_knowledge_map.sh fixture retains all 20 cases and complete 80-assertion original TAP: eight malformed headers, including both original affected headers, cause 16 REDs while 64 controls pass. Actual native channels and Git/capsule inputs remain exact.
- [x] **ROOT CAUSE (WHY + WHERE)** — Existing checker awk retains curkey after scalar/inline values; required-field presence and scalar answers can hide malformed list association. Source location knowledge-map/scripts/check_knowledge_map.sh, against KNOWLEDGE_MAP_ARCHITECTURE.md section2; Toolbox-directed public generator/checker observations establish the mechanism.
- [x] **FIX** — Empty-value keys alone own block lists; retain malformed answers for denial and report exact line numbers. Canonical tools/run_ci_local.sh runs the unchanged public fixture. No runtime implementation change.
- [x] **ADDRESSED (verified)** — All 80 assertions PASS; source regressions fail 14/2/16 and restore GREEN. Both semantic evidence corruptions receive the distinguishing denial and exact restoration PASS. The first mistaken control and 14/2/34 failure data remain immutable with distinct corrected source identity.
- [x] **NO REGRESSION** — Complete current Knowledge gate PASS over 1,485 Markdown inputs/1,349 facts, six planned route overlays and unchanged original bodies. All original 534 bindings/full 123,810 bytes and actual readonly baseline remain historical at activation Git. Exact staged canonical CI is required by the landing gate. Deferred metadata projection is owned by P3 .12 after factory/pipeline.
- [x] **LOCKSTEP** — Six Knowledge headers/current derived map, local architecture, public workflow examples, roadmap/task projections and continuity agree. Complete book 89 inputs/four actual controls PASS; memory/history/doctrine/whitespace and exact staged canonical receipt govern landing.

- `.11` canonical3 continuation: native illustrative labels pass20 current rows and reproduce both historical cached-second-target REDs. The first harness mistook string SystemExit for stderr and is retained separately. The first after harness exposes42 rather than40 references:15197dfd introduced two redundant negative selector mentions in the private source/assignment subsection. Own their prose-only correction within this leaf, retaining all70 current bytes and the exact failed instrument/log before editing; the unchanged primary checker/count and canonical composed public gate govern closure.

- `.11` composed-public prerequisite: actual tool67988 exits1 after the documentation classifier passes, because eight exact accepted private/negative native fixtures introduced since the last canonical source registration have14 selector-shaped lines. They directly call MethodLowering, assert original private observations, or assert public rejection; none is positive authored syntax. Own an exact path/SHA registration using the scanner's existing immutable diagnostic mechanism, preserving the old scanner/full failed channels and all eight bytes before editing. Prove the unchanged scanner algorithm with14 original REDs, zero repaired positives and24 per-file copied-path/changed-byte/added-selector controls; no wildcard, suffix or syntax exemption. No live claim binds the scanner in the actual pre-write census. Add composed public guards to upcoming FlowExpr/ControlFlow/pipeline focused checks.

- Remaining FlowExpr `.4`, ControlFlow `.5` and pipeline `.6` each run tools/check_public_aggregate_selector_surface.py as focused direct-dependent proof whenever editing public compiler teaching or adding synthetic native sources. Inspect each exact positive rather than relaxing the public selector contract. This requirement is part of their implementation/verification plan; registration `.7` remains before pipeline.

- `.11` portability repair owner: canonical4 session22423 reports repo-root-path-portability rejects two plain-text retained traceback fields; it is deliberately interrupted with actual130 in only its identified process group99786. The exact cause is the new document harness failure serializer using log.decode() instead of encoded raw channels. Preserve the complete177-input/full44317 publication and actual readonly baseline before any binding changes, retain the two original whole JSON byte strings in a compressed supplied overlay, and convert only their log representation to base64. Distinct .11-portability producers must replay the unchanged third publisher against its complete original177 byte identities, verify exact decoded-log equivalence, retain original observations and current six-header/body lineage, and repeat current Knowledge/book/public checks plus semantic corruption/restoration. No portability checker relaxation, runtime change or fabricated historical commit. All future captured diagnostics stay encoded.

- `.11` diagnostic portability closure: preserve74590/0 verifies every177 original binding/full44317 record and actual readonly baseline before ten bound-input overlays change. Replay81477/0 supplies all177 exact originals and full1485 Markdown to the unchanged third publisher, rejects whole-claim and missing-fixture corruptions, then restores byte/mode-exact PASS. Both original whole failure JSONs remain compressed and their new base64 logs decode exactly; all other fields agree. Current full Knowledge98254/0, complete book6406/0/book-review0, actual focused portability65387/0/composed public73387/0 and separate-channel validation96585/0 pass. Independent review4474/0 passes195 inputs; evidence12519/0 rejects changed diagnostic bytes and a rehashed orphan current header, then restores. Final publication24827/0 passes198 live inputs/full51535 bytes. Canonical4 deliberate130 and exact reported portability RED remain retained without a full canonical admission. Require exact staged canonical5/normal hooks; earlier producers/observations stay retired and unchanged.

- `.11` canonical5 claim-registration owner: actual session75557 exits1 after nine doctrines PASS because the live claim directly binds rgx/README.md, which is published public documentation inside a Git submodule and is not a parent-tracked file. The actual full198-input census finds exactly this one parent-untracked binding. Own a byte-exact parent-tracked snapshot of that public input, preserve the complete current198/full51535 publication before bound route/card/map writes, replay its unchanged producer with all original bytes, and declare the explicit live public-file-to-retained-snapshot mapping in the final reader/publisher. Other repositories/submodules stay read-only and their pin is unchanged. Do not relax the claim verifier or remove the public-file census. Check parent tracking of every final input before canonical6 and retain actual failure channels.

- `.11` parent-input closure: preserve58355/0 retains all198 bindings/full51535 and actual readonly baseline before eight route/card/map overlays change. Replay11034/0 supplies every original byte to the unchanged fourth publisher; whole-claim and missing-fixture corruptions reject and restoration agrees exactly. The sole external public README is copied byte-exact into a parent-owned snapshot, compared read-only with current published bytes and the unchanged real gitlink. Current Knowledge38076/0, book97077/0/book-review0, separate focused validation76062/0 and independent215-input review58322/0 pass. Evidence84918/0 rejects a rehashed snapshot and a forged gitlink record, then restores. Final publication97525/0 passes218 live inputs/full58582; no direct submodule path remains in its binding list. The extra final public fixture passes80 at20451/0; an initial nonexistent wrapper invocation127 is retained only as supplemental ignored command output and corrected without test/source changes. Stage and verify every declared path is parent-tracked, run the claim preflight, then exact canonical6/normal hooks before landing. No submodule implementation or pin changed.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.4.1

- [x] **REPRODUCE / ISSUE** — First100-input private Toolbox-style native factory capture retains27 warm/27 cold rows before assertions/source edits. Original402 TAP has47 missing-registration REDs/355 controls; current native callbacks have no original selection.
- [x] **ROOT CAUSE (WHY + WHERE)** — Complete native map/callback/build-context probes and original full FlowExpr::default_deps_for_package source identify nine returned native references with no FlowExpr-specific definition-owned selector. Equal names or unrelated catalogues cannot supply authority. Exact raw diagnostic channels identify and own all fixture/inventory refinements separately.
- [x] **FIX** — Two original factory delimiters delegate through appended context-preserving helpers; one separate nine-reference EmitContext catalogue/actual-identity selector registers built-in returned maps. Public callbacks/maps, existing required/optional bindings, original FlowExpr diagnostic lines and OwnerDispatch remain exact.
- [x] **ADDRESSED (verified)** — Final identical402 assertions retain the exact47 original failure names/numbers/355 controls and all GREEN. All22 full two-module syntax-valid source faults reach402 semantic RED, including the exact original inverse; six coherent artifact forgeries reject and restore PASS.
- [x] **NO REGRESSION** — Complete79 supplied suites/270 inputs/20634 assertions and exact predecessor plans/stderr pass. Supplemental standard syntax/strict-vars and public Phase0 reaches its full1035 plan/PASS; composed public guard70/40 and full book89/four controls pass. Broader private/parent/canonical admission remains separately owned.
- [x] **LOCKSTEP** — Readonly449/106177 publication preserves full426/99413/baseline at98f8d5d7f; dated full Knowledge1485/1349/nine overlays/8385408 under unchanged8388608, book, roadmap/index/live/MEMORY and bounded histories align. Normal focused hooks and clean handoff precede ControlFlow .5; fixture .7 remains before pipeline .6.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.5.0

- [x] **DIAGNOSE (LinkedSpec tools)** — First native diagnostic100 inputs/176 warm/132 cold and exact fresh-process recurrences precede expectations/source edits. Actual authority ledger and original paired848/198 RED/650 controls reproduce enclosing eligibility and packet donation.
- [x] **ROOT CAUSE (WHY + WHERE)** — Three original required-validator returns expose raw dependencies to the enclosing publication frame. Native switch tag normalization is list context in the hash constructor, while remaining selected sites are scalar; preserve that distinction. The separate first reader failure is traced to JSON spacing before gzip and retained with its exact source/reported channel.
- [x] **FIX** — Bind only the three selected validator returns through one appended lazy alias/context forwarding helper. Public maps and actual callback references, eager validation/selection and all original global diagnostic lines remain exact. Distinct final reader compares whole decoded fault records while binding both original gzip identities.
- [x] **ADDRESSED (verified)** — Identical848 assertions reproduce198 original authority REDs/650 controls/all GREEN; all13 complete syntax-valid variants reach848 semantic RED, including the exact inverse. Six coherent artifact forgeries reject for their deeper reason and restore exact source bytes/modes.
- [x] **NO REGRESSION** — Complete80 supplied suites/277 inputs/21482 assertions retain all predecessor headers/plans/stderr. Strict-vars/standard syntax/public Phase01035 and composed public guard pass. Full book89/four controls and dated Knowledge1485/1349/nine overlays pass. Independent private/parent/canonical admissions remain open.
- [x] **LOCKSTEP** — Current readonly428/full100775 preserves original449/full106177 and actual baseline at aa8823343. Nine live card routes retain all original headers/bodies in Git; Knowledge8384946 stays under unchanged8388608. Book, roadmap/index/live/MEMORY and bounded histories align. Normal focused hooks and clean handoff precede .5.1; .7 remains before .6.

- `2026-10-17`, `.5.1.3`: Exact finite history prerequisite; whole449/full105765 custody, complete1978 original-project replay, production30/23 and five semantic artifacts, full Knowledge1486/1349/8387290/book89/four and readonly507/117862 pass. First copied-root/reader/artifact failures stay frozen. Exact staged canonical receipt and normal hooks govern this commit before .5.2.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.5.2

- [x] **ROOT CAUSE (WHY + WHERE)** — Six original required validators return raw selected callbacks, so their parser/normalizer invocations use enclosing producer eligibility and can donate nested equal-text publications. Actual native-first probes and the unchanged1750 fixture establish294 original failures; six individual validator inverses locate each boundary.
- [x] **SCOPE** — Change exactly six return lines in the named if/while owners. Preserve helper/defaults/algorithms, six earlier bound validators, ten later raw validators and global line count. No public contract or pipeline admission changes.
- [x] **ADDRESSED (behavior)** — Identical1750 assertions are GREEN; all670 complete native rows and exact recurrences remain unchanged. Sixteen syntax-valid complete-source variants reject; the exact inverse reproduces every294 original failure name/number. First overwritten-case instrument/source/350/308 observations remain frozen beside the exact complete-inventory correction.
- [x] **NO REGRESSION (focused)** — All84 supplied suites/310 inputs/24959 assertions pass with accepted83 headers/plans/stderr exact. Public guard and full1486 Knowledge/1349 facts/twelve overlays/8388171 bytes pass. Full89-source book renders and its four actual controls and independent rendered-semantic review pass.
- [x] **LOCKSTEP / LANDING** — All nine artifact denials/restorations and standard syntax/public Phase01035 pass. Readonly463/109061 publication, live pointers/roadmap and current Knowledge/book align. Normal all10 doctrines, explicit memory/history/diff checks and clean/post-pointer/post-memory verification govern landing before switch .5.3. Independent admissions stay open.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.5.3

- [x] **REPRODUCE / ISSUE** — The retained native LinkedSpec::ActionIR::ControlFlow/MethodExpr probe and run.py before show273 actual callback/parent-publication REDs in complete1641 TAP;1368 ordinary controls pass. This is the planned private compiler mechanism, not a demonstrated public switch bug.
- [x] **ROOT CAUSE (WHY + WHERE)** — t/actionir_control_switch_native.pl records the real selected normalizer under the parent SourceEmissions::_call at six unbound required validators in perl/LinkedSpec/ActionIR/ControlFlow.pm. Actual callback identity is absent from that frame; an opaque dependency can donate matching text to the enclosing packet. The original native channels and exact six-line source oracle distinguish this mechanism.
- [x] **FIX** — Six original required-validator return lines use the existing _bind_emission_dependency helper. Public map selection, aliases, references, errors, state, helper/default bytes and diagnostic line count stay native; no new DSL syntax or .spec content.
- [x] **ADDRESSED (verified)** — Identical1641 assertions pass; original273 failure names/numbers are restored exactly by the full-source inverse. All630 ordinary native rows and recurrences remain exact. Fifteen source faults have witnesses; the copied-return variant has none and is excluded from the effectiveness claim. All85 supplied suites/317 inputs/26600 assertions pass.
- [x] **NO REGRESSION** — All five standard syntax/public Phase0 commands complete successfully with full channels in compat.json, including the actual1035-assertion PASS and true stop. Full85 supplied suites and exact readonly composition/publication pass. Normal doctrine hooks and explicit memory/post-pointer/clean-state checks govern landing.
- [x] **LOCKSTEP** — Book switch boundaries and corrected current workflow teaching each render under complete89-input/four-control captures. The complete original465-input proof replays from its frozen source before the single workflow paragraph correction. Whole prior463/full109061 publication and actual baseline stay historical at09000223f. Full Knowledge1486/1349/twelve/8388218 and public guard pass; live continuity is owned here. USER_GUIDE needs no new DSL teaching because ordinary switch syntax/behavior is unchanged.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.5.4

- [x] **REPRODUCE / ISSUE** — Retained native LinkedSpec::ActionIR::ControlFlow/MethodExpr output probe and run.py before show264 private authority failures in complete1146 TAP;882 original controls pass. Controlled callback results are distinguished from the separate public diagnostic suite.
- [x] **ROOT CAUSE (WHY + WHERE)** — Actual parser/trim/extractor callback frames in perl/LinkedSpec/ActionIR/ControlFlow.pm remain the parent at four raw required-validator returns. Native authority records identify each actual parser/trim/extractor reference, inherited eligibility, parent donation and absent matching own packets. The independently reconstructed four-line source delta names the precise mechanism and locations.
- [x] **FIX** — Four original required-validator return lines use the existing _bind_emission_dependency helper. All22 required validators are bound; helper/defaults/algorithms/line count and public callback maps stay unchanged. Optional kind remains separately owned.
- [x] **ADDRESSED (verified)** — Identical1146 assertions pass; exact inverse restores all264 original names/numbers. Thirteen syntax-valid full-source faults reject; all432 native ordinary rows/recurrences remain exact. Matching registered scalar trim/extractor returns retain only their own packet; parser references retain none; no parent donation occurs.
- [x] **NO REGRESSION** — Full87 supplied suites/332 inputs/27762 top-level assertions pass with predecessor85 headers/plans/stderr preserved. Dedicated public diagnostic before/after329-input captures each pass16 top-level assertions across native/generated/CLI routes. All standard syntax commands and actual public Phase01035 reach their complete successful stop; normal doctrine hooks govern landing.
- [x] **LOCKSTEP** — Full Knowledge1486/1349/twelve overlays/8388501 bytes and book89/four actual controls pass. Whole prior480/full111654 publication and actual baseline stay historical at4a8e92aef. First inventory rejection and exact one-label correction stay frozen; nine artifact denials/restorations and readonly495/full117562 pass. Existing wrapper warning and limited kernel sample retain explicit startup.7 ownership, source custody and falsification gap. USER_GUIDE has no new DSL semantics to document; current helper/event/exit behavior is preserved.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.5.5

- [x] **REPRODUCE / ISSUE** — Actual native ControlFlow callback/SourceEmissions frames and unchanged paired452 TAP reproduce77 private authority failures with375 controls; separate public diagnostics pass. No public print_each bug is inferred.
- [x] **ROOT CAUSE (WHY + WHERE)** — perl/LinkedSpec/ActionIR/ControlFlow.pm:1728 invokes optional second selections in the enclosing producer frame. Actual callback identity is absent and a matching nested publication can reach the parent. Retained native probes locate the native match alias, two tied-map reads and original error line.
- [x] **FIX** — Bind on the original opening condition line using an appended actual-CODE/opaque-native-call selector. Both dependency reads, guarded scalar call, aliases, diagnostic locations, helper/default bytes and public references stay native; no DSL or default-provider change.
- [x] **ADDRESSED (verified)** — Identical452 assertions PASS; exact complete-source inverse restores all77 failure names/numbers. All176 original ordinary rows/recurrences remain exact;12 syntax-valid complete-source faults reject. Five artifact denials include three coherently rehashed native-data controls; every restoration is byte/mode-exact PASS.
- [x] **NO REGRESSION** — All88 supplied suites/339 inputs/28214 assertions PASS with predecessor87 headers/plans/stderr exact. Separate public diagnostic before/after336-input captures each PASS16 top-level assertions. Standard syntax and public Phase0 reach full1035/PASS. Complete Knowledge1486/1349/twelve overlays and book89/four controls plus public guard PASS; normal doctrines and explicit memory/diff checks govern landing.
- [x] **LOCKSTEP** — Whole117562-byte two-claim predecessor/495 affected bindings and actual baseline stay historical at dadce45ac8; kernel sample unchanged. Initial tied-map snapshot and first Knowledge integrity rejection remain frozen. Distinct final Knowledge8388480 stays under unchanged8MiB; eleven card bodies stay exact and dated framework history condensation retains original Git bodies. New readonly506/full116166 publication, book, roadmap and handoff agree. USER_GUIDE needs no new DSL semantics; direct/rule/default/fixture/pipeline/independent admissions remain open.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.5.6

- [x] **REPRODUCE / CAUSE** — Actual selected lowerer/rule frames reproduce435 authority failures in1290 TAP with855 controls. Original420 rows and first1272/423 remain frozen; tied selection and native source locate both unbound invocation lines. Separate single-publication and cardinality62/one RED controls distinguish isolation from ambiguity.
- [x] **FIX / VERIFIED** — Two invocation lines use existing actual-CODE/opaque boundaries; exact inverse restores435 names/numbers. All426 ordinary rows/recurrences stay exact;14 syntax-valid full-source faults reject, including six clone-order failures. Contexts, aliases, public references, error locations and SourceEmissions stay native.
- [x] **NO REGRESSION / CUSTODY** — Full89/349/29504 consumers, public diagnostics343/16 before/after, standard1035, Knowledge8388505 and book89/four controls pass. Six semantic artifact denials restore exact originals, including a native-derived rendered counter oracle. Whole predecessor and failed/corrected readers remain retained; readonly525/full121708 passes. Normal focused hooks and post-pointer/brief0/clean checks govern landing.
- [x] **LOCKSTEP** — Book examples, current task/index/roadmap and bounded handoff agree. Default/fixture/pipeline/independent admissions remain separately owned. USER_GUIDE has no changed DSL contract to document.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.5.7

- [x] **REPRODUCE / CAUSE** — Exact native provider references reproduce53 mixed authority failures in445 assertions. Published native builder/actual specifications expose84 ordinary object mismatches and100 failures in444 assertions across three factories; equality overloads locate the target-name guard defect. Initial401/44 and full logical-draft sources/data remain preserved.
- [x] **FIX / VERIFIED** — Seven target facade definitions and fixed ValueExpr selection stay independent. Three !ref guards preserve object dispatch and native contexts without coercion or new facade grants. Identical445/53 and444/100 pairs pass with392/344 controls. Mixed26/26 native rows stay exact; object108/108 differences become zero. All18 mixed/ten object complete-source variants reject; exact inverses restore every original name/number.
- [x] **NO REGRESSION** — All91 supplied suites/363 inputs/30394 assertions pass. Initial90 plans stay exact; accepted89 add only one reconciled FlowExpr selector rejection. Diagnostics358/16 before/after, eight standard commands/public1035, explicit four-fixture public guard, complete Knowledge1486/1349/thirteen overlays/8388255 and book89/four controls pass. Four fact bodies change; nine route-only bodies remain exact. Rendered provider/object tables derive independently from native observations.
- [x] **CUSTODY / LOCKSTEP** — Whole prior525/full121708 stays historical atce9eaf32e. Complete initial546/full127929 draft, actual baseline and byte/mode archive precede repair; actual2020-file saved-input publisher replay passes after repair without a fake revision. Initial failed producers, two prewrite budget refusals and scoped reruns stay bound. Ten semantic artifact denials restore exact bytes/modes. Corrected readonly565/full129686 passes. Book/cards explicitly retain no-new-grant versus prior authority; roadmap/index/handoff align. Normal focused hooks and post-pointer/brief0/clean checks govern landing; finite continuity, fixture/pipeline and broader admissions remain owned.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.5.8

- [x] **REPRODUCE / CAUSE** — Actual complete369-line/59429-byte root triggers rollover255. Unchanged production limits reject files51/50, manifest50/49 lines/28559/27983 bytes and29516/29512 note lines. Complete1980/1981 original-project data/helper/config/namespace and four historical Git fixtures retain all channels.
- [x] **FIX / VERIFIED** — Sole accepted/indexed ADR0136 admits exactly six scalars: one actual member/manifest, one512-line note aggregate envelope and41 sole decision/index lines. Independently reconstruct exact257-line/26898-byte source109–365, retained111-line/32530-byte root, every prior manifest row and230 old files. All unrelated root/byte/per-file/membership controls stay exact; no future archive reserve or director-grant claim.
- [x] **CUSTODY / FALSIFY** — Whole565/full129686 compiler claim, every original binding/actual mode and actual baseline precede only mode/revision preservation at54bb5eb65. Original wrong control populations reject independently; exact two-line correction recurs with60 numeric/31 authority controls. Original helper-classification reader failure and precise repair remain retained. Seven semantic forgeries retain full counterfactual bytes/modes/channels and exact restoration; readonly550/full128458 passes.
- [x] **LOCKSTEP / ADMISSION** — Full Knowledge1486 original/1487 current,1349 facts/thirteen routes/one body/8388337 bytes and book89/four controls pass. Twelve card bodies and native teaching stay exact; all original accounts remain recoverable. Current roadmaps/index/live/pointer agree. Exact staged canonical CI/receipt, all normal hooks, post-pointer/memory/brief0/clean checks govern landing. Due artifact review precedes fixture .7; broader private/pipeline/parent admissions stay owned.

- `2026-10-19`, clean maintenance handoff: REPO-HYGIENE.19 preserves .5.8 whole550/full128458 at e953f69a9, retains dated parent/Rust metadata and complete public compiler-summary evidence with zero removals. Fuller warning census/report remains RUST-DEPENDENCY-WARNING-ZERO.1/.2. Fixture .7 is next only after the maintenance commit/brief0/post-pointer/clean checks; pipeline .6 and broader admissions remain open.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.7

- [x] **REPRODUCE / ISSUE** — Actual inventory-final.py require-complete command exits1; complete original91/46/363 population retains86 direct prove/132 tracked/131 syntax omissions. LinkedSpec focused callback fixtures remain unchanged.
- [x] **ROOT CAUSE (WHY + WHERE)** — tools/run_ci_local.sh selects literal commands, including source-bound raw dependency readiness near its former1103; new fixture creation supplies no implicit registration. Unchanged verify_objectives governance function passes original runner then rejects the added exact block. Actual first tool/source failures identify every bounded instrumentation correction.
- [x] **FIX** — One exact150-line block checks137 tracked/syntax paths and runs all91 supplied suites; narrow historical inverse preserves all older bytes and adds280 effective path/block/disabled/foreign controls. No Perl/DSL/runtime, fixture or dependency change.
- [x] **ADDRESSED (verified)** — Actual Bash137/91/30394 PASS; four actual exit-zero alternatives have effective population REDs. Complete historical proof134/84613241 and22/368 controls PASS with zero healthy original-log reads/tracked writes. Six artifact denials and a whole-draft semantic forgery each restore exact PASS.
- [x] **NO REGRESSION** — All363 supplied bytes/modes stay exact; native/current bodies and public diagnostics fixtures stay unchanged. Canonical receipt supplies the required full public Phase0 and cross-backend admission; focused proof does not substitute for it.
- [x] **LOCKSTEP** — Whole175/full43696/baseline historical at858eba97c; complete Knowledge1487/1349/15 routes/one body/8388024 and book89/four controls PASS. Initial source/draft/refusal lineages stay exact; current603/full115985 publication, task/index/roadmaps/bounded histories and intended clean pointer agree. Pipeline and broader admissions stay separately owned.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.6

- [x] **REPRODUCE / CAUSE** — Original native96 and supplemental9 rows precede production/assertions. Calibrated fixed-plan1988/1128 RED locates absent invocation producer/input scopes and five unseparated callback seams in RewritePipeline. Actual before-import direct/prove observations distinguish diagnostic filenames; original failed hypotheses/readers remain retained.
- [x] **FIX** — Fresh scopes are inside SourceOrigins before factories. Four selected dependencies and actual canonical apply have separate scalar frames. One-fetch call-local apply selection preserves symbolic/blessed/overloaded dispatch and original native diagnostic line489. Public references/maps, arguments, family order and replacement algorithm stay unchanged.
- [x] **ADDRESSED (verified)** — Same2065 assertions pass and distinguish13 exact syntax-valid semantic inverses. Actual same-token opaque publication cannot donate; nested successful/fatal calls restore actual parent call/registries/source and builder authority. Actual public native factory/callback/origin/tokens match; complete426 supplied inputs and all91/32235 consumers pass with byte/mode/parent custody.
- [x] **NO REGRESSION** — Required syntax checks and the complete wrapped public Phase0 pass1035/1035. The separately wrapped fallback/native-resolution pair passes32 and restores the volume assertion. The stopped invalid invocation stays retained separately; it is never classified as acceptance.
- [x] **CUSTODY / FALSIFY** — Whole603/full115985/baseline stay historical at64b66167c. Every original native/RED/repair and direct-GREEN boundary stays distinct; disclosed merged/post-run limits remain explicit. Eight coherent artifact interventions reject with named semantic/source reasons and exact restored PASS. Original first2 actors are preserved; remaining6 use a distinct finisher and actual retained restoration baseline.
- [x] **LOCKSTEP / LIMITS** — Full captured Knowledge1487/1349/10448, fifteen routes/two bodies/8384111 and book89/four controls pass; thirteen bodies and all older rendered tables stay exact. Existing canonical suite selection already runs the expanded framework fixture. Current root/task/roadmap/live/history/pointer handoff agrees; normal focused doctrines/history/memory/whitespace govern landing. Output/mapping/quoted-first/private/parent admissions remain separate.

## Transport and input-closure acceptance — PERL-PRIVATE-FACTORY-CAPTURE.6

- [x] Original complete625 declaration/whole123401, actual161 omitted namespace and both readonly baselines precede bound writes; failed625 replay and distinct corrections stay exact.
- [x] Standard solidus JSON transport has decoded equality and exact byte inverse; current 2065 fixture/426 guards pass with only that data encoding change.
- [x] Unchanged original readers pass with all786 supplied overlays and whole claim/mode guarded; forged argument, unescaped transport and coherently omitted claim each actually reject and restore exact healthy state. Unchanged path gate passes.
- [x] Full current supplied Knowledge re-derivation/check, whole book/four controls and every original table pass. Complete current bounded publication, continuity and normal focused doctrine/hook workflow govern landing; broader admissions stay owned.

## Knowledge routing acceptance — PERL-PRIVATE-FACTORY-CAPTURE.6

- [x] Original complete625 declaration/whole123401, actual161 omitted namespace and both readonly baselines precede bound writes; failed625 replay and distinct corrections stay exact.
- [x] Standard solidus JSON transport has decoded equality and exact byte inverse; current 2065 fixture/426 guards pass with only that data encoding change.
- [x] Unchanged original readers pass with all786 supplied overlays and whole claim/mode guarded; forged argument, unescaped transport and coherently omitted claim each actually reject and restore exact healthy state. Unchanged path gate passes.
- [x] Full current supplied Knowledge re-derivation/check, whole book/four controls and every original table pass. Complete current bounded publication, continuity and normal focused doctrine/hook workflow govern landing; broader admissions stay owned.

## Acceptance Checklist — PERL-PRIVATE-FACTORY-CAPTURE.3.2.1.12

- [x] Complete current/source-before populations and all intersecting live claims are preserved before bound writes; original observations and both input/assertion corrections remain exact.
- [x] Original80/corrected176, all30 public rows, all897 entries/248 fields, every scalar and10455 question rows pass with complete producer/input/mode custody.
- [x] Ten syntax-valid complete-plan source faults and three coherent artifact denials observe named REDs and exact healthy restoration.
- [x] Actual pressure RED, blank-only containment, actual render equality/visible control and exact archived output recovery pass under unchanged policies.
- [x] Current full supplied graph/book89/four controls, public70/40 and pressure20/62/40 pass. Exact staged canonical receipt plus normal hooks govern landing; broader owners remain open.
