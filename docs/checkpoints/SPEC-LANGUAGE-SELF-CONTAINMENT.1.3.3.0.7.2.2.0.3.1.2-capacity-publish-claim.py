"""Complete claim publication after the retained partial continuity writer; never replay docs."""
from pathlib import Path
import ast
import base64
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
LEAF = 'SPEC-LANGUAGE-SELF-CONTAINMENT.1.3.3.0.7.2.2.0.3.1.2'
PREFIX = 'docs/checkpoints/' + LEAF + '-'
CURRENT = 'DEVELOPMENT_NOTES.md'
MANIFEST = 'docs/history/development-notes/manifest.jsonl'
REGISTRY = 'doctrine/readme_stability/routes.jsonl'

def sha(raw):
    return hashlib.sha256(raw).hexdigest()

def read_json(path):
    return json.loads((ROOT / path).read_bytes())

plan = read_json(PREFIX + 'capacity-plan.json')
verification = read_json(PREFIX + 'capacity-verification.json')
instrument = read_json(PREFIX + 'capacity-instrument-verification.json')
error = read_json(PREFIX + 'capacity-finish-error.json')
initial_source = (ROOT / error['retained_source_path']).read_bytes()
assert sha(initial_source) == error['source_sha256'], 'exact partial continuity producer'
raw_error = base64.b64decode(error['tool_returned_channel']['base64'], validate=True)
assert sha(raw_error) == error['tool_returned_channel']['sha256'] and len(raw_error) == error['tool_returned_channel']['bytes']
assert error['tool_metadata']['exit_code'] == 1 and b"NameError: name 'CURRENT' is not defined" in raw_error
summary_nodes = [node for node in ast.parse(initial_source).body if isinstance(node, ast.Assign)
                 and any(isinstance(target, ast.Name) and target.id == 'summary' for target in node.targets)]
assert len(summary_nodes) == 1, 'one original static measurement statement'
summary = ast.literal_eval(summary_nodes[0].value)
assert isinstance(summary, str) and verification['complete'] and instrument['complete']
assert len(verification['evidence_controls']) == 14 and len(instrument['controls']) == 5
assert (ROOT / 'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md').read_text().count('## Acceptance Checklist — '+LEAF) == 1
assert (ROOT / 'CHANGES.md').read_text().count('## 2026-10-08 — '+LEAF+' - retain finite replacement-note history') == 1
assert sha((ROOT / CURRENT).read_bytes()) == plan['retained_root']['sha256'], 'actual root unchanged since proof'
assert sha((ROOT / MANIFEST).read_bytes()) == plan['new_manifest']['sha256'], 'actual manifest unchanged since proof'
guarded = [CURRENT,MANIFEST,REGISTRY,'MEMORY.md','CHANGES.md','LIVE_ACHIEVEMENT_STATUS.md',
           'docs/tasks/SPEC-LANGUAGE-SELF-CONTAINMENT.md','docs/TASK_TREE.md','ROADMAP.md','ROADMAP_V2.md',
           'docs/knowledge/replacement-repair-engineering-history-capacity.md','docs/knowledge/routing-decision-accepted-state-gap.md']
before = {path: sha((ROOT/path).read_bytes()) for path in guarded}
publication = {'complete':True,'producer_sha256':sha(Path(__file__).read_bytes()),
               'original_partial_producer_sha256':sha(initial_source),'original_statement_sha256':sha(summary.encode()),
               'guarded_document_inputs':before,
               'scope':'Claim-only continuation after the retained first continuity writer NameError. Static original statement recovered without importing or executing its document edits; no history, policy or continuity replay.'}
(ROOT/(PREFIX+'capacity-publication-verification.json')).write_text(json.dumps(publication,indent=2)+'\n')
extras = [CURRENT,MANIFEST,REGISTRY,'docs/decisions/0128-replacement-note-history-capacity.md','docs/decisions/INDEX.md',
          'docs/knowledge/replacement-repair-engineering-history-capacity.md','docs/knowledge/routing-decision-accepted-state-gap.md',
          'tools/roll_document_history.pl','tools/read_document_history.pl','scripts/check_readme_routing_pressure.pl',
          'tools/project_data_env.sh','tools/project_data_run.sh','tools/run_python_project_data.sh',
          plan['archive_record']['target_path'],*[row['path'] for row in plan['prior_archives']]]
paths = sorted(set(extras+[p.relative_to(ROOT).as_posix() for p in (ROOT/'docs/checkpoints').glob(LEAF+'-*') if p.is_file()]))
inputs = [{'path':path,'sha256':sha((ROOT/path).read_bytes()),
           'role':'producer' if path.endswith(('.py','.pl','.sh')) else 'input'} for path in paths]
scope = ('Exactly one governed archive and manifest row from clean47444428a, three scalar controls and explicitly accepted indexed ADR0128. '
         'Actual root/manifest/registry,42 original immutable archives and producer/input channels are bound; original clean Git source/blob reconstructs independently. '
         'Actual pressure RED/rollover GREEN and full history query,14 record corruptions,18 actual production thresholds/7 exact-authority denials, five instrument corruptions. '
         'These are evidence/authority controls, not parser semantic mutants. The initial reviewer is incomplete at wrong guard dictionary selection; exact first used source, '
         'combined shell error and initial reached control channels remain retained. Distinct original stdout/stderr are unavailable. Corrected review changes only that selection. '
         'The initial continuity writer stopped at an undeclared CURRENT constant after writing docs and before claim creation; exact used source and actual tool-returned channel survive. '
         'This publisher recovers its original static statement and completes only the claim, with no document replay. '
         'Proposed/missing-status diagnostics authorize in both functions; no composed bypass claimed. P1 .3.1.3 owns immediate full-path diagnosis/repair; current accepted ADR is independently checked. '
         'Autonomous maintenance does not assert a new explicit director grant or unlimited reserve. All other controls/history bytes/production/test/book/CI/hook/checker/dependency bytes stay unchanged. '
         'Exact staged canonical receipt and normal hooks govern admission independently; no runtime/readiness claim. Necessary read-only OS/Perl/Python/Git inputs, project data repository-local/same-volume; other repositories read-only.')
claim = {'version':1,'owner':LEAF,'claims':[{
    'name':'finite-clean-source-engineering-history-admission','statement':summary,'scope':scope,
    'rederive':{'status':'checked',
               'command':'At clean47444428a activation run bash tools/run_python_project_data.sh '+PREFIX+'capacity-plan.py then '+PREFIX+'capacity-apply.py. At the published boundary run bash tools/run_python_project_data.sh '+PREFIX+'capacity-review.py and '+PREFIX+'capacity-instrument-review.py. Original captures remain exact; claim-only continuation is '+PREFIX+'capacity-publish-claim.py.',
               'granularity':json.dumps(verification,sort_keys=True),'result':summary},
    'falsify':{'status':'checked','hypothesis':'Equal aggregate values or matching routing markers alone prove lossless finite accepted admission.',
              'oracle':'Independent original Git root/suffix/manifest/archive reconstruction, exact unchanged fields, actual full query and pressure channels; independently checked current accepted Status and actual unchanged authorization functions.',
              'red_control':'Actual pressure255 before apply0;14 evidence corruptions,7 actual indexed-authority denials,18 independent threshold observations and5 instrument denials. Two extra status fixtures authorize in both actual functions and remain separately owned; they are not rejecting controls.'},
    'durability':{'status':'checked','mode':'live','inputs':inputs}}]}
(ROOT/('docs/claims/'+LEAF+'.json')).write_text(json.dumps(claim,indent=2)+'\n')
assert before == {path:sha((ROOT/path).read_bytes()) for path in guarded}, 'no document/history/policy replay'
print(json.dumps({'complete':True,'owner':LEAF,'bound_inputs':len(inputs),'canonical_pending':True,'documents_unchanged':True}))
