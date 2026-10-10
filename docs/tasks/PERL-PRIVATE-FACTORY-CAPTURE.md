# PERL-PRIVATE-FACTORY-CAPTURE: Actual factory and dependency emission capture

## Metadata

- Tree ID: `PERL-PRIVATE-FACTORY-CAPTURE`
- Status: `active` / finite change-history prerequisite verified; array-end next
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
  Status: `done` / bounded inline and block child implementation complete; independent private admission remains open
  Goal: Inline/block required dependency boundaries with bounded native/current actual-call proof.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.1`
  Children: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.0`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.1`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2`.
  Owned paths: MethodLowering required seams in the six original inline/block owners; focused fixtures/proof/claim, Knowledge/book/continuity. Finite canonical history-capacity prerequisite .3.1.2.3 is separately bounded; optional/direct calls remain .3.2.
  Split rationale: Separate inline if/switch, block component/side-effect and block local-return/value control paths. Each family declares invoked versus validation-only callbacks and explicit secondary controls before writes; shared/native context primitive remains unchanged.
  Planned tier: `focused`
  Planned focused proof: Actual native/current caller behavior, opaque/known dependency separation, contexts/aliases/effects/errors/public maps, exact required diagnostics, retained semantic source faults/consumers and complete relevant book.
  Planned canonical boundary: none for bounded private implementation; original full-private/mapped/canonical owners retain admission.
  Planned claim record: none: Children declare source-bound measurements at activation; no independent parent admission inferred.
  Acceptance: Commit each bounded child before advancing. The following guarded AST owner depends on the last exact child.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.0`
  Status: `done` / `focused-signoff-complete` (activated from clean `9032b20e921540833ee0b5204594835b10e7b55b`)
  Goal: Inline if/switch required dependency boundaries with all five actual callback roles.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.1`
  Owned paths: MethodLowering required return seams only in _lower_inline_if_value_expr and _lower_inline_switch_value_expr; focused fixtures/proof/claim, Knowledge/book/continuity. No branch/truthiness helper, optional/direct call or pipeline changes.
  Verification tier: `focused`
  Focused checks: Five actual callback roles across two owners, native/current full ledgers and copied/shared argument behavior, required diagnostics, paired publication RED/GREEN, actual callback identity, cold lazy loading and supplied direct consumers; independent per-seam boundary/identity/diagnostic faults, retained producers/all inputs/channels, reviewer/original-binding controls and complete book.
  Canonical trigger: none for bounded private implementation without public/generated/mechanical changes; original full-private/mapped/canonical owners retain admission.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.0.json`
  Acceptance: Preserve all240 original live input bindings before source/fixture/book writes. Bind only two required returns; retain original public maps/references and native values/contexts/alias/effect/error behavior. Explicit constant branch payload/case/truthiness helper controls isolate the two actual caller bodies; no full successful conditional-language admission. Commit before .3.1.2.1.

  Result: Two inline if/switch required resolvers pass177 main/cold4 and six effective syntax-valid source faults. All five actual roles and15 native/current ledgers match; paired complete177 TAP has15 original publication-isolation REDs,162 passing original controls and all177 current GREEN. Supplied31 suites/150 files, evidence5, original-binding RED/restoration and book57/two controls pass. All240 original inference bindings stay historical at9032b20e. The initial copied freezer rejects at its wrong-prefix replay guard before writes; retain actual rejection/original-input snapshot and reconstruct only prefix/docstring/console correction. Block component/side-effect .3.1.2.1 is next; remaining required/optional, pipeline/output/full-private/mapped/canonical and parent owners remain open.
  Signoff evidence: docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.0-* bind exact native/current15 ledgers, paired177 plans/exact15 original failures, six complete syntax-valid semantic faults, supplied31/150, evidence5, original240 preservation and book57/two controls. Production independently reconstructs only two required return edits. Wrong-prefix freezer producer/actual repeat rejection/original snapshot and exact three-string correction remain retained.
  Reverify: `bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.0-final-review.py`; separately run its preservation-control.py with the same wrapper. One-shot writers are not resume entrypoints.
  Verification: `focused-signoff-complete`; ordinary doctrine hooks govern staged admission.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.0 - isolate inline control dependencies`

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.1`
  Status: `done` / `focused-signoff-complete` (activated from clean `65bd00faa0b10abc106a6da2283391c268ee88fa`)
  Goal: Block component and side-effect required dependency boundaries with actual native fallback/reference behavior.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.0`
  Owned paths: MethodLowering required return seams only in _lower_block_value_component_expr and _lower_block_side_effect_statement; focused fixtures/proof/claim, Knowledge/book/continuity. No AST/secondary helper, optional/direct or pipeline changes.
  Verification tier: `focused`
  Focused checks: Six invoked callback roles and separate validation-only lower_flow_composite_expr requirement; complete native/current string/undefined/fatal/reference ledgers, actual native fallback values and shared normalizer arrays, copied inputs/public references/contexts/effects/errors, exact required diagnostics and paired publication RED/GREEN. Explicit constant/undef secondary and AST controls isolate the actual two bodies. Per-seam boundary/identity/diagnostic faults include the validation-only missing-flow requirement; cold loading, supplied direct consumers, retained producers/all inputs/channels, actual reviewer/original-binding controls and complete book.
  Canonical trigger: none for bounded private implementation without public/generated/mechanical changes; original full-private/mapped/canonical owners retain admission.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.1.json`
  Acceptance: Preserve all242 original inline claim live inputs before source/fixture/book writes. Bind only the two required returns, preserving undefined-result fallbacks and actual references/aliases/native behavior. Do not claim an invocation for the validation-only flow callback. Commit before the separately owned finite history-capacity prerequisite .3.1.2.3; retain a concise complete note under existing limits.

  Result: Block component/side-effect required bindings pass223 main/cold4 and six effective syntax-valid source faults. Six invoked roles, a separately validated local flow binding and20 native/current ledgers preserve fallback/reference/context/alias/effect/error behavior. Paired complete223 TAP has18 original publication-isolation REDs,205 original passing controls and all223 current GREEN. Supplied33 suites/152 files, evidence5, original-binding RED/restoration and book57/two controls pass. All242 original inline bindings remain historical at65bd00faa. Finite history-capacity .3.1.2.3 precedes local-return/value .3.1.2.2; remaining required/optional, other owners/pipeline/output/full-private/mapped/canonical and parent obligations stay open.
  Signoff evidence: docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.1-* bind exact native/current20 ledgers, paired223 complete plans/exact18 original failures, six complete syntax-valid semantic faults, supplied33/152, evidence5, original242 preservation and book57/two controls. Production independently reconstructs only two required return edits; separate flow diagnostic fault distinguishes local validation without claiming direct invocation or a complete transitive graph.
  Reverify: `bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.1-final-review.py`; separately run its preservation-control.py with the same wrapper. One-shot writers are not resume entrypoints.
  Verification: `focused-signoff-complete`; ordinary doctrine hooks govern staged admission.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.1 - isolate block component dependencies`

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3`
  Status: `done` / `canonical accepted at268891fdf` (activated from clean `cdc45f9cbddbc53603e885225af2a35688657292`)
  Goal: Admit one exact engineering-notes archive member and its exact manifest capacity through a separately indexed accepted decision; preserve all prior history and current runtime proof inputs.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.1`
  Owned paths: Exact registry/ADR/index, engineering-notes complete-record rollover, retained capacity producer/claim, Knowledge and continuity. Stable storage responsibility remains LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3; no runtime/threshold-checker or external-repository changes. Blocking ownership includes t/actionir_method_inference_capture.t six-literal retained-constructor migration and tests/language-readiness/verify_objectives.py exact committed Contracts inverse, its source controls/retained proof, relevant book/Knowledge and committed runtime-claim preservation before book edits.
  Reproduction: The .3.1.2.1 ordinary commit hook rejects the proposed new segment under existing engineering_notes file-count and manifest limits. ADR0130 expressly grants no new member. Reproduce from this clean boundary with the production rollover/checkers and exact source/hash reconstruction.
  Impact / priority: P1 prerequisite for sustained PNT chronology; ordinary runtime slices cannot expand routing controls or rewrite immutable history. The current slice shortens only its newly authored note and withdraws only its uncommitted redundant rollover.
  Verification tier: `canonical`
  Focused checks: Independent clean-Git preservation; exact old/new canonical limit and contract objects; actual production boundary/accepted-indexed-authority REDs, retained all inputs/producers/channels and reviewer corruption controls; unchanged public documentation authority contract. Actual original504-input supplied replay, unchanged public selector classifier70/36 RED/GREEN, complete current book57+32 with three controls, retained failed draft render/producer and three actual new evidence REDs/restoration.
  Canonical trigger: Routing-capacity infrastructure requires exact complete staged-candidate CI/receipt before landing.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3.json`
  Acceptance: Use finite engineering-maintenance authority under current PNT and ADR0128/0129/0130 precedent. Preserve every old immutable byte and manifest record; admit only one measured new member and exact manifest growth. Account for the sole ADR in decision-store limits where required. Commit canonical proof before local-return/value .3.1.2.2.

  Result: ADR0131 admits exactly engineering_notes files45→46 and manifest44→45 lines/26633→27245 bytes; decisions131→132 files and13109→13144 aggregate lines account only for this sole new record/index row. Every other registry field and all220 prior immutable history/decision files stay exact. Production rollover creates segment4962 from the complete clean-cdc45f9cb suffix; independent root/blob/range/digest/manifest reconstruction passes. Actual30 thresholds/23 authority REDs and three reviewer corruption REDs/restored PASS are retained. Original runtime source/fixture proof remains exact atCDC; its241 original runtime/book bindings are historical at cdc45f9cb before book teaching edits. Blocking historical-auditor repair accepts only the two exact committed Contracts source blobs; full134/84613241 recovery,22 recovery/64 evolution denials, guard0, book57/2 and four evidence REDs/restoration pass. Exact staged canonical CI/receipt governs landing; local-return/value .3.1.2.2 follows the canonical commit.
  Signoff evidence: docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3-* retain exact producer, plan, rollover/control/reviewer channels and counterfactual bytes. Original capacity claim binds245 live and nine original historical inputs; the separately scoped historical repair adds259 live/two original historical inputs without refreshing those hashes. The exact rejected first publication and actual missing-producer schema RED are retained. A guarded metadata-only repair labels the unchanged original checker/roller as producers without refreshing any original hash or measured proof. No root/aggregate/per-file or future archive reserve is granted; stable storage owner remains LIVE-DOCUMENT-PRESSURE-CONTAINMENT.3.
  Reverify: `bash tools/run_python_project_data.sh docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3-selector-review.py` plus its `capacity.py final` under the same wrapper at the frozen boundary; this replays the exact original504-input historical proof in supplied isolation. Preserve current original/publication inputs before later writes. Apply/capture/freezer/book/packer/evidence/publisher are one-shot writers.
  Public explanation/input-closure signoff: Actual third canonical failure is repaired without changing the selector checker or expected36 count. Retained exact original uncommitted four-claim publication plus all504 original live identities replay the unchanged historical reviewer/validator in isolation. Current book includes57 configuration/source and32 recursive include files; missing-SUMMARY, removed-marker and omitted-include ERROR controls pass. Exact607752-byte raw capture is losslessly packed259324 bytes within the chosen524288-byte capture budget. Three actual reviewer REDs restore. The final corrected four-claim record keeps shared245 directly gated plus154 additional current inputs; every original additional259 remains individually hash-gated through its retained publication and actual supplied validator. Six literal constructor migrations preserve paired277 complete assertion names and supplied33/152; actual two-input source scanner goes from six positive lines to zero. Intermediate368-input publication/reader/evidence and three pre-migration draft captures remain exact. Original committed runtime/history measurements stay exact. Earlier57-file renders are explicitly narrower observations; broader retrospective producer/input admission remains startup .5.
  Verification: Focused source-bound proof complete; exact staged canonical receipt and normal doctrines are mandatory before commit.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3 - admit history capacity and reconcile factory audit`

  Blocking defect ownership (focused fix verified; canonical receipt gates landing): P1 historical recovery audit rejects committed Contracts dependencies be7d7071 and construction33e57dee because its boundary inverse expects exact b2156813 bytes. Canonical CI reaches all10 doctrine PASS before this actual rejection. Current Contracts is exactly the accepted33e57dee whole Git blob, with no later drift; baseline2d878478 equals b2156813. Own an exact committed-source inverse here, preserving all historical source/log/checkpoint hashes and rejecting every other byte change. This is historical integrity replay, not fresh historical runtime execution or new factory admission.
  Additional blocking defect ownership (P1; focused fix verified in current .3 slice): Third canonical attempt passes doctrines, historical recovery and cross-backend admission but rejects the inference chapter's internal `copy(array(x))` fixture spelling at line1126: no explicit removed/rejected/migrated context. Own the public explanation repair here. Reproduce through tools/check_public_aggregate_selector_surface.py; preserve the original uncommitted four-claim candidate and all504 live bindings before edits, retain original proof source/channels, remove the obsolete spelling from the product explanation, and run actual unchanged classifier RED/GREEN plus complete book proof and canonical admission. No checker threshold, runtime or archived measurement changes are authorized by this repair.


  Additional proof-supplier defect ownership (P1; focused fix verified in current .3 slice): Actual retained book command exits0 while logging missing {{#include}} files because copied supplier materializes only57 book/config files. Own current transitive include closure and an actual omitted-include rejection control here; retain original producer/partial channel before correcting its copied chapter lookup. Original five-line/six-literal authoring guard rejection and unchanged-fixture draft producer/three captures remain retained; final supplier requires actual six-literal migration before measurement. Earlier captures remain bounded observations, not complete external-include proof. SESSION-STARTUP-READING.5 retains the broader historical producer/input audit; this finite correction does not relabel its older measurements.

  Composed source-scan blocker ownership (P1; current .3 slice): Full public checker additionally rejects six retired bare-selector literals on five lines in the inference fixture and the exact old paragraph literal in the new reviewer. The private probe is not a runtime admission, but source retirement still forbids duplicate positive spellings. Retain the current publication/reader/evidence before edits. Own a six-literal migration to the retained quoted-literal array constructor, fragment the historical prose reconstruction, prove paired unchanged assertion names and supplied consumers, and run unchanged executable/public checkers. Original fixture bytes remain recoverable at clean CDC; no production or scanner implementation change.

  Canonical claim-path blocker ownership (P1; focused alias verified in current .3 slice): Nine doctrines pass; CLAIM-VERIFICATION rejects untracked input rgx/README.md. Actual public70 discovery reads RGX's published README, but LinkedSpec tracks only its Gitlink. Own exact read-only published-document snapshot and one input alias here, requiring current/public capture hashes to match. Retain the rejected publication/producer and actual guard RED; do not inspect dependency implementation, relax tracked-input validation or change any dependency pin. Exact published bytes match both actual public captures; the final104808-byte record replaces only this untracked durability path. Retain the actual partial publisher name-binding failure and exact one-token correction before publication.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2`
  Status: `done` / bounded local-return and block-value implementation complete; independent private admission remains open
  Goal: Block-local return and block-value required dependency boundaries.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3`
  Children: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.0`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.1`.
  Owned paths: MethodLowering required return seams in _lower_block_local_return_payload_expr and _lower_block_value_expr; focused fixtures/proof/claim, Knowledge/book/continuity.
  Planned tier: `focused`
  Planned focused proof: Actual invoked callbacks, AST-first/retained fallback path controls, native local-return/value shape, caller maps/aliases/errors and exact diagnostics; separate validation-only normalizer requirement in block-value owner. Supplied direct consumers, semantic source faults and complete relevant book.
  Planned canonical boundary: none for bounded private implementation; original admission owners retain closeout.
  Planned claim record: none: Declare bounded source-bound measurement at activation.
  Acceptance: Preserve current claim inputs before writes; retain existing AST-first and guarded local-return behavior. Commit before guarded AST .3.1.3; no independent parent admission inferred.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.0`
  Status: `done` / `focused-signoff-complete; normal doctrine hooks govern landing` (activated from clean `268891fdf948b1ccf875087416b62100e0ddc059`)
  Goal: Isolate the two required callbacks of block-local return without changing native payload behavior.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.3`
  Owned paths: Only the required resolver return in _lower_block_local_return_payload_expr; focused main/cold fixtures, retained producer/reviewer/claim, relevant Knowledge/book and continuity. The payload helper is explicitly controlled; block-value AST/fallback, optional/direct and pipeline remain separate.
  Verification tier: `focused`
  Focused checks: Actual parser/normalizer native string/undefined/fatal ledgers, shared argument array and public callbacks, opaque/known publication separation, exact diagnostics and payload guards; paired original/current complete TAP, three semantic source faults, unchanged supplied33/152 plus two fixtures, historical399-input preservation with actual corruption RED/restoration, complete recursive-include book and evidence controls; standard public Phase0 compatibility, ordinary doctrines, both history checks and diff hygiene.
  Canonical trigger: None for this bounded private required binding; complete private Phase0/mapped/parent and final push admission remain independently owned.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.0.json`
  Acceptance: Preserve all399 current capacity/audit claim live bindings at clean268891fdf before their source/book/history inputs change. Edit exactly one required return. Preserve parser-result argument identity, existing scalar copies, error effects/fatal objects, undefined/empty/zero payload guards and brace prefix. Do not infer complete payload-helper, block-value or language admission. Commit before .3.1.2.2.1.

  Result: Bounded proof PASS115 main/cold4, two invoked roles/six exact native-current ledgers and three effective source faults. Identical complete115 assertion names retain6 original publication-isolation REDs/109 original controls/all115 current GREEN. Supplied35/154, five actual reviewer REDs/restoration, original-binding RED/restoration and complete book57+32/three controls pass. All399 original capacity/audit live bindings remain historical at268891fdf; both older historical claims and all prior proof/hash fields stay exact. The65482-byte readonly publication gates273 current inputs and the complete original record/final publisher through two compact historical inputs.
  Signoff evidence: docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.0-* retain actual producers, every supplied input hash, full native/TAP/consumer/fault channels, independent source edits, all evidence counterfactuals/restoration and complete packed book HTML/channels. The payload helper is explicitly controlled; no complete helper/AST/fallback/authored-language or pipeline admission is inferred.
  Reverify: final-review.py, preservation-control.py and publish-claim.py under tools/run_python_project_data.sh; defaults are readonly. Capture/freezer and --capture publication are one-shot writers. Prior factory/runtime/book reviewers require their recorded accepted Git boundaries.
  Verification: Bounded source-bound proof complete; standard public Phase0 passes1035/1035 and both required Perl syntax checks pass. Knowledge1328/10184 and diff hygiene pass; changes267/55188 WARN below rollover, engineering171/33237 OK. Ordinary doctrine hooks and final history/memory checks govern landing. Block-value .3.1.2.2.1 follows a clean commit.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.0 - isolate local return required callbacks`

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.1`
  Status: `done` / `focused-signoff-complete; normal doctrine hooks govern landing` (activated from clean `de3b50dd06d4aff6babf379282f90368810d49e5`)
  Goal: Isolate block-value required dependencies while retaining AST-first dispatch and guarded legacy fallback.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.0`
  Owned paths: Required resolver return in _lower_block_value_expr; focused fixtures/proof/claim, Knowledge/book and continuity.
  Verification tier: `focused`
  Focused checks: Actual trim/split/parse native string/undefined/fatal ledgers; locally validated never-invoked normalizer and exact diagnostics; actual copied AST bridge/early-return/fallback/guarded local-return/shared-split-array paths under explicit secondary controls. Paired complete original/current TAP, three effective source faults, unchanged supplied35/154 plus two fixtures, original273-input preservation with actual corruption RED/restoration, evidence controls and complete recursive-include book. Standard public Phase0, syntax, ordinary doctrines/history/diff hygiene.
  Canonical trigger: None for bounded private implementation; original complete private Phase0/mapped/parent and final push owners retain admission.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.1.json`
  Acceptance: Preserve all273 original local-return live bindings at clean de3b50dd0 before bound writes. Bind exactly one required resolver return. Preserve AST-first dispatch and copied bridge dependencies, existing fallback/native aliases/errors/public maps and guarded nonfinal returns. Distinguish local normalizer validation from actual trim/split/parse invocations; controlled secondary helpers do not admit complete helper or authored-language behavior. Commit before guarded AST .3.1.3.

  Result: Bounded proof PASS222 main/cold5, three invoked roles/nine exact native-current callback ledgers, one validation-only role, sixteen controlled branch ledgers and three effective source faults. Identical complete222 assertion names retain9 original isolation REDs/213 original passing controls/all222 current GREEN. A single trim publication avoids multiple-publication ambiguity masking. Actual split-array aliases, copied bridge map, zero/reference early results and native effects/errors survive; three controlled generated blocks have independent Perl execution return-value/side-effect oracles. Supplied37/156, five actual reviewer REDs/restoration, original-binding RED/restoration and complete book57+32/three controls pass. All273 original local-return live bindings stay historical at de3b50dd with all original proof/hash fields and the already historical claim exact. Readonly publication gates275 current inputs in66597 bytes and the complete original record/actual final publisher through two compact historical inputs.
  Signoff evidence: docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.1-* retain actual producers, full native/TAP/consumer/fault channels, source edits, supplied input hashes, evidence counterfactuals/restoration and complete packed book HTML/channels. AST parsing and secondary helpers have explicit controlled results; real brace/fat-arrow helpers execute only supplied bounded cases. No complete secondary-helper/grammar/language or pipeline admission follows.
  Reverify: final-review.py, preservation-control.py and publish-claim.py under tools/run_python_project_data.sh; defaults readonly. Capture/freezer and --capture publication are one-shot writers. Earlier reviewers require accepted Git inputs; local-return requires de3b50dd.
  Verification: Bounded runtime/evidence/book reviews and both required Perl syntax checks pass. Claim gate PASS105 records/129 claims/7 existing disclosed gaps; new claim has all three legs. Knowledge1329/10191, memory architecture and diff hygiene pass; changes273/56714 WARN below rollover, engineering175/34220 OK. Standard public Phase0 compatibility passes1035/1035 in1204 seconds. Final history/memory/diff and normal doctrine hooks govern landing; guarded AST .3.1.3 follows a clean commit.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.1 - isolate block value required callbacks`

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3`
  Status: `active` / four bounded guarded AST children
  Goal: Guarded AST required dependency boundaries with separate native validation-order proof.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.1`
  Children: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.0`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.1`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.2`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.3`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.4`.
  Owned paths: MethodLowering required seams in _lower_ast_scalar_held_hash_index_assignment_value_node, _lower_ast_call_statement, _lower_ast_array_end_mutation_method_statement, _lower_ast_assignment_operator_statement; focused fixtures/proof/claim, Knowledge/book/continuity. Optional/direct calls remain .3.2.
  Planned tier: `focused`
  Planned focused proof: Actual native/current caller behavior, opaque dependency separation, contexts/aliases/effects/errors/public maps, retained source-bound faults/consumers and complete relevant book.
  Planned canonical boundary: none for bounded private implementation; original full-private/mapped/canonical owners retain admission.
  Planned claim record: none: Planning only; declare source-bound measurement at activation.
  Acceptance: Preserve actual public references and native behavior. Commit each bounded family before advancing; no independent parent admission inferred.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.0`
  Status: `done` / `focused-signoff-complete; normal doctrine hooks govern landing` (activated from clean `b50ce085a63c8777973bc4c4e4a999a8840c462b`)
  Goal: Isolate the guarded scalar-held hash-index assignment key callback without changing native guard or source-fallback order.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.2.2.1`
  Owned paths: Only the required resolver return in _lower_ast_scalar_held_hash_index_assignment_value_node; focused main/cold fixtures, retained producer/reviewer/claim, Knowledge/book and continuity. Source extraction, mutation-value lowering and final assembly have explicit secondary controls; other guarded AST owners remain separate.
  Verification tier: `focused`
  Focused checks: Actual required key callback native string/undefined/fatal ledgers, scalar context/copy/alias/effects/errors/fatal identity/public maps, opaque/known publication and actual identity; actual node/target guards before dependency validation, source/fallback/output guards and exact missing/non-CODE diagnostics under explicit secondary controls. Paired full original/current TAP, three effective semantic source faults, unchanged supplied37/156 plus two fixtures, original275-input preservation with actual corruption RED/restoration, evidence controls and full recursive-include book. Standard public Phase0 and Perl syntax, ordinary doctrines/history/memory/diff checks.
  Canonical trigger: None for bounded private implementation; original full-private/mapped/parent and final push owners retain admission.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.0.json`
  Acceptance: Preserve all275 original block-value live bindings at clean b50ce085a before bound writes. Edit exactly one required return. Preserve nonmatching-node/invalid-target early rejection, eager validation for valid nodes, source fallback, actual callback identity, copied key-source scalar and all existing native results/errors. Explicit secondary controls admit no complete source/payload/assembly helper, AST grammar or authored-language behavior. Commit before .3.1.3.1.

  Result: Bounded proof PASS171 main/cold4, one invoked role/three full native-current callback ledgers, fifteen bounded branch ledgers and three effective syntax-valid source faults. Same complete171 assertion names retain3 original isolation REDs/168 passing controls/all171 current GREEN. Actual guard/validation/source-fallback order, copied key scalar, public callbacks and native effects/errors/fatal identity survive under explicit source/payload/assembly controls. Supplied39/158, five reviewer REDs/restoration, original-binding RED/restoration and full book57+32/three controls pass. All275 original block-value live bindings remain historical at b50ce085a with every old proof/hash field and the already historical claim exact. Readonly publication gates280 live inputs in67806 bytes plus two compact historical inputs.
  Signoff evidence: docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.0-* retain actual producers, all native/TAP/fault/consumer channels and inputs, exact evidence counterfactuals/restoration and complete packed book channels/HTML. Draft producer/two baseline results are retained; final producer differs only by stale header and both original baseline rows otherwise compare exactly. Production changes exactly one required return; complete secondary-helper/AST grammar/language and independent private admissions remain open.
  Reverify: final-review.py, preservation-control.py and publish-claim.py under tools/run_python_project_data.sh; defaults readonly. Capture/freezer and --capture publication are one-shot writers. Earlier reviewers require accepted Git inputs; block-value requires b50ce085a.
  Verification: Bounded runtime/evidence/book and readonly publication reviews pass; both required Perl syntax checks pass. Standard public Phase0 compatibility passes1035/1035 in1200 seconds. Claim gate PASS106 records/131 claims/7 existing disclosed gaps; new claim has all three legs. Knowledge1330/10199, memory and diff checks pass; changes279/57967 WARN below rollover, engineering179/35057 OK. Final history/memory/diff and normal doctrine hooks govern landing. AST call statements .3.1.3.1 follow a clean commit.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.0 - isolate guarded AST hash key callbacks`

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.1`
  Status: `done` / `focused-signoff-complete; normal doctrine hooks govern landing` (activated from clean `2e9e5443ea38789fe454ee7ee24a68be81d4546c`)
  Goal: Isolate all six required AST call-statement callback roles while retaining branch-specific validation and native argument behavior.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.0`
  Owned paths: Only required resolver return in _lower_ast_call_statement; bounded main/cold fixtures, retained producer/reviewer/claim, Knowledge/book/continuity. Optional assignment callback and direct/secondary helpers stay outside this admission.
  Verification tier: `focused`
  Focused checks: Six actual required roles (normalizer, trim, hash extraction, key lowering, array extraction, primitive lowering), native string/undefined/fatal ledgers, scalar contexts, actual argument ARRAY/slot aliases versus local scalar copies, effects/errors/fatal/public map identities. Eager versus lazy branch validation/guard order, opaque/known publication separation, exact diagnostics, bounded return/return_undef/set/set_key/push behavior under explicit secondary-helper controls. Paired full original/current TAP, three syntax-valid semantic faults, supplied39/158 plus two fixtures, original280-input preservation with corruption RED/restoration, evidence controls and full recursive-include book. Standard public Phase0/Perl syntax and ordinary doctrines/history/memory/diff.
  Canonical trigger: None for bounded private implementation; full-private/mapped/parent/final push admissions remain separate.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.1.json`
  Acceptance: Preserve all280 current hash-key inputs at clean 2e9e5443e before bound writes. Change exactly one required return; retain callback references, native results, lazy validation order and actual aliases/copies. Normalizer/trim are eager, hash/key require successful set_key normalization, array extractor precedes push arity checks, primitive lowerer follows arity/scoped-target guards. Explicit source/secondary helpers admit no complete helper, AST grammar, authored-language, optional/direct or independent private behavior. Commit before .3.1.3.2.

  Result: Bounded runtime/book proof PASS695 main/cold12; six invoked roles/eighteen complete native-current callback ledgers and44 bounded branch ledgers. Same complete695 names retain18 original isolation REDs/677 passing controls/all695 current GREEN. Three effective syntax-valid complete source faults, supplied41/160, five reviewer REDs/restoration, original-binding RED/restoration and full book57+32/three controls pass. All280 original hash-key bindings remain historical at2e9e5443e with every old proof/hash field and the already historical claim unchanged. Readonly publication gates279 live inputs in67298 bytes plus two compact historical inputs.
  Signoff evidence: docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.1-* retain actual producers, complete native/TAP/fault/consumer channels and inputs, exact evidence counterfactuals/restoration and lossless packed full book channels/HTML. Actual required guards/order/aliases/copies/fallback execute under explicit secondary helpers. Production changes exactly one required return; optional assignment callback, complete helpers/AST grammar/language and independent admissions remain open.
  Reverify: final-review.py, preservation-control.py and publish-claim.py under tools/run_python_project_data.sh; defaults readonly. Capture/freezer/--capture are one-shot writers. Earlier reviewers require accepted Git inputs; hash-key requires2e9e5443e.
  Verification: Bounded runtime/evidence/book/readonly publication PASS; both required Perl syntax checks PASS. Standard public Phase0 passes1035/1035 in1186 seconds. Claim107 records/133 claims/7 existing disclosed gaps PASS; new record has all three legs. Knowledge1331/10207 PASS; final bounded history/memory/diff and normal doctrine hooks govern landing. Commit before array-end .3.1.3.2.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.1 - isolate AST call required callbacks`

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.2`
  Status: `pending`
  Goal: AST array-end mutation required symbol-extraction boundary.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.1`, `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.4`
  Owned paths: Required resolver return in _lower_ast_array_end_mutation_method_statement; bounded fixtures/proof/claim, Knowledge/book/continuity. Optional/direct callbacks stay .3.2.
  Planned tier: `focused`
  Planned focused proof: Actual symbol callback, pre-validation node/method/arity guards, native receiver fallback, context/aliases/effects/errors/maps and publication separation; source faults, supplied consumers and complete book under explicit secondary-helper controls.
  Planned canonical boundary: none for bounded private implementation; original admissions remain open.
  Planned claim record: none: Declare measured record at activation.
  Acceptance: Preserve current bindings before writes and actual references/native behavior; commit before .3.1.3.3.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.3`
  Status: `pending`
  Goal: AST assignment-operator required callback boundaries.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.2`
  Owned paths: Required resolver return in _lower_ast_assignment_operator_statement; bounded fixtures/proof/claim, Knowledge/book/continuity. Optional/direct callbacks stay .3.2.
  Planned tier: `focused`
  Planned focused proof: Distinguish actual invoked and path-specific validation roles; retain native guarded assignment behavior, contexts/aliases/effects/errors/maps and publication separation. Effective source faults, supplied consumers and complete book; refine before writes if branch scope exceeds one safe slice.
  Planned canonical boundary: none for bounded private implementation; original admissions remain open.
  Planned claim record: none: Declare measured record at activation.
  Acceptance: Preserve current bindings before writes and actual references/native behavior; commit before main method/value .3.1.4. No independent parent admission inferred.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.4`
  Status: `done` / `exact staged canonical receipt and normal hooks govern admission` (activated from clean `9085eb1e5075146ca00dab52304f85937cf7ea05`)
  Goal: Admit exactly one change-history archive member and measured manifest/decision overhead before further guarded AST slices.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.1`
  Owned paths: CHANGES.md and one new immutable clean-source suffix/manifest generation; one exact registry row change for change_history and exact indexed ADR prerequisite; move the unchanged0130/0131 index rows from below the authoring instructions into the existing table; bounded capacity producer/reviewer/claim, Knowledge and continuity. Existing runtime/source/tests, all older immutable bytes, root/per-file/aggregate ceilings and unrelated registry fields remain unchanged. Review/render existing mdBook teaching; no public semantics change.
  Verification tier: `canonical`
  Focused checks: Retain actual pressure RED before governed rollover GREEN; independently reconstruct exact clean-source suffix/blob/range/digest, current root and all older archive/manifest/decision bytes. Execute unchanged production threshold and accepted/indexed/exact-object authority functions with actual measured inputs and distinguishing REDs; reason-sensitive reviewer corruptions/restoration; current279-input AST-call preservation before bound writes and full book/include render. Normal doctrines/history/Knowledge/memory/diff and exact staged canonical CI/receipt.
  Canonical trigger: Registry capacity and decision/history infrastructure require exact staged canonical admission; focused proof alone cannot land.
  Claim verification: `docs/claims/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.4.json`
  Acceptance: Current CHANGES58706 bytes is276 bytes below mandatory rollover; collection48 files and manifest47 lines/26831 bytes reach admitted limits. Own the imminent required rollover rather than discard/shorten accepted history. Admit only one actual archive and its exact manifest growth plus this sole indexed ADR overhead under ADR0128/0129/0131 engineering precedent; no future reserve or new director grant. Preserve279 current AST-call inputs at clean9085eb1e5 before bound writes; no old measurement/hash refresh. Resume .3.1.3.2 only after canonical clean commit.

  Owned defect: Decision INDEX.md places accepted0130/0131 rows below `## How to add a record`, outside its table (reproduce by reading that marker through EOF). Actual previous capacity producer appended old(INDEX)+INDEX_ROW; unchanged index lookup accepts links anywhere, so normal gates did not reject this presentation drift. Preserve both exact row bytes and all existing prose, move them in numeric order into the table, then insert only0132. The new producer/reviewer must derive the complete exact transformation and a displaced-row counterfactual must fail; no old ADR or accepted producer is rewritten.
  Instrument recovery: Initial capacity writer correctly observes actual pressure255/lowercase rollover-required text but its uppercase REQUIRED matcher rejects before archive/manifest/registry/index/ADR/book writes. Retain exact draft producer, original pressure and two draft hot-root records; restore only those exact newly inserted records to clean base, correct only the two matcher literals, and capture supplied-isolation replay before retry. No production checker or history threshold changes.
  Applied-instrument recovery: Actual rollover succeeds; independent CHANGES prefix/suffix/range/digest agree. Initial copied readonly reviewer names the old NOTES source blob, so capture stops before production controls. Retain exact applied producer, unchanged original plan and fresh actual source-blob RED. Current reviewer corrects only that source-blob path and identifies the retained actual apply producer; no measured plan hash is refreshed. Preserve the unpublished draft replay reviewer too; its first unanchored heading guard matched inline `## ` in the CHANGES preamble, and the final guard anchors real headings. All dependent follow-ups now require successful preceding exits.
  Exact overhead correction: Initial index placement adds one row and one separating LF, so actual decisions census is133 files/13180 lines while the first metadata allowance is13179. Retain original applied producer/plan/control channels and both initial metadata files unchanged; their production threshold row records actual13180 rejected at13179. Separate final-capacity producer derives physical index growth, corrects only that same-width scalar in registry/ADR, writes a separately named final plan/control/evidence set and rejects any measured census above admitted ceilings. No initial measurement or hash is replaced.

  Result: Focused finite proof PASS222 prior immutable files/30 production threshold/23 authority cases/four actual reviewer corruptions and exact restoration. Clean9085eb1e5 change suffix lines172–283 (112 lines/27100 bytes) becomes segment4964-a4dea8bac129; current root179/32305. Admit exactly change_history files48→49, manifest47→48 lines/26831→27407 bytes, decisions132→133 files/13144→13180 lines. Existing root/per-file/aggregate limits and unrelated physical registry rows remain exact. Restore unchanged0130/0131 index rows to the table, add only0132 and preserve old prose. Original279 AST-call inputs stay historical with mode/revision-only changes and actual corruption RED/restoration. Full book57+32/three controls PASS. Readonly publication gates356 live inputs in86568 bytes plus two compact historical inputs.
  Signoff evidence: docs/checkpoints/PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.4-* retain actual draft/applied/final producers and original/initial/final channels, exact roots/metadata/plans and all counterfactual bytes. Initial uppercase pressure guard, stale source-blob expectation and one-line separator undercount remain explicit retained REDs; no original measured hash/result is refreshed. Finalizer changes only the exact same-width decision line scalar in registry/ADR and produces separately named final proof. Actual census fits every admitted ceiling. Source/runtime/tests, old ADRs and dependency pins remain unchanged.
  Reverify: final-review.py and publish-claim.py under tools/run_python_project_data.sh; defaults readonly. Initial capacity.py requires retained initial metadata, current final-capacity.py owns corrected proof. Capture/freezer/repair and --capture are one-shot writers. Earlier AST-call reviewers require accepted9085eb1e5 Git inputs.
  Gate preparation: An early README check began before staging, fixing INDEX_MODE false and rejecting the absent newly staged ADR authority. Source trace identifies staged_result_exists/staged_new_adrs; the complete staged rerun passes20 surfaces/62 routes/40 mutation classes without record/checker changes. Claim verification passes108 records/135 claims/7 existing disclosed gaps. ADR0132 retains its initial-instrument review reference; the current readonly entrypoints are the final-review.py/publish-claim.py commands above.
  Verification: Focused composed runtime-free capacity/preservation/instrument/book proof PASS. Knowledge1332/10215; both bounded-history checks and diff hygiene PASS. Canonical tier requires tools/run_ci_local.sh for the exact final staged candidate, its bound receipt and all normal doctrine hooks before landing; focused evidence alone admits no capacity. Guarded AST array-end .3.1.3.2 follows a clean canonical commit.
  Commit: `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.4 - admit finite guarded AST history capacity`

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
| 1 | `PERL-PRIVATE-FACTORY-CAPTURE.3.1.3.2` | `pending` | Activate bounded AST array-end mutation from clean HEAD; preserve356 current claim inputs before bound writes. |
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

## Verification Log

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

## Changelog

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
