# PERL-PRIVATE-FACTORY-CAPTURE: Actual factory and dependency emission capture

## Metadata

- Tree ID: `PERL-PRIVATE-FACTORY-CAPTURE`
- Status: `active` / MethodLowering required inference bindings accepted; inline/block family next
- Roadmap lane: `.spec language evolution / producer-bound residual repair`
- Created: `2026-10-10`
- Last updated: `2026-10-10`
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
  Children: `PERL-PRIVATE-FACTORY-CAPTURE.1`, `PERL-PRIVATE-FACTORY-CAPTURE.2`, `PERL-PRIVATE-FACTORY-CAPTURE.3`, `PERL-PRIVATE-FACTORY-CAPTURE.4`, `PERL-PRIVATE-FACTORY-CAPTURE.5`, `PERL-PRIVATE-FACTORY-CAPTURE.6`.
  Acceptance: Individual bounded owners preserve current public behavior and pass source-bound focused proof. Return independent composition to the original owner; no separate parent admission is inferred.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.1`
  Status: `done` / `focused-signoff-complete` (activated from clean `02345ee21f9cd674dea073b5e25f6200bd0a6ead`)
  Goal: Private registration/dependency boundary framework and native differential lifecycle/context/alias/error proof; no production factory or pipeline activation.
  Dependencies: `RUST-DEPENDENCY-WARNING-ZERO.8`
  Owned paths: `perl/LinkedSpec/ActionIR/SourceEmissions.pm`; focused fixture/proof/claim, relevant Knowledge/book and continuity. No unrelated producer or mapping changes.
  Verification tier: `focused`
  Focused checks: Actual/native callback and invocation identities; scalar/list/void context, aliases, once-only effects, exact return/error/fatal values, opaque nested delegation, scope restoration/release and unchanged public maps. Complete supplied direct consumers, effective semantic faults, retained instrument/input/channel identities, complete relevant book and ordinary doctrines.
  Canonical trigger: none for bounded private implementation without public/generated/mechanical change; reclassify before writes if scope crosses those boundaries. Complete private Phase0 and canonical replacement remain separately owned.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.1.json`
  Acceptance: Follow the retained owner plan; choose no authority by name, copied metadata or equal value. Preserve existing selected input grants and callback references. Split further before writes if actual code paths exceed a safe slice. Commit before activating the next owner.
  Result: The standalone private framework passes224 assertions,30 native differential modes and11 effective semantic source faults;17 direct suites in136 supplied files, evidence4 and complete book57/two controls pass. Actual callbacks register only in their current source/producer scope. Scalar dependency calls get separate captures; list/void calls retain native contexts with publication disabled. Caller aliases, once-only effects, returns/errors, map references and lifetime are preserved. The initial four identity failures came from a shared native fixture callback and are retained with the actual reference probe; lexical fixture closures correct that assumption without another production change. Original232 input-composition bindings are historical. Production factory/pipeline/output/mapping/full-private/canonical integration remains open; Contracts owner .2 is next.
  Signoff evidence: Source-bound capture/review, native closure probe and all initial draft source/instrument/channels retained under docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.1-*. Complete positive and each syntax-valid fault retain coherent224-assertion TAP and distinguishing semantic failures. Evidence controls reject failed positive, missing reader artifact, missing inverse and missing semantic reason after a rehashed index, then restore actual PASS. Complete57-source book retains missing SUMMARY and removed rendered-marker controls. Exact original232 input hashes and mode/revision-only preservation are independently reviewed; actual original-hash corruption rejects and restores.
  Reverify: `bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.1-final-review.py`; separately run `PERL-PRIVATE-FACTORY-CAPTURE.1-preservation-control.py` with the same wrapper. Capture/freezer/claim publisher entrypoints are one-shot; do not replay them.
  Verification: `focused-signoff-complete`; ordinary history/Knowledge/memory/claim/doctrine/whitespace checks govern the staged candidate.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.1 - isolate native dependency calls`

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
  Owned paths: `perl/LinkedSpec/RuleIR/EmitContext.pm` only for private actual built-in callback references and its resolved owner/default-factory invocation seams; focused fixture/proof/claim, relevant Knowledge/book/continuity. No OwnerDispatch, contract factory, SourceEmissions, parser/output/mapping or pipeline-scope activation change.
  Verification tier: `focused`
  Focused checks: Actual native facade reference versus same-name override/custom target/copied metadata; source/producer scopes and ordinary reference return; actual opaque owner nested-publication control; native scalar/list/void value/effect/error/reference/context comparisons including the existing copied-argument behavior; Trace/cold require and complete supplied direct consumers; effective semantic source faults, retained actual instruments/inputs/channels and reviewer controls; complete relevant book; ordinary doctrines.
  Canonical trigger: none for this bounded private prerequisite without public/generated/mechanical changes. Escalate before writes if selected proof exposes cross-cutting uncertainty. No parent/canonical admission inferred.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.2.0.json`
  Acceptance: Snapshot the actual definition-owned native references without selecting authority from a later public name lookup. A changed callback or custom target remains opaque; a retained same actual reference remains selectable. Separate every resolved owner/default-factory invocation; preserve existing lazy load, native context/arguments/effects/error behavior and trace order. Do not activate pipeline scopes or transfer child packets implicitly. Preserve original framework claim before changing its inputs. Commit before child .2.1.
  Result: EmitContext passes345 main/five cold assertions,30 exact native/current observation ledgers and13 effective semantic source faults. Nineteen direct suites in138 supplied files, four actual reviewer REDs and complete57-source book/two controls pass. Actual definition-owned references select28 native callbacks; same-name replacements and copied metadata remain opaque. Resolved owner/default-factory calls cannot donate nested publication in six scalar/list/void modes. Existing argument copies, shared references, return/error/fatal identities, actual factory maps and lazy loading remain unchanged. All233 original framework bindings are historical atb21b3bb9. Contracts construction/dependency integration .2.1 is next; pipeline/output/full-private/mapped/canonical obligations remain open.
  Signoff evidence: Actual native/current30 JSON ledgers agree, positive/fault TAP is complete345 or5 and every source fault is syntax-valid with its named semantic RED. Supplied consumer inputs retain all three JSON reader artifacts; Trace was already in the original136. The initial duplicate-Trace preflight assertion is retained separately and corrected before runtime capture. Four reason-sensitive evidence corruptions and one frozen original-hash corruption reject then restore actual PASS. Complete book source/config and rendered-marker controls are retained.
  Reverify: `bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.2.0-final-review.py`; separately run its `preservation-control.py` with the same wrapper. All capture/freezer/publisher programs are one-shot.
  Verification: `focused-signoff-complete`; ordinary doctrines govern staged admission.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.2.0 - bind native facade callback identity`

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
  Owned paths: `perl/LinkedSpec/ActionIR/Contracts.pm` only for native default selection and private required/optional/bare dependency bindings; bounded fixture/proof/claim, relevant Knowledge/book/continuity. Actual contract lower registration and delegated factories remain .2.1.1. No owner-dispatch, pipeline/output/mapping or family-order change.
  Verification tier: `focused`
  Focused checks: Actual native default references versus custom targets/same-name overrides, exact public map preservation; direct native scalar/list/void alias/effect/value/error ledgers and actual injected callback identity; each required/optional/bare binding, original input_slice opaque-publication control, weak lifetime and cold loading; complete supplied direct consumers, effective semantic source faults, actual input/instrument/channel identities and reviewer controls; complete book and ordinary doctrines.
  Canonical trigger: none for bounded private owner integration without public/generated/mechanical changes. Escalate before writes if proof exposes cross-cutting uncertainty. Complete private/mapped/canonical admission remains open.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.2.1.0.json`
  Acceptance: Preserve the current EmitContext claim before input writes. Select native default callbacks only for the built-in target and exact retained native references. Caller maps/default results/public lower fields stay actual and unchanged. Private lexical thunks must retain/invoke the actual callback and forward aliases/context/errors without autoloading SourceEmissions. Optional dropped and bare paths must not bypass isolation. No actual contract lower registration or pipeline activation. Commit before .2.1.1.
  Result: Contracts private dependency/default integration passes312 main/six cold assertions,15 exact native/current observation ledgers and16 effective semantic source faults;21 direct suites in140 supplied files, evidence4 and complete book57/two controls pass. Required/optional/bare calls retain actual callbacks in private native-context bindings; public maps/default results/lower fields stay unchanged. Built-in target plus retained definition identity selects native defaults. Actual input_slice, dropped fallback and both bare push paths deny opaque nested publication. All235 original EmitContext bindings are historical at2d8784780. One draft lifetime failure is reproduced on original/current sources and fixed only in the lexical-state fixture; all failed channels/probe inputs remain. Actual lower construction .2.1.1 is next; other owners/pipeline/output/full-private/mapped/canonical obligations remain open.
  Signoff evidence: Final main312/cold6 and all sixteen syntax-valid source faults retain coherent complete TAP and their named semantic REDs. Original/current15 JSON ledgers match. Complete supplied21/140 retains the original three JSON reader inputs. Four reason-sensitive reviewer corruptions and one original-binding corruption reject then restore actual PASS. Full57-source book retains two actual controls. Initial no-state lifetime failure/consumer run and exact native/current/lexical probe remain distinct from production REDs; production bytes are unchanged for the fixture correction.
  Reverify: `bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.2.1.0-final-review.py`; separately run its `preservation-control.py` with the same wrapper. One-shot captures/freezer/publisher/probe must not be replayed.
  Verification: `focused-signoff-complete`; ordinary doctrine hooks govern admission.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.2.1.0 - isolate contract dependencies`

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.2.1.1`
  Status: `done` / `focused-signoff-complete` (activated from clean `be7d70719856e76b7cb5a427ad6061a7109028ea`)
  Goal: Register actual locally constructed contract lower callbacks and the two delegated factory owners at their own construction seams.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.2.1.0`
  Owned paths: Contracts local builder returns and StagedParseJob/ProgressiveSpanDispatch own build_contracts returns; bounded proof/Knowledge/book/continuity. No default/dependency rework or shared owner-dispatch change.
  Verification tier: `focused`
  Focused checks: Actual complete native/current contract metadata/order/ordinary values/reference patterns, each actual local/delegated construction seam and returned array/hash/lower identity; changed/substituted factory opacity, current/nested source/producer scope selection/release and cold loading; complete supplied direct consumers, effective syntax-valid semantic source faults, retained producer/input/channel identities and reason-sensitive reviewer/book controls.
  Canonical trigger: none for bounded private factory construction; original complete private/independent/mapped/canonical owners remain open.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.2.1.1.json`
  Acceptance: Register actual native lower CODE references inside each owning factory, never blindly register callbacks returned by a substituted factory. Preserve actual public array/hash/lower references and family order. Commit before MethodLowering .3.
  Result: Actual local/delegated lower construction passes447 main/six cold assertions and20 effective semantic source faults. Two complete174-entry native/current catalogues match metadata/order, ordinary benign-input values and callback reuse patterns. All174 actual returned callbacks select in their current scope; twelve local return seams preserve actual array/hash/lower references and fourteen substituted factories remain opaque. Twenty-three suites in142 supplied files, evidence4 and complete book57/two controls pass. Nested source/producer selection restores, a lexical callback releases at scope exit, and cold construction stays lazy. All248 original dependency bindings are historical atbe7d70719. MethodLowering .3 is next; other dependency owners/pipeline/output/full-private/mapped/canonical obligations remain open.
  Signoff evidence: Complete positive447/cold6 and every syntax-valid fault retain coherent positive-sized TAP and named semantic REDs. Two actual live native/current catalogue ledgers preserve all174 entries and reference reuse; actual local return snapshots and fourteen substituted-factory publication controls distinguish reference/callback authority. Exact supplied23/142 includes all three JSON reader artifacts. Four reviewer corruptions and one original-binding corruption reject then restore actual PASS. Complete57-source book retains missing-SUMMARY and removed rendered-marker controls.
  Reverify: `bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.2.1.1-final-review.py`; separately run its `preservation-control.py` with the same wrapper. All capture/freezer/publisher programs are one-shot.
  Verification: `focused-signoff-complete`; ordinary doctrine hooks govern admission.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.2.1.1 - register own lower callbacks`

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
  Owned paths: `perl/LinkedSpec/ActionIR/MethodLowering.pm` default factory only; `perl/LinkedSpec/RuleIR/EmitContext.pm` separate native method reference catalogue/selector only; focused fixtures/proof/claim, Knowledge/book/continuity. No injected call, OwnerDispatch, source/input/pipeline/output/mapping change.
  Verification tier: `focused`
  Focused checks: Complete actual native/current public callback map ledgers, actual map/ref identity and individual definition-owned selection, every same-name replacement and custom target opacity, source/producer scope separation/restoration and cold lazy loading; complete supplied direct suites, effective per-entry source faults and actual reviewer controls, exact retained producers/inputs/channels and original claim preservation; complete relevant book and ordinary doctrines.
  Canonical trigger: none for bounded private reference selection without public/generated/mechanical change. Complete private Phase0 and independent canonical/parent admission remain separately owned.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.0.json`
  Acceptance: Preserve the previous244 live claim bindings before changing inputs. Return the exact actual map/callback references; only the built-in target and actual definition-owned callback can register. Names, copies and custom native aliases confer no authority. Commit before required bindings.
  Result: MethodLowering default native selection passes426 main/six cold assertions and24 effective syntax-valid source faults. Two complete19-callback native/current maps preserve keys, actual references and reuse. Actual OwnerDispatch map/ref snapshots, all nineteen same-name/retained-native controls, custom native aliases, opaque equal-text publication attempts and bounded source/producer restoration pass. Twenty-five suites in144 supplied files, evidence4, original-binding RED and complete book57/two controls pass. All244 original construction bindings remain historical at33e57deee. Initial30 all-GREEN captures/producer are retained before correcting inherited scope prose and recapturing with unchanged production/fixtures. Required .3.1 and optional/direct .3.2 dependency boundaries are next; no native-helper packet, full-private/mapped/canonical or parent admission is inferred.
  Signoff evidence: Complete426-main/six-cold positive and fault TAP, actual current/original callback map ledgers, every individual native entry omission and target/ref/map/cold control, exact supplied25/144 with all three JSON reader artifacts, four reason-sensitive evidence corruptions and one original-binding corruption with restored PASS. Initial scope-prose defect is owned and repaired here, retaining every original producer/channel and independently proving prose-only correction and unchanged runtime inputs. Complete57-source book retains missing-SUMMARY command and removed-marker rendered REDs.
  Reverify: `bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.0-final-review.py`; separately run its `preservation-control.py` with the same wrapper. Capture/freezer/publisher are one-shot. Original constructor review requires its accepted33e57deee boundary.
  Verification: `focused-signoff-complete`; ordinary doctrine hooks govern staged admission.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.0 - select native method defaults`

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
  Owned paths: `perl/LinkedSpec/ActionIR/MethodLowering.pm` private _bind_emission_dependency and only _infer_direct_shape_literal_kind/_normalize_method_tag_expr/_lower_inline_switch_case_value_expr required return seams; focused fixtures/proof/claim, Knowledge/book/continuity. No other required/optional/direct call, native default, pipeline/input/output/mapping change.
  Verification tier: `focused`
  Focused checks: Paired original/current actual-call publication fixture, direct native/current scalar/list/void values/aliases/effects/errors/fatal identities, actual three caller outcomes and copied top-level arguments, map references, required missing-dependency diagnostics, scoped opaque/known child separation and lexical lifetime/cold loading; supplied direct suites, effective per-seam and primitive faults, retained original producers/inputs/channels and reviewer/book controls.
  Canonical trigger: none for bounded private implementation without public/generated/mechanical change. Complete private Phase0 and independent canonical/parent admission remain original owners.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.0.json`
  Acceptance: Preserve all282 current claim live inputs before writes. Retain actual dependencies in private lexical thunks forwarding original aliases/context, return ordinary values and preserve caller maps. The three actual injected trim calls cannot donate nested publication. Commit before other required function families.
  Result: Private trim bindings pass255 main/five cold assertions and13 effective syntax-valid source faults. The same full fixture has exactly eleven original publication-isolation REDs and all255 current GREEN, with244 original controls passing. Fifteen native dependency and nine actual caller ledgers match context, aliases, copied top-level inputs, public references and value/effect/error/fatal behavior. Twenty-seven suites in146 supplied files, evidence4, original-binding RED and complete book57/two controls pass. All282 original method-default bindings remain historical at89a4ede6f. The partial attempt retains18 actual captures/producer; only two inherited assertion matcher labels change before recapture, with unchanged production/fixtures. Other required .3.1 children, optional/direct .3.2, other owners/pipeline/output/full-private/mapped/canonical and parent obligations remain open.
  Signoff evidence: Complete unchanged255-assertion original/current fixture with exact11 semantic-failure names; all244 original controls and all255 current assertions pass. Actual native15/caller9 JSON ledgers and coherent255/five positive/fault TAP, exact supplied27/146 with three reader JSONs, four reason-sensitive evidence REDs and one original-binding RED/restored PASS. Actual partial retention fault is syntax-valid RED255; original matcher expected an obsolete label. Retain every partial producer/input/channel, align two labels only, independently reconstruct correction and verify unchanged production/fixtures. Complete57-source book retains missing-SUMMARY command and removed-marker render controls.
  Reverify: `bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.0-final-review.py`; separately run its `preservation-control.py`. Capture/freezer/publisher are one-shot writers. Original default-selection reviewers require accepted89a4ede6f inputs.
  Verification: `focused-signoff-complete`; ordinary doctrine hooks govern staged admission.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.0 - isolate required trim dependencies`

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.1`
  Status: `done` / `focused-signoff-complete` (activated from clean `429d0c6d959e883304bc06d8c569c76e7bdcedfc`)
  Goal: Assignment/declaration inference required dependency boundaries; split further before writes if needed.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.0`
  Owned paths: MethodLowering required seams in _infer_assignment_source_container_kind, _lower_value_binding_source_expr, _lower_typed_declare_statement; focused fixtures/proof/claim, Knowledge/book/continuity. Optional/direct calls remain .3.2.
  Verification tier: `focused`
  Focused checks: Every eight required callback roles across three actual callers; native/current full value/context/effect/error/reference ledgers, paired original/current semantic publication fixture, unchanged caller maps and required diagnostics, actual native identity versus private wrapper, cold loading and supplied direct consumers; effective per-seam faults, retained producers/all inputs/channels, reason-sensitive reviewer/original-binding controls and complete relevant book.
  Canonical trigger: none for bounded private implementation without public/generated/mechanical changes; original full-private/mapped/canonical owners retain admission.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.1.json`
  Acceptance: Preserve original262 live bindings before input writes. Bind only the three required resolution seams, keeping actual public maps/callbacks and native behavior. Explicit controlled secondary helpers isolate these three actual caller mechanisms; no optional/direct call or authored-language change. Commit before inline/block .3.1.2; no independent parent admission inferred.
  Result: Three MethodLowering assignment/declaration required resolvers pass 277 main/four cold assertions and nine effective syntax-valid source faults. All eight callback roles and 25 native/current ledgers match; the same complete fixture has exactly 24 original publication-isolation REDs, 253 original passing controls and 277 current GREEN. Twenty-nine suites in 148 supplied files, evidence5, original-binding RED/restoration and complete book57/two controls pass. All262 original trim bindings stay historical at429d0c6d. An early review started before consumers.json existed; the fifth actual evidence control reproduces that missing-result rejection and restores PASS, with unchanged production/fixtures/capture programs. Inline/block .3.1.2 is next; remaining required/optional, other owners/pipeline/output/full-private/mapped/canonical and parent obligations remain open.
  Signoff evidence: docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.1-* retain all actual producers, native/current25 ledgers, paired complete277 TAP, exact24 original failures, nine complete semantic source faults,29/148 consumers, five actual reviewer RED/restored controls, original262 preservation and book57/two controls. Production is independently constrained to exactly three required return edits. Missing consumer-result orchestration diagnosis is retained in evidence.json; no runtime input changes for that correction.
  Reverify: `bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.1-final-review.py`; separately run its preservation-control.py with the same wrapper. One-shot writers are not resume entrypoints.
  Verification: `focused-signoff-complete`; ordinary doctrine hooks govern staged admission.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.1 - isolate required inference dependencies`


- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2`
  Status: `pending`
  Goal: Inline/block controls required dependency boundaries; split further before writes if needed.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.1`
  Owned paths: MethodLowering required seams in _lower_inline_if_value_expr, _lower_inline_switch_value_expr, _lower_block_value_component_expr, _lower_block_side_effect_statement, _lower_block_local_return_payload_expr, _lower_block_value_expr; focused fixtures/proof/claim, Knowledge/book/continuity. Optional/direct calls remain .3.2.
  Planned tier: `focused`
  Planned focused proof: Actual native/current caller behavior, opaque dependency separation, contexts/aliases/effects/errors/public maps, retained source-bound faults/consumers and complete relevant book.
  Planned canonical boundary: none for bounded private implementation; original full-private/mapped/canonical owners retain admission.
  Planned claim record: none: Planning only; declare source-bound measurement at activation.
  Acceptance: Preserve actual public references and native behavior. Commit each bounded family before advancing; no independent parent admission inferred.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3`
  Status: `pending`
  Goal: Guarded AST calls required dependency boundaries; split further before writes if needed.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2`
  Owned paths: MethodLowering required seams in _lower_ast_scalar_held_hash_index_assignment_value_node, _lower_ast_call_statement, _lower_ast_array_end_mutation_method_statement, _lower_ast_assignment_operator_statement; focused fixtures/proof/claim, Knowledge/book/continuity. Optional/direct calls remain .3.2.
  Planned tier: `focused`
  Planned focused proof: Actual native/current caller behavior, opaque dependency separation, contexts/aliases/effects/errors/public maps, retained source-bound faults/consumers and complete relevant book.
  Planned canonical boundary: none for bounded private implementation; original full-private/mapped/canonical owners retain admission.
  Planned claim record: none: Planning only; declare source-bound measurement at activation.
  Acceptance: Preserve actual public references and native behavior. Commit each bounded family before advancing; no independent parent admission inferred.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.4`
  Status: `pending`
  Goal: Main method/value lowering required dependency boundaries; split further before writes if needed.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3`
  Owned paths: MethodLowering required seams in _lower_method_value_expr; focused fixtures/proof/claim, Knowledge/book/continuity. Optional/direct calls remain .3.2.
  Planned tier: `focused`
  Planned focused proof: Actual native/current caller behavior, opaque dependency separation, contexts/aliases/effects/errors/public maps, retained source-bound faults/consumers and complete relevant book.
  Planned canonical boundary: none for bounded private implementation; original full-private/mapped/canonical owners retain admission.
  Planned claim record: none: Planning only; declare source-bound measurement at activation.
  Acceptance: Preserve actual public references and native behavior. Commit each bounded family before advancing; no independent parent admission inferred.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5`
  Status: `pending`
  Goal: Scalar/return/mutation helpers required dependency boundaries; split further before writes if needed.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.4`
  Owned paths: MethodLowering required seams in _lower_source_slot_bare_scalar_read_expr, _lower_mutation_slot_value_expr, _lower_return_payload_expr, _lower_return_general_statement, _lower_assign_statement, _lower_scalar_assignment_operator_statement, _lower_array_append_operator_statement, _lower_set_key_statement, _lower_push_statement, _lower_regex_subst_statement, _lower_return_undef_statement; focused fixtures/proof/claim, Knowledge/book/continuity. Optional/direct calls remain .3.2.
  Planned tier: `focused`
  Planned focused proof: Actual native/current caller behavior, opaque dependency separation, contexts/aliases/effects/errors/public maps, retained source-bound faults/consumers and complete relevant book.
  Planned canonical boundary: none for bounded private implementation; original full-private/mapped/canonical owners retain admission.
  Planned claim record: none: Planning only; declare source-bound measurement at activation.
  Acceptance: Preserve actual public references and native behavior. Commit each bounded family before advancing; no independent parent admission inferred.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6`
  Status: `pending`
  Goal: Receiver/parser helpers required dependency boundaries; split further before writes if needed.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.5`
  Owned paths: MethodLowering required seams in _normalize_array_receiver_value_chain_expr, _normalize_number_receiver_value_chain_expr, _normalize_string_receiver_value_chain_expr, _normalize_hash_receiver_value_chain_expr, _parse_array_end_mutation_method_statement, _parse_hash_index_assignment_operator_statement, _lower_hash_index_assignment_operator_statement; focused fixtures/proof/claim, Knowledge/book/continuity. Optional/direct calls remain .3.2.
  Planned tier: `focused`
  Planned focused proof: Actual native/current caller behavior, opaque dependency separation, contexts/aliases/effects/errors/public maps, retained source-bound faults/consumers and complete relevant book.
  Planned canonical boundary: none for bounded private implementation; original full-private/mapped/canonical owners retain admission.
  Planned claim record: none: Planning only; declare source-bound measurement at activation.
  Acceptance: Preserve actual public references and native behavior. Commit each bounded family before advancing; no independent parent admission inferred.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.2`
  Status: `pending`
  Goal: Isolate MethodLowering optional and direct injected callback calls; split function families before writes as needed.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.6`
  Owned paths: `perl/LinkedSpec/ActionIR/MethodLowering.pm` optional/direct callback calls; focused proof/claim, Knowledge/book/continuity.
  Planned tier: `focused`
  Planned focused proof: Actual opaque dependency boundaries, native contexts/aliases/effects/errors/public maps and retained source-bound controls/consumers.
  Planned canonical boundary: none for bounded private implementation; complete private Phase0 and canonical admission stay with original owners.
  Planned claim record: none: Planning only; declare measurement at activation.
  Acceptance: Preserve native behavior and actual public references; commit before FlowExpr. No separate parent admission inferred.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.4`
  Status: `pending`
  Goal: Actual default callbacks and flow-composite injected dependency boundaries, preserving native effects and arguments.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.2`
  Owned paths: `perl/LinkedSpec/ActionIR/FlowExpr.pm`; focused fixture/proof/claim, relevant Knowledge/book and continuity. No unrelated producer or mapping changes.
  Planned tier: `focused`
  Planned focused proof: Actual/native callback and invocation identities; scalar/list/void context where applicable, aliases, once-only effects, exact return/error/fatal values, opaque nested delegation, scope restoration/release and unchanged public maps. Complete supplied direct consumers, effective semantic faults, retained instrument/input/channel identities, relevant book and ordinary doctrines.
  Planned canonical boundary: none for bounded private implementation without public/generated/mechanical change; reclassify before writes if scope crosses those boundaries. Complete private Phase0 and canonical replacement remain separately owned.
  Planned claim record: none: Planning only; declare the actual source-bound measurement record at activation before publishing results.
  Acceptance: Follow the retained owner plan; choose no authority by name, copied metadata or equal value. Preserve existing selected input grants and callback references. Split further before writes if actual code paths exceed a safe slice. Commit before activating the next owner.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.5`
  Status: `pending`
  Goal: Actual default callbacks and control-flow injected dependency boundaries, including nested success/fatal restoration. Split by branch families before writes if necessary.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.4`
  Owned paths: `perl/LinkedSpec/ActionIR/ControlFlow.pm`; focused fixture/proof/claim, relevant Knowledge/book and continuity. No unrelated producer or mapping changes.
  Planned tier: `focused`
  Planned focused proof: Actual/native callback and invocation identities; scalar/list/void context where applicable, aliases, once-only effects, exact return/error/fatal values, opaque nested delegation, scope restoration/release and unchanged public maps. Complete supplied direct consumers, effective semantic faults, retained instrument/input/channel identities, relevant book and ordinary doctrines.
  Planned canonical boundary: none for bounded private implementation without public/generated/mechanical change; reclassify before writes if scope crosses those boundaries. Complete private Phase0 and canonical replacement remain separately owned.
  Planned claim record: none: Planning only; declare the actual source-bound measurement record at activation before publishing results.
  Acceptance: Follow the retained owner plan; choose no authority by name, copied metadata or equal value. Preserve existing selected input grants and callback references. Split further before writes if actual code paths exceed a safe slice. Commit before activating the next owner.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.6`
  Status: `pending`
  Goal: Invocation-local scope activation before contract factories, separate factory dependencies and actual canonical apply captures; preserve current replacement algorithm and all public shapes/order.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.5`
  Owned paths: `perl/LinkedSpec/ActionIR/RewritePipeline.pm`; focused fixture/proof/claim, relevant Knowledge/book and continuity. No unrelated producer or mapping changes.
  Planned tier: `focused`
  Planned focused proof: Actual/native callback and invocation identities; scalar/list/void context where applicable, aliases, once-only effects, exact return/error/fatal values, opaque nested delegation, scope restoration/release and unchanged public maps. Complete supplied direct consumers, effective semantic faults, retained instrument/input/channel identities, relevant book and ordinary doctrines.
  Planned canonical boundary: none for bounded private implementation without public/generated/mechanical change; reclassify before writes if scope crosses those boundaries. Complete private Phase0 and canonical replacement remain separately owned.
  Planned claim record: none: Planning only; declare the actual source-bound measurement record at activation before publishing results.
  Acceptance: Follow the retained owner plan; choose no authority by name, copied metadata or equal value. Preserve existing selected input grants and callback references. Split further before writes if actual code paths exceed a safe slice. Commit before activating the next owner.

## Current Frontier

| Order | Leaf | Status | Why next |
| --- | --- | --- | --- |
| 1 | `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2` | `pending` | Inspect/refine six inline/block required resolution seams; preserve current claim before writes. |
| 2 | `PERL-PRIVATE-FACTORY-CAPTURE.3.2` | `pending` | Optional/direct callbacks follow required bindings. |
| 3 | `PERL-PRIVATE-FACTORY-CAPTURE.4` | `pending` | Depends on the preceding bounded owner. |
| 4 | `PERL-PRIVATE-FACTORY-CAPTURE.5` | `pending` | Depends on the preceding bounded owner. |
| 5 | `PERL-PRIVATE-FACTORY-CAPTURE.6` | `pending` | Depends on the preceding bounded owner. |

## Handoff

After `.6`, independently accept the composed factory/input identity seams under
`SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.4`. The original
`SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.5` owns complete guarded private
Phase0/consumer acceptance; mapped replacement and independent canonical admission remain separate.

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

## Verification Log

Planning/routing verification belongs to `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.3.0`.

- `2026-10-10`, `.1`: PASS224/11, native30, supplied17/136, evidence4/book57/2 and original232 preservation. The four initial draft identity failures are retained and diagnosed, with no production change hidden by their fixture correction. SourceEmissions syntax is checked in every source-fault run; direct supplied consumers recur. All normal doctrine hooks are required before landing.
- `2026-10-10`, `.1`: Initial commit hooks rejected the missing formal acceptance checklist in this new tree. The completed checklist above now cites the existing actual proof and its limits; no runtime instrument, artifact or source changes for this workflow correction.

- `2026-10-10`, `.2.0`: EmitContext passes345 main/five cold assertions,30 exact native/current observation ledgers and13 effective semantic source faults. Nineteen direct suites in138 supplied files, four actual reviewer REDs and complete57-source book/two controls pass. Actual definition-owned references select28 native callbacks; same-name replacements and copied metadata remain opaque. Resolved owner/default-factory calls cannot donate nested publication in six scalar/list/void modes. Existing argument copies, shared references, return/error/fatal identities, actual factory maps and lazy loading remain unchanged. All233 original framework bindings are historical atb21b3bb9. Contracts construction/dependency integration .2.1 is next; pipeline/output/full-private/mapped/canonical obligations remain open.

- `2026-10-10`, `.2.1.0`: Contracts private dependency/default integration passes312 main/six cold assertions,15 exact native/current observation ledgers and16 effective semantic source faults;21 direct suites in140 supplied files, evidence4 and complete book57/two controls pass. Required/optional/bare calls retain actual callbacks in private native-context bindings; public maps/default results/lower fields stay unchanged. Built-in target plus retained definition identity selects native defaults. Actual input_slice, dropped fallback and both bare push paths deny opaque nested publication. All235 original EmitContext bindings are historical at2d8784780. One draft lifetime failure is reproduced on original/current sources and fixed only in the lexical-state fixture; all failed channels/probe inputs remain. Actual lower construction .2.1.1 is next; other owners/pipeline/output/full-private/mapped/canonical obligations remain open.

- `2026-10-10`, `.2.1.1`: Actual local/delegated lower construction passes447 main/six cold assertions and20 effective semantic source faults. Two complete174-entry native/current catalogues match metadata/order, ordinary benign-input values and callback reuse patterns. All174 actual returned callbacks select in their current scope; twelve local return seams preserve actual array/hash/lower references and fourteen substituted factories remain opaque. Twenty-three suites in142 supplied files, evidence4 and complete book57/two controls pass. Nested source/producer selection restores, a lexical callback releases at scope exit, and cold construction stays lazy. All248 original dependency bindings are historical atbe7d70719. MethodLowering .3 is next; other dependency owners/pipeline/output/full-private/mapped/canonical obligations remain open.

- `2026-10-10`, `.3.0`: PASS426/cold6, exact native/current2x19 maps,24 effective semantic source faults and supplied25/144. Evidence4, original244 preservation with actual RED/restored PASS and complete book57/two controls pass. Initial30 all-GREEN captures retain their original producer; prose-only inverse-scope correction is reconstructed before accepting unchanged-source recapture. All normal doctrine hooks govern admission.

- `2026-10-10`, `.3.1.0`: Private trim bindings pass255 main/five cold assertions and13 effective syntax-valid source faults. The same full fixture has exactly eleven original publication-isolation REDs and all255 current GREEN, with244 original controls passing. Fifteen native dependency and nine actual caller ledgers match context, aliases, copied top-level inputs, public references and value/effect/error/fatal behavior. Twenty-seven suites in146 supplied files, evidence4, original-binding RED and complete book57/two controls pass. All282 original method-default bindings remain historical at89a4ede6f. The partial attempt retains18 actual captures/producer; only two inherited assertion matcher labels change before recapture, with unchanged production/fixtures. Other required .3.1 children, optional/direct .3.2, other owners/pipeline/output/full-private/mapped/canonical and parent obligations remain open. Ordinary doctrine hooks govern admission.

- `2026-10-10`, `.3.1.1`: Three MethodLowering assignment/declaration required resolvers pass 277 main/four cold assertions and nine effective syntax-valid source faults. All eight callback roles and 25 native/current ledgers match; the same complete fixture has exactly 24 original publication-isolation REDs, 253 original passing controls and 277 current GREEN. Twenty-nine suites in 148 supplied files, evidence5, original-binding RED/restoration and complete book57/two controls pass. All262 original trim bindings stay historical at429d0c6d. An early review started before consumers.json existed; the fifth actual evidence control reproduces that missing-result rejection and restores PASS, with unchanged production/fixtures/capture programs. Inline/block .3.1.2 is next; remaining required/optional, other owners/pipeline/output/full-private/mapped/canonical and parent obligations remain open. Ordinary doctrine hooks govern staged admission.

## Commit Log

The planning commit belongs to the original tree. Every implementation leaf records its own result and commit
beside its stable ID; Git is the commit-identity authority.

- `.1`: `PERL-PRIVATE-FACTORY-CAPTURE.1 - isolate native dependency calls`, from clean02345ee21; no push.
- `.2.0`: `PERL-PRIVATE-FACTORY-CAPTURE.2.0 - bind native facade callback identity`, from cleanb21b3bb9; no push.
- `.2.1.0`: `PERL-PRIVATE-FACTORY-CAPTURE.2.1.0 - isolate contract dependencies`, from clean2d8784780; no push.
- `.2.1.1`: `PERL-PRIVATE-FACTORY-CAPTURE.2.1.1 - register own lower callbacks`, from cleanbe7d70719; no push.

- `.3.0`: `PERL-PRIVATE-FACTORY-CAPTURE.3.0 - select native method defaults`, from clean33e57deee; no push.

- `.3.1.0`: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.0 - isolate required trim dependencies`, from clean89a4ede6f; no push.

- `.3.1.1`: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.1 - isolate required inference dependencies`, from clean429d0c6d; no push.

## Changelog

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
