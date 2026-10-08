"""Publish the composed claim after both rejected candidates and original cleanup preservation."""
from pathlib import Path
import base64
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.3'
PREFIX = 'docs/checkpoints/'+LEAF+'-'
CLAIM = 'docs/claims/'+LEAF+'.json'
def sha(raw): return hashlib.sha256(raw).hexdigest()
def read(path): return (ROOT/path).read_bytes()
def data(name): return json.loads(read(PREFIX+name+'.json'))

review = data('verification')
semantic = data('semantic-controls')
docs = data('docs-verification')
workflow = data('workflow-claim-verification')
rejected = data('workflow-claim-rejected')
assert workflow['complete'] and workflow['recovered_regular_inputs'] == 5177
assert workflow['rejected_guard_inputs_recovered'] == 72 and workflow['original_cleanup_inputs_verified'] == 21
assert len(workflow['preservation_red_controls']) == 7
assert data('workflow-claim-freeze')['frozen_sha256'] == sha(read('docs/claims/REPO-HYGIENE.11.json'))
assert docs['complete'] and docs['recovered_regular_inputs'] == 5167 and docs['original_claim_inputs_recovered'] == 61
assert docs['ci_chapter_lines'] == 2047 and len(docs['book_migration_red_controls']) == 4
assert review['complete'] and semantic['complete']
assert review['regular_inputs'] == 5137 and review['frozen_original_inputs'] == 447
assert review['component_observations_each_epoch'] == 25 and review['complete_full_gate_observations_each_epoch'] == 9
assert review['effective_source_inverse_mutants'] == 9 and review['independent_authority_denials'] == 10 and review['pressure_boundaries'] == 21
assert len(review['evidence_red_controls']) == 7
for epoch in ('before','after'):
    assert all(data(epoch+'-'+name)['complete'] for name in ('components','resulting-tree','readme-caps'))
    components = data(epoch+'-components')['observations']
    full = data(epoch+'-resulting-tree')['observations']+data(epoch+'-readme-caps')['observations']
    assert sum(row['policy_result'] == 'RED' for row in components) == (15 if epoch == 'before' else 0)
    assert sum(row['policy_result'] == 'RED' for row in full) == (6 if epoch == 'before' else 0)

paths = {p.relative_to(ROOT).as_posix() for p in (ROOT/'docs/checkpoints').glob(LEAF+'-*') if p.is_file()}
paths.update(['scripts/check_readme_stability.sh','scripts/check_readme_routing_pressure.pl',
              'README.md','README_POLICY.md','COMMIT.md','DOCTRINE_ENFORCEMENT.md','TOOLBOX.md',
              'tools/project_data_env.sh','tools/project_data_run.sh','tools/run_python_project_data.sh',
              'tools/run_mdbook_local.sh','scripts/check_claim_verification.sh','tools/check_claim_verification.py',
              'CHANGES.md','DEVELOPMENT_NOTES.md','MEMORY.md','LIVE_ACHIEVEMENT_STATUS.md',
              'ROADMAP.md','ROADMAP_V2.md','docs/TASK_TREE.md','docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md',
              'docs/knowledge/routing-decision-accepted-state-gap.md','docs/knowledge/readme-stability-policy.md',
              'docs/knowledge/supplied-policy-reference-provenance.md','docs/tasks/SESSION-STARTUP-READING.04-49.md',
              'docs/decisions/0063-bounded-readme-landing-page.md','docs/decisions/0128-replacement-note-history-capacity.md',
              'docs/decisions/INDEX.md','doctrine/readme_stability/routes.jsonl',
              'docs/linkedspec-book/src/development/local-ci-and-regression.md',
              'docs/linkedspec-book/src/development/documentation-workflow.md',
              'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.0.json',
              'docs/claims/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.2.json',
              'docs/checkpoints/SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.2-capacity-plan.json',
              'docs/claims/REPO-HYGIENE.11.json'])
publication_path = PREFIX+'workflow-publication.json'
assert publication_path not in paths and read(CLAIM) == base64.b64decode(rejected['rejected_guard_claim']['base64'],validate=True), 'one-shot composition; original unadmitted record preserved exactly'
guard = {path:sha(read(path)) for path in sorted(paths)}
publication = {'complete':True,'producer_sha256':sha(Path(__file__).read_bytes()),'guarded_inputs':guard,
               'scope':'Current claim-only publication after independent5177-regular second-stage/all72-input recovery and21-input cleanup mode/revision-only qualification, plus independent recovery of original rejected5167-regular staged candidate/all61 original inputs and lossless book routing. The initial unadmitted record/source/publication and actual failed canonical combined log remain verbatim, not falsely frozen at eb6. Complete original graphs/overlays and current final continuity/book bytes are explicit inputs. No original publication/producer/before result replay, historical source hash refresh, intermediate document-state measurement or canonical receipt assertion.'}
(ROOT/publication_path).write_text(json.dumps(publication,indent=2)+'\n')
paths.add(publication_path)
inputs = [{'path':path,'sha256':sha(read(path)),'role':'producer' if path.endswith(('.py','.pl','.sh')) else 'input'} for path in sorted(paths)]
statement = ('Five actual README/routing authority branches require one accepted Status field while preserving qualified/bare acceptance, indexed exact transition markers and independent pressure checks. '
             'Retained before/after25 component observations change15 policy violations to rejections; each epoch retains nine complete Git-tree gates across routed increases and separately reached README-cap governance: three accepted positives and six proposed/missing violations. '
             'All six violations pass before and reject for accepted-state admission afterward. Fifty original/current component channels recur exactly;30 supplemental duplicate/token observations distinguish uniqueness and exact state semantics. '
             'Nine effective inverse source mutants, ten index/marker denials,21 pressure boundaries and seven independent evidence RED controls pass. Complete5137-regular Git supersets and exact overlays/staged diffs recover independently. '
             'All447 original diagnosis/capacity hashes are preserved at their original committed boundaries by mode/revision-only qualification. Three capture/review preparation error types retain exact sources/combined errors and separate actual Git recurrences; corrected complete gates and independent review pass. '
             'Initial canonical doctrine rejects the CI chapter at2064/2048 lines with nine other doctrines passing; its complete5167-regular staged graph/delta recovers all61 original claim inputs. The full1022-byte authority explanation moves byte-for-byte to the workflow chapter; CI returns to2047 lines and four content-sensitive controls reject. Second canonical doctrine rejects only the older live cleanup workflow input; all72 rejected guard inputs and the complete5177-regular staged graph recover. All21 original cleanup hashes verify at owning864b1a939 and change durability mode/revision only; seven preservation controls reject. No caps or runtime behavior change.')
scope = ('Five source-bound actual branches with explicit fixture getters: routed limits/contracts, initial registry, new/initial README caps. '
         'Complete actual unchanged-before/changed-after Bash gates use historical474 HEAD with the eb6 regular resulting tree for five routed increases; a separate private synthetic HEAD is exact eb6 minus only ADR0128, parent eb6, leaving routed controls identical and making only that ADR newly added for independent cap governance. '
         'Synthetic HEAD is test data, not historical admission. Initial-registry component fixtures preserve the routing phrase independently because it occurs in original0063 Status. '
         'Full initial-registry/initial-cap/contract-changing Git scenarios are not measured; those branches have actual component/recurring proof. Supplemental before results are replay of retained original source, not a second live snapshot. '
         'All regular original Git inputs are a recoverable complete superset, not minimal IO; explicit source/policy/ADR overlays and actual private-index staged diffs are independently reconstructed. Gitlink payload is excluded/uninspected, only metadata and an empty placeholder are used. '
         'Before producers remain immutable: original initial helper, successful-before/mode-failing helper, corrected-after helper, and unchanged cap wrapper are all retained. Capture failures stop before any full gate result; the original recovery review stops before its first staged boundary review. Combined channels are complete but distinct original stdout/stderr and the first original gitlink diff are unavailable. Separate actual recurrences isolate missing gitlink placeholder, executable overlay mode and missing recovery HEAD defects and restorations; corrected independent review passes. '
         'Historical diagnosis210 at11f6a87d1 and capacity237 at eb6 preserve every prior claim field/input except declared mode/revision; current final continuity bytes are explicit inputs, with no intermediate pre-write journal claim. '
         'The first unadmitted canonical candidate fails only README-STABILITY at CI chapter2064/2048. Its complete5167-regular staged superset and recoverable20,859,422-byte full-index binary delta preserve all61 original artifact inputs, original live-form claim and exact publisher source. The initial record is an unadmitted checkpoint, not historical at eb6. Complete original combined CI log survives; an independently retained before-CI fingerprint and distinct stdout/stderr are unavailable. '
         'The full1022-byte explanation moves unchanged to the contributor workflow chapter with a reciprocal canonical link; its direct current oracle count updates32 to40 while historical results remain untouched. CI chapter2047 preserves all other content and every registry cap stays exact. Independent Git recovery and four content-sensitive migration controls establish this composition; final actual routing/render/canonical admission remain separate. '
         'The second exact staged candidate rejects only CLAIM-VERIFICATION for the dated cleanup workflow input, with nine doctrines passing. Its complete5177-regular superset and binary delta preserve the original72-input live guard record without historical qualification at eb6. Original complete combined log survives; before-CI fingerprint and distinct original stdout/stderr are unavailable. All21 original REPO-HYGIENE.11 inputs and original live record verify at owning864b1a93934ab7fd4b059b0a7cb9d4b417e33c66; only mode/revision changes, with seven effective evidence/preservation controls and independent exact-stage recovery. No census rerun or hash/measurement refresh. '
         'No global doctrine/claim-identity bypass, director approval inference, whole-project policy adoption, runtime/readiness promotion, cap change, other-repository write or submodule implementation claim. All project-owned data is repository-local/same-volume; necessary OS/Git/Perl/Python/mdBook tools are readonly external dependencies. Exact staged canonical receipt and normal hooks remain separate admission authority.')
claim = {'version':1,'owner':LEAF,'claims':[{
    'name':'unique-accepted-readme-routing-authority','statement':statement,'scope':scope,
    'rederive':{'status':'checked','command':'At the owning committed boundary run bash tools/run_python_project_data.sh '+PREFIX+'review.py and '+PREFIX+'semantic-controls.py, '+PREFIX+'docs-review.py and '+PREFIX+'workflow-claim-review.py. Full captures are retained epoch-specific producers/results; do not replay before against repaired production. Activation, error-retention and publication writers are one-shot.',
               'granularity':'Five authority branches × five original states per epoch; three supplemental states × five branches per source epoch; nine full gates per epoch with each actual complete command/status/source/input boundary retained. Seven pressure axes × under/exact/overflow. Full reachable regular snapshot plus each declared overlay; historical claim inputs verified individually.',
               'result':statement},
    'falsify':{'status':'checked','hypothesis':'Matching indexed old/new markers suffices for authority, or a blanket rejection/other pressure failure explains the repaired result.',
              'oracle':'Existing accepted-state policy and exact accepted historical decisions; separately reached actual cap governance, complete independent Git tree/object/diff recovery, per-branch status/token/uniqueness and original input identities. Accepted positives distinguish blanket rejection; retained status-specific stderr and independent pressure/freshness positives distinguish unrelated failure.',
              'red_control':'Actual before15 component and six full policy violations; nine effective actual source inverse mutants escape proposed/duplicate/token oracles; ten index/marker denials and21 pressure boundaries; seven evidence corruptions reject. Original and corrected fixture mechanisms retain separate actual Git RED/GREEN rather than attribution by inspection. Initial actual canonical doctrine rejects chapter2064/2048; four content-sensitive moved-example/counter/link/unrelated-edit controls reject after exact private staged recovery. Second actual canonical rejection isolates the stale older cleanup input; seven graph/producer/status/claim/revision/hash/measurement corruptions reject against recovered72-input stage and mode/revision-only cleanup qualification.'},
    'durability':{'status':'checked','mode':'live','inputs':inputs}}]}
encoded = (json.dumps(claim,indent=2)+'\n').encode()
assert len(encoded) <= 131072, 'bounded claim record'
(ROOT/CLAIM).write_bytes(encoded)
assert guard == {path:sha(read(path)) for path in guard}, 'all actual artifact/publisher inputs unchanged'
print(json.dumps({'complete':True,'bound_inputs':len(inputs),'claim_bytes':len(encoded),'canonical_pending':True}))
