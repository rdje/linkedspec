# PERL-PRIVATE-FACTORY-CAPTURE: Actual factory and dependency emission capture

## Metadata

- Tree ID: `PERL-PRIVATE-FACTORY-CAPTURE`
- Status: `active` / framework accepted; Contracts integration next
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
  Status: `pending`
  Goal: Actual built-in contract lower registration plus separate injected dependency calls. Reuse the canonical input_slice opaque-delegation diagnosis; prove current factory behavior without changing public maps/callback fields.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.1`
  Owned paths: `perl/LinkedSpec/ActionIR/Contracts.pm`; focused fixture/proof/claim, relevant Knowledge/book and continuity. No unrelated producer or mapping changes.
  Planned tier: `focused`
  Planned focused proof: Actual/native callback and invocation identities; scalar/list/void context where applicable, aliases, once-only effects, exact return/error/fatal values, opaque nested delegation, scope restoration/release and unchanged public maps. Complete supplied direct consumers, effective semantic faults, retained instrument/input/channel identities, relevant book and ordinary doctrines.
  Planned canonical boundary: none for bounded private implementation without public/generated/mechanical change; reclassify before writes if scope crosses those boundaries. Complete private Phase0 and canonical replacement remain separately owned.
  Planned claim record: none: Planning only; declare the actual source-bound measurement record at activation before publishing results.
  Acceptance: Follow the retained owner plan; choose no authority by name, copied metadata or equal value. Preserve existing selected input grants and callback references. Split further before writes if actual code paths exceed a safe slice. Commit before activating the next owner.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.3`
  Status: `pending`
  Goal: Actual default native callback registration and injected method/value dependency boundaries. Split by function families before writes if this owner exceeds a safe slice.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.2`
  Owned paths: `perl/LinkedSpec/ActionIR/MethodLowering.pm`; focused fixture/proof/claim, relevant Knowledge/book and continuity. No unrelated producer or mapping changes.
  Planned tier: `focused`
  Planned focused proof: Actual/native callback and invocation identities; scalar/list/void context where applicable, aliases, once-only effects, exact return/error/fatal values, opaque nested delegation, scope restoration/release and unchanged public maps. Complete supplied direct consumers, effective semantic faults, retained instrument/input/channel identities, relevant book and ordinary doctrines.
  Planned canonical boundary: none for bounded private implementation without public/generated/mechanical change; reclassify before writes if scope crosses those boundaries. Complete private Phase0 and canonical replacement remain separately owned.
  Planned claim record: none: Planning only; declare the actual source-bound measurement record at activation before publishing results.
  Acceptance: Follow the retained owner plan; choose no authority by name, copied metadata or equal value. Preserve existing selected input grants and callback references. Split further before writes if actual code paths exceed a safe slice. Commit before activating the next owner.

- ID: `PERL-PRIVATE-FACTORY-CAPTURE.4`
  Status: `pending`
  Goal: Actual default callbacks and flow-composite injected dependency boundaries, preserving native effects and arguments.
  Dependencies: `PERL-PRIVATE-FACTORY-CAPTURE.3`
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
| 1 | `PERL-PRIVATE-FACTORY-CAPTURE.2` | `pending` | Actual Contracts callbacks and injected dependencies after accepted standalone framework. |
| 2 | `PERL-PRIVATE-FACTORY-CAPTURE.3` | `pending` | Depends on the preceding bounded owner. |
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

## Verification Log

Planning/routing verification belongs to `SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.1.1.2.1.3.0`.

- `2026-10-10`, `.1`: PASS224/11, native30, supplied17/136, evidence4/book57/2 and original232 preservation. The four initial draft identity failures are retained and diagnosed, with no production change hidden by their fixture correction. SourceEmissions syntax is checked in every source-fault run; direct supplied consumers recur. All normal doctrine hooks are required before landing.
- `2026-10-10`, `.1`: Initial commit hooks rejected the missing formal acceptance checklist in this new tree. The completed checklist above now cites the existing actual proof and its limits; no runtime instrument, artifact or source changes for this workflow correction.

## Commit Log

The planning commit belongs to the original tree. Every implementation leaf records its own result and commit
beside its stable ID; Git is the commit-identity authority.

- `.1`: `PERL-PRIVATE-FACTORY-CAPTURE.1 - isolate native dependency calls`, from clean02345ee21; no push.

## Changelog

- `2026-10-10`: Created the linked bounded implementation tree under the existing private producer protocol.
- `2026-10-10`: `.1` accepts the standalone actual registration/native dependency framework and hands off to Contracts `.2`. Initial fixture reference reuse is durably diagnosed; factory/pipeline activation remains open.
